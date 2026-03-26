import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../op_info_content.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OpInfoScreen extends StatefulWidget {
  const OpInfoScreen({super.key});

  @override
  State<OpInfoScreen> createState() => _OpInfoScreenState();
}

class _OpInfoScreenState extends State<OpInfoScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final cat = opInfoCategories[_selected];

    return GlassPage(
      title: 'OP-Infos',
      titleIcon: AppIcons.hospital,
      titleColor: AppColors.primary,
      scrollableBody: (headerHeight) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: headerHeight),

          // ── Chip row ─────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: List.generate(opInfoCategories.length, (i) {
                final isActive = i == _selected;
                final c = opInfoCategories[i];
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < opInfoCategories.length - 1 ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : const Color(0xFFD1D1D6),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassIcon(
                            icon: c.icon,
                            color: c.iconColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // ── Content ──────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _CategoryBody(key: ValueKey(cat.id), category: cat),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category body – dispatches to cards / faqs / warnings
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBody extends StatelessWidget {
  const _CategoryBody({super.key, required this.category});

  final OpInfoCategory category;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      physics: adaptiveScrollPhysics,
      children: [
        // ── Intro card ───────────────────────────────────────────
        _IntroCard(icon: category.icon,
                    iconColor: category.iconColor, text: category.intro),
        const SizedBox(height: 16),

        // ── Knowledge cards ──────────────────────────────────────
        for (var i = 0; i < category.cards.length; i++) ...[
          FadeSlideIn(
            delay: Duration(milliseconds: 60 + i * 50),
            child: _KnowledgeCard(
              index: i + 1,
              card: category.cards[i],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Warning items ────────────────────────────────────────
        if (category.warnings.isNotEmpty) ...[
          for (var i = 0; i < category.warnings.length; i++) ...[
            FadeSlideIn(
              delay: Duration(milliseconds: 60 + i * 50),
              child: _WarningTile(warning: category.warnings[i]),
            ),
            const SizedBox(height: 10),
          ],
        ],

        // ── FAQ items ────────────────────────────────────────────
        if (category.faqs.isNotEmpty) ...[
          for (var i = 0; i < category.faqs.length; i++) ...[
            FadeSlideIn(
              delay: Duration(milliseconds: 60 + i * 50),
              child: _FaqCard(faq: category.faqs[i]),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          // CTA to doctor questions
          FadeSlideIn(
            delay: Duration(
              milliseconds: 60 + category.faqs.length * 50,
            ),
            child: const _DoctorQuestionsCta(),
          ),
          const SizedBox(height: 12),
        ],

        // ── Footer hint ──────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(14),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ℹ️ ', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Diese Informationen ersetzen nicht die individuelle '
                  'Beratung durch Ihr Behandlungsteam.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Intro card
// ─────────────────────────────────────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.icon,
    required this.iconColor, required this.text});

  final IconData icon;


  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassIcon(icon: icon, color: iconColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Knowledge card
// ─────────────────────────────────────────────────────────────────────────────

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard({required this.index, required this.card});

  final int index;
  final OpInfoCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAQ card with visible short answer + expandable detail
// ─────────────────────────────────────────────────────────────────────────────

class _FaqCard extends StatefulWidget {
  const _FaqCard({required this.faq});

  final OpInfoFaq faq;

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDetail = widget.faq.detail != null;

    return GestureDetector(
      onTap: hasDetail ? () => setState(() => _expanded = !_expanded) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _expanded
                ? AppColors.primary.withValues(alpha: 0.25)
                : const Color(0xFFE5E5EA),
            width: _expanded ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _expanded
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : const Color(0x08000000),
              blurRadius: _expanded ? 24 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                if (hasDetail) ...[
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 22,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Short answer – always visible
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                widget.faq.shortAnswer,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Detail – expandable
            if (hasDetail)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 40, top: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.faq.detail!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Warning tile
// ─────────────────────────────────────────────────────────────────────────────

class _WarningTile extends StatelessWidget {
  const _WarningTile({required this.warning});

  final OpInfoWarning warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: warning.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warning.color.withValues(alpha: 0.20),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(warning.icon, size: 22, color: warning.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: warning.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    warning.levelLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: warning.color,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Symptom
                Text(
                  warning.text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                // Action
                if (warning.action != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    warning.action!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA to doctor questions
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorQuestionsCta extends StatelessWidget {
  const _DoctorQuestionsCta();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PressableScale(
      onTap: () {
        Haptic.light();
        Navigator.of(context).pushNamed('/doctor-questions');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.edit_note_rounded, size: 24, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ihre Frage ist nicht dabei?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    l.fragenFuerDenArztNotieren,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
