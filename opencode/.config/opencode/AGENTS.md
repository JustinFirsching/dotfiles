# Global Agent Instructions

These instructions apply to all OpenCode sessions.

## Commit Conventions

Use Conventional Commits with an area/scope specified:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or correcting tests
- `chore`: Maintenance tasks, dependency updates, tooling

### Examples
```
feat(auth): add login endpoint
fix(api): handle null response from upstream service
refactor(db): extract connection pooling logic
test(users): add edge case coverage for email validation
```

## General Coding Philosophy

- **Readability over cleverness**: Code is read far more often than written.
- **Explicit over implicit**: Favor clear, obvious code over magic.
- **Fail fast**: Validate inputs early and surface errors immediately.
- **Single responsibility**: Functions and modules should do one thing well.
- **Composition over inheritance**: Prefer composing behavior over deep hierarchies.
- **Don't repeat yourself (DRY)**: Extract common patterns, but not prematurely.
- **YAGNI**: Don't build features you don't need yet.

## Code Quality Standards

- Write meaningful variable and function names that describe intent.
- Keep functions short and focused.
- Limit function parameters where reasonable. Use objects/structs for large amounts of parameters as needed.
- Handle errors explicitly; never silently swallow exceptions.
- Add comments for *why*, not *what* (code should be self-documenting for *what*).
- Remove dead code; don't comment it out "just in case."

## Configuration & Environment

- Load configuration from environment variables (12-factor app principles).
- Validate all required config at startup; fail fast if missing.
- Never log secrets, credentials, or tokens.
- Use `.env` files for local development only (never commit them).
- Provide `.env.example` with dummy values as documentation.

## Concurrency

- Prefer structured concurrency patterns (async/await, goroutines with errgroup).
- Always set timeouts on external calls (HTTP, database, etc.).
- Use context for cancellation propagation.
- Avoid shared mutable state; prefer message passing or immutable data.

## Observability

- Log at appropriate levels: DEBUG for development, INFO for normal operations, WARN for recoverable issues, ERROR for failures.
- Use structured logging with key-value pairs, not string interpolation.
- Include request/correlation IDs in logs for tracing.
- Never log sensitive data (passwords, tokens, PII).

## Formatting

Formatting is handled by LSP formatters. Focus on semantics and best practices, not whitespace or style minutiae.

## Style Guide Reference

When in doubt about language-specific conventions, defer to Google's style guides:
- Python: https://google.github.io/styleguide/pyguide.html
- TypeScript: https://google.github.io/styleguide/tsguide.html
- Go: https://google.github.io/styleguide/go/

