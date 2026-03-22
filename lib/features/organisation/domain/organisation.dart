import 'package:cloud_firestore/cloud_firestore.dart';

class Organisation {
  const Organisation({
    required this.uid,
    required this.name,
    required this.email,
    required this.orgType,
    required this.address,
    required this.contactPerson,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory Organisation.fromJson(String id, Map<String, dynamic> json) {
    return Organisation(
      uid: id,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      orgType: json['orgType'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contactPerson: json['contactPerson'] as String? ?? '',
      phone: json['phone'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  final String uid;
  final String name;
  final String email;
  final String orgType;
  final String address;
  final String contactPerson;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
