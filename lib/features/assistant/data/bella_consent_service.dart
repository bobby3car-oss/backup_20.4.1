import 'package:shared_preferences/shared_preferences.dart';

/// Manages user consent for Bella AI data processing (DSGVO Art. 6/9).
///
/// Consent is stored locally and must be given before any chat messages
/// are sent to the external AI service (NVIDIA).
class BellaConsentService {
  BellaConsentService._();
  static final instance = BellaConsentService._();

  static const _key = 'bella_ai_consent_given';

  bool _cached = false;
  bool _consentGiven = false;

  /// Whether the user has already consented to Bella AI data processing.
  Future<bool> get hasConsented async {
    if (_cached) return _consentGiven;
    final prefs = await SharedPreferences.getInstance();
    _consentGiven = prefs.getBool(_key) ?? false;
    _cached = true;
    return _consentGiven;
  }

  /// Records that the user has given consent.
  Future<void> grantConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _consentGiven = true;
    _cached = true;
  }

  /// Revokes consent (e.g. from settings).
  Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _consentGiven = false;
    _cached = true;
  }

  /// Resets the in-memory cache so the next [hasConsented] call re-reads
  /// from SharedPreferences. Call after SharedPreferences are cleared
  /// (e.g. on sign-out) to prevent stale cached values.
  void resetCache() {
    _cached = false;
    _consentGiven = false;
  }
}
