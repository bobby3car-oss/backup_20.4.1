import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase/app_functions.dart';
import '../domain/org_join_request.dart';

/// Service for a doctor to join an organisation via invite code.
class OrgMembershipService {
  OrgMembershipService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? appFunctions();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Submits a join request for an organisation using an invite code.
  Future<void> submitJoinRequest(String code) async {
    final callable = _functions.httpsCallable('requestJoinOrganisation');
    await callable.call<dynamic>({'code': code.trim().toUpperCase()});
  }

  /// Streams all join requests from the current doctor.
  Stream<List<OrgJoinRequest>> watchMyJoinRequests() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('org_join_requests')
        .where('doctorUid', isEqualTo: uid)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OrgJoinRequest.fromJson(d.id, d.data()))
            .toList(growable: false));
  }
}
