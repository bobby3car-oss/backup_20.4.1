import 'package:cloud_firestore/cloud_firestore.dart';

class OrgJoinRequest {
  const OrgJoinRequest({
    required this.id,
    required this.orgUid,
    required this.orgName,
    required this.doctorUid,
    required this.doctorName,
    required this.doctorEmail,
    required this.doctorSpecialty,
    required this.inviteCode,
    required this.status,
    required this.requestedAt,
    this.resolvedAt,
    this.rejectionReason,
  });

  factory OrgJoinRequest.fromJson(String id, Map<String, dynamic> json) {
    return OrgJoinRequest(
      id: id,
      orgUid: (json['orgUid'] ?? '').toString(),
      orgName: (json['orgName'] ?? '').toString(),
      doctorUid: (json['doctorUid'] ?? '').toString(),
      doctorName: (json['doctorName'] ?? '').toString(),
      doctorEmail: (json['doctorEmail'] ?? '').toString(),
      doctorSpecialty: (json['doctorSpecialty'] ?? '').toString(),
      inviteCode: (json['inviteCode'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      requestedAt: (json['requestedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      resolvedAt: (json['resolvedAt'] as Timestamp?)?.toDate(),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  final String id;
  final String orgUid;
  final String orgName;
  final String doctorUid;
  final String doctorName;
  final String doctorEmail;
  final String doctorSpecialty;
  final String inviteCode;
  final String status; // pending | approved | rejected
  final DateTime requestedAt;
  final DateTime? resolvedAt;
  final String? rejectionReason;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
