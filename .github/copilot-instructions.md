# Superpowers - Agentic Development Workflow

This project uses the **Superpowers** methodology (by obra) for structured, high-quality agentic development.

## Core Workflow

1. **Brainstorming** → Before any creative work, explore intent, requirements, and design before implementation.
2. **Writing Plans** → Break approved designs into bite-sized, actionable implementation plans with TDD.
3. **Executing Plans / Subagent-Driven Development** → Execute plans task-by-task with review checkpoints.
4. **Test-Driven Development** → RED-GREEN-REFACTOR cycle for all features and bugfixes.
5. **Systematic Debugging** → Root cause investigation before proposing fixes.
6. **Verification Before Completion** → Evidence before claims, always.
7. **Code Review** → Review early, review often.

## Key Principles

- **YAGNI** — You Aren't Gonna Need It. Remove unnecessary features.
- **DRY** — Don't Repeat Yourself.
- **TDD** — Write tests first. Watch them fail. Write minimal code to pass.
- **No production code without a failing test first.**
- **Systematic over ad-hoc** — Process over guessing.
- **Evidence over claims** — Verify before declaring success.

## Skills

The following skills are available in `.github/skills/` and should be invoked automatically based on context:

| Skill | When to Use |
|-------|-------------|
| `brainstorming` | Before any creative work — creating features, building components, adding functionality |
| `writing-plans` | When you have a spec or requirements for a multi-step task |
| `executing-plans` | When you have a written implementation plan to execute |
| `subagent-driven-development` | When executing plans with independent tasks in the current session |
| `test-driven-development` | When implementing any feature or bugfix |
| `systematic-debugging` | When encountering any bug, test failure, or unexpected behavior |
| `verification-before-completion` | Before claiming work is complete, fixed, or passing |
| `requesting-code-review` | When completing tasks or before merging |
| `frontend-design` | When building web components, pages, or applications — distinctive, production-grade UI |
| `code-reviewer` | After completing any implementation — automated quality, reuse, and simplification pass |
| `security-auditor` | When reviewing auth flows, data handling, API endpoints, or security-sensitive code |
| `architecture` | When designing system architecture, component structure, or evaluating design decisions |
| `office-hours` | YC-style product discovery — use before building anything new to challenge premises and expose demand reality |
| `ship-workflow` | When code is ready to ship — tests, review, version bump, changelog, PR creation |
| `retrospective` | Weekly or post-milestone engineering retrospective — shipping velocity, test health, action items |
| `qa-review` | Systematic QA testing — find bugs, fix with atomic commits, generate regression tests |
