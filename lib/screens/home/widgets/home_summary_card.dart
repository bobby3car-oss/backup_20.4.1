import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../home_view_model.dart';

import '../../../l10n/app_localizations.dart';

/// Compact summary card at the top of the home screen.
/// Shows OP day label, progress ring, and key stats at a glance.
class HomeSummaryCard extends StatelessWidget {
  const HomeSummaryCard({
    super.key,
    required this.dayLabel,
    required this.encouragement,
    required this.summary,
    required this.hasOpDate,
    required this.onTap,
  });

  final String dayLabel;
  final String encouragement;
  final TimelineHeaderSummary summary;
  final bool hasOpDate;
  final VoidCallback onTap;

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0055D4), Color(0xFF007AFF), Color(0xFF5AC8FA)],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final percent = (summary.progress * 100).round();

    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.98,
      child: Container(
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _SubtleDotsPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
            child: Row(
              children: [
                // ── Left: text content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        encouragement,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xB3FFFFFF),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      // Stats row
                      Row(
                        children: [
                          _StatChip(
                            label: '${summary.doneCount}/${summary.totalCount}',
                            subtitle: 'erledigt',
                          ),
                          const SizedBox(width: 12),
                          if (summary.dueCount > 0)
                            _StatChip(
                              label: '${summary.dueCount}',
                              subtitle: l.homeSummaryCardFaellig,
                              isUrgent: true,
                            ),
                          if (summary.dueCount > 0)
                            const SizedBox(width: 12),
                          if (summary.todayCount > 0)
                            _StatChip(
                              label: '${summary.todayCount}',
                              subtitle: 'heute',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // ── Right: progress ring ──
                if (hasOpDate)
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: CircularProgressIndicator(
                            value: summary.progress.clamp(0.0, 1.0),
                            strokeWidth: 5.5,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.18),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Gesamt',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0x99FFFFFF),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.subtitle,
    this.isUrgent = false,
  });

  final String label;
  final String subtitle;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isUrgent
                  ? const Color(0xFFFFD60A)
                  : Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0x99FFFFFF),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtleDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Decorative circles in top-right area
    canvas.drawCircle(
      Offset(size.width - 30, -10),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width + 10, 50),
      40,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
