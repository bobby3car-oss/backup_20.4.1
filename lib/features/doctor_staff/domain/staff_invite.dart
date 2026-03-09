import 'package:cloud_firestore/cloud_firestore.dart';

/// An invite for a staff member, created by a doctor.
///
/// Stored at `staff_invites/{code}`.
class StaffInvite {
  const StaffInvite({
    required this.code,
    required this.doctorUid,
    required this.doctorName,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedByUid,
  });

  final String code;
  final String doctorUid;
  final String doctorName;
  final StaffInviteStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? acceptedByUid;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == StaffInviteStatus.pending && !isExpired;

  factory StaffInvite.fromJson(String code, Map<String, dynamic> json) {
    DateTime parseTime(Object? raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return StaffInvite(
      code: code,
      doctorUid: (json['doctorUid'] ?? '').toString(),
      doctorName: (json['doctorName'] ?? '').toString(),
      status: StaffInviteStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? '').toString(),
        orElse: () => StaffInviteStatus.pending,
      ),
      createdAt: parseTime(json['createdAt']),
      expiresAt: parseTime(json['expiresAt']),
      acceptedByUid: json['acceptedByUid']?.toString(),
    );
  }
}

enum StaffInviteStatus { pending, accepted, revoked }
