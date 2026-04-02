import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../pro/domain/org_entitlement.dart';
import '../../pro/presentation/org_paywall_screen.dart';
import '../data/invoice_repository.dart';
import '../domain/org_invoice.dart';

/// Billing section widget for the OrgProfileTab.
///
/// Shows subscription status, plan info, recent invoices, and a button
/// to manage the subscription via [OrgPaywallScreen].
class OrgBillingSection extends StatelessWidget {
  const OrgBillingSection({super.key, required this.orgUid});

  final String orgUid;

  @override
  Widget build(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    final orgEnt = pro?.orgEntitlementService;

    if (orgEnt == null) return const SizedBox.shrink();

    return ValueListenableBuilder<OrgEntitlement>(
      valueListenable: orgEnt.entitlement,
      builder: (context, ent, _) {
        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.borderRadiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: AppSpacing.lg),
              _statusChip(context, ent),
              const SizedBox(height: AppSpacing.md),
              _planDetails(context, ent),
              const SizedBox(height: AppSpacing.xl),
              _invoiceList(context),
              const SizedBox(height: AppSpacing.xl),
              _manageButton(context),
            ],
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.receipt_long_rounded,
            color: AppColors.accent, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Abrechnung',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Status chip ──────────────────────────────────────────────────────────

  Widget _statusChip(BuildContext context, OrgEntitlement ent) {
    final (label, color) = _statusInfo(ent);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderRadiusPill,
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ent.isActive
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (String, Color) _statusInfo(OrgEntitlement ent) {
    if (ent.isActive) {
      if (ent.proSource == 'trial') {
        return ('Trial', const Color(0xFFFF9500));
      }
      return ('Aktiv', AppColors.success);
    }
    return ('Inaktiv', AppColors.textSecondary);
  }

  // ── Plan details ─────────────────────────────────────────────────────────

  Widget _planDetails(BuildContext context, OrgEntitlement ent) {
    final theme = Theme.of(context);
    if (!ent.isActive) {
      return Text(
        'Kein aktives Abo',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: [
        _detailRow(
          context,
          icon: Icons.label_outline_rounded,
          label: 'Plan',
          value: _planName(ent),
        ),
        if (ent.proExpiresAt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _detailRow(
            context,
            icon: Icons.event_rounded,
            label: 'Nächste Abrechnung',
            value: _formatDate(ent.proExpiresAt!),
          ),
        ],
        if (ent.proProductId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _detailRow(
            context,
            icon: Icons.info_outline_rounded,
            label: 'Quelle',
            value: _sourceName(ent),
          ),
        ],
      ],
    );
  }

  String _planName(OrgEntitlement ent) {
    if (ent.proProductId != null) {
      final id = ent.proProductId!;
      if (id.contains('monthly')) return 'Pro Monatlich';
      if (id.contains('yearly') || id.contains('annual')) {
        return 'Pro Jährlich';
      }
      return 'Pro';
    }
    if (ent.proSource == 'key') return 'Pro (Key)';
    return 'Pro';
  }

  String _sourceName(OrgEntitlement ent) {
    if (ent.proSource == 'key') return 'Pro-Key';
    if (ent.proPlatform == 'ios') return 'App Store';
    if (ent.proPlatform == 'android') return 'Google Play';
    return ent.proPlatform ?? 'Abo';
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Invoice list ─────────────────────────────────────────────────────────

  Widget _invoiceList(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Divider(
            color: AppColors.textSecondary.withValues(alpha: 0.12),
            height: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Letzte Rechnungen',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        StreamBuilder<List<OrgInvoice>>(
          stream: InvoiceRepository(orgUid: orgUid).watchInvoices(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final invoices = snap.data ?? [];
            if (invoices.isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'Keine Rechnungen vorhanden',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return Column(
              children: invoices.map((inv) => _invoiceTile(context, inv)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _invoiceTile(BuildContext context, OrgInvoice invoice) {
    final theme = Theme.of(context);
    final statusColor = invoice.status == 'paid'
        ? AppColors.success
        : invoice.status == 'cancelled'
            ? AppColors.error
            : const Color(0xFFFF9500);
    final statusLabel = invoice.status == 'paid'
        ? 'Bezahlt'
        : invoice.status == 'cancelled'
            ? 'Storniert'
            : 'Offen';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(Icons.description_outlined,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(invoice.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${invoice.amount.toStringAsFixed(2)} ${invoice.currency}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Manage button ────────────────────────────────────────────────────────

  Widget _manageButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassButton(
        onPressed: () {
          final p = ProServices.of(context);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrgPaywallScreen(
                billingService: p.billingService,
                orgEntitlementService: p.orgEntitlementService,
              ),
            ),
          );
        },
        icon: Icons.settings_rounded,
        label: 'Abo verwalten',
        variant: GlassButtonVariant.primary,
        expand: true,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _formatDate(DateTime date) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }
}
