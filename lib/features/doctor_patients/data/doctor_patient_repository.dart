import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/auth_service.dart';
import '../../../domain/timeline_engine.dart';
import '../../../features/appointments/domain/appointment.dart';
import '../../../features/doctor_templates/domain/care_plan_template.dart';
import '../../../firebase/app_functions.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../security/encryption_key_manager.dart';
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

  /// Tracks whether we already attempted a one-time encryption key refresh
  /// to self-heal from a previously cached wrong key.
  bool _keyRefreshAttempted = false;

  /// Returns `true` if [value] looks like a Base64-encoded encrypted
  /// ciphertext rather than a human-readable name.
  static bool _looksEncrypted(String value) {
    if (value.length < 24) return false;
    try {
      final bytes = base64Decode(value);
      return bytes.length >= 17; // 16-byte IV + at least 1 byte
    } catch (_) {
      return false;
    }
  }

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
      debugPrint(
        '[DoctorPatientRepo] staff mode — using CF for overrideDoctorUid=$overrideDoctorUid',
      );
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
            final patientDoc = await _firestore
                .doc(FirestorePaths.patientDoc(patientId))
                .get();
            final patientData = patientDoc.data() ?? const <String, dynamic>{};

            final profile =
                patientData['profile'] as Map<String, dynamic>? ??
                const <String, dynamic>{};

            String displayName = '';
            int? age;
            try {
              final userDoc = await _firestore
                  .doc(FirestorePaths.userDoc(patientId))
                  .get();
              var userData = userDoc.data() ?? const <String, dynamic>{};
              // Decrypt patient PII fields.
              userData = FieldEncryptionService.instance
                  .decryptFields(patientId, userData, kEncryptedUserFields);
              displayName = (userData['displayName'] ?? '').toString();
              // Prefer direct age field; fall back to legacy birthDate.
              final ageRaw = userData['age'];
              if (ageRaw is int) {
                age = ageRaw;
              } else if (ageRaw is String && ageRaw.isNotEmpty) {
                age = int.tryParse(ageRaw);
              }
              if (age == null) {
                DateTime? birthDate;
                final birthRaw = userData['birthDate'];
                if (birthRaw is Timestamp) {
                  birthDate = birthRaw.toDate();
                } else if (birthRaw is String && birthRaw.isNotEmpty) {
                  birthDate = DateTime.tryParse(birthRaw);
                }
                age = LinkedPatient.ageFromBirthDate(birthDate);
              }
            } catch (_) {
              displayName = (profile['displayName'] ?? '').toString();
            }

            final opDateRaw = profile['opDate'] ?? patientData['opDate'];
            DateTime? opDate;
            if (opDateRaw is Timestamp) {
              opDate = opDateRaw.toDate();
            } else if (opDateRaw is String && opDateRaw.isNotEmpty) {
              opDate = DateTime.tryParse(opDateRaw);
            }

            patients.add(
              LinkedPatient(
                uid: patientId,
                displayName: displayName.isNotEmpty
                    ? displayName
                    : 'Patient',
                age: age,
                opDate: opDate,
                diagnosis: (profile['diagnosis'] ?? '').toString(),
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

                  // Self-healing: if patient names still look encrypted,
                  // the local encryption key is likely wrong (cached from a
                  // previous failed restore). Refresh the key once and retry.
                  if (!_keyRefreshAttempted &&
                      patients.any((p) => _looksEncrypted(p.displayName))) {
                    _keyRefreshAttempted = true;
                    final callerUid = _auth.currentUser?.uid;
                    if (callerUid != null) {
                      debugPrint(
                        '[DoctorPatientRepo] detected encrypted display names — refreshing encryption key',
                      );
                      final refreshed =
                          await EncryptionKeyManager().refreshKey(callerUid);
                      if (refreshed) {
                        patients = await parseSnapshot(snap);
                      }
                    }
                  }

                  debugPrint(
                    '[DoctorPatientRepo] stream emitted ${patients.length} patients',
                  );
                  if (patients.isEmpty) {
                    // If we already have cached server patients, reuse them
                    // instead of calling the CF again on every empty snapshot.
                    if (cachedServerPatients != null &&
                        cachedServerPatients!.isNotEmpty) {
                      debugPrint(
                        '[DoctorPatientRepo] reusing ${cachedServerPatients!.length} cached server patients',
                      );
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
                        debugPrint(
                          '[DoctorPatientRepo] CLIENT 0 but SERVER ${serverPatients.length} — using server data',
                        );
                        if (!controller.isClosed) {
                          controller.add(serverPatients);
                        }
                        return;
                      }
                    } catch (e) {
                      debugPrint(
                        '[DoctorPatientRepo] server cross-check failed: $e',
                      );
                    }
                  }
                  if (!controller.isClosed) controller.add(patients);
                } catch (e) {
                  debugPrint('[DoctorPatientRepo] parse error: $e');
                  if (!controller.isClosed) controller.add(const []);
                }
              },
              onError: (Object error, StackTrace stack) async {
                debugPrint('[DoctorPatientRepo] stream error: $error');
                try {
                  final patients = await getLinkedPatientsOnce();
                  debugPrint(
                    '[DoctorPatientRepo] fallback get() returned ${patients.length}',
                  );
                  if (patients.isNotEmpty) {
                    if (!controller.isClosed) controller.add(patients);
                  } else {
                    // Firestore returned 0 — try CF (org-staff scenario).
                    final serverPatients =
                        await _fetchLinkedPatientsViaFunction();
                    debugPrint(
                      '[DoctorPatientRepo] onError CF returned ${serverPatients.length}',
                    );
                    cachedServerPatients = serverPatients;
                    if (!controller.isClosed) {
                      controller.add(serverPatients);
                    }
                  }
                } catch (e2) {
                  debugPrint('[DoctorPatientRepo] fallback get() failed: $e2');
                  try {
                    final patients = await _fetchLinkedPatientsViaFunction();
                    debugPrint(
                      '[DoctorPatientRepo] CF fallback returned ${patients.length}',
                    );
                    cachedServerPatients = patients;
                    if (!controller.isClosed) controller.add(patients);
                  } catch (e3) {
                    debugPrint('[DoctorPatientRepo] CF fallback failed: $e3');
                    if (!controller.isClosed) controller.add(const []);
                  }
                }

                // Only retry if we have no data yet
                if (cachedServerPatients == null ||
                    cachedServerPatients!.isEmpty) {
                  await Future<void>.delayed(const Duration(seconds: 5));
                  if (!controller.isClosed) {
                    debugPrint('[DoctorPatientRepo] auto-retrying listener');
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
      debugPrint('[DoctorPatientRepo] notifyPatientNewAppointment failed: $e');
    }
  }

  /// Loads patients for staff users via Cloud Function.
  /// Returns the patient list (empty on failure).
  Future<List<LinkedPatient>> _loadPatientsViaCloudFunction() async {
    try {
      debugPrint('[DoctorPatientRepo] calling CF debugLinkedPatients...');
      var patients = await _fetchLinkedPatientsViaFunction();
      debugPrint(
        '[DoctorPatientRepo] CF returned ${patients.length} patients',
      );

      // Self-healing for staff path: refresh key if names look encrypted.
      if (!_keyRefreshAttempted &&
          patients.any((p) => _looksEncrypted(p.displayName))) {
        _keyRefreshAttempted = true;
        final callerUid = _auth.currentUser?.uid;
        if (callerUid != null) {
          debugPrint(
            '[DoctorPatientRepo] CF path: encrypted names detected — refreshing key',
          );
          final refreshed =
              await EncryptionKeyManager().refreshKey(callerUid);
          if (refreshed) {
            patients = await _fetchLinkedPatientsViaFunction();
          }
        }
      }

      return patients;
    } catch (e) {
      debugPrint('[DoctorPatientRepo] CF call failed: $e');
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
    debugPrint('[DoctorPatientRepo] CF raw result.data type: ${result.data.runtimeType}');
    final rawData = result.data;
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    final rawLinks = data['links'];
    debugPrint('[DoctorPatientRepo] CF links type: ${rawLinks.runtimeType}, value: $rawLinks');
    final links = rawLinks is List ? List<dynamic>.from(rawLinks) : <dynamic>[];
    debugPrint('[DoctorPatientRepo] CF parsing ${links.length} links');
    final patients = <LinkedPatient>[];
    for (final link in links) {
      final map = link is Map
          ? Map<String, dynamic>.from(link)
          : <String, dynamic>{};
      final patientId = map['patientId']?.toString();
      if (patientId == null || patientId.isEmpty) continue;
      debugPrint('[DoctorPatientRepo] CF link: patientId=$patientId');

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
        final userDoc =
            await _firestore.doc(FirestorePaths.userDoc(patientId)).get()
                .timeout(const Duration(seconds: 5));
        var userData = userDoc.data() ?? const <String, dynamic>{};
        userData = FieldEncryptionService.instance
            .decryptFields(patientId, userData, kEncryptedUserFields);
        if ((userData['displayName'] ?? '').toString().isNotEmpty) {
          displayName = userData['displayName'].toString();
        }
        // Prefer direct age field; fall back to legacy birthDate.
        final ageRaw = userData['age'];
        if (ageRaw is int) {
          age = ageRaw;
        } else if (ageRaw is String && ageRaw.isNotEmpty) {
          age = int.tryParse(ageRaw);
        }
        if (age == null) {
          DateTime? birthDate;
          final birthRaw = userData['birthDate'];
          if (birthRaw is Timestamp) {
            birthDate = birthRaw.toDate();
          } else if (birthRaw is String && birthRaw.isNotEmpty) {
            birthDate = DateTime.tryParse(birthRaw);
          }
          age = LinkedPatient.ageFromBirthDate(birthDate);
        }
      } catch (e) {
        debugPrint('[DoctorPatientRepo] enrich user/$patientId failed: $e');
      }
      try {
        final patientDoc =
            await _firestore.doc(FirestorePaths.patientDoc(patientId)).get()
                .timeout(const Duration(seconds: 5));
        final patientData = patientDoc.data() ?? const <String, dynamic>{};
        final profile = patientData['profile'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
        final opDateRaw = profile['opDate'] ?? patientData['opDate'];
        if (opDateRaw is Timestamp) {
          opDate = opDateRaw.toDate();
        } else if (opDateRaw is String && opDateRaw.isNotEmpty) {
          opDate = DateTime.tryParse(opDateRaw);
        }
        diagnosis = (profile['diagnosis'] ?? '').toString();
      } catch (e) {
        debugPrint('[DoctorPatientRepo] enrich patient/$patientId failed: $e');
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
        final userDoc = await _firestore
            .doc(FirestorePaths.userDoc(patientId))
            .get();
        var userData = userDoc.data() ?? const <String, dynamic>{};
        userData = FieldEncryptionService.instance
            .decryptFields(patientId, userData, kEncryptedUserFields);

        final patientDoc = await _firestore
            .doc(FirestorePaths.patientDoc(patientId))
            .get();
        final patientData = patientDoc.data() ?? const <String, dynamic>{};

        final profile =
            patientData['profile'] as Map<String, dynamic>? ??
            const <String, dynamic>{};

        final opDateRaw = profile['opDate'] ?? patientData['opDate'];
        DateTime? opDate;
        if (opDateRaw is Timestamp) {
          opDate = opDateRaw.toDate();
        } else if (opDateRaw is String && opDateRaw.isNotEmpty) {
          opDate = DateTime.tryParse(opDateRaw);
        }

        // Prefer direct age field; fall back to legacy birthDate.
        int? age;
        final ageRaw = userData['age'];
        if (ageRaw is int) {
          age = ageRaw;
        } else if (ageRaw is String && ageRaw.isNotEmpty) {
          age = int.tryParse(ageRaw);
        }
        if (age == null) {
          DateTime? birthDate;
          final birthRaw = userData['birthDate'];
          if (birthRaw is Timestamp) {
            birthDate = birthRaw.toDate();
          } else if (birthRaw is String && birthRaw.isNotEmpty) {
            birthDate = DateTime.tryParse(birthRaw);
          }
          age = LinkedPatient.ageFromBirthDate(birthDate);
        }

        final displayName = (userData['displayName'] ?? '').toString();

        patients.add(
          LinkedPatient(
            uid: patientId,
            displayName: displayName.isNotEmpty
                ? displayName
                : 'Patient',
            age: age,
            opDate: opDate,
            diagnosis: (profile['diagnosis'] ?? '').toString(),
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
