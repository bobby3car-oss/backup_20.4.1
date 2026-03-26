import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';

import '../../../auth/auth_service.dart';
import '../../../screens/onboarding/login_screen.dart';
import '../../../screens/onboarding/register_screen.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../locale/locale_provider.dart';
import '../../../locale/language_picker.dart';
import '../../../sync/sync_status_service.dart';
import '../../../sync/storage_upload_queue.dart';
import '../../mood/data/mood_repository_sync.dart';
import '../../nutrition/data/nutrition_repository_sync.dart';
import '../../pain/data/pain_repository_sync.dart';
import '../../questions/data/questions_repository_sync.dart';
import '../../red_flags/data/red_flag_repository_sync.dart';
import '../../rehab/data/rehab_session_repository_sync.dart';
import '../../medication/data/medication_repository_sync.dart';
import '../../vitals/data/vital_repository_sync.dart';
import '../../../ui/ui.dart';
import '../data/data_export_service.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../wound/data/wound_repository_local.dart';
import '../../appointments/data/appointments_repository_local.dart';
import '../../questions/data/questions_repository_local.dart';
import '../../documents/data/documents_repository_local.dart';
import '../../photos/data/photos_repository_local.dart';
import '../../voice/data/voice_repository_local.dart';
import '../../rehab/data/rehab_session_repository_local.dart';
import '../../packing/data/packing_repository_local.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../security/privacy_consent_service.dart';
import '../../assistant/data/bella_consent_service.dart';
import '../../onboarding_tutorial/data/tutorial_preferences.dart';
import '../../../main.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _keyPush = 'pref_push_enabled';
  static const _keyMail = 'pref_email_enabled';

  bool _pushEnabled = true;
  bool _mailEnabled = false;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pushEnabled = prefs.getBool(_keyPush) ?? true;
      _mailEnabled = prefs.getBool(_keyMail) ?? false;
      _prefsLoaded = true;
    });
  }

  Future<void> _setPush(bool value) async {
    setState(() => _pushEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPush, value);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final tokenDocRef = firestore.doc(FirestorePaths.userPushTokenDoc(uid));
      final userDocRef = firestore.doc(FirestorePaths.userDoc(uid));
      if (value) {
        // Re-register FCM token.
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await tokenDocRef.set(<String, dynamic>{
            'token': token,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await userDocRef.set(<String, dynamic>{
          'fcmToken': FieldValue.delete(),
          'fcmTokenUpdatedAt': FieldValue.delete(),
        }, SetOptions(merge: true));
      } else {
        // Remove FCM token so no push is sent.
        await tokenDocRef.delete();
        await userDocRef.set(<String, dynamic>{
          'fcmToken': FieldValue.delete(),
          'fcmTokenUpdatedAt': FieldValue.delete(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[Settings] _setPush failed: $e');
      await prefs.setBool(_keyPush, !value);
      if (!mounted) return;
      setState(() => _pushEnabled = !value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einstellung konnte nicht gespeichert werden.')),
        );
      }
    }
  }

  Future<void> _setMail(bool value) async {
    setState(() => _mailEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMail, value);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.doc(FirestorePaths.userDoc(uid)).set(
        <String, dynamic>{'emailNotificationsEnabled': value},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[Settings] _setMail failed: $e');
      await prefs.setBool(_keyMail, !value);
      if (!mounted) return;
      setState(() => _mailEnabled = !value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einstellung konnte nicht gespeichert werden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.of(context);
    final currentLang =
        LocaleProvider.localeLabels[localeProvider.locale.languageCode];
    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!
        : l.settingsNotAvailable;
    const buildName = String.fromEnvironment(
      'FLUTTER_BUILD_NAME',
      defaultValue: 'dev',
    );
    const buildNumber = String.fromEnvironment(
      'FLUTTER_BUILD_NUMBER',
      defaultValue: '0',
    );

    return GlassPage(
      title: l.settingsTitle,
      titleIcon: AppIcons.settings,
      titleColor: AppColors.grey600,
      horizontalPadding: AppSpacing.lg,
      children: [
        // ── Language ──
        _SectionCard(
          title: l.languageLabel,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(
              currentLang?.flag ?? '🌐',
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(currentLang?.name ?? ''),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLanguagePicker(context),
          ),
        ),
        const SizedBox(height: 12),
        if (user == null)
          _GuestAccountBanner()
        else
          _SectionCard(
            title: l.settingsAccount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l.fieldEmail}: $email'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async => AuthService().signOut(),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l.settingsLogout),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l.settingsNotifications,
          child: Column(
            children: [
              if (user == null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.notifications_off_rounded,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(l.settingsPush),
                  subtitle: const Text('Konto erforderlich'),
                  enabled: false,
                )
              else ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.settingsPush),
                  value: _pushEnabled,
                  onChanged: _prefsLoaded ? _setPush : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.settingsEmailNotif),
                  value: _mailEnabled,
                  onChanged: _prefsLoaded ? _setMail : null,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l.settingsData,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.upload_file_rounded),
                title: Text(l.settingsExportData),
                onTap: () {
                  final isPro = ProServices.maybeOf(context)
                          ?.entitlementService
                          .isPro ??
                      false;
                  if (!isPro) {
                    SmartPaywall.trigger(
                      context: context,
                      triggerContext: TriggerContext.dataExport,
                    );
                    return;
                  }
                  DataExportService.showExportSheet(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_sweep_rounded),
                title: Text(l.settingsResetData),
                onTap: () => _showResetDialog(context, l),
              ),
              if (user != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_remove_rounded,
                      color: Colors.red),
                  title: const Text(
                    'Konto löschen',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Alle Daten unwiderruflich entfernen'),
                  onTap: () => _deleteAccount(context),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l.settingsPro,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_rounded),
            title: Text(l.settingsProStatus),
            subtitle: Text(l.settingsProSubtitle),
            onTap: () => Navigator.of(context).pushNamed('/pro-status'),
          ),
        ),
        const SizedBox(height: 12),
        const _SyncStatusCard(),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Werbung & Datenschutz',
          child: const _AdsInfoSettings(),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Hilfe',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.school_rounded),
            title: const Text('Tutorial wiederholen'),
            subtitle: const Text('Einführung nochmals anzeigen'),
            onTap: () async {
              await TutorialPreferences.instance.resetTutorial();
              if (context.mounted) {
                _snack(context, 'Tutorial wird beim nächsten Start angezeigt.');
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l.settingsLegal,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l.medicalDisclaimer,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.business_rounded),
                title: Text(l.settingsImprint),
                onTap: () => Navigator.of(context).pushNamed('/imprint'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_rounded),
                title: Text(l.settingsPrivacy),
                onTap: () => Navigator.of(context).pushNamed('/privacy'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.gavel_rounded),
                title: Text(l.settingsTerms),
                onTap: () => Navigator.of(context).pushNamed('/terms'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l.settingsVersion,
          child: Text('${l.settingsVersion} $buildName+$buildNumber'),
        ),
      ],
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showResetDialog(
    BuildContext context,
    AppLocalizations l,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daten zurücksetzen'),
        content: const Text(
          'Möchten Sie nur Ihre lokalen Gesundheitsdaten löschen '
          'oder Ihren gesamten Account dauerhaft entfernen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'data'),
            child: const Text('Nur Daten löschen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'account'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Account löschen'),
          ),
        ],
      ),
    );

    if (choice == null || !context.mounted) return;

    if (choice == 'data') {
      await _resetLocalData(context);
    } else if (choice == 'account') {
      await _deleteAccount(context);
    }
  }

  Future<void> _resetLocalData(BuildContext context) async {
    try {
      await Future.wait([
        PainRepositoryLocal.instance.deleteAll(),
        VitalRepositoryLocal.instance.deleteAll(),
        MedicationRepositoryLocal.instance.deleteAll(),
        WoundRepositoryLocal.instance.deleteAll(),
        AppointmentsRepositoryLocal.instance.deleteAll(),
        QuestionsRepositoryLocal.instance.deleteAll(),
        DocumentsRepositoryLocal.instance.deleteAll(),
        PhotosRepositoryLocal.instance.deleteAll(),
        VoiceRepositoryLocal.instance.deleteAll(),
        RehabSessionRepositoryLocal.instance.deleteAll(),
        PackingRepositoryLocal.instance.deleteAll(),
      ]);

      // Also delete Firestore subcollections
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final fs = FirebaseFirestore.instance;
        final subs = [
          FirestorePaths.painCollection(uid),
          FirestorePaths.woundsCollection(uid),
          FirestorePaths.appointmentsCollection(uid),
          FirestorePaths.questionsCollection(uid),
          FirestorePaths.documentsCollection(uid),
          FirestorePaths.photosCollection(uid),
          FirestorePaths.voiceMemosCollection(uid),
          FirestorePaths.packingCollection(uid),
          FirestorePaths.warningsCollection(uid),
          FirestorePaths.observationsCollection(uid),
        ];
        for (final path in subs) {
          final snap = await fs.collection(path).limit(500).get();
          final batch = fs.batch();
          for (final doc in snap.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }

      if (context.mounted) {
        _snack(context, 'Alle Gesundheitsdaten wurden gelöscht.');
      }
    } catch (e) {
      debugPrint('[Settings] _resetLocalData failed: $e');
      if (context.mounted) {
        _snack(context, 'Einige Daten konnten nicht gelöscht werden.');
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account endgültig löschen?'),
        content: const Text(
          'Diese Aktion kann nicht rückgängig gemacht werden. '
          'Alle Ihre Daten werden unwiderruflich gelöscht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await _resetLocalData(context);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final db = FirebaseFirestore.instance;
        final patientRef = db.doc(FirestorePaths.patientDoc(uid));

        // Delete all patient subcollections (DSGVO Art. 17).
        const subs = [
          'links', 'invites', 'timeline', 'wounds', 'pain',
          'voice_memos', 'appointments', 'documents', 'photos',
          'packing', 'questions', 'warnings', 'observations',
          'red_flags', 'gamification', 'gamification_log',
          'daily_challenges', 'notifications', 'bella_chat',
        ];
        for (final sub in subs) {
          final snap = await patientRef.collection(sub).limit(500).get();
          for (final doc in snap.docs) {
            await doc.reference.delete();
          }
        }

        // Delete push token doc.
        try {
          await db.doc('${FirestorePaths.userPushTokens}/$uid').delete();
        } catch (_) {}

        // Delete top-level docs.
        await db.doc(FirestorePaths.userDoc(uid)).delete();
        await patientRef.delete();

        // Delete auth account.
        await user.delete();
      }

      // Clear all consent preferences (DSGVO: no leftover data).
      await BellaConsentService.instance.revokeConsent();
      await PrivacyConsentService.instance.setAnalyticsEnabled(false);
      await PrivacyConsentService.instance.setCrashlyticsEnabled(false);

      await AuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) await _reauthAndDelete(context);
      } else if (context.mounted) {
        _snack(context, userFacingError(e, fallback: 'Fehler beim Löschen.'));
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, userFacingError(e, fallback: 'Fehler beim Löschen.'));
      }
    }
  }

  /// Re-authenticates the user and retries account deletion.
  Future<void> _reauthAndDelete(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Determine provider
    final providers =
        user.providerData.map((p) => p.providerId).toSet();
    final isApple = providers.contains('apple.com');
    final isGoogle = providers.contains('google.com');
    final isPassword = providers.contains('password');

    try {
      if (isApple) {
        final appleProvider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        await user.reauthenticateWithProvider(appleProvider);
      } else if (isGoogle) {
        final googleProvider = GoogleAuthProvider();
        await user.reauthenticateWithProvider(googleProvider);
      } else if (isPassword) {
        final password = await _askPassword(context);
        if (password == null || !context.mounted) return;
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(cred);
      } else {
        if (context.mounted) {
          _snack(context,
              'Bitte melde dich ab und erneut an, dann versuche es nochmal.');
        }
        return;
      }

      // Retry deletion after re-auth
      await user.delete();

      // Clear consent preferences (DSGVO).
      await BellaConsentService.instance.revokeConsent();
      await PrivacyConsentService.instance.setAnalyticsEnabled(false);
      await PrivacyConsentService.instance.setCrashlyticsEnabled(false);

      await AuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, userFacingError(e, fallback: 'Fehler beim Löschen.'));
      }
    }
  }

  Future<String?> _askPassword(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Passwort bestätigen'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Passwort',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sync Status Card
// ─────────────────────────────────────────────────────────────────────────────

class _SyncStatusCard extends StatefulWidget {
  const _SyncStatusCard();

  @override
  State<_SyncStatusCard> createState() => _SyncStatusCardState();
}

class _SyncStatusCardState extends State<_SyncStatusCard> {
  bool _isSyncing = false;

  String _formatLastSync(BuildContext context, DateTime? lastSync) {
    if (lastSync == null) return 'Noch nie synchronisiert';
    final diff = DateTime.now().difference(lastSync);
    if (diff.inSeconds < 60) return 'Gerade eben';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Vor $m ${m == 1 ? "Minute" : "Minuten"}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'Vor $h ${h == 1 ? "Stunde" : "Stunden"}';
    }
    final d = diff.inDays;
    return 'Vor $d ${d == 1 ? "Tag" : "Tagen"}';
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      SyncStatusService.instance.markSyncing();
      // Trigger the same reconnect-style sync used by ConnectivityService.
      await Future.wait(<Future<void>>[
        PainRepositorySync.instance.syncNow(),
        MoodRepositorySync.instance.syncNow(),
        VitalRepositorySync.instance.syncNow(),
        MedicationRepositorySync.instance.syncNow(),
        RehabSessionRepositorySync.instance.syncNow(),
        NutritionRepositorySync.instance.syncNow(),
        QuestionsRepositorySync.instance.syncNow(),
        RedFlagRepositorySync.instance.syncNow(),
        StorageUploadQueue.instance.retryAll(),
      ]);
      await SyncStatusService.instance.markSynced();
    } catch (_) {
      // Best effort – indicator will recalculate automatically.
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: SyncStatusService.instance.lastSyncTime,
      builder: (context, lastSync, _) {
        return ValueListenableBuilder<int>(
          valueListenable: SyncStatusService.instance.pendingCount,
          builder: (context, pending, _) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Synchronisation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Letzte Synchronisation: ${_formatLastSync(context, lastSync)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (pending > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$pending ${pending == 1 ? "Eintrag wartet" : "Einträge warten"} auf Sync',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSyncing ? null : _syncNow,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          _isSyncing
                              ? 'Synchronisiert…'
                              : 'Jetzt synchronisieren',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _GuestAccountBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Daten sichern & überall nutzen',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Erstelle ein kostenloses Konto um deine Daten zu '
              'sichern und auf allen Geräten zu synchronisieren.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Registrieren'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Anmelden'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdsInfoSettings extends StatefulWidget {
  const _AdsInfoSettings();

  @override
  State<_AdsInfoSettings> createState() => _AdsInfoSettingsState();
}

class _AdsInfoSettingsState extends State<_AdsInfoSettings> {
  final _privacy = PrivacyConsentService.instance;
  late bool _analytics = _privacy.analyticsEnabled;
  late bool _crashlytics = _privacy.crashlyticsEnabled;
  bool _bellaConsent = false;

  @override
  void initState() {
    super.initState();
    _loadBellaConsent();
  }

  Future<void> _loadBellaConsent() async {
    final v = await BellaConsentService.instance.hasConsented;
    if (mounted) setState(() => _bellaConsent = v);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.privacy_tip_rounded),
          title: Text('Werbeanzeigen'),
          subtitle: Text(
            'Nutzer ohne Pro-Abo sehen Werbeanzeigen, sofern Werbung '
            'in der App aktiviert ist. Mit aktivem Pro-Abo werden '
            'keine Anzeigen geladen.',
          ),
          isThreeLine: true,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.analytics_outlined),
          title: const Text('Nutzungsstatistiken'),
          subtitle: const Text(
            'Anonymisierte Daten zur Verbesserung der App senden.',
          ),
          value: _analytics,
          onChanged: (v) async {
            setState(() => _analytics = v);
            await _privacy.setAnalyticsEnabled(v);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.bug_report_outlined),
          title: const Text('Absturzberichte'),
          subtitle: const Text(
            'Absturzberichte zur Fehlerbehebung senden.',
          ),
          value: _crashlytics,
          onChanged: (v) async {
            setState(() => _crashlytics = v);
            await _privacy.setCrashlyticsEnabled(v);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.smart_toy_outlined),
          title: const Text('Bella KI-Assistent'),
          subtitle: const Text(
            'Einwilligung zur Datenübermittlung an den '
            'KI-Dienst (NVIDIA).',
          ),
          value: _bellaConsent,
          onChanged: (v) async {
            if (v) {
              await BellaConsentService.instance.grantConsent();
            } else {
              await BellaConsentService.instance.revokeConsent();
            }
            if (!mounted) return;
            setState(() => _bellaConsent = v);
          },
        ),
      ],
    );
  }
}
