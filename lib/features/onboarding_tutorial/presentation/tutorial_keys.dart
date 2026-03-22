import 'package:flutter/material.dart';

/// Singleton holding [GlobalKey]s used by the onboarding tutorial
/// coach marks. Widgets register their keys here; the tutorial
/// overlay reads them.
class TutorialKeys {
  TutorialKeys._();
  static final TutorialKeys instance = TutorialKeys._();

  /// Key for the today-tasks card on the home screen (Step 1).
  final GlobalKey timelineKey = GlobalKey(debugLabel: 'tutorial_timeline');

  /// Key for the pain/new-entry quick action (Step 2).
  final GlobalKey painKey = GlobalKey(debugLabel: 'tutorial_pain');

  /// Key for the Bella AI FAB (Step 3).
  final GlobalKey bellaKey = GlobalKey(debugLabel: 'tutorial_bella');

  /// Key for the "Mehr" bottom-nav tab (Step 4).
  final GlobalKey mehrTabKey = GlobalKey(debugLabel: 'tutorial_mehr');
}
