import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/packing_item.dart';

/// Key for persisting the selected hospital mode.
const String _kHospitalModeKey = 'packing_hospital_mode';

class PackingRepositoryLocal {
  static final PackingRepositoryLocal instance =
      PackingRepositoryLocal._internal();

  factory PackingRepositoryLocal() => instance;

  PackingRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _items.clear();
    _emit();
    unawaited(loadFromDisk());
  }

  final List<PackingItem> _items = <PackingItem>[];
  final StreamController<List<PackingItem>> _controller =
      StreamController<List<PackingItem>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _loadedOnce = false;

  // ── Hospital mode ────────────────────────────────────────────

  /// Returns the persisted hospital mode, or `null` if not yet chosen.
  Future<HospitalMode?> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHospitalModeKey);
    return HospitalMode.tryParse(raw);
  }

  /// Persists the selected hospital mode.
  Future<void> setMode(HospitalMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHospitalModeKey, mode.name);
  }

  /// Clears the persisted mode (used during reset).
  Future<void> clearMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHospitalModeKey);
  }

  // ── CRUD ─────────────────────────────────────────────────────

  Stream<List<PackingItem>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  Future<void> upsert(PackingItem item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx == -1) {
      _items.add(item);
    } else {
      _items[idx] = item;
    }
    _emit();
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> deleteAll() async {
    _items.clear();
    _emit();
    await saveToDisk();
  }

  Future<PackingItem?> getById(String id) async {
    if (!_loadedOnce) {
      await loadFromDisk();
    }
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> loadFromDisk() async {
    _loadedOnce = true;
    if (kIsWeb) return;
    try {
      final raw = await UserScopedStorage.instance.readSecure('packing_items.json');
      if (raw == null) {
        _items.clear();
        _emit();
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _items.clear();
        _emit();
        return;
      }
      final loaded = <PackingItem>[];
      for (final row in decoded) {
        if (row is! Map) continue;
        try {
          loaded.add(PackingItem.fromJson(Map<String, dynamic>.from(row)));
        } catch (_) {
          // Skip invalid row.
        }
      }
      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _emit();
    }
  }

  Future<void> saveToDisk() async {
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _items.map((item) => item.toJson()).toList(growable: false),
      );
      await UserScopedStorage.instance.writeSecure('packing_items.json', payload);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingRepositoryLocal] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  /// Seeds the default packing items for [mode] if the local list is empty.
  Future<void> seedDefaultsIfEmpty(String ownerId, HospitalMode mode) async {
    if (!_loadedOnce) {
      await loadFromDisk();
    }
    if (_items.isNotEmpty) return;
    final now = DateTime.now();

    final all = _allSeedItems(ownerId, now);
    final filtered = all
        .where((item) => item.modes.contains(mode))
        .toList(growable: false);

    _items
      ..clear()
      ..addAll(filtered);
    _emit();
    await saveToDisk();
  }

  /// Re-seeds after a full reset: clears everything, then re-seeds.
  Future<void> resetAndReseed(String ownerId, HospitalMode mode) async {
    _items.clear();
    _emit();
    await saveToDisk();
    await seedDefaultsIfEmpty(ownerId, mode);
  }

  // ── Default seed items ───────────────────────────────────────

  static const _both = <HospitalMode>[
    HospitalMode.ambulant,
    HospitalMode.stationary,
  ];
  static const _stationaryOnly = <HospitalMode>[HospitalMode.stationary];
  static const _ambulantOnly = <HospitalMode>[HospitalMode.ambulant];

  List<PackingItem> _allSeedItems(String ownerId, DateTime now) {
    return <PackingItem>[
      // ── Dokumente ────────────────────────────────────────────
      _seed('pack_doc_versicherung', ownerId, 'Versichertenkarte',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_aufklaerung', ownerId, 'Aufklärungsunterlagen',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_ausweis', ownerId, 'Personalausweis',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_einweisung', ownerId, 'Einweisungsschein',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_medliste', ownerId, 'Aktuelle Medikamentenliste',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_verfuegung', ownerId,
          'Patientenverfügung / Vorsorgevollmacht',
          PackingCategory.documents, now, _both, false),
      _seed('pack_doc_allergiepass', ownerId, 'Allergiepass (falls vorhanden)',
          PackingCategory.documents, now, _both, false),

      // ── Kleidung ─────────────────────────────────────────────
      _seed('pack_clothing_hausschuhe', ownerId, 'Hausschuhe',
          PackingCategory.clothing, now, _stationaryOnly, true),
      _seed('pack_clothing_wechsel', ownerId,
          'Bequeme Kleidung (mehrere Wechsel)',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_schlafanzug', ownerId, 'Schlafanzug / Nachthemd',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_bademantel', ownerId, 'Bademantel',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_unterwaesche', ownerId, 'Unterwäsche (mehrere)',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_socken', ownerId, 'Socken (rutschfeste)',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_entlassung', ownerId, 'Kleidung für die Entlassung',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_ambulant', ownerId,
          'Bequeme Kleidung zum Umziehen',
          PackingCategory.clothing, now, _ambulantOnly, false),

      // ── Hygiene ──────────────────────────────────────────────
      _seed('pack_hygiene_zahnbuerste', ownerId, 'Zahnbürste & Zahnpasta',
          PackingCategory.hygiene, now, _stationaryOnly, true),
      _seed('pack_hygiene_kulturbeutel', ownerId, 'Kulturbeutel',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_shampoo', ownerId, 'Shampoo & Duschgel',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_deo', ownerId, 'Deodorant',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_kamm', ownerId, 'Haarbürste / Kamm',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_feuchttuecher', ownerId, 'Feuchttücher',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_lippenpflege', ownerId, 'Lippenpflege',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_taschentuecher', ownerId, 'Taschentücher',
          PackingCategory.hygiene, now, _both, false),

      // ── Technik ──────────────────────────────────────────────
      _seed('pack_tech_ladekabel', ownerId, 'Handy-Ladekabel',
          PackingCategory.technology, now, _both, false),
      _seed('pack_tech_mehrfachstecker', ownerId,
          'Mehrfachsteckdose / Verlängerungskabel',
          PackingCategory.technology, now, _stationaryOnly, false),

      // ── Unterhaltung ─────────────────────────────────────────
      _seed('pack_ent_kopfhoerer', ownerId, 'Kopfhörer',
          PackingCategory.entertainment, now, _stationaryOnly, false),
      _seed('pack_ent_buch', ownerId, 'Buch oder E-Reader',
          PackingCategory.entertainment, now, _stationaryOnly, false),
      _seed('pack_ent_notizbuch', ownerId, 'Notizbuch & Stift',
          PackingCategory.entertainment, now, _both, false),
      _seed('pack_ent_tablet', ownerId, 'Tablet (optional)',
          PackingCategory.entertainment, now, _stationaryOnly, false),

      // ── Medikamente ──────────────────────────────────────────
      _seed('pack_med_home_meds', ownerId,
          'Eigene Medikamente (nach Absprache)',
          PackingCategory.medication, now, _both, false),
      _seed('pack_med_blutzucker', ownerId,
          'Blutzuckermessgerät (falls benötigt)',
          PackingCategory.medication, now, _both, false),

      // ── Sonstiges ────────────────────────────────────────────
      _seed('pack_other_bargeld', ownerId, 'Bargeld (für Kiosk/Automaten)',
          PackingCategory.other, now, _stationaryOnly, false),
      _seed('pack_other_trinkflasche', ownerId, 'Trinkflasche',
          PackingCategory.other, now, _stationaryOnly, false),
      _seed('pack_other_ohropax', ownerId, 'Ohropax',
          PackingCategory.other, now, _stationaryOnly, false),
      _seed('pack_other_begleitperson', ownerId, 'Begleitperson organisiert',
          PackingCategory.other, now, _ambulantOnly, true),
      _seed('pack_other_heimfahrt', ownerId, 'Heimfahrt organisiert',
          PackingCategory.other, now, _ambulantOnly, true),
    ];
  }

  PackingItem _seed(
    String id,
    String ownerId,
    String title,
    PackingCategory category,
    DateTime now,
    List<HospitalMode> modes,
    bool isRequired,
  ) {
    return PackingItem(
      id: id,
      ownerId: ownerId,
      title: title,
      category: category,
      checked: false,
      createdAt: now,
      updatedAt: now,
      isDefault: true,
      isRequired: isRequired,
      modes: modes,
      metadata: const <String, dynamic>{'seed': true},
    );
  }

  void dispose() {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    _disposed = true;
    _controller.close();
  }

  void _scheduleSave() {
    if (_disposed) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 250), () {
      if (_disposed) return;
      unawaited(saveToDisk());
    });
  }

  void _emit() {
    if (_disposed || _controller.isClosed) return;
    _controller.add(_sorted(_items));
  }

  List<PackingItem> _sorted(List<PackingItem> source) {
    final copy = List<PackingItem>.from(source);
    copy.sort((a, b) {
      final byCategory = a.category.index.compareTo(b.category.index);
      if (byCategory != 0) return byCategory;
      // Required items first within category
      if (a.isRequired != b.isRequired) return a.isRequired ? -1 : 1;
      final byChecked = a.checked == b.checked ? 0 : (a.checked ? 1 : -1);
      if (byChecked != 0) return byChecked;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('packing_items.json');
  }
}
