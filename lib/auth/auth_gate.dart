import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../navigation/main_navigation.dart';
import '../roles/admin_home.dart';
import '../roles/caregiver_home.dart';
import '../roles/doctor_home.dart';
import 'auth_service.dart';
import 'login_screen.dart';
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
  AuthService get _auth => widget._authService ?? AuthService();
  UserProfileService get _profiles =>
      widget._profileService ?? UserProfileService();
  String? _ensuringUid;
  Future<void>? _ensureFuture;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          _ensuringUid = null;
          _ensureFuture = null;
          return LoginScreen(authService: _auth);
        }
        if (_ensuringUid != user.uid || _ensureFuture == null) {
          _ensuringUid = user.uid;
          _ensureFuture = _profiles.ensureUserDocExists(
            user.uid,
            email: user.email,
            displayName: user.displayName,
          );
        }
        return FutureBuilder<void>(
          future: _ensureFuture,
          builder: (context, ensureSnapshot) {
            if (ensureSnapshot.hasError) {
              return _ErrorState(
                message: 'Profil konnte nicht geladen werden.',
                onRetry: () => setState(() {}),
                onSignOut: _auth.signOut,
              );
            }
            if (ensureSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return StreamBuilder<AppUserRole>(
              stream: _profiles.watchMyRole(),
              initialData: AppUserRole.patient,
              builder: (context, roleSnapshot) {
                if (roleSnapshot.hasError) {
                  return _ErrorState(
                    message: 'Rolle konnte nicht geladen werden.',
                    onRetry: () => setState(() {}),
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
                  AppUserRole.caregiver => const CaregiverHome(),
                  AppUserRole.admin => const AdminHome(),
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
