import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPage(
      title: l.settingsPrivacy,
      titleEmoji: '🔒',
      titleColor: AppColors.textSecondary,
      children: const [
        // ── 1. Verantwortlicher ──
        _LegalSection(
          title: '1. Verantwortlicher',
          body: 'Verantwortlich im Sinne der Datenschutz-Grundverordnung '
              '(DSGVO) ist:\n\n'
              '[FIRMENNAME]\n'
              '[STRAßE UND HAUSNUMMER]\n'
              '[PLZ ORT]\n'
              'E-Mail: [E-MAIL-ADRESSE]',
        ),

        // ── 2. Erhobene Daten ──
        _LegalSection(
          title: '2. Erhobene Daten und Zweck der Verarbeitung',
          body: 'Wir verarbeiten folgende personenbezogene Daten:\n\n'
              'a) Kontodaten\n'
              'E-Mail-Adresse und Passwort zur Authentifizierung über '
              'Firebase Authentication (Art. 6 Abs. 1 lit. b DSGVO — '
              'Vertragserfüllung).\n\n'
              'b) Gesundheitsdaten\n'
              'Schmerzwerte, Vitalzeichen (Blutdruck, Puls, Temperatur), '
              'Medikamente, Wundfotos, Symptom-Einschätzungen und '
              'Sprachnotizen. Diese Daten werden ausschließlich auf Ihre '
              'Eingabe hin gespeichert und dienen der Dokumentation Ihres '
              'Genesungsverlaufs (Art. 9 Abs. 2 lit. a DSGVO — '
              'ausdrückliche Einwilligung).\n\n'
              'c) Dokumente und Fotos\n'
              'Von Ihnen hochgeladene Dateien (z. B. Arztbriefe, OP-Berichte, '
              'Wunddokumentation) werden in Firebase Cloud Storage '
              'gespeichert.\n\n'
              'd) Termine und Aufgaben\n'
              'Arzttermine, Checklisten und Timeline-Fortschritt werden in '
              'Cloud Firestore gespeichert, um Ihren Genesungsplan '
              'abzubilden.\n\n'
              'e) Geräte- und Nutzungsdaten\n'
              'Push-Token (Firebase Cloud Messaging) zur Zustellung von '
              'Erinnerungen. Es werden keine Werbe-IDs erhoben.',
        ),

        // ── 3. Rechtsgrundlagen ──
        _LegalSection(
          title: '3. Rechtsgrundlagen der Verarbeitung',
          body: '• Art. 6 Abs. 1 lit. a DSGVO — Einwilligung '
              '(Gesundheitsdaten, Push-Benachrichtigungen)\n'
              '• Art. 6 Abs. 1 lit. b DSGVO — Vertragserfüllung '
              '(Nutzerkonto, Pro-Abonnement)\n'
              '• Art. 6 Abs. 1 lit. f DSGVO — Berechtigtes Interesse '
              '(Fehlerbehebung, Sicherheit)',
        ),

        // ── 4. Auftragsverarbeitung ──
        _LegalSection(
          title: '4. Auftragsverarbeiter und Drittlandtransfer',
          body: 'Wir nutzen Dienste von Google Ireland Limited '
              '(Gordon House, Barrow Street, Dublin 4, Irland) als '
              'Auftragsverarbeiter:\n\n'
              '• Firebase Authentication — Kontoverwaltung\n'
              '• Cloud Firestore — Datenspeicherung\n'
              '• Firebase Cloud Storage — Dateispeicherung\n'
              '• Firebase Cloud Messaging — Push-Benachrichtigungen\n\n'
              'Daten können auf Servern innerhalb der EU/des EWR oder in '
              'den USA verarbeitet werden. Der Transfer in die USA erfolgt '
              'auf Grundlage des EU-US Data Privacy Framework (Angemessenheitsbeschluss '
              'der EU-Kommission) bzw. der Standardvertragsklauseln '
              '(Art. 46 Abs. 2 lit. c DSGVO).',
        ),

        // ── 5. Speicherdauer ──
        _LegalSection(
          title: '5. Speicherdauer',
          body: 'Ihre Daten werden gespeichert, solange Ihr Nutzerkonto '
              'besteht. Nach Löschung des Kontos werden alle '
              'personenbezogenen Daten innerhalb von 30 Tagen aus unseren '
              'Systemen entfernt, sofern keine gesetzlichen '
              'Aufbewahrungspflichten entgegenstehen.',
        ),

        // ── 6. Rechte der Betroffenen ──
        _LegalSection(
          title: '6. Ihre Rechte',
          body: 'Sie haben jederzeit das Recht auf:\n\n'
              '• Auskunft über Ihre gespeicherten Daten (Art. 15 DSGVO)\n'
              '• Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n'
              '• Löschung Ihrer Daten (Art. 17 DSGVO)\n'
              '• Einschränkung der Verarbeitung (Art. 18 DSGVO)\n'
              '• Datenübertragbarkeit (Art. 20 DSGVO)\n'
              '• Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)\n'
              '• Widerruf einer erteilten Einwilligung mit Wirkung für '
              'die Zukunft (Art. 7 Abs. 3 DSGVO)\n\n'
              'Richten Sie Ihre Anfrage an: [E-MAIL-ADRESSE]',
        ),

        // ── 7. Beschwerderecht ──
        _LegalSection(
          title: '7. Beschwerderecht',
          body: 'Sie haben das Recht, sich bei einer '
              'Datenschutzaufsichtsbehörde über die Verarbeitung Ihrer '
              'personenbezogenen Daten zu beschweren (Art. 77 DSGVO).\n\n'
              'Zuständige Aufsichtsbehörde:\n'
              '[NAME DER ZUSTÄNDIGEN LANDESBEHÖRDE]\n'
              '[ADRESSE DER AUFSICHTSBEHÖRDE]',
        ),

        // ── 8. Datensicherheit ──
        _LegalSection(
          title: '8. Datensicherheit',
          body: 'Die Kommunikation zwischen der App und den Servern '
              'erfolgt ausschließlich über verschlüsselte Verbindungen '
              '(TLS/SSL). Der Zugriff auf Ihre Daten in Cloud Firestore '
              'und Cloud Storage ist durch Firebase Security Rules auf '
              'Ihr Nutzerkonto beschränkt.',
        ),

        // ── 9. Änderungen ──
        _LegalSection(
          title: '9. Änderungen dieser Datenschutzerklärung',
          body: 'Wir behalten uns vor, diese Datenschutzerklärung '
              'anzupassen, um sie an geänderte Rechtslagen oder '
              'Änderungen der App anzupassen. Die aktuelle Fassung '
              'ist stets in der App unter Einstellungen → Datenschutz '
              'abrufbar.\n\n'
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
