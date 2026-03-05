enum InviteStatus { pending, accepted, revoked, expired }

class DoctorInvite {
  const DoctorInvite({
    required this.code,
    required this.doctorUid,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  final String code;
  final String doctorUid;
  final DateTime createdAt;
  final DateTime expiresAt;
  final InviteStatus status;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == InviteStatus.pending && !isExpired;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'doctorUid': doctorUid,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory DoctorInvite.fromJson(String code, Map<String, dynamic> json) {
    return DoctorInvite(
      code: code,
      doctorUid: (json['doctorUid'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
      status: InviteStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? '').toString(),
        orElse: () => InviteStatus.pending,
      ),
    );
  }
}
