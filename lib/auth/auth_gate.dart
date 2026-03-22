import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../navigation/main_navigation.dart';
import '../roles/admin/admin_home.dart';
import '../roles/caregiver_home.dart';
import '../roles/doctor_home.dart';
import '../roles/org_home.dart';
import '../screens/onboarding/login_screen.dart';
import 'auth_service.dart';
import 'user_profile_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    AuthService? authService,
    UserProfileService? profileService,
    Widget? patientHome,
  }) : _authService = authService,
       _profileService = profileService,
       _patientHome = patientHome;

  final AuthService? _authService;
  final UserProfileService? _profileService;
  final Widget? _patientHome;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _auth;
  late final UserProfileService _profiles;
  late final Stream<User?> _authStream;
  String? _ensuringUid;
  Future<void>? _ensureFuture;
  String? _roleUid;
  Stream<AppUserRole>? _roleStream;

  @override
  void initState() {
    super.initState();
    _auth = widget._authService ?? AuthService();
    _profiles = widget._profileService ?? UserProfileService();
    _authStream = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          _ensuringUid = null;
          _ensureFuture = null;
          _roleUid = null;
          _roleStream = null;
          return const LoginScreen();
        }
        if (_ensuringUid != user.uid || _ensureFuture == null) {
          _ensuringUid = user.uid;
          _ensureFuture = _profiles.ensureUserDocExists(
            user.uid,
            email: user.email,
            displayName: user.displayName,
          );
        }
        if (_roleUid != user.uid) {
          _roleUid = user.uid;
          _roleStream = _profiles.watchMyRole();
        }
        return FutureBuilder<void>(
          future: _ensureFuture,
          builder: (context, ensureSnapshot) {
            if (ensureSnapshot.hasError) {
              return _ErrorState(
                message: 'Profil konnte nicht geladen werden.',
                onRetry: () => setState(() {
                  _ensuringUid = null;
                  _ensureFuture = null;
                  _roleUid = null;
                  _roleStream = null;
                }),
                onSignOut: _auth.signOut,
              );
            }
            if (ensureSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return StreamBuilder<AppUserRole>(
              stream: _roleStream,
              initialData: AppUserRole.patient,
              builder: (context, roleSnapshot) {
                if (roleSnapshot.hasError) {
                  return _ErrorState(
                    message: 'Rolle konnte nicht geladen werden.',
                    onRetry: () => setState(() {
                      _roleUid = null;
                      _roleStream = null;
                    }),
                    onSignOut: _auth.signOut,
                  );
                }
                if (roleSnapshot.connectionState == ConnectionState.waiting &&
                    !roleSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final role = roleSnapshot.data ?? AppUserRole.patient;
                return switch (role) {
                  AppUserRole.patient =>
                    widget._patientHome ?? const MainNavigation(),
                  AppUserRole.doctor => const DoctorHome(),
                  AppUserRole.staff =>
                    const DoctorHome(isStaff: true),
                  AppUserRole.family => const CaregiverHome(),
                  AppUserRole.admin => const AdminHome(),
                  AppUserRole.organisation => const OrgHome(),
                };
              },
            );
          },
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Erneut versuchen'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onSignOut, child: const Text('Logout')),
            ],
          ),
        ),
      ),
    );
  }
}
