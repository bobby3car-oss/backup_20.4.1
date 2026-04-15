# Patient Plan Interaction — Implementation Plan

**Goal:** Enable patients to check off plan items and create private notes on their active aftercare plan.

**Architecture:**
- Progress stored as a single doc per plan in subcollection `patient_aftercare_plans/{planId}/progress/items` with a map of itemId → {completed, completedAt}
- Notes stored in subcollection `patient_aftercare_plans/{planId}/patient_notes/{noteId}`
- All items are checkable (no extra flag needed — simplest UX, YAGNI)
- Archived plans are fully read-only; active plans are interactive
- Patient-only Firestore rules (no admin/doctor access to notes or progress)
- Timeline items reflect completion status via enhanced mapper

**Tech Stack:** Flutter, Dart, Cloud Firestore, Existing GlassPage/GlassCard UI system

---

### Task 1: Domain Models

**Files:**
- Create: `lib/features/aftercare/domain/aftercare_item_progress.dart`
- Create: `lib/features/aftercare/domain/aftercare_note.dart`

### Task 2: Firebase Paths + Firestore Rules

**Files:**
- Modify: `lib/firebase/firebase_paths.dart`
- Modify: `firestore.rules`

### Task 3: Progress Service

**Files:**
- Create: `lib/features/aftercare/data/patient_aftercare_progress_service.dart`

### Task 4: Notes Service

**Files:**
- Create: `lib/features/aftercare/data/patient_aftercare_notes_service.dart`

### Task 5: Patient Plan View Screen — Major Rework

**Files:**
- Modify: `lib/features/aftercare/presentation/patient_plan_view_screen.dart`

UI additions:
- Checkboxes on each item (active plan only)
- Phase completion progress bar
- Private notes section with create/edit/delete
- Read-only badges for archived plan views

### Task 6: Timeline Completion Sync

**Files:**
- Modify: `lib/features/aftercare/data/aftercare_timeline_mapper.dart`
- Modify: `lib/domain/task_orchestrator_sync.dart`

### Task 7: Analyzer Verification

Run `dart analyze` on all modified/created files.
