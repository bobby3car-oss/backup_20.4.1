import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import 'smart_paywall.dart';

/// Legacy entry point – delegates to [ProUpsellBottomSheet] from
/// `smart_paywall.dart`.
///
/// Kept for backward-compatibility. New code should use
/// [SmartPaywall.trigger] or [ProUpsellBottomSheet.custom] directly.
class ProUpsellSheet {
  ProUpsellSheet._();

  /// Shows the feature or the upsell sheet depending on Pro status.
  static void show({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    String cta = 'Pro freischalten',
    required VoidCallback onProAction,
  }) {
    final pro = ProServices.of(context);
    if (pro.entitlementService.isPro) {
      onProAction();
      return;
    }

    HapticFeedback.lightImpact();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProUpsellBottomSheet.custom(
        icon: icon,
        iconColor: iconColor,
        title: title,
        body: body,
        cta: cta,
      ),
    );
  }
}
