import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'sync_models.dart';

class SyncQueueLocal {
  SyncQueueLocal({
    this.fileName = 'sync_queue.json',
    this.saveDebounce = const Duration(milliseconds: 300),
  });

  final String fileName;
  final Duration saveDebounce;

  final List<SyncOp> _ops = <SyncOp>[];
  bool _isLoaded = false;
  bool _isSaving = false;
  bool _saveQueued = false;
  Timer? _saveDebounceTimer;

  Future<void> enqueue(SyncOp op) async {
    await _ensureLoaded();
    _ops.removeWhere((SyncOp existing) => existing.id == op.id);
    _ops.add(op);
    _scheduleSave();
  }

  Future<List<SyncOp>> pending() async {
    await _ensureLoaded();
    final sorted = List<SyncOp>.of(_ops)
      ..sort((SyncOp a, SyncOp b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  Future<void> markDone(String id) async {
    await _ensureLoaded();
    _ops.removeWhere((SyncOp op) => op.id == id);
    _scheduleSave();
  }

  Future<void> markFailed(String id, String error) async {
    await _ensureLoaded();
    final index = _ops.indexWhere((SyncOp op) => op.id == id);
    if (index == -1) return;

    final op = _ops[index];
    _ops[index] = op.copyWith(
      retryCount: op.retryCount + 1,
      lastError: error,
    );
    _scheduleSave();
  }

  Future<void> clear() async {
    await _ensureLoaded();
    _ops.clear();
    _scheduleSave();
  }

  Future<void> flush() async {
    _saveDebounceTimer?.cancel();
    await _saveNow();
  }

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    _isLoaded = true;
    await _loadFromDisk();
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<void> _loadFromDisk() async {
    final file = await _file();
    if (!await file.exists()) {
      return;
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return;

      final decoded = jsonDecode(content);
      if (decoded is! List) {
        await _backupBrokenFile(file);
        return;
      }

      final parsed = <SyncOp>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          final json = item.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          );
          parsed.add(SyncOp.fromJson(json));
        } catch (_) {
          // Skip malformed entry to keep queue usable.
        }
      }
      _ops
        ..clear()
        ..addAll(parsed);
    } catch (_) {
      await _backupBrokenFile(file);
    }
  }

  void _scheduleSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(saveDebounce, () async {
      await _saveNow();
    });
  }

  Future<void> _saveNow() async {
    if (_isSaving) {
      _saveQueued = true;
      return;
    }
    _isSaving = true;
    try {
      final file = await _file();
      final jsonList = _ops.map((SyncOp op) => op.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList), flush: true);
    } finally {
      _isSaving = false;
      if (_saveQueued) {
        _saveQueued = false;
        await _saveNow();
      }
    }
  }

  Future<void> _backupBrokenFile(File file) async {
    try {
      final backupPath =
          '${file.path}.broken_${DateTime.now().millisecondsSinceEpoch}';
      await file.rename(backupPath);
    } catch (_) {
      try {
        await file.delete();
      } catch (_) {
        // Ignore if backup and delete both fail.
      }
    }
    _ops.clear();
  }
}
