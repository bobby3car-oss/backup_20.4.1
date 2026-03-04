import 'package:flutter/material.dart';

class TimelineStatusColors {
  const TimelineStatusColors({
    required this.bg,
    required this.fg,
    required this.border,
  });

  final Color bg;
  final Color fg;
  final Color border;
}

class TimelineAppColors {
  const TimelineAppColors._();

  // Neutral surfaces
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF1F3F8);

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);

  // Status colors
  static const TimelineStatusColors planned = TimelineStatusColors(
    bg: Color(0xFFF3F4F6),
    fg: Color(0xFF475569),
    border: Color(0x1F475569),
  );

  static const TimelineStatusColors inProgress = TimelineStatusColors(
    bg: Color(0x141D4ED8),
    fg: Color(0xFF1D4ED8),
    border: Color(0x2E1D4ED8),
  );

  static const TimelineStatusColors due = TimelineStatusColors(
    bg: Color(0x14DC2626),
    fg: Color(0xFFB91C1C),
    border: Color(0x30B91C1C),
  );

  static const TimelineStatusColors done = TimelineStatusColors(
    bg: Color(0x1416A34A),
    fg: Color(0xFF15803D),
    border: Color(0x2D15803D),
  );

  static const TimelineStatusColors skipped = TimelineStatusColors(
    bg: Color(0x14B45309),
    fg: Color(0xFF92400E),
    border: Color(0x2E92400E),
  );
}
