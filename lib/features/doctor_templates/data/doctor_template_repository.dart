import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/care_plan_template.dart';

/// Firestore-backed CRUD for doctor care plan templates.
///
/// Path: `doctors/{doctorUid}/templates/{templateId}`
class DoctorTemplateRepository {
  DoctorTemplateRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? _basePath() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return 'doctors/$uid/templates';
  }

  /// Real-time stream of all templates for the current doctor.
  Stream<List<CarePlanTemplate>> watchAll() {
    final path = _basePath();
    if (path == null) return const Stream.empty();

    return _firestore
        .collection(path)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                CarePlanTemplate.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Creates or updates a template.
  Future<void> upsert(CarePlanTemplate template) async {
    final path = _basePath();
    if (path == null) return;
    await _firestore
        .collection(path)
        .doc(template.id)
        .set(template.toJson());
  }

  /// Deletes a template by ID.
  Future<void> delete(String templateId) async {
    final path = _basePath();
    if (path == null) return;
    await _firestore.collection(path).doc(templateId).delete();
  }
}
