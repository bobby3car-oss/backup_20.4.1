import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../ui/ui.dart';
import '../../domain/questionnaire_data.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../../../l10n/app_localizations.dart';

/// Page 1 of onboarding: OP type (via category drill-down), date, and mode.
class OpInfoPage extends StatefulWidget {
  const OpInfoPage({
    super.key,
    required this.selectedOpType,
    required this.customOpType,
    required this.opDate,
    required this.opDateUnknown,
    required this.opModus,
    required this.onOpTypeSelected,
    required this.onCustomOpTypeChanged,
    required this.onPickDate,
    required this.onDateUnknownChanged,
    required this.onModusChanged,
  });

  final String? selectedOpType;
  final TextEditingController customOpType;
  final DateTime? opDate;
  final bool opDateUnknown;
  final String? opModus;
  final ValueChanged<String?> onOpTypeSelected;
  final ValueChanged<String> onCustomOpTypeChanged;
  final VoidCallback onPickDate;
  final ValueChanged<bool> onDateUnknownChanged;
  final ValueChanged<String> onModusChanged;

  @override
  State<OpInfoPage> createState() => _OpInfoPageState();
}

class _OpInfoPageState extends State<OpInfoPage> {
  /// Currently expanded category index, or -1 for "Sonstiges".
  int? _expandedCategoryIndex;

  /// Scroll controller for the operation list.
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Finds the category index that contains the selected op type.
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

    // If user selected an op but hasn't expanded the category, auto-expand it.
    _expandedCategoryIndex ??= _categoryIndexForOpType(widget.selectedOpType);

    return ListView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Hero ──
        _PageHeader(
          icon: AppIcons.hospital,
          iconColor: AppIcons.hospitalColor,
          title: l.erzaehlUnsVonDeinerOp,
          subtitle:
              l.dieseInformationenHelfenUnsDeinenPersoenlichenCarePla,
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // ── OP-Typ (category drill-down) ──
        Text(
          'Art der Operation *',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),

        // Show selected op as a chip if one is chosen
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

        // Category cards
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
                // Scroll to show expanded content
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

        // "Sonstiges" option
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _CategorySection(
            category: 'Sonstiges',
            iconCodePoint: 0xe3c9, // more_horiz
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
        const SizedBox(height: AppSpacing.xxl),

        // ── OP-Datum ──
        Text(l.opDate, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: widget.opDateUnknown ? null : widget.onPickDate,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            borderRadius: AppRadius.borderRadiusMd,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: widget.opDateUnknown
                      ? AppColors.grey400
                      : widget.opDate != null
                          ? AppColors.primary
                          : AppColors.grey500,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.opDateUnknown
                        ? 'Datum noch unbekannt'
                        : widget.opDate != null
                            ? DateFormat('dd. MMMM yyyy', 'de')
                                .format(widget.opDate!)
                            : l.datumAuswaehlen,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.opDateUnknown
                          ? AppColors.grey400
                          : widget.opDate != null
                              ? AppColors.textPrimary
                              : AppColors.grey500,
                    ),
                  ),
                ),
                if (!widget.opDateUnknown)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: widget.opDateUnknown,
                onChanged: (v) => widget.onDateUnknownChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => widget.onDateUnknownChanged(!widget.opDateUnknown),
              child: Text(
                'Datum noch unbekannt',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── OP-Modus ──
        Text(l.treatmentType, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModusCard(
                icon: Icons.wb_sunny_outlined,
                label: 'Ambulant',
                subtitle: l.gleichtaegigeEntlassung,
                selected: widget.opModus == 'ambulant',
                onTap: () => widget.onModusChanged('ambulant'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModusCard(
                icon: Icons.hotel_outlined,
                label: 'Stationär',
                subtitle: l.mitKrankenhausaufenthalt,
                selected: widget.opModus == l.stationaer2,
                onTap: () => widget.onModusChanged(l.stationaer2),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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

/// Banner showing the currently selected OP with a clear button.
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

/// Expandable category section that shows operations when tapped.
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
          // Category header
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
          // Expanded operation list
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

class _ModusCard extends StatelessWidget {
  const _ModusCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.grey300,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? AppColors.white : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
