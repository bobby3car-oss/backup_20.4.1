---
name: ship-workflow
description: "Full release engineering workflow. Use when code is ready to ship — runs tests, reviews diff, bumps version, updates changelog, commits, pushes, and creates PR. Invoke when asked to 'ship', 'deploy', 'create a PR', or 'push to main'."
---

# Ship Workflow — Release Engineering

Inspired by gstack's /ship methodology. Fully automated ship workflow — run straight through. Only stop for merge conflicts, test failures, or review findings that need user judgment.

## Step 0: Branch Check

```bash
git branch --show-current
git log --oneline -5
```

- If on the base branch (main/master/develop): **ABORT** — "You're on the base branch. Create a feature branch first."
- Detect the base branch: check for `main`, then `master`, then `develop`.

## Step 1: Sync Base Branch

```bash
git fetch origin
git merge origin/<base> --no-edit
```

If merge conflicts: **STOP**, show conflicts, let user resolve.

## Step 2: Run Tests

Run the project's test suite:

### Flutter/Dart:
```bash
flutter test
```

### Other frameworks:
Detect and run the appropriate test command for the project.

**If tests fail:**
- Determine if failures are **in-branch** (caused by your changes) or **pre-existing**
- In-branch failures: **STOP** — fix before shipping
- Pre-existing failures: Ask user whether to fix now, create a TODO, or skip

**If all pass:** Continue. Note test counts.

## Step 3: Test Coverage Audit

Assess test coverage for changed code:

1. Get the diff: `git diff origin/<base>...HEAD --stat`
2. For each changed file, check if corresponding test files exist
3. Identify untested code paths using this mental model:
   - Every `if` branch → both sides need tests
   - Every error handler → needs a test triggering that error
   - Every user flow → needs integration test walking through

4. **Coverage Assessment:**
   - Sufficient coverage: Continue
   - Gaps found: List gaps and ask user whether to generate tests now or ship without

## Step 4: Pre-Landing Review

Review the diff for structural issues that tests don't catch:

```bash
git diff origin/<base>...HEAD
```

Apply these checks:
1. **SQL & Data Safety** — injection risks, missing transactions, destructive operations without backup
2. **Race Conditions** — concurrent access without locking, TOCTOU bugs
3. **Security** — hardcoded secrets, missing auth checks, input not sanitized
4. **Error Handling** — swallowed errors, missing error states, silent failures
5. **Completeness** — half-implemented features, TODO comments, dead code
6. **Breaking Changes** — API contract changes, schema migrations without backward compat

### Confidence Calibration

Every finding MUST include a confidence score (1-10):
- 9-10: Verified by reading specific code. Concrete bug demonstrated.
- 7-8: High confidence pattern match. Very likely correct.
- 5-6: Moderate. Could be false positive. Show with caveat.
- 3-4: Low confidence. Suppress from main report.

### Fix-First Approach

For each finding:
- **AUTO-FIX**: Obvious improvements (missing null check, typo, missing import) → fix directly
- **ASK**: Judgment calls (architecture decisions, scope questions) → ask user

Output: `Pre-Landing Review: N issues — M auto-fixed, K need your input`

## Step 5: Version Bump (if VERSION file exists)

If a `VERSION` file or `pubspec.yaml` version exists:

1. Count lines changed: `git diff origin/<base>...HEAD --stat | tail -1`
2. Auto-decide bump level:
   - **PATCH**: < 50 lines, bug fixes, tweaks
   - **MINOR**: 50+ lines, new features, new files
   - **MAJOR**: Breaking API changes, major refactors → Ask user first

3. Update the version file. For Flutter: update `pubspec.yaml` version field.

## Step 6: Changelog

If `CHANGELOG.md` exists:

1. Enumerate every commit: `git log <base>..HEAD --oneline`
2. Group by theme: Features, Bug Fixes, Refactoring, Tests
3. Write changelog entry with the new version and date

## Step 7: Commit

```bash
git add -A
git commit -m "<type>: <summary of changes>"
```

Split into logical commits if multiple unrelated changes exist.

Commit types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

## Step 8: Push and Create PR

```bash
git push origin HEAD
```

**Never force push.**

Then create PR if `gh` CLI is available:
```bash
gh pr create --base <base> --title "<type>: <summary>" --body "<PR body>"
```

### PR Body Template:
```markdown
## Summary
<what changed and why>

## Test Results
<test counts, pass/fail>

## Coverage
<coverage assessment>

## Pre-Landing Review
<findings summary>

## Changes
<grouped list of changes>
```

If `gh` is not available: print branch name and instruct user to create PR manually.

**Output the PR URL.**

## Step 9: Post-Ship

- Suggest running verification on staging/production
- If documentation needs updating, suggest `/document-release` or manual doc updates

## Important Rules

- **Never skip tests.** If tests fail, stop.
- **Never force push.** Use regular `git push` only.
- **Never ask for trivial confirmations** (e.g., "ready to push?", "create PR?"). DO stop for: version bumps (MAJOR), review findings (ASK items).
- **Split commits for bisectability** — each commit = one logical change.
- **Date format in CHANGELOG:** `YYYY-MM-DD`
