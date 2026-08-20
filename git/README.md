# Canonical Git worktree roots

`git worktree-clone <remote-url> [directory]` creates a repository root with a
bare repository and a worktree for the remote's default branch:

```text
repository/
├── .bare/    # Shared Git directory and object database
├── .git      # gitdir: ./.bare
└── master/   # Initial worktree
```

The root `.git` file points normal Git commands at `.bare`; no shell wrapper is
needed. Add further worktrees with standard Git commands from the root:

```sh
git worktree add feature/my-change -b feature/my-change origin/master
```

`git worktree-init [directory]` creates the same empty canonical root without a
remote or initial worktree. Add a remote, fetch it, and create worktrees when
ready.

`git worktree-migrate` converts the current clean, standalone clone in place.
It moves `.git` to `.bare`, recreates the currently checked-out branch as the
initial worktree, and moves ignored files into it. It preserves the Git
directory, including its configuration, hooks, refs, tags, and reflogs.

When the current directory already contains a valid `.bare` repository and no
`.git` entry, `git worktree-migrate` only creates the root `.git` reference.
Existing worktrees are left untouched.

All three commands enable reflogs and relative worktree paths.
