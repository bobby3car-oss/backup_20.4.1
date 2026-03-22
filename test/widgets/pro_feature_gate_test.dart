import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/pro/presentation/pro_feature_gate_view.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_theme.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('ProFeatureGateView — gate when not pro', () {
    testWidgets('shows PRO badge, hero title, and CTA', (tester) async {
      var ctaTapped = false;

      await tester.pumpWidget(buildApp(
        child: ProFeatureGateView(
          pageTitle: 'Analytics',
          pageIcon: Icons.analytics,
          pageColor: Colors.purple,
          heroIcon: Icons.analytics,
          heroTitle: 'Deine Daten erzählen eine Geschichte',
          heroSubtitle: 'Teste PRO jetzt',
          primaryCta: 'Jetzt Pro freischalten',
          onPrimaryTap: () => ctaTapped = true,
          benefits: const [
            ('Vorteil 1', 'Beschreibung 1'),
            ('Vorteil 2', 'Beschreibung 2'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // Gate shows PRO badge
      expect(find.text('PRO'), findsOneWidget);

      // Gate shows hero title
      expect(
        find.text('Deine Daten erzählen eine Geschichte'),
        findsOneWidget,
      );

      // Gate shows CTA button
      expect(find.text('Jetzt Pro freischalten'), findsOneWidget);

      // Benefits are listed
      expect(find.text('Vorteil 1'), findsOneWidget);
      expect(find.text('Vorteil 2'), findsOneWidget);

      // Tap CTA triggers callback
      await tester.tap(find.text('Jetzt Pro freischalten'));
      expect(ctaTapped, true);
    });

    testWidgets('shows optional secondary button', (tester) async {
      var secondaryTapped = false;

      await tester.pumpWidget(buildApp(
        child: ProFeatureGateView(
          pageTitle: 'Test',
          pageIcon: Icons.star,
          pageColor: Colors.blue,
          heroIcon: Icons.star,
          heroTitle: 'Title',
          heroSubtitle: 'Subtitle',
          primaryCta: 'Upgrade',
          onPrimaryTap: () {},
          benefits: const [('B', 'D')],
          secondaryLabel: 'Vorschau ansehen',
          onSecondaryTap: () => secondaryTapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Vorschau ansehen'), findsOneWidget);

      await tester.tap(find.text('Vorschau ansehen'));
      expect(secondaryTapped, true);
    });

    testWidgets('no secondary button when label is null', (tester) async {
      await tester.pumpWidget(buildApp(
        child: ProFeatureGateView(
          pageTitle: 'Test',
          pageIcon: Icons.star,
          pageColor: Colors.blue,
          heroIcon: Icons.star,
          heroTitle: 'Title',
          heroSubtitle: 'Subtitle',
          primaryCta: 'Upgrade',
          onPrimaryTap: () {},
          benefits: const [('B', 'D')],
        ),
      ));
      await tester.pumpAndSettle();

      // No secondary button
      expect(find.text('Vorschau ansehen'), findsNothing);
    });
  });

  group('Pro conditional pattern — shows content when pro', () {
    testWidgets('isPro=false shows gate, isPro=true shows content',
        (tester) async {
      // Simulates the common pattern used across the app:
      // if (!isPro) return ProFeatureGateView(...) else actual content
      Widget buildScreen({required bool isPro}) {
        if (!isPro) {
          return ProFeatureGateView(
            pageTitle: 'Feature',
            pageIcon: Icons.star,
            pageColor: Colors.blue,
            heroIcon: Icons.star,
            heroTitle: 'Pro erforderlich',
            heroSubtitle: 'Upgrade nötig',
            primaryCta: 'Upgrade',
            onPrimaryTap: () {},
            benefits: const [('Pro Feature', 'Beschreibung')],
          );
        }
        return const Center(
          child: Text('Pro Content geladen'),
        );
      }

      // Test non-pro: shows gate
      await tester.pumpWidget(buildApp(child: buildScreen(isPro: false)));
      await tester.pumpAndSettle();

      expect(find.text('Pro erforderlich'), findsOneWidget);
      expect(find.text('Pro Content geladen'), findsNothing);

      // Test pro: shows content
      await tester.pumpWidget(buildApp(child: buildScreen(isPro: true)));
      await tester.pumpAndSettle();

      expect(find.text('Pro Content geladen'), findsOneWidget);
      expect(find.text('Pro erforderlich'), findsNothing);
    });
  });
}
