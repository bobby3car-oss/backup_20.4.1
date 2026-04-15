import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks which aftercare items a patient has completed.
///
/// Stored as a single document per plan at:
/// `patient_aftercare_plans/{planId}/progress/items`
///
/// The [items] map stores per-item completion state keyed by item ID.
class AftercareItemProgress {
  const AftercareItemProgress({
    required this.patientId,
    required this.planId,
    this.items = const {},
    this.pendingItemIds = const <String>{},
    this.lastSyncedAt,
    this.updatedAt,
  });

  final String patientId;
  final String planId;

  /// Map of itemId → completion state.
  final Map<String, ItemCompletionState> items;

  /// Item IDs currently pending local sync.
  final Set<String> pendingItemIds;

  /// Last time local queue sync completed successfully.
  final DateTime? lastSyncedAt;

  final DateTime? updatedAt;

  /// Whether a specific item is marked as completed.
  bool isCompleted(String itemId) => items[itemId]?.completed ?? false;

  /// Count of completed items.
  int get completedCount =>
      items.values.where((s) => s.completed).length;

  AftercareItemProgress copyWith({
    String? patientId,
    String? planId,
    Map<String, ItemCompletionState>? items,
    Set<String>? pendingItemIds,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  }) {
    return AftercareItemProgress(
      patientId: patientId ?? this.patientId,
      planId: planId ?? this.planId,
      items: items ?? this.items,
      pendingItemIds: pendingItemIds ?? this.pendingItemIds,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Applies local pending completion overrides without mutating server state.
  AftercareItemProgress withPendingOverrides(Map<String, bool> overrides) {
    if (overrides.isEmpty) return this;

    final mergedItems = Map<String, ItemCompletionState>.from(items);
    final mergedPending = Set<String>.from(pendingItemIds);

    for (final entry in overrides.entries) {
      final existing = mergedItems[entry.key];
      mergedItems[entry.key] = ItemCompletionState(
        completed: entry.value,
        completedAt: entry.value ? (existing?.completedAt ?? DateTime.now()) : null,
      );
      mergedPending.add(entry.key);
    }

    return copyWith(
      items: mergedItems,
      pendingItemIds: mergedPending,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'patientId': patientId,
      'planId': planId,
      'items': items.map((k, v) => MapEntry(k, v.toJson())),
      if (pendingItemIds.isNotEmpty) 'pendingItemIds': pendingItemIds.toList(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt!.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AftercareItemProgress.fromJson(
    Map<String, dynamic> json, {
    required String planId,
  }) {
    final rawItems = json['items'];
    final items = <String, ItemCompletionState>{};
    if (rawItems is Map) {
      for (final entry in rawItems.entries) {
        final key = entry.key.toString();
        if (entry.value is Map) {
          items[key] = ItemCompletionState.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }
    return AftercareItemProgress(
      patientId: (json['patientId'] ?? '').toString(),
      planId: planId,
      items: items,
      pendingItemIds: _parseStringSet(json['pendingItemIds']),
      lastSyncedAt: _parseDateTime(json['lastSyncedAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Empty progress for a plan (no items completed yet).
  factory AftercareItemProgress.empty({
    required String patientId,
    required String planId,
  }) {
    return AftercareItemProgress(
      patientId: patientId,
      planId: planId,
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static Set<String> _parseStringSet(Object? raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return const <String>{};
  }
}

/// Completion state for a single aftercare item.
class ItemCompletionState {
  const ItemCompletionState({
    required this.completed,
    this.completedAt,
  });

  final bool completed;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }

  factory ItemCompletionState.fromJson(Map<String, dynamic> json) {
    return ItemCompletionState(
      completed: json['completed'] == true,
      completedAt: _parseDateTime(json['completedAt']),
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
