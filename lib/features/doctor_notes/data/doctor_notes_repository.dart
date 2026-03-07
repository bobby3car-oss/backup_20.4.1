import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/doctor_note.dart';

/// Repository for private doctor notes (stored under doctors/{doctorUid}/patientNotes).
class DoctorNotesRepository {
  DoctorNotesRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notesRef() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    return _firestore.collection('doctors/$uid/patientNotes');
  }

  /// Streams notes for a specific patient, pinned first, then by updatedAt desc.
  Stream<List<DoctorNote>> watchNotes(String patientId) {
    return _notesRef()
        .where('patientId', isEqualTo: patientId)
        .orderBy('updatedAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) {
      final notes = snap.docs.map(DoctorNote.fromFirestore).toList();
      // Sort pinned first, then by updatedAt
      notes.sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return notes;
    });
  }

  /// Creates a new note.
  Future<String> createNote({
    required String patientId,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final ref = await _notesRef().add({
      'patientId': patientId,
      'title': title,
      'content': content,
      'tags': tags,
      'pinned': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Updates an existing note.
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (tags != null) data['tags'] = tags;
    await _notesRef().doc(noteId).update(data);
  }

  /// Toggles the pinned state.
  Future<void> togglePin(String noteId, bool pinned) async {
    await _notesRef().doc(noteId).update({
      'pinned': pinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a note.
  Future<void> deleteNote(String noteId) async {
    await _notesRef().doc(noteId).delete();
  }
}
