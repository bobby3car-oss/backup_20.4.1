import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/questionnaire_data.dart';

/// Persists onboarding questionnaire data to `users/{uid}` and manages the
/// `onboardingComplete` gate flag.
class QuestionnaireRepository {
  QuestionnaireRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Saves the completed questionnaire to the user document and also stores
  /// the `opDate` in the patient document (for timeline generation).
  Future<void> saveQuestionnaire(String uid, QuestionnaireData data) async {
    final userRef = _firestore.doc(FirestorePaths.userDoc(uid));
    await userRef.set(data.toFirestore(uid: uid), SetOptions(merge: true));

    // Mirror opDate to patients/{uid} so the timeline engine can find it.
    final patientRef = _firestore.doc(FirestorePaths.patientDoc(uid));
    await patientRef.set(<String, dynamic>{
      if (data.opDate != null) 'opDate': data.opDate!.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Checks whether the patient has completed the onboarding questionnaire.
  /// Returns `true` if the field is explicitly `true`, or if the user doc
  /// was created before the questionnaire feature (no field present but
  /// the doc already has profile data like `opDate` or `role`).
  Future<bool> isOnboardingComplete(String uid) async {
    final ref = _firestore.doc(FirestorePaths.userDoc(uid));
    // watchMyRole() already started a Firestore listener on this document by
    // the time _buildPatientGate() is called, so the doc is in the local
    // cache. Use cache-first to avoid an extra network round trip on startup.
    DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      // On web, Source.cache can hang if IndexedDB isn't ready yet.
      doc = await ref
          .get(const GetOptions(source: Source.cache))
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      try {
        doc = await ref.get().timeout(const Duration(seconds: 2));
      } catch (_) {
        // All reads failed or timed out – skip questionnaire so the UI
        // isn't blocked.  watchMyRole() will correct the view shortly.
        return true;
      }
    }
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    // Non-patient roles must never see the patient onboarding questionnaire.
    final role = data['role']?.toString() ?? '';
    if (role.isNotEmpty && role != 'patient') return true;
    // Explicitly completed.
    if (data['onboardingComplete'] == true) return true;
    // Existing user who registered before the questionnaire feature:
    // if the field doesn't exist at all, skip the questionnaire.
    if (!data.containsKey('onboardingComplete')) return true;
    return false;
  }
}
