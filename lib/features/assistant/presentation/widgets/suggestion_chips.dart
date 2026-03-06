import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

/// Horizontally scrollable chips with suggested starter questions.
class SuggestionChips extends StatelessWidget {
  const SuggestionChips({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  static const _suggestions = [
    ('🏥', 'Wie bereite ich mich auf die OP vor?'),
    ('📋', 'Was passiert am OP-Tag?'),
    ('📱', 'Wie funktioniert die Timeline?'),
    ('🚨', 'Wann sollte ich den Arzt rufen?'),
    ('💊', 'Wie erfasse ich meine Medikamente?'),
    ('🦴', 'Infos zur Knie-TEP'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: adaptiveScrollPhysics,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: _suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (emoji, text) = _suggestions[index];
          return PressableScale(
            onTap: () {
              Haptic.selection();
              onSelected(text);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.55),
                borderRadius: AppRadius.borderRadiusPill,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
