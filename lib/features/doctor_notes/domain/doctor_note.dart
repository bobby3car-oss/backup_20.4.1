import 'package:cloud_firestore/cloud_firestore.dart';

/// A private doctor note about a patient.
class DoctorNote {
  DoctorNote({
    required this.id,
    required this.patientId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.pinned = false,
  });

  final String id;
  final String patientId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool pinned;

  factory DoctorNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return DoctorNote(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] as List? ?? []),
      pinned: data['pinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'patientId': patientId,
        'title': title,
        'content': content,
        'tags': tags,
        'pinned': pinned,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  DoctorNote copyWith({
    String? title,
    String? content,
    List<String>? tags,
    bool? pinned,
  }) =>
      DoctorNote(
        id: id,
        patientId: patientId,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        tags: tags ?? this.tags,
        pinned: pinned ?? this.pinned,
      );
}
