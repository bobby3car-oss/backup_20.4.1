import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../security/field_encryption_service.dart';

class Organisation {
  const Organisation({
    required this.uid,
    required this.name,
    required this.email,
    required this.orgType,
    required this.address,
    required this.contactPerson,
    this.phone,
    this.website,
    this.openingHours,
    this.createdAt,
    this.updatedAt,
  });

  factory Organisation.fromJson(String id, Map<String, dynamic> json) {
    Map<String, OrgOpeningHours>? oh;
    if (json['openingHours'] is Map) {
      final raw = Map<String, dynamic>.from(json['openingHours'] as Map);
      oh = raw.map((k, v) {
        final m = Map<String, dynamic>.from(v as Map);
        return MapEntry(
          k,
          OrgOpeningHours(
            from: TimeOfDay(
              hour: (m['fromHour'] as int?) ?? 8,
              minute: (m['fromMinute'] as int?) ?? 0,
            ),
            to: TimeOfDay(
              hour: (m['toHour'] as int?) ?? 17,
              minute: (m['toMinute'] as int?) ?? 0,
            ),
          ),
        );
      });
    }

    final enc = FieldEncryptionService.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Organisation(
      uid: id,
      name: enc.decryptField(uid, json['name'] as String?) ?? '',
      email: enc.decryptField(uid, json['email'] as String?) ?? '',
      orgType: json['orgType'] as String? ?? '',
      address: enc.decryptField(uid, json['address'] as String?) ?? '',
      contactPerson: enc.decryptField(uid, json['contactPerson'] as String?) ?? '',
      phone: enc.decryptField(uid, json['phone'] as String?),
      website: json['website'] as String?,
      openingHours: oh,
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
  final String? website;
  final Map<String, OrgOpeningHours>? openingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class OrgOpeningHours {
  const OrgOpeningHours({required this.from, required this.to});

  final TimeOfDay from;
  final TimeOfDay to;

  String format() {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(from.hour)}:${pad(from.minute)} – ${pad(to.hour)}:${pad(to.minute)}';
  }
}
