import 'package:cloud_firestore/cloud_firestore.dart';

class OrgDoctor {
  const OrgDoctor({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialty,
    required this.status,
    this.addedAt,
  });

  factory OrgDoctor.fromJson(String id, Map<String, dynamic> json) {
    return OrgDoctor(
      uid: id,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      addedAt: (json['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  final String uid;
  final String name;
  final String email;
  final String specialty;
  final String status;
  final DateTime? addedAt;

  bool get isActive => status == 'active';
}
