import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('telemetry is default-off until privacy consent enables it', () {
    final androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final iosPlist = File('ios/Runner/Info.plist').readAsStringSync();
    final macosPlist = File('macos/Runner/Info.plist').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(
      androidManifest,
      matches(
        RegExp(
          r'firebase_analytics_collection_enabled"[\s\S]*android:value="false"',
        ),
      ),
    );
    expect(
      androidManifest,
      matches(
        RegExp(
          r'firebase_crashlytics_collection_enabled"[\s\S]*android:value="false"',
        ),
      ),
    );
    expect(
      iosPlist,
      matches(
        RegExp(
          r'FIREBASE_ANALYTICS_COLLECTION_ENABLED</key>\s*<false/>',
        ),
      ),
    );
    expect(
      iosPlist,
      matches(
        RegExp(
          r'FirebaseCrashlyticsCollectionEnabled</key>\s*<false/>',
        ),
      ),
    );
    expect(
      macosPlist,
      matches(
        RegExp(
          r'FIREBASE_ANALYTICS_COLLECTION_ENABLED</key>\s*<false/>',
        ),
      ),
    );
    expect(
      macosPlist,
      matches(
        RegExp(
          r'FirebaseCrashlyticsCollectionEnabled</key>\s*<false/>',
        ),
      ),
    );

    expect(mainSource, contains('await PrivacyConsentService.instance.init();'));
    expect(mainSource, isNot(contains('recordFlutterFatalError')));
    expect(mainSource, isNot(contains('PlatformDispatcher.instance.onError =')));
  });
}