import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/packing_item.dart';
import '../domain/packing_list.dart';

/// Key for persisting the selected hospital mode.
const String _kHospitalModeKey = 'packing_hospital_mode';

/// Key to track whether the V2 (multi-list) migration has run.
const String _kMigrationDoneKey = 'packing_v2_migrated';

class PackingListRepositoryLocal {
  static final PackingListRepositoryLocal instance =
      PackingListRepositoryLocal._internal();

  factory PackingListRepositoryLocal() => instance;

  PackingListRepositoryLocal._internal() {
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _loadedOnce = false;
    _lists.clear();
    _itemsByList.clear();
    _emitLists();
    unawaited(loadFromDisk());
  }

  final List<PackingList> _lists = <PackingList>[];
  final Map<String, List<PackingItem>> _itemsByList =
      <String, List<PackingItem>>{};
  final StreamController<List<PackingList>> _listsController =
      StreamController<List<PackingList>>.broadcast();
  final Map<String, StreamController<List<PackingItem>>> _itemControllers =
      <String, StreamController<List<PackingItem>>>{};

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _loadedOnce = false;

  // ── Hospital mode (legacy compat) ──────────────────────────

  Future<HospitalMode?> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHospitalModeKey);
    return HospitalMode.tryParse(raw);
  }

  Future<void> setMode(HospitalMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHospitalModeKey, mode.name);
  }

  Future<void> clearMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHospitalModeKey);
  }

  // ── Migration ──────────────────────────────────────────────

  Future<bool> needsMigration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kMigrationDoneKey) != true;
  }

  Future<void> markMigrationDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMigrationDoneKey, true);
  }

  /// Migrates old flat-file items into a default list.
  Future<void> migrateFromV1(String ownerId) async {
    if (!(await needsMigration())) return;

    final oldFile = await _legacyStorageFile();
    if (!await oldFile.exists()) {
      await markMigrationDone();
      return;
    }

    try {
      final raw = await oldFile.readAsString();
      if (raw.trim().isEmpty) {
        await markMigrationDone();
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.isEmpty) {
        await markMigrationDone();
        return;
      }

      final oldItems = <PackingItem>[];
      for (final row in decoded) {
        if (row is! Map) continue;
        try {
          oldItems.add(PackingItem.fromJson(Map<String, dynamic>.from(row)));
        } catch (_) {}
      }

      if (oldItems.isEmpty) {
        await markMigrationDone();
        return;
      }

      // Determine mode from SharedPreferences.
      final mode = await getMode();
      final now = DateTime.now();

      final listId = 'packing_list_migrated_${now.microsecondsSinceEpoch}';
      final list = PackingList(
        id: listId,
        ownerId: ownerId,
        title: mode == HospitalMode.ambulant
            ? 'Ambulante OP'
            : 'Stationäre OP',
        type: mode == HospitalMode.ambulant
            ? PackingListType.ambulant
            : PackingListType.stationary,
        mode: mode,
        createdAt: now,
        updatedAt: now,
        isDefault: true,
        itemCount: oldItems.length,
        checkedCount: oldItems.where((i) => i.checked).length,
      );

      final migratedItems = oldItems.map((item) {
        return item.copyWith(listId: listId);
      }).toList(growable: false);

      _lists.add(list);
      _itemsByList[listId] = migratedItems;
      _emitLists();
      _emitItems(listId);
      await _saveToDisk();
      await markMigrationDone();

      if (kDebugMode) {
        debugPrint(
          '[PackingListRepo] Migrated ${oldItems.length} items into list "$listId"',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingListRepo] Migration failed: $error');
        debugPrint('$stackTrace');
      }
      // Mark done anyway to prevent repeated failures.
      await markMigrationDone();
    }
  }

  // ── Lists CRUD ─────────────────────────────────────────────

  Stream<List<PackingList>> watchLists() async* {
    yield _sortedLists();
    yield* _listsController.stream;
  }

  List<PackingList> get currentLists => _sortedLists();

  Future<PackingList?> getListById(String id) async {
    if (!_loadedOnce) await loadFromDisk();
    for (final list in _lists) {
      if (list.id == id) return list;
    }
    return null;
  }

  Future<void> upsertList(PackingList list) async {
    final idx = _lists.indexWhere((l) => l.id == list.id);
    if (idx == -1) {
      _lists.add(list);
    } else {
      _lists[idx] = list;
    }
    _emitLists();
    _scheduleSave();
  }

  Future<void> deleteList(String listId) async {
    _lists.removeWhere((l) => l.id == listId);
    _itemsByList.remove(listId);
    _itemControllers.remove(listId)?.close();
    _emitLists();
    _scheduleSave();
  }

  Future<void> archiveList(String listId) async {
    final idx = _lists.indexWhere((l) => l.id == listId);
    if (idx == -1) return;
    _lists[idx] = _lists[idx].copyWith(
      archivedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _emitLists();
    _scheduleSave();
  }

  // ── Items CRUD ─────────────────────────────────────────────

  Stream<List<PackingItem>> watchItems(String listId) async* {
    yield _sortedItems(listId);
    final controller = _itemControllers.putIfAbsent(
      listId,
      () => StreamController<List<PackingItem>>.broadcast(),
    );
    yield* controller.stream;
  }

  List<PackingItem> getItems(String listId) => _sortedItems(listId);

  Future<void> upsertItem(PackingItem item) async {
    final listId = item.listId;
    if (listId == null) return;

    final items = _itemsByList.putIfAbsent(listId, () => <PackingItem>[]);
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx == -1) {
      items.add(item);
    } else {
      items[idx] = item;
    }
    _emitItems(listId);
    _updateListCounters(listId);
    _scheduleSave();
  }

  Future<void> deleteItem(String listId, String itemId) async {
    _itemsByList[listId]?.removeWhere((i) => i.id == itemId);
    _emitItems(listId);
    _updateListCounters(listId);
    _scheduleSave();
  }

  Future<void> toggleItem(String listId, PackingItem item, bool value,
      {String? byUid}) async {
    final now = DateTime.now();
    await upsertItem(item.copyWith(
      checked: value,
      updatedAt: now,
      packedByUid: value ? byUid : null,
      packedAt: value ? now : null,
      clearPackedBy: !value,
    ));
  }

  // ── Seed defaults ──────────────────────────────────────────

  Future<PackingList> createListWithDefaults({
    required String ownerId,
    required String title,
    required PackingListType type,
    HospitalMode? mode,
    String? icon,
  }) async {
    final now = DateTime.now();
    final listId = 'packing_list_${now.microsecondsSinceEpoch}';

    final seeds = _seedItemsForType(ownerId, listId, type, mode, now);

    final list = PackingList(
      id: listId,
      ownerId: ownerId,
      title: title,
      type: type,
      mode: mode,
      icon: icon,
      createdAt: now,
      updatedAt: now,
      isDefault: _lists.isEmpty,
      itemCount: seeds.length,
      checkedCount: 0,
    );

    _lists.add(list);
    _itemsByList[listId] = seeds;
    _emitLists();
    _emitItems(listId);
    await _saveToDisk();
    return list;
  }

  // ── Persistence ────────────────────────────────────────────

  Future<void> loadFromDisk() async {
    if (_loadedOnce) return;
    _loadedOnce = true;
    final file = await _storageFile();
    try {
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final listsJson = decoded['lists'];
      if (listsJson is List) {
        _lists.clear();
        for (final row in listsJson) {
          if (row is! Map) continue;
          try {
            _lists.add(PackingList.fromJson(Map<String, dynamic>.from(row)));
          } catch (_) {}
        }
      }

      final itemsJson = decoded['items'];
      if (itemsJson is Map) {
        _itemsByList.clear();
        for (final entry in itemsJson.entries) {
          final listId = entry.key.toString();
          final itemList = entry.value;
          if (itemList is! List) continue;
          final items = <PackingItem>[];
          for (final row in itemList) {
            if (row is! Map) continue;
            try {
              items.add(
                  PackingItem.fromJson(Map<String, dynamic>.from(row)));
            } catch (_) {}
          }
          _itemsByList[listId] = items;
        }
      }

      _emitLists();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingListRepo] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> _saveToDisk() async {
    final file = await _storageFile();
    try {
      final payload = jsonEncode(<String, dynamic>{
        'lists':
            _lists.map((l) => l.toJson()).toList(growable: false),
        'items': _itemsByList.map(
          (listId, items) => MapEntry(
            listId,
            items.map((i) => i.toJson()).toList(growable: false),
          ),
        ),
      });
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingListRepo] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  void dispose() {
    _saveDebounce?.cancel();
    _disposed = true;
    _listsController.close();
    for (final c in _itemControllers.values) {
      c.close();
    }
  }

  // ── Internal helpers ───────────────────────────────────────

  void _scheduleSave() {
    if (_disposed) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 250), () {
      if (_disposed) return;
      unawaited(_saveToDisk());
    });
  }

  void _emitLists() {
    if (_disposed || _listsController.isClosed) return;
    _listsController.add(_sortedLists());
  }

  void _emitItems(String listId) {
    final controller = _itemControllers[listId];
    if (controller == null || controller.isClosed) return;
    controller.add(_sortedItems(listId));
  }

  void _updateListCounters(String listId) {
    final idx = _lists.indexWhere((l) => l.id == listId);
    if (idx == -1) return;
    final items = _itemsByList[listId] ?? const <PackingItem>[];
    _lists[idx] = _lists[idx].copyWith(
      itemCount: items.length,
      checkedCount: items.where((i) => i.checked).length,
      updatedAt: DateTime.now(),
    );
    _emitLists();
  }

  List<PackingList> _sortedLists() {
    final copy = List<PackingList>.from(_lists);
    copy.sort((a, b) {
      // Active lists first, archived last.
      if (a.isArchived != b.isArchived) return a.isArchived ? 1 : -1;
      // Default list first.
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      // Then by sort order, then by creation date.
      final bySortOrder = a.sortOrder.compareTo(b.sortOrder);
      if (bySortOrder != 0) return bySortOrder;
      return b.createdAt.compareTo(a.createdAt);
    });
    return copy;
  }

  List<PackingItem> _sortedItems(String listId) {
    final items = _itemsByList[listId];
    if (items == null || items.isEmpty) return const <PackingItem>[];
    final copy = List<PackingItem>.from(items);
    copy.sort((a, b) {
      final byCategory = a.category.index.compareTo(b.category.index);
      if (byCategory != 0) return byCategory;
      // Required / high-priority first.
      if (a.isRequired != b.isRequired) return a.isRequired ? -1 : 1;
      final byPriority = b.priority.index.compareTo(a.priority.index);
      if (byPriority != 0) return byPriority;
      // Unchecked first.
      if (a.checked != b.checked) return a.checked ? 1 : -1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('packing_lists_v2.json');
  }

  Future<File> _legacyStorageFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/packing_items.json');
  }

  // ── Seed item factory ──────────────────────────────────────

  List<PackingItem> _seedItemsForType(
    String ownerId,
    String listId,
    PackingListType type,
    HospitalMode? mode,
    DateTime now,
  ) {
    final effectiveMode = mode ??
        (type == PackingListType.ambulant
            ? HospitalMode.ambulant
            : HospitalMode.stationary);

    // Use the same seed pool as before, filtered by effective mode.
    final all = _allSeedItems(ownerId, listId, now);
    if (type == PackingListType.child) {
      return [
        ...all.where((i) => i.modes.contains(effectiveMode)),
        _seed('pack_child_kuscheltier', ownerId, listId, 'Kuscheltier / Lieblingsspielzeug',
            PackingCategory.entertainment, now, _both, false),
        _seed('pack_child_muetze', ownerId, listId, 'Mütze oder Stirnband',
            PackingCategory.clothing, now, _both, false),
        _seed('pack_child_windeln', ownerId, listId, 'Windeln (falls benötigt)',
            PackingCategory.hygiene, now, _both, false),
        _seed('pack_child_schnuller', ownerId, listId, 'Schnuller',
            PackingCategory.other, now, _both, false),
        _seed('pack_child_mutterpass', ownerId, listId, 'U-Heft',
            PackingCategory.documents, now, _both, true),
      ];
    }

    if (type == PackingListType.rehab) {
      return [
        ...all.where((i) => i.modes.contains(HospitalMode.stationary)),
        _seed('pack_rehab_sportschuhe', ownerId, listId, 'Sportschuhe',
            PackingCategory.clothing, now, _stationaryOnly, false),
        _seed('pack_rehab_sportkleidung', ownerId, listId, 'Sportkleidung (mehrere Sets)',
            PackingCategory.clothing, now, _stationaryOnly, false),
        _seed('pack_rehab_schwimmsachen', ownerId, listId, 'Schwimmsachen / Badekappe',
            PackingCategory.clothing, now, _stationaryOnly, false),
        _seed('pack_rehab_sonnenbrille', ownerId, listId, 'Sonnenbrille / Sonnencreme',
            PackingCategory.other, now, _stationaryOnly, false),
        _seed('pack_rehab_wanderschuhe', ownerId, listId, 'Wanderschuhe (falls Outdoor)',
            PackingCategory.clothing, now, _stationaryOnly, false),
      ];
    }

    return all.where((i) => i.modes.contains(effectiveMode)).toList(growable: false);
  }

  static const _both = <HospitalMode>[
    HospitalMode.ambulant,
    HospitalMode.stationary,
  ];
  static const _stationaryOnly = <HospitalMode>[HospitalMode.stationary];
  static const _ambulantOnly = <HospitalMode>[HospitalMode.ambulant];

  List<PackingItem> _allSeedItems(String ownerId, String listId, DateTime now) {
    return <PackingItem>[
      // ── Dokumente ────────────────────────────────────────────
      _seed('pack_doc_versicherung', ownerId, listId, 'Versichertenkarte',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_aufklaerung', ownerId, listId, 'Aufklärungsunterlagen',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_ausweis', ownerId, listId, 'Personalausweis',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_einweisung', ownerId, listId, 'Einweisungsschein',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_medliste', ownerId, listId, 'Aktuelle Medikamentenliste',
          PackingCategory.documents, now, _both, true),
      _seed('pack_doc_verfuegung', ownerId, listId,
          'Patientenverfügung / Vorsorgevollmacht',
          PackingCategory.documents, now, _both, false),
      _seed('pack_doc_allergiepass', ownerId, listId,
          'Allergiepass (falls vorhanden)',
          PackingCategory.documents, now, _both, false),

      // ── Kleidung ─────────────────────────────────────────────
      _seed('pack_clothing_hausschuhe', ownerId, listId, 'Hausschuhe',
          PackingCategory.clothing, now, _stationaryOnly, true),
      _seed('pack_clothing_wechsel', ownerId, listId,
          'Bequeme Kleidung (mehrere Wechsel)',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_schlafanzug', ownerId, listId,
          'Schlafanzug / Nachthemd',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_bademantel', ownerId, listId, 'Bademantel',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_unterwaesche', ownerId, listId,
          'Unterwäsche (mehrere)',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_socken', ownerId, listId, 'Socken (rutschfeste)',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_entlassung', ownerId, listId,
          'Kleidung für die Entlassung',
          PackingCategory.clothing, now, _stationaryOnly, false),
      _seed('pack_clothing_ambulant', ownerId, listId,
          'Bequeme Kleidung zum Umziehen',
          PackingCategory.clothing, now, _ambulantOnly, false),

      // ── Hygiene ──────────────────────────────────────────────
      _seed('pack_hygiene_zahnbuerste', ownerId, listId,
          'Zahnbürste & Zahnpasta',
          PackingCategory.hygiene, now, _stationaryOnly, true),
      _seed('pack_hygiene_kulturbeutel', ownerId, listId, 'Kulturbeutel',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_shampoo', ownerId, listId, 'Shampoo & Duschgel',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_deo', ownerId, listId, 'Deodorant',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_kamm', ownerId, listId, 'Haarbürste / Kamm',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_feuchttuecher', ownerId, listId, 'Feuchttücher',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_lippenpflege', ownerId, listId, 'Lippenpflege',
          PackingCategory.hygiene, now, _stationaryOnly, false),
      _seed('pack_hygiene_taschentuecher', ownerId, listId, 'Taschentücher',
          PackingCategory.hygiene, now, _both, false),

      // ── Technik ──────────────────────────────────────────────
      _seed('pack_tech_ladekabel', ownerId, listId, 'Handy-Ladekabel',
          PackingCategory.technology, now, _both, false),
      _seed('pack_tech_mehrfachstecker', ownerId, listId,
          'Mehrfachsteckdose / Verlängerungskabel',
          PackingCategory.technology, now, _stationaryOnly, false),

      // ── Unterhaltung ─────────────────────────────────────────
      _seed('pack_ent_kopfhoerer', ownerId, listId, 'Kopfhörer',
          PackingCategory.entertainment, now, _stationaryOnly, false),
      _seed('pack_ent_buch', ownerId, listId, 'Buch oder E-Reader',
          PackingCategory.entertainment, now, _stationaryOnly, false),
      _seed('pack_ent_notizbuch', ownerId, listId, 'Notizbuch & Stift',
          PackingCategory.entertainment, now, _both, false),
      _seed('pack_ent_tablet', ownerId, listId, 'Tablet (optional)',
          PackingCategory.entertainment, now, _stationaryOnly, false),

      // ── Medikamente ──────────────────────────────────────────
      _seed('pack_med_home_meds', ownerId, listId,
          'Eigene Medikamente (nach Absprache)',
          PackingCategory.medication, now, _both, false),
      _seed('pack_med_blutzucker', ownerId, listId,
          'Blutzuckermessgerät (falls benötigt)',
          PackingCategory.medication, now, _both, false),

      // ── Sonstiges ────────────────────────────────────────────
      _seed('pack_other_bargeld', ownerId, listId,
          'Bargeld (für Kiosk/Automaten)',
          PackingCategory.other, now, _stationaryOnly, false),
      _seed('pack_other_trinkflasche', ownerId, listId, 'Trinkflasche',
          PackingCategory.other, now, _stationaryOnly, false),
      _seed('pack_other_ohropax', ownerId, listId, 'Ohropax',
          PackingCategory.other, now, _stationaryOnly, false),
      _seed('pack_other_begleitperson', ownerId, listId,
          'Begleitperson organisiert',
          PackingCategory.other, now, _ambulantOnly, true),
      _seed('pack_other_heimfahrt', ownerId, listId, 'Heimfahrt organisiert',
          PackingCategory.other, now, _ambulantOnly, true),
    ];
  }

  PackingItem _seed(
    String id,
    String ownerId,
    String listId,
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
      listId: listId,
      priority:
          isRequired ? PackingPriority.high : PackingPriority.normal,
      modes: modes,
      metadata: const <String, dynamic>{'seed': true},
    );
  }
}
