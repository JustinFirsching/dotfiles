---
name: canonical-git-worktrees
description: Create, locate, migrate, or manage Git worktrees in the local canonical bare-repository layout. Use whenever a task requires a new worktree, the `/cwt` workflow, or diagnosing worktree paths. Keep worktrees under the canonical repository root beside `.bare/`.
---

# Canonical Git Worktrees

Keep every worktree inside the canonical repository root, as a sibling of `.bare/`. Do not create worktrees in temporary, session-state, home-level, or repository-external directories.

## Locate the Canonical Root

From an existing worktree:

```sh
git rev-parse --path-format=absolute --git-common-dir
```

In the canonical layout this resolves to `<canonical-root>/.bare`; its parent is the canonical root. Confirm the layout with:

```sh
git worktree list --porcelain
```

Do not infer the root from the current directory name.

## Create a Worktree

Run the command from the canonical root and use a relative path beneath it:

```sh
git worktree add feature/my-change -b feature/my-change <base-ref>
```

Before creation:

- Confirm the target path does not already exist.
- Confirm the branch is not already checked out elsewhere.
- Resolve the intended base explicitly when it is not the current `HEAD`.
- Do not overwrite or relocate an existing worktree without user approval.

After creation, switch the harness working directory to the absolute worktree
path before editing. In Copilot CLI, run:

```text
/cd <absolute-worktree-path>
```

## Copilot CLI Integration

When Copilot CLI exposes the user-level worktree extension, prefer:

```text
/cwt [--base <ref>] [--branch <branch>] [task prompt]
```

Aliases: `/cw` and `/canonical-worktree`.

The command creates the branch and worktree from the selected base, opens a Copilot session there, and submits the optional task prompt. With `--branch` and no prompt, it opens an empty session. After creation, verify the focused session is rooted in the new worktree before editing.

`/cwt` is a Copilot CLI extension command, not functionality provided by this
skill. In other harnesses, follow the standard Git workflow above and use the
harness's working-directory mechanism.

## Migrate a Standalone Clone

If the repository still uses a standalone `.git` directory, run:

```sh
git worktree-migrate
```

Migration requires a clean, single-worktree checkout and user confirmation. Do not bypass those safeguards. After migration, create all additional worktrees beneath the canonical root.
