import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/task_orchestrator_sync.dart';
import '../../../domain/timeline_engine.dart';
import '../../../notifications/local_notifications.dart';
import '../../../notifications/notification_repository.dart';
import '../../../notifications/notification_service.dart';
import '../../../security/field_encryption_service.dart';
import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import 'appointments_repository.dart';
import 'appointments_repository_local.dart';

class AppointmentsRepositorySync implements AppointmentsRepository {
  static final AppointmentsRepositorySync instance =
      AppointmentsRepositorySync._internal();

  factory AppointmentsRepositorySync() => instance;

  AppointmentsRepositorySync._internal({
    AppointmentsRepositoryLocal? local,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirebaseAuth? firebaseAuth,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? AppointmentsRepositoryLocal.instance,
       _queue =
           queue ?? SyncQueueLocal(fileName: 'appointments_sync_queue.json'),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
    if (!_initialPullTriggered) {
      _initialPullTriggered = true;
      unawaited(_initialLoad());
    }
  }

  final AppointmentsRepositoryLocal _local;
  final SyncQueueLocal _queue;
  final FirebaseAuth _firebaseAuth;
  final FirestoreClient _firestoreClient;
  late final SyncService _syncService;

  bool _initialPullTriggered = false;

  Future<void> _initialLoad() async {
    await _local.switchUser(_patientId);
    await pullLatest();
  }

  @override
  Stream<List<Appointment>> watchAll() => _local.watchAll();

  @override
  Stream<List<Appointment>> watchRange(DateTime from, DateTime to) {
    return _local.watchRange(from, to);
  }

  @override
  Future<void> upsert(Appointment appointment) async {
    final now = DateTime.now();
    final updatedAtIso = now.toIso8601String();
    final localItem = appointment.copyWith(
      updatedAt: now,
      metadata: <String, dynamic>{
        ...appointment.metadata,
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      },
    );
    await _local.upsert(localItem);
    await LocalNotifications.scheduleForAppointment(localItem);
    unawaited(NotificationService.instance.onAppointmentChanged(localItem));
    await _syncTimelineForAppointment(localItem);

    final patientId = _patientId;
    if (patientId == null) return;

    final payload = <String, dynamic>{
      ...localItem.toJson(),
      'updatedAt': updatedAtIso,
      'clientUpdatedAt': updatedAtIso,
    };

    // Encrypt identifying fields before syncing to Firestore.
    final encPayload = FieldEncryptionService.instance
        .encryptFields(patientId, payload, kEncryptedAppointmentFields);

    try {
      await _queue.enqueue(
        SyncOp(
          id: 'appointment_upsert_${localItem.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$patientId/appointments',
          docId: localItem.id,
          type: SyncOpType.upsert,
          payload: encPayload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[AppointmentsRepositorySync] upsert enqueue failed: $error',
        );
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    await LocalNotifications.cancelForAppointment(id);
    unawaited(NotificationRepository.instance.deleteBySourceId(id));
    await _cancelTimelineForAppointment(id);

    final patientId = _patientId;
    if (patientId == null) return;

    try {
      final now = DateTime.now();
      await _queue.enqueue(
        SyncOp(
          id: 'appointment_delete_${id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$patientId/appointments',
          docId: id,
          type: SyncOpType.delete,
          payload: const <String, dynamic>{},
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[AppointmentsRepositorySync] delete enqueue failed: $error',
        );
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<Appointment?> getById(String id) => _local.getById(id);

  @override
  Future<void> loadFromDisk() => _local.loadFromDisk();

  @override
  Future<void> saveToDisk() => _local.saveToDisk();

  @override
  Future<void> switchUser(String? userId) => _local.switchUser(userId);

  Future<void> pullLatest({int? limit}) async {
    final patientId = _patientId;
    if (patientId == null) return;

    try {
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$patientId/appointments',
        limit: limit,
      );
      if (remoteDocs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, Appointment>{
        for (final item in localItems) item.id: item,
      };

      for (final remoteDoc in remoteDocs) {
        var remoteData = <String, dynamic>{
          ...remoteDoc.data,
          'id': remoteDoc.id,
        };
        // Decrypt identifying fields from Firestore.
        remoteData = FieldEncryptionService.instance
            .decryptFields(patientId, remoteData, kEncryptedAppointmentFields);
        final remoteUpdatedAt = _readUpdatedAt(remoteData);
        final localItem = localById[remoteDoc.id];
        final localUpdatedAt = _localUpdatedAt(localItem);

        if (localItem != null && !remoteUpdatedAt.isAfter(localUpdatedAt)) {
          continue;
        }

        if (remoteData['deletedAt'] != null) {
          await _local.delete(remoteDoc.id);
          await LocalNotifications.cancelForAppointment(remoteDoc.id);
          continue;
        }

        final mergedMetadata = <String, dynamic>{
          ...(remoteData['metadata'] is Map
              ? Map<String, dynamic>.from(remoteData['metadata'] as Map)
              : const <String, dynamic>{}),
          if (remoteData['updatedAt'] != null)
            'updatedAt': remoteData['updatedAt'].toString(),
          if (remoteData['clientUpdatedAt'] != null)
            'clientUpdatedAt': remoteData['clientUpdatedAt'].toString(),
        };

        final remoteItem = Appointment.fromJson(<String, dynamic>{
          ...remoteData,
          'metadata': mergedMetadata,
        });
        await _local.upsert(remoteItem);
        await LocalNotifications.scheduleForAppointment(remoteItem);
        await _syncTimelineForAppointment(remoteItem);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AppointmentsRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  DateTime _localUpdatedAt(Appointment? appointment) {
    if (appointment == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return _parseIso(appointment.metadata['clientUpdatedAt']?.toString()) ??
        _parseIso(appointment.metadata['updatedAt']?.toString()) ??
        appointment.updatedAt;
  }

  DateTime _readUpdatedAt(Map<String, dynamic> data) {
    return _parseIso(data['clientUpdatedAt']?.toString()) ??
        _parseIso(data['updatedAt']?.toString()) ??
        _parseIso(data['createdAt']?.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _parseIso(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  Future<void> _syncTimelineForAppointment(Appointment appointment) async {
    final now = DateTime.now();
    final timelineState = _timelineStateFor(appointment, now);
    final subtitle = _timelineSubtitleFor(appointment);
    final itemId = 'appt_${appointment.id}';

    await TaskOrchestratorSync.instance.upsert(
      TimelineItem(
        id: itemId,
        type: TaskType.appointment,
        title: appointment.title,
        subtitle: subtitle,
        scheduledAt: appointment.startAt,
        dueAt: appointment.startAt,
        priority: TaskPriority.normal,
        state: timelineState,
        deeplinkRoute: '/appointments',
        metadata: <String, dynamic>{
          ...appointment.metadata,
          'appointmentId': appointment.id,
          'ownerId': appointment.ownerId,
        },
        createdAt: appointment.createdAt,
        updatedAt: appointment.updatedAt,
        doneAt: timelineState == TaskState.done ? now : null,
        skippedAt: timelineState == TaskState.skipped ? now : null,
      ),
    );
  }

  Future<void> _cancelTimelineForAppointment(String appointmentId) async {
    await TaskOrchestratorSync.instance.deleteItem('appt_$appointmentId');
  }

  TaskState _timelineStateFor(Appointment appointment, DateTime now) {
    if (appointment.status == AppointmentStatus.done ||
        appointment.status == AppointmentStatus.completed) {
      return TaskState.done;
    }
    if (appointment.status == AppointmentStatus.canceled ||
        appointment.status == AppointmentStatus.declined) {
      return TaskState.skipped;
    }
    if (!appointment.startAt.isAfter(now)) {
      return TaskState.due;
    }
    return TaskState.planned;
  }

  String _timelineSubtitleFor(Appointment appointment) {
    final location = appointment.locationName?.trim() ?? '';
    if (location.isNotEmpty) return location;
    final notes = appointment.notes.trim();
    if (notes.isNotEmpty) return notes;
    return _appointmentTypeLabel(appointment.type);
  }

  String _appointmentTypeLabel(AppointmentType type) {
    return switch (type) {
      AppointmentType.followUp => 'Nachsorge',
      AppointmentType.physio => 'Physio',
      AppointmentType.surgery => 'Operation',
      AppointmentType.call => 'Telefonat',
      AppointmentType.imaging => 'Bildgebung',
      AppointmentType.other => 'Termin',
    };
  }
}
