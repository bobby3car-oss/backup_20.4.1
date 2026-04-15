import 'package:cloud_firestore/cloud_firestore.dart';

import 'aftercare_item_category.dart';

/// A single actionable item within an aftercare phase.
class AftercareItem {
  const AftercareItem({
    required this.id,
    required this.category,
    required this.title,
    this.description = '',
    this.startDayOffset,
    this.endDayOffset,
    this.exactDate,
    this.isTimeBound = false,
    this.showInTimeline = true,
    this.value = const <String, dynamic>{},
    this.notes = '',
    this.order = 0,
  });

  final String id;
  final AftercareItemCategory category;
  final String title;
  final String description;

  /// Day offset relative to surgery date when this item starts.
  final int? startDayOffset;

  /// Day offset relative to surgery date when this item ends.
  final int? endDayOffset;

  /// Optional exact date (overrides day-offset logic).
  final DateTime? exactDate;

  /// Whether this item is bound to a specific time window.
  final bool isTimeBound;

  /// Whether this item should appear in the patient timeline.
  final bool showInTimeline;

  /// Flexible key-value data (e.g. weight-bearing percentage, ROM degrees).
  final Map<String, dynamic> value;

  /// Free-text notes for additional context.
  final String notes;

  /// Display order within the phase.
  final int order;

  AftercareItem copyWith({
    String? id,
    AftercareItemCategory? category,
    String? title,
    String? description,
    int? startDayOffset,
    bool clearStartDayOffset = false,
    int? endDayOffset,
    bool clearEndDayOffset = false,
    DateTime? exactDate,
    bool clearExactDate = false,
    bool? isTimeBound,
    bool? showInTimeline,
    Map<String, dynamic>? value,
    String? notes,
    int? order,
  }) {
    return AftercareItem(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      startDayOffset:
          clearStartDayOffset ? null : (startDayOffset ?? this.startDayOffset),
      endDayOffset:
          clearEndDayOffset ? null : (endDayOffset ?? this.endDayOffset),
      exactDate: clearExactDate ? null : (exactDate ?? this.exactDate),
      isTimeBound: isTimeBound ?? this.isTimeBound,
      showInTimeline: showInTimeline ?? this.showInTimeline,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category': category.name,
      'title': title,
      'description': description,
      if (startDayOffset != null) 'startDayOffset': startDayOffset,
      if (endDayOffset != null) 'endDayOffset': endDayOffset,
      if (exactDate != null) 'exactDate': exactDate!.toIso8601String(),
      'isTimeBound': isTimeBound,
      'showInTimeline': showInTimeline,
      'value': value,
      'notes': notes,
      'order': order,
    };
  }

  factory AftercareItem.fromJson(Map<String, dynamic> json) {
    return AftercareItem(
      id: (json['id'] ?? '').toString(),
      category: AftercareItemCategory.fromString(json['category']?.toString()),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      startDayOffset: _parseInt(json['startDayOffset']),
      endDayOffset: _parseInt(json['endDayOffset']),
      exactDate: _parseDateTime(json['exactDate']),
      isTimeBound: json['isTimeBound'] == true,
      showInTimeline: json['showInTimeline'] != false,
      value: _parseMap(json['value']),
      notes: (json['notes'] ?? '').toString(),
      order: _parseInt(json['order']) ?? 0,
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

  static Map<String, dynamic> _parseMap(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return const <String, dynamic>{};
  }
}
