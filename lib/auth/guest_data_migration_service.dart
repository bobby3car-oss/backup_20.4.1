import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/user_scoped_storage.dart';
import '../screens/onboarding/login_screen.dart';
import '../l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context)!;
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
        title: Text(l.guestDataFound),
        content: const Text(
          'Du hast die App bereits als Gast benutzt. '
          'Möchtest du deine bisherigen Daten in deinen Account '
          'übertragen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.guestDataDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.guestDataTransfer),
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

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );

    return FirebaseAuth.instance.currentUser != null;
  }
}

