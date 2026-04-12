import 'package:cloud_firestore/cloud_firestore.dart';

import 'staff_permissions.dart';

/// A staff member linked to a doctor.
///
/// Stored at `doctors/{doctorUid}/staff/{staffUid}`.
class StaffMember {
  const StaffMember({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.status,
    required this.permissions,
    this.createdAt,
    this.staffRole,
    this.createdByDoctor,
  });

  final String uid;
  final String displayName;
  final String email;
  final StaffStatus status;
  final StaffPermissions permissions;
  final DateTime? createdAt;

  /// Job title / role label, e.g. MFA, ZFA, Krankenpfleger.
  final String? staffRole;

  /// UID of the doctor who created this staff member (set on org mirror docs).
  final String? createdByDoctor;

  bool get isActive => status == StaffStatus.active;

  factory StaffMember.fromJson(String id, Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    }

    return StaffMember(
      uid: id,
      displayName: (json['displayName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: StaffStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? '').toString(),
        orElse: () => StaffStatus.active,
      ),
      permissions: StaffPermissions.fromMap(
        json['permissions'] as Map<String, dynamic>?,
      ),
      createdAt: createdAt,
      staffRole: json['staffRole'] as String?,
      createdByDoctor: json['createdByDoctor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'email': email,
        'status': status.name,
        'permissions': permissions.toMap(),
        if (staffRole != null) 'staffRole': staffRole,
      };
}

enum StaffStatus { active, disabled, revoked }
