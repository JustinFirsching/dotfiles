---
name: canonical-git-worktrees
description: Create, locate, migrate, or manage Git worktrees in the local canonical bare-repository layout. Use whenever a task requires a new worktree or diagnosing worktree paths. Keep new worktrees under the canonical repository root beside `.bare`.
---

# Canonical Git Worktrees

Create new worktrees inside the canonical repository root, as siblings of `.bare`. Existing linked worktrees outside the root may remain there after migration, but do not create additional worktrees outside the root.

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

From a canonical root or one of its worktrees, run:

```sh
git canonical-worktree new feature/my-change <base-ref>
```

The command migrates a standalone clone to the canonical layout when needed,
then creates the new worktree as a direct child of the canonical root. Branch
names containing `/` use a flattened directory name.

Before creation:

- Confirm the target path does not already exist.
- Confirm the branch is not already checked out elsewhere.
- Resolve the intended base explicitly when it is not the current `HEAD`.
- Do not overwrite or relocate an existing worktree without user approval.

After creation, switch the harness working directory to the absolute worktree
path before editing using the harness's working-directory mechanism.

## Migrate a Standalone Clone

If the repository still uses a standalone `.git` directory, run:

```sh
git canonical-worktree migrate
```

Migration requires a clean, single-worktree checkout and user confirmation. Existing linked worktrees outside the repository root remain in place and are repaired to use `.bare`; linked worktrees already inside the root must be moved first. After migration, create all additional worktrees beneath the canonical root.
