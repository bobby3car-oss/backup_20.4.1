import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/screens/symptom_checker_screen.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_theme.dart';

void main() {
  Widget buildApp() {
    return MaterialApp(
      theme: AppTheme.light,
      home: const SymptomCheckerScreen(),
    );
  }

  Future<void> ensureVisibleAndTap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  group('SymptomCheckerScreen — traffic light logic', () {
    testWidgets('shows green when no symptoms are severe', (tester) async {
      // Use a larger surface to avoid overlap issues with sticky header
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // All symptoms default to "none". Scroll to and tap "Auswertung anzeigen".
      await ensureVisibleAndTap(tester, find.text('Auswertung anzeigen'));

      // Should show green result text
      await tester.ensureVisible(find.text('Alles im grünen Bereich'));
      expect(find.text('Alles im grünen Bereich'), findsOneWidget);
    });

    testWidgets('shows red when multiple symptoms are severe', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Each "Stark" = weight 3. We need total ≥ 8, so 3 "Stark" = 9 points.
      for (var i = 0; i < 3; i++) {
        await ensureVisibleAndTap(tester, find.text('Stark').at(i));
      }

      await ensureVisibleAndTap(tester, find.text('Auswertung anzeigen'));

      await tester.ensureVisible(find.text('Ärztlichen Rat einholen'));
      expect(find.text('Ärztlichen Rat einholen'), findsOneWidget);
    });

    testWidgets('shows yellow for moderate symptoms', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap "Mittel" (weight 2) for 2 questions = 4 points → yellow threshold
      for (var i = 0; i < 2; i++) {
        await ensureVisibleAndTap(tester, find.text('Mittel').at(i));
      }

      await ensureVisibleAndTap(tester, find.text('Auswertung anzeigen'));

      await tester.ensureVisible(find.text('Bitte beobachten'));
      expect(find.text('Bitte beobachten'), findsOneWidget);
    });

    testWidgets('reset button clears results', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await ensureVisibleAndTap(tester, find.text('Auswertung anzeigen'));

      // Should show result with "Erneut prüfen"
      await ensureVisibleAndTap(tester, find.text('Erneut prüfen'));

      // Back to question screen — "Auswertung anzeigen" is present
      await tester.ensureVisible(find.text('Auswertung anzeigen'));
      expect(find.text('Auswertung anzeigen'), findsOneWidget);
    });
  });
}
