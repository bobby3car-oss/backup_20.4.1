import 'package:flutter/material.dart';

import '../../../../features/pain/domain/pain_entry.dart';
import '../../../../ui/ui.dart';
import '../../data/doctor_patient_repository.dart';

/// Read-only pain diary view for a linked patient.
class PatientPainTab extends StatefulWidget {
  const PatientPainTab({super.key, required this.patientId});

  final String patientId;

  @override
  State<PatientPainTab> createState() => _PatientPainTabState();
}

class _PatientPainTabState extends State<PatientPainTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = DoctorPatientRepository();

  @override
  bool get wantKeepAlive => true;

  String _formatDate(DateTime dt) =>
      '${dt.day}.${dt.month}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<PainEntry>>(
      stream: _repo.watchPatientPain(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.show_chart_rounded,
                    size: 48, color: AppColors.grey400),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Kein Schmerztagebuch vorhanden',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Simple pain chart ────────────────────────────────
            if (entries.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: _SimplePainChart(
                  entries: entries.reversed.toList(growable: false),
                ),
              ),

            // ── Entries list ─────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: AppSpacing.screenPadding,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return GlassCard(
                    child: Row(
                      children: [
                        _PainIndicator(level: entry.painLevel),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(entry.occurredAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: AppColors.textSecondary),
                              ),
                              if (entry.location != null)
                                Text(
                                  entry.location!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              if (entry.note.isNotEmpty)
                                Text(
                                  entry.note,
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '${entry.painLevel}/10',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _painColor(entry.painLevel),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Color _painColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }
}

class _PainIndicator extends StatelessWidget {
  const _PainIndicator({required this.level});

  final int level;

  Color get _color {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: AppRadius.borderRadiusPill,
      ),
    );
  }
}

/// A simple custom-painted line chart of pain levels over time.
class _SimplePainChart extends StatelessWidget {
  const _SimplePainChart({required this.entries});

  final List<PainEntry> entries;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schmerzverlauf',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: Size.infinite,
              painter: _PainChartPainter(entries),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _shortDate(entries.first.occurredAt),
                style: TextStyle(fontSize: 10, color: AppColors.grey600),
              ),
              Text(
                _shortDate(entries.last.occurredAt),
                style: TextStyle(fontSize: 10, color: AppColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortDate(DateTime dt) =>
      '${dt.day}.${dt.month}';
}

class _PainChartPainter extends CustomPainter {
  _PainChartPainter(this.entries);

  final List<PainEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final xStep = size.width / (entries.length - 1);

    for (int i = 0; i < entries.length; i++) {
      final x = i * xStep;
      final y = size.height - (entries[i].painLevel / 10.0) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
