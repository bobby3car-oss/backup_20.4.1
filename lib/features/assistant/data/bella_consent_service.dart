import 'package:shared_preferences/shared_preferences.dart';

/// Manages user consent for Bella AI data processing (DSGVO Art. 6/9).
///
/// Consent is stored locally and must be given before any chat messages
/// are sent to the external AI service (NVIDIA).
///
/// Stores consent version and timestamp to satisfy DSGVO Art. 7(1)
/// proof-of-consent requirements. When the consent text changes, bump
/// [_currentVersion] to force a re-consent prompt.
class BellaConsentService {
  BellaConsentService._();
  static final instance = BellaConsentService._();

  static const _key = 'bella_ai_consent_given';
  static const _versionKey = 'bella_ai_consent_version';
  static const _timestampKey = 'bella_ai_consent_timestamp';

  /// Bump this when the consent text changes to trigger re-consent.
  static const int _currentVersion = 2;

  bool _cached = false;
  bool _consentGiven = false;

  /// Whether the user has already consented to the current version.
  Future<bool> get hasConsented async {
    if (_cached) return _consentGiven;
    final prefs = await SharedPreferences.getInstance();
    final given = prefs.getBool(_key) ?? false;
    final version = prefs.getInt(_versionKey) ?? 0;
    // Re-consent required if the consent text version has changed.
    _consentGiven = given && version == _currentVersion;
    _cached = true;
    return _consentGiven;
  }

  /// Records that the user has given consent to the current version.
  Future<void> grantConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await prefs.setInt(_versionKey, _currentVersion);
    await prefs.setString(
        _timestampKey, DateTime.now().toUtc().toIso8601String());
    _consentGiven = true;
    _cached = true;
  }

  /// Revokes consent (e.g. from settings).
  Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_versionKey);
    await prefs.remove(_timestampKey);
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
