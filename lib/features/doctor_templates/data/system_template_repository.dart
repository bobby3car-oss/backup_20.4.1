import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/care_plan_template.dart';

/// Firestore-backed read-only access to admin-created system templates.
///
/// Path: `system_templates/{templateId}`
///
/// Doctors can read these but not modify them. Admin manages via dashboard.
class SystemTemplateRepository {
  SystemTemplateRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'system_templates';

  /// Real-time stream of all system templates.
  Stream<List<CarePlanTemplate>> watchAll() {
    return _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                CarePlanTemplate.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }
}

/// Admin-only write operations for system templates.
///
/// Separated from [SystemTemplateRepository] for clarity – only used
/// in the admin dashboard.
class AdminSystemTemplateRepository {
  AdminSystemTemplateRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'system_templates';

  /// Real-time stream of all system templates.
  Stream<List<CarePlanTemplate>> watchAll() {
    return _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                CarePlanTemplate.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Creates or updates a system template.
  Future<void> upsert(CarePlanTemplate template) async {
    await _firestore
        .collection(_collection)
        .doc(template.id)
        .set(template.toJson());
  }

  /// Deletes a system template by ID.
  Future<void> delete(String templateId) async {
    await _firestore.collection(_collection).doc(templateId).delete();
  }
}
