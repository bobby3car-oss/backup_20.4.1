import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'package:operationsbegleiter_v3/ui/components/glass_icon.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_icons.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class HeroBannerData {
  const HeroBannerData({
    required this.dayLabel,
    required this.encouragementText,
    required this.doneCount,
    required this.totalCount,
    this.opType,
    this.opModus,
    this.opDateFormatted,
    this.currentStreak = 0,
    this.todayXp = 0,
    this.level = 1,
    this.levelProgress = 0.0,
    this.streakMultiplier = 1.0,
    this.recentDaysActive = const [],
    this.isPro = false,
  });

  final String dayLabel;
  final String encouragementText;
  final int doneCount;
  final int totalCount;

  /// e.g. "Allgemeine OP", "Knie-OP"
  final String? opType;

  /// e.g. "Stationär", "Ambulant"
  final String? opModus;

  /// Formatted OP date, e.g. "14.02.26"
  final String? opDateFormatted;

  final int currentStreak;
  final int todayXp;
  final int level;
  final double levelProgress;
  final double streakMultiplier;

  /// Which of the last 7 days (index 0 = 6 days ago, 6 = today) had activity.
  final List<bool> recentDaysActive;

  final bool isPro;

  double get progress => totalCount == 0 ? 0.0 : doneCount / totalCount;
  int get progressPercent => (progress * 100).round();
}

// ── Widget ───────────────────────────────────────────────────────────────────

class TimelineHeroBanner extends StatelessWidget {
  const TimelineHeroBanner({
    super.key,
    required this.data,
    this.onTap,
    this.onActionsPressed,
  });

  final HeroBannerData data;
  final VoidCallback? onTap;
  final VoidCallback? onActionsPressed;

  static const _borderRadius = BorderRadius.all(Radius.circular(20));

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0055D4), Color(0xFF007AFF), Color(0xFF5AC8FA)],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          gradient: _gradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: CustomPaint(
            painter: _HighlightPainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
              child: Row(
                children: [
                  // ── Left: text content ─────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _topInfoRow(context),
                        const SizedBox(height: 8),
                        Text(
                          data.dayLabel,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: -0.4,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.encouragementText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xB3FFFFFF),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ── Right: circular progress ring ──────────
                  _progressRing(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top info row: OP type + modus | OP date ────────────────────────────────

  Widget _topInfoRow(BuildContext context) {
    final hasOpInfo = (data.opType != null && data.opType!.isNotEmpty) ||
        (data.opModus != null && data.opModus!.isNotEmpty);

    return Row(
      children: [
        if (hasOpInfo)
          Expanded(
            child: Text(
              [
                if (data.opType != null && data.opType!.isNotEmpty) data.opType!,
                if (data.opModus != null && data.opModus!.isNotEmpty)
                  data.opModus!,
              ].join(' • '),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xCCFFFFFF),
                letterSpacing: 0.1,
              ),
            ),
          ),
        if (!hasOpInfo) const Spacer(),
        if (data.opDateFormatted != null) ...[
          GlassIcon(icon: AppIcons.appointments, color: AppIcons.appointmentsColor, size: 14),
          const SizedBox(width: 4),
          Text(
            data.opDateFormatted!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xCCFFFFFF),
            ),
          ),
        ],
      ],
    );
  }

  // ── Title block: "Tag X nach/vor OP" + encouragement ──────────────────────

  // (Inlined into build method above)

  // ── Circular progress ring ─────────────────────────────────────────────────

  Widget _progressRing() {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: data.progress,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xF2FFFFFF),
              ),
            ),
          ),
          Text(
            '${data.progressPercent}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xEEFFFFFF),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress section (removed — replaced by ring) ──────────────────────────
}

// ── Highlight painter ────────────────────────────────────────────────────────

class _HighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Top-left radial glow
    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.9),
        radius: 0.8,
        colors: [
          AppColors.white.withValues(alpha: 0.12),
          AppColors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, topGlow);

    // Bottom-right warm glow
    final bottomGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 1.0),
        radius: 0.7,
        colors: [
          AppColors.white.withValues(alpha: 0.05),
          AppColors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bottomGlow);

    // Top edge highlight line
    final topLine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.white.withValues(alpha: 0.0),
          AppColors.white.withValues(alpha: 0.25),
          AppColors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.05, 0.5, 0.95],
      ).createShader(Offset.zero & Size(size.width, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(const Offset(0, 0.5), Offset(size.width, 0.5), topLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
