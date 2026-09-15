import { execFile } from "node:child_process";
import { randomUUID } from "node:crypto";
import { promisify } from "node:util";

import { joinSession } from "@github/copilot-sdk/extension";

const execFileAsync = promisify(execFile);
let session;

const handleWorktreeCommand = async ({ args }) => {
    try {
        const { prompt, requestedBranch, baseRef } = parseArgs(args);
        const { workingDirectory } = await session.rpc.metadata.snapshot();
        const branch =
            requestedBranch ??
            (await generateBranchName(prompt));
        const worktreePath = (
            await git(workingDirectory, [
                "canonical-worktree",
                "new",
                branch,
                baseRef,
            ])
        ).trim();
        if (!worktreePath) {
            throw new Error("git canonical-worktree new did not return a worktree path.");
        }
        await startSession(worktreePath, prompt);
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        await session.log(message, { level: "error" });
        throw new Error(message);
    }
};

session = await joinSession({
    commands: ["canonical-worktree", "cwt"].map((name) => ({
        name,
        description: "Start a task in a new canonical Git worktree and session",
        handler: handleWorktreeCommand,
    })),
});

async function generateBranchName(prompt) {
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
    return branch;
}

async function startSession(worktreePath, prompt) {
    const connection = session.connection;
    if (!connection?.sendRequest) {
        throw new Error("The Copilot CLI session API is unavailable.");
    }

    const { selectedModel } = await session.rpc.metadata.snapshot();
    const sessionId = randomUUID();
    const created = await connection.sendRequest("session.create", {
        sessionId,
        model: selectedModel,
        clientName: "copilot-cli",
        workingDirectory: worktreePath,
        enableConfigDiscovery: true,
        enableFileHooks: true,
        enableSessionStore: true,
        enableSkills: true,
        infiniteSessions: { enabled: true },
        includeSubAgentStreamingEvents: true,
        requestExtensions: true,
    });
    if (created.sessionId !== sessionId) {
        throw new Error(`The runtime returned an unexpected session ID: ${created.sessionId}`);
    }

    await session.log(
        `Created ${worktreePath} and started session ${sessionId.slice(0, 8)}.`,
    );

    const promptRequest = prompt
        ? connection.sendRequest("session.send", {
              sessionId,
              prompt,
              displayPrompt: prompt,
          })
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
