import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/questionnaire_data.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../../../l10n/app_localizations.dart';

/// Page 1 of onboarding: OP type selection only (category drill-down).
///
/// Date and mode (ambulant/stationär) live on a separate page
/// ([OpDateModusPage]) so the long operation list doesn't require
/// scrolling past them.
class OpInfoPage extends StatefulWidget {
  const OpInfoPage({
    super.key,
    required this.selectedOpType,
    required this.customOpType,
    required this.onOpTypeSelected,
    required this.onCustomOpTypeChanged,
  });

  final String? selectedOpType;
  final TextEditingController customOpType;
  final ValueChanged<String?> onOpTypeSelected;
  final ValueChanged<String> onCustomOpTypeChanged;

  @override
  State<OpInfoPage> createState() => _OpInfoPageState();
}

class _OpInfoPageState extends State<OpInfoPage> {
  int? _expandedCategoryIndex;
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  int? _categoryIndexForOpType(String? opType) {
    if (opType == null || opType == 'Sonstiges') return null;
    for (var i = 0; i < kSurgeryGroups.length; i++) {
      if (kSurgeryGroups[i].operations.contains(opType)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    _expandedCategoryIndex ??= _categoryIndexForOpType(widget.selectedOpType);

    return ListView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        _PageHeader(
          icon: AppIcons.hospital,
          iconColor: AppIcons.hospitalColor,
          title: l.erzaehlUnsVonDeinerOp,
          subtitle:
              l.dieseInformationenHelfenUnsDeinenPersoenlichenCarePla,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          'Art der Operation *',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        if (widget.selectedOpType != null) ...[
          _SelectedOpBanner(
            opType: widget.selectedOpType!,
            onClear: () {
              widget.onOpTypeSelected(null);
              setState(() => _expandedCategoryIndex = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ...List.generate(kSurgeryGroups.length, (index) {
          final group = kSurgeryGroups[index];
          final isExpanded = _expandedCategoryIndex == index;
          final hasSelectedInCategory = widget.selectedOpType != null &&
              group.operations.contains(widget.selectedOpType);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _CategorySection(
              category: group.category,
              iconCodePoint: group.icon,
              isExpanded: isExpanded,
              hasSelectedChild: hasSelectedInCategory,
              onToggle: () {
                setState(() {
                  _expandedCategoryIndex = isExpanded ? null : index;
                });
                if (!isExpanded) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (_scrollCtrl.hasClients) {
                      _scrollCtrl.animateTo(
                        _scrollCtrl.offset + 80,
                        duration: MotionDuration.medium,
                        curve: MotionCurve.standard,
                      );
                    }
                  });
                }
              },
              operations: group.operations,
              selectedOpType: widget.selectedOpType,
              onOpSelected: (op) {
                widget.onOpTypeSelected(op);
              },
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _CategorySection(
            category: 'Sonstiges',
            iconCodePoint: 0xe3c9,
            isExpanded: widget.selectedOpType == 'Sonstiges',
            hasSelectedChild: widget.selectedOpType == 'Sonstiges',
            onToggle: () {
              widget.onOpTypeSelected('Sonstiges');
            },
            operations: const [],
            selectedOpType: widget.selectedOpType,
            onOpSelected: (_) {},
          ),
        ),
        if (widget.selectedOpType == 'Sonstiges') ...[
          const SizedBox(height: AppSpacing.sm),
          GlassTextField(
            controller: widget.customOpType,
            label: l.oPTypEingeben,
            hint: 'z.B. Blinddarm-OP',
            prefixIcon: Icons.edit_outlined,
            onChanged: widget.onCustomOpTypeChanged,
          ),
        ],
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: GlassIcon(icon: icon, color: iconColor, size: 32),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SelectedOpBanner extends StatelessWidget {
  const _SelectedOpBanner({
    required this.opType,
    required this.onClear,
  });
  final String opType;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderRadius: AppRadius.borderRadiusMd,
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              opType,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded,
                color: AppColors.grey500, size: 20),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.iconCodePoint,
    required this.isExpanded,
    required this.hasSelectedChild,
    required this.onToggle,
    required this.operations,
    required this.selectedOpType,
    required this.onOpSelected,
  });

  final String category;
  final int iconCodePoint;
  final bool isExpanded;
  final bool hasSelectedChild;
  final VoidCallback onToggle;
  final List<String> operations;
  final String? selectedOpType;
  final ValueChanged<String> onOpSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MotionDuration.medium,
      curve: MotionCurve.standard,
      decoration: BoxDecoration(
        color: isExpanded || hasSelectedChild
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.white.withValues(alpha: 0.7),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: hasSelectedChild
              ? AppColors.primary.withValues(alpha: 0.4)
              : isExpanded
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.grey300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Icon(
                    IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
                    size: 24,
                    color: hasSelectedChild
                        ? AppColors.primary
                        : AppColors.grey600,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: hasSelectedChild
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (hasSelectedChild)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 20)
                  else if (operations.isNotEmpty)
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: MotionDuration.medium,
                      child: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.grey400, size: 24),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && operations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final op in operations)
                    _SelectableChip(
                      label: op,
                      selected: selectedOpType == op,
                      onTap: () => onOpSelected(op),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.grey300,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
