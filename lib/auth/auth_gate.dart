import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/onboarding_questionnaire/data/questionnaire_repository.dart';
import '../features/onboarding_questionnaire/presentation/onboarding_questionnaire_screen.dart';
import '../navigation/main_navigation.dart';
import '../roles/admin/admin_home.dart';
import '../roles/doctor_home.dart';
import '../roles/org_home.dart';
import '../screens/onboarding/onboarding_carousel.dart';
import 'auth_service.dart';
import 'user_profile_service.dart';
import '../l10n/app_localizations.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    AuthService? authService,
    UserProfileService? profileService,
    Widget? patientHome,
  }) : _authService = authService,
       _profileService = profileService,
       _patientHome = patientHome;

  /// Notifier that pushed screens (e.g. RegisterScreen) can set to trigger
  /// guest mode.  AuthGate listens to this and rebuilds.
  static final guestModeNotifier = ValueNotifier<bool>(false);

  static const String kGuestModeKey = 'guest_mode_active';
  static const String kGuestQuestionnaireKey = 'guest_questionnaire_complete';
  static const String kQuestionnaireCompleteKey = 'questionnaire_complete';

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
  String? _roleUid;
  Stream<AppUserRole>? _roleStream;
  bool _onboardingSeen = false;
  bool _guestMode = false;
  // Flags load synchronously from the SharedPreferences cache that was
  // pre-warmed in main().  Default to loaded=true so we never show a
  // spinner just for reading two booleans.
  final bool _flagsLoaded = true;
  bool _questionnaireCompleteCache = false;
  Future<bool>? _questionnaireFuture;
  String? _questionnaireUid;
  Future<bool>? _guestQuestionnaireFuture;

  @override
  void initState() {
    super.initState();
    _auth = widget._authService ?? AuthService();
    _profiles = widget._profileService ?? UserProfileService();
    _authStream = _auth.currentUser;
    _loadFlags();
    AuthGate.guestModeNotifier.addListener(_onGuestModeChanged);
  }

  @override
  void dispose() {
    AuthGate.guestModeNotifier.removeListener(_onGuestModeChanged);
    super.dispose();
  }

  void _onGuestModeChanged() {
    if (AuthGate.guestModeNotifier.value && !_guestMode) {
      setState(() => _guestMode = true);
    }
  }

  Future<void> _loadFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool(kOnboardingSeenKey) ?? false;
      final guest = prefs.getBool(AuthGate.kGuestModeKey) ?? false;
      _questionnaireCompleteCache =
          prefs.getBool(AuthGate.kQuestionnaireCompleteKey) ?? false;
      // Only trigger a rebuild if the values differ from the defaults.
      if (mounted && (seen != _onboardingSeen || guest != _guestMode)) {
        setState(() {
          _onboardingSeen = seen;
          _guestMode = guest;
        });
      }
      if (guest) AuthGate.guestModeNotifier.value = true;
    } catch (_) {
      // SharedPreferences failure – keep defaults, no spinner needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_flagsLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return StreamBuilder<User?>(
      stream: _authStream,
      // Use the synchronously available currentUser so the very first
      // frame never shows a "waiting" spinner.
      initialData: _auth.user,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          // When transitioning from logged-in to logged-out, reset
          // the onboarding flag so the full onboarding carousel
          // (with doctor/org registration) is shown again.
          // Important: do NOT reset _guestMode here – the user may have
          // just activated guest mode in this same frame via setState().
          // Guest mode is only cleared when a real user signs in (see below).
          if (_ensuringUid != null) {
            _onboardingSeen = false;
            _guestQuestionnaireFuture = null;
          }
          _ensuringUid = null;
          _roleUid = null;
          _roleStream = null;
          if (_guestMode) {
            return _buildGuestGate();
          }
          // Always show the OnboardingCarousel for unauthenticated users.
          // If onboarding was already seen, skip straight to the auth slide
          // (light background with login/register/guest buttons) instead of
          // the dark LoginScreen.
          return OnboardingCarousel(
            skipToAuth: _onboardingSeen,
            onSkipAsGuest: () {
              // Immediately transition – no await so the UI responds on tap.
              setState(() {
                _onboardingSeen = true;
                _guestMode = true;
              });
              AuthGate.guestModeNotifier.value = true;
              // Persist in background (non-blocking).
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool(kOnboardingSeenKey, true);
                prefs.setBool(AuthGate.kGuestModeKey, true);
              });
            },
          );
        }
        if (_ensuringUid != user.uid) {
          // Fresh authentication – dismiss any pushed auth overlay
          // routes (register, login, carousel) so the root route
          // reveals the main app flow.
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
          // Clear guest mode when user authenticates.
          _guestMode = false;
          AuthGate.guestModeNotifier.value = false;
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove(AuthGate.kGuestModeKey);
            prefs.remove(AuthGate.kGuestQuestionnaireKey);
          });
          _ensuringUid = user.uid;
          // Bootstrap runs in background – Firestore writes do not block the
          // first frame. For returning users the docs already exist; for new
          // users the Firestore SDK commits the write to the local cache
          // immediately so subsequent reads (watchMyRole, isOnboardingComplete)
          // see the data without waiting for server ACK.
          unawaited(
            _profiles
                .ensureUserDocExists(
                  user.uid,
                  email: user.email,
                  displayName: user.displayName,
                )
                .catchError((Object e) {
              if (kDebugMode) {
                debugPrint('[AuthGate] ensureUserDoc failed: $e');
              }
            }),
          );
        }
        if (_roleUid != user.uid) {
          _roleUid = user.uid;
          _roleStream = _profiles.watchMyRole();
        }
        // Bootstrap is fire-and-forget, so skip the FutureBuilder wrapper
        // entirely – go straight to the role stream.
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
            final role = roleSnapshot.data ?? AppUserRole.patient;
            if (role == AppUserRole.patient) {
              return _buildPatientGate(user);
            }
            return switch (role) {
              AppUserRole.patient => const MainNavigation(),
              AppUserRole.doctor => const DoctorHome(),
              AppUserRole.staff => const DoctorHome(isStaff: true),
              AppUserRole.admin => const AdminHome(),
              AppUserRole.organisation => const OrgHome(),
            };
          },
        );
      },
    );
  }

  Widget _buildPatientGate(User user) {
    if (_questionnaireUid != user.uid) {
      _questionnaireUid = user.uid;
      _questionnaireFuture =
          QuestionnaireRepository().isOnboardingComplete(user.uid);
    }
    return FutureBuilder<bool>(
      future: _questionnaireFuture,
      // Use cached result so returning patients skip the spinner entirely.
      initialData: _questionnaireCompleteCache ? true : null,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done && !snap.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF2F2F7),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final complete = snap.data ?? false;
        if (!complete) {
          return OnboardingQuestionnaireScreen(
            onComplete: () => setState(() {
              _questionnaireUid = null;
              _questionnaireFuture = null;
            }),
          );
        }
        // Persist for instant startup next time.
        if (!_questionnaireCompleteCache) {
          _questionnaireCompleteCache = true;
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(AuthGate.kQuestionnaireCompleteKey, true);
          });
        }
        return widget._patientHome ?? const MainNavigation();
      },
    );
  }

  Widget _buildGuestGate() {
    _guestQuestionnaireFuture ??= SharedPreferences.getInstance().then(
      (prefs) => prefs.getBool(AuthGate.kGuestQuestionnaireKey) ?? false,
    );
    return FutureBuilder<bool>(
      future: _guestQuestionnaireFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFF2F2F7),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final complete = snap.data ?? false;
        if (!complete) {
          return OnboardingQuestionnaireScreen(
            onComplete: () => setState(() {
              _guestQuestionnaireFuture = null;
            }),
          );
        }
        return widget._patientHome ?? const MainNavigation();
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
    final l = AppLocalizations.of(context)!;
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
                child: Text(l.retry),
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
