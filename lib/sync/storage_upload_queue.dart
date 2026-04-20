import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'user_scoped_storage.dart';

/// A single pending file upload.
class StorageUploadOp {
  const StorageUploadOp({
    required this.id,
    required this.localFilePath,
    required this.remoteStoragePath,
    required this.contentType,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  final String id;
  final String localFilePath;
  final String remoteStoragePath;
  final String contentType;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  StorageUploadOp copyWith({int? retryCount, String? lastError}) {
    return StorageUploadOp(
      id: id,
      localFilePath: localFilePath,
      remoteStoragePath: remoteStoragePath,
      contentType: contentType,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'localFilePath': localFilePath,
    'remoteStoragePath': remoteStoragePath,
    'contentType': contentType,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
    'lastError': lastError,
  };

  factory StorageUploadOp.fromJson(Map<String, dynamic> json) {
    return StorageUploadOp(
      id: (json['id'] ?? '').toString(),
      localFilePath: (json['localFilePath'] ?? '').toString(),
      remoteStoragePath: (json['remoteStoragePath'] ?? '').toString(),
      contentType: (json['contentType'] ?? 'application/octet-stream').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      lastError: json['lastError']?.toString(),
    );
  }
}

/// Persistent queue for Firebase Storage file uploads.
///
/// Files are enqueued locally and uploaded when connectivity is available.
/// Failed uploads stay in the queue and are retried on the next
/// [retryAll] call (triggered by [ConnectivityService] on reconnect).
class StorageUploadQueue {
  StorageUploadQueue._();
  static final StorageUploadQueue instance = StorageUploadQueue._();

  static const _fileName = 'storage_upload_queue.json';

  final List<StorageUploadOp> _ops = <StorageUploadOp>[];
  bool _isLoaded = false;
  bool _isSaving = false;
  bool _saveQueued = false;
  Timer? _saveTimer;
  bool _isRetrying = false;

  Future<void> enqueue(StorageUploadOp op) async {
    await _ensureLoaded();
    _ops.removeWhere((e) => e.id == op.id);
    _ops.add(op);
    _scheduleSave();
  }

  Future<List<StorageUploadOp>> pending() async {
    await _ensureLoaded();
    return List<StorageUploadOp>.of(
      _ops..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  }

  static const int maxRetries = 10;

  /// Upload all pending files. Called on reconnect or manually.
  Future<void> retryAll() async {
    if (kIsWeb || _isRetrying) return;
    _isRetrying = true;

    try {
      await _ensureLoaded();
      final snapshot = List<StorageUploadOp>.of(_ops);
      final storage = FirebaseStorage.instance;

      for (final op in snapshot) {
        if (op.retryCount > maxRetries) {
          if (kDebugMode) {
            debugPrint(
              '[UploadQueue] Dropping op ${op.id} after ${op.retryCount} '
              'retries: ${op.lastError}',
            );
          }
          _ops.removeWhere((e) => e.id == op.id);
          continue;
        }
        final file = File(op.localFilePath);
        if (!await file.exists()) {
          _ops.removeWhere((e) => e.id == op.id);
          continue;
        }
        try {
          await storage
              .ref(op.remoteStoragePath)
              .putFile(file, SettableMetadata(contentType: op.contentType));
          _ops.removeWhere((e) => e.id == op.id);
        } catch (e) {
          final idx = _ops.indexWhere((o) => o.id == op.id);
          if (idx != -1) {
            _ops[idx] = _ops[idx].copyWith(
              retryCount: _ops[idx].retryCount + 1,
              lastError: e.toString(),
            );
          }
        }
      }
      _scheduleSave();
    } finally {
      _isRetrying = false;
    }
  }

  Future<void> markDone(String id) async {
    await _ensureLoaded();
    _ops.removeWhere((e) => e.id == id);
    _scheduleSave();
  }

  // ── Persistence ────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    _isLoaded = true;
    if (kIsWeb) return;

    try {
      final content = await UserScopedStorage.instance.readSecure(_fileName);
      if (content == null) return;
      final decoded = jsonDecode(content);
      if (decoded is! List) return;

      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          final json =
              item.map((k, v) => MapEntry(k.toString(), v));
          _ops.add(StorageUploadOp.fromJson(json));
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[UploadQueue] Failed to load queue: $e');
      _ops.clear();
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), () async {
      await _saveNow();
    });
  }

  Future<void> _saveNow() async {
    if (kIsWeb) return;
    if (_isSaving) {
      _saveQueued = true;
      return;
    }
    _isSaving = true;
    try {
      final json = _ops.map((o) => o.toJson()).toList();
      await UserScopedStorage.instance.writeSecure(_fileName, jsonEncode(json));
    } finally {
      _isSaving = false;
      if (_saveQueued) {
        _saveQueued = false;
        // Schedule via timer to avoid unbounded recursion.
        _scheduleSave();
      }
    }
  }

  void dispose() {
    _saveTimer?.cancel();
  }
}
