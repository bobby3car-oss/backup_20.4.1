import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/profile/data/profile_boundary_repository.dart';
import '../firebase/app_functions.dart';
import '../firebase/bootstrap_service.dart';

/// Only this email is allowed to hold the admin role.
///
/// Injected at build time via `--dart-define=ADMIN_EMAIL=your@email.com`.
/// When empty, admin access is controlled purely by Firebase Custom Claims.
const allowedAdminEmail = String.fromEnvironment('ADMIN_EMAIL');

enum AppUserRole { patient, doctor, admin, staff, organisation }

class UserProfileService {
  UserProfileService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      _bootstrap = BootstrapService(
        firestore: firestore ?? FirebaseFirestore.instance,
      ),
      _profileBoundaryRepository = ProfileBoundaryRepository(
        firestore: firestore ?? FirebaseFirestore.instance,
      );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final BootstrapService _bootstrap;
  final ProfileBoundaryRepository _profileBoundaryRepository;

  Future<void> ensureUserDocExists(
    String uid, {
    String? email,
    String? displayName,
  }) async {
    await Future.wait([
      _bootstrap.ensureUserDocExists(
        uid,
        email: email,
        displayName: displayName,
        roleDefault: AppUserRole.patient.name,
      ),
      _bootstrap.ensurePatientRootExists(uid),
    ]);
  }

  Future<void> ensureCurrentUserDocExists() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await ensureUserDocExists(
      user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  Stream<Map<String, dynamic>?> getMyUserDoc() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<Map<String, dynamic>?>.empty();
    }
    final uid = user.uid;
    return _profileBoundaryRepository.watchSelfProfile(uid);
  }

  Future<AppUserRole> getMyRole() async {
    final user = _auth.currentUser;
    if (user == null) return AppUserRole.patient;

    final userDoc = await _firestore.doc('users/${user.uid}').get();
    final role = _parseRole(userDoc.data()?['role']);
    return _enforceAdminRestriction(role);
  }

  Stream<AppUserRole> watchMyRole() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<AppUserRole>.empty();
    }
    // For the CURRENT user we can cross-check against custom claims, which
    // are server-signed and cannot be spoofed via a Firestore write. This
    // prevents a stale or tampered `role` field from escalating UI access
    // beyond what the verified claim allows.
    return _firestore.doc('users/${user.uid}').snapshots().asyncMap((snapshot) async {
      final firestoreRole = _parseRole(snapshot.data()?['role']);
      final claimRole = await _roleFromClaims();
      final effective = _reconcileRoles(firestoreRole, claimRole);
      return _enforceAdminRestriction(effective);
    });
  }

  /// Watches the role for a specific uid. Unlike [watchMyRole], this does
  /// not depend on [_auth.currentUser] being non-null at call time and does
  /// NOT cross-check claims (claims are only available for the current user).
  Stream<AppUserRole> watchRoleForUid(String uid) {
    return _firestore.doc('users/$uid').snapshots().map((snapshot) {
      final role = _parseRole(snapshot.data()?['role']);
      return _enforceAdminRestriction(role);
    });
  }

  /// Resolves the role from the current user's verified custom claims.
  Future<AppUserRole?> _roleFromClaims() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final result = await user.getIdTokenResult();
      final claims = result.claims ?? const <String, dynamic>{};
      if (claims['admin'] == true) return AppUserRole.admin;
      if (claims['organisation'] == true) return AppUserRole.organisation;
      if (claims['doctor'] == true) return AppUserRole.doctor;
      if (claims['staff'] == true) return AppUserRole.staff;
    } catch (_) {
      // Best effort — fall back to Firestore role.
    }
    return null;
  }

  /// Reconciles the Firestore role with the verified claim role. The claim
  /// is authoritative for elevated roles (admin/doctor/staff/organisation)
  /// because it is server-signed; a stale Firestore value must not upgrade
  /// a user silently. When Firestore shows an elevated role but the claim
  /// disagrees, prefer the claim (or patient if no claim) to fail closed.
  AppUserRole _reconcileRoles(AppUserRole firestoreRole, AppUserRole? claimRole) {
    const elevated = {
      AppUserRole.admin,
      AppUserRole.doctor,
      AppUserRole.staff,
      AppUserRole.organisation,
    };
    if (elevated.contains(firestoreRole) && firestoreRole != claimRole) {
      return claimRole ?? AppUserRole.patient;
    }
    return firestoreRole;
  }

  /// Ensures only the allowed email can hold the admin role.
  /// Any other account with admin role gets actively demoted to patient
  /// both client-side and in Firestore.
  ///
  /// Fail-closed: if [allowedAdminEmail] is not configured, admin role is
  /// always rejected on the client.
  AppUserRole _enforceAdminRestriction(AppUserRole role) {
    if (role != AppUserRole.admin) return role;
    // Unconfigured build: fail-closed on UI (show patient), but don't
    // write back to Firestore — the server-side enforceAdminRestriction
    // trigger is authoritative and a local misconfiguration must not
    // corrupt the authoritative role record.
    if (allowedAdminEmail.isEmpty) return AppUserRole.patient;
    final user = _auth.currentUser;
    final email = user?.email?.toLowerCase().trim() ?? '';
    if (email == allowedAdminEmail) return role;

    // Unauthorized admin — actively revoke in Firestore.
    if (user != null) {
      _revokeUnauthorizedAdmin(user.uid);
    }
    return AppUserRole.patient;
  }

  /// Actively demotes an unauthorized admin in Firestore and revokes the
  /// custom claim via Cloud Function.  Fire-and-forget so it doesn't block
  /// the UI stream.
  bool _revokingAdmin = false;
  void _revokeUnauthorizedAdmin(String uid) {
    if (_revokingAdmin) return; // prevent duplicate calls
    _revokingAdmin = true;
    Future<void>(() async {
      try {
        // 1. Overwrite role in Firestore.
        await _firestore.doc('users/$uid').set(
          {'role': 'patient', 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
        // 2. Ask backend to clear admin custom claim.
        await appFunctions().httpsCallable('refreshAdminClaim').call();
        // 3. Force token refresh so stale admin claim is gone.
        await _auth.currentUser?.getIdToken(true);
      } catch (_) {
        // Best-effort — server-side trigger will also catch this.
      } finally {
        _revokingAdmin = false;
      }
    });
  }

  Future<AppUserRole> roleForUid(String uid) async {
    final userDoc = await _firestore.doc('users/$uid').get();
    return _parseRole(userDoc.data()?['role']);
  }

  Future<int> getLinkedPatientsCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final query = await _firestore
        .collectionGroup('links')
        .where('linkedUid', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .get();
    return query.docs.length;
  }

  AppUserRole _parseRole(Object? raw) {
    final roleName = raw?.toString() ?? '';
    for (final role in AppUserRole.values) {
      if (role.name == roleName) return role;
    }
    return AppUserRole.patient;
  }

  Future<AppUserRole> get role => getMyRole();
}
