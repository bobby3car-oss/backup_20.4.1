# Plan Versioning, Lifecycle & Audit — Implementation Plan

**Goal:** Extend the aftercare plan system with paused/completed/cancelled statuses, template version tracking, safe active-plan editing, and change-log audit trail.

**Architecture:** Extend existing domain models (PlanStatus, PatientAftercarePlan, AftercareTemplate) with new fields. Add PlanChangeLog domain model + service as a subcollection under plans. Extend PatientAftercarePlanService with lifecycle methods. Update timeline mapper and orchestrator sync to handle paused plans.

**Tech Stack:** Flutter/Dart, Cloud Firestore, Firestore Security Rules

---

### Task 1: Extend PlanStatus enum

**Files:**
- Modify: `lib/features/aftercare/domain/plan_status.dart`

- [ ] **Step 1: Add paused, completed, cancelled to PlanStatus**

```dart
enum PlanStatus {
  draft,
  scheduled,
  active,
  paused,      // NEW
  completed,   // NEW
  cancelled,   // NEW
  archived;
}
```

Add German displayName for each new status:
- `paused` → 'Pausiert'
- `completed` → 'Abgeschlossen'
- `cancelled` → 'Abgebrochen'

- [ ] **Step 2: Verify no analyzer errors**

Run: `get_errors` on `plan_status.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/domain/plan_status.dart
git commit -m "feat(aftercare): add paused/completed/cancelled plan statuses"
```

---

### Task 2: Extend PatientAftercarePlan with new fields

**Files:**
- Modify: `lib/features/aftercare/domain/patient_aftercare_plan.dart`

- [ ] **Step 1: Add new fields to constructor + class body**

New fields:
```dart
// Template version tracking
final int sourceTemplateVersion;

// Pause
final DateTime? pausedAt;
final String? pausedBy;
final String? pauseReason;
final DateTime? resumedAt;

// Completion
final DateTime? completedAt;
final String? completedBy;
final String? completionSummary;

// Cancellation
final DateTime? cancelledAt;
final String? cancelledBy;
final String? cancelReason;
```

Default `sourceTemplateVersion` to `1` in constructor.

- [ ] **Step 2: Update copyWith() with all new fields**

Add all new fields with `clearX` booleans for nullable fields.

- [ ] **Step 3: Update toJson()**

Add all new fields. Use conditional inclusion for nullable fields.

- [ ] **Step 4: Update fromJson()**

Parse all new fields. `sourceTemplateVersion` defaults to `version` (backward compat).

- [ ] **Step 5: Verify no analyzer errors**

Run: `get_errors` on `patient_aftercare_plan.dart`

- [ ] **Step 6: Commit**

```bash
git add lib/features/aftercare/domain/patient_aftercare_plan.dart
git commit -m "feat(aftercare): add lifecycle + version fields to PatientAftercarePlan"
```

---

### Task 3: Add changeDescription to AftercareTemplate

**Files:**
- Modify: `lib/features/aftercare/domain/aftercare_template.dart`

- [ ] **Step 1: Add changeDescription field**

```dart
final String? changeDescription;
```

Add to constructor (optional), copyWith, toJson (conditional), fromJson.

- [ ] **Step 2: Verify no analyzer errors**

Run: `get_errors` on `aftercare_template.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/domain/aftercare_template.dart
git commit -m "feat(aftercare): add changeDescription to AftercareTemplate"
```

---

### Task 4: Create PlanChangeLog domain model

**Files:**
- Create: `lib/features/aftercare/domain/plan_change_log.dart`

- [ ] **Step 1: Create PlanChangeType enum + PlanChangeLog class**

```dart
enum PlanChangeType {
  statusChange,
  itemModified,
  itemAdded,
  itemRemoved,
  phaseModified,
  planEdited;
}

class PlanChangeLog {
  final String id;
  final String planId;
  final String changedBy;
  final DateTime changedAt;
  final PlanChangeType changeType;
  final String description;
  final Map<String, dynamic>? details;

  // constructor, toJson, fromJson, copyWith
}
```

- [ ] **Step 2: Verify no analyzer errors**

Run: `get_errors` on `plan_change_log.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/domain/plan_change_log.dart
git commit -m "feat(aftercare): add PlanChangeLog domain model"
```

---

### Task 5: Add Firestore paths for change_log

**Files:**
- Modify: `lib/firebase/firebase_paths.dart`

- [ ] **Step 1: Add change_log constants**

```dart
static const String aftercareChangeLog = 'change_log';
static String aftercareChangeLogCollection(String planId) =>
    '$patientAftercarePlans/$planId/$aftercareChangeLog';
```

- [ ] **Step 2: Verify no analyzer errors**

- [ ] **Step 3: Commit**

```bash
git add lib/firebase/firebase_paths.dart
git commit -m "feat(aftercare): add change_log Firestore path constants"
```

---

### Task 6: Add Firestore rules for change_log

**Files:**
- Modify: `firestore.rules`

- [ ] **Step 1: Add change_log match block**

Inside the `patient_aftercare_plans/{planId}` block, after patient_notes:

```
// ── Plan change log (audit trail) ──────────────────────
match /change_log/{logId} {
  allow read: if isSignedIn()
    && (get(/databases/$(database)/documents/patient_aftercare_plans/$(planId)).data.patientId == uid()
        || get(/databases/$(database)/documents/patient_aftercare_plans/$(planId)).data.doctorId == uid()
        || isAdmin());
  allow create: if isSignedIn()
    && (get(/databases/$(database)/documents/patient_aftercare_plans/$(planId)).data.doctorId == uid()
        || isAdmin());
  allow update, delete: if false; // immutable audit trail
}
```

- [ ] **Step 2: Verify rules syntax**

Run: `firebase deploy --only firestore:rules --dry-run` (or just validate via read)

- [ ] **Step 3: Commit**

```bash
git add firestore.rules
git commit -m "feat(aftercare): add Firestore rules for change_log subcollection"
```

---

### Task 7: Create PlanChangeLogService

**Files:**
- Create: `lib/features/aftercare/data/plan_change_log_service.dart`

- [ ] **Step 1: Create service with log + read methods**

```dart
class PlanChangeLogService {
  Future<void> log({planId, changeType, description, details?});
  Stream<List<PlanChangeLog>> watchLogs(String planId);
  Future<List<PlanChangeLog>> getLogs(String planId);
}
```

`log()` auto-populates: id (docRef.id), planId, changedBy (current user UID), changedAt (server timestamp).

- [ ] **Step 2: Verify no analyzer errors**

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/data/plan_change_log_service.dart
git commit -m "feat(aftercare): add PlanChangeLogService"
```

---

### Task 8: Extend PatientAftercarePlanService — lifecycle methods

**Files:**
- Modify: `lib/features/aftercare/data/patient_aftercare_plan_service.dart`

- [ ] **Step 1: Add sourceTemplateVersion to createDraftFromTemplate + assignTemplateToPatient**

In both methods, add `sourceTemplateVersion: template.version` when constructing the plan.

- [ ] **Step 2: Add pausePlan method**

```dart
Future<void> pausePlan(String planId, {String? reason}) async {
  // Validate status == active
  // Update: status=paused, pausedAt=serverTimestamp, pausedBy=uid, pauseReason
  // Log change via PlanChangeLogService
}
```

- [ ] **Step 3: Add resumePlan method**

```dart
Future<void> resumePlan(String planId) async {
  // Validate status == paused
  // Update: status=active, resumedAt=serverTimestamp
  // Log change
}
```

- [ ] **Step 4: Add completePlan method**

```dart
Future<void> completePlan(String planId, {String? summary}) async {
  // Validate status == active || paused
  // Update: status=completed, completedAt=serverTimestamp, completedBy=uid, completionSummary
  // Log change
}
```

- [ ] **Step 5: Add cancelPlan method**

```dart
Future<void> cancelPlan(String planId, {String? reason}) async {
  // Validate status == active || paused
  // Update: status=cancelled, cancelledAt=serverTimestamp, cancelledBy=uid, cancelReason
  // Log change
}
```

- [ ] **Step 6: Update updatePlan to block terminal statuses**

Currently blocks only `archived`. Add: also block `completed` and `cancelled`.

- [ ] **Step 7: Update activatePlan to also archive paused plans**

The existing active-plan query checks `status == active`. Also query for `status == paused` and archive those too.

- [ ] **Step 8: Verify no analyzer errors**

- [ ] **Step 9: Commit**

```bash
git add lib/features/aftercare/data/patient_aftercare_plan_service.dart
git commit -m "feat(aftercare): add pause/resume/complete/cancel lifecycle methods"
```

---

### Task 9: Update AftercareTimelineResolver for paused plans

**Files:**
- Modify: `lib/features/aftercare/data/aftercare_timeline_resolver.dart`

- [ ] **Step 1: Add fetchActivePlanOrPaused method**

New method that queries for `status in ['active', 'paused']` to handle paused plans staying visible.

Actually, simpler: rename nothing. Instead modify `fetchActivePlan` and `watchActivePlan` to also match `paused` status. Paused plans still show in timeline (greyed out).

Update the Firestore queries:
- Instead of `.where('status', isEqualTo: PlanStatus.active.name)`
- Use `.where('status', whereIn: [PlanStatus.active.name, PlanStatus.paused.name])`

- [ ] **Step 2: Verify no analyzer errors**

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/data/aftercare_timeline_resolver.dart
git commit -m "feat(aftercare): timeline resolver includes paused plans"
```

---

### Task 10: Update AftercareTimelineMapper for paused plans

**Files:**
- Modify: `lib/features/aftercare/data/aftercare_timeline_mapper.dart`

- [ ] **Step 1: Accept plan status parameter, handle paused**

Add `PlanStatus? planStatus` parameter to `mapPlanToTimelineItems()`.

If `planStatus == PlanStatus.paused`: all items get `TaskState.skipped` regardless of other logic.

```dart
static List<TimelineItem> mapPlanToTimelineItems(
  PatientAftercarePlan plan, {
  AftercareItemProgress? progress,
  PlanStatus? planStatus,
}) {
  // ...existing code...
  // After computing resolvedState:
  final finalState = (planStatus == PlanStatus.paused)
      ? TaskState.skipped
      : resolvedState;
  // Use finalState instead of resolvedState
}
```

- [ ] **Step 2: Verify no analyzer errors**

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/data/aftercare_timeline_mapper.dart
git commit -m "feat(aftercare): timeline mapper handles paused plan state"
```

---

### Task 11: Update TaskOrchestratorSync for paused plans

**Files:**
- Modify: `lib/domain/task_orchestrator_sync.dart`

- [ ] **Step 1: Pass plan status to timeline mapper**

In `_injectAftercarePlanItems()`, pass `planStatus: plan.status` to the mapper call.

- [ ] **Step 2: Update watcher to handle paused → active transitions**

The existing watcher already re-injects on any plan change. Just ensure paused plans are kept (not cleared).

In `_startWatchingAftercarePlan()` listener: when `plan == null` AND `_activeAftercarePlan != null`, that means the plan was completed/cancelled (no longer active/paused) → clear items.

- [ ] **Step 3: Verify no analyzer errors**

- [ ] **Step 4: Commit**

```bash
git add lib/domain/task_orchestrator_sync.dart
git commit -m "feat(aftercare): orchestrator sync handles paused plan status"
```

---

### Task 12: Final verification

- [ ] **Step 1: Run get_errors on all modified/created files**

Files to check:
- `lib/features/aftercare/domain/plan_status.dart`
- `lib/features/aftercare/domain/patient_aftercare_plan.dart`
- `lib/features/aftercare/domain/aftercare_template.dart`
- `lib/features/aftercare/domain/plan_change_log.dart`
- `lib/firebase/firebase_paths.dart`
- `firestore.rules`
- `lib/features/aftercare/data/plan_change_log_service.dart`
- `lib/features/aftercare/data/patient_aftercare_plan_service.dart`
- `lib/features/aftercare/data/aftercare_timeline_resolver.dart`
- `lib/features/aftercare/data/aftercare_timeline_mapper.dart`
- `lib/domain/task_orchestrator_sync.dart`

- [ ] **Step 2: Verify backward compatibility**

- The existing `PlanStatus.fromString()` still defaults to `draft` for unknown values ✓
- `PatientAftercarePlan.fromJson()` handles missing new fields with defaults ✓
- `toJson()` uses conditional inclusion for nullable fields ✓
- Timeline resolver now matches `active` AND `paused` → no plans lost ✓
- `updatePlan()` blocks `archived`, `completed`, `cancelled` → terminal states respected ✓

- [ ] **Step 3: Final commit if any fixes needed**
