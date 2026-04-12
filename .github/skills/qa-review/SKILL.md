---
name: qa-review
description: "Systematic QA testing workflow. Use when asked to 'test the app', 'find bugs', 'QA this', or 'does this work'. Finds bugs, fixes them with atomic commits, and generates regression tests for every fix."
---

# QA Review — Systematic Bug Finding

Inspired by gstack's /qa methodology. Systematic quality assurance: find bugs, fix them, verify fixes, generate regression tests.

## Step 1: Understand What to Test

1. Read the project README and any design docs
2. Check recent changes: `git log --oneline -20`
3. Get the diff if on a feature branch: `git diff origin/<base>...HEAD --stat`
4. Identify the **test surface**:
   - What screens/pages/flows were changed?
   - What user interactions are affected?
   - What edge cases exist?

## Step 2: Build Test Plan

Create a structured test plan:

```
QA TEST PLAN
═════════════
Target: [feature/page/flow being tested]
Branch: [current branch]

CRITICAL PATHS (must work):
1. [primary user flow — happy path]
2. [secondary flow]
3. [error recovery flow]

EDGE CASES:
1. [empty state — no data]
2. [large data — many items]
3. [invalid input — malformed data]
4. [network failure — offline/timeout]
5. [concurrent actions — rapid taps/clicks]
6. [navigation — back button, deep links]

REGRESSION CHECKS:
1. [existing feature that might be affected]
2. [related flow that shares code]
```

## Step 3: Execute Test Plan

For each test case:

### Code Review Testing
1. Read the implementation code for each flow
2. Trace the data path from input to output
3. Check every branch condition (if/else/switch)
4. Verify error handling exists for each failure mode
5. Check state management for race conditions

### Static Analysis
```bash
# For Flutter/Dart
flutter analyze
dart fix --dry-run
```

### Unit/Widget Test Execution
```bash
# Run existing tests
flutter test
```

### Manual Code Inspection Checklist
For each changed file:
- [ ] All inputs validated at entry points
- [ ] All error states handled with user feedback
- [ ] Loading states shown during async operations
- [ ] Empty states handled (no data, first use)
- [ ] Null/undefined checks where needed
- [ ] Proper disposal of resources (controllers, streams, subscriptions)
- [ ] No hardcoded strings (use l10n)
- [ ] Accessibility considered (semantics, contrast, touch targets)

## Step 4: Bug Report

For each bug found:

```
BUG #{N}
═════════
Severity: [P0-Critical / P1-High / P2-Medium / P3-Low]
Location: [file:line]
Description: [what's wrong]
Expected: [what should happen]
Actual: [what happens instead]
Root Cause: [why it happens]
Fix: [how to fix it]
```

## Step 5: Fix Loop

For each bug (P0 first, then P1, etc.):

1. **Fix the bug** — minimal, focused change
2. **Write a regression test** — test that would have caught this bug
3. **Verify the fix** — run the test, confirm it passes
4. **Atomic commit:**
   ```bash
   git add <fixed files> <test files>
   git commit -m "fix: <description of fix>

   Regression test added: <test description>"
   ```

### Regression Test Rules
- Every bug fix MUST have a corresponding test
- Test should fail without the fix and pass with it
- Test name should describe the bug scenario, not the fix

## Step 6: Re-verify

After all fixes:

1. Run the full test suite: `flutter test`
2. Run static analysis: `flutter analyze`
3. Re-check each fixed bug — confirm the fix holds
4. Check that fixes didn't introduce new issues

## Step 7: QA Report

```
QA REPORT
═══════════
Date: {date}
Branch: {branch}
Scope: {what was tested}

RESULTS:
- Test cases executed: N
- Bugs found: N (P0: N, P1: N, P2: N, P3: N)
- Bugs fixed: N
- Regression tests added: N
- Remaining issues: N

BUGS FIXED:
1. [file:line] — [description] — [commit SHA]
2. [file:line] — [description] — [commit SHA]

REMAINING ISSUES:
1. [description] — [why not fixed now]

TEST HEALTH:
- Tests before: N
- Tests after: N (+N new)
- All passing: Yes/No
```

## Important Rules

- **Every bug fix gets a regression test.** No exceptions.
- **Atomic commits per fix.** One commit = one bug fix + its test.
- **P0 bugs block shipping.** P1-P3 are tracked but may ship with known issues.
- **Fix the real bug, not the symptom.** Trace to root cause.
- **Be thorough but practical.** Cover the important paths, don't test every pixel.
- **Never skip verification.** After fixing, always confirm the fix works AND didn't break anything else.
