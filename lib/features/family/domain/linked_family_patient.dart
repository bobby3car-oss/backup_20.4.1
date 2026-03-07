import 'package:cloud_firestore/cloud_firestore.dart';

import 'family_visibility.dart';

/// Represents one patient that a family member is linked to.
class LinkedFamilyPatient {
  const LinkedFamilyPatient({
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.linkId,
    required this.connectedSince,
    required this.visibility,
    this.opType,
    this.opDate,
    this.avatarInitials = '?',
  });

  final String patientId;
  final String patientName;
  final String patientEmail;
  final String linkId;
  final DateTime connectedSince;
  final FamilyVisibility visibility;
  final String? opType;
  final DateTime? opDate;
  final String avatarInitials;

  factory LinkedFamilyPatient.fromLinkDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    Map<String, dynamic>? patientData,
  }) {
    final d = doc.data() ?? {};
    final patientId = doc.reference.parent.parent?.id ?? '';
    final name = patientData?['displayName'] as String? ??
        d['patientName'] as String? ??
        'Patient';
    final email =
        patientData?['email'] as String? ?? d['patientEmail'] as String? ?? '';
    final created = d['createdAt'];
    DateTime connectedSince = DateTime.now();
    if (created is Timestamp) {
      connectedSince = created.toDate();
    }

    final visMap = d['visibility'] as Map<String, dynamic>?;
    final visibility = FamilyVisibility.fromMap(visMap);

    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return LinkedFamilyPatient(
      patientId: patientId,
      patientName: name,
      patientEmail: email,
      linkId: doc.id,
      connectedSince: connectedSince,
      visibility: visibility,
      opType: patientData?['opType'] as String?,
      opDate: patientData?['opDate'] is Timestamp
          ? (patientData!['opDate'] as Timestamp).toDate()
          : null,
      avatarInitials: initials.isEmpty ? '?' : initials,
    );
  }
}

/// Relationship role of the family member (kept from old CaregiverRole).
enum FamilyRelation { partner, parent, child, friend, other }

extension FamilyRelationMeta on FamilyRelation {
  String get label => switch (this) {
        FamilyRelation.partner => 'Partner/in',
        FamilyRelation.parent => 'Elternteil',
        FamilyRelation.child => 'Kind',
        FamilyRelation.friend => 'Freund/in',
        FamilyRelation.other => 'Sonstige',
      };
}
