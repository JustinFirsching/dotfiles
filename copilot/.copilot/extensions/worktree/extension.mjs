import { execFile } from "node:child_process";
import { randomUUID } from "node:crypto";
import { access } from "node:fs/promises";
import { basename, dirname, isAbsolute, relative, resolve, sep } from "node:path";
import { promisify } from "node:util";

import { joinSession } from "@github/copilot-sdk/extension";

const execFileAsync = promisify(execFile);

let session;

const handleWorktreeCommand = async ({ args }) => {
    try {
        const request = parseArgs(args);
        const worktree = await createWorktree(request);
        await startSession(worktree, request.prompt);
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
    const { workingDirectory, selectedModel } = await session.rpc.metadata.snapshot();
    const baseCommit = (
        await git(workingDirectory, ["rev-parse", "--verify", `${baseRef}^{commit}`])
    ).trim();
    const canonicalRoot = await ensureCanonicalRoot(workingDirectory);
    const { workingDirectory: activeWorkingDirectory } =
        await session.rpc.metadata.snapshot();
    const suggestedBranch =
        requestedBranch ??
        (await generateBranchName(prompt, activeWorkingDirectory, selectedModel));
    const branch = await chooseBranch(
        canonicalRoot,
        suggestedBranch,
        requestedBranch !== undefined,
    );
    const worktreePath = branch;
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
    await git(canonicalRoot, ["check-ref-format", "--branch", branch]);
    await git(canonicalRoot, ["worktree", "add", "-b", branch, destination, baseCommit]);

    return { branch, path: destination };
}

async function ensureCanonicalRoot(workingDirectory) {
    let commonDir = await getCommonDir(workingDirectory);

    if (basename(commonDir) === ".bare") {
        return dirname(commonDir);
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

    return dirname(commonDir);
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

async function chooseBranch(canonicalRoot, suggestedBranch, isExplicit) {
    await git(canonicalRoot, ["check-ref-format", "--branch", suggestedBranch]);

    if (isExplicit) {
        if (await branchOrPathExists(canonicalRoot, suggestedBranch)) {
            throw new Error(`Branch or worktree path already exists: ${suggestedBranch}`);
        }
        return suggestedBranch;
    }

    for (let suffix = 1; ; suffix += 1) {
        const candidate =
            suffix === 1 ? suggestedBranch : `${suggestedBranch}-${suffix}`;
        if (!(await branchOrPathExists(canonicalRoot, candidate))) {
            return candidate;
        }
    }
}

async function branchOrPathExists(canonicalRoot, branch) {
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
        await access(resolve(canonicalRoot, branch));
        return true;
    } catch (error) {
        if (error && typeof error === "object" && "code" in error && error.code === "ENOENT") {
            return false;
        }
        throw error;
    }
}

async function generateBranchName(prompt, workingDirectory, activeModel) {
    const connection = session.connection;
    if (!connection?.sendRequest) {
        throw new Error("The Copilot CLI session API is unavailable.");
    }

    const model = await getBranchNameModel(activeModel);
    const sessionId = randomUUID();
    let created = false;
    try {
        await createRuntimeSession(connection, {
            sessionId,
            model,
            reasoningEffort: "low",
            workingDirectory,
            requestExtensions: false,
            availableTools: [],
            enableSessionStore: false,
            infiniteSessions: { enabled: false },
        });
        created = true;
        await connection.sendRequest("session.send", {
            sessionId,
            prompt: [
                "Create a concise Git branch name for the task below.",
                "Summarize the intent instead of copying the full task.",
                "Output exactly one lowercase branch name using letters, digits, hyphens, and optional slashes.",
                "Do not include quotes, Markdown, explanation, or a refs/heads prefix.",
                "",
                `Task: ${prompt}`,
            ].join("\n"),
            wait: true,
        });

        const page = await connection.sendRequest("session.eventLog.read", {
            sessionId,
            direction: "backward",
            includeEphemeral: false,
            max: 10,
            types: ["assistant.message"],
            waitMs: 0,
        });
        const content = page.events
            .find((event) => event.type === "assistant.message")
            ?.data?.content?.trim();
        const branch = content?.split(/\r?\n/, 1)[0]?.trim();

        if (!branch) {
            throw new Error("The model did not return a branch name.");
        }
        await git(workingDirectory, ["check-ref-format", "--branch", branch]);
        return branch;
    } finally {
        if (created) {
            await connection.sendRequest("session.delete", { sessionId });
        }
    }
}

async function getBranchNameModel(activeModel) {
    const connection = session.connection;
    if (!connection?.sendRequest) {
        throw new Error("The Copilot CLI session API is unavailable.");
    }

    const { settings } = await connection.sendRequest("user.settings.get", {});
    const model =
        settings.subagents?.value?.agents?.["general-purpose"]?.model;
    if (typeof model === "string" && model.trim()) {
        return model.trim();
    }

    if (typeof activeModel === "string" && activeModel.trim()) {
        return activeModel.trim();
    }

    throw new Error(
        "No model is configured for the general-purpose subagent or active session.",
    );
}

async function startSession(worktree, prompt) {
    const connection = session.connection;
    if (!connection?.sendRequest) {
        throw new Error("The Copilot CLI session API is unavailable.");
    }

    const { selectedModel } = await session.rpc.metadata.snapshot();
    const sessionId = randomUUID();

    try {
        await createRuntimeSession(connection, {
            sessionId,
            model: selectedModel,
            workingDirectory: worktree.path,
            requestExtensions: true,
        });
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        throw new Error(
            `Created worktree ${worktree.path}, but could not create its Copilot session: ${message}`,
        );
    }

    await session.log(
        `Created ${worktree.path} and started session ${sessionId.slice(0, 8)}.`,
    );

    const promptRequest = prompt
        ? sendPrompt(connection, sessionId, prompt)
        : Promise.resolve();
    const foreground = await connection.sendRequest("session.setForeground", {
        sessionId,
    });
    if (!foreground.success) {
        throw new Error(
            `Started session ${sessionId}, but could not focus it: ${
                foreground.error ?? "unknown error"
            }`,
        );
    }
    await promptRequest;
}

async function createRuntimeSession(
    connection,
    {
        sessionId,
        model,
        reasoningEffort,
        workingDirectory,
        requestExtensions,
        availableTools,
        enableSessionStore = true,
        infiniteSessions = { enabled: true },
    },
) {
    const created = await connection.sendRequest("session.create", {
        sessionId,
        model,
        reasoningEffort,
        clientName: "copilot-cli",
        workingDirectory,
        enableConfigDiscovery: requestExtensions,
        enableFileHooks: requestExtensions,
        enableSessionStore,
        enableSkills: requestExtensions,
        infiniteSessions,
        includeSubAgentStreamingEvents: true,
        requestExtensions,
        availableTools,
    });
    if (created.sessionId !== sessionId) {
        throw new Error(`The runtime returned an unexpected session ID: ${created.sessionId}`);
    }
}

async function sendPrompt(connection, sessionId, prompt) {
    await connection.sendRequest("session.send", {
        sessionId,
        prompt,
        displayPrompt: prompt,
    });
}

function usage(message) {
    return new Error(
        `${message}\nUsage: /cwt [--base <ref>] [--branch <branch>] [task prompt]`,
    );
}

async function git(cwd, args) {
    try {
        const { stdout } = await execFileAsync("git", args, {
            cwd,
            encoding: "utf8",
            maxBuffer: 10 * 1024 * 1024,
        });
        return stdout;
    } catch (error) {
        const stderr =
            error && typeof error === "object" && "stderr" in error
                ? String(error.stderr).trim()
                : "";
        throw new Error(stderr || `git ${args.join(" ")} failed`);
    }
}

async function gitExitCode(cwd, args) {
    try {
        await execFileAsync("git", args, {
            cwd,
            encoding: "utf8",
            maxBuffer: 10 * 1024 * 1024,
        });
        return 0;
    } catch (error) {
        if (error && typeof error === "object" && "code" in error) {
            return Number(error.code);
        }
        throw error;
    }
}
