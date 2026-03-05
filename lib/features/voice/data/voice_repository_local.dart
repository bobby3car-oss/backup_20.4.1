import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/voice_memo.dart';

class VoiceRepositoryLocal {
  static final VoiceRepositoryLocal instance = VoiceRepositoryLocal._internal();

  factory VoiceRepositoryLocal() => instance;

  VoiceRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
  }

  final List<VoiceMemo> _items = <VoiceMemo>[];
  final StreamController<List<VoiceMemo>> _controller =
      StreamController<List<VoiceMemo>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  Stream<List<VoiceMemo>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  Future<void> upsert(VoiceMemo memo) async {
    final index = _items.indexWhere((existing) => existing.id == memo.id);
    if (index == -1) {
      _items.add(memo);
    } else {
      _items[index] = memo;
    }
    _emit();
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((memo) => memo.id == id);
    _emit();
    _scheduleSave();
  }

  Future<VoiceMemo?> getById(String id) async {
    if (!_isLoadedOnce) {
      await loadFromDisk();
    }
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<String> recordingPathFor(String memoId) async {
    final dir = await _audioDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/$memoId.m4a';
  }

  Future<void> deleteLocalAudioFile(String filePath) async {
    if (filePath.trim().isEmpty) return;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup errors.
    }
  }

  Future<void> loadFromDisk() async {
    _isLoadedOnce = true;
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

      final loaded = <VoiceMemo>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(VoiceMemo.fromJson(Map<String, dynamic>.from(entry)));
        } catch (_) {
          // Skip malformed entry.
        }
      }

      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[VoiceRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _emit();
    }
  }

  Future<void> saveToDisk() async {
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _items.map((item) => item.toJson()).toList(growable: false),
      );
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[VoiceRepositoryLocal] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
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

  List<VoiceMemo> _sorted(List<VoiceMemo> source) {
    final copy = List<VoiceMemo>.from(source);
    copy.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return copy;
  }

  Future<File> _storageFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/voice_memos.json');
  }

  Future<Directory> _audioDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/voice_memos');
  }
}
