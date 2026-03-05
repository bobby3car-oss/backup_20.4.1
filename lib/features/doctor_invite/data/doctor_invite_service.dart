import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/doctor_invite.dart';

class DoctorInviteService {
  DoctorInviteService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const int _codeLength = 6;
  static const Duration _expireAfter = Duration(hours: 48);

  /// Generates a 6-character alphanumeric invite code.
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(
      _codeLength,
      (_) => chars[rng.nextInt(chars.length)],
    ).join();
  }

  /// Creates an invite, stores it in Firestore, and returns it.
  Future<DoctorInvite> createInvite() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht eingeloggt');

    final code = _generateCode();
    final now = DateTime.now();
    final invite = DoctorInvite(
      code: code,
      doctorUid: uid,
      createdAt: now,
      expiresAt: now.add(_expireAfter),
      status: InviteStatus.pending,
    );

    await _firestore
        .collection(FirestorePaths.doctorInvites)
        .doc(code)
        .set(invite.toJson());

    return invite;
  }

  /// Builds a shareable deep-link URL for the invite code.
  String buildDeepLink(String code) {
    return 'https://operationsbegleiter.page.link/invite?code=$code';
  }

  /// Shares the invite code via the system share sheet.
  Future<void> shareInvite(DoctorInvite invite) async {
    final link = buildDeepLink(invite.code);
    final text =
        'Ihr Arzt möchte Sie in der Operationsbegleiter-App begleiten.\n\n'
        'Code: ${invite.code}\n'
        'Link: $link';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Accepts an invite code (called from patient side).
  Future<void> acceptInvite(String code) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht eingeloggt');

    final docRef =
        _firestore.collection(FirestorePaths.doctorInvites).doc(code);
    final doc = await docRef.get();
    if (!doc.exists) throw StateError('Ungültiger Code');

    final invite = DoctorInvite.fromJson(code, doc.data()!);
    if (!invite.isActive) throw StateError('Einladung abgelaufen oder ungültig');

    final doctorUid = invite.doctorUid;

    // Create link in patient's links sub-collection.
    // Convention: doc ID = {linkedUid}_{linkType}
    final linkDocId = '${doctorUid}_doctor';
    await _firestore
        .doc('${FirestorePaths.linksCollection(uid)}/$linkDocId')
        .set(<String, dynamic>{
      'linkedUid': doctorUid,
      'linkType': 'doctor',
      'status': 'active',
      'permissions': {'read': true, 'write': false},
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Mark invite as accepted.
    await docRef.update({'status': InviteStatus.accepted.name});
  }

  /// Stream of all pending invites for the current doctor.
  Stream<List<DoctorInvite>> watchMyInvites() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection(FirestorePaths.doctorInvites)
        .where('doctorUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DoctorInvite.fromJson(d.id, d.data()))
            .toList(growable: false));
  }
}
