import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../../../ui/theme/app_icons.dart';

class ImprintScreen extends StatelessWidget {
  const ImprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPage(
      title: l.settingsImprint,
      titleIcon: AppIcons.documents,
      titleColor: AppColors.textSecondary,
      children: const [
        _LegalSection(
          title: 'Angaben gemäß § 5 TMG',
          body: '[FIRMENNAME]\n'
              '[RECHTSFORM, z. B. GmbH, UG (haftungsbeschränkt)]\n'
              '[STRAßE UND HAUSNUMMER]\n'
              '[PLZ ORT]\n'
              'Deutschland',
        ),
        _LegalSection(
          title: 'Vertreten durch',
          body: '[VORNAME NACHNAME], Geschäftsführer/in',
        ),
        _LegalSection(
          title: 'Kontakt',
          body: 'E-Mail: [E-MAIL-ADRESSE]\n'
              'Telefon: [TELEFONNUMMER]',
        ),
        _LegalSection(
          title: 'Registereintrag',
          body: 'Eingetragen im Handelsregister.\n'
              'Registergericht: [AMTSGERICHT]\n'
              'Registernummer: [HRB-NUMMER]',
        ),
        _LegalSection(
          title: 'Umsatzsteuer-ID',
          body:
              'Umsatzsteuer-Identifikationsnummer gemäß § 27a UStG:\n'
              '[DE XXXXXXXXX]',
        ),
        _LegalSection(
          title: 'Verantwortlich für den Inhalt nach § 18 Abs. 2 MStV',
          body: '[VORNAME NACHNAME]\n'
              '[STRAßE UND HAUSNUMMER]\n'
              '[PLZ ORT]',
        ),
        _LegalSection(
          title: 'Haftungshinweis',
          body:
              'Die Inhalte dieser App wurden mit größter Sorgfalt erstellt. '
              'Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte '
              'übernehmen wir jedoch keine Gewähr. Die App stellt keine '
              'medizinische Beratung dar und ersetzt nicht die Konsultation '
              'eines Arztes oder einer Ärztin.\n\n'
              'Trotz sorgfältiger inhaltlicher Kontrolle übernehmen wir keine '
              'Haftung für die Inhalte externer Links. Für den Inhalt der '
              'verlinkten Seiten sind ausschließlich deren Betreiber '
              'verantwortlich.',
        ),
        _LegalSection(
          title: 'Streitbeilegung',
          body:
              'Die Europäische Kommission stellt eine Plattform zur '
              'Online-Streitbeilegung (OS) bereit: '
              'https://ec.europa.eu/consumers/odr\n\n'
              'Wir sind nicht bereit oder verpflichtet, an '
              'Streitbeilegungsverfahren vor einer '
              'Verbraucherschlichtungsstelle teilzunehmen.',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
