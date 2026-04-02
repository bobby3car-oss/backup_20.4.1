import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/doctor_staff/domain/staff_permissions.dart';

import '../features/onboarding_questionnaire/presentation/onboarding_questionnaire_screen.dart';
import '../navigation/main_navigation.dart';
import '../roles/admin/admin_home.dart';
import '../roles/doctor_home.dart';
import '../roles/org_home.dart';
import '../screens/onboarding/onboarding_carousel.dart';
import 'auth_service.dart';
import 'post_auth_transition.dart';
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
  Future<_BootstrapSessionState>? _bootstrapFuture;
  _BootstrapSessionState? _bootstrapOverride;
  bool _onboardingSeen = false;
  bool _guestMode = false;
  Timer? _webFallbackTimer;
  // Flags load synchronously from the SharedPreferences cache that was
  // pre-warmed in main().  Default to loaded=true so we never show a
  // spinner just for reading two booleans.
  final bool _flagsLoaded = true;
  bool _questionnaireCompleteCache = false;
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
    _webFallbackTimer?.cancel();
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
          _bootstrapFuture = null;
          _bootstrapOverride = null;
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
          _bootstrapOverride = null;
          _bootstrapFuture = _resolveBootstrapSession(user);
          // Safety net: if bootstrap hangs on web, force a one-time reload.
          _scheduleWebFallbackReload();
        }
        return FutureBuilder<_BootstrapSessionState>(
          future: _bootstrapFuture,
          initialData: _bootstrapOverride,
          builder: (context, bootstrapSnapshot) {
            if (bootstrapSnapshot.hasError) {
              return _ErrorState(
                message: 'Rolle konnte nicht geladen werden.',
                onRetry: () => setState(() {
                  _bootstrapOverride = null;
                  _bootstrapFuture = _resolveBootstrapSession(user);
                }),
                onSignOut: _auth.signOut,
              );
            }
            final bootstrap = bootstrapSnapshot.data;
            if (bootstrap == null) {
              return const Scaffold(
                backgroundColor: Color(0xFFF2F2F7),
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Bootstrap resolved — cancel fallback timer.
            _webFallbackTimer?.cancel();
            _webFallbackTimer = null;
            final role = bootstrap.role;
            if (kDebugMode) {
              debugPrint(
                '[AuthGate] bootstrap role=$role '
                'onboarding=${bootstrap.onboardingComplete} uid=${user.uid}',
              );
            }
            if (role == AppUserRole.patient) {
              return _buildPatientGate(user, bootstrap);
            }
            return switch (role) {
              AppUserRole.patient => const MainNavigation(),
              AppUserRole.doctor => const DoctorHome(),
              AppUserRole.staff => DoctorHome(
                isStaff: true,
                doctorUid: bootstrap.staffOf,
                canManageStaff: bootstrap.canManageStaff,
              ),
              AppUserRole.admin => const AdminHome(),
              AppUserRole.organisation => const OrgHome(),
            };
          },
        );
      },
    );
  }

  Widget _buildPatientGate(User user, _BootstrapSessionState bootstrap) {
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

    if (!bootstrap.onboardingComplete) {
      return OnboardingQuestionnaireScreen(
        onComplete: () {
          _questionnaireCompleteCache = true;
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(AuthGate.kQuestionnaireCompleteKey, true);
          });
          setState(() {
            _bootstrapOverride = bootstrap.copyWith(onboardingComplete: true);
          });
        },
      );
    }

    if (!_questionnaireCompleteCache) {
      _questionnaireCompleteCache = true;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool(AuthGate.kQuestionnaireCompleteKey, true);
      });
    }
    return widget._patientHome ?? const MainNavigation();
  }

  Future<_BootstrapSessionState> _resolveBootstrapSession(User user) async {
    try {
      await AuthService.waitForWebSessionReady(
        authTimeout: const Duration(seconds: 6),
        tokenTimeout: const Duration(seconds: 4),
      );
    } catch (_) {
      // Best effort only. The backend bootstrap below still has its own
      // fallbacks if the web auth handoff is slow.
    }

    final cached = await _readBootstrapCache(user.uid);
    final tokenRole = await _roleFromClaims(user);
    final fallback = _fallbackBootstrapState(cached: cached, tokenRole: tokenRole);

    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('resolveBootstrapSession');
      final result = await callable.call(<String, dynamic>{}).timeout(
            const Duration(seconds: 5),
          );
      final data = Map<String, dynamic>.from(result.data as Map);
      final resolved = _BootstrapSessionState.fromMap(data, fallback: fallback);
      unawaited(_writeBootstrapCache(user.uid, resolved));
      return resolved;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthGate] resolveBootstrapSession failed: $e');
      }
      return fallback;
    }
  }

  _BootstrapSessionState _fallbackBootstrapState({
    _BootstrapSessionState? cached,
    AppUserRole? tokenRole,
  }) {
    final role = cached?.role ?? tokenRole ?? AppUserRole.patient;
    final onboardingComplete =
        role == AppUserRole.patient ? (cached?.onboardingComplete ?? _questionnaireCompleteCache) : true;
    return _BootstrapSessionState(
      role: role,
      onboardingComplete: onboardingComplete,
      staffOf: cached?.staffOf,
      canManageStaff: cached?.canManageStaff ?? false,
    );
  }

  /// On web, if the bootstrap (Cloud Function + fallback) takes more than
  /// 4 seconds, force a full page reload.  SharedPreferences is used
  /// as a cooldown so we don't reload more than once per 30 seconds.
  void _scheduleWebFallbackReload() {
    if (!kIsWeb) return;
    _webFallbackTimer?.cancel();
    _webFallbackTimer = Timer(const Duration(seconds: 4), () async {
      if (!mounted || _bootstrapOverride != null) return;
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastReload = prefs.getInt('web_fallback_reload_ts') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastReload < 30000) {
          // Already reloaded recently — don't loop.
          if (kDebugMode) {
            debugPrint('[AuthGate] web fallback: skipped (cooldown)');
          }
          return;
        }
        await prefs.setInt('web_fallback_reload_ts', now);
        if (kDebugMode) {
          debugPrint('[AuthGate] web fallback: reloading page');
        }
        reloadCurrentPage();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[AuthGate] web fallback reload failed: $e');
        }
      }
    });
  }

  Future<AppUserRole?> _roleFromClaims(User user) async {
    try {
      final result = await user.getIdTokenResult(true).timeout(
            const Duration(seconds: 3),
          );
      final claims = result.claims ?? const <String, dynamic>{};
      if (claims['admin'] == true) {
        final email = user.email?.toLowerCase().trim() ?? '';
        if (email == allowedAdminEmail) return AppUserRole.admin;
      }
      if (claims['organisation'] == true) return AppUserRole.organisation;
      if (claims['doctor'] == true) return AppUserRole.doctor;
      if (claims['staff'] == true) return AppUserRole.staff;
    } catch (_) {
      // Best effort only.
    }
    return null;
  }

  Future<_BootstrapSessionState?> _readBootstrapCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roleName = prefs.getString('bootstrap_role_$uid');
      if (roleName == null || roleName.isEmpty) return null;

      AppUserRole role = AppUserRole.patient;
      for (final candidate in AppUserRole.values) {
        if (candidate.name == roleName) {
          role = candidate;
          break;
        }
      }

      return _BootstrapSessionState(
        role: role,
        onboardingComplete: role == AppUserRole.patient
            ? prefs.getBool(AuthGate.kQuestionnaireCompleteKey) ?? false
            : true,
        staffOf: prefs.getString('bootstrap_staff_of_$uid'),
        canManageStaff: prefs.getBool('bootstrap_staff_manage_$uid') ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeBootstrapCache(
    String uid,
    _BootstrapSessionState state,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bootstrap_role_$uid', state.role.name);
      if (state.staffOf != null && state.staffOf!.isNotEmpty) {
        await prefs.setString('bootstrap_staff_of_$uid', state.staffOf!);
      } else {
        await prefs.remove('bootstrap_staff_of_$uid');
      }
      await prefs.setBool('bootstrap_staff_manage_$uid', state.canManageStaff);
      if (state.role == AppUserRole.patient) {
        await prefs.setBool(
          AuthGate.kQuestionnaireCompleteKey,
          state.onboardingComplete,
        );
      }
    } catch (_) {
      // Best effort only.
    }
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

class _BootstrapSessionState {
  const _BootstrapSessionState({
    required this.role,
    required this.onboardingComplete,
    this.staffOf,
    this.canManageStaff = false,
  });

  final AppUserRole role;
  final bool onboardingComplete;
  final String? staffOf;
  final bool canManageStaff;

  _BootstrapSessionState copyWith({
    AppUserRole? role,
    bool? onboardingComplete,
    String? staffOf,
    bool? canManageStaff,
  }) {
    return _BootstrapSessionState(
      role: role ?? this.role,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      staffOf: staffOf ?? this.staffOf,
      canManageStaff: canManageStaff ?? this.canManageStaff,
    );
  }

  static _BootstrapSessionState fromMap(
    Map<String, dynamic> map, {
    required _BootstrapSessionState fallback,
  }) {
    final rawRole = map['role']?.toString() ?? '';
    var role = fallback.role;
    for (final candidate in AppUserRole.values) {
      if (candidate.name == rawRole) {
        role = candidate;
        break;
      }
    }

    var canManageStaff = fallback.canManageStaff;
    final rawPermissions = map['staffPermissions'];
    if (rawPermissions is Map) {
      final perms = StaffPermissions.fromMap(
        Map<String, dynamic>.from(rawPermissions),
      );
      canManageStaff = perms.manageStaff == StaffAccessLevel.readWrite;
    }

    return _BootstrapSessionState(
      role: role,
      onboardingComplete:
          map['onboardingComplete'] == true || (role != AppUserRole.patient),
      staffOf: (map['staffOf'] ?? fallback.staffOf)?.toString(),
      canManageStaff: canManageStaff,
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
