import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/auth_service.dart';
import '../../../domain/timeline_engine.dart';
import '../../../features/appointments/domain/appointment.dart';
import '../../../features/doctor_templates/domain/care_plan_template.dart';
import '../../../features/red_flags/domain/red_flag.dart';
import '../../../firebase/app_functions.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../security/field_encryption_service.dart';
import '../domain/linked_patient.dart';

/// Read-only repository that lets a doctor view linked patients' data.
///
/// When [overrideDoctorUid] is set (i.e. for staff members), all queries
/// use that doctor's UID for link resolution instead of the signed-in user's UID.
class DoctorPatientRepository {
  DoctorPatientRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.overrideDoctorUid,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// If set, queries are resolved against this doctor UID (staff mode).
  final String? overrideDoctorUid;

  /// Returns the effective doctor UID (own UID for doctors, override for staff).
  String? get _effectiveDoctorUid =>
      overrideDoctorUid ?? _auth.currentUser?.uid;

  Future<String?> _waitForEffectiveDoctorUid() async {
    final currentUid = _effectiveDoctorUid;
    if (currentUid != null && currentUid.isNotEmpty) return currentUid;

    try {
      await AuthService.waitForWebSessionReady();
    } catch (_) {
      // Best effort only.
    }

    final readyUid = _effectiveDoctorUid;
    if (readyUid != null && readyUid.isNotEmpty) return readyUid;

    try {
      final user = await _auth
          .idTokenChanges()
          .firstWhere((candidate) => candidate != null)
          .timeout(const Duration(seconds: 5));
      return overrideDoctorUid ?? user?.uid;
    } catch (_) {
      return _effectiveDoctorUid;
    }
  }

  Future<Map<String, dynamic>> _loadPatientCareProfile(String patientId) async {
    final patientDoc = await _firestore.doc(FirestorePaths.patientDoc(patientId)).get();
    final patientData = patientDoc.data() ?? const <String, dynamic>{};
    final legacyProfile =
        patientData['profile'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    Map<String, dynamic> careProfile = const <String, dynamic>{};
    try {
      final careProfileDoc = await _firestore
          .doc(FirestorePaths.patientCareProfileDoc(patientId))
          .get();
      careProfile = careProfileDoc.data() ?? const <String, dynamic>{};
    } catch (_) {
      careProfile = const <String, dynamic>{};
    }

    return <String, dynamic>{
      ...legacyProfile,
      ...careProfile,
      'opDate':
          careProfile['opDate'] ?? legacyProfile['opDate'] ?? patientData['opDate'],
      'diagnosis':
          careProfile['diagnosis'] ??
          legacyProfile['diagnosis'] ??
          patientData['diagnosis'],
    };
  }

  int? _extractAge(Map<String, dynamic> careProfile) {
    final ageRaw = careProfile['age'];
    if (ageRaw is int) return ageRaw;
    if (ageRaw is String && ageRaw.isNotEmpty) {
      return int.tryParse(ageRaw);
    }
    return null;
  }

  DateTime? _parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  // ── Linked patients ──────────────────────────────────────────────

  /// Streams all patients that have an active link with the current doctor.
  ///
  /// On collectionGroup permission errors the stream falls back to a
  /// one-shot [getLinkedPatientsOnce] call so the UI never stays stuck on a
  /// permanent error state.
  Stream<List<LinkedPatient>> watchLinkedPatients() {
    // ── Staff users: use Cloud Function exclusively ──
    // Staff users (especially org-staff) can't query Firestore directly
    // because security rules prevent collectionGroup queries where
    // linkedUid ≠ caller's UID. The CF runs with admin privileges.
    if (overrideDoctorUid != null) {
      if (kDebugMode) {
        debugPrint(
          '[DoctorPatientRepo] staff mode — using CF for overrideDoctorUid=$overrideDoctorUid',
        );
      }
      return Stream.fromFuture(_loadPatientsViaCloudFunction());
    }

    // ── Doctor users: use Firestore streaming ──
    return Stream<String?>.fromFuture(_waitForEffectiveDoctorUid()).asyncExpand((uid) {
      if (kDebugMode) debugPrint('[DoctorPatientRepo] watchLinkedPatients called');
      if (uid == null) return Stream.value(const <LinkedPatient>[]);

      final controller = StreamController<List<LinkedPatient>>();
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;

      Future<List<LinkedPatient>> parseSnapshot(
        QuerySnapshot<Map<String, dynamic>> snap,
      ) async {
        if (kDebugMode) {
          debugPrint(
            '[DoctorPatientRepo] links snapshot size=${snap.docs.length}',
          );
        }

        final patients = <LinkedPatient>[];
        for (final doc in snap.docs) {
          final patientId = doc.reference.parent.parent?.id;
          if (patientId == null) continue;

          try {
            final careProfile = await _loadPatientCareProfile(patientId);
            final displayName =
                (careProfile['displayName'] ?? '').toString();
            final age = _extractAge(careProfile);
            final opDate = _parseDate(careProfile['opDate']);

            patients.add(
              LinkedPatient(
                uid: patientId,
                displayName: displayName.isNotEmpty
                    ? displayName
                    : 'Patient',
                age: age,
                opDate: opDate,
                diagnosis: (careProfile['diagnosis'] ?? '').toString(),
                phase: _computePhase(opDate),
              ),
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                '[DoctorPatientRepo] Error loading linked patient: ${e.runtimeType}',
              );
            }
            patients.add(
              LinkedPatient(uid: patientId, displayName: 'Patient'),
            );
          }
        }

        return patients;
      }

      // ── Standard doctor/direct-staff path ──
      // Cache CF results so that subsequent empty Firestore snapshots
      // don't overwrite previously fetched server data with an empty list.
      List<LinkedPatient>? cachedServerPatients;

      void startListening() {
        sub = _firestore
            .collectionGroup(FirestorePaths.links)
            .where('linkedUid', isEqualTo: uid)
            .where('status', isEqualTo: 'active')
            .where('linkType', isEqualTo: 'doctor')
            .limit(100)
            .snapshots()
            .listen(
              (snap) async {
                try {
                  var patients = await parseSnapshot(snap);

                  if (kDebugMode) {
                    debugPrint(
                      '[DoctorPatientRepo] stream emitted ${patients.length} patients',
                    );
                  }
                  if (patients.isEmpty) {
                    // If we already have cached server patients, reuse them
                    // instead of calling the CF again on every empty snapshot.
                    if (cachedServerPatients != null &&
                        cachedServerPatients!.isNotEmpty) {
                      if (kDebugMode) {
                        debugPrint(
                          '[DoctorPatientRepo] reusing ${cachedServerPatients!.length} cached server patients',
                        );
                      }
                      if (!controller.isClosed) {
                        controller.add(cachedServerPatients!);
                      }
                      return;
                    }
                    try {
                      final serverPatients =
                          await _fetchLinkedPatientsViaFunction();
                      if (serverPatients.isNotEmpty) {
                        cachedServerPatients = serverPatients;
                        if (kDebugMode) {
                          debugPrint(
                            '[DoctorPatientRepo] CLIENT 0 but SERVER ${serverPatients.length} — using server data',
                          );
                        }
                        if (!controller.isClosed) {
                          controller.add(serverPatients);
                        }
                        return;
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        debugPrint(
                          '[DoctorPatientRepo] server cross-check failed: $e',
                        );
                      }
                    }
                  }
                  if (!controller.isClosed) controller.add(patients);
                } catch (e) {
                  if (kDebugMode) {
                    debugPrint('[DoctorPatientRepo] parse error: $e');
                  }
                  if (!controller.isClosed) controller.add(const []);
                }
              },
              onError: (Object error, StackTrace stack) async {
                if (kDebugMode) {
                  debugPrint('[DoctorPatientRepo] stream error: $error');
                }
                try {
                  final patients = await getLinkedPatientsOnce();
                  if (kDebugMode) {
                    debugPrint(
                      '[DoctorPatientRepo] fallback get() returned ${patients.length}',
                    );
                  }
                  if (patients.isNotEmpty) {
                    if (!controller.isClosed) controller.add(patients);
                  } else {
                    // Firestore returned 0 — try CF (org-staff scenario).
                    final serverPatients =
                        await _fetchLinkedPatientsViaFunction();
                    if (kDebugMode) {
                      debugPrint(
                        '[DoctorPatientRepo] onError CF returned ${serverPatients.length}',
                      );
                    }
                    cachedServerPatients = serverPatients;
                    if (!controller.isClosed) {
                      controller.add(serverPatients);
                    }
                  }
                } catch (e2) {
                  if (kDebugMode) {
                    debugPrint('[DoctorPatientRepo] fallback get() failed: $e2');
                  }
                  try {
                    final patients = await _fetchLinkedPatientsViaFunction();
                    if (kDebugMode) {
                      debugPrint(
                        '[DoctorPatientRepo] CF fallback returned ${patients.length}',
                      );
                    }
                    cachedServerPatients = patients;
                    if (!controller.isClosed) controller.add(patients);
                  } catch (e3) {
                    if (kDebugMode) {
                      debugPrint('[DoctorPatientRepo] CF fallback failed: $e3');
                    }
                    if (!controller.isClosed) controller.add(const []);
                  }
                }

                // Only retry if we have no data yet
                if (cachedServerPatients == null ||
                    cachedServerPatients!.isEmpty) {
                  await Future<void>.delayed(const Duration(seconds: 5));
                  if (!controller.isClosed) {
                    if (kDebugMode) {
                      debugPrint('[DoctorPatientRepo] auto-retrying listener');
                    }
                    sub?.cancel();
                    startListening();
                  }
                }
              },
            );
      }

      controller.onListen = startListening;
      controller.onCancel = () {
        sub?.cancel();
        controller.close();
      };

      return controller.stream;
    });
  }

  // ── Link management ─────────────────────────────────────────────

  /// Disconnects a patient by deactivating the link via Cloud Function.
  Future<void> unlinkPatient(String patientId) async {
    final uid = _effectiveDoctorUid;
    if (uid == null) return;

    final callable = appFunctions().httpsCallable('unlinkPatient');
    await callable.call<dynamic>({
      'patientId': patientId,
      'linkType': 'doctor',
    });
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

  /// Sends a push notification to a patient about a new doctor-created appointment.
  Future<void> notifyPatientNewAppointment({
    required String patientId,
    required String title,
    required DateTime startAt,
    required String doctorName,
  }) async {
    try {
      final callable = appFunctions().httpsCallable(
        'notifyDoctorAppointment',
      );
      await callable.call<dynamic>({
        'patientId': patientId,
        'title': title,
        'startAt': startAt.toIso8601String(),
        'doctorName': doctorName,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DoctorPatientRepo] notifyPatientNewAppointment failed: $e');
      }
    }
  }

  /// Loads patients for staff users via Cloud Function.
  /// Returns the patient list (empty on failure).
  Future<List<LinkedPatient>> _loadPatientsViaCloudFunction() async {
    try {
      if (kDebugMode) {
        debugPrint('[DoctorPatientRepo] calling CF debugLinkedPatients...');
      }
      final patients = await _fetchLinkedPatientsViaFunction();
      if (kDebugMode) {
        debugPrint(
          '[DoctorPatientRepo] CF returned ${patients.length} patients',
        );
      }

      return patients;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DoctorPatientRepo] CF call failed: $e');
      }
      return const [];
    }
  }

  /// Server-side fallback: fetch linked patients via Cloud Function when
  /// the client-side collectionGroup query fails due to rules issues.
  Future<List<LinkedPatient>> _fetchLinkedPatientsViaFunction() async {
    final result = await appFunctions().httpsCallable('debugLinkedPatients').call(
      <String, dynamic>{
      if (overrideDoctorUid != null) 'doctorUid': overrideDoctorUid,
    });
    if (kDebugMode) {
      debugPrint('[DoctorPatientRepo] CF raw result.data type: ${result.data.runtimeType}');
    }
    final rawData = result.data;
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    final rawLinks = data['links'];
    if (kDebugMode) {
      debugPrint('[DoctorPatientRepo] CF links type: ${rawLinks.runtimeType}, value: $rawLinks');
    }
    final links = rawLinks is List ? List<dynamic>.from(rawLinks) : <dynamic>[];
    if (kDebugMode) {
      debugPrint('[DoctorPatientRepo] CF parsing ${links.length} links');
    }
    final patients = <LinkedPatient>[];
    for (final link in links) {
      final map = link is Map
          ? Map<String, dynamic>.from(link)
          : <String, dynamic>{};
      final patientId = map['patientId']?.toString();
      if (patientId == null || patientId.isEmpty) continue;
      if (kDebugMode) {
        debugPrint('[DoctorPatientRepo] CF link: patientId=$patientId');
      }

      // Use server-provided display info as defaults.
      String displayName =
          (map['displayName']?.toString() ?? '').isNotEmpty
              ? map['displayName'].toString()
              : 'Patient';

      DateTime? opDate;
      int? age;
      String diagnosis = '';

      // Try enriching from Firestore (may fail if rules block reads).
      try {
        final careProfile = await _loadPatientCareProfile(patientId)
            .timeout(const Duration(seconds: 5));
        if ((careProfile['displayName'] ?? '').toString().isNotEmpty) {
          displayName = careProfile['displayName'].toString();
        }
        age = _extractAge(careProfile);
        opDate = _parseDate(careProfile['opDate']);
        diagnosis = (careProfile['diagnosis'] ?? '').toString();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[DoctorPatientRepo] enrich care profile/$patientId failed: $e');
        }
      }

      patients.add(LinkedPatient(
        uid: patientId,
        displayName: displayName.isNotEmpty
            ? displayName
            : 'Patient',
        age: age,
        opDate: opDate,
        diagnosis: diagnosis,
        linkedDoctorUid: map['linkedUid']?.toString(),
        phase: _computePhase(opDate),
      ));
    }
    return patients;
  }

  /// Returns all linked patients once (non-streaming).
  Future<List<LinkedPatient>> getLinkedPatientsOnce() async {
    // Staff users: use Cloud Function (Firestore collectionGroup blocked).
    if (overrideDoctorUid != null) {
      return _loadPatientsViaCloudFunction();
    }

    final uid = await _waitForEffectiveDoctorUid();
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

      try {
        final careProfile = await _loadPatientCareProfile(patientId);
        final opDate = _parseDate(careProfile['opDate']);
        final age = _extractAge(careProfile);
        final displayName = (careProfile['displayName'] ?? '').toString();

        patients.add(
          LinkedPatient(
            uid: patientId,
            displayName: displayName.isNotEmpty
                ? displayName
                : 'Patient',
            age: age,
            opDate: opDate,
            diagnosis: (careProfile['diagnosis'] ?? '').toString(),
            phase: _computePhase(opDate),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[DoctorPatientRepo] Error loading patient $patientId: $e',
          );
        }
        patients.add(
          LinkedPatient(uid: patientId, displayName: 'Patient'),
        );
      }
    }
    return patients;
  }

  Future<LinkedPatient> enrichPatient(LinkedPatient patient) async {
    try {
      final redFlagsSnap = await _firestore
          .collection(FirestorePaths.redFlagsCollection(patient.uid))
          .get();
      final redFlags = redFlagsSnap.docs
          .map((doc) => RedFlag.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      return patient.copyWith(redFlags: redFlags);
    } catch (_) {
      return patient;
    }
  }

  /// Returns appointments created by this doctor for all linked patients
  /// on a given [date].
  Future<List<PatientAppointment>> getAppointmentsForDate(DateTime date) async {
    final patients = await getLinkedPatientsOnce();
    final results = <PatientAppointment>[];
    final doctorUid = await _waitForEffectiveDoctorUid();
    if (doctorUid == null) return results;

    for (final patient in patients) {
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final snap = await _firestore
          .collection(FirestorePaths.appointmentsCollection(patient.uid))
          .where('createdBy', isEqualTo: doctorUid)
          .where('startAt', isGreaterThanOrEqualTo: dayStart.toIso8601String())
          .where('startAt', isLessThan: dayEnd.toIso8601String())
          .orderBy('startAt')
          .get();

      for (final doc in snap.docs) {
        results.add(
          PatientAppointment(
            patient: patient,
            appointment: Appointment.fromJson({...doc.data(), 'id': doc.id}),
          ),
        );
      }
    }

    results.sort(
      (a, b) => a.appointment.startAt.compareTo(b.appointment.startAt),
    );
    return results;
  }

  /// Returns a map of day → appointment count for a given month.
  /// Only counts appointments created by this doctor.
  Future<Map<DateTime, int>> getMonthAppointmentCounts(
    int year,
    int month,
  ) async {
    final patients = await getLinkedPatientsOnce();
    final counts = <DateTime, int>{};
    final doctorUid = await _waitForEffectiveDoctorUid();
    if (doctorUid == null) return counts;

    final monthStart = DateTime(year, month);
    final monthEnd = DateTime(year, month + 1);

    for (final patient in patients) {
      final snap = await _firestore
          .collection(FirestorePaths.appointmentsCollection(patient.uid))
          .where('createdBy', isEqualTo: doctorUid)
          .where(
            'startAt',
            isGreaterThanOrEqualTo: monthStart.toIso8601String(),
          )
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
    final uid = await _waitForEffectiveDoctorUid();
    if (uid == null) return '';
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    var data = doc.data() ?? const <String, dynamic>{};
    data = FieldEncryptionService.instance
        .decryptFields(uid, data, kEncryptedDoctorFields);
    return (data['displayName'] ?? '').toString();
  }

  // ── Remote task control ───────────────────────────────────────

  /// Watches the patient's timeline items (doctor-assigned tasks only).
  Stream<List<TimelineItem>> watchPatientTasks(String patientId) {
    return _firestore
        .collection(FirestorePaths.timelineCollection(patientId))
        .where('metadata.assignedByDoctor', isEqualTo: true)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TimelineItem.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  /// Adds a task (TimelineItem) to a patient's timeline collection.
  Future<void> addTaskForPatient(String patientId, TimelineItem task) async {
    final data = task.toJson();
    // Firestore rules require ownerId == patientId for feature creates.
    data['ownerId'] = patientId;
    await _firestore
        .collection(FirestorePaths.timelineCollection(patientId))
        .doc(task.id)
        .set(data);
  }

  /// Applies a care plan template to a patient, creating timeline items.
  ///
  /// When [selectedTaskIndices] is provided, only the tasks at those indices
  /// are applied. Otherwise all tasks in the template are used.
  Future<int> applyTemplate({
    required String patientId,
    required CarePlanTemplate template,
    DateTime? startDate,
    Set<int>? selectedTaskIndices,
  }) async {
    final now = DateTime.now();
    final baseDate = startDate ?? now;
    var count = 0;

    for (var i = 0; i < template.tasks.length; i++) {
      if (selectedTaskIndices != null && !selectedTaskIndices.contains(i)) {
        continue;
      }
      final task = template.tasks[i];
      final occurrences = _expandRecurrence(task, baseDate);

      for (final scheduledAt in occurrences) {
        final taskId = 'tpl_${now.millisecondsSinceEpoch}_$count';

        final item = TimelineItem(
          id: taskId,
          type: task.type,
          title: task.title,
          subtitle: task.subtitle,
          scheduledAt: scheduledAt,
          dueAt: scheduledAt.add(Duration(hours: task.dueHours)),
          priority: task.priority,
          state: TaskState.planned,
          deeplinkRoute: '',
          metadata: <String, dynamic>{
            'fromTemplate': template.id,
            'templateName': template.name,
            'assignedByDoctor': true,
          },
          createdAt: now,
          updatedAt: now,
        );

        await addTaskForPatient(patientId, item);
        count++;
      }
    }
    return count;
  }

  /// Expands a single task definition into one or more scheduled dates,
  /// honouring [TemplateTask.recurrence] and [TemplateTask.timeOfDay].
  static List<DateTime> _expandRecurrence(TemplateTask task, DateTime baseDate) {
    DateTime withTime(DateTime d) {
      if (task.timeOfDay != null) {
        return DateTime(d.year, d.month, d.day, task.timeOfDay!.hour);
      }
      return d;
    }

    final first = withTime(baseDate.add(Duration(days: task.relativeDayOffset)));

    final rec = task.recurrence;
    if (rec == null || rec.count <= 1) return [first];

    final dates = <DateTime>[first];
    var cursor = first;
    for (var n = 1; n < rec.count; n++) {
      switch (rec.type) {
        case RecurrenceType.daily:
          cursor = cursor.add(const Duration(days: 1));
        case RecurrenceType.weekdays:
          cursor = cursor.add(const Duration(days: 1));
          // Skip weekends.
          while (cursor.weekday == DateTime.saturday ||
              cursor.weekday == DateTime.sunday) {
            cursor = cursor.add(const Duration(days: 1));
          }
        case RecurrenceType.everyNDays:
          cursor = cursor.add(Duration(days: rec.intervalDays));
      }
      dates.add(withTime(cursor));
    }
    return dates;
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
}

/// Associates a [LinkedPatient] with an [Appointment].
class PatientAppointment {
  const PatientAppointment({required this.patient, required this.appointment});

  final LinkedPatient patient;
  final Appointment appointment;
}
