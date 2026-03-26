import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../domain/packing_item.dart';
import '../domain/packing_list.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../../../l10n/app_localizations.dart';

/// Result from the template sheet.
class PackingTemplateResult {
  const PackingTemplateResult({
    required this.title,
    required this.type,
    this.mode,
    this.icon,
  });

  final String title;
  final PackingListType type;
  final HospitalMode? mode;
  final String? icon;
}

/// Bottom sheet for choosing a packing‑list template or creating a custom list.
class PackingTemplateSheet extends StatelessWidget {
  const PackingTemplateSheet({super.key});

  bool _isPro(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    return pro?.entitlementService.isPro ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _isPro(context);

    // Templates: first two free, rest Pro.
    final templates = <_TemplateOption>[
      _TemplateOption(
        type: PackingListType.ambulant,
        mode: HospitalMode.ambulant,
        requiresPro: false,
      ),
      _TemplateOption(
        type: PackingListType.stationary,
        mode: HospitalMode.stationary,
        requiresPro: false,
      ),
      _TemplateOption(
        type: PackingListType.child,
        mode: null,
        requiresPro: true,
      ),
      _TemplateOption(
        type: PackingListType.rehab,
        mode: null,
        requiresPro: true,
      ),
      _TemplateOption(
        type: PackingListType.custom,
        mode: null,
        requiresPro: true,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Neue Packliste',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Wähle eine Vorlage oder erstelle eine eigene Liste',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Template options
              for (var i = 0; i < templates.length; i++) ...[
                _TemplateCard(
                  option: templates[i],
                  isPro: isPro,
                  onTap: () => _selectTemplate(context, templates[i], isPro),
                ),
                if (i < templates.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTemplate(
    BuildContext context,
    _TemplateOption option,
    bool isPro,
  ) async {
    if (option.requiresPro && !isPro) {
      await SmartPaywall.trigger(
        context: context,
        triggerContext: TriggerContext.packingTemplateLimit,
      );
      return;
    }

    if (option.type == PackingListType.custom) {
      // Show name input for custom list.
      if (!context.mounted) return;
      final name = await _showNameDialog(context);
      if (name == null || name.isEmpty) return;
      if (!context.mounted) return;
      Navigator.of(context).pop(
        PackingTemplateResult(
          title: name,
          type: PackingListType.custom,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      PackingTemplateResult(
        title: option.type.label,
        type: option.type,
        mode: option.mode,
        icon: option.type.emoji,
      ),
    );
  }

  Future<String?> _showNameDialog(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.packingListName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'z.B. Reha Bad Nauheim',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.of(ctx).pop(text);
            },
            child: Text(l.create),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Template option model ───────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _TemplateOption {
  const _TemplateOption({
    required this.type,
    required this.mode,
    required this.requiresPro,
  });

  final PackingListType type;
  final HospitalMode? mode;
  final bool requiresPro;
}

// ─────────────────────────────────────────────────────────────────
// ── Template card ───────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.option,
    required this.isPro,
    required this.onTap,
  });

  final _TemplateOption option;
  final bool isPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = option.requiresPro && !isPro;

    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusMd,
        elevation: GlassElevation.low,
        variant: GlassVariant.thin,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: locked
                    ? AppColors.grey200.withValues(alpha: 0.5)
                    : AppColors.primary.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Center(
                child: GlassIcon(
                  icon: option.type.icon,
                  color: locked ? AppColors.grey400 : option.type.iconColor,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.type.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: locked
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.type.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (locked) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5856D6), Color(0xFF007AFF)],
                  ),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
