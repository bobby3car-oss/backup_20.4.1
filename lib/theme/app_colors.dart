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
    start: Color(0xFFEF4444),
    end: Color(0xFFFF7B7B),
    bg: Color(0x28EF4444),
  );

  static const meds = TaskTypeColors(
    start: Color(0xFF6D28D9),
    end: Color(0xFF8B5CF6),
    bg: Color(0x286D28D9),
  );

  static const checklist = TaskTypeColors(
    start: Color(0xFF047857),
    end: Color(0xFF10B981),
    bg: Color(0x28047857),
  );

  static const appointment = TaskTypeColors(
    start: Color(0xFF1E40AF),
    end: Color(0xFF3B82F6),
    bg: Color(0x281E40AF),
  );

  static const message = TaskTypeColors(
    start: Color(0xFFB45309),
    end: Color(0xFFF59E0B),
    bg: Color(0x28B45309),
  );

  static const custom = TaskTypeColors(
    start: Color(0xFF334155),
    end: Color(0xFF64748B),
    bg: Color(0x24334155),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class TimelineAppColors {
  const TimelineAppColors._();

  // Neutral surfaces
  static const Color background = Color(0xFFF0F2F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFE8EBF4);

  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textMuted = Color(0xFF6B7280);

  // Status colors – kept subtle to match the calm home-screen aesthetic.
  static const TimelineStatusColors planned = TimelineStatusColors(
    bg: Color(0x00000000),
    fg: Color(0xFFC7C7CC),
    border: Color(0x00000000),
  );

  static const TimelineStatusColors inProgress = TimelineStatusColors(
    bg: Color(0x00000000),
    fg: Color(0xFFFF9500),
    border: Color(0x00000000),
  );

  static const TimelineStatusColors due = TimelineStatusColors(
    bg: Color(0x00000000),
    fg: Color(0xFFFF3B30),
    border: Color(0x00000000),
  );

  static const TimelineStatusColors done = TimelineStatusColors(
    bg: Color(0x00000000),
    fg: Color(0xFF34C759),
    border: Color(0x00000000),
  );

  static const TimelineStatusColors skipped = TimelineStatusColors(
    bg: Color(0x00000000),
    fg: Color(0xFFC7C7CC),
    border: Color(0x00000000),
  );
}
