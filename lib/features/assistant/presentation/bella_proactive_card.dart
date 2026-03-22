import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../domain/bella_proactive_engine.dart';

/// A home-screen card showing Bella's most important proactive
/// recommendation. Tapping triggers [onTap] with the chat prompt.
/// Dismissing hides it for the rest of the day.
class BellaProactiveCard extends StatefulWidget {
  const BellaProactiveCard({
    super.key,
    required this.engine,
    required this.onTap,
  });

  final BellaProactiveEngine engine;

  /// Called with the pre-filled chat prompt when the user taps the card.
  final void Function(String chatPrompt) onTap;

  @override
  State<BellaProactiveCard> createState() => _BellaProactiveCardState();
}

class _BellaProactiveCardState extends State<BellaProactiveCard> {
  BellaRecommendation? _recommendation;
  bool _dismissed = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rec = await widget.engine.topRecommendation();
    if (!mounted) return;
    setState(() {
      _recommendation = rec;
      _loaded = true;
    });
  }

  void _dismiss() {
    if (_recommendation == null) return;
    HapticFeedback.lightImpact();
    widget.engine.dismiss(_recommendation!.type);
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _recommendation == null || _dismissed) {
      return const SizedBox.shrink();
    }

    final rec = _recommendation!;

    return FadeSlideIn(
      slideOffset: 4,
      duration: const Duration(milliseconds: 300),
      child: Dismissible(
        key: ValueKey('bella_proactive_${rec.type.name}'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => _dismiss(),
        child: PressableScale(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap(rec.chatPrompt);
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppRadius.borderRadiusLg,
            color: const Color(0xFFFF6B9D).withValues(alpha: 0.06),
            child: Row(
              children: [
                // Bella avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D)
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/bella_avatar.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bella sagt:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF6B9D),
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rec.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Dismiss button
                GestureDetector(
                  onTap: _dismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 20,
                      color: AppColors.textSecondary.withValues(alpha: 0.4),
                    ),
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
