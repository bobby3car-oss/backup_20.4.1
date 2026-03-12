import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/task_orchestrator_sync.dart';
import '../../../domain/timeline_engine.dart';
import '../../appointments/data/appointments_repository_sync.dart';
import '../../appointments/domain/appointment.dart';
import '../../appointments/domain/appointment_enums.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../medication/domain/medication_intake.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../pain/domain/pain_entry.dart';
import '../../red_flags/data/red_flag_repository_sync.dart';
import '../../red_flags/domain/red_flag.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../vitals/domain/vital_entry.dart';
import '../../wound/data/wound_repository_sync.dart';
import '../../wound/domain/wound_entry.dart';
import 'bella_action.dart';

String _bellaId() {
  final now = DateTime.now();
  return 'bella_${now.millisecondsSinceEpoch}';
}

/// Executes confirmed Bella actions by writing to the appropriate repositories.
class BellaActionExecutor {
  const BellaActionExecutor();

  /// Execute the given action. Throws on failure.
  Future<void> execute(BellaAction action) async {
    switch (action.type) {
      case BellaActionType.createAppointment:
        await _createAppointment(action.params);
      case BellaActionType.createTimelineTask:
        await _createTimelineTask(action.params);
      case BellaActionType.logVital:
        await _logVital(action.params);
      case BellaActionType.logMedication:
        await _logMedication(action.params);
      case BellaActionType.logPain:
        await _logPain(action.params);
      case BellaActionType.logWound:
        await _logWound(action.params);
      case BellaActionType.createRedFlag:
        await _createRedFlag(action.params);
      case BellaActionType.rememberThis:
        await _rememberThis(action.params);
    }
  }

  Future<void> _createAppointment(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'bella';
    final id = _bellaId();
    final startAt = _parseDate(p['date']) ?? now;

    final typeStr = (p['appointmentType'] ?? 'other').toString();
    final type = AppointmentType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => AppointmentType.other,
    );

    final appointment = Appointment(
      id: id,
      ownerId: uid,
      title: (p['title'] ?? 'Termin').toString(),
      notes: (p['notes'] ?? '').toString(),
      type: type,
      status: AppointmentStatus.planned,
      startAt: startAt,
      allDay: false,
      reminderPreset: ReminderPreset.hour1,
      repeatRule: RepeatRule.none,
      createdAt: now,
      updatedAt: now,
      doctorName: p['doctorName']?.toString(),
      locationName: p['locationName']?.toString(),
      preparation: p['preparation']?.toString(),
      metadata: const {'source': 'bella_ai'},
    );

    await AppointmentsRepositorySync.instance.upsert(appointment);
    debugPrint('[BellaAction] Created appointment: ${appointment.title}');
  }

  Future<void> _createTimelineTask(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final id = _bellaId();
    final scheduledAt = _parseDate(p['date']) ?? now;

    final typeStr = (p['taskType'] ?? 'custom').toString();
    final type = TaskType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => TaskType.custom,
    );

    final priorityStr = (p['priority'] ?? 'normal').toString();
    final priority = TaskPriority.values.firstWhere(
      (e) => e.name == priorityStr,
      orElse: () => TaskPriority.normal,
    );

    final item = TimelineItem(
      id: id,
      type: type,
      title: (p['title'] ?? 'Aufgabe').toString(),
      subtitle: (p['subtitle'] ?? '').toString(),
      scheduledAt: scheduledAt,
      priority: priority,
      state: TaskState.planned,
      deeplinkRoute: '',
      metadata: const {'source': 'bella_ai'},
      createdAt: now,
      updatedAt: now,
    );

    await TaskOrchestratorSync.instance.upsert(item);
    debugPrint('[BellaAction] Created timeline task: ${item.title}');
  }

  Future<void> _logVital(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'bella';
    final id = _bellaId();

    final entry = VitalEntry(
      id: id,
      ownerId: uid,
      systolic: _parseInt(p['systolic']) ?? 120,
      diastolic: _parseInt(p['diastolic']) ?? 80,
      pulse: _parseInt(p['pulse']) ?? 70,
      temperature: _parseDouble(p['temperature']),
      oxygenSaturation: _parseInt(p['oxygenSaturation']),
      weight: _parseDouble(p['weight']),
      note: p['note']?.toString(),
      createdAt: now,
      updatedAt: now,
      source: 'bella_ai',
    );

    await VitalRepositoryLocal.instance.upsert(entry);
    debugPrint('[BellaAction] Logged vital: ${entry.systolic}/${entry.diastolic}');
  }

  Future<void> _logMedication(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'bella';
    final id = _bellaId();

    final entry = MedicationIntake(
      id: id,
      ownerId: uid,
      name: (p['name'] ?? 'Medikament').toString(),
      dose: p['dose']?.toString(),
      takenAt: _parseDate(p['takenAt']) ?? now,
      createdAt: now,
      updatedAt: now,
      metadata: const {'source': 'bella_ai'},
    );

    await MedicationRepositoryLocal.instance.upsert(entry);
    debugPrint('[BellaAction] Logged medication: ${entry.name}');
  }

  Future<void> _logPain(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'bella';
    final id = _bellaId();

    final painLevel = (_parseInt(p['painLevel']) ?? 5).clamp(0, 10);

    final regionStr = p['bodyRegion']?.toString();
    final bodyRegion = regionStr != null
        ? BodyRegion.values
            .where((e) => e.name == regionStr)
            .firstOrNull
        : null;

    final typeStr = p['painType']?.toString();
    final painType = typeStr != null
        ? PainType.values
            .where((e) => e.name == typeStr)
            .firstOrNull
        : null;

    final entry = PainEntry(
      id: id,
      ownerId: uid,
      occurredAt: now,
      painLevel: painLevel,
      note: (p['note'] ?? '').toString(),
      trigger: p['trigger']?.toString(),
      painType: painType,
      bodyRegion: bodyRegion,
      createdAt: now,
      updatedAt: now,
      metadata: const {'source': 'bella_ai'},
    );

    await PainRepositoryLocal.instance.upsert(entry);
    debugPrint('[BellaAction] Logged pain: level $painLevel');
  }

  Future<void> _logWound(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final id = WoundEntry.generateId(now);

    final entry = WoundEntry(
      id: id,
      createdAt: now,
      pain: (_parseInt(p['pain']) ?? 0).clamp(0, 10),
      note: (p['note'] ?? '').toString(),
      bodyLocation: p['bodyLocation']?.toString(),
      metadata: const {'source': 'bella_ai'},
    );

    await WoundRepositorySync.instance.upsert(entry);
    debugPrint('[BellaAction] Logged wound: ${entry.note}');
  }

  Future<void> _createRedFlag(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'bella';
    final id = _bellaId();

    final severityStr = (p['severity'] ?? 'yellow').toString();
    final severity = RedFlagSeverity.values.firstWhere(
      (e) => e.name == severityStr,
      orElse: () => RedFlagSeverity.yellow,
    );

    final flag = RedFlag(
      id: id,
      ownerId: uid,
      severity: severity,
      status: RedFlagStatus.open,
      source: RedFlagSource.manual,
      title: (p['title'] ?? 'Warnung').toString(),
      summary: (p['summary'] ?? '').toString(),
      recommendedAction:
          (p['recommendedAction'] ?? 'Bitte kontaktiere dein medizinisches Team.').toString(),
      createdAt: now,
      updatedAt: now,
      metadata: const {'source': 'bella_ai'},
    );

    await RedFlagRepositorySync.instance.upsert(flag);
    debugPrint('[BellaAction] Created red flag: ${flag.title}');
  }

  Future<void> _rememberThis(Map<String, dynamic> p) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final key = (p['key'] ?? 'notiz').toString().replaceAll(RegExp(r'[^a-zA-Z0-9_äöüÄÖÜß]'), '_');
    final value = (p['value'] ?? '').toString();
    if (value.isEmpty) return;

    final col = FirebaseFirestore.instance.collection('users/$uid/bella_memory');

    // Enforce max 10 entries: delete oldest if at limit.
    final existing = await col.orderBy('updatedAt', descending: true).limit(11).get();
    if (existing.docs.length >= 10) {
      // Delete the oldest entries beyond 9 (we're about to add/update one).
      final toDelete = existing.docs.skip(9);
      for (final doc in toDelete) {
        await doc.reference.delete();
      }
    }

    await col.doc(key).set({
      'value': value,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
    debugPrint('[BellaAction] Remembered: $key = $value');
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static double? _parseDouble(Object? raw) {
    if (raw is double) return raw;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }
}
