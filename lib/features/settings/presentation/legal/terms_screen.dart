import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../../../ui/theme/app_icons.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPage(
      title: l.settingsTerms,
      titleIcon: AppIcons.imprint,
      titleColor: AppColors.textSecondary,
      children: const [
        // ── 1. Geltungsbereich ──
        _LegalSection(
          title: '1. Geltungsbereich',
          body: 'Diese Allgemeinen Geschäftsbedingungen (AGB) gelten für '
              'die Nutzung der mobilen Anwendung „Operationsbegleiter" '
              '(nachfolgend „App"), bereitgestellt von:\n\n'
              '[FIRMENNAME]\n'
              '[STRAßE UND HAUSNUMMER]\n'
              '[PLZ ORT]\n\n'
              'Mit der Registrierung und Nutzung der App erkennen Sie '
              'diese AGB an.',
        ),

        // ── 2. Leistungsbeschreibung ──
        _LegalSection(
          title: '2. Leistungsbeschreibung',
          body: 'Die App unterstützt Patientinnen und Patienten bei der '
              'Vor- und Nachbereitung eines operativen Eingriffs. '
              'Funktionen umfassen u. a.:\n\n'
              '• Genesungs-Timeline mit Aufgaben und Erinnerungen\n'
              '• Schmerztagebuch und Vitalzeichen-Dokumentation\n'
              '• Wunddokumentation mit Fotovergleich\n'
              '• Medikamenten- und Terminverwaltung\n'
              '• Dokumenten- und Foto-Upload\n'
              '• Arztbericht-Zusammenfassung\n'
              '• Sprachnotizen\n\n'
              'Die App stellt keine medizinische Beratung dar und ersetzt '
              'nicht die ärztliche Konsultation. Alle Gesundheitsinformationen '
              'dienen ausschließlich der persönlichen Dokumentation.',
        ),

        // ── 3. Nutzerkonto ──
        _LegalSection(
          title: '3. Nutzerkonto und Registrierung',
          body: 'Zur Nutzung der App ist die Erstellung eines '
              'Nutzerkontos mit einer gültigen E-Mail-Adresse '
              'erforderlich. Sie sind verpflichtet, Ihre Zugangsdaten '
              'vertraulich zu behandeln und uns über eine unbefugte '
              'Nutzung unverzüglich zu informieren.\n\n'
              'Sie können Ihr Konto jederzeit über die Einstellungen '
              'der App löschen. Mit der Löschung werden alle '
              'gespeicherten Daten gemäß unserer Datenschutzerklärung '
              'entfernt.',
        ),

        // ── 4. Pro-Abonnement ──
        _LegalSection(
          title: '4. Pro-Abonnement und In-App-Käufe',
          body: 'Die App bietet eine kostenlose Basisversion sowie ein '
              'kostenpflichtiges Pro-Abonnement mit erweiterten '
              'Funktionen (z. B. Gamification, Warnsystem, erweiterte '
              'Analysen).\n\n'
              'a) Abschluss\n'
              'Das Pro-Abonnement wird über den jeweiligen App Store '
              '(Apple App Store / Google Play Store) abgeschlossen. '
              'Es gelten die Zahlungsbedingungen des Stores.\n\n'
              'b) Laufzeit und Verlängerung\n'
              'Das Abonnement verlängert sich automatisch um die '
              'gewählte Laufzeit, sofern es nicht mindestens 24 Stunden '
              'vor Ablauf der aktuellen Periode gekündigt wird.\n\n'
              'c) Kündigung\n'
              'Die Kündigung erfolgt über die Abo-Verwaltung des '
              'jeweiligen App Stores. Eine Kündigung in der App selbst '
              'ist nicht möglich.\n\n'
              'd) Einlöse-Codes\n'
              'Pro-Zugänge können auch über Einlöse-Codes (Redeem Keys) '
              'freigeschaltet werden. Diese sind nicht übertragbar und '
              'nur einmal einlösbar.',
        ),

        // ── 5. Nutzerpflichten ──
        _LegalSection(
          title: '5. Pflichten der Nutzer',
          body: 'Sie verpflichten sich:\n\n'
              '• Die App nur für den bestimmungsgemäßen Zweck zu nutzen\n'
              '• Keine falschen oder irreführenden Angaben zu machen\n'
              '• Keine rechtswidrigen Inhalte hochzuladen\n'
              '• Die App nicht zu dekompilieren, zurückzuentwickeln oder '
              'in anderer Weise zu manipulieren',
        ),

        // ── 6. Haftung ──
        _LegalSection(
          title: '6. Haftungsbeschränkung',
          body: 'a) Bei kostenloser Nutzung haften wir nur für Vorsatz '
              'und grobe Fahrlässigkeit.\n\n'
              'b) Bei kostenpflichtiger Nutzung (Pro) haften wir '
              'zusätzlich für die Verletzung wesentlicher '
              'Vertragspflichten (Kardinalpflichten), begrenzt auf den '
              'vorhersehbaren, vertragstypischen Schaden.\n\n'
              'c) Die App ersetzt keine ärztliche Diagnose oder '
              'Behandlung. Für gesundheitliche Entscheidungen auf '
              'Grundlage der App-Inhalte übernehmen wir keine Haftung.\n\n'
              'd) Die vorstehenden Haftungsbeschränkungen gelten nicht '
              'für Schäden aus der Verletzung des Lebens, des Körpers '
              'oder der Gesundheit.',
        ),

        // ── 7. Verfügbarkeit ──
        _LegalSection(
          title: '7. Verfügbarkeit',
          body: 'Wir bemühen uns um eine hohe Verfügbarkeit der App, '
              'garantieren jedoch keine ununterbrochene Erreichbarkeit. '
              'Wartungsarbeiten, Updates und höhere Gewalt können zu '
              'vorübergehenden Einschränkungen führen.',
        ),

        // ── 8. Änderungen der AGB ──
        _LegalSection(
          title: '8. Änderungen dieser AGB',
          body: 'Wir behalten uns vor, diese AGB mit Wirkung für die '
              'Zukunft zu ändern. Über wesentliche Änderungen werden '
              'Sie per E-Mail oder In-App-Benachrichtigung informiert. '
              'Widersprechen Sie den Änderungen nicht innerhalb von '
              '30 Tagen nach Benachrichtigung, gelten die neuen AGB '
              'als akzeptiert.',
        ),

        // ── 9. Schlussbestimmungen ──
        _LegalSection(
          title: '9. Schlussbestimmungen',
          body: 'a) Es gilt das Recht der Bundesrepublik Deutschland '
              'unter Ausschluss des UN-Kaufrechts.\n\n'
              'b) Gerichtsstand für alle Streitigkeiten aus oder im '
              'Zusammenhang mit diesen AGB ist, soweit gesetzlich '
              'zulässig, [ORT DES FIRMENSITZES].\n\n'
              'c) Sollten einzelne Bestimmungen dieser AGB unwirksam '
              'sein oder werden, bleibt die Wirksamkeit der übrigen '
              'Bestimmungen unberührt.\n\n'
              'Stand: [DATUM EINFÜGEN]',
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
