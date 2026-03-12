import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/doctor_event.dart';

/// Repository for practice-internal events stored at
/// `doctors/{doctorId}/events`.
class DoctorEventRepository {
  DoctorEventRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.overrideDoctorUid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String? overrideDoctorUid;

  String? get _doctorUid => overrideDoctorUid ?? _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _eventsCol {
    final uid = _doctorUid;
    if (uid == null) {
      throw StateError('No doctor UID available');
    }
    return _firestore.collection('doctors/$uid/events');
  }

  // ── CRUD ────────────────────────────────────────────────────────

  Future<void> createEvent(DoctorEvent event) async {
    await _eventsCol.doc(event.id).set(event.toJson());
  }

  Future<void> updateEvent(DoctorEvent event) async {
    await _eventsCol.doc(event.id).update(event.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsCol.doc(eventId).delete();
  }

  // ── Queries ─────────────────────────────────────────────────────

  Future<List<DoctorEvent>> getEventsForDate(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final snap = await _eventsCol
        .where('startAt',
            isGreaterThanOrEqualTo: dayStart.toIso8601String())
        .where('startAt', isLessThan: dayEnd.toIso8601String())
        .orderBy('startAt')
        .get();

    return snap.docs
        .map((d) => DoctorEvent.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<Map<DateTime, int>> getMonthEventCounts(
    int year,
    int month,
  ) async {
    final monthStart = DateTime(year, month);
    final monthEnd = DateTime(year, month + 1);

    final snap = await _eventsCol
        .where('startAt',
            isGreaterThanOrEqualTo: monthStart.toIso8601String())
        .where('startAt', isLessThan: monthEnd.toIso8601String())
        .get();

    final counts = <DateTime, int>{};
    for (final doc in snap.docs) {
      final startAtStr = doc.data()['startAt']?.toString() ?? '';
      final dt = DateTime.tryParse(startAtStr);
      if (dt != null) {
        final dayKey = DateTime(dt.year, dt.month, dt.day);
        counts[dayKey] = (counts[dayKey] ?? 0) + 1;
      }
    }
    return counts;
  }
}
