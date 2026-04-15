# Aftercare UX Stability Security Stage 1 Implementation Plan

**Goal:** Deliver a professional patient aftercare experience with today-first clarity, offline-safe task completion, undo support, and resilient error handling without breaking existing timeline/task/plan systems.

**Architecture:** Extend the existing aftercare feature with additive service and UI enhancements. Keep data contracts backward compatible, isolate offline behavior in progress service, and keep timeline/status semantics unchanged.

**Tech Stack:** Flutter, Dart, Cloud Firestore, Firebase Auth, connectivity_plus, shared_preferences, existing Glass UI components.

---

### Task 1: Add Progress Overlay and Pending Metadata

**Files:**
- Modify: `lib/features/aftercare/domain/aftercare_item_progress.dart`
- Test: `test/features/aftercare/aftercare_item_progress_test.dart`

- [ ] Step 1: Write failing tests for pending overlay and completion count behavior.
- [ ] Step 2: Run targeted test and verify RED.
- [ ] Step 3: Implement pending metadata fields and overlay helper.
- [ ] Step 4: Run targeted test and verify GREEN.

### Task 2: Implement Offline Queue in Progress Service

**Files:**
- Modify: `lib/features/aftercare/data/patient_aftercare_progress_service.dart`
- Test: `test/features/aftercare/aftercare_item_progress_test.dart`

- [ ] Step 1: Add queue data model and persistence helpers using shared_preferences.
- [ ] Step 2: Extend watch/get progress to apply pending local overrides.
- [ ] Step 3: Make toggle/set item offline-safe with queued writes.
- [ ] Step 4: Add syncPendingActions with bounded retries and LWW behavior.
- [ ] Step 5: Run analysis and targeted tests.

### Task 3: Today Section UX and Priority Hierarchy

**Files:**
- Modify: `lib/features/aftercare/presentation/widgets/today_hero_section.dart`

- [ ] Step 1: Sort today items by critical/open/completed priority.
- [ ] Step 2: Add explicit state markers and pending sync hint.
- [ ] Step 3: Keep micro-interactions subtle for critical tasks.
- [ ] Step 4: Verify analyzer clean.

### Task 4: Undo Flow and Connectivity Re-sync

**Files:**
- Modify: `lib/features/aftercare/presentation/patient_plan_view_screen.dart`

- [ ] Step 1: Wire toggle callback to show 8-second undo Snackbar.
- [ ] Step 2: Implement undo by restoring prior state via service.
- [ ] Step 3: Trigger syncPendingActions on screen init and connectivity restore.
- [ ] Step 4: Add completed-plan summary card and reduce overload.
- [ ] Step 5: Verify analyzer clean.

### Task 5: Archive Error Retry and Edge-state Consistency

**Files:**
- Modify: `lib/features/aftercare/presentation/patient_plan_view_screen.dart`
- Modify: `lib/features/aftercare/presentation/widgets/error_retry_widget.dart`
- Modify: `lib/features/aftercare/presentation/widgets/plan_status_banner.dart`

- [ ] Step 1: Make archive screen retry functional.
- [ ] Step 2: Normalize patient-facing error language.
- [ ] Step 3: Ensure paused/completed/cancelled copy remains medically calm.
- [ ] Step 4: Verify analyzer clean.

### Task 6: Compatibility and Security Validation

**Files:**
- Check: `lib/features/aftercare/data/aftercare_timeline_mapper.dart`
- Check: `lib/features/aftercare/data/patient_aftercare_plan_service.dart`
- Check: `firestore.rules`

- [ ] Step 1: Confirm unchanged timeline route and mapping compatibility.
- [ ] Step 2: Confirm no permission broadening and no sensitive local queue fields.
- [ ] Step 3: Run targeted error scan for modified files.

### Task 7: Final Verification

**Files:**
- Verify: modified files and related tests

- [ ] Step 1: Run Dart analyzer on all touched aftercare files.
- [ ] Step 2: Run targeted tests.
- [ ] Step 3: Summarize results and residual risks.
