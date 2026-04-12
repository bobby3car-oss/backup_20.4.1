---
name: code-reviewer
description: "Use after completing any implementation to review code for quality, reuse, efficiency, and simplification. Automatically catches over-engineering, duplication, dead code, and inconsistent patterns before presenting code."
---

# Code Reviewer / Simplify

## Overview

Review all changed code for quality, reuse, and efficiency — then fix what you find. This runs as a final pass before presenting code to the user.

**Core principle:** Every piece of code the user sees should already be the second draft, not the first.

## When to Use

**Automatically after:**
- Completing any implementation task
- Writing new functions, classes, or modules
- Modifying existing code
- Before committing or creating PRs

## Review Checklist

Check for and fix:

### Structure
- **Functions longer than 30 lines** — likely doing too much, extract sub-functions
- **Single Responsibility** — each function/class does one thing
- **Unused imports and dead code** — remove entirely
- **Inconsistent patterns** — match the rest of the codebase

### Reuse
- **Logic duplicated more than twice** — extract to utility
- **Similar API call patterns** — create shared helper
- **Repeated error handling** — centralize

### Quality
- **Naming that doesn't communicate intent** — rename for clarity
- **Magic numbers and strings** — extract to named constants
- **Missing error handling on async operations** — add appropriate handling
- **Overly complex conditionals** — simplify or extract

### Performance
- **Unnecessary re-renders** (Flutter: unnecessary setState, missing const)
- **N+1 queries** — batch where possible
- **Blocking operations** — make async where appropriate
- **Unnecessary object creation in hot paths**

### Flutter-Specific
- **Missing `const` constructors** — add where possible
- **Widget rebuilds** — use `const`, `ValueListenableBuilder`, or extract widgets
- **Disposing controllers and streams** — verify cleanup
- **Proper key usage in lists**

## Process

1. **Review changed files** — read through all modifications
2. **Check against checklist** — systematically verify each point
3. **Fix issues inline** — don't just flag, fix them
4. **Verify fixes** — ensure fixes don't break existing tests
5. **Report** — briefly note what was improved

## Anti-Patterns to Catch

```
// BAD: Duplicated fetch pattern
final users = await firestore.collection('users').doc(id).get();
final posts = await firestore.collection('posts').doc(id).get();

// GOOD: Extracted utility
Future<DocumentSnapshot> getDoc(String collection, String id) =>
    firestore.collection(collection).doc(id).get();
final users = await getDoc('users', id);
final posts = await getDoc('posts', id);
```

## Severity Levels

| Level | Action | Example |
|-------|--------|---------|
| **Critical** | Fix immediately, blocks completion | Security vulnerability, data loss risk |
| **Important** | Fix before presenting | Duplication, missing error handling |
| **Minor** | Note for later | Naming improvements, style consistency |

## Remember
- Fix, don't just flag
- Match existing codebase patterns
- Don't over-engineer the fix
- Run tests after changes
