import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../../../features/assistant/domain/bella_proactive_engine.dart';

/// A more prominent Bella recommendation section for the home screen.
/// Shows a section header + recommendation card with Bella branding.
class HomeBellaSection extends StatefulWidget {
  const HomeBellaSection({
    super.key,
    required this.engine,
    required this.onTap,
  });

  final BellaProactiveEngine engine;
  final void Function(String chatPrompt) onTap;

  @override
  State<HomeBellaSection> createState() => _HomeBellaSectionState();
}

class _HomeBellaSectionState extends State<HomeBellaSection> {
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
    final tt = Theme.of(context).textTheme;

    return FadeSlideIn(
      slideOffset: 4,
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/bella_avatar.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Bellas Empfehlung',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Recommendation card ──
          Dismissible(
            key: ValueKey('bella_home_${rec.type.name}'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => _dismiss(),
            child: PressableScale(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap(rec.chatPrompt);
              },
              scaleFactor: 0.98,
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.06),
                elevation: GlassElevation.low,
                child: Row(
                  children: [
                    // Bella avatar
                    Container(
                      width: 44,
                      height: 44,
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
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.message,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Mit Bella besprechen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF6B9D),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.arrow_right,
                                size: 12,
                                color: const Color(0xFFFF6B9D),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Dismiss
                    GestureDetector(
                      onTap: _dismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          size: 20,
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
