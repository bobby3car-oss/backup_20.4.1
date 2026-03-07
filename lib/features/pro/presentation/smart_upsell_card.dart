import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/theme/colors.dart';
import '../domain/trigger_context.dart';

/// Inline upsell card for the dashboard.
///
/// Shows a non-aggressive upsell nudge with 🚀 emoji, descriptive text
/// and a CTA button. Respects [PaywallTriggerService.shouldShowDashboardUpsell]
/// and only renders for free users who have been active ≥ 3 days.
///
/// Drop this widget into any scrollable list for free users.
class SmartUpsellCard extends StatelessWidget {
  const SmartUpsellCard({super.key});

  @override
  Widget build(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    if (pro == null) return const SizedBox.shrink();
    if (pro.entitlementService.isPro) return const SizedBox.shrink();
    if (!pro.paywallTriggerService.shouldShowDashboardUpsell) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pro freischalten',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Schalte Arztbericht, Reha-System und weitere Pro-Funktionen frei, '
            'damit Nachsorge und Arzttermine deutlich einfacher werden.',
            style: tt.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _UpsellMiniPill(label: '🧑‍⚕️ Arztbericht'),
              _UpsellMiniPill(label: '🏋️ Reha-System'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                SmartPaywallHelper.openFromDashboard(context);
              },
              child: const Text('Freischalten'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpsellMiniPill extends StatelessWidget {
  const _UpsellMiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Helper to open paywall from the dashboard card context.
class SmartPaywallHelper {
  SmartPaywallHelper._();

  static void openFromDashboard(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/paywall',
      arguments: {'source': TriggerContext.dashboardCard.sourceKey},
    );
  }
}
