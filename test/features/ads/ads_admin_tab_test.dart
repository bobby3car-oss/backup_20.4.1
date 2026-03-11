import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/pro/data/billing_service.dart';
import 'package:operationsbegleiter_v3/features/ads/data/ad_config.dart';
import 'package:operationsbegleiter_v3/features/ads/data/ad_service.dart';
import 'package:operationsbegleiter_v3/features/ads/data/partner_ad.dart';
import 'package:operationsbegleiter_v3/features/ads/presentation/admin/ads_admin_tab.dart';
import 'package:operationsbegleiter_v3/features/ads/presentation/ad_banner_widget.dart';
import 'package:operationsbegleiter_v3/features/pro/data/entitlement_service.dart';
import 'package:operationsbegleiter_v3/features/pro/data/paywall_config.dart';
import 'package:operationsbegleiter_v3/features/pro/data/paywall_cooldown_storage.dart';
import 'package:operationsbegleiter_v3/features/pro/data/paywall_trigger_analytics.dart';
import 'package:operationsbegleiter_v3/features/pro/data/paywall_trigger_service.dart';
import 'package:operationsbegleiter_v3/features/pro/data/pro_analytics.dart';
import 'package:operationsbegleiter_v3/main.dart';

class _FakeAdService extends AdService {
  _FakeAdService({List<PartnerAd> partnerAds = const <PartnerAd>[]})
    : _partnerAds = partnerAds {
    config.value = const AdConfig(
      adsEnabled: true,
      googleAdsEnabled: true,
      partnerAdsEnabled: true,
      adFrequency: 5,
    );
  }

  final List<PartnerAd> _partnerAds;

  @override
  Stream<List<PartnerAd>> allPartnerAdsStream() {
    return Stream<List<PartnerAd>>.value(_partnerAds);
  }

  @override
  Future<void> updateConfig(AdConfig newConfig) async {
    config.value = newConfig;
  }
}

Widget _wrapWithScope(AdService service) {
  return MaterialApp(
    home: AdServiceScope(
      adService: service,
      child: const AdsAdminTab(),
    ),
  );
}

Widget _wrapBanner(AdService service) {
  final entitlementService = EntitlementService.disabled();
  final paywallConfig = PaywallConfig.disabled();

  return MaterialApp(
    home: ProServices(
      billingService: BillingService.disabledBackend(),
      entitlementService: entitlementService,
      proAnalytics: ProAnalytics.disabled(),
      paywallConfig: paywallConfig,
      paywallTriggerService: PaywallTriggerService(
        entitlementService: entitlementService,
        paywallConfig: paywallConfig,
        cooldownStorage: PaywallCooldownStorage(),
        triggerAnalytics: PaywallTriggerAnalytics.disabled(),
      ),
      child: Scaffold(
        body: AdServiceScope(
          adService: service,
          child: const AdBannerWidget(),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdsAdminTab', () {
    testWidgets('shows empty partner ads state', (tester) async {
      await tester.pumpWidget(_wrapWithScope(_FakeAdService()));
      await tester.pumpAndSettle();

      expect(find.text('Noch keine Partner-Anzeigen vorhanden.'), findsOneWidget);
      expect(find.text('Partner-Anzeigen (0)'), findsOneWidget);
    });

    testWidgets('requires title and url before creating partner ad', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithScope(_FakeAdService()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Partner-Anzeige'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Erstellen'));
      await tester.pump();

      expect(find.text('Titel und URL sind erforderlich.'), findsOneWidget);
    });

    testWidgets('rejects invalid partner ad urls', (tester) async {
      await tester.pumpWidget(_wrapWithScope(_FakeAdService()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Partner-Anzeige'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(0),
        'Test Partneranzeige',
      );
      await tester.enterText(find.byType(TextField).at(1), 'example.com');

      await tester.tap(find.text('Erstellen'));
      await tester.pump();

      expect(
        find.text('Bitte eine vollständige http(s)-URL eingeben.'),
        findsOneWidget,
      );
    });

    testWidgets('requires an image before submitting a valid ad', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithScope(_FakeAdService()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Partner-Anzeige'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(0),
        'Test Partneranzeige',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'https://example.com',
      );

      await tester.tap(find.text('Erstellen'));
      await tester.pump();

      expect(
        find.text('Bitte ein Bild für die Partner-Anzeige auswählen.'),
        findsOneWidget,
      );
    });
  });

  group('AdBannerWidget', () {
    testWidgets('shows debug preview when no live ad source is available', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapBanner(_FakeAdService()));
      await tester.pumpAndSettle();

      expect(find.text('Testanzeige'), findsOneWidget);
      expect(find.text('Anzeige'), findsOneWidget);
    });
  });
}