import 'aftercare_item.dart';

/// A named phase within an aftercare plan (e.g. "Woche 1–2", "Ab Woche 6").
class AftercarePhase {
  const AftercarePhase({
    required this.id,
    required this.title,
    required this.startDayOffset,
    this.endDayOffset,
    this.order = 0,
    this.items = const [],
  });

  final String id;

  /// Free-form phase title (e.g. "Frühphase", "Belastungsaufbau").
  final String title;

  /// Day offset from surgery date when this phase begins.
  final int startDayOffset;

  /// Optional day offset when this phase ends.
  final int? endDayOffset;

  /// Display order among sibling phases.
  final int order;

  /// Items belonging to this phase.
  final List<AftercareItem> items;

  AftercarePhase copyWith({
    String? id,
    String? title,
    int? startDayOffset,
    int? endDayOffset,
    bool clearEndDayOffset = false,
    int? order,
    List<AftercareItem>? items,
  }) {
    return AftercarePhase(
      id: id ?? this.id,
      title: title ?? this.title,
      startDayOffset: startDayOffset ?? this.startDayOffset,
      endDayOffset:
          clearEndDayOffset ? null : (endDayOffset ?? this.endDayOffset),
      order: order ?? this.order,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'startDayOffset': startDayOffset,
      if (endDayOffset != null) 'endDayOffset': endDayOffset,
      'order': order,
      'items': items.map((i) => i.toJson()).toList(growable: false),
    };
  }

  factory AftercarePhase.fromJson(Map<String, dynamic> json) {
    return AftercarePhase(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      startDayOffset: _parseInt(json['startDayOffset']) ?? 0,
      endDayOffset: _parseInt(json['endDayOffset']),
      order: _parseInt(json['order']) ?? 0,
      items: _parseItems(json['items']),
    );
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static List<AftercareItem> _parseItems(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AftercareItem.fromJson)
          .toList(growable: false);
    }
    return const [];
  }
}
