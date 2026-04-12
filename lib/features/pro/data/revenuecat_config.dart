import 'dart:io';

import 'package:flutter/foundation.dart';

/// RevenueCat configuration constants.
///
/// API keys are set at build time via `--dart-define`:
/// ```
/// flutter build ios  --dart-define=RC_API_KEY=appl_xxx
/// flutter build web  --dart-define=RC_WEB_API_KEY=rcb_pub_xxx
/// ```
abstract final class RevenueCatConfig {
  /// RevenueCat public API key for iOS / Android (App Store + Play Store).
  static const String apiKey = String.fromEnvironment(
    'RC_API_KEY',
    defaultValue: 'appl_IoYMfRfBydZzyoZKgycZDwrkeJx',
  );

  /// RevenueCat Web Billing public API key (web platform only).
  ///
  /// Obtain from RC Dashboard → Apps & providers → your Web Billing config
  /// → "Public API Key".  Safe to ship in production code.
  static const String webApiKey = String.fromEnvironment(
    'RC_WEB_API_KEY',
    defaultValue: '',
  );

  /// The entitlement identifier for "Operationsbegleiter Pro".
  static const String proEntitlementId = 'Operationsbegleiter Pro';

  /// The entitlement identifier for organisation Pro.
  static const String orgProEntitlementId = 'org_pro';

  /// Whether this platform supports native store purchases (iOS / Android).
  static bool get supportsNativePurchases =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Whether RevenueCat is configured and `getCustomerInfo()` is available.
  ///
  /// True on iOS/Android always; true on web when [webApiKey] is provided.
  static bool get isSupported {
    if (kIsWeb) return webApiKey.isNotEmpty;
    return Platform.isIOS || Platform.isAndroid;
  }
}
