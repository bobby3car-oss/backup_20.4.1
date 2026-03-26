import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/support/presentation/my_tickets_screen.dart';
import '../sync/online_guard.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';
import '../l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqItems = <_FaqItem>[
    _FaqItem(
      question: 'Wie werden meine Daten gespeichert?',
      answer:
          'Ihre Daten werden lokal auf Ihrem Gerät und verschlüsselt in '
          'Google Firebase (Cloud Firestore) gespeichert. Der Zugriff ist '
          'auf Ihr Nutzerkonto beschränkt. Weitere Details finden Sie in '
          'der Datenschutzerklärung unter Einstellungen → Datenschutz.',
    ),
    _FaqItem(
      question: 'Wie kann ich mein Pro-Abo kündigen?',
      answer:
          'Das Pro-Abonnement wird über den App Store (Apple) bzw. Google '
          'Play Store verwaltet. Öffnen Sie dort Ihre Abo-Verwaltung und '
          'kündigen Sie das Abo mindestens 24 Stunden vor Ablauf der '
          'aktuellen Periode.',
    ),
    _FaqItem(
      question: 'Wie funktioniert die Wunddokumentation?',
      answer:
          'Öffnen Sie „Wunddokumentation" im Hauptmenü oder der Timeline. '
          'Fotografieren Sie die Wunde mit der Kamera oder wählen Sie ein '
          'Bild aus der Galerie. Die Fotos werden chronologisch gespeichert '
          'und können über den Vergleichs-Modus nebeneinander angezeigt werden.',
    ),
    _FaqItem(
      question: 'Kann ich meinen Account löschen?',
      answer:
          'Ja. Gehen Sie zu Einstellungen → Daten → „Daten zurücksetzen". '
          'Dort haben Sie die Möglichkeit, alle Daten zu löschen oder Ihren '
          'Account vollständig zu entfernen. Diese Aktion kann nicht '
          'rückgängig gemacht werden.',
    ),
    _FaqItem(
      question: 'Wer kann meine Gesundheitsdaten sehen?',
      answer:
          'Nur Sie und die Personen, denen Sie über die Einladungsfunktion '
          'Zugang gewährt haben (Arzt oder Angehörige). Niemand sonst hat '
          'Zugriff auf Ihre Daten.',
    ),
    _FaqItem(
      question: 'Was bedeuten die Warnstufen beim Symptom-Check?',
      answer:
          '🟢 Grün = unbedenklich, normale Genesungserscheinungen.\n'
          '🟡 Gelb = beobachten, beim nächsten Arzttermin ansprechen.\n'
          'Rot = zeitnah ärztlichen Rat einholen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: 'Hilfe & Support',
      titleIcon: AppIcons.messages,
      titleColor: AppColors.accent,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Häufig gestellte Fragen',
            style: TextStyle(
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
                for (var i = 0; i < _faqItems.length; i++) ...[
                  ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      _faqItems[i].question,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          _faqItems[i].answer,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < _faqItems.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Kontakt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Sie haben eine Frage, die hier nicht beantwortet wird? '
            'Erstellen Sie ein Ticket oder schreiben Sie uns eine E-Mail.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@operationsbegleiter.de',
      queryParameters: {
        'subject': 'Operationsbegleiter – Support-Anfrage',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Keine E-Mail-App gefunden')),
      );
    }
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}
