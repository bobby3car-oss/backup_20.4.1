---
name: subagent-driven-development
description: "Use when executing implementation plans with independent tasks in the current session"
---

# Subagent-Driven Development

Execute plan by dispatching fresh subagent per task, with two-stage review after each: spec compliance review first, then code quality review.

**Why subagents:** You delegate tasks to specialized agents with isolated context. By precisely crafting their instructions and context, you ensure they stay focused and succeed. They should never inherit your session's context or history — you construct exactly what they need.

**Core principle:** Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration

## When to Use

- Have an implementation plan with mostly independent tasks
- Want to stay in the current session
- Tasks can be executed sequentially without tight coupling

**vs. Executing Plans:** Same session (no context switch), fresh subagent per task (no context pollution), two-stage review after each task, faster iteration.

## The Process

1. Read plan, extract all tasks with full text, note context, create task list
2. For each task:
   - Dispatch implementer subagent with full task text + context
   - If implementer asks questions → answer, then re-dispatch
   - Implementer implements, tests, commits, self-reviews
   - Dispatch spec reviewer subagent → confirms code matches spec
   - If spec issues → implementer fixes → re-review
   - Dispatch code quality reviewer subagent
   - If quality issues → implementer fixes → re-review
   - Mark task complete
3. After all tasks: dispatch final code reviewer for entire implementation

## Model Selection

Use the least powerful model that can handle each role to conserve cost and increase speed.

- **Mechanical tasks** (isolated functions, clear specs, 1-2 files): use a fast, cheap model
- **Integration tasks** (multi-file coordination, debugging): use a standard model
- **Architecture and review tasks**: use the most capable available model

## Handling Implementer Status

- **DONE:** Proceed to spec compliance review
- **DONE_WITH_CONCERNS:** Read concerns, address if about correctness/scope, then proceed
- **NEEDS_CONTEXT:** Provide missing context and re-dispatch
- **BLOCKED:** Assess blocker — provide more context, use more capable model, break into smaller pieces, or escalate to human

**Never** ignore an escalation or force the same model to retry without changes.

## Red Flags

**Never:**
- Skip reviews (spec compliance OR code quality)
- Proceed with unfixed issues
- Dispatch multiple implementation subagents in parallel (conflicts)
- Make subagent read plan file (provide full text instead)
- Skip scene-setting context
- Accept "close enough" on spec compliance
- **Start code quality review before spec compliance is ✅**
- Move to next task while either review has open issues
- Start implementation on main/master branch without explicit user consent

## Advantages

- Subagents follow TDD naturally
- Fresh context per task (no confusion)
- Self-review catches issues before handoff
- Two-stage review ensures both correctness and quality
- Review loops ensure fixes actually work
