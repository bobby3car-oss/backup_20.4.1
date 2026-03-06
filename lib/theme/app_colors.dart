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

// ── Per-TaskType gradient colors ──────────────────────────────────────────────

class TaskTypeColors {
  const TaskTypeColors({
    required this.start,
    required this.end,
    required this.bg,
  });

  final Color start;
  final Color end;
  final Color bg;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [start, end],
  );
}

abstract final class TaskTypeGradients {
  static const wound = TaskTypeColors(
    start: Color(0xFFFF6B6B),
    end: Color(0xFFFF9A9A),
    bg: Color(0x18FF6B6B),
  );

  static const meds = TaskTypeColors(
    start: Color(0xFF7C3AED),
    end: Color(0xFFA78BFA),
    bg: Color(0x187C3AED),
  );

  static const checklist = TaskTypeColors(
    start: Color(0xFF059669),
    end: Color(0xFF34D399),
    bg: Color(0x18059669),
  );

  static const appointment = TaskTypeColors(
    start: Color(0xFF1D4ED8),
    end: Color(0xFF60A5FA),
    bg: Color(0x181D4ED8),
  );

  static const message = TaskTypeColors(
    start: Color(0xFFD97706),
    end: Color(0xFFFBBF24),
    bg: Color(0x18D97706),
  );

  static const custom = TaskTypeColors(
    start: Color(0xFF475569),
    end: Color(0xFF94A3B8),
    bg: Color(0x18475569),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

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
