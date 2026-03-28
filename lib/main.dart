import 'dart:async';

// TODO(release): Entkommentieren wenn Ads aktiviert werden.
// import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/app_localizations.dart';
import 'locale/locale_provider.dart';
import 'debug/firebase_smoke_test_screen.dart';
import 'auth/auth_gate.dart';
import 'auth/user_profile_service.dart';
import 'auth/role_debug_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/onboarding/register_screen.dart';
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
import 'features/nutrition/presentation/nutrition_diary_screen.dart';
import 'features/nutrition/presentation/nutrition_screen.dart';
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
import 'features/voice/presentation/voice_memo_detail_screen.dart';
import 'features/voice/presentation/voice_memos_screen.dart';
import 'features/wound/domain/wound_entry.dart';
import 'features/wound/presentation/wound_compare_screen.dart';
import 'features/wound/presentation/wound_comparison_screen.dart';
import 'features/wound/presentation/wound_entry_detail_screen.dart';
import 'features/wound/presentation/wound_history_screen.dart';
import 'features/wound/presentation/wound_hub_screen.dart';
import 'features/wound/presentation/wound_screen.dart';
import 'features/warnings/presentation/warnings_screen.dart';
import 'features/emergency/presentation/emergency_screen.dart';
import 'screens/alert_screen.dart';
import 'screens/timeline_feed_screen.dart';
import 'features/doctor_invite/presentation/connect_doctor_screen.dart';

import 'notifications/local_notifications.dart';
import 'notifications/fcm_service.dart';
import 'notifications/notification_preferences.dart';
import 'navigation/main_navigation.dart';
import 'screens/family_member_hub_screen.dart';
import 'ui/ui.dart';
import 'features/gamification/gamification_service.dart';
import 'domain/task_orchestrator.dart';
import 'domain/task_orchestrator_sync.dart';
import 'features/wound/data/wound_repository_sync.dart';
import 'features/nutrition/data/nutrition_repository_sync.dart';
import 'features/mood/data/mood_repository_sync.dart';
import 'features/mood/presentation/mood_screen.dart';
import 'features/pain/data/pain_repository_sync.dart';
import 'features/sleep/data/sleep_repository_sync.dart';
import 'features/sleep/presentation/sleep_screen.dart';
import 'features/sleep/presentation/sleep_diary_screen.dart';
import 'features/vitals/data/vital_repository_sync.dart';
import 'features/medication/data/medication_repository_sync.dart';
import 'features/rehab/data/rehab_session_repository_sync.dart';
import 'features/questions/data/questions_repository_sync.dart';
import 'features/red_flags/data/red_flag_repository_sync.dart';
import 'sync/storage_upload_queue.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/export/presentation/health_report_screen.dart';
import 'features/rehab/presentation/rehab_screen.dart';
import 'features/assistant/presentation/bella_overlay_wrapper.dart';
import 'features/assistant/presentation/bella_overlay_controller.dart';
import 'features/assistant/presentation/bella_briefing_screen.dart';
import 'features/ads/data/ad_service.dart';
import 'features/ads/presentation/admin/ads_admin_tab.dart';
import 'features/ads/presentation/ad_banner_widget.dart';
import 'screens/notification_center_screen.dart';
import 'security/app_check_service.dart';
import 'security/pin_lock_screen.dart';
import 'security/pin_lock_service.dart';
import 'security/privacy_consent_service.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'sync/connectivity_service.dart';
import 'sync/sync_status_service.dart';
import 'sync/user_scoped_storage.dart';
import 'features/widget/widget_data_service.dart';

String? debugInitialRouteOverride;

const _debugInitialRouteFromEnvironment = String.fromEnvironment(
  'DEBUG_INITIAL_ROUTE',
);

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

  // ── Pre-warm SharedPreferences once (used by locale, entitlement,
  //    privacy consent, cooldown storage, AuthGate). ──
  final prefsFuture = SharedPreferences.getInstance();

  final localeProvider = LocaleProvider();
  final cooldownStorage = PaywallCooldownStorage();

  // ── Phase 0: Firebase + minimal blocking services ──
  // ONLY Firebase init + locale must finish before runApp.
  // Everything else is either deferred or runs in parallel.
  bool firebaseReady = false;
  final sw = Stopwatch()..start();
  debugPrint('[STARTUP] Phase 0 starting');
  await Future.wait(<Future<void>>[
    // Firebase init (required – SDK must be ready before any Firebase service)
    () async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        firebaseReady = true;
        UserScopedStorage.instance.init();
        debugPrint('[STARTUP]   Firebase.initializeApp: ${sw.elapsedMilliseconds}ms');
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('[main] Firebase init skipped: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
    }(),
    // Locale (fast SharedPrefs read – required for MaterialApp locale)
    localeProvider.load(),
    // Connectivity (fast platform channel)
    () async {
      try {
        await ConnectivityService.instance.init();
        await SyncStatusService.instance.init();
      } catch (e) {
        if (kDebugMode) debugPrint('[main] ConnectivityService failed: $e');
      }
    }(),
  ]);
  debugPrint('[STARTUP] Phase 0 done: ${sw.elapsedMilliseconds}ms');

  // ── Create service instances (no async work yet) ──
  final proAnalytics = firebaseReady
      ? ProAnalytics.enabled()
      : ProAnalytics.disabled();

  final paywallConfig = firebaseReady
      ? PaywallConfig.enabled()
      : PaywallConfig.disabled();

  final entitlementService = firebaseReady
      ? EntitlementService.enabled()
      : EntitlementService.disabled();

  final billingService = firebaseReady
      ? BillingService.enabled()
      : BillingService.disabledBackend();

  final adService = firebaseReady ? AdService.enabled() : AdService.disabled();

  // ── Smart Paywall Trigger System (sync, no async work) ──
  final triggerAnalytics = firebaseReady
      ? PaywallTriggerAnalytics.enabled()
      : PaywallTriggerAnalytics.disabled();

  final paywallTriggerService = PaywallTriggerService(
    entitlementService: entitlementService,
    paywallConfig: paywallConfig,
    cooldownStorage: cooldownStorage,
    triggerAnalytics: triggerAnalytics,
  );

  paywallTriggerService.onSessionStarted();

  // ── Gamification (sync assignments only) ──
  final gamificationService = firebaseReady
      ? GamificationService.enabled()
      : GamificationService.disabled();
  TaskOrchestrator.gamificationService = gamificationService;
  WoundRepositorySync.gamificationService = gamificationService;
  PainRepositorySync.gamificationService = gamificationService;
  VitalRepositorySync.gamificationService = gamificationService;
  MedicationRepositorySync.gamificationService = gamificationService;
  RehabSessionRepositorySync.gamificationService = gamificationService;
  NutritionRepositorySync.gamificationService = gamificationService;
  MoodRepositorySync.gamificationService = gamificationService;
  SleepRepositorySync.gamificationService = gamificationService;

  // ── Homescreen Widget Data Bridge ──
  WidgetDataService.instance.startListening(
    gamificationService: gamificationService,
  );

  // ── Reconnect handler (just registers a callback, no async) ──
  ConnectivityService.instance.onReconnect(() async {
    SyncStatusService.instance.markSyncing();
    await Future.wait(<Future<void>>[
      PainRepositorySync.instance.syncNow(),
      MoodRepositorySync.instance.syncNow(),
      SleepRepositorySync.instance.syncNow(),
      VitalRepositorySync.instance.syncNow(),
      MedicationRepositorySync.instance.syncNow(),
      RehabSessionRepositorySync.instance.syncNow(),
      NutritionRepositorySync.instance.syncNow(),
      QuestionsRepositorySync.instance.syncNow(),
      RedFlagRepositorySync.instance.syncNow(),
      gamificationService.syncNow(),
      StorageUploadQueue.instance.retryAll(),
    ]);
    await Future.wait(<Future<void>>[
      PainRepositorySync.instance.pullLatest(),
      MoodRepositorySync.instance.pullLatest(),
      SleepRepositorySync.instance.pullLatest(),
      VitalRepositorySync.instance.pullLatest(),
      MedicationRepositorySync.instance.pullLatest(),
      RehabSessionRepositorySync.instance.pullLatest(),
      NutritionRepositorySync.instance.pullLatest(),
      QuestionsRepositorySync.instance.pullLatest(),
      RedFlagRepositorySync.instance.pullLatest(),
    ]);
    await SyncStatusService.instance.markSynced();
  });

  NotificationPreferences.instance.addListener(() {
    unawaited(MedicationReminderScheduler.instance.rescheduleAll());
  });

  // ── Pre-warm TaskOrchestratorSync: starts local disk read immediately
  //    so it is already done when HomeScreen.initState() runs. ──
  TaskOrchestratorSync.instance;

  // ── Show the first frame immediately ──
  debugPrint('[STARTUP] runApp at: ${sw.elapsedMilliseconds}ms');
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

  // ── Post-frame init: services that were previously blocking. ──
  // These all run AFTER the first frame so the user sees UI immediately.
  unawaited(_postFrameInit(
    firebaseReady: firebaseReady,
    prefsFuture: prefsFuture,
    cooldownStorage: cooldownStorage,
    entitlementService: entitlementService,
    gamificationService: gamificationService,
  ));

  // ── Deferred init: heavy / network-dependent services. ──
  unawaited(_deferredInit(
    firebaseReady: firebaseReady,
    paywallConfig: paywallConfig,
    billingService: billingService,
    adService: adService,
  ));
}

/// Initialises services that were removed from the blocking path.
///
/// Runs immediately after the first frame. None of these are required
/// before the UI is visible.
Future<void> _postFrameInit({
  required bool firebaseReady,
  required Future<SharedPreferences> prefsFuture,
  required PaywallCooldownStorage cooldownStorage,
  required EntitlementService entitlementService,
  required GamificationService gamificationService,
}) async {
  // Yield so the first frame paints.
  await Future<void>.delayed(Duration.zero);

  await Future.wait(<Future<void>>[
    // Privacy consent (SharedPrefs read + Firebase Analytics/Crashlytics toggle)
    () async {
      if (!firebaseReady) return;
      try {
        await PrivacyConsentService.instance.init();
        if (!kDebugMode && !kIsWeb &&
            PrivacyConsentService.instance.crashlyticsEnabled) {
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterFatalError;
          PlatformDispatcher.instance.onError = (error, stack) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            return true;
          };
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[postFrame] PrivacyConsent failed: $e');
      }
    }(),
    // Web redirect auth result (web only, no-op on mobile)
    () async {
      try {
        await AuthService.handleWebRedirectResult();
      } catch (e) {
        if (kDebugMode) debugPrint('[postFrame] handleWebRedirect failed: $e');
      }
    }(),
    // Local notifications plugin init
    () async {
      try {
        await LocalNotifications.init();
      } catch (e) {
        if (kDebugMode) debugPrint('[postFrame] LocalNotifications failed: $e');
      }
    }(),
    // Paywall cooldown storage
    () async {
      try {
        await cooldownStorage.init();
      } catch (e) {
        if (kDebugMode) debugPrint('[postFrame] CooldownStorage failed: $e');
      }
    }(),
    // Notification preferences
    () async {
      try {
        await NotificationPreferences.instance.load();
      } catch (e) {
        if (kDebugMode) debugPrint('[postFrame] NotifPrefs failed: $e');
      }
    }(),
    // Entitlement service (SharedPrefs cache load)
    () async {
      try {
        await entitlementService.init();
      } catch (e) {
        if (kDebugMode) debugPrint('[postFrame] EntitlementService failed: $e');
      }
    }(),
  ]);

  // Gamification schedule notifications (fire-and-forget)
  unawaited(gamificationService.checkAndScheduleDailyChallengeNotification());
  unawaited(
    gamificationService.generateWeeklySummary().then(
          (summary) => gamificationService.emitWeeklySummaryEvent(summary),
        ),
  );
}

/// Initialises heavy / network-dependent services after the first frame.
///
/// This keeps the blocking path in [main] minimal so the user sees the UI
/// as fast as possible. All work here is wrapped in try/catch so a single
/// failure never tears down the app.
Future<void> _deferredInit({
  required bool firebaseReady,
  required PaywallConfig paywallConfig,
  required BillingService billingService,
  required AdService adService,
}) async {
  // Yield to the event loop so the first frame can paint.
  await Future<void>.delayed(Duration.zero);

  // App Check must be active before any other Firebase network traffic.
  if (firebaseReady) {
    try {
      await AppCheckService.activate();
    } catch (e) {
      if (kDebugMode) debugPrint('[deferred] AppCheck.activate failed: $e');
    }
  }

  // All remaining heavy services in parallel.
  await Future.wait(<Future<void>>[
    () async {
      try {
        await paywallConfig.init();
      } catch (e) {
        if (kDebugMode) debugPrint('[deferred] PaywallConfig.init failed: $e');
      }
    }(),
    () async {
      try {
        await billingService.init();
      } catch (e) {
        if (kDebugMode) debugPrint('[deferred] BillingService.init failed: $e');
      }
    }(),
    if (firebaseReady)
      () async {
        try {
          await FcmService().init();
        } catch (e) {
          if (kDebugMode) debugPrint('[deferred] FcmService.init failed: $e');
        }
      }(),
    // MigrationService.migrateTimelineIfNeeded() is already handled by
    // TaskOrchestratorSync.initialize() – no need to duplicate here.
    () async {
      try {
        await MedicationReminderScheduler.instance.bootstrap();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[deferred] MedicationReminder failed: $e');
        }
      }
    }(),
    () async {
      try {
        adService.init();
      } catch (e) {
        if (kDebugMode) debugPrint('[deferred] AdService.init failed: $e');
      }
    }(),
    () async {
      final isSupportedMobilePlatform =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);
      if (!isSupportedMobilePlatform) return;
      try {
        // Request ATT permission before loading ads (Apple requirement).
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
        await MobileAds.instance.initialize();
      } catch (e) {
        if (kDebugMode) debugPrint('[deferred] MobileAds.init failed: $e');
      }
    }(),
    () async {
      try {
        await LocalNotifications.requestPermissionsIfNeeded();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[deferred] Notification permissions failed: $e');
        }
      }
    }(),
  ]);
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

  /// Global navigator key — used by Bella overlay to navigate to paywall.
  static GlobalKey<NavigatorState>? appNavigatorKey;

  @override
  State<OperationsbegleiterApp> createState() => _OperationsbegleiterAppState();
}

class _OperationsbegleiterAppState extends State<OperationsbegleiterApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _deepLinkSub;
  bool _pinLockShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    OperationsbegleiterApp.appNavigatorKey = _navigatorKey;
    widget.localeProvider.addListener(_onLocaleChanged);
    _initDeepLinks();
    // Consume any notification route that launched the app.
    _consumePendingNotificationRoute();
  }

  void _onLocaleChanged() {
    debugPrint('[OperationsbegleiterApp] locale changed → ${widget.localeProvider.locale}');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.localeProvider.removeListener(_onLocaleChanged);
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkSub?.cancel();
    widget.adService.dispose();
    super.dispose();
  }

  /// When the app returns to the foreground, check if a notification tap
  /// queued a route while we were in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consumePendingNotificationRoute();
      _showPinLockIfNeeded();
      // Re-check connectivity when returning from background.
      unawaited(ConnectivityService.instance.recheckNow().catchError((_) {}));
    }
  }

  Future<void> _showPinLockIfNeeded() async {
    if (_pinLockShowing) return;
    final enabled = await PinLockService().isEnabled;
    if (!enabled || !mounted) return;
    final nav = _navigatorKey.currentState;
    if (nav == null) return;
    _pinLockShowing = true;
    await nav.push<bool>(
      MaterialPageRoute(
        builder: (_) => const PinLockScreen(mode: PinScreenMode.unlock),
        fullscreenDialog: true,
      ),
    );
    _pinLockShowing = false;
  }

  void _consumePendingNotificationRoute() {
    final route = FcmService.instance.consumePendingRoute();
    if (route == null) return;

    // Bella trend notification: open Bella overlay with prepared analysis.
    if (route == '__bella_trend__') {
      final trendMsg = FcmService.instance.consumePendingBellaTrend();
      if (trendMsg != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          BellaOverlayController.instance?.openWithTrendAnalysis(trendMsg);
        });
      }
      return;
    }

    // Standard route-based navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamed(route);
    });
  }

  void _initDeepLinks() {
    try {
      final appLinks = AppLinks();

      // Handle links while app is running
      _deepLinkSub = appLinks.stringLinkStream.listen((link) {
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
    // Permanent doctor link: .../doctor-link/ABCDEF1234
    final permanentMatch = RegExp(
      r'doctor-link/([A-Za-z0-9]{6,16})',
      caseSensitive: false,
    ).firstMatch(link);
    if (permanentMatch != null) {
      final code = permanentMatch.group(1)!.toUpperCase();
      if (FirebaseAuth.instance.currentUser == null) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('pendingDoctorCode', code);
          prefs.setBool('pendingDoctorCodeIsPermanent', true);
        }).catchError((Object e) {
          debugPrint('[DeepLink] prefs failed: $e');
          return null;
        });
      }
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ConnectDoctorScreen(
              initialCode: code, isPermanentCode: true),
        ),
      );
      return;
    }

    // Doctor invite: .../doctor-invite/ABCD1234
    final doctorMatch = RegExp(
      r'doctor-invite/([A-Za-z0-9]{6,16})',
      caseSensitive: false,
    ).firstMatch(link);
    if (doctorMatch != null) {
      final code = doctorMatch.group(1)!.toUpperCase();
      if (FirebaseAuth.instance.currentUser == null) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('pendingDoctorCode', code);
          prefs.setBool('pendingDoctorCodeIsPermanent', false);
        }).catchError((Object e) {
          debugPrint('[DeepLink] prefs failed: $e');
          return null;
        });
      }
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ConnectDoctorScreen(initialCode: code),
        ),
      );
      return;
    }

    // Family invite: .../invite/ABCDEF123456
    final familyMatch = RegExp(
      r'operationsbegleiter-860e7\.web\.app/invite/([A-Fa-f0-9]{12})',
    ).firstMatch(link);
    if (familyMatch != null) {
      final code = familyMatch.group(1)!.toUpperCase();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Logged in – go straight to hub with the code.
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => FamilyMemberHubScreen(initialCode: code),
          ),
        );
      } else {
        // Not logged in – persist code and open hub (will ask to log in).
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('pendingFamilyInviteCode', code);
        }).catchError((Object e) {
          debugPrint('[DeepLink] prefs failed: $e');
          return null;
        });
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => FamilyMemberHubScreen(initialCode: code),
          ),
        );
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedDebugInitialRoute =
        debugInitialRouteOverride ?? _debugInitialRouteFromEnvironment;
    final initialRoute = kDebugMode && resolvedDebugInitialRoute.isNotEmpty
        ? resolvedDebugInitialRoute
        : null;

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
              // Depend on LocaleScope so this Builder rebuilds when locale
              // changes – the InheritedNotifier path guarantees a rebuild
              // even without the setState listener as a backup.
              final locale = LocaleProvider.of(ctx).locale;
              return MaterialApp(
                navigatorKey: _navigatorKey,
                title: 'Operationsbegleiter',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                initialRoute: initialRoute,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (context, child) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      BellaOverlayWrapper(
                        child: child ?? const SizedBox.shrink(),
                      ),
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: OfflineBanner(),
                      ),
                    ],
                  );
                },
                home: initialRoute == null
                    ? widget.firebaseReady
                          ? const AuthGate(patientHome: MainNavigation())
                          : const _FirebaseUnavailableScreen()
                    : null,
                routes: {
                  '/login': (_) => const LoginScreen(),
                  '/signup': (_) => const RegisterScreen(),
                  '/role-debug': (_) =>
                      const _AdminGuard(child: RoleDebugScreen()),
                  '/debug/ads-admin': (_) =>
                      const _AdminGuard(child: AdsAdminTab()),
                  '/linking': (_) => const ConnectDoctorScreen(),
                  '/wound': (_) => const WoundHubScreen(),
                  '/wound-editor': (_) => const WoundScreen(),
                  '/wound-history': (_) => WoundHistoryScreen(),
                  '/wound-detail': (context) {
                    final l = AppLocalizations.of(context)!;
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final entry = _extractWoundEntry(args);
                    if (entry == null) {
                      return _NamedPlaceholderScreen(
                        title: l.wunddetailFehlendeArgumente,
                      );
                    }
                    return WoundEntryDetailScreen(entry: entry);
                  },
                  '/wound-compare': (context) {
                    final l = AppLocalizations.of(context)!;
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final compareEntries = _extractCompareEntries(args);
                    if (compareEntries == null) {
                      return _NamedPlaceholderScreen(
                        title: l.wundvergleichFehlendeArgumente,
                      );
                    }
                    return WoundCompareScreen(
                      entryA: compareEntries.$1,
                      entryB: compareEntries.$2,
                    );
                  },
                  '/wound-comparison': (_) => const WoundComparisonScreen(),
                  '/meds': (_) => const MedicationScreen(),
                  '/appointment': (_) => const AppointmentsScreen(),
                  '/appointments': (_) => const AppointmentsScreen(),
                  '/appointment-editor': (_) => const AppointmentEditorScreen(),
                  '/documents': (_) => const DocumentsScreen(),
                  '/photos': (_) => const PhotosScreen(),
                  '/doctor-report': (_) => const ReportScreen(),
                  '/doctor-report-legacy': (_) => const DoctorReportScreen(),
                  '/op-info': (_) => const OpInfoScreen(),
                  '/packing': (_) => const PackingListsScreen(),
                  '/nutrition': (_) => const NutritionScreen(),
                  '/nutrition-diary': (_) => const NutritionDiaryScreen(),
                  '/pain': (_) => const PainScreen(),
                  '/pain-diary': (_) => const PainDiaryScreen(),
                  '/sleep': (_) => const SleepScreen(),
                  '/sleep-diary': (_) => const SleepDiaryScreen(),
                  '/mood': (_) => const MoodScreen(),
                  '/mood-diary': (_) => const MoodScreen(),
                  '/doctor-questions': (_) => const DoctorQuestionsScreen(),
                  '/settings': (_) => const SettingsScreen(),
                  '/imprint': (_) => const ImprintScreen(),
                  '/privacy': (_) => const PrivacyScreen(),
                  '/terms': (_) => const TermsScreen(),
                  '/voice': (_) => const SpeechScreen(),
                  '/voice-memos': (_) => const VoiceMemosScreen(),
                  '/voice-memo-detail': (context) {
                    final memoId = ModalRoute.of(context)!.settings.arguments as String;
                    return VoiceMemoDetailScreen(memoId: memoId);
                  },
                  '/speech': (_) => const SpeechScreen(),
                  '/vitals': (_) => const VitalsScreen(),
                  '/warnings': (_) => const WarningsScreen(),
                  '/alerts': (_) => const AlertScreen(),
                  '/timeline': (_) => const TimelineFeedScreen(),
                  '/notifications': (_) => const NotificationCenterScreen(),
                  '/analytics': (_) => const AnalyticsScreen(),
                  '/health-report': (_) => const HealthReportScreen(),
                  '/rehab': (_) => const RehabScreen(),
                  '/bella-briefing': (_) => const BellaBriefingScreen(),
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
                  '/emergency': (_) => const EmergencyScreen(),
                  '/pro-status': (_) => const ProStatusScreen(),
                  '/redeem-key': (_) => const RedeemKeyScreen(),
                  '/invite-accept': (context) {
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final code = (args is Map && args['code'] is String)
                        ? args['code'] as String
                        : null;
                    return FamilyMemberHubScreen(initialCode: code);
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
    final l = AppLocalizations.of(context)!;
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
                            label: Text(l.medicationHubOpen),
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
                            label: Text(l.documentsOpen),
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
          final l = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(title: Text(l.noAccess)),
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Diese Seite konnte nicht geladen werden.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
