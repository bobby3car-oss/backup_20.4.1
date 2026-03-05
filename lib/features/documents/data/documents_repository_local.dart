import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/document_item.dart';
import 'documents_repository.dart';

class DocumentsRepositoryLocal implements DocumentsRepository {
  static final DocumentsRepositoryLocal instance =
      DocumentsRepositoryLocal._internal();

  factory DocumentsRepositoryLocal() => instance;

  DocumentsRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
  }

  final List<DocumentItem> _items = <DocumentItem>[];
  final StreamController<List<DocumentItem>> _controller =
      StreamController<List<DocumentItem>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;

  @override
  Stream<List<DocumentItem>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(DocumentItem item) async {
    final index = _items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    _emit();
    _scheduleSave();
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
    _scheduleSave();
  }

  @override
  Future<void> loadFromDisk() async {
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

      final loaded = <DocumentItem>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          loaded.add(DocumentItem.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Skip malformed entry to keep repository usable.
        }
      }

      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[DocumentsRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _emit();
    }
  }

  @override
  Future<void> saveToDisk() async {
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _items.map((item) => item.toJson()).toList(growable: false),
      );
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[DocumentsRepositoryLocal] saveToDisk failed: $error');
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

  List<DocumentItem> _sorted(List<DocumentItem> source) {
    final copy = List<DocumentItem>.from(source);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  Future<File> _storageFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/documents.json');
  }
}
