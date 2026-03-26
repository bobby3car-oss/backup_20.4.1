import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/ui.dart';
import '../l10n/app_localizations.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

class _VitalReading {
  const _VitalReading(this.label, this.value);
  final String label;
  final double value;
}

class _VitalType {
  const _VitalType({
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    required this.history,
    required this.normalMin,
    required this.normalMax,
    this.secondaryLabel,
    this.secondaryUnit,
    this.secondaryHistory,
  });

  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final List<_VitalReading> history;
  final double normalMin;
  final double normalMax;

  final String? secondaryLabel;
  final String? secondaryUnit;
  final List<_VitalReading>? secondaryHistory;

  double get current => history.last.value;
  double get secondaryCurrent => secondaryHistory?.last.value ?? 0;

  bool get isNormal => current >= normalMin && current <= normalMax;
}

// ─────────────────────────────────────────────────────────────────────────────

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  int _expandedIndex = -1;

  static final _vitals = <_VitalType>[
    _VitalType(
      label: 'Blutdruck',
      unit: 'mmHg',
      icon: Icons.monitor_heart_outlined,
      color: AppColors.error,
      normalMin: 90,
      normalMax: 140,
      secondaryLabel: 'Diastolisch',
      secondaryUnit: 'mmHg',
      history: const [
        _VitalReading('Mo', 128),
        _VitalReading('Di', 132),
        _VitalReading('Mi', 125),
        _VitalReading('Do', 130),
        _VitalReading('Fr', 127),
        _VitalReading('Sa', 124),
        _VitalReading('So', 126),
      ],
      secondaryHistory: const [
        _VitalReading('Mo', 82),
        _VitalReading('Di', 85),
        _VitalReading('Mi', 80),
        _VitalReading('Do', 83),
        _VitalReading('Fr', 81),
        _VitalReading('Sa', 79),
        _VitalReading('So', 80),
      ],
    ),
    _VitalType(
      label: 'Puls',
      unit: 'bpm',
      icon: Icons.favorite_outline_rounded,
      color: AppColors.primary,
      normalMin: 60,
      normalMax: 100,
      history: const [
        _VitalReading('Mo', 72),
        _VitalReading('Di', 78),
        _VitalReading('Mi', 68),
        _VitalReading('Do', 74),
        _VitalReading('Fr', 70),
        _VitalReading('Sa', 66),
        _VitalReading('So', 71),
      ],
    ),
    _VitalType(
      label: 'Temperatur',
      unit: '°C',
      icon: Icons.thermostat_outlined,
      color: AppColors.warning,
      normalMin: 36.0,
      normalMax: 37.5,
      history: const [
        _VitalReading('Mo', 36.8),
        _VitalReading('Di', 37.0),
        _VitalReading('Mi', 36.6),
        _VitalReading('Do', 36.9),
        _VitalReading('Fr', 36.7),
        _VitalReading('Sa', 36.5),
        _VitalReading('So', 36.7),
      ],
    ),
    _VitalType(
      label: 'SpO2',
      unit: '%',
      icon: Icons.air_rounded,
      color: AppColors.success,
      normalMin: 95,
      normalMax: 100,
      history: const [
        _VitalReading('Mo', 98),
        _VitalReading('Di', 97),
        _VitalReading('Mi', 99),
        _VitalReading('Do', 98),
        _VitalReading('Fr', 97),
        _VitalReading('Sa', 98),
        _VitalReading('So', 99),
      ],
    ),
    _VitalType(
      label: 'Gewicht',
      unit: 'kg',
      icon: Icons.monitor_weight_outlined,
      color: AppColors.accent,
      normalMin: 60,
      normalMax: 100,
      history: const [
        _VitalReading('Mo', 78.2),
        _VitalReading('Di', 78.0),
        _VitalReading('Mi', 77.8),
        _VitalReading('Do', 77.9),
        _VitalReading('Fr', 77.6),
        _VitalReading('Sa', 77.5),
        _VitalReading('So', 77.4),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: topPadding + AppSpacing.sm,
          bottom: AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildSummaryRow(context),
            const SizedBox(height: AppSpacing.xxl),
            for (var i = 0; i < _vitals.length; i++) ...[
              _VitalCard(
                vital: _vitals[i],
                expanded: _expandedIndex == i,
                onTap: () => setState(() {
                  _expandedIndex = _expandedIndex == i ? -1 : i;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.lg),
            _buildAddButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Vitalwerte',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        GestureDetector(
          onTap: () {
            final l = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.exportPreparing)),
            );
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
            child: const Icon(
              Icons.ios_share_rounded,
              size: 18,
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final v in _vitals) ...[
            _SummaryPill(vital: v),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GlassButton(
      onPressed: () => _showInputSheet(context),
      label: 'Neue Messung eintragen',
      icon: Icons.add_rounded,
      expand: true,
    );
  }

  void _showInputSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InputSheet(),
    );
  }
}

// ── Summary pill ─────────────────────────────────────────────────────────────

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.vital});

  final _VitalType vital;

  @override
  Widget build(BuildContext context) {
    final valueText = vital.label == 'Blutdruck'
        ? '${vital.current.round()}/${vital.secondaryCurrent.round()}'
        : vital.unit == '°C'
        ? vital.current.toStringAsFixed(1)
        : vital.unit == 'kg'
        ? vital.current.toStringAsFixed(1)
        : '${vital.current.round()}';

    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderRadius: AppRadius.borderRadiusPill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: vital.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(vital.icon, size: 14, color: vital.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: vital.isNormal
                      ? AppColors.textPrimary
                      : AppColors.error,
                ),
              ),
              Text(
                vital.unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Vital card with expandable chart ─────────────────────────────────────────

class _VitalCard extends StatelessWidget {
  const _VitalCard({
    required this.vital,
    required this.expanded,
    required this.onTap,
  });

  final _VitalType vital;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final valueText = vital.label == 'Blutdruck'
        ? '${vital.current.round()}/${vital.secondaryCurrent.round()}'
        : vital.unit == '°C' || vital.unit == 'kg'
        ? vital.current.toStringAsFixed(1)
        : '${vital.current.round()}';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.borderRadiusXl,
          child: Column(
            children: [
              // ── Header row ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: vital.color.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                    child: Icon(vital.icon, size: 24, color: vital.color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vital.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Normalbereich: ${vital.normalMin.round()}–${vital.normalMax.round()} ${vital.unit}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        valueText,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: vital.isNormal
                              ? AppColors.textPrimary
                              : AppColors.error,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        vital.unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),

              // ── Expanded chart ──────────────────────────────
              if (expanded) ...[
                const SizedBox(height: AppSpacing.xl),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.grey200.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 140,
                  child: _TrendChart(
                    readings: vital.history,
                    color: vital.color,
                    normalMin: vital.normalMin,
                    normalMax: vital.normalMax,
                    unit: vital.unit,
                  ),
                ),
                if (vital.secondaryHistory != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 100,
                    child: _TrendChart(
                      readings: vital.secondaryHistory!,
                      color: vital.color.withValues(alpha: 0.55),
                      normalMin: 60,
                      normalMax: 90,
                      unit: vital.secondaryUnit ?? vital.unit,
                      label: vital.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trend chart (custom painted) ─────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.readings,
    required this.color,
    required this.normalMin,
    required this.normalMax,
    required this.unit,
    this.label,
  });

  final List<_VitalReading> readings;
  final Color color;
  final double normalMin;
  final double normalMax;
  final String unit;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ChartPainter(
              readings: readings,
              lineColor: color,
              normalMin: normalMin,
              normalMax: normalMax,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final r in readings)
              Text(
                r.label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.readings,
    required this.lineColor,
    required this.normalMin,
    required this.normalMax,
  });

  final List<_VitalReading> readings;
  final Color lineColor;
  final double normalMin;
  final double normalMax;

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final values = readings.map((r) => r.value).toList();
    final dataMin = values.reduce(math.min);
    final dataMax = values.reduce(math.max);
    final rangeMin = math.min(dataMin, normalMin) - 2;
    final rangeMax = math.max(dataMax, normalMax) + 2;
    final range = rangeMax - rangeMin;

    double yFor(double v) =>
        size.height - ((v - rangeMin) / range) * size.height;

    // ── Normal zone ──────────────────────────────────────────
    final zonePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(0, yFor(normalMax), size.width, yFor(normalMin)),
      zonePaint,
    );

    // ── Grid lines ───────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0x0F000000)
      ..strokeWidth = 0.5;

    for (var i = 0; i < 3; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Area fill ────────────────────────────────────────────
    final areaPath = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = yFor(values[i]);
      if (i == 0) {
        areaPath.moveTo(x, y);
      } else {
        final prevX = size.width * (i - 1) / (values.length - 1);
        final prevY = yFor(values[i - 1]);
        final cx = (prevX + x) / 2;
        areaPath.cubicTo(cx, prevY, cx, y, x, y);
      }
    }
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.18),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);

    // ── Line ─────────────────────────────────────────────────
    final linePath = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = yFor(values[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = size.width * (i - 1) / (values.length - 1);
        final prevY = yFor(values[i - 1]);
        final cx = (prevX + x) / 2;
        linePath.cubicTo(cx, prevY, cx, y, x, y);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // ── Dots ─────────────────────────────────────────────────
    final dotFill = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    final dotStroke = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = yFor(values[i]);
      canvas.drawCircle(Offset(x, y), 4, dotFill);
      canvas.drawCircle(Offset(x, y), 4, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      readings != old.readings || lineColor != old.lineColor;
}

// ── Input sheet ──────────────────────────────────────────────────────────────

class _InputSheet extends StatelessWidget {
  const _InputSheet();

  static const _fields = [
    _InputField(
      'Systolisch',
      'mmHg',
      Icons.monitor_heart_outlined,
      AppColors.error,
    ),
    _InputField(
      'Diastolisch',
      'mmHg',
      Icons.monitor_heart_outlined,
      AppColors.error,
    ),
    _InputField(
      'Puls',
      'bpm',
      Icons.favorite_outline_rounded,
      AppColors.primary,
    ),
    _InputField(
      'Temperatur',
      '°C',
      Icons.thermostat_outlined,
      AppColors.warning,
    ),
    _InputField('SpO2', '%', Icons.air_rounded, AppColors.success),
    _InputField(
      'Gewicht',
      'kg',
      Icons.monitor_weight_outlined,
      AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──────────────────────────────────────
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Neue Messung',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Trage deine aktuellen Vitalwerte ein.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxl),

            for (final f in _fields) ...[
              _NumericInput(field: f),
              const SizedBox(height: AppSpacing.md),
            ],

            const SizedBox(height: AppSpacing.lg),
            GlassButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Messung gespeichert'),
                  ),
                );
              },
              label: l.save,
              icon: Icons.check_rounded,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _InputField {
  const _InputField(this.label, this.unit, this.icon, this.color);
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
}

class _NumericInput extends StatelessWidget {
  const _NumericInput({required this.field});

  final _InputField field;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppRadius.borderRadiusMd,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: field.color.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(field.icon, size: 16, color: field.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: field.label,
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey400,
                ),
              ),
            ),
          ),
          Text(
            field.unit,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
