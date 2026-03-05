/// The hospital stay mode – determines which seed items are shown.
enum HospitalMode {
  ambulant,
  stationary;

  String get label {
    return switch (this) {
      HospitalMode.ambulant => 'Ambulant',
      HospitalMode.stationary => 'Stationär',
    };
  }

  String get emoji {
    return switch (this) {
      HospitalMode.ambulant => '🚗',
      HospitalMode.stationary => '🏥',
    };
  }

  static HospitalMode? tryParse(String? name) {
    if (name == null) return null;
    for (final mode in HospitalMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}

enum PackingCategory {
  documents,
  clothing,
  hygiene,
  technology,
  entertainment,
  medication,
  other,
}

extension PackingCategoryLabel on PackingCategory {
  String get label {
    return switch (this) {
      PackingCategory.documents => 'Dokumente',
      PackingCategory.clothing => 'Kleidung',
      PackingCategory.hygiene => 'Hygiene',
      PackingCategory.technology => 'Technik',
      PackingCategory.entertainment => 'Unterhaltung',
      PackingCategory.medication => 'Medikamente',
      PackingCategory.other => 'Sonstiges',
    };
  }

  String get emoji {
    return switch (this) {
      PackingCategory.documents => '📄',
      PackingCategory.clothing => '👕',
      PackingCategory.hygiene => '🧴',
      PackingCategory.technology => '🔌',
      PackingCategory.entertainment => '📖',
      PackingCategory.medication => '💊',
      PackingCategory.other => '📦',
    };
  }
}

class PackingItem {
  const PackingItem({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.category,
    required this.checked,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
    this.isRequired = false,
    this.modes = const <HospitalMode>[
      HospitalMode.ambulant,
      HospitalMode.stationary,
    ],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final String title;
  final PackingCategory category;
  final bool checked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final bool isRequired;

  /// Which hospital modes this item applies to.
  /// Defaults to both (ambulant + stationary).
  final List<HospitalMode> modes;
  final Map<String, dynamic> metadata;

  PackingItem copyWith({
    String? id,
    String? ownerId,
    String? title,
    PackingCategory? category,
    bool? checked,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    bool? isRequired,
    List<HospitalMode>? modes,
    Map<String, dynamic>? metadata,
  }) {
    return PackingItem(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      category: category ?? this.category,
      checked: checked ?? this.checked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      isRequired: isRequired ?? this.isRequired,
      modes: modes ?? this.modes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'category': category.name,
      'checked': checked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
      'isRequired': isRequired,
      'modes': modes.map((m) => m.name).toList(growable: false),
      'metadata': metadata,
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDateTime(json['createdAt']) ?? DateTime.now();
    return PackingItem(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: _parseCategory(json['category']),
      checked: _asBool(json['checked']),
      createdAt: createdAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? createdAt,
      isDefault: _asBool(json['isDefault']),
      isRequired: _asBool(json['isRequired']),
      modes: _parseModes(json['modes']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static PackingCategory _parseCategory(Object? raw) {
    final name = raw?.toString() ?? '';
    for (final category in PackingCategory.values) {
      if (category.name == name) return category;
    }
    return PackingCategory.other;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static List<HospitalMode> _parseModes(Object? raw) {
    if (raw is List) {
      final result = <HospitalMode>[];
      for (final entry in raw) {
        final mode = HospitalMode.tryParse(entry?.toString());
        if (mode != null) result.add(mode);
      }
      if (result.isNotEmpty) return result;
    }
    // Default: both modes
    return <HospitalMode>[HospitalMode.ambulant, HospitalMode.stationary];
  }

  static Map<String, dynamic> _parseMetadata(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return const <String, dynamic>{};
  }
}
