---
name: code-review
description: Systematic code review checklist for quality, correctness, and maintainability
---

# Code Review Skill

Use this skill when reviewing code changes, PRs, or evaluating code quality.

## Review Process

1. **Understand the context** - What problem is being solved? What's the expected behavior?
2. **Read the code** - Understand the implementation before critiquing.
3. **Check for correctness** - Does it do what it's supposed to do?
4. **Evaluate quality** - Is it maintainable, readable, and well-structured?
5. **Provide actionable feedback** - Be specific, constructive, and prioritize issues.

## Providing Feedback

### Be Specific
Bad: "This is confusing."
Good: "The variable `x` doesn't describe its purpose. Consider renaming to `userCount`."

### Explain Why
Bad: "Don't do this."
Good: "This approach can cause a race condition if two requests arrive simultaneously."

### Suggest Alternatives
Bad: "This is wrong."
Good: "Consider using a map lookup instead of a loop here for O(1) access."

### Prioritize Issues
- **Blocking**: Must fix before merge (bugs, security issues, breaking changes)
- **Important**: Should fix, but not blocking (maintainability, performance)
- **Nit**: Minor suggestions (style, naming preferences)

Label your feedback clearly: `[blocking]`, `[important]`, `[nit]`

## Checklist

### Correctness
- [ ] Does the code correctly implement the intended functionality?
- [ ] Are edge cases handled (null, empty, boundary values)?
- [ ] Are error conditions handled appropriately?
- [ ] Are there any off-by-one errors or incorrect loop bounds?
- [ ] Is the logic correct for all input combinations?

### Error Handling
- [ ] Are errors caught and handled, not silently ignored?
- [ ] Are error messages informative and actionable?
- [ ] Do errors propagate correctly to callers?
- [ ] Are resources cleaned up on error (files, connections, locks)?

### Readability
- [ ] Are names descriptive and consistent?
- [ ] Is the code self-documenting, or are comments needed for clarity?
- [ ] Is the control flow easy to follow?
- [ ] Are magic numbers replaced with named constants?
- [ ] Is nesting depth reasonable (generally 3 levels or fewer)?

### Maintainability
- [ ] Is the code DRY without being over-abstracted?
- [ ] Are functions and classes appropriately sized?
- [ ] Is there a single responsibility per function/class?
- [ ] Are dependencies explicit and minimal?
- [ ] Would a new team member understand this code?

### Performance
- [ ] Are there any obvious inefficiencies (N+1 queries, unnecessary loops)?
- [ ] Is the algorithmic complexity appropriate for the data size?
- [ ] Are resources (memory, connections) managed efficiently?
- [ ] Could any operations be batched or cached?

### Testing
- [ ] Are there tests covering the new/changed functionality?
- [ ] Do tests cover edge cases and error conditions?
- [ ] Are tests readable and maintainable?
- [ ] Do tests actually assert the correct behavior?

### API Design
- [ ] Are function signatures intuitive and consistent?
- [ ] Are return types clear and predictable?
- [ ] Is the public API minimal (no unnecessary exposure)?
- [ ] Are breaking changes avoided or clearly documented?

### Security
- [ ] Is user input validated and sanitized?
- [ ] Are there any hardcoded secrets or credentials?
- [ ] Are permissions/authorization checked appropriately?
- [ ] See `security-check` skill for comprehensive security review.

### Concurrency
- [ ] Are shared resources protected from race conditions?
- [ ] Are database transactions used correctly (appropriate isolation levels)?
- [ ] Are locks held for minimal time?
- [ ] Is there potential for deadlocks?
- [ ] Are async operations properly awaited?

### Observability
- [ ] Are key operations logged with appropriate levels?
- [ ] Is sensitive data excluded from logs?
- [ ] Are errors logged with enough context for debugging?
- [ ] Are request/correlation IDs propagated?

### Dependencies
- [ ] Are new dependencies necessary and well-maintained?
- [ ] Is the dependency license compatible with the project?
- [ ] Are there known vulnerabilities in new dependencies?

### Backward Compatibility
- [ ] Are API contracts preserved (no breaking changes without versioning)?
- [ ] Are database migrations reversible or forward-compatible?
- [ ] Are feature flags used for risky changes?
