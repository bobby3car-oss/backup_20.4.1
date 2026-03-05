import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';
import 'locale/locale_provider.dart';
import 'debug/firebase_smoke_test_screen.dart';
import 'auth/auth_gate.dart';
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
import 'features/packing/presentation/packing_list_screen.dart';
import 'features/pain/presentation/pain_diary_screen.dart';
import 'features/pain/presentation/pain_screen.dart';
import 'features/vitals/presentation/vitals_screen.dart';
import 'features/medication/presentation/medication_screen.dart';
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
import 'features/wound/presentation/wound_screen.dart';
import 'features/warnings/presentation/warnings_screen.dart';
import 'linking/linking_screen.dart';
import 'notifications/local_notifications.dart';
import 'notifications/fcm_service.dart';
import 'firebase/migration_service.dart';
import 'navigation/main_navigation.dart';
import 'ui/theme/app_theme.dart';
import 'features/gamification/gamification_service.dart';
import 'domain/task_orchestrator.dart';
import 'features/wound/data/wound_repository_sync.dart';
import 'features/pain/data/pain_repository_sync.dart';
import 'features/vitals/data/vital_repository_sync.dart';
import 'features/medication/data/medication_repository_sync.dart';
import 'features/rehab/data/rehab_session_repository_sync.dart';
import 'features/rehab/presentation/rehab_screen.dart';

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
  final proAnalytics = ProAnalytics();

  final paywallConfig = PaywallConfig();
  try {
    await paywallConfig.init();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] PaywallConfig.init failed: $e');
  }

  final entitlementService = EntitlementService();
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

  final triggerAnalytics = PaywallTriggerAnalytics();

  final paywallTriggerService = PaywallTriggerService(
    entitlementService: entitlementService,
    paywallConfig: paywallConfig,
    cooldownStorage: cooldownStorage,
    triggerAnalytics: triggerAnalytics,
  );

  // Record active day for smart trigger moments.
  paywallTriggerService.onSessionStarted();

  // ── Gamification ──
  final gamificationService = GamificationService();
  TaskOrchestrator.gamificationService = gamificationService;
  WoundRepositorySync.gamificationService = gamificationService;
  PainRepositorySync.gamificationService = gamificationService;
  VitalRepositorySync.gamificationService = gamificationService;
  MedicationRepositorySync.gamificationService = gamificationService;
  RehabSessionRepositorySync.gamificationService = gamificationService;

  final billingService = BillingService();
  // NOTE: No onPurchaseVerified callback – the Firestore real-time listener
  // in EntitlementService already picks up Pro status changes triggered by
  // the Cloud Function. Calling refresh() here caused a race condition.
  try {
    await billingService.init();
  } catch (e) {
    if (kDebugMode) debugPrint('[main] BillingService.init failed: $e');
  }

  // ── Locale ──
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  runApp(OperationsbegleiterApp(
    billingService: billingService,
    entitlementService: entitlementService,
    proAnalytics: proAnalytics,
    paywallConfig: paywallConfig,
    paywallTriggerService: paywallTriggerService,
    localeProvider: localeProvider,
  ));
}

class OperationsbegleiterApp extends StatelessWidget {
  const OperationsbegleiterApp({
    super.key,
    required this.billingService,
    required this.entitlementService,
    required this.proAnalytics,
    required this.paywallConfig,
    required this.paywallTriggerService,
    required this.localeProvider,
  });

  final BillingService billingService;
  final EntitlementService entitlementService;
  final ProAnalytics proAnalytics;
  final PaywallConfig paywallConfig;
  final PaywallTriggerService paywallTriggerService;
  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      provider: localeProvider,
      child: ProServices(
        billingService: billingService,
        entitlementService: entitlementService,
        proAnalytics: proAnalytics,
        paywallConfig: paywallConfig,
        paywallTriggerService: paywallTriggerService,
        child: Builder(
          builder: (ctx) {
            final lp = LocaleProvider.of(ctx);
            return MaterialApp(
              title: 'Operationsbegleiter',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: lp.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const AuthGate(patientHome: MainNavigation()),
              routes: {
                '/login': (_) => const LoginScreen(),
                '/signup': (_) => const SignupScreen(),
                '/role-debug': (_) => const RoleDebugScreen(),
                '/linking': (_) => const LinkingScreen(),
                '/wound': (_) => const WoundScreen(),
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
                '/checklist': (_) => const PackingListScreen(),
                '/appointment': (_) => const AppointmentsScreen(),
                '/appointments': (_) => const AppointmentsScreen(),
                '/appointment-editor': (_) => const AppointmentEditorScreen(),
                '/documents': (_) => const DocumentsScreen(),
                '/photos': (_) => const PhotosScreen(),
                '/doctor-report': (_) => const ReportScreen(),
                '/doctor-report-legacy': (_) => const DoctorReportScreen(),
                '/op-info': (_) => const OpInfoScreen(),
                '/packing': (_) => const PackingListScreen(),
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
                '/rehab': (_) => const RehabScreen(),
                '/debug/firebase': (_) => const FirebaseSmokeTestScreen(),
                '/paywall': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments;
                  final source = (args is Map && args['source'] is String)
                      ? args['source'] as String
                      : 'unknown';
                  return PaywallScreen(
                    billingService: billingService,
                    entitlementService: entitlementService,
                    proAnalytics: proAnalytics,
                    paywallConfig: paywallConfig,
                    source: source,
                  );
                },
                '/pro-status': (_) => const ProStatusScreen(),
                '/redeem-key': (_) => const RedeemKeyScreen(),
              },
            );
          },
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
            return const Center(child: Text('Daten konnten nicht geladen werden.'));
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
