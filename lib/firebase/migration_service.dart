import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/timeline_engine.dart';
import 'firebase_paths.dart';
import 'timeline_repository.dart';

/// Handles one-time migration of local timeline data to Firestore.
class MigrationService {
  MigrationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    TimelineRepository? timelineRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _timelineRepository = timelineRepository ?? TimelineRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final TimelineRepository _timelineRepository;

  /// Checks if migration has already been performed for the current user.
  /// If not, reads local timeline_items.json and uploads to Firestore.
  Future<void> migrateTimelineIfNeeded() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Check if already migrated.
    final userDoc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    final data = userDoc.data();
    if (data != null && data['timelineMigratedAt'] != null) {
      if (kDebugMode) {
        debugPrint('[MigrationService] Timeline already migrated for $uid');
      }
      return;
    }

    // Read local file.
    final items = await _readLocalTimelineItems();
    if (items.isEmpty) {
      if (kDebugMode) {
        debugPrint('[MigrationService] No local items to migrate');
      }
      // Mark as migrated even if empty to avoid re-checking.
      await _markMigrated(uid);
      return;
    }

    // Upload to Firestore.
    try {
      await _timelineRepository.migrateLocalItems(items);
      await _markMigrated(uid);
      if (kDebugMode) {
        debugPrint(
            '[MigrationService] Successfully migrated ${items.length} items');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MigrationService] Migration failed: $error');
        debugPrint('$stackTrace');
      }
      // Don't mark as migrated on failure — will retry next launch.
    }
  }

  Future<List<TimelineItem>> _readLocalTimelineItems() async {
    if (kIsWeb) return const [];
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/timeline_items.json');

      if (!await file.exists()) return const [];

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return const [];

      final decoded = jsonDecode(raw);
      Object? itemsPayload = decoded;
      if (decoded is Map<String, dynamic>) {
        itemsPayload = decoded['items'];
      }

      if (itemsPayload is! List) return const [];

      final items = <TimelineItem>[];
      for (final entry in itemsPayload) {
        if (entry is Map) {
          try {
            items.add(
                TimelineItem.fromJson(Map<String, dynamic>.from(entry)));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[MigrationService] Skipped malformed entry: $e');
            }
          }
        }
      }
      return items;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
            '[MigrationService] Failed to read local file: $error');
      }
      return const [];
    }
  }

  Future<void> _markMigrated(String uid) async {
    await _firestore.doc(FirestorePaths.userDoc(uid)).set(
      <String, dynamic>{
        'timelineMigratedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
