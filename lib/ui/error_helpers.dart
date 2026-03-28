import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Maps any error to a short, user-facing localised message.
///
/// Pass [l] (from `AppLocalizations.of(context)!`) to get a properly
/// localised string.  When [l] is `null` the function still works but
/// returns the German fallback so existing callers keep compiling.
String userFacingError(Object error, {AppLocalizations? l, String? fallback}) {
  final String fb = fallback ?? 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.';

  // ── FirebaseAuthException ──────────────────────────────────────
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'user-not-found' => l?.errorUserNotFound ?? 'Kein Konto mit dieser E\u2011Mail gefunden.',
      'wrong-password' || 'invalid-credential' =>
        l?.errorWrongPassword ?? 'Falsches Passwort.',
      'invalid-email' => l?.errorInvalidEmail ?? 'Ungültige E\u2011Mail-Adresse.',
      'email-already-in-use' => l?.errorEmailInUse ?? 'Diese E\u2011Mail wird bereits verwendet.',
      'weak-password' => l?.errorWeakPassword ?? 'Das Passwort ist zu schwach.',
      'user-disabled' => l?.errorUserDisabled ?? 'Dieses Konto wurde deaktiviert.',
      'too-many-requests' => l?.errorTooManyRequests ?? 'Zu viele Versuche. Bitte später erneut.',
      'requires-recent-login' =>
        l?.errorRequiresRecentLogin ?? 'Bitte melde dich erneut an, um fortzufahren.',
      'network-request-failed' =>
        l?.errorNoInternet ?? 'Keine Internetverbindung. Bitte prüfe dein Netzwerk.',
      'operation-not-allowed' => l?.errorOperationNotAllowed ?? 'Dieser Vorgang ist nicht erlaubt.',
      _ => fb,
    };
  }

  // ── FirebaseFunctionsException ─────────────────────────────────
  if (error is FirebaseFunctionsException) {
    return switch (error.code) {
      'not-found' => l?.errorNotFound ?? 'Nicht gefunden. Bitte prüfe die Eingabe.',
      'already-exists' => l?.errorAlreadyExists ?? 'Existiert bereits.',
      'permission-denied' || 'unauthenticated' =>
        l?.errorPermissionDenied ?? 'Keine Berechtigung für diese Aktion.',
      'invalid-argument' => l?.errorInvalidArgument ?? 'Ungültige Eingabe.',
      'failed-precondition' => l?.errorFailedPrecondition ?? 'Aktion kann nicht ausgeführt werden.',
      'unavailable' =>
        l?.errorServiceUnavailable ?? 'Der Dienst ist vorübergehend nicht erreichbar. Bitte versuche es später.',
      'deadline-exceeded' =>
        l?.errorDeadlineExceeded ?? 'Zeitüberschreitung. Bitte versuche es erneut.',
      'resource-exhausted' => l?.errorResourceExhausted ?? 'Zu viele Anfragen. Bitte warte kurz.',
      _ => fb,
    };
  }

  // ── FirebaseException (Firestore, Storage, etc.) ───────────────
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => l?.errorPermissionDenied ?? 'Keine Berechtigung für diese Aktion.',
      'unavailable' =>
        l?.errorServiceUnavailableShort ?? 'Der Dienst ist vorübergehend nicht erreichbar.',
      'not-found' => l?.errorNotFoundShort ?? 'Nicht gefunden.',
      'already-exists' => l?.errorAlreadyExists ?? 'Existiert bereits.',
      'cancelled' => l?.errorCancelled ?? 'Vorgang abgebrochen.',
      'deadline-exceeded' =>
        l?.errorDeadlineExceeded ?? 'Zeitüberschreitung. Bitte versuche es erneut.',
      'unauthenticated' => l?.errorPleaseSignIn ?? 'Bitte melde dich an.',
      _ => fb,
    };
  }

  // ── Substring matching for generic / wrapped errors ────────────
  final msg = error.toString().toLowerCase();
  if (msg.contains('permission') || msg.contains('berechtigung')) {
    return l?.errorPermissionDenied ?? 'Keine Berechtigung für diese Aktion.';
  }
  if (msg.contains('network') || msg.contains('internet') ||
      msg.contains('socket') || msg.contains('connection')) {
    return l?.errorNoInternet ?? 'Keine Internetverbindung. Bitte prüfe dein Netzwerk.';
  }
  if (msg.contains('not-found') || msg.contains('not found') ||
      msg.contains('nicht gefunden')) {
    return l?.errorNotFound ?? 'Nicht gefunden. Bitte prüfe die Eingabe.';
  }
  if (msg.contains('timeout') || msg.contains('timed out')) {
    return l?.errorDeadlineExceeded ?? 'Zeitüberschreitung. Bitte versuche es erneut.';
  }

  // Always log the real error for developers.
  debugPrint('[userFacingError] unhandled: $error');

  return fb;
}

/// Convenience wrapper that pulls [AppLocalizations] from [context].
String localizedError(BuildContext context, Object error, {String? fallback}) {
  return userFacingError(error, l: AppLocalizations.of(context)!, fallback: fallback);
}
