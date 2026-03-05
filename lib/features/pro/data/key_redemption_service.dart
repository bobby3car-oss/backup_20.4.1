import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Result of a Pro key redemption attempt.
class KeyRedemptionResult {
  const KeyRedemptionResult({
    required this.success,
    this.isPro = false,
    this.expiresAt,
    this.errorMessage,
  });

  final bool success;
  final bool isPro;
  final DateTime? expiresAt;
  final String? errorMessage;

  factory KeyRedemptionResult.fromResponse(Map<String, dynamic> data) {
    final expiresAtStr = data['expiresAt'] as String?;
    return KeyRedemptionResult(
      success: true,
      isPro: data['isPro'] as bool? ?? false,
      expiresAt:
          expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null,
    );
  }

  factory KeyRedemptionResult.error(String message) {
    return KeyRedemptionResult(success: false, errorMessage: message);
  }
}

/// Calls the `redeemProKey` Cloud Function.
///
/// This service does NOT modify any local state – it only forwards the key
/// to the server. After a successful redemption the caller should trigger
/// [EntitlementService.refresh] so the UI picks up the new Pro state.
class KeyRedemptionService {
  KeyRedemptionService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;

  /// Redeem a raw Pro key.
  ///
  /// Returns a [KeyRedemptionResult] with either the new entitlement data
  /// or a user-facing error message.
  Future<KeyRedemptionResult> redeem(String rawKey) async {
    final trimmed = rawKey.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return KeyRedemptionResult.error('Bitte gib einen Key ein.');
    }

    try {
      final callable = _functions.httpsCallable('redeemProKey');
      final result = await callable.call<dynamic>({'key': trimmed});
      if (result.data is! Map) {
        return KeyRedemptionResult.error('Ungültige Server-Antwort.');
      }
      final data = Map<String, dynamic>.from(result.data as Map);
      return KeyRedemptionResult.fromResponse(data);
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        debugPrint('[KeyRedemptionService] CF error: ${e.code} ${e.message}');
      }
      return KeyRedemptionResult.error(_mapError(e));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[KeyRedemptionService] Unexpected error: $e');
      }
      return KeyRedemptionResult.error(
        'Ein unerwarteter Fehler ist aufgetreten.',
      );
    }
  }

  String _mapError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
        return 'Key nicht gefunden oder bereits eingelöst.';
      case 'failed-precondition':
        return 'Dieser Key wurde bereits eingelöst.';
      case 'unauthenticated':
        return 'Du musst angemeldet sein.';
      case 'invalid-argument':
        return 'Ungültiger Key.';
      default:
        return e.message ?? 'Fehler beim Einlösen des Keys.';
    }
  }
}
