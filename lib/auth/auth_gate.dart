import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/main_navigation.dart';
import '../roles/admin/admin_home.dart';
import '../features/family/presentation/family_home.dart';
import '../roles/doctor_home.dart';
import '../screens/onboarding/onboarding_carousel.dart';
import '../features/onboarding_questionnaire/data/questionnaire_repository.dart';
import '../features/onboarding_questionnaire/presentation/onboarding_questionnaire_screen.dart';
import '../screens/onboarding/pro_promo_screen.dart';
import '../ui/screens/maintenance_screen.dart';
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
  AuthService get _auth => widget._authService ?? AuthService();
  UserProfileService get _profiles =>
      widget._profileService ?? UserProfileService();
  String? _ensuringUid;
  Future<void>? _ensureFuture;

  /// Cached SharedPreferences future to avoid re-reading on every build.
  late final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  Widget _buildDestination(AppUserRole role) {
    final destination = switch (role) {
      AppUserRole.patient =>
        widget._patientHome ?? const MainNavigation(),
      AppUserRole.doctor => const _DoctorVerificationGate(),
      AppUserRole.family => const FamilyHome(),
      AppUserRole.admin => const AdminHome(),
    };
    if (role == AppUserRole.patient) {
      return _ProPromoGate(
        prefsFuture: _prefsFuture,
        child: _OnboardingQuestionnaireGate(child: destination),
      );
    }
    return destination;
  }

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

        // ── Not logged in → Onboarding or Auth slide ─────────
        if (user == null) {
          _ensuringUid = null;
          _ensureFuture = null;
          return FutureBuilder<SharedPreferences>(
            future: _prefsFuture,
            builder: (context, prefsSnap) {
              if (!prefsSnap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final seen =
                  prefsSnap.data!.getBool(kOnboardingSeenKey) ?? false;
              return OnboardingCarousel(skipToAuth: seen);
            },
          );
        }

        // ── Logged in → ensure profile, then route ───────────
        if (_ensuringUid != user.uid || _ensureFuture == null) {
          _ensuringUid = user.uid;
          _ensureFuture = _profiles.ensureUserDocExists(
            user.uid,
            email: user.email,
            displayName: user.displayName,
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              // Offline or slow — proceed anyway for returning users.
            },
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

                // Maintenance mode gate — admins always pass.
                if (role != AppUserRole.admin) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .doc('appConfig/global')
                        .snapshots(),
                    builder: (context, configSnap) {
                      final data = configSnap.data?.data()
                          as Map<String, dynamic>?;
                      if (data != null &&
                          data['maintenanceMode'] == true) {
                        return MaintenanceScreen(
                          message: data['maintenanceMessage'] as String?,
                        );
                      }
                      return _buildDestination(role);
                    },
                  );
                }

                return _buildDestination(role);
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Shows [ProPromoScreen] once after first login, then the actual [child].
class _ProPromoGate extends StatefulWidget {
  const _ProPromoGate({required this.prefsFuture, required this.child});
  final Future<SharedPreferences> prefsFuture;
  final Widget child;

  @override
  State<_ProPromoGate> createState() => _ProPromoGateState();
}

class _ProPromoGateState extends State<_ProPromoGate> {
  bool? _proPromoSeen;

  @override
  void initState() {
    super.initState();
    _checkProPromo();
  }

  Future<void> _checkProPromo() async {
    final prefs = await widget.prefsFuture;
    if (!mounted) return;
    setState(() {
      _proPromoSeen = prefs.getBool(kProPromoSeenKey) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_proPromoSeen == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_proPromoSeen == false) {
      return ProPromoScreen(
        onDismiss: () => setState(() => _proPromoSeen = true),
      );
    }
    return widget.child;
  }
}

/// Shows the [OnboardingQuestionnaireScreen] if the patient hasn't completed
/// the initial questionnaire yet, then transitions to [child].
class _OnboardingQuestionnaireGate extends StatefulWidget {
  const _OnboardingQuestionnaireGate({required this.child});
  final Widget child;

  @override
  State<_OnboardingQuestionnaireGate> createState() =>
      _OnboardingQuestionnaireGateState();
}

class _OnboardingQuestionnaireGateState
    extends State<_OnboardingQuestionnaireGate> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Check local cache first for offline resilience.
    final prefs = await SharedPreferences.getInstance();
    final cachedKey = 'onboarding_complete_$uid';
    if (prefs.getBool(cachedKey) == true) {
      if (mounted) setState(() => _onboardingComplete = true);
      return;
    }

    try {
      final complete = await QuestionnaireRepository()
          .isOnboardingComplete(uid)
          .timeout(const Duration(seconds: 6), onTimeout: () => true);
      if (complete) await prefs.setBool(cachedKey, true);
      if (!mounted) return;
      setState(() => _onboardingComplete = complete);
    } catch (_) {
      // Offline — assume complete for returning users.
      if (!mounted) return;
      setState(() => _onboardingComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_onboardingComplete == false) {
      return OnboardingQuestionnaireScreen(
        onComplete: () => setState(() => _onboardingComplete = true),
      );
    }
    return widget.child;
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

// ─────────────────────────────────────────────────────────────────────────────
// Doctor Verification Gate – shows pending screen or DoctorHome
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorVerificationGate extends StatelessWidget {
  const _DoctorVerificationGate();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.doc('users/$uid').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final verified = data?['doctorVerified'] == true;
        final rejected = data?['verificationRejected'] == true;

        if (verified) return const DoctorHome();

        return _DoctorPendingScreen(rejected: rejected);
      },
    );
  }
}

class _DoctorPendingScreen extends StatelessWidget {
  const _DoctorPendingScreen({this.rejected = false});
  final bool rejected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (rejected ? Colors.red : Colors.orange)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    rejected
                        ? Icons.cancel_outlined
                        : Icons.hourglass_top_rounded,
                    color: rejected ? Colors.red : Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  rejected
                      ? 'Verifizierung abgelehnt'
                      : 'Verifizierung ausstehend',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  rejected
                      ? 'Ihr Antrag wurde leider abgelehnt. '
                        'Bitte kontaktieren Sie den Support für '
                        'weitere Informationen.'
                      : 'Ihr Konto wird derzeit von unserem Team '
                        'geprüft. Sie erhalten Zugang, sobald die '
                        'Verifizierung abgeschlossen ist.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => AuthService().signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Abmelden'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
