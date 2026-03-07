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
    await userRef.set(data.toFirestore(), SetOptions(merge: true));

    // Mirror opDate to patients/{uid} so the timeline engine can find it.
    final patientRef = _firestore.doc(FirestorePaths.patientDoc(uid));
    await patientRef.set(<String, dynamic>{
      'opDate': data.opDate.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Checks whether the patient has completed the onboarding questionnaire.
  /// Returns `true` if the field is explicitly `true`, or if the user doc
  /// was created before the questionnaire feature (no field present but
  /// the doc already has profile data like `opDate` or `role`).
  Future<bool> isOnboardingComplete(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    // Explicitly completed.
    if (data['onboardingComplete'] == true) return true;
    // Existing user who registered before the questionnaire feature:
    // if the field doesn't exist at all, skip the questionnaire.
    if (!data.containsKey('onboardingComplete')) return true;
    return false;
  }
}
