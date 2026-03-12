import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Maps any error to a short, user-friendly German message.
///
/// Use this everywhere instead of showing raw [Exception.toString()] output.
String userFacingError(Object error, {String? fallback}) {
  // ── FirebaseAuthException ──────────────────────────────────────
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'user-not-found' => 'Kein Konto mit dieser E\u2011Mail gefunden.',
      'wrong-password' || 'invalid-credential' =>
        'Falsches Passwort.',
      'invalid-email' => 'Ungültige E\u2011Mail-Adresse.',
      'email-already-in-use' => 'Diese E\u2011Mail wird bereits verwendet.',
      'weak-password' => 'Das Passwort ist zu schwach.',
      'user-disabled' => 'Dieses Konto wurde deaktiviert.',
      'too-many-requests' => 'Zu viele Versuche. Bitte später erneut.',
      'requires-recent-login' =>
        'Bitte melde dich erneut an, um fortzufahren.',
      'network-request-failed' =>
        'Keine Internetverbindung. Bitte prüfe dein Netzwerk.',
      'operation-not-allowed' => 'Dieser Vorgang ist nicht erlaubt.',
      _ => fallback ?? 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.',
    };
  }

  // ── FirebaseFunctionsException ─────────────────────────────────
  if (error is FirebaseFunctionsException) {
    return switch (error.code) {
      'not-found' => 'Nicht gefunden. Bitte prüfe die Eingabe.',
      'already-exists' => 'Existiert bereits.',
      'permission-denied' || 'unauthenticated' =>
        'Keine Berechtigung für diese Aktion.',
      'invalid-argument' => 'Ungültige Eingabe.',
      'failed-precondition' => 'Aktion kann nicht ausgeführt werden.',
      'unavailable' =>
        'Der Dienst ist vorübergehend nicht erreichbar. Bitte versuche es später.',
      'deadline-exceeded' =>
        'Zeitüberschreitung. Bitte versuche es erneut.',
      'resource-exhausted' => 'Zu viele Anfragen. Bitte warte kurz.',
      _ => fallback ?? 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.',
    };
  }

  // ── FirebaseException (Firestore, Storage, etc.) ───────────────
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => 'Keine Berechtigung für diese Aktion.',
      'unavailable' =>
        'Der Dienst ist vorübergehend nicht erreichbar.',
      'not-found' => 'Nicht gefunden.',
      'already-exists' => 'Existiert bereits.',
      'cancelled' => 'Vorgang abgebrochen.',
      'deadline-exceeded' =>
        'Zeitüberschreitung. Bitte versuche es erneut.',
      'unauthenticated' => 'Bitte melde dich an.',
      _ => fallback ?? 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.',
    };
  }

  // ── Substring matching for generic / wrapped errors ────────────
  final msg = error.toString().toLowerCase();
  if (msg.contains('permission') || msg.contains('berechtigung')) {
    return 'Keine Berechtigung für diese Aktion.';
  }
  if (msg.contains('network') || msg.contains('internet') ||
      msg.contains('socket') || msg.contains('connection')) {
    return 'Keine Internetverbindung. Bitte prüfe dein Netzwerk.';
  }
  if (msg.contains('not-found') || msg.contains('not found') ||
      msg.contains('nicht gefunden')) {
    return 'Nicht gefunden. Bitte prüfe die Eingabe.';
  }
  if (msg.contains('timeout') || msg.contains('timed out')) {
    return 'Zeitüberschreitung. Bitte versuche es erneut.';
  }

  // Always log the real error for developers.
  debugPrint('[userFacingError] unhandled: $error');

  return fallback ?? 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.';
}
