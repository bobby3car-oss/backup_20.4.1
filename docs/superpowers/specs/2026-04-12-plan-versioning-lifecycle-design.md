# Aftercare Plan Versioning, Lifecycle & Audit — Design Spec

**Date:** 2026-04-12
**Status:** Approved

---

## Problem

The aftercare plan system supports basic lifecycle (draft → scheduled → active → archived) but lacks:
- Pausing/resuming active plans
- Proper completion vs. cancellation/archival distinction
- Safe editing of running plans (only future steps)
- Audit trail for plan changes
- Template version tracking on assigned plans

## Goals

1. Extend plan lifecycle with `paused`, `completed`, `cancelled` as independent statuses
2. Track which template version was snapshotted at assignment time
3. Allow safe editing of active plans: lock completed/past items, allow future items
4. Log all plan changes to a subcollection audit trail
5. Keep full compatibility with Timeline, Task system, Templates, Dashboards, Roles

## Non-Goals (YAGNI)

- Full template version history (subcollection of past snapshots)
- Automatic completion detection (all items checked → auto-complete)
- UI for viewing change logs (data stored, display comes later)
- Doctor visibility into patient progress/notes (patient-private, unchanged)

---

## 1. Extended Plan Status Enum

```
PlanStatus: draft | scheduled | active | paused | completed | cancelled | archived
```

### Transition Rules

```
draft ──→ scheduled ──→ active ──→ completed
       └─────────────→ active ──→ archived (replaced by new plan)
                        active ──→ cancelled
                        active ←→ paused → completed
                                   paused → cancelled
                                   paused → archived (replaced by new plan)
```

- `paused` — Temporarily stopped. Can resume to `active`, or be completed/cancelled.
- `completed` — All required items done OR doctor manually completes. Terminal state.
- `cancelled` — Aborted without completion. Terminal state with optional reason.
- `archived` — Specifically for "replaced by a new plan" (existing behavior unchanged).

### German Labels

| Status | Label |
|--------|-------|
| draft | Entwurf |
| scheduled | Geplant |
| active | Aktiv |
| paused | Pausiert |
| completed | Abgeschlossen |
| cancelled | Abgebrochen |
| archived | Archiviert |

---

## 2. New Fields on PatientAftercarePlan

### Template Version Tracking

```dart
sourceTemplateVersion: int  // version number of template at snapshot time
```

Set once at creation. Never changes.

### Pause Fields

```dart
pausedAt: DateTime?
pausedBy: String?      // UID
pauseReason: String?
resumedAt: DateTime?   // last resume timestamp
```

### Completion Fields

```dart
completedAt: DateTime?
completedBy: String?       // UID of doctor who completed
completionSummary: String? // optional free-text summary
```

### Cancellation Fields

```dart
cancelledAt: DateTime?
cancelledBy: String?   // UID
cancelReason: String?  // optional reason
```

---

## 3. Template changeDescription

New optional field on `AftercareTemplate`:

```dart
changeDescription: String?  // e.g. "Belastungsaufbau angepasst"
```

Set when saving changes in the builder. Displayed alongside version number.
Overwritten on next edit (not cumulative — just describes the most recent change).

---

## 4. Change Log Subcollection

**Path:** `patient_aftercare_plans/{planId}/change_log/{logId}`

```dart
class PlanChangeLog {
  final String id;
  final String planId;
  final String changedBy;    // UID
  final DateTime changedAt;
  final PlanChangeType changeType;
  final String description;  // human-readable
  final Map<String, dynamic>? details; // structured data
}

enum PlanChangeType {
  statusChange,     // active → paused, etc.
  itemModified,     // step title/description changed
  itemAdded,        // new step added
  itemRemoved,      // step removed
  phaseModified,    // phase title/timing changed
  planEdited,       // general plan fields changed
}
```

### What Gets Logged

| Action | changeType | description example |
|--------|-----------|---------------------|
| Plan paused | statusChange | "Plan pausiert: [reason]" |
| Plan resumed | statusChange | "Plan fortgesetzt" |
| Plan completed | statusChange | "Plan abgeschlossen" |
| Plan cancelled | statusChange | "Plan abgebrochen: [reason]" |
| Item title changed | itemModified | "Schritt 'X' geändert" |
| Item added to active plan | itemAdded | "Neuer Schritt hinzugefügt: [title]" |
| Item removed from active plan | itemRemoved | "Schritt entfernt: [title]" |

### Firestore Rules

```
match /change_log/{logId} {
  allow read: if isPatientOf(planId) || isDoctorOf(planId) || isAdmin();
  allow create, update: if isDoctorOf(planId) || isAdmin();
  allow delete: if false; // immutable audit trail
}
```

Where `isPatientOf`/`isDoctorOf` check the parent plan document's `patientId`/`doctorId`.

---

## 5. Safe Editing of Active Plans

When a doctor opens an active plan in the builder:

### Lock Rules

An item is **locked** (not editable) if ANY of:
1. `progress.isCompleted(item.id) == true` — patient already checked it off
2. Item's resolved start date is in the past (based on `surgeryDate + startDayOffset`)
3. Phase's `startDayOffset` is in the past AND item has `isTimeBound == true`

### Editable Items

Items where ALL of:
1. Not completed by patient
2. Resolved start date is in the future (or no date resolved)

### UI Behavior

- Locked items: Lock icon overlay, greyed out, tap shows "Bereits gestartet/erledigt"
- Editable items: Normal editor behavior
- Every change creates a change log entry
- Plan version is incremented

### Service Logic

`PatientAftercarePlanService.updateActivePlan()`:
1. Fetch current progress for the plan
2. Validate that no locked items were modified (compare old vs new phases)
3. Increment version
4. Write change log entries
5. Update Firestore

---

## 6. Plan Lifecycle Service Methods

### New Methods on PatientAftercarePlanService

```dart
/// Pauses an active plan.
Future<void> pausePlan(String planId, {String? reason})

/// Resumes a paused plan to active.
Future<void> resumePlan(String planId)

/// Completes a plan (manual doctor action).
Future<void> completePlan(String planId, {String? summary})

/// Cancels a plan with optional reason.
Future<void> cancelPlan(String planId, {String? reason})
```

All methods:
- Validate current status allows the transition
- Set appropriate audit fields
- Create a change log entry
- Update `updatedAt`

---

## 7. Timeline Integration

### Paused Plans

- Items from paused plans mapped with `TaskState.skipped` (existing enum value)
- Items remain visible in timeline but visually distinct (greyed out)
- `TaskOrchestratorSync` checks plan status before mapping

### Completed/Cancelled Plans

- Items NOT injected into active timeline (plan is done)
- Visible in patient's archive/history view

### Status Check in Mapper

`AftercareTimelineMapper.mapPlanToTimelineItems()` already only processes active plans via `AftercareTimelineResolver`. Extension:
- Accept optional `planStatus` parameter
- If `paused`: all items get `TaskState.skipped`
- If `completed`/`cancelled`/`archived`: return empty list

---

## 8. sourceTemplateVersion at Assignment

When `createDraftFromTemplate()` or `assignTemplateToPatient()` is called:
- Copy `template.version` to `plan.sourceTemplateVersion`
- This is write-once, never updated

Doctor can see: "Basiert auf Vorlage 'Knie-TEP Standard' v3"

---

## 9. Firestore Paths

New constants in `FirestorePaths`:
```dart
static const String aftercareChangeLog = 'change_log';
static String aftercareChangeLogCollection(String planId) =>
    'patient_aftercare_plans/$planId/change_log';
```

---

## 10. Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Plan changed while patient offline | Patient syncs on next online — progress stays, plan updates merge |
| Plan swap mid-flow | Transaction: archive old + activate new (existing behavior) |
| Rapid successive edits by doctor | Each edit increments version + logs independently |
| Double assignment prevention | Existing: only 1 active plan per patient, enforced by transaction |
| Timezone | All timestamps stored as UTC (ISO 8601 / Firestore Timestamp) |
| Pause then new plan assigned | Paused plan gets archived (same as active → archived via transaction) |
| Edit paused plan | Allowed — same lock rules as active plan editing |
| Complete already-completed plan | No-op — method validates current status |

---

## 11. Files to Create/Modify

### New Files
- `lib/features/aftercare/domain/plan_change_log.dart` — PlanChangeLog + PlanChangeType
- `lib/features/aftercare/data/plan_change_log_service.dart` — CRUD for change logs

### Modified Files
- `lib/features/aftercare/domain/plan_status.dart` — add paused, completed, cancelled
- `lib/features/aftercare/domain/patient_aftercare_plan.dart` — new fields
- `lib/features/aftercare/domain/aftercare_template.dart` — changeDescription field
- `lib/features/aftercare/data/patient_aftercare_plan_service.dart` — new lifecycle methods + safe edit
- `lib/features/aftercare/data/aftercare_timeline_mapper.dart` — paused plan handling
- `lib/domain/task_orchestrator_sync.dart` — paused plan handling
- `lib/firebase/firebase_paths.dart` — change_log paths
- `firestore.rules` — change_log rules

### NOT Modified (compatibility preserved)
- Patient plan view screen (interactive checkboxes — unchanged)
- Progress/notes services (patient-private — unchanged)
- Template service (version increment already works)
- Assign plan screen (snapshot behavior already correct)
- Template list/builder screens (no changes needed for MVP)
