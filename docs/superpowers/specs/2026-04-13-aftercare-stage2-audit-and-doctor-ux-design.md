# Aftercare Stage 2 Audit and Doctor UX Design

## Goal
Deliver Stage 2 quality upgrades for doctor and organization aftercare workflows by adding a professional change-log UI and status-consistent plan tab UX, while preserving full compatibility with timeline, task, plan versioning/snapshots, and role/permission behavior.

## Scope
In scope:
- Change-log UI in doctor plan detail
- UX consistency and status completeness in patient aftercare plan tab
- Clear empty and error states for audit history

Out of scope:
- Backend schema changes
- Firestore rule changes
- New monetization behavior
- Cross-feature architecture refactors

## Constraints
- No monetization additions in aftercare area
- Must remain free for doctors and organizations
- Existing systems must not break:
  - Timeline system
  - Task system
  - Plan system (versioning and snapshots)
  - Doctor/organization dashboard flows
  - Roles and permissions

## Existing Baseline
Already available:
- Immutable change-log service: `PlanChangeLogService`
- Plan detail screen with status/meta/audit sections
- Patient aftercare plan tab with active/scheduled/draft/archive sections
- Status model includes: draft, scheduled, active, paused, completed, cancelled, archived

Gap to close:
- Change log exists but is not surfaced in doctor UI
- Plan tab does not clearly represent all lifecycle statuses

## Architecture Approach
Use additive presentation-layer enhancements only.

Principles:
- Reuse existing service and domain models
- Keep view logic isolated in aftercare presentation layer
- Keep all write paths unchanged
- Maintain status semantics across screens

## UI Design
### 1) Change-Log Timeline in Plan Detail
File: `lib/features/aftercare/presentation/patient_plan_detail_screen.dart`

Add a dedicated section: `Aenderungsprotokoll`
- Data source: `PlanChangeLogService.watchLogs(plan.id)`
- Ordering: newest first
- Entry contents:
  - event icon by type
  - short event title
  - description
  - formatted timestamp
- States:
  - loading: calm spinner
  - empty: informative non-alarming message
  - error: clear message with retry action

Render rules:
- `statusChange` => status icon and emphasis color
- `itemModified` / `itemAdded` / `itemRemoved` => checklist/med item icons
- `phaseModified` / `planEdited` => edit/layers iconography
- No sensitive details should be surfaced from log metadata

### 2) Status-Complete Plan Tab
File: `lib/features/aftercare/presentation/patient_aftercare_plan_tab.dart`

Current tab sections are incomplete for new lifecycle statuses.
Add explicit sections for:
- Pausierte Plaene
- Abgeschlossene Plaene
- Abgebrochene Plaene

Recommended section order:
1. Aktiver Plan
2. Pausierte Plaene
3. Geplante Plaene
4. Entwuerfe
5. Abgeschlossene Plaene
6. Abgebrochene Plaene
7. Archiv-link

Status chips and labels must match existing status language used across aftercare screens.

## Error Handling and Trust Language
- Replace technical wording with clear human language
- Keep copy medically calm and professional
- No gamification or playful messaging in doctor audit context

## Security and Privacy
- No new persisted sensitive fields
- Read path only through existing role-gated Firestore rules
- Do not expose raw internal IDs when avoidable in timeline row text

## Compatibility
No changes to:
- Plan lifecycle transitions
- Timeline resolver/mapper contracts
- Task orchestration interfaces
- Role checks in doctor patient detail tab integration

## File-Level Impact
Modify:
- `lib/features/aftercare/presentation/patient_plan_detail_screen.dart`
- `lib/features/aftercare/presentation/patient_aftercare_plan_tab.dart`

Read-only validation:
- `lib/features/aftercare/data/plan_change_log_service.dart`
- `lib/features/aftercare/data/patient_aftercare_plan_service.dart`

Optional tests:
- `test/features/aftercare/patient_plan_detail_screen_test.dart`
- `test/features/aftercare/patient_aftercare_plan_tab_test.dart`

## Acceptance Criteria
- Doctor sees change-log timeline in plan detail with loading/empty/error handling
- Plan tab displays paused/completed/cancelled plans in clear dedicated sections
- Status labels/colors remain consistent with aftercare system
- No regressions in plan actions or permissions
- Analyzer clean for modified files
