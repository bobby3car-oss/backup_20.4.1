import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/family_visibility.dart';
import '../domain/linked_family_patient.dart';

/// Repository for the family role.
///
/// Handles multi-patient linked data access and real-time streams.
class FamilyRepository {
  FamilyRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  // ─── Linked patients ──────────────────────────────────────────────

  /// Stream of all patients this family member is linked to.
  Stream<List<LinkedFamilyPatient>> watchLinkedPatients() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collectionGroup('links')
        .where('linkedUid', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .where('linkType', isEqualTo: 'family')
        .snapshots()
        .asyncMap((snapshot) async {
      final patients = <LinkedFamilyPatient>[];
      for (final doc in snapshot.docs) {
        final patientId = doc.reference.parent.parent?.id;
        if (patientId == null) continue;

        // Fetch patient profile data for display
        Map<String, dynamic>? patientData;
        try {
          final patientDoc = await _firestore
              .collection(FirestorePaths.users)
              .doc(patientId)
              .get();
          patientData = patientDoc.data();
        } catch (_) {}

        patients.add(LinkedFamilyPatient.fromLinkDoc(
          doc,
          patientData: patientData,
        ));
      }
      return patients;
    });
  }

  /// Get a single linked patient's details.
  Future<LinkedFamilyPatient?> getLinkedPatient(String patientId) async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final linkDoc = await _firestore
          .doc('${FirestorePaths.linksCollection(patientId)}/${uid}_family')
          .get();

      if (!linkDoc.exists) return null;

      final patientDoc = await _firestore
          .collection(FirestorePaths.users)
          .doc(patientId)
          .get();

      return LinkedFamilyPatient.fromLinkDoc(
        linkDoc,
        patientData: patientDoc.data(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get the visibility settings for a specific patient link.
  Future<FamilyVisibility> getVisibility(String patientId) async {
    final uid = _uid;
    if (uid == null) return const FamilyVisibility();

    try {
      final doc = await _firestore
          .doc('${FirestorePaths.linksCollection(patientId)}/${uid}_family')
          .get();
      final data = doc.data();
      return FamilyVisibility.fromMap(
        data?['visibility'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return const FamilyVisibility();
    }
  }

  // ─── Patient data streams (permission-gated) ──────────────────────

  /// Stream timeline entries for a patient (if visible).
  Stream<QuerySnapshot<Map<String, dynamic>>> watchTimeline(
    String patientId,
  ) {
    return _firestore
        .collection(FirestorePaths.timelineCollection(patientId))
        .orderBy('scheduledAt')
        .snapshots();
  }

  /// Stream vital entries for a patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchVitals(
    String patientId,
  ) {
    return _firestore
        .collection('${FirestorePaths.patientDoc(patientId)}/vitals')
        .orderBy('measuredAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Stream pain entries for a patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPain(
    String patientId,
  ) {
    return _firestore
        .collection(FirestorePaths.painCollection(patientId))
        .orderBy('recordedAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Stream wound entries for a patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchWounds(
    String patientId,
  ) {
    return _firestore
        .collection(FirestorePaths.woundsCollection(patientId))
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Stream appointments for a patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchAppointments(
    String patientId,
  ) {
    return _firestore
        .collection(FirestorePaths.appointmentsCollection(patientId))
        .orderBy('dateTime')
        .snapshots();
  }

  /// Stream red flags for a patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchRedFlags(
    String patientId,
  ) {
    return _firestore
        .collection('${FirestorePaths.patientDoc(patientId)}/red_flags')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Stream medication intake entries for a patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMedications(
    String patientId,
  ) {
    return _firestore
        .collection('${FirestorePaths.patientDoc(patientId)}/medication_intakes')
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Stream document entries for a patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDocuments(
    String patientId,
  ) {
    return _firestore
        .collection(FirestorePaths.documentsCollection(patientId))
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // ─── Messages ─────────────────────────────────────────────────────

  static String _messagesPath(String patientId) =>
      '${FirestorePaths.patientDoc(patientId)}/messages';

  /// Stream messages between family member and patient.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(
    String patientId,
  ) {
    return _firestore
        .collection(_messagesPath(patientId))
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  /// Send a message to the patient.
  Future<void> sendMessage({
    required String patientId,
    required String text,
  }) async {
    final uid = _uid;
    final user = _auth.currentUser;
    if (uid == null) return;

    await _firestore.collection(_messagesPath(patientId)).add({
      'text': text,
      'authorUid': uid,
      'authorName': user?.displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Accept additional invite ─────────────────────────────────────

  /// Accept a new invite code to link with another patient.
  /// This is called from the family settings to add more patients.
  Future<void> acceptInviteCode(String code) async {
    // The actual call is done in the UI layer via FirebaseFunctions.
    throw UnimplementedError(
      'Use FirebaseFunctions.instance.httpsCallable("acceptInvite") directly.',
    );
  }
}
