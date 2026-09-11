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

`git worktree-migrate [repository]` converts a clone in place. It moves `.git`
to `.bare`, recreates the current branch as a worktree, and preserves staged,
unstaged, untracked, and ignored files. Existing linked worktrees are moved
under the repository root without changing their directory names.

When the current directory already contains a valid `.bare` repository and no
`.git` entry, `git worktree-migrate [repository]` only creates the root `.git`
reference.

All three commands enable reflogs and relative worktree paths.
