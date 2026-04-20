import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/support/presentation/my_tickets_screen.dart';
import '../sync/online_guard.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';
import '../l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final faqItems = <_FaqItem>[
      _FaqItem(question: l.helpFaq1Question, answer: l.helpFaq1Answer),
      _FaqItem(question: l.helpFaq2Question, answer: l.helpFaq2Answer),
      _FaqItem(question: l.helpFaq3Question, answer: l.helpFaq3Answer),
      _FaqItem(question: l.helpFaq4Question, answer: l.helpFaq4Answer),
      _FaqItem(question: l.helpFaq5Question, answer: l.helpFaq5Answer),
      _FaqItem(question: l.helpFaq6Question, answer: l.helpFaq6Answer),
    ];

    return GlassPage(
      title: l.helpHilfeUndSupport,
      titleIcon: AppIcons.messages,
      titleColor: AppColors.accent,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            l.helpFaqTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Card(
            child: Column(
              children: [
                for (var i = 0; i < faqItems.length; i++) ...[
                  ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      faqItems[i].question,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faqItems[i].answer,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < faqItems.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            l.helpContactTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            l.helpContactDesc,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                if (!await requireOnline(context)) return;
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MyTicketsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.support_agent_rounded),
              label: Text(l.myTickets),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _sendEmail(context),
              icon: const Icon(Icons.email_rounded),
              label: Text(l.sendEmail),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@operationsbegleiter.de',
      queryParameters: {
        'subject': l.helpEmailSubject,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.keineEmailApp)),
      );
    }
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}
