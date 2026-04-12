import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/photo_entry.dart';

class PhotosRepositoryLocal {
  static final PhotosRepositoryLocal instance =
      PhotosRepositoryLocal._internal();

  factory PhotosRepositoryLocal() => instance;

  PhotosRepositoryLocal._internal({bool autoLoad = true}) {
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

  final List<PhotoEntry> _items = <PhotoEntry>[];
  final StreamController<List<PhotoEntry>> _controller =
      StreamController<List<PhotoEntry>>.broadcast();
  Timer? _saveDebounce;
  bool _disposed = false;

  Stream<List<PhotoEntry>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  Future<void> upsert(PhotoEntry item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
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

  Future<void> loadFromDisk() async {
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      if (!await file.exists()) {
        _items.clear();
        _emit();
        return;
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
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

      final loaded = <PhotoEntry>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          loaded.add(PhotoEntry.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Keep repository robust if single entries are malformed.
        }
      }

      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PhotosRepositoryLocal] loadFromDisk failed: $error');
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
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PhotosRepositoryLocal] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<String> storeImageFromPath(String sourcePath, String photoId) async {
    final userDir = await UserScopedStorage.instance.userDirectory();
    final dir = Directory('${userDir.path}/photos');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final extension = _fileExtension(sourcePath);
    final targetPath = '${dir.path}/$photoId$extension';
    final copied = await File(sourcePath).copy(targetPath);
    return copied.path;
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
    _saveDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_disposed) return;
      unawaited(saveToDisk());
    });
  }

  void _emit() {
    if (_disposed || _controller.isClosed) return;
    _controller.add(_sorted(_items));
  }

  List<PhotoEntry> _sorted(List<PhotoEntry> source) {
    final copy = source.where((e) => e.deletedAt == null).toList();
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  String _fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot >= path.length - 1) return '.jpg';
    return path.substring(dot);
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('photo_entries.json');
  }
}
