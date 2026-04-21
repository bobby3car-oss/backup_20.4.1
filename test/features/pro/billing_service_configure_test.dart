import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/pro/data/billing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BillingService.configureRevenueCatSdk', () {
    test('is safe to call concurrently 10 times in a row', () async {
      final futures = List.generate(
        10,
        (_) => BillingService.configureRevenueCatSdk(),
      );
      await expectLater(Future.wait(futures), completes);
    });

    test('is idempotent across sequential calls', () async {
      for (var i = 0; i < 10; i++) {
        await expectLater(
          BillingService.configureRevenueCatSdk(),
          completes,
        );
      }
    });

    test('sdkConfigured stays false on host platform (no native store)',
        () async {
      await BillingService.configureRevenueCatSdk();
      expect(BillingService.sdkConfigured, isFalse);
    });
  });

  group('BillingService.restorePurchases guard', () {
    test('does not throw when SDK is not configured', () async {
      final billing = BillingService.enabled();
      RestoreResult? result;
      billing.onRestoreComplete = (r) => result = r;

      for (var i = 0; i < 10; i++) {
        await expectLater(billing.restorePurchases(), completes);
      }
      expect(result, RestoreResult.error);
    });
  });
}
