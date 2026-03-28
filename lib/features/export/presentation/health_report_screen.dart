import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/pro_feature_gate_view.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/health_report_pdf_builder.dart';
import '../domain/health_report_builder.dart';
import '../domain/health_report_data.dart';
import '../../../l10n/app_localizations.dart';

class HealthReportScreen extends StatefulWidget {
  const HealthReportScreen({super.key});

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  ReportRange _range = ReportRange.days14;
  DateTimeRange? _customRange;
  bool _isGenerating = false;

  final _sections = <ReportSection, bool>{
    ReportSection.pain: true,
    ReportSection.vitals: true,
    ReportSection.wounds: true,
    ReportSection.medication: true,
    ReportSection.nutrition: true,
    ReportSection.redFlags: true,
  };

  DateTimeRange get _effectiveRange {
    if (_range == ReportRange.custom && _customRange != null) {
      return _customRange!;
    }
    final now = DateTime.now();
    final days = switch (_range) {
      ReportRange.days7 => 7,
      ReportRange.days14 => 14,
      ReportRange.days30 => 30,
      ReportRange.custom => 14,
    };
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day - days),
      end: now,
    );
  }

  Set<ReportSection> get _activeSections => _sections.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toSet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isPro =
        ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

    if (!isPro) {
      return ProFeatureGateView(
        pageTitle: 'Gesundheitsbericht',
        pageIcon: Icons.picture_as_pdf_rounded,
        pageColor: AppColors.error,
        heroIcon: Icons.picture_as_pdf_rounded,
        heroTitle: 'Dein persönlicher\nGesundheitsbericht',
        heroSubtitle:
            'Fasse alle gesammelten Gesundheitsdaten als übersichtliches PDF '
            'zusammen und teile den Bericht mit deinem Arzt.',
        primaryCta: l.proUnlock,
        onPrimaryTap: () => SmartPaywall.trigger(
          context: context,
          triggerContext: TriggerContext.healthReportExport,
        ),
        benefits: [
          (
            'PDF-Export',
            'Alle Daten als professionellen Bericht exportieren.'
          ),
          (
            l.zeitraumWaehlbar,
            l.berichtFuer714Oder30TageErstellen
          ),
          (
            l.sektionenWaehlen,
            l.nurDieRelevantenDatenEinschliessen
          ),
          (
            'Arzt-tauglich',
            l.uebersichtlichesLayoutZumAusdrucken
          ),
        ],
      );
    }

    return GlassPage(
      title: 'Gesundheitsbericht',
      titleIcon: Icons.picture_as_pdf_rounded,
      titleColor: AppColors.error,
      children: [
        // ── Time range ─────────────────────────────────────────
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zeitraum',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ReportRange.values.map((r) {
                  final selected = r == _range;
                  return ChoiceChip(
                    label: Text(_rangeLabel(r)),
                    selected: selected,
                    onSelected: (_) async {
                      if (r == ReportRange.custom) {
                        await _pickCustomRange();
                      } else {
                        setState(() => _range = r);
                      }
                    },
                    selectedColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppColors.primary
                          : AppColors.grey600,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.grey300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    backgroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  );
                }).toList(),
              ),
              if (_range == ReportRange.custom && _customRange != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${DateFormat('dd.MM.yyyy').format(_customRange!.start)} – '
                  '${DateFormat('dd.MM.yyyy').format(_customRange!.end)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Sections ───────────────────────────────────────────
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enthaltene Sektionen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final section in ReportSection.values)
                _SectionToggle(
                  section: section,
                  enabled: _sections[section]!,
                  onChanged: (v) =>
                      setState(() => _sections[section] = v),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Generate button ────────────────────────────────────
        GlassButton(
          onPressed: _isGenerating ? null : _generateAndShare,
          label: _isGenerating
              ? 'Wird erstellt …'
              : 'PDF erstellen & teilen',
          icon: _isGenerating
              ? CupertinoIcons.hourglass
              : Icons.picture_as_pdf_rounded,
          variant: GlassButtonVariant.primary,
        ),
        const SizedBox(height: AppSpacing.massive),
      ],
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 14)),
            end: now,
          ),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _range = ReportRange.custom;
        _customRange = picked;
      });
    }
  }

  Future<void> _generateAndShare() async {
    final l = AppLocalizations.of(context)!;
    if (_activeSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.selectMinOneSection)),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final range = _effectiveRange;
      final data = await HealthReportBuilder.build(
        from: range.start,
        to: range.end,
        sections: _activeSections,
      );

      final bytes = await HealthReportPdfBuilder.build(data);
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Gesundheitsbericht_$date.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.fehlerMitError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _rangeLabel(ReportRange r) {
    return switch (r) {
      ReportRange.days7 => '7 Tage',
      ReportRange.days14 => '14 Tage',
      ReportRange.days30 => '30 Tage',
      ReportRange.custom => 'Eigener Zeitraum',
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _SectionToggle
// ═══════════════════════════════════════════════════════════════════════════

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({
    required this.section,
    required this.enabled,
    required this.onChanged,
  });

  final ReportSection section;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            _icon,
            size: 20,
            color: enabled ? _color : AppColors.grey400,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeTrackColor: AppColors.primary,
            onChanged: (v) => onChanged(v),
          ),
        ],
      ),
    );
  }

  String get _label => switch (section) {
        ReportSection.pain => 'Schmerzverlauf',
        ReportSection.vitals => 'Vitalwerte',
        ReportSection.wounds => 'Wunddokumentation',
        ReportSection.medication => 'Medikamente',
        ReportSection.nutrition => 'Ernährung',
        ReportSection.redFlags => 'Red Flags',
      };

  IconData get _icon => switch (section) {
        ReportSection.pain => AppIcons.pain,
        ReportSection.vitals => AppIcons.vitals,
        ReportSection.wounds => AppIcons.wound,
        ReportSection.medication => AppIcons.medication,
        ReportSection.nutrition => AppIcons.nutrition,
        ReportSection.redFlags => AppIcons.redFlags,
      };

  Color get _color => switch (section) {
        ReportSection.pain => AppIcons.painColor,
        ReportSection.vitals => AppIcons.vitalsColor,
        ReportSection.wounds => AppIcons.woundColor,
        ReportSection.medication => AppIcons.medicationColor,
        ReportSection.nutrition => AppIcons.nutritionColor,
        ReportSection.redFlags => AppIcons.redFlagsColor,
      };
}
