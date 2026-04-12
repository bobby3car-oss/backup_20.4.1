import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

class AppCheckService {
  AppCheckService._();

  static const String _webSiteKey = String.fromEnvironment(
    'FIREBASE_APP_CHECK_WEB_SITE_KEY',
  );

  static Future<void> activate({FirebaseAppCheck? instance}) async {
    try {
      await _activateInternal(instance: instance);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppCheck] Activation failed (non-fatal): $e');
      }
    }
  }

  static Future<void> _activateInternal({FirebaseAppCheck? instance}) async {
    final appCheck = instance ?? FirebaseAppCheck.instance;

    if (kIsWeb) {
      if (_webSiteKey.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[AppCheck] Web skipped: FIREBASE_APP_CHECK_WEB_SITE_KEY missing.',
          );
        }
        return;
      }
      await appCheck.activate(providerWeb: ReCaptchaV3Provider(_webSiteKey));
      await appCheck.setTokenAutoRefreshEnabled(true);
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await appCheck.activate(
          providerAndroid: kDebugMode
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
        );
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        await appCheck.activate(
          providerApple: kDebugMode
              ? const AppleDebugProvider()
              : const AppleAppAttestWithDeviceCheckFallbackProvider(),
        );
        break;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        if (kDebugMode) {
          debugPrint('[AppCheck] Skipped on unsupported desktop platform.');
        }
        return;
      default:
        if (kDebugMode) {
          debugPrint('[AppCheck] Skipped on unsupported platform.');
        }
        return;
    }

    await appCheck.setTokenAutoRefreshEnabled(true);
  }
}
