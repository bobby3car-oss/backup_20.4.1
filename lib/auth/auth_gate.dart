import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/main_navigation.dart';
import '../roles/admin/admin_home.dart';
import '../roles/doctor_home.dart';
import '../screens/onboarding/onboarding_carousel.dart';
import '../features/onboarding_questionnaire/data/questionnaire_repository.dart';
import '../features/onboarding_questionnaire/presentation/onboarding_questionnaire_screen.dart';
import '../screens/onboarding/pro_promo_screen.dart';
import '../ui/screens/maintenance_screen.dart';
import 'auth_service.dart';
import 'email_verification_banner.dart';
import 'guest_data_migration_service.dart';
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
  late final UserProfileService _profiles =
      widget._profileService ?? UserProfileService();
  String? _ensuringUid;
  Future<void>? _ensureFuture;
  bool _migrationTriggered = false;

  /// Cached streams to avoid re-creating on every build.
  Stream<AppUserRole>? _roleStream;
  String? _roleStreamUid;
  late final Stream<DocumentSnapshot> _maintenanceStream =
      FirebaseFirestore.instance.doc('appConfig/global').snapshots();

  /// Cached SharedPreferences future to avoid re-reading on every build.
  late final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  Widget _buildDestination(AppUserRole role) {
    final destination = switch (role) {
      AppUserRole.patient =>
        widget._patientHome ?? const MainNavigation(),
      AppUserRole.doctor => const _DoctorVerificationGate(),

      AppUserRole.family =>
        widget._patientHome ?? const MainNavigation(),
      AppUserRole.admin => const AdminHome(),
      AppUserRole.staff => const _StaffGate(),
    };

    // Wrap with email verification banner for all non-admin roles.
    final withBanner = role != AppUserRole.admin
        ? EmailVerificationBanner(child: destination)
        : destination;

    if (role == AppUserRole.patient || role == AppUserRole.family) {
      return _ProPromoGate(
        prefsFuture: _prefsFuture,
        child: _OnboardingQuestionnaireGate(child: withBanner),
      );
    }
    return withBanner;
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

        // ── Not logged in → Onboarding, Auth, or Guest mode ──
        if (user == null) {
          _ensuringUid = null;
          _ensureFuture = null;
          _roleStream = null;
          _roleStreamUid = null;
          return FutureBuilder<SharedPreferences>(
            future: _prefsFuture,
            builder: (context, prefsSnap) {
              if (!prefsSnap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final prefs = prefsSnap.data!;
              final seen =
                  prefs.getBool(kOnboardingSeenKey) ?? false;
              // Guest mode: user has already seen onboarding → go
              // straight to MainNavigation without authentication.
              if (seen) {
                return _GuestProPromoGate(
                  prefsFuture: _prefsFuture,
                  child: widget._patientHome ?? const MainNavigation(),
                );
              }
              return OnboardingCarousel(
                onSkipAsGuest: () async {
                  await prefs.setBool(kOnboardingSeenKey, true);
                  if (mounted) setState(() {});
                },
              );
            },
          );
        }

        // ── Logged in → ensure profile, then route ───────────
        if (_ensuringUid != user.uid || _ensureFuture == null) {
          _ensuringUid = user.uid;
          _migrationTriggered = false;
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

            // Trigger guest data migration once after login.
            if (!_migrationTriggered) {
              _migrationTriggered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  GuestDataMigrationService.promptMigrationIfNeeded(
                    context,
                    user.uid,
                  );
                }
              });
            }

            // Cache the role stream per UID so it isn't recreated
            // on every parent rebuild.
            final currentUid = user.uid;
            if (_roleStreamUid != currentUid || _roleStream == null) {
              _roleStreamUid = currentUid;
              _roleStream = _profiles.watchMyRole();
            }

            return StreamBuilder<AppUserRole>(
              stream: _roleStream,
              builder: (context, roleSnapshot) {
                if (roleSnapshot.hasError) {
                  return _ErrorState(
                    message: 'Rolle konnte nicht geladen werden.',
                    onRetry: () => setState(() {}),
                    onSignOut: _auth.signOut,
                  );
                }
                if (!roleSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final role = roleSnapshot.data!;

                // Maintenance mode gate — admins always pass.
                if (role != AppUserRole.admin) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: _maintenanceStream,
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
/// Shows [ProPromoScreen] to guest users after a configurable number of
/// sessions, then the actual [child]. "Pro testen" on the promo screen
/// triggers an auth prompt before navigating to the paywall.
class _GuestProPromoGate extends StatefulWidget {
  const _GuestProPromoGate({required this.prefsFuture, required this.child});
  final Future<SharedPreferences> prefsFuture;
  final Widget child;

  @override
  State<_GuestProPromoGate> createState() => _GuestProPromoGateState();
}

class _GuestProPromoGateState extends State<_GuestProPromoGate> {
  static const _sessionCountKey = 'guest_session_count';
  static const _promoSeenKey = 'pro_promo_seen_guest';
  static const _sessionThreshold = 3;

  bool _showPromo = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkAndIncrement();
  }

  Future<void> _checkAndIncrement() async {
    final prefs = await widget.prefsFuture;
    if (!mounted) return;
    final count = (prefs.getInt(_sessionCountKey) ?? 0) + 1;
    await prefs.setInt(_sessionCountKey, count);
    final alreadySeen = prefs.getBool(_promoSeenKey) ?? false;
    setState(() {
      _showPromo = count >= _sessionThreshold && !alreadySeen;
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_showPromo) {
      return ProPromoScreen(
        onDismiss: () async {
          final prefs = await widget.prefsFuture;
          await prefs.setBool(_promoSeenKey, true);
          if (mounted) setState(() => _showPromo = false);
        },
      );
    }
    return widget.child;
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

class _DoctorVerificationGate extends StatefulWidget {
  const _DoctorVerificationGate();

  @override
  State<_DoctorVerificationGate> createState() =>
      _DoctorVerificationGateState();
}

class _DoctorVerificationGateState extends State<_DoctorVerificationGate>
    with WidgetsBindingObserver {
  Stream<DocumentSnapshot>? _stream;
  String? _uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStream();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _stream = FirebaseFirestore.instance.doc('users/$uid').snapshots();
    }
  }

  /// Re-attach the Firestore listener when the app returns to the foreground
  /// so the doctor is redirected even if the connection was dropped while
  /// the app was in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        setState(() {
          _uid = uid;
          _stream = FirebaseFirestore.instance.doc('users/$uid').snapshots();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null || _stream == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _stream,
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

        return _DoctorPendingScreen(uid: _uid!, rejected: rejected);
      },
    );
  }
}

class _DoctorPendingScreen extends StatefulWidget {
  const _DoctorPendingScreen({required this.uid, this.rejected = false});
  final String uid;
  final bool rejected;

  @override
  State<_DoctorPendingScreen> createState() => _DoctorPendingScreenState();
}

class _DoctorPendingScreenState extends State<_DoctorPendingScreen> {
  bool _showResubmit = false;
  bool _submitting = false;

  final _nameCtrl = TextEditingController();
  final _approbationCtrl = TextEditingController();
  final _practiceNameCtrl = TextEditingController();
  final _kvNumberCtrl = TextEditingController();
  String? _selectedSpecialty;

  static const _specialties = <String>[
    'Allgemeinchirurgie',
    'Orthopädie & Unfallchirurgie',
    'Viszeralchirurgie',
    'Herzchirurgie',
    'Neurochirurgie',
    'Gefäßchirurgie',
    'Plastische Chirurgie',
    'Urologie',
    'Gynäkologie',
    'HNO',
    'Augenheilkunde',
    'Innere Medizin',
    'Anästhesiologie',
    'Sonstige',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.rejected) _loadPreviousData();
  }

  Future<void> _loadPreviousData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc('doctor_verifications/${widget.uid}')
          .get();
      final d = doc.data() ?? {};
      _nameCtrl.text = (d['name'] ?? '').toString();
      _approbationCtrl.text = (d['approbationNumber'] ?? '').toString();
      _practiceNameCtrl.text = (d['practiceName'] ?? '').toString();
      _kvNumberCtrl.text = (d['kvNumber'] ?? '').toString();
      if (mounted) {
        setState(() {
          _selectedSpecialty = (d['specialty'] ?? '').toString();
          if (_selectedSpecialty!.isEmpty ||
              !_specialties.contains(_selectedSpecialty)) {
            _selectedSpecialty = null;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _resubmit() async {
    final name = _nameCtrl.text.trim();
    final approbation = _approbationCtrl.text.trim();
    final practice = _practiceNameCtrl.text.trim();

    if (name.isEmpty || approbation.isEmpty || practice.isEmpty ||
        _selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte alle Pflichtfelder ausfüllen.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('resubmitDoctorVerification');
      await callable.call(<String, dynamic>{
        'name': name,
        'specialty': _selectedSpecialty,
        'approbationNumber': approbation,
        'practiceName': practice,
        'kvNumber': _kvNumberCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() => _showResubmit = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Antrag erneut eingereicht. '
              'Sie werden benachrichtigt, sobald die Prüfung abgeschlossen ist.'),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Fehler beim Einreichen')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ein Fehler ist aufgetreten.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _approbationCtrl.dispose();
    _practiceNameCtrl.dispose();
    _kvNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_showResubmit) return _buildResubmitForm(theme);

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
                    color: (widget.rejected ? Colors.red : Colors.orange)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.rejected
                        ? Icons.cancel_outlined
                        : Icons.hourglass_top_rounded,
                    color: widget.rejected ? Colors.red : Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.rejected
                      ? 'Verifizierung abgelehnt'
                      : 'Verifizierung ausstehend',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.rejected)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .doc('doctor_verifications/${widget.uid}')
                        .get(),
                    builder: (context, snap) {
                      final reason = (snap.data?.data()
                              as Map<String, dynamic>?)?['reason']
                          as String?;
                      return Column(
                        children: [
                          Text(
                            'Ihr Antrag wurde leider abgelehnt.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          if (reason != null && reason.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Begründung:',
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reason,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () =>
                                setState(() => _showResubmit = true),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Angaben korrigieren '
                                'und erneut einreichen'),
                          ),
                        ],
                      );
                    },
                  )
                else
                  Text(
                    'Ihr Konto wird derzeit von unserem Team '
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

  Widget _buildResubmitForm(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrag korrigieren'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _showResubmit = false),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Bitte korrigieren Sie Ihre Angaben und reichen '
              'Sie den Antrag erneut ein.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Vollständiger Name *',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSpecialty,
              decoration: const InputDecoration(
                labelText: 'Fachrichtung *',
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              items: _specialties
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSpecialty = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _approbationCtrl,
              decoration: const InputDecoration(
                labelText: 'Approbationsnummer *',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _practiceNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Praxisname *',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kvNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'KV-Nummer (optional)',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _submitting ? null : _resubmit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_submitting
                  ? 'Wird eingereicht…'
                  : 'Erneut einreichen'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Staff Gate – verifies staffOf link is active, then shows DoctorHome
// ─────────────────────────────────────────────────────────────────────────────

class _StaffGate extends StatefulWidget {
  const _StaffGate();

  @override
  State<_StaffGate> createState() => _StaffGateState();
}

class _StaffGateState extends State<_StaffGate> with WidgetsBindingObserver {
  Stream<DocumentSnapshot>? _userStream;
  String? _uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStream();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _userStream = FirebaseFirestore.instance.doc('users/$uid').snapshots();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        setState(() {
          _uid = uid;
          _userStream =
              FirebaseFirestore.instance.doc('users/$uid').snapshots();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null || _userStream == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final staffOf = data?['staffOf']?.toString();

        if (staffOf == null || staffOf.isEmpty) {
          return _StaffRevokedScreen();
        }

        // Verify the staff doc under the doctor is active.
        return _StaffStatusGate(uid: _uid!, staffOf: staffOf);
      },
    );
  }
}

/// Inner gate that watches the staff document status for a specific doctor.
/// Extracted so the stream is only recreated when [staffOf] actually changes.
class _StaffStatusGate extends StatefulWidget {
  const _StaffStatusGate({required this.uid, required this.staffOf});
  final String uid;
  final String staffOf;

  @override
  State<_StaffStatusGate> createState() => _StaffStatusGateState();
}

class _StaffStatusGateState extends State<_StaffStatusGate>
    with WidgetsBindingObserver {
  late Stream<DocumentSnapshot> _staffStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _staffStream = _buildStream();
  }

  @override
  void didUpdateWidget(_StaffStatusGate old) {
    super.didUpdateWidget(old);
    if (old.staffOf != widget.staffOf || old.uid != widget.uid) {
      _staffStream = _buildStream();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _staffStream = _buildStream());
    }
  }

  Stream<DocumentSnapshot> _buildStream() {
    return FirebaseFirestore.instance
        .doc('doctors/${widget.staffOf}/staff/${widget.uid}')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _staffStream,
      builder: (context, staffSnap) {
        if (staffSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final staffData =
            staffSnap.data?.data() as Map<String, dynamic>?;
        final status = staffData?['status']?.toString();

        if (status == 'disabled') {
          return _StaffDisabledScreen();
        }
        if (status != 'active') {
          return _StaffRevokedScreen();
        }

        return DoctorHome(isStaff: true, doctorUid: widget.staffOf);
      },
    );
  }
}

class _StaffRevokedScreen extends StatelessWidget {
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
                    color: Colors.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_off_rounded,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Zugang widerrufen',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ihr Mitarbeiter-Zugang wurde deaktiviert. '
                  'Bitte wenden Sie sich an Ihren Arzt.',
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

class _StaffDisabledScreen extends StatelessWidget {
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
                    color: Colors.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Account deaktiviert',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ihr Account wurde von Ihrem Arzt vorübergehend '
                  'deaktiviert. Bitte wenden Sie sich an Ihre Praxis.',
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
