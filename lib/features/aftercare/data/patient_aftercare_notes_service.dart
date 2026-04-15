import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/aftercare_note.dart';
import '../domain/plan_status.dart';

/// Service for managing patient-private notes on aftercare plans.
///
/// Notes are stored at:
/// `patient_aftercare_plans/{planId}/patient_notes/{noteId}`
///
/// Strictly patient-only — no admin, doctor, or staff access.
/// Only active plans can have notes created/edited/deleted.
class PatientAftercareNotesService {
  PatientAftercareNotesService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notesCol(String planId) =>
      _firestore.collection(
        FirestorePaths.aftercarePatientNotesCollection(planId),
      );

  /// Streams all notes for a plan, ordered by creation date (newest first).
  Stream<List<AftercareNote>> watchNotes(String planId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);

    return _notesCol(planId)
        .where('patientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AftercareNote.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Fetches all notes once (non-streaming).
  Future<List<AftercareNote>> getNotes(String planId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const [];

    final snap = await _notesCol(planId)
        .where('patientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => AftercareNote.fromJson({...d.data(), 'id': d.id}))
        .toList(growable: false);
  }

  /// Creates a new note on an active plan.
  ///
  /// Returns the new note's ID, or empty string on failure.
  /// Rejects empty text and non-active plans.
  Future<String> createNote({
    required String planId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError('Notiz darf nicht leer sein');

    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht angemeldet');

    // Verify plan is active and belongs to user.
    await _verifyActivePlan(planId, uid);

    final ref = _notesCol(planId).doc();
    final now = DateTime.now();

    final note = AftercareNote(
      id: ref.id,
      patientId: uid,
      planId: planId,
      text: trimmed,
      createdAt: now,
      updatedAt: now,
    );

    final data = note.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }

  /// Updates an existing note's text.
  ///
  /// Only works for active plans.
  Future<void> updateNote({
    required String planId,
    required String noteId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError('Notiz darf nicht leer sein');

    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht angemeldet');

    await _verifyActivePlan(planId, uid);

    await _notesCol(planId).doc(noteId).update({
      'text': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a note.
  ///
  /// Only works for active plans.
  Future<void> deleteNote({
    required String planId,
    required String noteId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht angemeldet');

    await _verifyActivePlan(planId, uid);

    await _notesCol(planId).doc(noteId).delete();
  }

  /// Verifies that the plan exists, is active, and belongs to the user.
  Future<void> _verifyActivePlan(String planId, String uid) async {
    final planSnap = await _firestore
        .collection(FirestorePaths.patientAftercarePlans)
        .doc(planId)
        .get();

    if (!planSnap.exists) {
      throw StateError('Plan nicht gefunden');
    }

    final status = planSnap.data()?['status']?.toString();
    final isEditable = status == PlanStatus.active.name ||
        status == PlanStatus.paused.name;
    if (!isEditable) {
      throw StateError(
        'Notizen koennen nur bei aktiven oder pausierten Plaenen bearbeitet werden',
      );
    }

    final patientId = planSnap.data()?['patientId']?.toString();
    if (patientId != uid) {
      throw StateError('Kein Zugriff');
    }
  }
}
