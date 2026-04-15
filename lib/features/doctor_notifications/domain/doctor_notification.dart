import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../security/field_encryption_service.dart';

/// Type of doctor notification.
enum DoctorNotificationType {
  redFlag,
  patientQuestion,
  appointmentChange,
  newPatient;

  String get label => switch (this) {
        redFlag => 'Red Flag',
        patientQuestion => 'Patientenfrage',
        appointmentChange => 'Terminänderung',
        newPatient => 'Neuer Patient',
      };

  IconData get icon => switch (this) {
        redFlag => Icons.flag_rounded,
        patientQuestion => Icons.help_outline_rounded,
        appointmentChange => Icons.calendar_month_rounded,
        newPatient => Icons.person_add_rounded,
      };

  Color get color => switch (this) {
        redFlag => const Color(0xFFFF3B30),
        patientQuestion => const Color(0xFF007AFF),
        appointmentChange => const Color(0xFFFF9500),
        newPatient => const Color(0xFF34C759),
      };
}

class DoctorNotification {
  const DoctorNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.patientId,
    this.patientName,
    this.isRead = false,
  });

  final String id;
  final DoctorNotificationType type;
  final String title;
  final String body;
  final String? patientId;
  final String? patientName;
  final bool isRead;
  final DateTime createdAt;

  factory DoctorNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final enc = FieldEncryptionService.instance;
    return DoctorNotification(
      id: doc.id,
      type: _parseType(d['type'] as String?),
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      patientId: d['patientId'] as String?,
      patientName: enc.decryptField(uid, d['patientName'] as String?),
      isRead: d['isRead'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static DoctorNotificationType _parseType(String? value) {
    if (value == null) return DoctorNotificationType.patientQuestion;
    return DoctorNotificationType.values.asNameMap()[value] ??
        DoctorNotificationType.patientQuestion;
  }

  DoctorNotification copyWith({bool? isRead}) {
    return DoctorNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      patientId: patientId,
      patientName: patientName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
