---
name: retrospective
description: "Weekly or post-milestone engineering retrospective. Use after shipping features, at end of sprint, or when asked for 'retro', 'what went well', or 'weekly review'. Analyzes shipping velocity, test health, code quality trends, and growth opportunities."
---

# Engineering Retrospective

Inspired by gstack's /retro methodology. Systematic engineering retrospective that analyzes real data from git history.

## Step 1: Gather Data

```bash
# Last 7 days of commits (adjust range as needed)
git log --since="7 days ago" --oneline --stat
git log --since="7 days ago" --format="%an" | sort | uniq -c | sort -rn
git log --since="7 days ago" --shortstat --format="" | tail -20
```

Also check:
- Open PRs/MRs
- Recent test results
- Any TODOs added or resolved

## Step 2: Shipping Velocity

Analyze what was shipped:

```
SHIPPING REPORT (last 7 days)
═══════════════════════════════════
Commits: N
Files changed: N
Lines added: +N
Lines removed: -N
Net: +/-N lines

FEATURES SHIPPED:
- [feature name] — [1-line description]
- [feature name] — [1-line description]

BUG FIXES:
- [fix] — [what was broken]

REFACTORS:
- [refactor] — [why it mattered]
```

## Step 3: Test Health

```bash
# Run test suite and capture results
flutter test 2>&1 | tail -20
```

Assess:
- Total tests: N
- Pass rate: N%
- New tests added this period: N
- Test-to-code ratio trend: improving / stable / declining
- Any flaky tests?

```
TEST HEALTH
═══════════
Total tests:     N
Pass rate:       N%
New this period: N
Flaky tests:     [list or "none"]
Coverage trend:  [improving / stable / declining]
```

## Step 4: Code Quality Trends

Analyze the diff patterns:

```bash
# Churn analysis — most changed files
git log --since="7 days ago" --name-only --format="" | sort | uniq -c | sort -rn | head -10
```

Look for:
- **Hot files** — files changed many times (potential design issue)
- **Large files growing** — complexity accumulation
- **TODO/FIXME accumulation** — tech debt trend
- **Dead code** — unused imports, unreachable paths

```
CODE QUALITY
═════════════
Hot files (changed 3+ times):
- [file] — changed N times [reason or concern]

Tech debt:
- TODOs added: N
- TODOs resolved: N
- Net: +/-N

Concerns:
- [specific concern about code quality trend]
```

## Step 5: What Went Well

Identify wins:
- Features shipped on time
- Bugs caught by tests before production
- Clean PRs with good review feedback
- Effective debugging sessions
- Good design decisions that paid off

## Step 6: What Could Be Better

Identify friction:
- Time spent on rework or debugging
- Tests that were missing and caused issues
- Design decisions that needed revisiting
- Tooling or process friction
- Knowledge gaps that slowed progress

## Step 7: Growth Opportunities

Based on the analysis, suggest:
- **Technical skills** to develop
- **Patterns** to adopt or improve
- **Process** improvements
- **Architecture** areas that need attention

## Step 8: Action Items

Produce 2-3 concrete, actionable items for the next period:

```
ACTION ITEMS
═════════════
1. [specific action] — [why, based on data above]
2. [specific action] — [why, based on data above]
3. [specific action] — [why, based on data above]
```

Each action item should be:
- **Specific** — not "write more tests" but "add integration tests for auth flow (0 coverage currently)"
- **Measurable** — how will you know it's done?
- **Time-boxed** — can be completed in one week

## Step 9: Save Retrospective

Write the retro to `docs/superpowers/retros/YYYY-MM-DD-retro.md`:

```markdown
# Engineering Retrospective — {date}

## Period
{start date} to {end date}

## Shipping Report
{from Step 2}

## Test Health
{from Step 3}

## Code Quality
{from Step 4}

## What Went Well
{from Step 5}

## What Could Be Better
{from Step 6}

## Growth Opportunities
{from Step 7}

## Action Items
{from Step 8}
```

## Important Rules

- **Data-driven, not feelings-driven.** Every claim backed by git data.
- **Be direct about quality.** "Well-designed" or "this is a mess." Don't dance around judgments.
- **Name specifics.** Real file names, real function names, real numbers.
- **End with action items.** Every retro produces concrete next steps.
- **Compare to previous retro** if one exists — track trend over time.
