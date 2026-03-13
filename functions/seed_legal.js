#!/usr/bin/env node
/**
 * Seed-Script: Legt die initialen Rechtstexte in Firestore an.
 *
 * Ausführen:
 *   cd functions && node seed_legal.js
 *
 * Voraussetzung: Firebase Admin SDK initialisiert sich über
 * Application Default Credentials (firebase login reicht).
 */

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

// Uses GOOGLE_APPLICATION_CREDENTIALS env var, or falls back to
// gcloud ADC, or Firebase emulator when FIRESTORE_EMULATOR_HOST is set.
initializeApp({ projectId: "operationsbegleiter-860e7" });

const db = getFirestore();

const privacy = {
  sections: [
    {
      title: "1. Verantwortlicher",
      body:
        "Verantwortlich im Sinne der Datenschutz-Grundverordnung " +
        "(DSGVO) ist:\n\n" +
        "[FIRMENNAME]\n" +
        "[STRAßE UND HAUSNUMMER]\n" +
        "[PLZ ORT]\n" +
        "E-Mail: [E-MAIL-ADRESSE]",
    },
    {
      title: "2. Erhobene Daten und Zweck der Verarbeitung",
      body:
        "Wir verarbeiten folgende personenbezogene Daten:\n\n" +
        "a) Kontodaten\n" +
        "E-Mail-Adresse und Passwort zur Authentifizierung über " +
        "Firebase Authentication (Art. 6 Abs. 1 lit. b DSGVO — " +
        "Vertragserfüllung).\n\n" +
        "b) Gesundheitsdaten\n" +
        "Schmerzwerte, Vitalzeichen (Blutdruck, Puls, Temperatur), " +
        "Medikamente, Wundfotos, Symptom-Einschätzungen und " +
        "Sprachnotizen. Diese Daten werden ausschließlich auf Ihre " +
        "Eingabe hin gespeichert und dienen der Dokumentation Ihres " +
        "Genesungsverlaufs (Art. 9 Abs. 2 lit. a DSGVO — " +
        "ausdrückliche Einwilligung).\n\n" +
        "c) Dokumente und Fotos\n" +
        "Von Ihnen hochgeladene Dateien (z. B. Arztbriefe, OP-Berichte, " +
        "Wunddokumentation) werden in Firebase Cloud Storage " +
        "gespeichert.\n\n" +
        "d) Termine und Aufgaben\n" +
        "Arzttermine, Checklisten und Timeline-Fortschritt werden in " +
        "Cloud Firestore gespeichert, um Ihren Genesungsplan " +
        "abzubilden.\n\n" +
        "e) Werbung\n" +
        "Wenn Werbung in der App aktiviert ist, werden Werbebanner " +
        "für Nutzer ohne aktives Pro-Abonnement geladen. Nutzer mit " +
        "aktivem Pro-Abonnement sehen keine Werbung.\n\n" +
        "f) Geräte- und Nutzungsdaten\n" +
        "Push-Token (Firebase Cloud Messaging) zur Zustellung von " +
        "Erinnerungen. Im Dev/Test-Stand werden keine Werbe-IDs " +
        "für Profilbildung gespeichert.",
    },
    {
      title: "3. Rechtsgrundlagen der Verarbeitung",
      body:
        "• Art. 6 Abs. 1 lit. a DSGVO — Einwilligung " +
        "(Gesundheitsdaten, Push-Benachrichtigungen)\n" +
        "• Art. 6 Abs. 1 lit. b DSGVO — Vertragserfüllung " +
        "(Nutzerkonto, Pro-Abonnement, werbefreie Nutzung mit Pro)\n" +
        "• Art. 6 Abs. 1 lit. f DSGVO — Berechtigtes Interesse " +
        "(Fehlerbehebung, Sicherheit)",
    },
    {
      title: "4. Auftragsverarbeiter und Drittlandtransfer",
      body:
        "Wir nutzen Dienste von Google Ireland Limited " +
        "(Gordon House, Barrow Street, Dublin 4, Irland) als " +
        "Auftragsverarbeiter:\n\n" +
        "• Firebase Authentication — Kontoverwaltung\n" +
        "• Cloud Firestore — Datenspeicherung\n" +
        "• Firebase Cloud Storage — Dateispeicherung\n" +
        "• Firebase Cloud Messaging — Push-Benachrichtigungen\n\n" +
        "Daten können auf Servern innerhalb der EU/des EWR oder in " +
        "den USA verarbeitet werden. Der Transfer in die USA erfolgt " +
        "auf Grundlage des EU-US Data Privacy Framework (Angemessenheitsbeschluss " +
        "der EU-Kommission) bzw. der Standardvertragsklauseln " +
        "(Art. 46 Abs. 2 lit. c DSGVO).",
    },
    {
      title: "5. Speicherdauer",
      body:
        "Ihre Daten werden gespeichert, solange Ihr Nutzerkonto " +
        "besteht. Nach Löschung des Kontos werden alle " +
        "personenbezogenen Daten innerhalb von 30 Tagen aus unseren " +
        "Systemen entfernt, sofern keine gesetzlichen " +
        "Aufbewahrungspflichten entgegenstehen.",
    },
    {
      title: "6. Ihre Rechte",
      body:
        "Sie haben jederzeit das Recht auf:\n\n" +
        "• Auskunft über Ihre gespeicherten Daten (Art. 15 DSGVO)\n" +
        "• Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n" +
        "• Löschung Ihrer Daten (Art. 17 DSGVO)\n" +
        "• Einschränkung der Verarbeitung (Art. 18 DSGVO)\n" +
        "• Datenübertragbarkeit (Art. 20 DSGVO)\n" +
        "• Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)\n" +
        "• Widerruf einer erteilten Einwilligung mit Wirkung für " +
        "die Zukunft (Art. 7 Abs. 3 DSGVO)\n\n" +
        "Richten Sie Ihre Anfrage an: [E-MAIL-ADRESSE]",
    },
    {
      title: "7. Beschwerderecht",
      body:
        "Sie haben das Recht, sich bei einer " +
        "Datenschutzaufsichtsbehörde über die Verarbeitung Ihrer " +
        "personenbezogenen Daten zu beschweren (Art. 77 DSGVO).\n\n" +
        "Zuständige Aufsichtsbehörde:\n" +
        "[NAME DER ZUSTÄNDIGEN LANDESBEHÖRDE]\n" +
        "[ADRESSE DER AUFSICHTSBEHÖRDE]",
    },
    {
      title: "8. Datensicherheit",
      body:
        "Die Kommunikation zwischen der App und den Servern " +
        "erfolgt ausschließlich über verschlüsselte Verbindungen " +
        "(TLS/SSL). Der Zugriff auf Ihre Daten in Cloud Firestore " +
        "und Cloud Storage ist durch Firebase Security Rules auf " +
        "Ihr Nutzerkonto beschränkt.",
    },
    {
      title: "9. Änderungen dieser Datenschutzerklärung",
      body:
        "Wir behalten uns vor, diese Datenschutzerklärung " +
        "anzupassen, um sie an geänderte Rechtslagen oder " +
        "Änderungen der App anzupassen. Die aktuelle Fassung " +
        "ist stets in der App unter Einstellungen → Datenschutz " +
        "abrufbar.\n\n" +
        "Stand: [DATUM EINFÜGEN]",
    },
  ],
};

const terms = {
  sections: [
    {
      title: "1. Geltungsbereich",
      body:
        "Diese Allgemeinen Geschäftsbedingungen (AGB) gelten für " +
        "die Nutzung der mobilen Anwendung \"Operationsbegleiter\" " +
        "(nachfolgend \"App\"), bereitgestellt von:\n\n" +
        "[FIRMENNAME]\n" +
        "[STRAßE UND HAUSNUMMER]\n" +
        "[PLZ ORT]\n\n" +
        "Mit der Registrierung und Nutzung der App erkennen Sie " +
        "diese AGB an.",
    },
    {
      title: "2. Leistungsbeschreibung",
      body:
        "Die App unterstützt Patientinnen und Patienten bei der " +
        "Vor- und Nachbereitung eines operativen Eingriffs. " +
        "Funktionen umfassen u. a.:\n\n" +
        "• Genesungs-Timeline mit Aufgaben und Erinnerungen\n" +
        "• Schmerztagebuch und Vitalzeichen-Dokumentation\n" +
        "• Wunddokumentation mit Fotovergleich\n" +
        "• Medikamenten- und Terminverwaltung\n" +
        "• Dokumenten- und Foto-Upload\n" +
        "• Arztbericht-Zusammenfassung\n" +
        "• Sprachnotizen\n\n" +
        "Die App stellt keine medizinische Beratung dar und ersetzt " +
        "nicht die ärztliche Konsultation. Alle Gesundheitsinformationen " +
        "dienen ausschließlich der persönlichen Dokumentation.",
    },
    {
      title: "3. Nutzerkonto und Registrierung",
      body:
        "Zur Nutzung der App ist die Erstellung eines " +
        "Nutzerkontos mit einer gültigen E-Mail-Adresse " +
        "erforderlich. Sie sind verpflichtet, Ihre Zugangsdaten " +
        "vertraulich zu behandeln und uns über eine unbefugte " +
        "Nutzung unverzüglich zu informieren.\n\n" +
        "Sie können Ihr Konto jederzeit über die Einstellungen " +
        "der App löschen. Mit der Löschung werden alle " +
        "gespeicherten Daten gemäß unserer Datenschutzerklärung " +
        "entfernt.",
    },
    {
      title: "4. Pro-Abonnement und In-App-Käufe",
      body:
        "Die App bietet eine kostenlose Basisversion sowie ein " +
        "kostenpflichtiges Pro-Abonnement mit erweiterten " +
        "Funktionen (z. B. Gamification, Warnsystem, erweiterte " +
        "Analysen).\n\n" +
        "a) Abschluss\n" +
        "Das Pro-Abonnement wird über den jeweiligen App Store " +
        "(Apple App Store / Google Play Store) abgeschlossen. " +
        "Es gelten die Zahlungsbedingungen des Stores.\n\n" +
        "b) Laufzeit und Verlängerung\n" +
        "Das Abonnement verlängert sich automatisch um die " +
        "gewählte Laufzeit, sofern es nicht mindestens 24 Stunden " +
        "vor Ablauf der aktuellen Periode gekündigt wird.\n\n" +
        "c) Kündigung\n" +
        "Die Kündigung erfolgt über die Abo-Verwaltung des " +
        "jeweiligen App Stores. Eine Kündigung in der App selbst " +
        "ist nicht möglich.\n\n" +
        "d) Einlöse-Codes\n" +
        "Pro-Zugänge können auch über Einlöse-Codes (Redeem Keys) " +
        "freigeschaltet werden. Diese sind nicht übertragbar und " +
        "nur einmal einlösbar.",
    },
    {
      title: "5. Pflichten der Nutzer",
      body:
        "Sie verpflichten sich:\n\n" +
        "• Die App nur für den bestimmungsgemäßen Zweck zu nutzen\n" +
        "• Keine falschen oder irreführenden Angaben zu machen\n" +
        "• Keine rechtswidrigen Inhalte hochzuladen\n" +
        "• Die App nicht zu dekompilieren, zurückzuentwickeln oder " +
        "in anderer Weise zu manipulieren",
    },
    {
      title: "6. Haftungsbeschränkung",
      body:
        "a) Bei kostenloser Nutzung haften wir nur für Vorsatz " +
        "und grobe Fahrlässigkeit.\n\n" +
        "b) Bei kostenpflichtiger Nutzung (Pro) haften wir " +
        "zusätzlich für die Verletzung wesentlicher " +
        "Vertragspflichten (Kardinalpflichten), begrenzt auf den " +
        "vorhersehbaren, vertragstypischen Schaden.\n\n" +
        "c) Die App ersetzt keine ärztliche Diagnose oder " +
        "Behandlung. Für gesundheitliche Entscheidungen auf " +
        "Grundlage der App-Inhalte übernehmen wir keine Haftung.\n\n" +
        "d) Die vorstehenden Haftungsbeschränkungen gelten nicht " +
        "für Schäden aus der Verletzung des Lebens, des Körpers " +
        "oder der Gesundheit.",
    },
    {
      title: "7. Verfügbarkeit",
      body:
        "Wir bemühen uns um eine hohe Verfügbarkeit der App, " +
        "garantieren jedoch keine ununterbrochene Erreichbarkeit. " +
        "Wartungsarbeiten, Updates und höhere Gewalt können zu " +
        "vorübergehenden Einschränkungen führen.",
    },
    {
      title: "8. Änderungen dieser AGB",
      body:
        "Wir behalten uns vor, diese AGB mit Wirkung für die " +
        "Zukunft zu ändern. Über wesentliche Änderungen werden " +
        "Sie per E-Mail oder In-App-Benachrichtigung informiert. " +
        "Widersprechen Sie den Änderungen nicht innerhalb von " +
        "30 Tagen nach Benachrichtigung, gelten die neuen AGB " +
        "als akzeptiert.",
    },
    {
      title: "9. Schlussbestimmungen",
      body:
        "a) Es gilt das Recht der Bundesrepublik Deutschland " +
        "unter Ausschluss des UN-Kaufrechts.\n\n" +
        "b) Gerichtsstand für alle Streitigkeiten aus oder im " +
        "Zusammenhang mit diesen AGB ist, soweit gesetzlich " +
        "zulässig, [ORT DES FIRMENSITZES].\n\n" +
        "c) Sollten einzelne Bestimmungen dieser AGB unwirksam " +
        "sein oder werden, bleibt die Wirksamkeit der übrigen " +
        "Bestimmungen unberührt.\n\n" +
        "Stand: [DATUM EINFÜGEN]",
    },
  ],
};

const imprint = {
  sections: [
    {
      title: "Angaben gemäß § 5 TMG",
      body:
        "[FIRMENNAME]\n" +
        "[RECHTSFORM, z. B. GmbH, UG (haftungsbeschränkt)]\n" +
        "[STRAßE UND HAUSNUMMER]\n" +
        "[PLZ ORT]\n" +
        "Deutschland",
    },
    {
      title: "Vertreten durch",
      body: "[VORNAME NACHNAME], Geschäftsführer/in",
    },
    {
      title: "Kontakt",
      body: "E-Mail: [E-MAIL-ADRESSE]\nTelefon: [TELEFONNUMMER]",
    },
    {
      title: "Registereintrag",
      body:
        "Eingetragen im Handelsregister.\n" +
        "Registergericht: [AMTSGERICHT]\n" +
        "Registernummer: [HRB-NUMMER]",
    },
    {
      title: "Umsatzsteuer-ID",
      body:
        "Umsatzsteuer-Identifikationsnummer gemäß § 27a UStG:\n" +
        "[DE XXXXXXXXX]",
    },
    {
      title: "Verantwortlich für den Inhalt nach § 18 Abs. 2 MStV",
      body:
        "[VORNAME NACHNAME]\n" +
        "[STRAßE UND HAUSNUMMER]\n" +
        "[PLZ ORT]",
    },
    {
      title: "Haftungshinweis",
      body:
        "Die Inhalte dieser App wurden mit größter Sorgfalt erstellt. " +
        "Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte " +
        "übernehmen wir jedoch keine Gewähr. Die App stellt keine " +
        "medizinische Beratung dar und ersetzt nicht die Konsultation " +
        "eines Arztes oder einer Ärztin.\n\n" +
        "Trotz sorgfältiger inhaltlicher Kontrolle übernehmen wir keine " +
        "Haftung für die Inhalte externer Links. Für den Inhalt der " +
        "verlinkten Seiten sind ausschließlich deren Betreiber " +
        "verantwortlich.",
    },
    {
      title: "Streitbeilegung",
      body:
        "Die Europäische Kommission stellt eine Plattform zur " +
        "Online-Streitbeilegung (OS) bereit: " +
        "https://ec.europa.eu/consumers/odr\n\n" +
        "Wir sind nicht bereit oder verpflichtet, an " +
        "Streitbeilegungsverfahren vor einer " +
        "Verbraucherschlichtungsstelle teilzunehmen.",
    },
  ],
};

async function main() {
  const batch = db.batch();
  batch.set(db.collection("legal").doc("privacy"), privacy);
  batch.set(db.collection("legal").doc("terms"), terms);
  batch.set(db.collection("legal").doc("imprint"), imprint);
  await batch.commit();
  console.log("✅ Dokumente legal/privacy, legal/terms, legal/imprint angelegt.");
}

main().catch((err) => {
  console.error("❌ Fehler:", err);
  process.exit(1);
});
