import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../appointments/data/appointments_repository_sync.dart';
import '../appointments/domain/appointment.dart';
import '../documents/data/documents_repository_local.dart';
import '../documents/domain/document_item.dart';
import '../pain/data/pain_repository_sync.dart';
import '../pain/domain/pain_entry.dart';
import '../warnings/data/warnings_repository_sync.dart';
import '../warnings/domain/warning_check.dart';
import '../wound/data/wound_repository_sync.dart';
import '../wound/domain/wound_entry.dart';
import '../../domain/task_orchestrator.dart';
import '../../domain/timeline_engine.dart';

enum ReportLight { green, yellow, red, unknown }

class DoctorReportData {
  const DoctorReportData({
    required this.patientName,
    required this.patientEmail,
    required this.patientBirthDate,
    required this.patientDiagnosis,
    required this.opDate,
    required this.timelineTodayCount,
    required this.timelineOverdueCount,
    required this.painSummary,
    required this.woundSummary,
    required this.upcomingAppointments,
    required this.warnStatus,
    required this.latestDocuments,
    required this.unavailableSections,
  });

  final String? patientName;
  final String? patientEmail;
  final String? patientBirthDate;
  final String? patientDiagnosis;
  final DateTime? opDate;
  final int timelineTodayCount;
  final int timelineOverdueCount;
  final PainSummary? painSummary;
  final WoundSummary? woundSummary;
  final List<Appointment> upcomingAppointments;
  final ReportLight warnStatus;
  final List<DocumentItem> latestDocuments;
  final List<String> unavailableSections;
}

class PainSummary {
  const PainSummary({
    required this.current,
    required this.min,
    required this.max,
    required this.latestEntries,
  });

  final int current;
  final int min;
  final int max;
  final List<PainEntry> latestEntries;
}

class WoundSummary {
  const WoundSummary({required this.latestEntries});

  final List<WoundEntry> latestEntries;
}

class DoctorReportBuilder {
  DoctorReportBuilder({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    AppointmentsRepositorySync? appointmentsRepository,
    PainRepositorySync? painRepository,
    WoundRepositorySync? woundRepository,
    WarningsRepositorySync? warningsRepository,
    DocumentsRepositoryLocal? documentsRepository,
    TaskOrchestrator? orchestrator,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _appointmentsRepository =
           appointmentsRepository ?? AppointmentsRepositorySync.instance,
       _painRepository = painRepository ?? PainRepositorySync.instance,
       _woundRepository = woundRepository ?? WoundRepositorySync.instance,
       _warningsRepository =
           warningsRepository ?? WarningsRepositorySync.instance,
       _documentsRepository =
           documentsRepository ?? DocumentsRepositoryLocal.instance,
       _orchestrator = orchestrator ?? TaskOrchestrator();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final AppointmentsRepositorySync _appointmentsRepository;
  final PainRepositorySync _painRepository;
  final WoundRepositorySync _woundRepository;
  final WarningsRepositorySync _warningsRepository;
  final DocumentsRepositoryLocal _documentsRepository;
  final TaskOrchestrator _orchestrator;

  Future<DoctorReportData> build() async {
    final unavailable = <String>[];
    String? patientName;
    String? patientEmail;
    String? patientBirthDate;
    String? patientDiagnosis;
    DateTime? opDate;
    int timelineTodayCount = 0;
    int timelineOverdueCount = 0;
    PainSummary? painSummary;
    WoundSummary? woundSummary;
    List<Appointment> upcomingAppointments = const <Appointment>[];
    List<DocumentItem> latestDocuments = const <DocumentItem>[];
    ReportLight warnStatus = ReportLight.unknown;

    final uid = _auth.currentUser?.uid;
    patientEmail = _auth.currentUser?.email;
    patientName = _auth.currentUser?.displayName;
    if (uid == null || uid.isEmpty) {
      unavailable.add('Patient Basisdaten');
      unavailable.add('OP Datum');
      unavailable.add('Timeline');
      unavailable.add('Schmerztagebuch');
      unavailable.add('Wunddoku');
      unavailable.add('Termine');
      unavailable.add('Warnzeichen');
      unavailable.add('Dokumente');
      return DoctorReportData(
        patientName: patientName,
        patientEmail: patientEmail,
        patientBirthDate: patientBirthDate,
        patientDiagnosis: patientDiagnosis,
        opDate: opDate,
        timelineTodayCount: timelineTodayCount,
        timelineOverdueCount: timelineOverdueCount,
        painSummary: painSummary,
        woundSummary: woundSummary,
        upcomingAppointments: upcomingAppointments,
        warnStatus: warnStatus,
        latestDocuments: latestDocuments,
        unavailableSections: unavailable,
      );
    }

    try {
      final userDoc = await _firestore.doc('users/$uid').get();
      final patientDoc = await _firestore.doc('patients/$uid').get();
      final user = userDoc.data() ?? const <String, dynamic>{};
      final patient = patientDoc.data() ?? const <String, dynamic>{};
      patientName = _stringOrNull(user['displayName']) ?? patientName;
      patientEmail = _stringOrNull(user['email']) ?? patientEmail;
      patientBirthDate = _stringOrNull(
        patient['birthDate'] ?? user['birthDate'],
      );
      patientDiagnosis = _stringOrNull(
        patient['diagnosis'] ?? user['diagnosis'],
      );
    } catch (_) {
      unavailable.add('Patient Basisdaten');
    }

    try {
      final now = DateTime.now();
      final timeline = await _orchestrator
          .watch(
            from: now.subtract(const Duration(days: 365)),
            to: now.add(const Duration(days: 365)),
          )
          .first;

      final todayOnly = DateTime(now.year, now.month, now.day);
      for (final item in timeline) {
        final state = computeState(item, now);
        final day = DateTime(
          item.scheduledAt.year,
          item.scheduledAt.month,
          item.scheduledAt.day,
        );
        if (day == todayOnly &&
            state != TaskState.done &&
            state != TaskState.skipped) {
          timelineTodayCount++;
        }
        if (state == TaskState.due) {
          timelineOverdueCount++;
        }
      }

      final opDayItems =
          timeline
              .where((item) => item.metadata['phase']?.toString() == 'opday')
              .toList(growable: false)
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      if (opDayItems.isNotEmpty) {
        opDate = DateTime(
          opDayItems.first.scheduledAt.year,
          opDayItems.first.scheduledAt.month,
          opDayItems.first.scheduledAt.day,
        );
      }
    } catch (_) {
      unavailable.add('Timeline');
      unavailable.add('OP Datum');
    }

    try {
      await _painRepository.loadFromDisk();
      await _painRepository.pullLatest();
      final all = await _painRepository.watchAll().first;
      final now = DateTime.now();
      final since = now.subtract(const Duration(days: 7));
      final sevenDays =
          all
              .where((entry) => !entry.occurredAt.isBefore(since))
              .toList(growable: false)
            ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      if (sevenDays.isNotEmpty) {
        final levels = sevenDays
            .map((e) => e.painLevel)
            .toList(growable: false);
        final min = levels.reduce((a, b) => a < b ? a : b);
        final max = levels.reduce((a, b) => a > b ? a : b);
        painSummary = PainSummary(
          current: sevenDays.first.painLevel,
          min: min,
          max: max,
          latestEntries: sevenDays.take(5).toList(growable: false),
        );
      }
    } catch (_) {
      unavailable.add('Schmerztagebuch');
    }

    try {
      await _woundRepository.loadFromDisk();
      await _woundRepository.pullLatest();
      final all = await _woundRepository.watchAll().first;
      final top3 = all.take(3).toList(growable: false);
      if (top3.isNotEmpty) {
        woundSummary = WoundSummary(latestEntries: top3);
      }
    } catch (_) {
      unavailable.add('Wunddoku');
    }

    try {
      await _appointmentsRepository.loadFromDisk();
      await _appointmentsRepository.pullLatest();
      final all = await _appointmentsRepository.watchAll().first;
      final now = DateTime.now();
      final until = now.add(const Duration(days: 14));
      upcomingAppointments =
          all
              .where(
                (a) => !a.startAt.isBefore(now) && !a.startAt.isAfter(until),
              )
              .toList(growable: false)
            ..sort((a, b) => a.startAt.compareTo(b.startAt));
    } catch (_) {
      unavailable.add('Termine');
    }

    try {
      await _documentsRepository.loadFromDisk();
      final all = await _documentsRepository.watchAll().first;
      latestDocuments = all.take(3).toList(growable: false);
    } catch (_) {
      unavailable.add('Dokumente');
    }

    try {
      final latestWarning = await _warningsRepository.loadLatest();
      if (latestWarning != null) {
        warnStatus = _fromWarningLevel(latestWarning.level);
      } else {
        warnStatus = _deriveWarnStatus(
          painSummary: painSummary,
          woundSummary: woundSummary,
          timelineOverdueCount: timelineOverdueCount,
        );
      }
    } catch (_) {
      warnStatus = _deriveWarnStatus(
        painSummary: painSummary,
        woundSummary: woundSummary,
        timelineOverdueCount: timelineOverdueCount,
      );
    }
    if (warnStatus == ReportLight.unknown) unavailable.add('Warnzeichen');

    return DoctorReportData(
      patientName: patientName,
      patientEmail: patientEmail,
      patientBirthDate: patientBirthDate,
      patientDiagnosis: patientDiagnosis,
      opDate: opDate,
      timelineTodayCount: timelineTodayCount,
      timelineOverdueCount: timelineOverdueCount,
      painSummary: painSummary,
      woundSummary: woundSummary,
      upcomingAppointments: upcomingAppointments,
      warnStatus: warnStatus,
      latestDocuments: latestDocuments,
      unavailableSections: unavailable,
    );
  }

  ReportLight _deriveWarnStatus({
    required PainSummary? painSummary,
    required WoundSummary? woundSummary,
    required int timelineOverdueCount,
  }) {
    if (painSummary == null &&
        woundSummary == null &&
        timelineOverdueCount == 0) {
      return ReportLight.unknown;
    }
    final pain = painSummary?.current ?? 0;
    if (pain >= 8 || timelineOverdueCount >= 5) return ReportLight.red;
    if (pain >= 5 || timelineOverdueCount >= 2) return ReportLight.yellow;
    return ReportLight.green;
  }

  ReportLight _fromWarningLevel(WarningLevel level) {
    return switch (level) {
      WarningLevel.green => ReportLight.green,
      WarningLevel.yellow => ReportLight.yellow,
      WarningLevel.red => ReportLight.red,
    };
  }

  String buildMarkdown(DoctorReportData data) {
    final buffer = StringBuffer();
    buffer.writeln('# Arztbericht (MVP)');
    buffer.writeln();
    buffer.writeln('## Patient');
    buffer.writeln('- Name: ${data.patientName ?? "Nicht verfügbar"}');
    buffer.writeln('- E-Mail: ${data.patientEmail ?? "Nicht verfügbar"}');
    buffer.writeln(
      '- Geburtsdatum: ${data.patientBirthDate ?? "Nicht verfügbar"}',
    );
    buffer.writeln('- Diagnose: ${data.patientDiagnosis ?? "Nicht verfügbar"}');
    buffer.writeln();
    buffer.writeln('## OP');
    buffer.writeln('- OP Datum: ${_formatDate(data.opDate)}');
    buffer.writeln();
    buffer.writeln('## Timeline');
    buffer.writeln('- Heute offen: ${data.timelineTodayCount}');
    buffer.writeln('- Überfällig: ${data.timelineOverdueCount}');
    buffer.writeln();
    buffer.writeln('## Schmerztagebuch (7 Tage)');
    if (data.painSummary == null) {
      buffer.writeln('- Nicht verfügbar');
    } else {
      final pain = data.painSummary!;
      buffer.writeln('- Aktuell: ${pain.current}/10');
      buffer.writeln('- Min/Max: ${pain.min}/${pain.max}');
      for (final entry in pain.latestEntries) {
        buffer.writeln(
          '- ${_formatDateTime(entry.occurredAt)} · ${entry.painLevel}/10 · ${entry.note.trim().isEmpty ? "ohne Notiz" : entry.note.trim()}',
        );
      }
    }
    buffer.writeln();
    buffer.writeln('## Wunddoku (letzte 3)');
    if (data.woundSummary == null) {
      buffer.writeln('- Nicht verfügbar');
    } else {
      for (final wound in data.woundSummary!.latestEntries) {
        buffer.writeln(
          '- ${_formatDateTime(wound.createdAt)} · Schmerz ${wound.pain}/10',
        );
      }
    }
    buffer.writeln();
    buffer.writeln('## Termine (nächste 14 Tage)');
    if (data.upcomingAppointments.isEmpty) {
      buffer.writeln('- Keine');
    } else {
      for (final appt in data.upcomingAppointments) {
        buffer.writeln('- ${_formatDateTime(appt.startAt)} · ${appt.title}');
      }
    }
    buffer.writeln();
    buffer.writeln('## Warnzeichen');
    buffer.writeln('- Status: ${_lightLabel(data.warnStatus)}');
    buffer.writeln();
    buffer.writeln('## Dokumente (letzte 3)');
    if (data.latestDocuments.isEmpty) {
      buffer.writeln('- Keine');
    } else {
      for (final doc in data.latestDocuments) {
        buffer.writeln('- ${_formatDateTime(doc.createdAt)} · ${doc.title}');
      }
    }
    return buffer.toString();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Nicht verfügbar';
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    return '$dd.$mm.${value.year}';
  }

  String _formatDateTime(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${value.year} $hh:$min';
  }

  String _lightLabel(ReportLight light) {
    return switch (light) {
      ReportLight.green => 'Grün',
      ReportLight.yellow => 'Gelb',
      ReportLight.red => 'Rot',
      ReportLight.unknown => 'Nicht verfügbar',
    };
  }

  String? _stringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }
}
