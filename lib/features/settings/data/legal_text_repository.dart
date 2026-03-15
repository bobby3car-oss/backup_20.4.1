import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A single section of a legal document (e.g. "1. Verantwortlicher" + body).
class LegalSection {
  const LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// Fetches legal texts from Firestore (`/legal/{type}`) with hardcoded
/// fallback data so screens are never empty – even offline.
class LegalTextRepository {
  LegalTextRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Fetches sections for [type] (`privacy`, `terms`, `imprint`) from
  /// Firestore. Returns the hardcoded fallback on any error.
  Future<List<LegalSection>> fetch(String type) async {
    try {
      final doc = await _db.collection('legal').doc(type).get();
      final data = doc.data();
      if (data == null || data['sections'] is! List) {
        return fallbackFor(type);
      }
      final raw = data['sections'] as List<dynamic>;
      return raw.map((e) {
        final map = e as Map<String, dynamic>;
        return LegalSection(
          title: map['title'] as String? ?? '',
          body: map['body'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('LegalTextRepository.fetch($type) failed: $e');
      return fallbackFor(type);
    }
  }

  /// Hardcoded fallback texts – identical to the original screens.
  List<LegalSection> fallbackFor(String type) {
    switch (type) {
      case 'privacy':
        return _privacyFallback;
      case 'terms':
        return _termsFallback;
      case 'imprint':
        return _imprintFallback;
      default:
        return const [];
    }
  }

  // ── Privacy fallback ───────────────────────────────────────────────

  static final _privacyFallback = const [
    LegalSection(
      title: '1. Verantwortlicher',
      body: 'Verantwortlich im Sinne der Datenschutz-Grundverordnung '
          '(DSGVO) ist:\n\n'
          'Jan Goede\n'
          'Halmweg 15b\n'
          '31228 Peine\n'
          'Deutschland\n\n'
          'E-Mail: operationsbegleiter@gmail.com',
    ),
    LegalSection(
      title: '2. Erhobene Daten und Zweck der Verarbeitung',
      body: 'Im Rahmen der Nutzung der App „Operationsbegleiter" '
          '(nachfolgend „App") werden folgende personenbezogene '
          'Daten verarbeitet:\n\n'
          'a) Kontodaten\n'
          'E-Mail-Adresse und Passwort zur Authentifizierung über '
          'Firebase Authentication (Art. 6 Abs. 1 lit. b DSGVO — '
          'Vertragserfüllung).\n\n'
          'b) Gesundheitsbezogene Daten (Art. 9 DSGVO)\n'
          'Schmerzwerte, Vitalzeichen (Blutdruck, Puls, Temperatur), '
          'Medikamente, Wundfotos, Symptom-Einschätzungen und '
          'Sprachnotizen. Diese Daten werden ausschließlich auf Ihre '
          'aktive Eingabe hin gespeichert und dienen allein der '
          'persönlichen Dokumentation Ihres Genesungsverlaufs '
          '(Art. 9 Abs. 2 lit. a DSGVO — ausdrückliche Einwilligung). '
          'Eine medizinische Auswertung oder Diagnose findet '
          'ausdrücklich nicht statt.\n\n'
          'c) Dokumente und Fotos\n'
          'Von Ihnen hochgeladene Dateien (z. B. Arztbriefe, '
          'OP-Berichte, Wunddokumentation) werden in Firebase '
          'Cloud Storage gespeichert.\n\n'
          'd) Termine und Aufgaben\n'
          'Arzttermine, Checklisten und Timeline-Fortschritt werden '
          'in Cloud Firestore gespeichert, um Ihren persönlichen '
          'Genesungsplan abzubilden.\n\n'
          'e) Werbung\n'
          'Wenn Werbung in der App aktiviert ist, werden Werbebanner '
          'über Google AdMob für Nutzer ohne aktives Pro-Abonnement '
          'angezeigt. Nutzer mit aktivem Pro-Abonnement sehen keine '
          'Werbung. Google AdMob kann dabei Geräte-IDs und '
          'Nutzungsdaten gemäß der Google-Datenschutzrichtlinie '
          'verarbeiten.\n\n'
          'f) Geräte- und Nutzungsdaten\n'
          'Push-Token (Firebase Cloud Messaging) zur Zustellung von '
          'Erinnerungen.\n\n'
          'g) KI-Assistent (Bella AI)\n'
          'Wenn Sie den KI-Assistenten nutzen, werden Ihre '
          'Chat-Nachrichten an einen externen KI-Dienst (NVIDIA '
          'Corporation) übermittelt, um eine Antwort zu generieren. '
          'Es werden ausschließlich die von Ihnen eingegebenen '
          'Nachrichten und der Gesprächsverlauf übertragen — keine '
          'weiteren personenbezogenen Daten. Die Nutzung erfolgt '
          'auf Grundlage Ihrer Einwilligung (Art. 6 Abs. 1 lit. a, '
          'Art. 9 Abs. 2 lit. a DSGVO). Sie können den KI-Assistenten '
          'jederzeit nicht nutzen, um die Datenübermittlung zu '
          'vermeiden.\n\n'
          'h) Analyse- und Absturzdaten\n'
          'Firebase Analytics erfasst anonymisierte Nutzungsstatistiken '
          'zur Verbesserung der App. Firebase Crashlytics protokolliert '
          'Absturzberichte zur Fehlerbehebung. Beide Dienste können '
          'in den Einstellungen deaktiviert werden '
          '(Art. 6 Abs. 1 lit. a DSGVO — Einwilligung).',
    ),
    LegalSection(
      title: '3. Rechtsgrundlagen der Verarbeitung',
      body: '• Art. 6 Abs. 1 lit. a DSGVO — Einwilligung '
          '(Gesundheitsdaten, Push-Benachrichtigungen, '
          'personalisierte Werbung)\n'
          '• Art. 6 Abs. 1 lit. b DSGVO — Vertragserfüllung '
          '(Nutzerkonto, Pro-Abonnement, werbefreie Nutzung '
          'mit Pro)\n'
          '• Art. 6 Abs. 1 lit. f DSGVO — Berechtigtes Interesse '
          '(Fehlerbehebung, App-Sicherheit, Missbrauchsprävention)',
    ),
    LegalSection(
      title: '4. Auftragsverarbeiter und Drittlandtransfer',
      body: 'Zur Erbringung der App-Funktionen werden Dienste von '
          'Google Ireland Limited (Gordon House, Barrow Street, '
          'Dublin 4, Irland) als Auftragsverarbeiter genutzt:\n\n'
          '• Firebase Authentication — Kontoverwaltung\n'
          '• Cloud Firestore — Datenspeicherung\n'
          '• Firebase Cloud Storage — Dateispeicherung\n'
          '• Firebase Cloud Messaging — Push-Benachrichtigungen\n'
          '• Google AdMob — Werbeanzeigen (nur Basis-Version)\n'
          '• Firebase Analytics — anonymisierte Nutzungsstatistiken\n'
          '• Firebase Crashlytics — Absturzberichte\n\n'
          'Für den KI-Assistenten (Bella AI) wird zusätzlich ein '
          'Dienst der NVIDIA Corporation (2788 San Tomas '
          'Expressway, Santa Clara, CA 95051, USA) als '
          'Auftragsverarbeiter genutzt. Die Übermittlung Ihrer '
          'Chat-Nachrichten an NVIDIA erfolgt ausschließlich zur '
          'Generierung von KI-Antworten.\n\n'
          'Daten können auf Servern innerhalb der EU/des EWR oder '
          'in den USA verarbeitet werden. Der Transfer in die USA '
          'erfolgt auf Grundlage des EU-US Data Privacy Framework '
          '(Angemessenheitsbeschluss der EU-Kommission vom '
          '10.07.2023) bzw. der Standardvertragsklauseln '
          '(Art. 46 Abs. 2 lit. c DSGVO).',
    ),
    LegalSection(
      title: '5. Speicherdauer',
      body: 'Ihre Daten werden gespeichert, solange Ihr Nutzerkonto '
          'besteht. Nach Löschung des Kontos werden alle '
          'personenbezogenen Daten innerhalb von 30 Tagen aus den '
          'Systemen entfernt, sofern keine gesetzlichen '
          'Aufbewahrungspflichten (z. B. steuerrechtlich) '
          'entgegenstehen.',
    ),
    LegalSection(
      title: '6. Ihre Rechte',
      body: 'Sie haben jederzeit das Recht auf:\n\n'
          '• Auskunft über Ihre gespeicherten Daten '
          '(Art. 15 DSGVO)\n'
          '• Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n'
          '• Löschung Ihrer Daten (Art. 17 DSGVO)\n'
          '• Einschränkung der Verarbeitung (Art. 18 DSGVO)\n'
          '• Datenübertragbarkeit (Art. 20 DSGVO)\n'
          '• Widerspruch gegen die Verarbeitung '
          '(Art. 21 DSGVO)\n'
          '• Widerruf einer erteilten Einwilligung mit Wirkung '
          'für die Zukunft (Art. 7 Abs. 3 DSGVO)\n\n'
          'Richten Sie Ihre Anfrage an: operationsbegleiter@gmail.com',
    ),
    LegalSection(
      title: '7. Beschwerderecht',
      body: 'Sie haben das Recht, sich bei einer '
          'Datenschutzaufsichtsbehörde über die Verarbeitung Ihrer '
          'personenbezogenen Daten zu beschweren '
          '(Art. 77 DSGVO).\n\n'
          'Zuständige Aufsichtsbehörde:\n'
          'Die Landesbeauftragte für den Datenschutz Niedersachsen\n'
          'Prinzenstraße 5\n'
          '30159 Hannover\n'
          'https://www.lfd.niedersachsen.de',
    ),
    LegalSection(
      title: '8. Datensicherheit',
      body: 'Die Kommunikation zwischen der App und den Servern '
          'erfolgt ausschließlich über verschlüsselte Verbindungen '
          '(TLS/SSL). Der Zugriff auf Ihre Daten in Cloud Firestore '
          'und Cloud Storage ist durch Firebase Security Rules auf '
          'Ihr Nutzerkonto beschränkt. Trotz angemessener '
          'technischer und organisatorischer Maßnahmen kann keine '
          'absolute Sicherheit der Datenübertragung und '
          '-speicherung im Internet garantiert werden.',
    ),
    LegalSection(
      title: '9. Änderungen dieser Datenschutzerklärung',
      body: 'Diese Datenschutzerklärung kann angepasst werden, um '
          'sie an geänderte Rechtslagen oder Änderungen der App '
          'anzupassen. Die aktuelle Fassung ist stets in der App '
          'unter Einstellungen → Datenschutz abrufbar.\n\n'
          'Stand: 14. März 2026',
    ),
  ];

  // ── Terms fallback ─────────────────────────────────────────────────

  static final _termsFallback = const [
    LegalSection(
      title: '1. Geltungsbereich',
      body: 'Diese Nutzungsbedingungen gelten für die Nutzung der '
          'mobilen Anwendung „Operationsbegleiter" (nachfolgend '
          '„App"), bereitgestellt von:\n\n'
          'Jan Goede\n'
          'Halmweg 15b\n'
          '31228 Peine\n'
          'Deutschland\n\n'
          'E-Mail: operationsbegleiter@gmail.com\n\n'
          'Mit der Registrierung und Nutzung der App erkennen Sie '
          'diese Nutzungsbedingungen an.',
    ),
    LegalSection(
      title: '2. Leistungsbeschreibung und wichtiger Hinweis',
      body: 'Die App unterstützt Patientinnen und Patienten bei der '
          'persönlichen Dokumentation rund um einen operativen '
          'Eingriff. Funktionen umfassen u. a.:\n\n'
          '• Genesungs-Timeline mit Aufgaben und Erinnerungen\n'
          '• Schmerztagebuch und Vitalzeichen-Dokumentation\n'
          '• Wunddokumentation mit Fotovergleich\n'
          '• Medikamenten- und Terminverwaltung\n'
          '• Dokumenten- und Foto-Upload\n'
          '• Arztbericht-Zusammenfassung\n'
          '• Sprachnotizen\n\n'
          'WICHTIGER HINWEIS: Die App stellt ausdrücklich keine '
          'medizinische Beratung, Diagnose oder Behandlung dar '
          'und ersetzt in keinem Fall die Konsultation eines '
          'Arztes, einer Ärztin oder sonstiger medizinischer '
          'Fachkräfte. Alle in der App dargestellten '
          'Gesundheitsinformationen dienen ausschließlich der '
          'persönlichen Dokumentation des Nutzers. '
          'Gesundheitsbezogene Entscheidungen dürfen niemals '
          'allein auf Grundlage der App-Inhalte getroffen werden.',
    ),
    LegalSection(
      title: '3. Nutzerkonto und Registrierung',
      body: 'Zur Nutzung der App ist die Erstellung eines '
          'Nutzerkontos mit einer gültigen E-Mail-Adresse '
          'erforderlich. Sie sind verpflichtet, Ihre Zugangsdaten '
          'vertraulich zu behandeln und den Betreiber über eine '
          'unbefugte Nutzung unverzüglich zu informieren. Für '
          'Schäden, die aus der Weitergabe Ihrer Zugangsdaten '
          'entstehen, wird keine Haftung übernommen.\n\n'
          'Sie können Ihr Konto jederzeit über die Einstellungen '
          'der App löschen. Mit der Löschung werden alle '
          'gespeicherten Daten gemäß der Datenschutzerklärung '
          'entfernt.',
    ),
    LegalSection(
      title: '4. Pro-Abonnement und In-App-Käufe',
      body: 'Die App bietet eine kostenlose Basisversion sowie ein '
          'kostenpflichtiges Pro-Abonnement mit erweiterten '
          'Funktionen (z. B. Gamification, Warnsystem, erweiterte '
          'Analysen).\n\n'
          'a) Abschluss\n'
          'Das Pro-Abonnement wird über den jeweiligen App Store '
          '(Apple App Store / Google Play Store) abgeschlossen. '
          'Es gelten die Zahlungsbedingungen des jeweiligen '
          'Stores.\n\n'
          'b) Laufzeit und Verlängerung\n'
          'Das Abonnement verlängert sich automatisch um die '
          'gewählte Laufzeit, sofern es nicht mindestens '
          '24 Stunden vor Ablauf der aktuellen Periode '
          'gekündigt wird.\n\n'
          'c) Kündigung\n'
          'Die Kündigung erfolgt ausschließlich über die '
          'Abo-Verwaltung des jeweiligen App Stores. Eine '
          'Kündigung in der App selbst ist nicht möglich.\n\n'
          'd) Einlöse-Codes\n'
          'Pro-Zugänge können auch über Einlöse-Codes '
          '(Redeem Keys) freigeschaltet werden. Diese sind '
          'nicht übertragbar und nur einmal einlösbar.',
    ),
    LegalSection(
      title: '5. Pflichten der Nutzer',
      body: 'Sie verpflichten sich:\n\n'
          '• Die App nur für den bestimmungsgemäßen Zweck '
          'zu nutzen\n'
          '• Keine falschen oder irreführenden Angaben zu machen\n'
          '• Keine rechtswidrigen Inhalte hochzuladen\n'
          '• Die App nicht zu dekompilieren, zurückzuentwickeln '
          'oder in anderer Weise zu manipulieren\n'
          '• Die App-Inhalte nicht als medizinischen Rat zu '
          'interpretieren oder als Grundlage für '
          'gesundheitsbezogene Entscheidungen zu verwenden',
    ),
    LegalSection(
      title: '6. Haftungsbeschränkung',
      body: 'a) Die App wird „wie besehen" (as is) bereitgestellt. '
          'Für die ununterbrochene, fehlerfreie oder sichere '
          'Bereitstellung der App wird keine Gewähr '
          'übernommen.\n\n'
          'b) Bei kostenloser Nutzung wird nur für Vorsatz und '
          'grobe Fahrlässigkeit gehaftet.\n\n'
          'c) Bei kostenpflichtiger Nutzung (Pro) wird zusätzlich '
          'für die Verletzung wesentlicher Vertragspflichten '
          '(Kardinalpflichten) gehaftet, begrenzt auf den '
          'vorhersehbaren, vertragstypischen Schaden.\n\n'
          'd) Die App ersetzt ausdrücklich keine ärztliche '
          'Diagnose, Behandlung oder Beratung. Für '
          'gesundheitliche Entscheidungen, die auf Grundlage '
          'der App-Inhalte getroffen werden, wird keinerlei '
          'Haftung übernommen.\n\n'
          'e) Für die Richtigkeit, Vollständigkeit und '
          'Aktualität der durch die App bereitgestellten '
          'Informationen (insbesondere Timelines, Checklisten, '
          'Erinnerungen) wird keine Gewähr übernommen.\n\n'
          'f) Für den Verlust von Daten, die der Nutzer in der '
          'App gespeichert hat, wird keine Haftung übernommen, '
          'soweit nicht Vorsatz oder grobe Fahrlässigkeit '
          'vorliegen.\n\n'
          'g) Die vorstehenden Haftungsbeschränkungen gelten '
          'nicht für Schäden aus der Verletzung des Lebens, '
          'des Körpers oder der Gesundheit sowie für Ansprüche '
          'nach dem Produkthaftungsgesetz.',
    ),
    LegalSection(
      title: '7. Verfügbarkeit',
      body: 'Es wird eine möglichst hohe Verfügbarkeit der App '
          'angestrebt, jedoch keine ununterbrochene '
          'Erreichbarkeit garantiert. Wartungsarbeiten, Updates, '
          'höhere Gewalt, Störungen bei Drittanbietern oder '
          'sonstige technische Schwierigkeiten können zu '
          'vorübergehenden Einschränkungen führen. Ein Anspruch '
          'auf ständige Verfügbarkeit besteht nicht.',
    ),
    LegalSection(
      title: '8. Gewährleistungsausschluss',
      body: 'Es wird keine Garantie oder Zusicherung dafür '
          'übernommen, dass die App frei von Fehlern ist, '
          'bestimmte Ergebnisse erzielt werden oder die App '
          'für einen bestimmten Zweck geeignet ist. Die Nutzung '
          'der App erfolgt auf eigenes Risiko des Nutzers.',
    ),
    LegalSection(
      title: '9. Änderungen dieser Nutzungsbedingungen',
      body: 'Diese Nutzungsbedingungen können mit Wirkung für '
          'die Zukunft geändert werden. Über wesentliche '
          'Änderungen werden Sie per E-Mail oder '
          'In-App-Benachrichtigung informiert. Widersprechen Sie '
          'den Änderungen nicht innerhalb von 30 Tagen nach '
          'Benachrichtigung, gelten die neuen '
          'Nutzungsbedingungen als akzeptiert.',
    ),
    LegalSection(
      title: '10. Schlussbestimmungen',
      body: 'a) Es gilt das Recht der Bundesrepublik Deutschland '
          'unter Ausschluss des UN-Kaufrechts.\n\n'
          'b) Gerichtsstand für alle Streitigkeiten aus oder im '
          'Zusammenhang mit diesen Nutzungsbedingungen ist, '
          'soweit gesetzlich zulässig, Peine.\n\n'
          'c) Sollten einzelne Bestimmungen dieser '
          'Nutzungsbedingungen unwirksam sein oder werden, '
          'bleibt die Wirksamkeit der übrigen Bestimmungen '
          'unberührt. An die Stelle der unwirksamen Bestimmung '
          'tritt eine wirksame Regelung, die dem wirtschaftlichen '
          'Zweck der unwirksamen Bestimmung am nächsten kommt.\n\n'
          'Stand: 14. März 2026',
    ),
  ];

  // ── Imprint fallback ───────────────────────────────────────────────

  static final _imprintFallback = const [
    LegalSection(
      title: 'Angaben gemäß § 5 TMG',
      body: 'Jan Goede\n'
          'Halmweg 15b\n'
          '31228 Peine\n'
          'Deutschland',
    ),
    LegalSection(
      title: 'Kontakt',
      body: 'E-Mail: operationsbegleiter@gmail.com',
    ),
    LegalSection(
      title: 'Verantwortlich für den Inhalt nach § 18 Abs. 2 MStV',
      body: 'Jan Goede\n'
          'Halmweg 15b\n'
          '31228 Peine',
    ),
    LegalSection(
      title: 'Haftungsausschluss',
      body: 'Die Inhalte dieser App wurden mit größter Sorgfalt '
          'erstellt. Für die Richtigkeit, Vollständigkeit und '
          'Aktualität der Inhalte wird jedoch keine Gewähr '
          'übernommen.\n\n'
          'Die App stellt ausdrücklich keine medizinische '
          'Beratung, Diagnose oder Behandlungsempfehlung dar '
          'und ersetzt in keinem Fall die Konsultation eines '
          'Arztes, einer Ärztin oder sonstiger medizinischer '
          'Fachkräfte. Jegliche Nutzung der App-Inhalte '
          'erfolgt auf eigenes Risiko.\n\n'
          'Trotz sorgfältiger inhaltlicher Kontrolle wird keine '
          'Haftung für die Inhalte externer Links übernommen. '
          'Für den Inhalt der verlinkten Seiten sind '
          'ausschließlich deren Betreiber verantwortlich.',
    ),
    LegalSection(
      title: 'Streitbeilegung',
      body: 'Die Europäische Kommission stellt eine Plattform zur '
          'Online-Streitbeilegung (OS) bereit:\n'
          'https://ec.europa.eu/consumers/odr\n\n'
          'Zur Teilnahme an einem Streitbeilegungsverfahren vor '
          'einer Verbraucherschlichtungsstelle besteht weder '
          'Bereitschaft noch Verpflichtung.',
    ),
  ];
}
