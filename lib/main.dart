import 'dart:async';

// TODO(release): Entkommentieren wenn Ads aktiviert werden.
// import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// TODO(release): Entkommentieren wenn Ads aktiviert werden.
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/app_localizations.dart';
import 'locale/locale_provider.dart';
import 'debug/firebase_smoke_test_screen.dart';
import 'auth/auth_gate.dart';
import 'auth/user_profile_service.dart';
import 'auth/login_screen.dart';
import 'auth/role_debug_screen.dart';
import 'auth/signup_screen.dart';
import 'features/pro/data/billing_service.dart';
import 'features/pro/data/entitlement_service.dart';
import 'features/pro/data/paywall_config.dart';
import 'features/pro/data/paywall_cooldown_storage.dart';
import 'features/pro/data/paywall_trigger_analytics.dart';
import 'features/pro/data/paywall_trigger_service.dart';
import 'features/pro/data/pro_analytics.dart';
import 'features/pro/presentation/paywall_screen.dart';
import 'features/pro/presentation/pro_status_screen.dart';
import 'features/pro/presentation/redeem_key_screen.dart';
import 'firebase_options.dart';
import 'features/appointments/presentation/appointment_editor_screen.dart';
import 'features/appointments/presentation/appointments_screen.dart';
import 'features/documents/presentation/documents_screen.dart';
import 'features/doctor_report/presentation/doctor_report_screen.dart';
import 'features/doctor_report/presentation/report_screen.dart';
import 'features/op_info/presentation/op_info_screen.dart';
import 'features/packing/presentation/packing_lists_screen.dart';
import 'features/pain/presentation/pain_diary_screen.dart';
import 'features/pain/presentation/pain_screen.dart';
import 'features/vitals/presentation/vitals_screen.dart';
import 'features/medication/presentation/medication_screen.dart';
import 'features/medication/data/medication_reminder_scheduler.dart';
import 'features/photos/presentation/photos_screen.dart';
import 'features/questions/presentation/doctor_questions_screen.dart';
import 'features/settings/presentation/legal/imprint_screen.dart';
import 'features/settings/presentation/legal/privacy_screen.dart';
import 'features/settings/presentation/legal/terms_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/voice/presentation/speech_screen.dart';
import 'features/voice/presentation/voice_memos_screen.dart';
import 'features/wound/domain/wound_entry.dart';
import 'features/wound/presentation/wound_compare_screen.dart';
import 'features/wound/presentation/wound_entry_detail_screen.dart';
import 'features/wound/presentation/wound_history_screen.dart';
import 'features/wound/presentation/wound_hub_screen.dart';
import 'features/wound/presentation/wound_screen.dart';
import 'features/warnings/presentation/warnings_screen.dart';
import 'screens/alert_screen.dart';
import 'features/doctor_invite/presentation/connect_doctor_screen.dart';
import 'notifications/local_notifications.dart';
import 'notifications/fcm_service.dart';
import 'notifications/notification_preferences.dart';
import 'firebase/migration_service.dart';
import 'navigation/main_navigation.dart';
import 'screens/onboarding/register_caregiver_screen.dart';
import 'ui/ui.dart';
import 'features/gamification/gamification_service.dart';
import 'domain/task_orchestrator.dart';
import 'features/wound/data/wound_repository_sync.dart';
import 'features/pain/data/pain_repository_sync.dart';
import 'features/vitals/data/vital_repository_sync.dart';
import 'features/medication/data/medication_repository_sync.dart';
import 'features/rehab/data/rehab_session_repository_sync.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/rehab/presentation/rehab_screen.dart';
import 'features/assistant/presentation/assistant_screen.dart';
import 'features/ads/data/ad_service.dart';
import 'features/ads/presentation/ad_banner_widget.dart';
import 'screens/notification_center_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    ErrorWidget.builder = (details) {
      return Material(
        color: const Color(0xFFF7F8FC),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x33FF3B30)),
              ),
              child: Text(
                'UI Error\n${details.exceptionAsString()}',
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      );
    };
  }

  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;

    // ── Crashlytics ──
    if (!kDebugMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[main] Firebase init skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  try {
    await LocalNotifications.init();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] LocalNotifications.init failed: $e');
  }

  try {
    await LocalNotifications.requestPermissionsIfNeeded();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] Notification permissions failed: $e');
  }

  if (firebaseReady) {
    try {
      await FcmService().init();
    } catch (e) {
      if (kDebugMode) debugPrint('[main] FcmService.init failed: $e');
    }

    try {
      await MigrationService().migrateTimelineIfNeeded();
    } catch (e) {
      if (kDebugMode) debugPrint('[main] MigrationService failed: $e');
    }
  }

  // ── In-App Purchase services ──
  final proAnalytics = firebaseReady
      ? ProAnalytics.enabled()
      : ProAnalytics.disabled();

  final paywallConfig = firebaseReady
      ? PaywallConfig.enabled()
      : PaywallConfig.disabled();
  try {
    await paywallConfig.init();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] PaywallConfig.init failed: $e');
  }

  final entitlementService = firebaseReady
      ? EntitlementService.enabled()
      : EntitlementService.disabled();
  try {
    await entitlementService.init();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] EntitlementService.init failed: $e');
  }

  // ── Smart Paywall Trigger System ──
  final cooldownStorage = PaywallCooldownStorage();
  try {
    await cooldownStorage.init();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] CooldownStorage.init failed: $e');
  }

  final triggerAnalytics = firebaseReady
      ? PaywallTriggerAnalytics.enabled()
      : PaywallTriggerAnalytics.disabled();

  final paywallTriggerService = PaywallTriggerService(
    entitlementService: entitlementService,
    paywallConfig: paywallConfig,
    cooldownStorage: cooldownStorage,
    triggerAnalytics: triggerAnalytics,
  );

  // Record active day for smart trigger moments.
  paywallTriggerService.onSessionStarted();

  // ── Gamification ──
  final gamificationService = firebaseReady
      ? GamificationService.enabled()
      : GamificationService.disabled();
  TaskOrchestrator.gamificationService = gamificationService;
  WoundRepositorySync.gamificationService = gamificationService;
  PainRepositorySync.gamificationService = gamificationService;
  VitalRepositorySync.gamificationService = gamificationService;
  MedicationRepositorySync.gamificationService = gamificationService;
  RehabSessionRepositorySync.gamificationService = gamificationService;

  // ── Notification preferences ──
  await NotificationPreferences.instance.load();

  try {
    await MedicationReminderScheduler.instance.bootstrap();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[main] MedicationReminderScheduler.bootstrap failed: $e');
    }
  }

  NotificationPreferences.instance.addListener(() {
    unawaited(MedicationReminderScheduler.instance.rescheduleAll());
  });

  final billingService = firebaseReady
      ? BillingService.enabled()
      : BillingService.disabledBackend();
  // NOTE: No onPurchaseVerified callback – the Firestore real-time listener
  // in EntitlementService already picks up Pro status changes triggered by
  // the Cloud Function. Calling refresh() here caused a race condition.
  try {
    await billingService.init();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] BillingService.init failed: $e');
  }

  // ── Ads (deaktiviert für ersten Release) ──
  final adService = firebaseReady ? AdService.enabled() : AdService.disabled();
  // TODO(release): Ads aktivieren wenn produktive AdMob-ID eingerichtet ist.
  // if (firebaseReady) {
  //   adService.init();
  // }

  // Initialize Google Mobile Ads (mobile only).
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  // TODO(release): Ads aktivieren wenn produktive AdMob-ID eingerichtet ist.
  //   try {
  //     await MobileAds.instance.initialize();
  //   } catch (e) {
  //     if (kDebugMode) debugPrint('[main] MobileAds.init failed: $e');
  //   }
  // }

  // ── Locale ──
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  runApp(
    OperationsbegleiterApp(
      firebaseReady: firebaseReady,
      billingService: billingService,
      entitlementService: entitlementService,
      proAnalytics: proAnalytics,
      paywallConfig: paywallConfig,
      paywallTriggerService: paywallTriggerService,
      localeProvider: localeProvider,
      adService: adService,
    ),
  );
}

class OperationsbegleiterApp extends StatefulWidget {
  const OperationsbegleiterApp({
    super.key,
    required this.firebaseReady,
    required this.billingService,
    required this.entitlementService,
    required this.proAnalytics,
    required this.paywallConfig,
    required this.paywallTriggerService,
    required this.localeProvider,
    required this.adService,
  });

  final bool firebaseReady;
  final BillingService billingService;
  final EntitlementService entitlementService;
  final ProAnalytics proAnalytics;
  final PaywallConfig paywallConfig;
  final PaywallTriggerService paywallTriggerService;
  final LocaleProvider localeProvider;
  final AdService adService;

  @override
  State<OperationsbegleiterApp> createState() => _OperationsbegleiterAppState();
}

class _OperationsbegleiterAppState extends State<OperationsbegleiterApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    try {
      final appLinks = AppLinks();

      // Handle links while app is running
      appLinks.stringLinkStream.listen((link) {
        _handleLink(link);
      });

      // Handle initial link (app opened via link)
      appLinks.getInitialLink().then((uri) {
        if (uri != null) _handleLink(uri.toString());
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[DeepLinks] init failed: $e');
    }
  }

  void _handleLink(String link) {
    // Doctor invite: .../doctor-invite/ABCD1234
    final doctorMatch = RegExp(
      r'doctor-invite/([A-Za-z0-9]{6,12})',
      caseSensitive: false,
    ).firstMatch(link);
    if (doctorMatch != null) {
      final code = doctorMatch.group(1)!.toUpperCase();
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ConnectDoctorScreen(initialCode: code),
        ),
      );
      return;
    }

    // Caregiver invite: .../invite/ABCDEF123456
    final caregiverMatch = RegExp(
      r'operationsbegleiter-860e7\.web\.app/invite/([A-Fa-f0-9]{12})',
    ).firstMatch(link);
    if (caregiverMatch != null) {
      final code = caregiverMatch.group(1)!.toUpperCase();
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => RegisterCaregiverScreen(initialCode: code),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      provider: widget.localeProvider,
      child: AdServiceScope(
        adService: widget.adService,
        child: ProServices(
          billingService: widget.billingService,
          entitlementService: widget.entitlementService,
          proAnalytics: widget.proAnalytics,
          paywallConfig: widget.paywallConfig,
          paywallTriggerService: widget.paywallTriggerService,
          child: Builder(
            builder: (ctx) {
              final lp = LocaleProvider.of(ctx);
              return MaterialApp(
                navigatorKey: _navigatorKey,
                title: 'Operationsbegleiter',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                locale: lp.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: widget.firebaseReady
                    ? const AuthGate(patientHome: MainNavigation())
                    : const _FirebaseUnavailableScreen(),
                routes: {
                  '/login': (_) => const LoginScreen(),
                  '/signup': (_) => const SignupScreen(),
                  '/role-debug': (_) =>
                      const _AdminGuard(child: RoleDebugScreen()),
                  '/linking': (_) => const ConnectDoctorScreen(),
                  '/wound': (_) => const WoundHubScreen(),
                  '/wound-editor': (_) => const WoundScreen(),
                  '/wound-history': (_) => WoundHistoryScreen(),
                  '/wound-detail': (context) {
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final entry = _extractWoundEntry(args);
                    if (entry == null) {
                      return const _NamedPlaceholderScreen(
                        title: 'Wunddetail (fehlende Argumente)',
                      );
                    }
                    return WoundEntryDetailScreen(entry: entry);
                  },
                  '/wound-compare': (context) {
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final compareEntries = _extractCompareEntries(args);
                    if (compareEntries == null) {
                      return const _NamedPlaceholderScreen(
                        title: 'Wundvergleich (fehlende Argumente)',
                      );
                    }
                    return WoundCompareScreen(
                      entryA: compareEntries.$1,
                      entryB: compareEntries.$2,
                    );
                  },
                  '/meds': (_) => const MedicationScreen(),
                  '/checklist': (_) => const PackingListsScreen(),
                  '/appointment': (_) => const AppointmentsScreen(),
                  '/appointments': (_) => const AppointmentsScreen(),
                  '/appointment-editor': (_) => const AppointmentEditorScreen(),
                  '/documents': (_) => const DocumentsScreen(),
                  '/photos': (_) => const PhotosScreen(),
                  '/doctor-report': (_) => const ReportScreen(),
                  '/doctor-report-legacy': (_) => const DoctorReportScreen(),
                  '/op-info': (_) => const OpInfoScreen(),
                  '/packing': (_) => const PackingListsScreen(),
                  '/pain': (_) => const PainScreen(),
                  '/pain-diary': (_) => const PainDiaryScreen(),
                  '/doctor-questions': (_) => const DoctorQuestionsScreen(),
                  '/settings': (_) => const SettingsScreen(),
                  '/imprint': (_) => const ImprintScreen(),
                  '/privacy': (_) => const PrivacyScreen(),
                  '/terms': (_) => const TermsScreen(),
                  '/voice': (_) => const SpeechScreen(),
                  '/voice-memos': (_) => const VoiceMemosScreen(),
                  '/speech': (_) => const SpeechScreen(),
                  '/vitals': (_) => const VitalsScreen(),
                  '/warnings': (_) => const WarningsScreen(),
                  '/alerts': (_) => const AlertScreen(),
                  '/notifications': (_) => const NotificationCenterScreen(),
                  '/analytics': (_) => const AnalyticsScreen(),
                  '/rehab': (_) => const RehabScreen(),
                  '/debug/firebase': (_) =>
                      const _AdminGuard(child: FirebaseSmokeTestScreen()),
                  '/paywall': (context) {
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final source = (args is Map && args['source'] is String)
                        ? args['source'] as String
                        : 'unknown';
                    return PaywallScreen(
                      billingService: widget.billingService,
                      entitlementService: widget.entitlementService,
                      proAnalytics: widget.proAnalytics,
                      paywallConfig: widget.paywallConfig,
                      source: source,
                    );
                  },
                  '/assistant': (_) => const AssistantScreen(),
                  '/pro-status': (_) => const ProStatusScreen(),
                  '/redeem-key': (_) => const RedeemKeyScreen(),
                  '/invite-accept': (context) {
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final code = (args is Map && args['code'] is String)
                        ? args['code'] as String
                        : null;
                    return RegisterCaregiverScreen(initialCode: code);
                  },
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FirebaseUnavailableScreen extends StatelessWidget {
  const _FirebaseUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  borderRadius: AppRadius.borderRadiusXxl,
                  variant: GlassVariant.thick,
                  elevation: GlassElevation.high,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.14),
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.warning,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Lokaler Modus',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Firebase ist auf dieser Plattform aktuell nicht konfiguriert. Für macOS startet die App deshalb im lokalen Testmodus.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const MedicationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.medication_rounded),
                            label: const Text('Medikamenten-Hub öffnen'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const DocumentsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.folder_open_rounded),
                            label: const Text('Dokumente öffnen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inherited widget that provides [BillingService] and [EntitlementService]
/// to the entire widget tree.
class ProServices extends InheritedWidget {
  const ProServices({
    super.key,
    required this.billingService,
    required this.entitlementService,
    required this.proAnalytics,
    required this.paywallConfig,
    required this.paywallTriggerService,
    required super.child,
  });

  final BillingService billingService;
  final EntitlementService entitlementService;
  final ProAnalytics proAnalytics;
  final PaywallConfig paywallConfig;
  final PaywallTriggerService paywallTriggerService;

  static ProServices of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ProServices>();
    assert(result != null, 'No ProServices found in context');
    return result!;
  }

  static ProServices? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProServices>();
  }

  @override
  bool updateShouldNotify(ProServices oldWidget) {
    return billingService != oldWidget.billingService ||
        entitlementService != oldWidget.entitlementService ||
        proAnalytics != oldWidget.proAnalytics ||
        paywallConfig != oldWidget.paywallConfig ||
        paywallTriggerService != oldWidget.paywallTriggerService;
  }
}

WoundEntry? _extractWoundEntry(Object? args) {
  if (args is WoundEntry) return args;
  if (args is Map && args['entry'] is WoundEntry) {
    return args['entry'] as WoundEntry;
  }
  return null;
}

(WoundEntry, WoundEntry)? _extractCompareEntries(Object? args) {
  if (args is Map &&
      args['entryA'] is WoundEntry &&
      args['entryB'] is WoundEntry) {
    return (args['entryA'] as WoundEntry, args['entryB'] as WoundEntry);
  }
  if (args is List &&
      args.length >= 2 &&
      args[0] is WoundEntry &&
      args[1] is WoundEntry) {
    return (args[0] as WoundEntry, args[1] as WoundEntry);
  }
  return null;
}

class _AdminGuard extends StatelessWidget {
  const _AdminGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUserRole>(
      future: UserProfileService().getMyRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != AppUserRole.admin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kein Zugriff')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nur fuer Admins verfuegbar.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Zurueck'),
                  ),
                ],
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}

class _NamedPlaceholderScreen extends StatelessWidget {
  const _NamedPlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'In Arbeit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  Future<void> _addTestPatient() async {
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection('patients').add({
      'name': 'Test Patient ${now.hour}:${now.minute}:${now.second}',
      'birthDate': '01.01.1990',
      'diagnosis': 'Test',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientsStream = FirebaseFirestore.instance
        .collection('patients')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Patienten')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestPatient,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: patientsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Daten konnten nicht geladen werden.'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Noch keine Patienten. Tippe auf +'),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final name = (data['name'] ?? 'Unbenannt') as String;
              final birthDate = (data['birthDate'] ?? '') as String;
              final diagnosis = (data['diagnosis'] ?? '') as String;

              return ListTile(
                title: Text(name),
                subtitle: Text(
                  [birthDate, diagnosis].where((s) => s.isNotEmpty).join(' • '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Patient geöffnet: $name')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
