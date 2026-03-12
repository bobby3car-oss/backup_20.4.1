import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/user_scoped_storage.dart';
import '../ui/ui.dart';
import 'login_screen.dart';
import '../screens/onboarding/register_doctor_screen.dart';
import '../screens/onboarding/register_screen.dart';

/// Handles migration of locally stored guest data into a freshly
/// authenticated user account and provides an auth-requirement prompt
/// for features that need an account.
class GuestDataMigrationService {
  GuestDataMigrationService._();

  // ── Guest data migration ──────────────────────────────────────────

  /// Shows a migration dialog when anonymous data exists that hasn't
  /// been migrated for [uid] yet. Call this once after the user signs in.
  static Future<void> promptMigrationIfNeeded(
    BuildContext context,
    String uid,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final doneKey = 'guest_migration_done_$uid';
    if (prefs.getBool(doneKey) == true) return;

    final storage = UserScopedStorage.instance;
    final hasData = await storage.hasAnonymousData();
    if (!hasData) {
      await prefs.setBool(doneKey, true);
      return;
    }

    if (!context.mounted) return;

    final shouldMigrate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Lokale Daten gefunden'),
        content: const Text(
          'Du hast die App bereits als Gast benutzt. '
          'Möchtest du deine bisherigen Daten in deinen Account '
          'übertragen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Nein, verwerfen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ja, übertragen'),
          ),
        ],
      ),
    );

    if (shouldMigrate == true) {
      await storage.migrateGuestDataTo(uid);
    }
    await storage.clearAnonymousData();
    await prefs.setBool(doneKey, true);
  }

  // ── Auth requirement prompt ───────────────────────────────────────

  /// Returns `true` if a user is already signed in. If not, shows a
  /// modal explaining that an account is required and offers
  /// login / register options. Returns `true` when the user has
  /// successfully authenticated after the prompt, `false` if they
  /// cancel.
  static Future<bool> requireAuth(
    BuildContext context, {
    String? reason,
  }) async {
    if (FirebaseAuth.instance.currentUser != null) return true;

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AuthRequiredSheet(reason: reason),
    );

    // After the sheet closes, check if auth succeeded.
    return result == true || FirebaseAuth.instance.currentUser != null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AuthRequiredSheet extends StatelessWidget {
  const _AuthRequiredSheet({this.reason});
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ──
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Konto erforderlich',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reason ??
                  'Für dieses Feature ist ein kostenloses Konto '
                      'erforderlich.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Jetzt registrieren'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Anmelden'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterDoctorScreen(),
                        ),
                      );
                    },
                    child: const Text('Als Arzt'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Abbrechen',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
