import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../firebase/app_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/doctor_invite.dart';

class DoctorInviteService {
  DoctorInviteService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? appFunctions();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  static const Duration _expireAfter = Duration(hours: 48);

  /// Creates an invite via the `createDoctorInvite` Cloud Function and
  /// returns a [DoctorInvite] with the generated code.
  Future<DoctorInvite> createInvite() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht eingeloggt');

    final callable = _functions.httpsCallable('createDoctorInvite');
    final dynamic result;
    try {
      result = await callable.call<dynamic>(<String, dynamic>{});
    } on FirebaseFunctionsException {
      rethrow;
    }
    if (result.data is! Map) {
      throw StateError('Ungültige Server-Antwort');
    }
    final data = Map<String, dynamic>.from(result.data as Map);

    final code = (data['code'] ?? '').toString();
    if (code.isEmpty) throw StateError('Kein Invite Code erhalten');

    final expiresAtStr = (data['expiresAt'] ?? '').toString();
    final expiresAt =
        DateTime.tryParse(expiresAtStr) ?? DateTime.now().add(_expireAfter);

    return DoctorInvite(
      code: code,
      doctorUid: uid,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      status: InviteStatus.pending,
    );
  }

  /// Builds a shareable deep-link URL for the invite code.
  String buildDeepLink(String code) {
    return 'https://operationsbegleiter-860e7.web.app/doctor-invite/$code';
  }

  /// Shares the invite code via the system share sheet.
  Future<void> shareInvite(DoctorInvite invite) async {
    final link = buildDeepLink(invite.code);
    final text =
        'Verbinden Sie sich mit Ihrem Arzt in der Operationsbegleiter-App.\n\n'
        'Code: ${invite.code}\n'
        'Link: $link';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Accepts an invite code (called from patient side).
  /// Routes through the `acceptDoctorInvite` Cloud Function so that
  /// Firestore link documents are created server-side.
  Future<void> acceptInvite(String code) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht eingeloggt');

    final callable = _functions.httpsCallable('acceptDoctorInvite');
    try {
      await callable.call<dynamic>({'code': code.trim().toUpperCase()});
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  // ── Permanent doctor code ──────────────────────────────────────

  /// Returns the doctor's permanent invite code.
  /// Creates one server-side if it doesn't exist yet.
  Future<String> getPermanentCode() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht eingeloggt');

    final callable = _functions.httpsCallable('getDoctorPermanentCode');
    final result = await callable.call<dynamic>(<String, dynamic>{});
    final data = Map<String, dynamic>.from(result.data as Map);
    final code = (data['code'] ?? '').toString();
    if (code.isEmpty) throw StateError('Kein Code erhalten');
    return code;
  }

  /// Builds a deep-link URL for a permanent doctor code.
  String buildPermanentDeepLink(String code) {
    return 'https://operationsbegleiter-860e7.web.app/doctor-link/$code';
  }

  /// Shares the permanent QR code link via the system share sheet.
  Future<void> sharePermanentCode(String code) async {
    final link = buildPermanentDeepLink(code);
    final text =
        'Verbinden Sie sich mit Ihrem Arzt in der Operationsbegleiter-App.\n\n'
        'Link: $link';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Accepts a permanent doctor code (called from patient side).
  Future<void> acceptPermanentCode(String code) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht eingeloggt');

    final callable = _functions.httpsCallable('acceptDoctorPermanentCode');
    try {
      await callable.call<dynamic>({'code': code.trim().toUpperCase()});
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  /// Stream of all pending invites for the current doctor.
  /// For staff members, queries by the assigned doctor's UID.
  Stream<List<DoctorInvite>> watchMyInvites({String? doctorUid}) {
    final uid = doctorUid ?? _auth.currentUser?.uid;
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
