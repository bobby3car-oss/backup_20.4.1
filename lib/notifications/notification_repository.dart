import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../sync/user_scoped_storage.dart';
import 'notification_model.dart';

/// Local repository for in-app notifications.
///
/// Follows the same singleton + broadcast-stream pattern used by
/// [VitalRepositoryLocal], [PainRepositoryLocal] etc.
class NotificationRepository {
  // ── Singleton ────────────────────────────────────────────────────────────

  static final NotificationRepository instance =
      NotificationRepository._internal();

  factory NotificationRepository() => instance;

  NotificationRepository._internal() {
    unawaited(loadFromDisk());
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _items.clear();
    _emit();
    unawaited(loadFromDisk());
  }

  // ── State ────────────────────────────────────────────────────────────────

  final List<InAppNotification> _items = <InAppNotification>[];
  final StreamController<List<InAppNotification>> _controller =
      StreamController<List<InAppNotification>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;

  // ── Streams ──────────────────────────────────────────────────────────────

  /// Emits all visible (non-dismissed, non-expired, non-future) notifications,
  /// newest first.
  Stream<List<InAppNotification>> watchAll() async* {
    yield _visible(_items);
    yield* _controller.stream.map(_visible);
  }

  /// Emits the count of unread visible notifications.
  Stream<int> watchUnreadCount() =>
      watchAll().map((list) => list.where((n) => !n.isRead).length);

  // ── Reads ────────────────────────────────────────────────────────────────

  /// Current unread count (synchronous snapshot).
  int get unreadCount =>
      _visible(_items).where((n) => !n.isRead).length;

  /// Returns a notification by its ID, or `null`.
  InAppNotification? getById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Returns a notification by its source entity ID, or `null`.
  InAppNotification? getBySourceId(String sourceId) {
    for (final item in _items) {
      if (item.sourceId == sourceId) return item;
    }
    return null;
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  /// Insert or update a notification.
  Future<void> upsert(InAppNotification notification) async {
    final index = _items.indexWhere((n) => n.id == notification.id);
    if (index == -1) {
      _items.add(notification);
    } else {
      _items[index] = notification;
    }
    _emit();
    _scheduleSave();
  }

  /// Mark a single notification as read.
  Future<void> markRead(String id) async {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isRead: true);
    _emit();
    _scheduleSave();
  }

  /// Mark all visible notifications as read.
  Future<void> markAllRead() async {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].isRead && _items[i].isVisible) {
        _items[i] = _items[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _emit();
      _scheduleSave();
    }
  }

  /// Soft-dismiss a notification (keeps in storage but hidden).
  Future<void> dismiss(String id) async {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isDismissed: true);
    _emit();
    _scheduleSave();
  }

  /// Remove a notification permanently.
  Future<void> delete(String id) async {
    _items.removeWhere((n) => n.id == id);
    _emit();
    _scheduleSave();
  }

  /// Remove all notifications that reference the given source entity.
  Future<void> deleteBySourceId(String sourceId) async {
    _items.removeWhere((n) => n.sourceId == sourceId);
    _emit();
    _scheduleSave();
  }

  /// Remove all dismissed + expired items (housekeeping).
  Future<void> purgeStale() async {
    final now = DateTime.now();
    _items.removeWhere((n) =>
        n.isDismissed ||
        (n.expiresAt != null && now.isAfter(n.expiresAt!)));
    _emit();
    _scheduleSave();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> loadFromDisk() async {
    if (kIsWeb) return;
    try {
      final raw = await UserScopedStorage.instance.readSecure(
        'in_app_notifications.json',
      );
      if (raw == null || raw.trim().isEmpty) {
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

      final loaded = <InAppNotification>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(
            InAppNotification.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (_) {
          // Skip malformed entries.
        }
      }

      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NotificationRepository] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _emit();
    }
  }

  Future<void> saveToDisk() async {
    if (kIsWeb) return;
    try {
      final payload = jsonEncode(
        _items.map((n) => n.toJson()).toList(growable: false),
      );
      await UserScopedStorage.instance.writeSecure(
        'in_app_notifications.json',
        payload,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NotificationRepository] saveToDisk failed: $error');
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

  // ── Internals ────────────────────────────────────────────────────────────

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
    _controller.add(List<InAppNotification>.unmodifiable(_items));
  }

  /// Returns only visible notifications, newest first.
  List<InAppNotification> _visible(List<InAppNotification> source) {
    final now = DateTime.now();
    final result = source.where((n) {
      if (n.isDismissed) return false;
      if (n.expiresAt != null && now.isAfter(n.expiresAt!)) return false;
      if (n.scheduledAt != null && now.isBefore(n.scheduledAt!)) return false;
      return true;
    }).toList();
    result.sort((a, b) {
      // Critical first, then by date
      final pc = b.priority.index.compareTo(a.priority.index);
      if (pc != 0) return pc;
      return b.createdAt.compareTo(a.createdAt);
    });
    return result;
  }
}
