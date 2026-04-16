# Route 1 Stage 3 Profile Boundary Cutover Implementation Plan

**Goal:** Split owner-only profile data from shared care-profile data, backfill the new Firestore documents, and cut critical Flutter read/write paths over to the new boundaries.

**Architecture:** Introduce an explicit `patients/{patientId}/care_profile/current` document alongside the already-added `users/{uid}/private/profile`, add rules and bootstrap support for the new path, create server-controlled backfill/projection tooling, then move self-only UI/services to the private profile and doctor/family patient views to the shared care profile. Keep the rollout fail-closed for permissions, but allow tightly scoped legacy read fallback only inside the migration window.

**Tech Stack:** Flutter 3 / Dart, Cloud Firestore, Firestore Rules + Emulator, Cloud Functions / Admin SDK migration tooling, existing `test/security` policy-test pattern.

---

## File Map

- Modify: `lib/firebase/firebase_paths.dart`
  Add canonical helpers for `patients/{patientId}/care_profile/current` and related collection constants.
- Modify: `firestore.rules`
  Add read/write boundaries for shared care profile vs owner-only private profile.
- Modify: `lib/firebase/bootstrap_service.dart`
  Ensure new patient roots create the `care_profile/current` scaffold during bootstrap.
- Create: `test/security/profile_boundary_cutover_policy_test.dart`
  Lock in the new path helpers and client cutover expectations with static policy tests.
- Create: `tests/rules/patient_care_profile_access.test.js`
  Emulator coverage for owner, linked doctor/family, and unauthorized access to care profile docs.
- Modify: `tests/rules/package.json`
  Add targeted scripts for the new care-profile rules suite.
- Create: `lib/features/profile/data/profile_boundary_repository.dart`
  Single place that reads/writes the private-profile doc, shared shell user doc, and care-profile projection.
- Modify: `lib/auth/user_profile_service.dart`
  Stop treating `users/{uid}` as the source of owner-only PII.
- Modify: `lib/screens/profile_settings_screen.dart`
  Write owner-only fields to `users/{uid}/private/profile` and shared fields to `patients/{uid}/care_profile/current`.
- Modify: `lib/features/emergency/data/emergency_repository.dart`
  Read emergency/private contact data from the private profile doc instead of mixed user-doc fields.
- Modify: `lib/features/doctor_patients/data/doctor_patient_repository.dart`
  Read patient-facing display metadata from `care_profile/current` instead of decrypting `users/{uid}`.
- Modify: `lib/features/family/data/family_repository.dart`
  Read family-visible patient data from `care_profile/current`.
- Modify: `lib/features/family/domain/linked_family_patient.dart`
  Align the patient model with the new shared care-profile payload.
- Create or Modify: `functions/index.js`
  Add admin-only backfill/projection tooling for private profile + care profile data reconstruction.

## Task 1: RED - Add Failing Cutover Tests

**Files:**
- Create: `test/security/profile_boundary_cutover_policy_test.dart`
- Create: `tests/rules/patient_care_profile_access.test.js`
- Modify: `tests/rules/package.json`

- [ ] **Step 1: Add Flutter policy tests that describe the cutover.**

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('firebase paths expose patient care profile helper', () async {
    final paths = File('lib/firebase/firebase_paths.dart').readAsStringSync();

    expect(paths, contains('static const String careProfile = \'care_profile\''));
    expect(paths, contains('static String patientCareProfileDoc(String patientId) =>'));
  });

  test('profile settings no longer persist owner-only pii in users doc', () async {
    final screen = File('lib/screens/profile_settings_screen.dart').readAsStringSync();

    expect(screen, isNot(contains("'emergencyContactPhone': enc.encryptField(user.uid")));
    expect(screen, isNot(contains("'hospitalName': enc.encryptField(user.uid")));
    expect(screen, contains('FirestorePaths.userPrivateProfileDoc(user.uid)'));
    expect(screen, contains('FirestorePaths.patientCareProfileDoc(user.uid)'));
  });

  test('doctor and family repositories read shared patient data from care profile', () async {
    final doctorRepo = File('lib/features/doctor_patients/data/doctor_patient_repository.dart').readAsStringSync();
    final familyRepo = File('lib/features/family/data/family_repository.dart').readAsStringSync();

    expect(doctorRepo, contains('FirestorePaths.patientCareProfileDoc(patientId)'));
    expect(familyRepo, contains('FirestorePaths.patientCareProfileDoc(patientId)'));
  });
}
```

- [ ] **Step 2: Add a Firestore emulator test for `care_profile/current`.**

```javascript
describe('patients/{patientId}/care_profile/current', () => {
  it('allows owner and linked care roles to read, but only owner/admin to write', async () => {
    // owner read/write allowed
    // linked doctor read allowed, write denied
    // linked family read allowed, write denied
    // unrelated user denied
  });
});
```

- [ ] **Step 3: Add targeted npm scripts.**

```json
{
  "scripts": {
    "test:care-profile": "mocha --timeout 30000 --exit patient_care_profile_access.test.js",
    "test:care-profile:emulator": "firebase emulators:exec --only firestore 'npm run test:care-profile' --project operationsbegleiter-860e7"
  }
}
```

- [ ] **Step 4: Run the RED checks and confirm they fail for the expected reasons.**

Run:

```bash
cd /Users/jan/projects/operationsbegleiter_v3
flutter test test/security/profile_boundary_cutover_policy_test.dart
```

Expected: FAIL because `patientCareProfileDoc` and cutover call sites do not exist yet.

Run:

```bash
cd /Users/jan/projects/operationsbegleiter_v3/tests/rules
export JAVA_HOME="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
npm run test:care-profile:emulator
```

Expected: FAIL because `care_profile/current` rules are not implemented yet.

- [ ] **Step 5: Commit the failing tests.**

```bash
git add test/security/profile_boundary_cutover_policy_test.dart tests/rules/patient_care_profile_access.test.js tests/rules/package.json
git commit -m "test(security): add failing tests for profile boundary cutover"
```

## Task 2: GREEN - Add Path Helpers, Bootstrap Support, and Rules

**Files:**
- Modify: `lib/firebase/firebase_paths.dart`
- Modify: `lib/firebase/bootstrap_service.dart`
- Modify: `firestore.rules`
- Test: `tests/rules/patient_care_profile_access.test.js`

- [ ] **Step 1: Add canonical Firestore path helpers.**

```dart
static const String careProfile = 'care_profile';

static String patientCareProfileDoc(String patientId) =>
    '${patientDoc(patientId)}/$careProfile/current';
```

- [ ] **Step 2: Scaffold `care_profile/current` during patient bootstrap.**

```dart
await ref.set(<String, dynamic>{
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
  'profile': <String, dynamic>{},
  'settings': <String, dynamic>{},
}, SetOptions(merge: true));

await _firestore.doc(FirestorePaths.patientCareProfileDoc(uid)).set(
  <String, dynamic>{
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  },
  SetOptions(merge: true),
);
```

- [ ] **Step 3: Add rules for shared care profile access.**

```text
match /care_profile/{docId} {
  allow read: if canReadPatient(patientId);
  allow create, update, delete: if isAdmin() || isPatientOwner(patientId);
}
```

- [ ] **Step 4: Run the targeted rules test and confirm GREEN.**

Run:

```bash
cd /Users/jan/projects/operationsbegleiter_v3/tests/rules
export JAVA_HOME="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
npm run test:care-profile:emulator
```

Expected: PASS.

- [ ] **Step 5: Commit the path/rules scaffold.**

```bash
git add lib/firebase/firebase_paths.dart lib/firebase/bootstrap_service.dart firestore.rules tests/rules/package.json tests/rules/patient_care_profile_access.test.js
git commit -m "feat(security): add shared care profile boundary"
```

## Task 3: GREEN - Add Server-Controlled Backfill and Projection Tooling

**Files:**
- Modify: `functions/index.js`
- Test: `test/security/profile_boundary_cutover_policy_test.dart`

- [ ] **Step 1: Add pure mapping helpers for private vs shared fields.**

```javascript
function buildPrivateProfileProjection(userData) {
  return {
    email: userData.email ?? null,
    hospitalName: userData.hospitalName ?? null,
    doctorName: userData.doctorName ?? null,
    emergencyContactName: userData.emergencyContactName ?? null,
    emergencyContactPhone: userData.emergencyContactPhone ?? null,
    hospitalPhone: userData.hospitalPhone ?? null,
    doctorPhone: userData.doctorPhone ?? null,
    insuranceInfo: userData.insuranceInfo ?? null,
    bloodType: userData.bloodType ?? null,
    allergies: userData.allergies ?? [],
    currentMedications: userData.currentMedications ?? [],
    bellaConsent: userData.bellaConsent ?? null,
  };
}

function buildCareProfileProjection(userData, patientData) {
  return {
    displayName: userData.displayName ?? '',
    age: userData.age ?? null,
    opType: userData.opType ?? null,
    opDate: patientData.opDate ?? userData.opDate ?? null,
    diagnosis: patientData.profile?.diagnosis ?? null,
  };
}
```

- [ ] **Step 2: Add an admin-only callable or admin script entry point in `europe-west1`.**

```javascript
exports.backfillProfileBoundaries = onCall({ region: 'europe-west1' }, async (request) => {
  enforceAdmin(request);
  // read existing users/{uid} and patients/{uid}
  // write users/{uid}/private/profile and patients/{uid}/care_profile/current
  // return migrated count
});
```

- [ ] **Step 3: Extend the policy test to lock the tooling into place.**

```dart
test('backend exposes eu-pinned profile boundary backfill tooling', () {
  final backend = File('functions/index.js').readAsStringSync();

  expect(backend, contains('exports.backfillProfileBoundaries'));
  expect(backend, contains("region: 'europe-west1'"));
});
```

- [ ] **Step 4: Verify backend syntax.**

Run:

```bash
cd /Users/jan/projects/operationsbegleiter_v3
node --check functions/index.js
```

Expected: exit code 0.

- [ ] **Step 5: Commit the migration tooling.**

```bash
git add functions/index.js test/security/profile_boundary_cutover_policy_test.dart
git commit -m "feat(security): add profile boundary backfill tooling"
```

## Task 4: GREEN - Cut Over Self-Only Profile Reads and Writes

**Files:**
- Create: `lib/features/profile/data/profile_boundary_repository.dart`
- Modify: `lib/auth/user_profile_service.dart`
- Modify: `lib/screens/profile_settings_screen.dart`
- Modify: `lib/features/emergency/data/emergency_repository.dart`
- Test: `test/security/profile_boundary_cutover_policy_test.dart`

- [ ] **Step 1: Add a repository that merges shell, private, and care-profile docs.**

```dart
class ProfileBoundaryRepository {
  ProfileBoundaryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> getSelfProfile(String uid) async {
    final results = await Future.wait([
      _firestore.doc(FirestorePaths.userDoc(uid)).get(),
      _firestore.doc(FirestorePaths.userPrivateProfileDoc(uid)).get(),
      _firestore.doc(FirestorePaths.patientCareProfileDoc(uid)).get(),
    ]);

    return {
      ...?results[0].data(),
      ...?results[1].data(),
      ...?results[2].data(),
    };
  }
}
```

- [ ] **Step 2: Move owner-only writes out of `users/{uid}`.**

```dart
batch.set(
  firestore.doc(FirestorePaths.userPrivateProfileDoc(user.uid)),
  <String, dynamic>{
    'hospitalName': _hospitalCtrl.text.trim(),
    'doctorName': _doctorNameCtrl.text.trim(),
    'emergencyContactName': _emergencyNameCtrl.text.trim(),
    'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
    'hospitalPhone': _hospitalPhoneCtrl.text.trim(),
    'doctorPhone': _doctorPhoneCtrl.text.trim(),
    'insuranceInfo': _insuranceInfoCtrl.text.trim(),
    'bloodType': _bloodType,
    'allergies': _allergies,
    'currentMedications': _currentMedications,
    'updatedAt': FieldValue.serverTimestamp(),
  },
  SetOptions(merge: true),
);

batch.set(
  firestore.doc(FirestorePaths.patientCareProfileDoc(user.uid)),
  <String, dynamic>{
    'displayName': newName,
    'age': int.tryParse(_ageCtrl.text.trim()),
    'opType': _opTypeCtrl.text.trim(),
    'opDate': selectedOpDate?.toIso8601String(),
    'updatedAt': FieldValue.serverTimestamp(),
  },
  SetOptions(merge: true),
);
```

- [ ] **Step 3: Stop decrypting mixed PII from `users/{uid}` in self-only flows.**

```dart
return _profileBoundaryRepository.watchSelfProfile(uid);
```

- [ ] **Step 4: Run the Flutter policy test and targeted analyzer.**

Run:

```bash
cd /Users/jan/projects/operationsbegleiter_v3
flutter test test/security/profile_boundary_cutover_policy_test.dart
dart analyze lib/auth/user_profile_service.dart lib/screens/profile_settings_screen.dart lib/features/emergency/data/emergency_repository.dart lib/features/profile/data/profile_boundary_repository.dart
```

Expected: PASS, then `No issues found!`.

- [ ] **Step 5: Commit the self-profile cutover.**

```bash
git add lib/features/profile/data/profile_boundary_repository.dart lib/auth/user_profile_service.dart lib/screens/profile_settings_screen.dart lib/features/emergency/data/emergency_repository.dart test/security/profile_boundary_cutover_policy_test.dart
git commit -m "feat(security): cut over self profile to private and care docs"
```

## Task 5: GREEN - Cut Over Doctor and Family Patient Reads

**Files:**
- Modify: `lib/features/doctor_patients/data/doctor_patient_repository.dart`
- Modify: `lib/features/family/data/family_repository.dart`
- Modify: `lib/features/family/domain/linked_family_patient.dart`
- Test: `test/security/profile_boundary_cutover_policy_test.dart`

- [ ] **Step 1: Read patient-facing display data from `care_profile/current`.**

```dart
final careProfileDoc = await _firestore
    .doc(FirestorePaths.patientCareProfileDoc(patientId))
    .get();
final careProfile = careProfileDoc.data() ?? const <String, dynamic>{};
```

- [ ] **Step 2: Remove shared-display dependence on `FieldEncryptionService` for doctor/family patient lists.**

```dart
displayName = (careProfile['displayName'] ?? profile['displayName'] ?? 'Patient').toString();
age = careProfile['age'] as int?;
```

- [ ] **Step 3: Keep a narrow temporary fallback only for migration drift.**

```dart
final legacyProfile = patientData['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{};
final resolvedDisplayName = (careProfile['displayName'] ?? legacyProfile['displayName'] ?? 'Patient').toString();
```

- [ ] **Step 4: Run targeted Flutter tests and analyzer.**

Run:

```bash
cd /Users/jan/projects/operationsbegleiter_v3
flutter test test/security/profile_boundary_cutover_policy_test.dart
dart analyze lib/features/doctor_patients/data/doctor_patient_repository.dart lib/features/family/data/family_repository.dart lib/features/family/domain/linked_family_patient.dart
```

Expected: PASS, then `No issues found!`.

- [ ] **Step 5: Commit the care-team read cutover.**

```bash
git add lib/features/doctor_patients/data/doctor_patient_repository.dart lib/features/family/data/family_repository.dart lib/features/family/domain/linked_family_patient.dart test/security/profile_boundary_cutover_policy_test.dart
git commit -m "feat(security): cut over care team reads to care profile"
```

## Task 6: Final Verification

**Files:**
- Verify all files touched in Tasks 1-5

- [ ] **Step 1: Run the focused Flutter/security checks.**

```bash
cd /Users/jan/projects/operationsbegleiter_v3
flutter test test/security/profile_boundary_cutover_policy_test.dart
dart analyze
```

Expected: all targeted tests pass, analyzer clean.

- [ ] **Step 2: Run the Firestore emulator suites.**

```bash
cd /Users/jan/projects/operationsbegleiter_v3/tests/rules
export JAVA_HOME="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
npm run test:private-profile:emulator
npm run test:care-profile:emulator
```

Expected: both suites pass.

- [ ] **Step 3: Verify backend syntax.**

```bash
cd /Users/jan/projects/operationsbegleiter_v3
node --check functions/index.js
```

Expected: exit code 0.

- [ ] **Step 4: Commit any final verification-driven fixes.**

```bash
git add [only files changed by verification fixes]
git commit -m "fix(security): finalize profile boundary cutover"
```

## Done Criteria

- Owner-only PII is stored in `users/{uid}/private/profile` instead of mixed `users/{uid}` fields.
- Shared patient display data used by doctors/family reads from `patients/{patientId}/care_profile/current`.
- Firestore rules allow linked care roles to read the shared care profile but deny non-owners write access.
- Bootstrap creates the new care-profile document boundary for new patients.
- Server-controlled backfill tooling exists and is EU-pinned.
- Existing unrelated worktree churn, especially under `functions/node_modules`, remains untouched.