import 'packing_item.dart';

/// The type of packing list – determines which seed template is used.
enum PackingListType {
  standard,
  ambulant,
  stationary,
  child,
  rehab,
  custom;

  String get label => switch (this) {
        PackingListType.standard => 'Standard',
        PackingListType.ambulant => 'Ambulant',
        PackingListType.stationary => 'Stationär',
        PackingListType.child => 'Kind',
        PackingListType.rehab => 'Reha',
        PackingListType.custom => 'Eigene Liste',
      };

  String get emoji => switch (this) {
        PackingListType.standard => '🧳',
        PackingListType.ambulant => '🚗',
        PackingListType.stationary => '🏥',
        PackingListType.child => '🧒',
        PackingListType.rehab => '🏋️',
        PackingListType.custom => '📋',
      };

  String get description => switch (this) {
        PackingListType.standard => 'Automatisch angepasst an deinen Aufenthalt',
        PackingListType.ambulant => 'Kein Übernachten – nur das Nötigste',
        PackingListType.stationary => 'Mit Übernachtung – vollständige Liste',
        PackingListType.child => 'Speziell für Kinder-OPs zusammengestellt',
        PackingListType.rehab => 'Alles für den Reha-Aufenthalt',
        PackingListType.custom => 'Deine eigene individuelle Packliste',
      };

  static PackingListType? tryParse(String? name) {
    if (name == null) return null;
    for (final t in PackingListType.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}

/// Collaboration role for a list member.
enum PackingListRole {
  owner,
  editor,
  viewer;

  String get label => switch (this) {
        PackingListRole.owner => 'Besitzer',
        PackingListRole.editor => 'Bearbeiter',
        PackingListRole.viewer => 'Betrachter',
      };
}

/// A member who has access to a shared packing list.
class PackingListMember {
  const PackingListMember({
    required this.uid,
    required this.role,
    this.displayName,
    this.addedAt,
  });

  final String uid;
  final PackingListRole role;
  final String? displayName;
  final DateTime? addedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uid': uid,
        'role': role.name,
        if (displayName != null) 'displayName': displayName,
        if (addedAt != null) 'addedAt': addedAt!.toIso8601String(),
      };

  factory PackingListMember.fromJson(Map<String, dynamic> json) {
    return PackingListMember(
      uid: (json['uid'] ?? '').toString(),
      role: PackingListRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => PackingListRole.viewer,
      ),
      displayName: json['displayName']?.toString(),
      addedAt: _parseDateTime(json['addedAt']),
    );
  }
}

/// A packing list that groups [PackingItem]s.
class PackingList {
  const PackingList({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.mode,
    this.operationId,
    this.icon,
    this.accentColorValue,
    this.archivedAt,
    this.sortOrder = 0,
    this.isDefault = false,
    this.members = const <PackingListMember>[],
    this.itemCount = 0,
    this.checkedCount = 0,
  });

  final String id;
  final String ownerId;
  final String title;
  final PackingListType type;
  final HospitalMode? mode;
  final String? operationId;
  final String? icon;
  final int? accentColorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final int sortOrder;
  final bool isDefault;
  final List<PackingListMember> members;

  /// Denormalized counters updated on item changes.
  final int itemCount;
  final int checkedCount;

  bool get isArchived => archivedAt != null;
  bool get isShared => members.length > 1;
  double get progress => itemCount == 0 ? 0.0 : checkedCount / itemCount;
  String get emoji => icon ?? type.emoji;

  PackingList copyWith({
    String? id,
    String? ownerId,
    String? title,
    PackingListType? type,
    HospitalMode? mode,
    String? operationId,
    String? icon,
    int? accentColorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    int? sortOrder,
    bool? isDefault,
    List<PackingListMember>? members,
    int? itemCount,
    int? checkedCount,
    bool clearArchivedAt = false,
  }) {
    return PackingList(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      operationId: operationId ?? this.operationId,
      icon: icon ?? this.icon,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      members: members ?? this.members,
      itemCount: itemCount ?? this.itemCount,
      checkedCount: checkedCount ?? this.checkedCount,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'type': type.name,
        'mode': mode?.name,
        'operationId': operationId,
        'icon': icon,
        'accentColorValue': accentColorValue,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'archivedAt': archivedAt?.toIso8601String(),
        'sortOrder': sortOrder,
        'isDefault': isDefault,
        'members': members.map((m) => m.toJson()).toList(growable: false),
        'itemCount': itemCount,
        'checkedCount': checkedCount,
      };

  factory PackingList.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDateTime(json['createdAt']) ?? DateTime.now();
    return PackingList(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      type: PackingListType.tryParse(json['type']?.toString()) ??
          PackingListType.standard,
      mode: HospitalMode.tryParse(json['mode']?.toString()),
      operationId: json['operationId']?.toString(),
      icon: json['icon']?.toString(),
      accentColorValue: json['accentColorValue'] is int
          ? json['accentColorValue'] as int
          : null,
      createdAt: createdAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? createdAt,
      archivedAt: _parseDateTime(json['archivedAt']),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] == true,
      members: _parseMembers(json['members']),
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      checkedCount: (json['checkedCount'] as num?)?.toInt() ?? 0,
    );
  }

  static List<PackingListMember> _parseMembers(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(PackingListMember.fromJson)
          .toList(growable: false);
    }
    return const <PackingListMember>[];
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
