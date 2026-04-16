# Security Hardening Route 1 Stage 1 Foundations Implementation Plan

**Goal:** Establish secure stage-1 foundations for Route 1 by enforcing a single EU Cloud Functions entry point, making secure local writes fail closed, moving sensitive in-app notification persistence to encrypted storage, and defaulting analytics/crash reporting to off until consent is explicitly applied.

**Architecture:** This stage is deliberately scoped to the cross-cutting foundations that later Bella and data-split work depend on. It adds one shared Functions helper in `lib/firebase/`, hardens storage behavior at the `UserScopedStorage` boundary, keeps notification persistence inside the existing singleton repository while switching it to secure user-scoped I/O, and uses platform config plus explicit consent enablement for telemetry.

**Tech Stack:** Flutter, Dart, Firebase Cloud Functions, Firebase Analytics, Firebase Crashlytics, flutter_secure_storage, SharedPreferences, AndroidManifest.xml, Apple Info.plist files, Flutter policy tests.

---

Route decomposition note:
- Route 1 from the spec is too large for one safe execution batch.
- This plan covers only Stage 1 foundations.
- Later stages should handle Bella server-side consent gates, wound-input validation, then the data split and key/migration removal.

### Task 1: Add a shared EU Functions helper

**Files:**
- Create: `lib/firebase/app_functions.dart`
- Modify: `lib/roles/admin/admin_functions.dart`

- [ ] **Step 1: Create the shared helper file**

Add `lib/firebase/app_functions.dart` with one region constant and one helper:

```dart
import 'package:cloud_functions/cloud_functions.dart';

const appFunctionsRegion = 'europe-west1';

FirebaseFunctions appFunctions() =>
    FirebaseFunctions.instanceFor(region: appFunctionsRegion);
```

- [ ] **Step 2: Reuse the shared region in admin helper**

Update `lib/roles/admin/admin_functions.dart` so admin calls still use the same region constant instead of maintaining a separate source of truth.

- [ ] **Step 3: Run analyzer on the helper files**

Run: `dart analyze lib/firebase/app_functions.dart lib/roles/admin/admin_functions.dart`
Expected: no errors.

- [ ] **Step 4: Commit the helper foundation**

```bash
git add lib/firebase/app_functions.dart lib/roles/admin/admin_functions.dart
git commit -m "feat(security): add shared EU functions helper"
```

### Task 2: Enforce the shared helper at current sensitive Functions call sites

**Files:**
- Create: `test/security/functions_region_policy_test.dart`
- Modify: `lib/auth/auth_gate.dart`
- Modify: `lib/auth/user_profile_service.dart`
- Modify: `lib/features/doctor_invite/data/doctor_invite_service.dart`
- Modify: `lib/features/doctor_patients/data/doctor_patient_repository.dart`
- Modify: `lib/features/doctor_staff/data/staff_management_service.dart`
- Modify: `lib/features/organisation/data/organisation_service.dart`
- Modify: `lib/features/organisation/data/org_membership_service.dart`
- Modify: `lib/features/pro/data/billing_service.dart`
- Modify: `lib/features/pro/data/key_redemption_service.dart`
- Modify: `lib/linking/linking_screen.dart`
- Modify: `lib/security/encryption_key_manager.dart`
- Modify: `lib/screens/onboarding/register_doctor_screen.dart`
- Modify: `lib/screens/linked_doctors_screen.dart`
- Modify: `lib/screens/caregiver_screen.dart`
- Modify: `lib/screens/family_member_hub_screen.dart`
- Modify: `lib/features/family/presentation/family_patients_tab.dart`
- Modify: `lib/features/family/presentation/family_overview_tab.dart`
- Modify: `lib/features/family/presentation/family_profile_tab.dart`
- Modify: `lib/features/family/data/family_repository.dart`

- [ ] **Step 1: Write a failing policy test for direct default Functions usage**

Create `test/security/functions_region_policy_test.dart` that:
- scans `lib/`
- fails if a source file still contains `FirebaseFunctions.instance.httpsCallable(`
- fails if a source file still contains `functions ?? FirebaseFunctions.instance`
- fails if a source file still contains `FirebaseFunctions.instanceFor(region:` outside the helper files
- allows only helper files that intentionally create region-bound instances

Use an allowlist for:
- `lib/firebase/app_functions.dart`
- `lib/roles/admin/admin_functions.dart`
- no other files

- [ ] **Step 2: Run the policy test and verify RED**

Run: `flutter test test/security/functions_region_policy_test.dart`
Expected: FAIL and list the current direct-call files.

- [ ] **Step 3: Migrate service constructors and call sites to `appFunctions()`**

Update every file listed above so that:
- injected defaults use `appFunctions()` instead of `FirebaseFunctions.instance`
- one-off UI call sites call `appFunctions().httpsCallable(...)`
- existing region-pinned callers also switch to `appFunctions()` so the region remains defined in one place
- existing behavior and payloads stay unchanged
- `family_repository.dart` no longer documents the insecure direct default-instance pattern

- [ ] **Step 4: Re-run the policy test and verify GREEN**

Run: `flutter test test/security/functions_region_policy_test.dart`
Expected: PASS.

- [ ] **Step 5: Run analyzer on all touched functions-call files**

Run:

```bash
dart analyze \
  lib/auth/auth_gate.dart \
  lib/auth/user_profile_service.dart \
  lib/features/doctor_invite/data/doctor_invite_service.dart \
  lib/features/doctor_patients/data/doctor_patient_repository.dart \
  lib/features/doctor_staff/data/staff_management_service.dart \
  lib/features/organisation/data/organisation_service.dart \
  lib/features/organisation/data/org_membership_service.dart \
  lib/features/pro/data/billing_service.dart \
  lib/features/pro/data/key_redemption_service.dart \
  lib/linking/linking_screen.dart \
  lib/security/encryption_key_manager.dart \
  lib/screens/onboarding/register_doctor_screen.dart \
  lib/screens/linked_doctors_screen.dart \
  lib/screens/caregiver_screen.dart \
  lib/screens/family_member_hub_screen.dart \
  lib/features/family/presentation/family_patients_tab.dart \
  lib/features/family/presentation/family_overview_tab.dart \
  lib/features/family/presentation/family_profile_tab.dart \
  lib/features/family/data/family_repository.dart
```

Expected: no new errors in touched files.

- [ ] **Step 6: Commit the call site migration**

```bash
git add \
  test/security/functions_region_policy_test.dart \
  lib/auth/auth_gate.dart \
  lib/auth/user_profile_service.dart \
  lib/features/doctor_invite/data/doctor_invite_service.dart \
  lib/features/doctor_patients/data/doctor_patient_repository.dart \
  lib/features/doctor_staff/data/staff_management_service.dart \
  lib/features/organisation/data/organisation_service.dart \
  lib/features/organisation/data/org_membership_service.dart \
  lib/features/pro/data/billing_service.dart \
  lib/features/pro/data/key_redemption_service.dart \
  lib/linking/linking_screen.dart \
  lib/security/encryption_key_manager.dart \
  lib/screens/onboarding/register_doctor_screen.dart \
  lib/screens/linked_doctors_screen.dart \
  lib/screens/caregiver_screen.dart \
  lib/screens/family_member_hub_screen.dart \
  lib/features/family/presentation/family_patients_tab.dart \
  lib/features/family/presentation/family_overview_tab.dart \
  lib/features/family/presentation/family_profile_tab.dart \
  lib/features/family/data/family_repository.dart
git commit -m "fix(security): enforce EU functions helper in sensitive flows"
```

### Task 3: Make secure local writes fail closed

**Files:**
- Create: `test/security/local_storage_encryption_test.dart`
- Modify: `lib/security/local_storage_encryption.dart`
- Modify: `lib/sync/user_scoped_storage.dart`

- [ ] **Step 1: Write failing tests for secure-write behavior**

Create `test/security/local_storage_encryption_test.dart` with tests for:
- encryption roundtrip with a deterministic testing key
- `encryptForStorage(..., allowPlaintextFallback: false)` throws when no key is loaded
- decrypt still returns legacy plaintext unchanged

To make this testable, plan to add `@visibleForTesting` hooks in `LocalStorageEncryption` for setting and clearing the in-memory key.

- [ ] **Step 2: Run the local storage test and verify RED**

Run: `flutter test test/security/local_storage_encryption_test.dart`
Expected: FAIL because the new secure-write API/testing hooks do not exist yet.

- [ ] **Step 3: Add an explicit secure-write API to `LocalStorageEncryption`**

Update `lib/security/local_storage_encryption.dart` to:
- keep `decrypt()` legacy plaintext fallback for reads
- add a new method for writes that either encrypts or throws when fallback is disallowed
- expose testing-only key setters/resetters so the behavior can be tested deterministically

Recommended write API:

```dart
String encryptForStorage(
  String plaintext, {
  required bool allowPlaintextFallback,
})
```

- [ ] **Step 4: Route `UserScopedStorage.writeSecure()` through the explicit secure-write API**

Update `lib/sync/user_scoped_storage.dart` so that:
- release/profile writes require encryption
- debug/test can still opt into plaintext fallback when a key is not initialized
- the comment no longer claims plaintext fallback is normal production behavior

- [ ] **Step 5: Re-run the test and verify GREEN**

Run: `flutter test test/security/local_storage_encryption_test.dart`
Expected: PASS.

- [ ] **Step 6: Run analyzer on the storage files**

Run: `dart analyze lib/security/local_storage_encryption.dart lib/sync/user_scoped_storage.dart test/security/local_storage_encryption_test.dart`
Expected: no errors.

- [ ] **Step 7: Commit the storage hardening**

```bash
git add \
  test/security/local_storage_encryption_test.dart \
  lib/security/local_storage_encryption.dart \
  lib/sync/user_scoped_storage.dart
git commit -m "fix(security): fail closed for secure local writes"
```

### Task 4: Move in-app notification persistence to secure storage

**Files:**
- Create: `test/security/notification_repository_persistence_policy_test.dart`
- Modify: `lib/notifications/notification_repository.dart`

- [ ] **Step 1: Write a failing policy test for notification persistence**

Create `test/security/notification_repository_persistence_policy_test.dart` that reads `lib/notifications/notification_repository.dart` and asserts:
- `UserScopedStorage.instance.readSecure(` is used
- `UserScopedStorage.instance.writeSecure(` is used
- the file no longer contains direct `readAsString(` or `writeAsString(` calls

- [ ] **Step 2: Run the policy test and verify RED**

Run: `flutter test test/security/notification_repository_persistence_policy_test.dart`
Expected: FAIL against the current direct file I/O implementation.

- [ ] **Step 3: Refactor the repository to use secure user-scoped persistence**

Update `lib/notifications/notification_repository.dart` so that:
- `loadFromDisk()` reads JSON via `UserScopedStorage.instance.readSecure('in_app_notifications.json')`
- `saveToDisk()` writes JSON via `UserScopedStorage.instance.writeSecure('in_app_notifications.json', payload)`
- raw `File` I/O helpers and the `dart:io` dependency are removed if no longer needed

- [ ] **Step 4: Re-run the policy test and verify GREEN**

Run: `flutter test test/security/notification_repository_persistence_policy_test.dart`
Expected: PASS.

- [ ] **Step 5: Run analyzer on the repository and test**

Run: `dart analyze lib/notifications/notification_repository.dart test/security/notification_repository_persistence_policy_test.dart`
Expected: no errors.

- [ ] **Step 6: Commit the notification persistence change**

```bash
git add \
  test/security/notification_repository_persistence_policy_test.dart \
  lib/notifications/notification_repository.dart
git commit -m "fix(security): encrypt in-app notification persistence"
```

### Task 5: Default analytics and crash reporting to off until consent

**Files:**
- Create: `test/security/telemetry_defaults_policy_test.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`
- Modify: `macos/Runner/Info.plist`
- Modify: `lib/security/privacy_consent_service.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Write a failing policy test for telemetry defaults**

Create `test/security/telemetry_defaults_policy_test.dart` that asserts:
- `android/app/src/main/AndroidManifest.xml` contains `firebase_analytics_collection_enabled=false`
- `android/app/src/main/AndroidManifest.xml` contains `firebase_crashlytics_collection_enabled=false`
- `ios/Runner/Info.plist` contains `FIREBASE_ANALYTICS_COLLECTION_ENABLED` set to false
- `ios/Runner/Info.plist` contains `FirebaseCrashlyticsCollectionEnabled` set to false
- `macos/Runner/Info.plist` contains the same Apple defaults if Crashlytics/Analytics are linked there
- `lib/main.dart` only installs Crashlytics handlers after consent is loaded and enabled

- [ ] **Step 2: Run the telemetry policy test and verify RED**

Run: `flutter test test/security/telemetry_defaults_policy_test.dart`
Expected: FAIL because the platform flags do not exist yet.

- [ ] **Step 3: Add default-off platform flags**

Update Android manifest with metadata entries:

```xml
<meta-data android:name="firebase_analytics_collection_enabled" android:value="false" />
<meta-data android:name="firebase_crashlytics_collection_enabled" android:value="false" />
```

Update Apple Info.plist files with:

```xml
<key>FIREBASE_ANALYTICS_COLLECTION_ENABLED</key>
<false/>
<key>FirebaseCrashlyticsCollectionEnabled</key>
<false/>
```

- [ ] **Step 4: Tighten app-side consent enabling**

Update `lib/security/privacy_consent_service.dart` and `lib/main.dart` so that:
- consent init remains the single source of truth for enabling analytics/crashlytics
- crash handlers are attached only when consent is enabled
- comments and method docs state that collection is disabled by default at the platform level and only enabled after consent

- [ ] **Step 5: Re-run the telemetry policy test and verify GREEN**

Run: `flutter test test/security/telemetry_defaults_policy_test.dart`
Expected: PASS.

- [ ] **Step 6: Run analyzer on the app-side consent files**

Run: `dart analyze lib/security/privacy_consent_service.dart lib/main.dart test/security/telemetry_defaults_policy_test.dart`
Expected: no errors.

- [ ] **Step 7: Commit the telemetry defaults**

```bash
git add \
  test/security/telemetry_defaults_policy_test.dart \
  android/app/src/main/AndroidManifest.xml \
  ios/Runner/Info.plist \
  macos/Runner/Info.plist \
  lib/security/privacy_consent_service.dart \
  lib/main.dart
git commit -m "fix(security): default telemetry to off until consent"
```

### Task 6: Stage 1 verification

**Files:**
- Verify: all files touched in Tasks 1-5

- [ ] **Step 1: Run analyzer on all touched Dart files**

Run:

```bash
dart analyze \
  lib/firebase/app_functions.dart \
  lib/roles/admin/admin_functions.dart \
  lib/auth/auth_gate.dart \
  lib/auth/user_profile_service.dart \
  lib/features/doctor_invite/data/doctor_invite_service.dart \
  lib/features/doctor_patients/data/doctor_patient_repository.dart \
  lib/features/doctor_staff/data/staff_management_service.dart \
  lib/features/organisation/data/organisation_service.dart \
  lib/features/organisation/data/org_membership_service.dart \
  lib/features/pro/data/billing_service.dart \
  lib/features/pro/data/key_redemption_service.dart \
  lib/linking/linking_screen.dart \
  lib/security/encryption_key_manager.dart \
  lib/screens/onboarding/register_doctor_screen.dart \
  lib/screens/linked_doctors_screen.dart \
  lib/screens/caregiver_screen.dart \
  lib/screens/family_member_hub_screen.dart \
  lib/features/family/presentation/family_patients_tab.dart \
  lib/features/family/presentation/family_overview_tab.dart \
  lib/features/family/presentation/family_profile_tab.dart \
  lib/features/family/data/family_repository.dart \
  lib/security/local_storage_encryption.dart \
  lib/sync/user_scoped_storage.dart \
  lib/notifications/notification_repository.dart \
  lib/security/privacy_consent_service.dart \
  lib/main.dart
```

Expected: no new analyzer errors in touched files.

- [ ] **Step 2: Run the targeted stage-1 tests**

Run:

```bash
flutter test test/security
```

Expected: all PASS.

- [ ] **Step 3: Run a focused git diff review**

Check that:
- no direct default Functions instance remains in Stage 1 target files
- no plaintext fallback remains in `writeSecure()` for non-debug production paths
- notification repository no longer uses raw file read/write for persisted content
- Android/iOS/macOS telemetry defaults are explicitly off

- [ ] **Step 4: Summarize residual risks before moving to Stage 2**

Residual items expected after Stage 1:
- Bella still needs server-side consent and wound-input enforcement
- user/private/care data split is not done yet
- shared-key migration and legacy field cleanup are not done yet

- [ ] **Step 5: Commit only if Stage 1 verification required a doc/test adjustment**

If verification introduces a small fix, commit it separately with the narrowest possible message.