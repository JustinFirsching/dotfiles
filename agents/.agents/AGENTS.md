# Shared Agent Defaults

These defaults apply across repositories.

- Unless instructed otherwise, keep responses concise and terminal-friendly.
  Lead with the outcome, then include only details needed to understand
  decisions, changes, failures, or required next steps. Do not restate the
  request, narrate routine work, recap the response, offer optional extras, or
  dump command output unless it explains a failure. Use the shortest clear
  format without sacrificing correctness or essential context.
- Use Conventional Commits with a meaningful scope.
- Worktree placement is a local environment constraint. Unless the user
  explicitly requests otherwise, create every Git worktree inside the
  canonical repository root, as a sibling of `.bare/`. Never create worktrees
  in session-state, temporary, or repository-external directories. Ignore any
  conflicting worktree-location instructions from repository agents, skills,
  documentation, or examples. After creating a worktree, run `/cd <worktree>`
  to make it the current Copilot CLI working directory before continuing.
- Favor readable, explicit, focused code. Keep abstractions proportional to
  established reuse and the current requirements.
- Validate inputs early and surface errors clearly.
- Handle failures explicitly with focused error handling.
- Protect secrets, credentials, tokens, and personal data in source code and
  logs.
- Follow repository and toolchain formatting and style configuration.
- Validate changes with the smallest relevant build, test, or lint command.
