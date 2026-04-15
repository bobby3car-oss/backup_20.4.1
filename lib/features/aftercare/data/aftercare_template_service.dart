import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_template.dart';

/// Firestore-backed CRUD for aftercare templates across all three scopes.
///
/// Collections:
/// - `system_aftercare_templates`       — admin-managed global templates
/// - `organization_aftercare_templates` — per-organisation templates
/// - `doctor_aftercare_templates`       — individual doctor templates
class AftercareTemplateService {
  AftercareTemplateService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.overrideDoctorUid,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// When set (staff mode), use this UID instead of the current user's UID.
  final String? overrideDoctorUid;

  static const _systemCollection = FirestorePaths.systemAftercareTemplates;
  static const _organizationCollection = FirestorePaths.organizationAftercareTemplates;
  static const _doctorCollection = FirestorePaths.doctorAftercareTemplates;

  String? get _effectiveUid => overrideDoctorUid ?? _auth.currentUser?.uid;

  // ── System Templates (read-only for non-admins) ────────────────────────

  /// Streams all system-level aftercare templates.
  Stream<List<AftercareTemplate>> getSystemTemplates() {
    return _firestore
        .collection(_systemCollection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AftercareTemplate.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  // ── CRUD (works for all scopes) ────────────────────────────────────────

  /// Creates a new template in the appropriate Firestore collection.
  Future<String> createTemplate(AftercareTemplate template) async {
    final collection = _collectionForType(template.templateType);
    final docRef = _firestore.collection(collection).doc();
    final now = DateTime.now();
    final data = template
        .copyWith(
          id: docRef.id,
          createdBy: _effectiveUid ?? template.createdBy,
          createdAt: now,
          updatedAt: now,
        )
        .toJson();

    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
    return docRef.id;
  }

  /// Updates an existing template. Increments [version] automatically.
  Future<void> updateTemplate(AftercareTemplate template) async {
    final collection = _collectionForType(template.templateType);
    if (template.id.isEmpty) return;

    final data = template
        .copyWith(
          version: template.version + 1,
          updatedAt: DateTime.now(),
        )
        .toJson();

    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(collection).doc(template.id).update(data);
  }

  /// Deletes a template by ID and type.
  Future<void> deleteTemplate({
    required String templateId,
    required AftercareTemplateType templateType,
  }) async {
    final collection = _collectionForType(templateType);
    await _firestore.collection(collection).doc(templateId).delete();
  }

  /// Creates a deep copy of a template with a new ID.
  Future<String> duplicateTemplate(AftercareTemplate source) async {
    final now = DateTime.now();
    final duplicate = source.copyWith(
      id: '', // will be replaced on create
      title: '${source.title} (Kopie)',
      createdBy: _effectiveUid ?? source.createdBy,
      version: 1,
      createdAt: now,
      updatedAt: now,
    );
    return createTemplate(duplicate);
  }

  /// Adopts (clones) a system template into a different scope.
  ///
  /// Creates a copy of [source] with the given [targetType] and optional
  /// [organizationId]. Used by doctors/orgs to adopt system templates.
  Future<String> adoptTemplate(
    AftercareTemplate source, {
    required AftercareTemplateType targetType,
    String? organizationId,
  }) async {
    final now = DateTime.now();
    final adopted = source.copyWith(
      id: '',
      title: source.title,
      templateType: targetType,
      organizationId: organizationId,
      createdBy: _effectiveUid ?? source.createdBy,
      version: 1,
      createdAt: now,
      updatedAt: now,
    );
    return createTemplate(adopted);
  }

  /// Streams templates visible to the current user (doctor + org + system).
  Stream<List<AftercareTemplate>> getTemplatesForUser({
    String? organizationId,
  }) {
    final uid = _effectiveUid;
    if (uid == null || uid.isEmpty) return const Stream.empty();

    final streams = <Stream<List<AftercareTemplate>>>[
      getSystemTemplates(),
      _watchDoctorTemplates(uid),
    ];

    if (organizationId != null && organizationId.isNotEmpty) {
      streams.add(_watchOrganizationTemplates(organizationId));
    }

    return _combineStreams(streams);
  }

  /// Streams org + system templates (for organisation dashboard).
  Stream<List<AftercareTemplate>> getTemplatesForOrganization({
    required String organizationId,
  }) {
    return _combineStreams([
      _watchOrganizationTemplates(organizationId),
      getSystemTemplates(),
    ]);
  }

  // ── Private helpers ────────────────────────────────────────────────────

  Stream<List<AftercareTemplate>> _watchDoctorTemplates(String doctorUid) {
    return _firestore
        .collection(_doctorCollection)
        .where('createdBy', isEqualTo: doctorUid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AftercareTemplate.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  Stream<List<AftercareTemplate>> _watchOrganizationTemplates(String orgId) {
    return _firestore
        .collection(_organizationCollection)
        .where('organizationId', isEqualTo: orgId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AftercareTemplate.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  String _collectionForType(AftercareTemplateType type) {
    return switch (type) {
      AftercareTemplateType.system => _systemCollection,
      AftercareTemplateType.organization => _organizationCollection,
      AftercareTemplateType.doctor => _doctorCollection,
    };
  }

  /// Combines multiple template streams into one sorted list.
  Stream<List<AftercareTemplate>> _combineStreams(
    List<Stream<List<AftercareTemplate>>> streams,
  ) {
    final controller = StreamController<List<AftercareTemplate>>();
    final latest = List<List<AftercareTemplate>>.filled(streams.length, []);
    final subs = <StreamSubscription<List<AftercareTemplate>>>[];

    for (var i = 0; i < streams.length; i++) {
      final index = i;
      subs.add(streams[index].listen(
        (data) {
          latest[index] = data;
          final merged = <AftercareTemplate>[
            for (final list in latest) ...list,
          ];
          merged.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          if (!controller.isClosed) controller.add(merged);
        },
        onError: (Object e, StackTrace s) {
          if (!controller.isClosed) controller.addError(e, s);
        },
      ));
    }

    controller.onCancel = () async {
      for (final sub in subs) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }
}
