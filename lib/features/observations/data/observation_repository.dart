import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/observation_entry.dart';

class ObservationRepository {
  ObservationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Watches all observations for a patient, ordered by creation date.
  Stream<List<ObservationEntry>> watchObservations(String patientId) {
    return _firestore
        .collection(FirestorePaths.observationsCollection(patientId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return ObservationEntry.fromJson(data);
      }).toList();
    });
  }

  /// Creates a new observation entry.
  Future<String> addObservation({
    required String patientId,
    required String text,
    ObservationSeverity severity = ObservationSeverity.info,
    String? attachmentUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not authenticated');

    final now = DateTime.now();
    final docRef = _firestore
        .collection(FirestorePaths.observationsCollection(patientId))
        .doc();

    final entry = ObservationEntry(
      id: docRef.id,
      patientId: patientId,
      authorUid: user.uid,
      authorName: user.displayName ?? user.email ?? 'Unbekannt',
      text: text,
      severity: severity,
      attachmentUrl: attachmentUrl,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(entry.toJson());
    return docRef.id;
  }

  /// Deletes an observation.
  Future<void> deleteObservation(
      String patientId, String observationId) async {
    await _firestore
        .doc(FirestorePaths.observationDoc(patientId, observationId))
        .delete();
  }
}
