import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/appointments/domain/appointment.dart';
import '../../../features/doctor_report/doctor_report_builder.dart';
import '../../../features/documents/domain/document_item.dart';
import '../../../features/pain/domain/pain_entry.dart';
import '../../../features/wound/domain/wound_entry.dart';
import '../../../firebase/firebase_paths.dart';
import '../domain/linked_patient.dart';

/// Read-only repository that lets a doctor view linked patients' data.
class DoctorPatientRepository {
  DoctorPatientRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ── Linked patients ──────────────────────────────────────────────

  /// Streams all patients that have an active link with the current doctor.
  Stream<List<LinkedPatient>> watchLinkedPatients() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collectionGroup(FirestorePaths.links)
        .where('linkedUid', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .where('linkType', isEqualTo: 'doctor')
        .limit(100)
        .snapshots()
        .asyncMap((snap) async {
      final patients = <LinkedPatient>[];
      for (final doc in snap.docs) {
        // The parent is patients/{patientId}/links/{doctorUid}
        final patientId = doc.reference.parent.parent?.id;
        if (patientId == null) continue;

        final userDoc =
            await _firestore.doc(FirestorePaths.userDoc(patientId)).get();
        final userData = userDoc.data() ?? const <String, dynamic>{};

        final patientDoc =
            await _firestore.doc(FirestorePaths.patientDoc(patientId)).get();
        final patientData = patientDoc.data() ?? const <String, dynamic>{};

        final profile = patientData['profile'] as Map<String, dynamic>? ??
            const <String, dynamic>{};

        final opDateRaw = profile['opDate'] ?? patientData['opDate'];
        DateTime? opDate;
        if (opDateRaw is Timestamp) {
          opDate = opDateRaw.toDate();
        } else if (opDateRaw is String && opDateRaw.isNotEmpty) {
          opDate = DateTime.tryParse(opDateRaw);
        }

        patients.add(LinkedPatient(
          uid: patientId,
          displayName:
              (userData['displayName'] ?? '').toString().isNotEmpty
                  ? userData['displayName'].toString()
                  : (userData['email'] ?? 'Patient').toString(),
          email: (userData['email'] ?? '').toString(),
          opDate: opDate,
          diagnosis: (profile['diagnosis'] ?? '').toString(),
          phase: _computePhase(opDate),
          progressPercent: _computeProgress(opDate),
        ));
      }
      return patients;
    });
  }

  /// Enriches a [LinkedPatient] with latest entries and warning status.
  Future<LinkedPatient> enrichPatient(LinkedPatient patient) async {
    final patientId = patient.uid;

    // Latest wound or pain entry
    DateTime? lastEntryAt;
    String? lastEntryLabel;

    final woundSnap = await _firestore
        .collection(FirestorePaths.woundsCollection(patientId))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (woundSnap.docs.isNotEmpty) {
      final data = woundSnap.docs.first.data();
      lastEntryAt = DateTime.tryParse(data['createdAt']?.toString() ?? '');
      lastEntryLabel = 'Wunddoku';
    }

    final painSnap = await _firestore
        .collection(FirestorePaths.painCollection(patientId))
        .orderBy('occurredAt', descending: true)
        .limit(1)
        .get();
    if (painSnap.docs.isNotEmpty) {
      final data = painSnap.docs.first.data();
      final painAt =
          DateTime.tryParse(data['occurredAt']?.toString() ?? '');
      if (painAt != null &&
          (lastEntryAt == null || painAt.isAfter(lastEntryAt))) {
        lastEntryAt = painAt;
        lastEntryLabel = 'Schmerz';
      }
    }

    // Next appointment
    DateTime? nextAppAt;
    String? nextAppTitle;
    final now = DateTime.now();
    final apptSnap = await _firestore
        .collection(FirestorePaths.appointmentsCollection(patientId))
        .where('startAt', isGreaterThanOrEqualTo: now.toIso8601String())
        .orderBy('startAt')
        .limit(1)
        .get();
    if (apptSnap.docs.isNotEmpty) {
      final data = apptSnap.docs.first.data();
      nextAppAt = DateTime.tryParse(data['startAt']?.toString() ?? '');
      nextAppTitle = (data['title'] ?? '').toString();
    }

    // Warning status
    ReportLight warnStatus = ReportLight.unknown;
    final warnSnap = await _firestore
        .collection(FirestorePaths.warningsCollection(patientId))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (warnSnap.docs.isNotEmpty) {
      final data = warnSnap.docs.first.data();
      final level = (data['level'] ?? '').toString();
      warnStatus = switch (level) {
        'green' => ReportLight.green,
        'yellow' => ReportLight.yellow,
        'red' => ReportLight.red,
        _ => ReportLight.unknown,
      };
    }

    return patient.copyWith(
      lastEntryAt: lastEntryAt,
      lastEntryLabel: lastEntryLabel,
      nextAppointmentAt: nextAppAt,
      nextAppointmentTitle: nextAppTitle,
      warnStatus: warnStatus,
    );
  }

  // ── Individual patient data streams ──────────────────────────────

  Stream<List<WoundEntry>> watchPatientWounds(String patientId) {
    return _firestore
        .collection(FirestorePaths.woundsCollection(patientId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WoundEntry.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  Stream<List<PainEntry>> watchPatientPain(String patientId) {
    return _firestore
        .collection(FirestorePaths.painCollection(patientId))
        .orderBy('occurredAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PainEntry.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  Stream<List<Appointment>> watchPatientAppointments(String patientId) {
    return _firestore
        .collection(FirestorePaths.appointmentsCollection(patientId))
        .orderBy('startAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Appointment.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  Stream<List<DocumentItem>> watchPatientDocuments(String patientId) {
    return _firestore
        .collection(FirestorePaths.documentsCollection(patientId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DocumentItem.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  // ── Link management ─────────────────────────────────────────────

  /// Disconnects a patient by setting the link status to inactive.
  Future<void> unlinkPatient(String patientId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Convention: link doc ID = {linkedUid}_{linkType}
    final linkDocId = '${uid}_doctor';
    await _firestore
        .doc('${FirestorePaths.linksCollection(patientId)}/$linkDocId')
        .update({'status': 'inactive'});
  }

  /// Creates an appointment for a linked patient.
  Future<void> createAppointmentForPatient(
    String patientId,
    Appointment appointment,
  ) async {
    await _firestore
        .collection(FirestorePaths.appointmentsCollection(patientId))
        .doc(appointment.id)
        .set(appointment.toJson());
  }

  /// Updates an existing appointment for a linked patient.
  Future<void> updateAppointmentForPatient(
    String patientId,
    Appointment appointment,
  ) async {
    await _firestore
        .collection(FirestorePaths.appointmentsCollection(patientId))
        .doc(appointment.id)
        .update(appointment.toJson());
  }

  /// Deletes an appointment from a linked patient.
  Future<void> deleteAppointmentForPatient(
    String patientId,
    String appointmentId,
  ) async {
    await _firestore
        .collection(FirestorePaths.appointmentsCollection(patientId))
        .doc(appointmentId)
        .delete();
  }

  /// Returns all linked patients once (non-streaming).
  Future<List<LinkedPatient>> getLinkedPatientsOnce() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const [];

    final snap = await _firestore
        .collectionGroup(FirestorePaths.links)
        .where('linkedUid', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .where('linkType', isEqualTo: 'doctor')
        .limit(100)
        .get();

    final patients = <LinkedPatient>[];
    for (final doc in snap.docs) {
      final patientId = doc.reference.parent.parent?.id;
      if (patientId == null) continue;

      final userDoc =
          await _firestore.doc(FirestorePaths.userDoc(patientId)).get();
      final userData = userDoc.data() ?? const <String, dynamic>{};

      final patientDoc =
          await _firestore.doc(FirestorePaths.patientDoc(patientId)).get();
      final patientData = patientDoc.data() ?? const <String, dynamic>{};

      final profile = patientData['profile'] as Map<String, dynamic>? ??
          const <String, dynamic>{};

      final opDateRaw = profile['opDate'] ?? patientData['opDate'];
      DateTime? opDate;
      if (opDateRaw is Timestamp) {
        opDate = opDateRaw.toDate();
      } else if (opDateRaw is String && opDateRaw.isNotEmpty) {
        opDate = DateTime.tryParse(opDateRaw);
      }

      patients.add(LinkedPatient(
        uid: patientId,
        displayName:
            (userData['displayName'] ?? '').toString().isNotEmpty
                ? userData['displayName'].toString()
                : (userData['email'] ?? 'Patient').toString(),
        email: (userData['email'] ?? '').toString(),
        opDate: opDate,
        diagnosis: (profile['diagnosis'] ?? '').toString(),
        phase: _computePhase(opDate),
        progressPercent: _computeProgress(opDate),
      ));
    }
    return patients;
  }

  /// Returns appointments for all linked patients on a given [date].
  Future<List<PatientAppointment>> getAppointmentsForDate(
      DateTime date) async {
    final patients = await getLinkedPatientsOnce();
    final results = <PatientAppointment>[];

    for (final patient in patients) {
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final snap = await _firestore
          .collection(FirestorePaths.appointmentsCollection(patient.uid))
          .where('startAt',
              isGreaterThanOrEqualTo: dayStart.toIso8601String())
          .where('startAt', isLessThan: dayEnd.toIso8601String())
          .orderBy('startAt')
          .get();

      for (final doc in snap.docs) {
        results.add(PatientAppointment(
          patient: patient,
          appointment:
              Appointment.fromJson({...doc.data(), 'id': doc.id}),
        ));
      }
    }

    results.sort(
        (a, b) => a.appointment.startAt.compareTo(b.appointment.startAt));
    return results;
  }

  /// Returns a map of day → appointment count for a given month.
  Future<Map<DateTime, int>> getMonthAppointmentCounts(
      int year, int month) async {
    final patients = await getLinkedPatientsOnce();
    final counts = <DateTime, int>{};

    final monthStart = DateTime(year, month);
    final monthEnd = DateTime(year, month + 1);

    for (final patient in patients) {
      final snap = await _firestore
          .collection(FirestorePaths.appointmentsCollection(patient.uid))
          .where('startAt',
              isGreaterThanOrEqualTo: monthStart.toIso8601String())
          .where('startAt', isLessThan: monthEnd.toIso8601String())
          .get();

      for (final doc in snap.docs) {
        final startAtStr = doc.data()['startAt']?.toString() ?? '';
        final dt = DateTime.tryParse(startAtStr);
        if (dt != null) {
          final dayKey = DateTime(dt.year, dt.month, dt.day);
          counts[dayKey] = (counts[dayKey] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  /// Returns the doctor's display name from their user doc.
  Future<String> getDoctorDisplayName() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return '';
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    final data = doc.data() ?? const <String, dynamic>{};
    return (data['displayName'] ?? '').toString();
  }

  // ── Helpers ─────────────────────────────────────────────────────

  static PatientPhase _computePhase(DateTime? opDate) {
    if (opDate == null) return PatientPhase.preOp;
    final now = DateTime.now();
    final daysSinceOp = now.difference(opDate).inDays;
    if (daysSinceOp < 0) return PatientPhase.preOp;
    if (daysSinceOp == 0) return PatientPhase.opDay;
    if (daysSinceOp <= 42) return PatientPhase.postOp;
    return PatientPhase.discharged;
  }

  static double _computeProgress(DateTime? opDate) {
    if (opDate == null) return 0;
    final now = DateTime.now();
    final daysSinceOp = now.difference(opDate).inDays;
    if (daysSinceOp < 0) return 0;
    // 6 weeks (42 days) is "full" recovery
    return (daysSinceOp / 42.0).clamp(0, 1);
  }
}

/// Associates a [LinkedPatient] with an [Appointment].
class PatientAppointment {
  const PatientAppointment({
    required this.patient,
    required this.appointment,
  });

  final LinkedPatient patient;
  final Appointment appointment;
}
