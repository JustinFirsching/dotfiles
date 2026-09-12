---
name: canonical-git-worktrees
description: Create and manage Git worktrees in the canonical bare-repository layout. Use when creating, locating, migrating, or modifying worktrees.
---

# Git Worktrees

Use the canonical layout when a repository has a bare Git directory:

```text
repository/
├── .bare/
├── .git
├── master/
└── feature/my-change/
```

Worktree directories belong under the canonical repository root, alongside
`.bare/`.

## Locating the canonical root

From any worktree, inspect the shared Git directory:

```sh
git rev-parse --git-common-dir
```

Resolve that path to an absolute path. In the canonical layout, its parent is
the repository root containing `.bare/` and the root `.git` file.

Run worktree management commands from that canonical root:

```sh
git worktree list
git worktree add feature/my-change -b feature/my-change origin/master
```

After creating a worktree, run `/cd <worktree>` to make it the current Copilot
CLI working directory before continuing.

## Copilot CLI command

Use the user-level `/cwt` command to start a task in a new worktree and a new
Copilot CLI session:

```text
/cwt [--base <ref>] [--branch <branch>] [task prompt]
```

The command asks the model configured for the `general-purpose` subagent for a
concise branch name based on the task, falling back to the active session model
when no general-purpose model is configured. Branch naming always uses low
reasoning effort. The command creates that branch and worktree from the current
`HEAD`, opens and focuses a new Copilot session in that worktree, and submits
the original prompt there. The new task session still uses the model selected
in the originating session. Use `--base <ref>` to select another starting
point or `--branch <branch>` to supply the exact branch and worktree path.
`/cw` and `/canonical-worktree` are aliases.

When `--branch` is supplied without a task prompt, the command creates and
focuses an empty session without submitting a message.

If the current repository is still a standalone clone with a `.git` directory,
the command runs `git worktree-migrate` before creating the requested worktree.

## Converting a standalone clone

When a standalone clone should use the canonical layout, run this helper from
the clone:

```sh
git worktree-migrate
```

The helper requires a clean, single-worktree checkout and asks for confirmation
before moving the checkout into its initial worktree. After conversion, create
additional worktrees under the canonical root.
