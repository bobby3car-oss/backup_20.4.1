import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/user_profile_service.dart';
import '../../../domain/task_orchestrator_sync.dart';
import '../../../domain/timeline_engine.dart';
import '../../appointments/data/appointments_repository_sync.dart';
import '../../appointments/domain/appointment.dart';
import '../../appointments/domain/appointment_enums.dart';
import '../../doctor_invite/data/doctor_invite_service.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../medication/domain/medication_intake.dart';
import '../../organisation/data/organisation_service.dart';
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

  /// Returns the current user UID, or null if not authenticated.
  static String? _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('[BellaAction] Skipped – user not authenticated');
    }
    return uid;
  }

  /// Execute the given action. Returns an optional follow-up message.
  Future<String?> execute(BellaAction action) async {
    switch (action.type) {
      case BellaActionType.createAppointment:
        return _createAppointment(action.params);
      case BellaActionType.createTimelineTask:
        return _createTimelineTask(action.params);
      case BellaActionType.logVital:
        return _logVital(action.params);
      case BellaActionType.logMedication:
        await _logMedication(action.params);
        return null;
      case BellaActionType.logPain:
        await _logPain(action.params);
        return null;
      case BellaActionType.logWound:
        await _logWound(action.params);
        return null;
      case BellaActionType.createRedFlag:
        return _createRedFlag(action.params);
      case BellaActionType.rememberThis:
        await _rememberThis(action.params);
        return null;
      case BellaActionType.invitePatient:
        return _invitePatient(action.params);
      case BellaActionType.requestOrgStats:
        return _requestOrgStats(action.params);
      case BellaActionType.inviteDoctor:
        return _inviteDoctor(action.params);
      case BellaActionType.sendBroadcast:
        return _sendBroadcast(action.params);
      case BellaActionType.unknown:
        throw StateError('Unbekannter Bella-Aktionstyp');
    }
  }

  Future<String?> _createAppointment(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = _requireUid();
    if (uid == null) return null;
    final id = _bellaId();
    final startAt = _parseDate(p['date']) ?? now;

    final typeStr = (p['appointmentType'] ?? 'other').toString();
    final type = AppointmentType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => AppointmentType.other,
    );

    final role = await UserProfileService().getMyRole();
    final patientHint = (p['patientHint'] ?? '').toString().trim();
    final doctorOverrideUid = await _doctorOverrideUidForRole(role, uid);

    if (doctorOverrideUid != null) {
      if (patientHint.isEmpty) {
        throw StateError('Bitte einen Patienten angeben.');
      }

      final repo = DoctorPatientRepository(
        overrideDoctorUid: doctorOverrideUid == uid ? null : doctorOverrideUid,
      );
      final patient = await _resolveLinkedPatient(repo, patientHint);
      final actorName = await _currentActorLabel(role);
      final appointment = Appointment(
        id: id,
        ownerId: patient.uid,
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
        doctorName: actorName,
        locationName: p['locationName']?.toString(),
        preparation: p['preparation']?.toString(),
        createdBy: doctorOverrideUid,
        metadata: <String, dynamic>{
          'source': 'bella_ai',
          'patientHint': patientHint,
          'createdForPatient': true,
        },
      );

      await repo.createAppointmentForPatient(patient.uid, appointment);
      await repo.notifyPatientNewAppointment(
        patientId: patient.uid,
        title: appointment.title,
        startAt: startAt,
        doctorName: actorName,
      );
      debugPrint(
        '[BellaAction] Created appointment for patient: ${patient.displayName}',
      );
      return 'Termin für ${patient.displayName} angelegt: '
          '${appointment.title} am ${_formatDateTime(startAt)}.';
    }

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
      metadata: const <String, dynamic>{'source': 'bella_ai'},
    );

    await AppointmentsRepositorySync.instance.upsert(appointment);
    debugPrint('[BellaAction] Created appointment: ${appointment.title}');
    return 'Termin angelegt: ${appointment.title} am '
        '${_formatDateTime(startAt)}.';
  }

  Future<String?> _createTimelineTask(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = _requireUid();
    if (uid == null) return null;
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

    final role = await UserProfileService().getMyRole();
    final patientHint = (p['patientHint'] ?? '').toString().trim();
    final doctorOverrideUid = await _doctorOverrideUidForRole(role, uid);

    if (doctorOverrideUid != null) {
      if (patientHint.isEmpty) {
        throw StateError('Bitte einen Patienten angeben.');
      }
      final repo = DoctorPatientRepository(
        overrideDoctorUid: doctorOverrideUid == uid ? null : doctorOverrideUid,
      );
      final patient = await _resolveLinkedPatient(repo, patientHint);

      final data = <String, dynamic>{
        'id': id,
        'type': type.name,
        'title': (p['title'] ?? 'Aufgabe').toString(),
        'subtitle': (p['subtitle'] ?? '').toString(),
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'priority': priority.name,
        'state': 'planned',
        'deeplinkRoute': '',
        'metadata': {'source': 'bella_ai', 'createdBy': doctorOverrideUid},
        'createdAt': now.toUtc().toIso8601String(),
        'updatedAt': now.toUtc().toIso8601String(),
      };
      await FirebaseFirestore.instance
          .doc('patients/${patient.uid}/timeline/$id')
          .set(data);
      debugPrint('[BellaAction] Created timeline task for patient: ${patient.displayName}');
      return 'Aufgabe "${data['title']}" für ${patient.displayName} erstellt.';
    }

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
    return null;
  }

  Future<String?> _logVital(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = _requireUid();
    if (uid == null) return null;
    final id = _bellaId();

    final role = await UserProfileService().getMyRole();
    final patientHint = (p['patientHint'] ?? '').toString().trim();
    final doctorOverrideUid = await _doctorOverrideUidForRole(role, uid);

    if (doctorOverrideUid != null && patientHint.isNotEmpty) {
      final repo = DoctorPatientRepository(
        overrideDoctorUid: doctorOverrideUid == uid ? null : doctorOverrideUid,
      );
      final patient = await _resolveLinkedPatient(repo, patientHint);

      final data = <String, dynamic>{
        'id': id,
        'ownerId': patient.uid,
        'systolic': _parseInt(p['systolic']) ?? 120,
        'diastolic': _parseInt(p['diastolic']) ?? 80,
        'pulse': _parseInt(p['pulse']) ?? 70,
        'note': p['note']?.toString(),
        'createdAt': now.toUtc().toIso8601String(),
        'updatedAt': now.toUtc().toIso8601String(),
        'source': 'bella_ai',
        'createdBy': doctorOverrideUid,
      };
      if (p['temperature'] != null) data['temperature'] = _parseDouble(p['temperature']);
      if (p['oxygenSaturation'] != null) data['oxygenSaturation'] = _parseInt(p['oxygenSaturation']);
      if (p['weight'] != null) data['weight'] = _parseDouble(p['weight']);

      await FirebaseFirestore.instance
          .doc('patients/${patient.uid}/vitals/$id')
          .set(data);
      debugPrint('[BellaAction] Logged vital for patient: ${patient.displayName}');
      return 'Vitalwerte für ${patient.displayName} eingetragen: '
          '${data['systolic']}/${data['diastolic']}, Puls ${data['pulse']}.';
    }

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
    return null;
  }

  Future<void> _logMedication(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = _requireUid();
    if (uid == null) return;
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
    final uid = _requireUid();
    if (uid == null) return;
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

    final uid = _requireUid() ?? '';
    final entry = WoundEntry(
      id: id,
      ownerId: uid,
      createdAt: now,
      updatedAt: now,
      pain: (_parseInt(p['pain']) ?? 0).clamp(0, 10),
      note: (p['note'] ?? '').toString(),
      bodyLocation: p['bodyLocation']?.toString(),
      metadata: const {'source': 'bella_ai'},
    );

    await WoundRepositorySync.instance.upsert(entry);
    debugPrint('[BellaAction] Logged wound: ${entry.note}');
  }

  Future<String?> _createRedFlag(Map<String, dynamic> p) async {
    final now = DateTime.now();
    final uid = _requireUid();
    if (uid == null) return null;
    final id = _bellaId();

    final severityStr = (p['severity'] ?? 'yellow').toString();
    final severity = RedFlagSeverity.values.firstWhere(
      (e) => e.name == severityStr,
      orElse: () => RedFlagSeverity.yellow,
    );

    final role = await UserProfileService().getMyRole();
    final patientHint = (p['patientHint'] ?? '').toString().trim();
    final doctorOverrideUid = await _doctorOverrideUidForRole(role, uid);

    if (doctorOverrideUid != null && patientHint.isNotEmpty) {
      final repo = DoctorPatientRepository(
        overrideDoctorUid: doctorOverrideUid == uid ? null : doctorOverrideUid,
      );
      final patient = await _resolveLinkedPatient(repo, patientHint);

      final data = <String, dynamic>{
        'id': id,
        'ownerId': patient.uid,
        'severity': severityStr,
        'status': 'open',
        'source': 'manual',
        'title': (p['title'] ?? 'Warnung').toString(),
        'summary': (p['summary'] ?? '').toString(),
        'recommendedAction':
            (p['recommendedAction'] ?? 'Bitte kontaktiere dein medizinisches Team.').toString(),
        'createdAt': now.toUtc().toIso8601String(),
        'updatedAt': now.toUtc().toIso8601String(),
        'metadata': {'source': 'bella_ai', 'createdBy': doctorOverrideUid},
      };

      await FirebaseFirestore.instance
          .doc('patients/${patient.uid}/red_flags/$id')
          .set(data);
      debugPrint('[BellaAction] Created red flag for patient: ${patient.displayName}');
      return 'Warnung "${data['title']}" für ${patient.displayName} erstellt ($severityStr).';
    }

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
    return null;
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

  Future<String?> _invitePatient(Map<String, dynamic> p) async {
    final uid = _requireUid();
    if (uid == null) return null;
    final role = await UserProfileService().getMyRole();
    if (role != AppUserRole.doctor) {
      throw StateError('Patienteneinladungen sind nur für Ärzte verfügbar.');
    }

    final service = DoctorInviteService();
    final code = await service.getPermanentCode();
    final link = service.buildPermanentDeepLink(code);
    debugPrint('[BellaAction] Generated patient invite code');
    return 'Dauerhafter Patientencode bereit:\n'
        'Code: $code\n'
        'Link: $link';
  }

  Future<String?> _requestOrgStats(Map<String, dynamic> p) async {
    final uid = _requireUid();
    if (uid == null) return null;
    final role = await UserProfileService().getMyRole();
    if (role != AppUserRole.organisation) {
      throw StateError('Organisationsstatistiken sind nur für Organisationskonten verfügbar.');
    }

    final stats = await OrganisationService().getOrgStats();
    final phaseParts = <String>[
      'Prä-OP ${stats.patientsByPhase[PatientPhase.preOp] ?? 0}',
      'OP-Tag ${stats.patientsByPhase[PatientPhase.opDay] ?? 0}',
      'Post-OP ${stats.patientsByPhase[PatientPhase.postOp] ?? 0}',
      'Entlassen ${stats.patientsByPhase[PatientPhase.discharged] ?? 0}',
    ];
    return 'Aktuelle Organisationsstatistik:\n'
        '- Patienten gesamt: ${stats.totalPatients}\n'
        '- Davon aktiv (7 Tage): ${stats.activePatients}\n'
        '- Phasen: ${phaseParts.join(' | ')}';
  }

  Future<String?> _inviteDoctor(Map<String, dynamic> p) async {
    final uid = _requireUid();
    if (uid == null) return null;
    final role = await UserProfileService().getMyRole();
    if (role != AppUserRole.organisation) {
      throw StateError('Arzteinladungen sind nur für Organisationskonten verfügbar.');
    }

    final email = (p['email'] ?? '').toString().trim();
    final code = await OrganisationService().getInviteCode();
    final prefix = email.isEmpty
        ? 'Ein Organisations-Einladungscode ist bereit:'
        : 'Ein Organisations-Einladungscode für $email ist bereit:';
    return '$prefix\nCode: $code\n'
        'Der Arzt kann den Code in der App beim Organisationsbeitritt verwenden.';
  }

  Future<String?> _sendBroadcast(Map<String, dynamic> p) async {
    final uid = _requireUid();
    if (uid == null) return null;
    final role = await UserProfileService().getMyRole();

    // Determine the acting doctor UID or allow org role directly.
    final actorUid = role == AppUserRole.organisation
        ? uid
        : await _doctorOverrideUidForRole(role, uid);
    if (actorUid == null) {
      throw StateError('Broadcasts sind nur für Ärzte, Mitarbeiter und Organisationen verfügbar.');
    }

    final title = (p['title'] ?? 'Nachricht').toString();
    final body = (p['body'] ?? '').toString();
    final priority = (p['priority'] ?? 'normal').toString();

    final repo = DoctorPatientRepository(
      overrideDoctorUid: actorUid == uid ? null : actorUid,
    );
    final patients = await repo.getLinkedPatientsOnce();
    if (patients.isEmpty) {
      throw StateError('Keine verknüpften Patienten gefunden.');
    }

    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();

    for (final patient in patients) {
      final notifId = 'broadcast_${now.millisecondsSinceEpoch}_${patient.uid}';
      final ref = FirebaseFirestore.instance
          .collection('patients/${patient.uid}/notifications')
          .doc(notifId);
      batch.set(ref, {
        'id': notifId,
        'type': 'broadcast',
        'title': title,
        'body': body,
        'priority': priority,
        'senderId': actorUid,
        'read': false,
        'createdAt': now.toUtc().toIso8601String(),
      });
    }

    await batch.commit();
    debugPrint('[BellaAction] Broadcast sent to ${patients.length} patients');
    return 'Broadcast "$title" an ${patients.length} Patienten gesendet.';
  }

  Future<String?> _doctorOverrideUidForRole(AppUserRole role, String uid) async {
    if (role == AppUserRole.doctor) return uid;
    if (role != AppUserRole.staff) return null;

    final snap = await FirebaseFirestore.instance.doc('users/$uid').get();
    final staffOf = snap.data()?['staffOf']?.toString().trim();
    if (staffOf == null || staffOf.isEmpty) {
      throw StateError('Keinem Arzt zugeordnet.');
    }
    return staffOf;
  }

  Future<LinkedPatient> _resolveLinkedPatient(
    DoctorPatientRepository repo,
    String patientHint,
  ) async {
    final patients = await repo.getLinkedPatientsOnce();
    if (patients.isEmpty) {
      throw StateError('Keine verknüpften Patienten gefunden.');
    }

    final match = _matchLinkedPatient(patients, patientHint);
    if (match == null) {
      throw StateError('Kein eindeutiger Patient für "$patientHint" gefunden.');
    }
    return match;
  }

  LinkedPatient? _matchLinkedPatient(
    List<LinkedPatient> patients,
    String hint,
  ) {
    final query = _normaliseForMatch(hint);
    if (query.isEmpty) return null;

    List<LinkedPatient> exactMatches() => patients.where((patient) {
      final values = [patient.displayName, patient.uid]
          .map(_normaliseForMatch);
      return values.any((value) => value == query);
    }).toList(growable: false);

    List<LinkedPatient> prefixMatches() => patients.where((patient) {
      final values = [patient.displayName]
          .map(_normaliseForMatch);
      return values.any((value) => value.startsWith(query));
    }).toList(growable: false);

    List<LinkedPatient> containsMatches() => patients.where((patient) {
      final values = [patient.displayName]
          .map(_normaliseForMatch);
      return values.any((value) => value.contains(query));
    }).toList(growable: false);

    final exact = exactMatches();
    if (exact.length == 1) return exact.first;
    if (exact.length > 1) return null;

    final prefix = prefixMatches();
    if (prefix.length == 1) return prefix.first;
    if (prefix.length > 1) return null;

    final contains = containsMatches();
    if (contains.length == 1) return contains.first;
    return null;
  }

  Future<String> _currentActorLabel(AppUserRole role) async {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim() ?? '';
    if (email.isNotEmpty) return email;

    return switch (role) {
      AppUserRole.staff => 'Praxisteam',
      AppUserRole.organisation => 'Organisation',
      AppUserRole.admin => 'Admin',
      _ => 'Behandlungsteam',
    };
  }

  static String _normaliseForMatch(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9@._\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final yyyy = local.year.toString().padLeft(4, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$dd.$mm.$yyyy $hh:$min';
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
