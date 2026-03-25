import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/colors.dart';
import '../data/billing_service.dart';
import '../data/entitlement_service.dart';
import '../domain/entitlement.dart';
import '../../../ui/theme/app_icons.dart';

/// Settings screen showing Pro status, manage subscription, restore, key redeem.
class ProStatusScreen extends StatefulWidget {
  const ProStatusScreen({super.key});

  @override
  State<ProStatusScreen> createState() => _ProStatusScreenState();
}

class _ProStatusScreenState extends State<ProStatusScreen> {
  late final EntitlementService _entitlement;
  late final BillingService _billing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pro = ProServices.of(context);
    _entitlement = pro.entitlementService;
    _billing = pro.billingService;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Entitlement>(
      valueListenable: _entitlement.entitlement,
      builder: (context, entitlement, _) {
        return GlassPage(
          title: 'Pro Status',
          titleIcon: AppIcons.pro,
          titleColor: AppColors.primary,
          horizontalPadding: AppSpacing.lg,
          children: [
            if (entitlement.isActive)
              _ProActiveCard(entitlement: entitlement)
            else
              _FreeTeaser(
                onUpgrade: () => Navigator.of(context).pushNamed(
                  '/paywall',
                  arguments: {'source': 'settings'},
                ),
              ),
            const SizedBox(height: 16),
            if (entitlement.isActive) ...[
              const _ProBenefitsCard(),
              const SizedBox(height: 16),
            ],
            _ActionsCard(
              isPro: entitlement.isActive,
              billing: _billing,
              onRestore: () async {
                _billing.restorePurchases();
              },
              onManage: () {
                // Opens platform subscription management
                _billing.openSubscriptionManagement();
              },
            ),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Pro Active Card
// ══════════════════════════════════════════════════════════════════════

class _ProActiveCard extends StatelessWidget {
  const _ProActiveCard({required this.entitlement});

  final Entitlement entitlement;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    String? validUntil;
    if (entitlement.proExpiresAt != null) {
      final d = entitlement.proExpiresAt!;
      validUntil =
          '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }

    String sourceLabel;
    if (entitlement.proProductId != null) {
      sourceLabel = entitlement.proProductId!.contains('yearly')
          ? 'Jahresabo'
          : 'Monatsabo';
    } else {
      sourceLabel = 'Pro Mitgliedschaft';
    }

    return GlassContainer(
      child: Column(
        children: [
          GlassIcon(icon: AppIcons.done, color: AppIcons.doneColor, size: 30),
          const SizedBox(height: 12),
          Text(
            'Pro aktiv',
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sourceLabel,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (validUntil != null) ...[
            const SizedBox(height: 4),
            Text(
              'Gültig bis $validUntil',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Free Teaser Card
// ══════════════════════════════════════════════════════════════════════

class _FreeTeaser extends StatelessWidget {
  const _FreeTeaser({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      child: Column(
        children: [
          GlassIcon(icon: AppIcons.pro, color: AppIcons.proColor, size: 30),
          const SizedBox(height: 12),
          Text(
            'Pro freischalten',
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Angehörige einladen und alle\nPro Funktionen nutzen.',
            style: tt.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onUpgrade,
              child: const Text('Pro freischalten'),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Actions Card
// ══════════════════════════════════════════════════════════════════════

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.isPro,
    required this.billing,
    required this.onRestore,
    required this.onManage,
  });

  final bool isPro;
  final BillingService billing;
  final VoidCallback onRestore;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktionen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          if (isPro)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Abo verwalten'),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: onManage,
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Kauf wiederherstellen'),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: billing.restoring,
              builder: (_, restoring, _) => restoring
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded, size: 20),
            ),
            onTap: onRestore,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Pro Benefits Card (collapsible feature comparison)
// ══════════════════════════════════════════════════════════════════════

class _ProBenefitsCard extends StatelessWidget {
  const _ProBenefitsCard();

  static const _appRows = <(String, String, String)>[
    ('OP-Timeline', '✓', '✓'),
    ('Medikamenten\u00ADplan', '✓', '✓'),
    ('Schmerztagebuch', '✓', '✓'),
    ('Vitalwerte', '✓', '✓'),
    ('Termin\u00ADverwaltung', '✓', '✓'),
    ('Packlisten', '1', '∞'),
    ('Fotos', '3', '∞'),
    ('Dokumente', '5', '∞'),
    ('Sprach\u00ADnotizen', '–', '✓'),
    ('Angehörige einladen', '–', '✓'),
    ('Reha-System', '–', '✓'),
    ('Red-Flag Warnung', '–', '✓'),
    ('Arztbericht Export', '–', '✓'),
    ('Fortschritts\u00ADtracking', '–', '✓'),
    ('Werbefrei', '–', '✓'),
  ];

  static const _bellaRows = <(String, String, String)>[
    ('Bella KI-Chat', '15/Tag', '200/Tag'),
    ('Bella KI-Aktionen', '–', '✓'),
    ('Bella Gedächtnis', '–', '✓'),
    ('Bella Wund\u00ADanalyse', '–', '✓'),
    ('Bella Tages\u00ADanalyse', '–', '✓'),
    ('Bella Chat-Export', '–', '✓'),
  ];

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return GlassContainer(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 4, bottom: 8),
          leading: const Icon(Icons.star_rounded, color: AppColors.primary),
          title: Text(
            'Deine Pro Vorteile',
            style: ts.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          children: [
            // Column header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Feature',
                      style: ts.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Free',
                      textAlign: TextAlign.center,
                      style: ts.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Pro',
                      textAlign: TextAlign.center,
                      style: ts.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // App features
            for (int i = 0; i < _appRows.length; i++)
              _buildRow(ts, _appRows[i], i),
            // Bella section header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                border: Border(
                  top: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 13, color: AppColors.accent),
                  const SizedBox(width: 5),
                  Text(
                    'Bella KI',
                    style: ts.labelSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Bella features
            for (int i = 0; i < _bellaRows.length; i++)
              _buildRow(ts, _bellaRows[i], i),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(TextTheme ts, (String, String, String) row, int i) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      decoration: BoxDecoration(
        color: i.isOdd
            ? AppColors.primary.withValues(alpha: 0.04)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row.$1,
              style: ts.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.$2,
              textAlign: TextAlign.center,
              style: ts.bodySmall?.copyWith(
                color: row.$2 == '–'
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : row.$2 == '✓'
                        ? AppColors.success
                        : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.$3,
              textAlign: TextAlign.center,
              style: ts.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
