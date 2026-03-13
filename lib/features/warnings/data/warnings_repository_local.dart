import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/warning_check.dart';

class WarningsRepositoryLocal {
  static final WarningsRepositoryLocal instance =
      WarningsRepositoryLocal._internal();

  factory WarningsRepositoryLocal() => instance;

  WarningsRepositoryLocal._internal() {
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _latest = null;
  }

  WarningCheck? _latest;

  Future<WarningCheck?> loadLatest() async {
    if (kIsWeb) return null;
    final file = await _storageFile();
    try {
      if (!await file.exists()) {
        _latest = null;
        return null;
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _latest = null;
        return null;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _latest = null;
        return null;
      }
      _latest = WarningCheck.fromJson(Map<String, dynamic>.from(decoded));
      return _latest;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WarningsRepositoryLocal] loadLatest failed: $error');
        debugPrint('$stackTrace');
      }
      _latest = null;
      return null;
    }
  }

  Future<void> saveLatest(WarningCheck check) async {
    _latest = check;
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      await file.writeAsString(jsonEncode(check.toJson()), flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WarningsRepositoryLocal] saveLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  WarningCheck? get cachedLatest => _latest;

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('warning_latest.json');
  }
}
