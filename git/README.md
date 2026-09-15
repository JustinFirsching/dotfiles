# Canonical Git worktree roots

`git canonical-worktree clone <remote-url> [directory]` creates a repository root with a
bare repository and a worktree for the remote's default branch:

```text
repository/
├── .bare/    # Shared Git directory and object database
├── .git      # gitdir: ./.bare
└── master/   # Initial worktree
```

The root `.git` file points normal Git commands at `.bare`; no shell wrapper is
needed. Add further worktrees with the grouped helper from the root:

```sh
git canonical-worktree new feature/my-change origin/master
```

`git canonical-worktree init [directory]` creates the same empty canonical root without a
remote or initial worktree. Add a remote, fetch it, and create worktrees when
ready.

`git canonical-worktree migrate [repository]` converts a clone in place. It moves `.git`
to `.bare`, recreates the current branch as a worktree, and preserves staged,
unstaged, untracked, and ignored files. Existing linked worktrees outside the
repository root remain where they are and are repaired to use `.bare`.
Linked worktrees already inside the repository root must be moved first.

When the current directory already contains a valid `.bare` repository and no
`.git` entry, `git canonical-worktree migrate [repository]` only creates the root `.git`
reference.

The shorter `git cwt` is an alias for `git canonical-worktree`.
