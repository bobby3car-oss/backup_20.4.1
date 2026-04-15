import 'package:cloud_firestore/cloud_firestore.dart';

import 'aftercare_item_category.dart';
import 'aftercare_phase.dart';

/// A reusable aftercare template.
///
/// Templates exist at three levels:
/// - **system** — global, admin-managed (`system_aftercare_templates`)
/// - **organization** — per organisation (`organization_aftercare_templates`)
/// - **doctor** — individual doctor templates (`doctor_aftercare_templates`)
class AftercareTemplate {
  const AftercareTemplate({
    required this.id,
    required this.title,
    this.description = '',
    this.surgeryType = '',
    this.bodyRegion = '',
    required this.createdBy,
    this.organizationId,
    required this.templateType,
    this.version = 1,
    this.changeDescription,
    required this.createdAt,
    required this.updatedAt,
    this.phases = const [],
  });

  final String id;
  final String title;
  final String description;

  /// Surgery type this template is designed for (e.g. "Knie-TEP").
  final String surgeryType;

  /// Body region (e.g. "Knie", "Hüfte", "Schulter").
  final String bodyRegion;

  /// UID of the user who created this template.
  final String createdBy;

  /// Organisation this template belongs to (only for [AftercareTemplateType.organization]).
  final String? organizationId;

  /// Scope of this template.
  final AftercareTemplateType templateType;

  /// Version number for tracking template revisions.
  final int version;

  /// Description of the most recent change (e.g. "Belastungsaufbau angepasst").
  final String? changeDescription;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Ordered list of treatment phases.
  final List<AftercarePhase> phases;

  AftercareTemplate copyWith({
    String? id,
    String? title,
    String? description,
    String? surgeryType,
    String? bodyRegion,
    String? createdBy,
    String? organizationId,
    bool clearOrganizationId = false,
    AftercareTemplateType? templateType,
    int? version,
    String? changeDescription,
    bool clearChangeDescription = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AftercarePhase>? phases,
  }) {
    return AftercareTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      surgeryType: surgeryType ?? this.surgeryType,
      bodyRegion: bodyRegion ?? this.bodyRegion,
      createdBy: createdBy ?? this.createdBy,
      organizationId: clearOrganizationId
          ? null
          : (organizationId ?? this.organizationId),
      templateType: templateType ?? this.templateType,
      version: version ?? this.version,
      changeDescription: clearChangeDescription
          ? null
          : (changeDescription ?? this.changeDescription),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phases: phases ?? this.phases,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'surgeryType': surgeryType,
      'bodyRegion': bodyRegion,
      'createdBy': createdBy,
      if (organizationId != null) 'organizationId': organizationId,
      'templateType': templateType.name,
      'version': version,
      if (changeDescription != null) 'changeDescription': changeDescription,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'phases': phases.map((p) => p.toJson()).toList(growable: false),
    };
  }

  factory AftercareTemplate.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return AftercareTemplate(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      surgeryType: (json['surgeryType'] ?? '').toString(),
      bodyRegion: (json['bodyRegion'] ?? '').toString(),
      createdBy: (json['createdBy'] ?? '').toString(),
      organizationId: json['organizationId'] as String?,
      templateType:
          AftercareTemplateType.fromString(json['templateType']?.toString()),
      version: _parseInt(json['version']) ?? 1,
      changeDescription: json['changeDescription'] as String?,
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
      phases: _parsePhases(json['phases']),
    );
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static List<AftercarePhase> _parsePhases(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AftercarePhase.fromJson)
          .toList(growable: false);
    }
    return const [];
  }
}
