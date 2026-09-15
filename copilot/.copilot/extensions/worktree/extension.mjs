import { execFile } from "node:child_process";
import { access } from "node:fs/promises";
import { userInfo } from "node:os";
import { basename, dirname, isAbsolute, relative, resolve, sep } from "node:path";
import { promisify } from "node:util";

import { joinSession } from "@github/copilot-sdk/extension";

const execFileAsync = promisify(execFile);

let session;

const handleWorktreeCommand = async ({ args }) => {
    try {
        const request = parseArgs(args);
        const worktree = await createWorktree(request);
        await switchToWorktree(worktree, request.prompt);
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        await session.log(message, { level: "error" });
        throw new Error(message);
    }
};

session = await joinSession({
    commands: ["canonical-worktree", "cwt", "cw"].map((name) => ({
        name,
        description: "Start a task in a new canonical Git worktree and session",
        handler: handleWorktreeCommand,
    })),
});

async function createWorktree({ prompt, requestedBranch, baseRef }) {
    const { workingDirectory } = await session.rpc.metadata.snapshot();
    const {
        canonicalRoot,
        activeWorkingDirectory,
    } = await prepareRepository(workingDirectory);
    const baseCommit = await resolveBaseCommit(
        activeWorkingDirectory,
        canonicalRoot,
        baseRef,
    );
    const suggestedBranch =
        requestedBranch ??
        (await generateBranchName(session, prompt, activeWorkingDirectory));
    const aliases = await getBranchAliases(canonicalRoot);
    const branch = await chooseBranch(
        canonicalRoot,
        suggestedBranch,
        requestedBranch !== undefined,
        aliases,
    );
    const worktreePath = getWorktreePath(branch, aliases);
    const destination = resolve(canonicalRoot, worktreePath);
    const destinationRelative = relative(canonicalRoot, destination);

    if (
        !destinationRelative ||
        isAbsolute(destinationRelative) ||
        destinationRelative === ".." ||
        destinationRelative.startsWith(`..${sep}`)
    ) {
        throw new Error("The worktree path must stay inside the canonical repository root.");
    }

    const firstSegment = destinationRelative.split(sep)[0];
    if (firstSegment === ".bare" || firstSegment === ".git") {
        throw new Error(`The worktree path cannot use the reserved ${firstSegment} entry.`);
    }
    await git(canonicalRoot, ["worktree", "add", "-b", branch, destination, baseCommit]);

    return { branch, path: destination };
}

async function prepareRepository(workingDirectory) {
    let commonDir = await getCommonDir(workingDirectory);

    if (basename(commonDir) === ".bare") {
        return {
            canonicalRoot: dirname(commonDir),
            activeWorkingDirectory: workingDirectory,
        };
    }

    if (basename(commonDir) !== ".git") {
        throw new Error(
            `The current repository uses an unsupported shared Git directory: ${commonDir}`,
        );
    }

    const worktreeList = await git(workingDirectory, ["worktree", "list", "--porcelain"]);
    const worktreeCount = worktreeList
        .split("\n")
        .filter((line) => line.startsWith("worktree ")).length;
    if (worktreeCount !== 1) {
        throw new Error(
            "Automatic migration requires a single-worktree repository. Run git worktree-migrate manually.",
        );
    }

    if ((await git(workingDirectory, ["status", "--porcelain"])).trim()) {
        throw new Error(
            "Automatic migration requires a clean checkout. Commit or stash changes first.",
        );
    }

    const repositoryRoot = dirname(commonDir);
    const currentBranch = (
        await git(workingDirectory, ["branch", "--show-current"])
    ).trim();

    if (!currentBranch) {
        throw new Error("Cannot migrate a repository in detached HEAD state.");
    }

    await session.log(`Migrating ${repositoryRoot} to the canonical worktree layout...`, {
        ephemeral: true,
    });
    await git(workingDirectory, ["worktree-migrate", repositoryRoot]);

    const migratedWorkingDirectory = resolve(repositoryRoot, basename(currentBranch));
    await session.rpc.metadata.setWorkingDirectory({
        workingDirectory: migratedWorkingDirectory,
    });

    commonDir = await getCommonDir(migratedWorkingDirectory);
    if (basename(commonDir) !== ".bare") {
        throw new Error("git worktree-migrate did not create the canonical .bare layout.");
    }

    return {
        canonicalRoot: dirname(commonDir),
        activeWorkingDirectory: migratedWorkingDirectory,
    };
}

async function resolveBaseCommit(workingDirectory, canonicalRoot, baseRef) {
    const resolveRevision = async (directory, ref) => {
        const revision = `${ref}^{commit}`;
        const exitCode = await gitExitCode(directory, [
            "rev-parse",
            "--verify",
            "--quiet",
            revision,
        ]);
        return exitCode === 0
            ? (await git(directory, ["rev-parse", "--verify", revision])).trim()
            : undefined;
    };

    const baseCommit = await resolveRevision(workingDirectory, baseRef);
    if (baseCommit !== undefined) {
        return baseCommit;
    }

    if (baseRef === "HEAD" && resolve(workingDirectory) === resolve(canonicalRoot)) {
        const remoteHeadCommit = await resolveRevision(canonicalRoot, "origin/HEAD");
        if (remoteHeadCommit !== undefined) {
            return remoteHeadCommit;
        }
    }

    throw new Error(
        `Base ref ${baseRef} does not resolve to a commit in ${workingDirectory}.`,
    );
}

async function getCommonDir(workingDirectory) {
    const commonDirOutput = await git(workingDirectory, [
        "rev-parse",
        "--path-format=absolute",
        "--git-common-dir",
    ]);
    return commonDirOutput.trim();
}

function parseArgs(rawArgs) {
    let remaining = rawArgs.trim();
    let requestedBranch;
    let baseRef = "HEAD";

    while (remaining.startsWith("-")) {
        if (remaining === "--") {
            remaining = "";
            break;
        }
        if (remaining.startsWith("-- ")) {
            remaining = remaining.slice(3);
            break;
        }

        const match = remaining.match(
            /^(--base|-B|--branch|-b)(?:=|\s+)(\S+)(?:\s+|$)/,
        );
        if (!match) {
            throw usage(`Unknown or incomplete option: ${remaining.split(/\s+/, 1)[0]}`);
        }

        const [, option, value] = match;
        if (option === "--base" || option === "-B") {
            baseRef = value;
        } else {
            requestedBranch = value;
        }
        remaining = remaining.slice(match[0].length);
    }

    const prompt = remaining.trim();
    if (!prompt && !requestedBranch) {
        throw usage("Provide a task prompt or an explicit branch.");
    }

    return { prompt: prompt || undefined, requestedBranch, baseRef };
}

async function chooseBranch(canonicalRoot, suggestedBranch, isExplicit, aliases) {
    await git(canonicalRoot, ["check-ref-format", "--branch", suggestedBranch]);

    if (isExplicit) {
        if (
            await branchOrPathExists(
                canonicalRoot,
                suggestedBranch,
                getWorktreePath(suggestedBranch, aliases),
            )
        ) {
            throw new Error(`Branch or worktree path already exists: ${suggestedBranch}`);
        }
        return suggestedBranch;
    }

    for (let suffix = 1; ; suffix += 1) {
        const candidate =
            suffix === 1 ? suggestedBranch : `${suggestedBranch}-${suffix}`;
        if (
            !(await branchOrPathExists(
                canonicalRoot,
                candidate,
                getWorktreePath(candidate, aliases),
            ))
        ) {
            return candidate;
        }
    }
}

async function branchOrPathExists(canonicalRoot, branch, worktreePath) {
    const branchExitCode = await gitExitCode(canonicalRoot, [
        "show-ref",
        "--verify",
        "--quiet",
        `refs/heads/${branch}`,
    ]);
    if (branchExitCode !== 0 && branchExitCode !== 1) {
        throw new Error(`Could not determine whether branch ${branch} exists.`);
    }
    if (branchExitCode === 0) {
        return true;
    }

    try {
        await access(resolve(canonicalRoot, worktreePath));
        return true;
    } catch (error) {
        if (error && typeof error === "object" && "code" in error && error.code === "ENOENT") {
            return false;
        }
        throw error;
    }
}

async function getBranchAliases(canonicalRoot) {
    const emails = await gitConfigValues(canonicalRoot, ["--get-all", "user.email"]);
    const aliases = new Set(
        emails
            .map((email) => email.split("@", 1)[0]?.trim().toLowerCase())
            .filter(Boolean),
    );
    const username = userInfo().username.trim().toLowerCase();
    if (username) {
        aliases.add(username);
    }
    return aliases;
}

function getWorktreePath(branch, aliases) {
    const segments = branch.split("/");
    const firstSegment = segments[0]?.toLowerCase();
    const secondSegment = segments[1]?.toLowerCase();

    if (segments.length > 1 && aliases.has(firstSegment)) {
        segments.shift();
    } else if (
        segments.length > 2 &&
        firstSegment === "users" &&
        aliases.has(secondSegment)
    ) {
        segments.splice(0, 2);
    }

    return segments.join("_");
}

async function generateBranchName(session, prompt, workingDirectory) {
    const { answer } = await session.rpc.ui.ephemeralQuery({
        question: [
            "Create a concise Git branch name for the task below.",
            "Summarize the intent instead of copying the full task.",
            "Output exactly one lowercase branch name using letters, digits, hyphens, and optional slashes.",
            "Do not include quotes, Markdown, explanation, or a refs/heads prefix.",
            "",
            `Task: ${prompt}`,
        ].join("\n"),
    });
    const branch = answer?.split(/\r?\n/, 1)[0]?.trim();

    if (!branch) {
        throw new Error("The model did not return a branch name.");
    }
    await git(workingDirectory, ["check-ref-format", "--branch", branch]);
    return branch;
}

async function switchToWorktree(worktree, prompt) {
    await session.rpc.metadata.setWorkingDirectory({
        workingDirectory: worktree.path,
    });

    await session.log(`Created ${worktree.path} and switched the session there.`);
    if (prompt) {
        await session.send({
            prompt,
            displayPrompt: prompt,
        });
    }
}

function usage(message) {
    return new Error(
        `${message}\nUsage: /cwt [--base <ref>] [--branch <branch>] [task prompt]`,
    );
}

async function git(cwd, args) {
    try {
        const { stdout } = await execGit(cwd, args);
        return stdout;
    } catch (error) {
        throw new Error(formatGitError(error, args));
    }
}

async function gitExitCode(cwd, args) {
    try {
        await execGit(cwd, args);
        return 0;
    } catch (error) {
        if (error && typeof error === "object" && "code" in error) {
            return Number(error.code);
        }
        throw error;
    }
}

async function gitConfigValues(cwd, args) {
    const gitArgs = ["config", ...args];
    try {
        const { stdout } = await execGit(cwd, gitArgs);
        return stdout
            .split(/\r?\n/)
            .map((value) => value.trim())
            .filter(Boolean);
    } catch (error) {
        if (
            error &&
            typeof error === "object" &&
            "code" in error &&
            Number(error.code) === 1
        ) {
            return [];
        }
        throw new Error(formatGitError(error, gitArgs));
    }
}

function execGit(cwd, args) {
    return execFileAsync("git", args, {
        cwd,
        encoding: "utf8",
        maxBuffer: 10 * 1024 * 1024,
    });
}

function formatGitError(error, args) {
    const stderr =
        error && typeof error === "object" && "stderr" in error
            ? String(error.stderr).trim()
            : "";
    return stderr || `git ${args.join(" ")} failed`;
}
