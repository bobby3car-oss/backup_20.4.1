#!/usr/bin/env python3
"""Seed legal documents into Firestore using Firebase CLI's stored credentials."""
import json
import urllib.request
import urllib.error

CONFIG_PATH = "/Users/jan/.config/configstore/firebase-tools.json"
PROJECT_ID = "operationsbegleiter-860e7"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def get_access_token():
    with open(CONFIG_PATH) as f:
        config = json.load(f)
    tokens = config["tokens"]
    # Try using the stored access token first; if expired, refresh it
    refresh_token = tokens["refresh_token"]
    # Refresh the token
    # Firebase CLI uses its own OAuth client ID
    data = urllib.parse.urlencode({
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
        "client_id": "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com",
        "client_secret": "j9iVZfS8kkCEFUPaAeJV0sAi",
    }).encode()
    req = urllib.request.Request("https://oauth2.googleapis.com/token", data=data)
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())["access_token"]

def to_firestore_value(val):
    if isinstance(val, str):
        return {"stringValue": val}
    if isinstance(val, list):
        return {"arrayValue": {"values": [to_firestore_value(v) for v in val]}}
    if isinstance(val, dict):
        return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in val.items()}}}
    return {"stringValue": str(val)}

def create_document(token, collection, doc_id, data):
    url = f"{BASE_URL}/{collection}/{doc_id}"
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    body = json.dumps({"fields": fields}).encode()
    req = urllib.request.Request(url, data=body, method="PATCH")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"  \u2705 legal/{doc_id} erstellt")
    except urllib.error.HTTPError as e:
        print(f"  \u274c legal/{doc_id} fehlgeschlagen: {e.code} {e.read().decode()[:200]}")

# ── Data ──────────────────────────────────────────────────────────────

privacy = {"sections": [
    {"title": "1. Verantwortlicher", "body": "Verantwortlich im Sinne der Datenschutz-Grundverordnung (DSGVO) ist:\n\n[FIRMENNAME]\n[STRAßE UND HAUSNUMMER]\n[PLZ ORT]\nE-Mail: [E-MAIL-ADRESSE]"},
    {"title": "2. Erhobene Daten und Zweck der Verarbeitung", "body": "Wir verarbeiten folgende personenbezogene Daten:\n\na) Kontodaten\nE-Mail-Adresse und Passwort zur Authentifizierung \u00fcber Firebase Authentication (Art. 6 Abs. 1 lit. b DSGVO \u2014 Vertragserf\u00fcllung).\n\nb) Gesundheitsdaten\nSchmerzwerte, Vitalzeichen (Blutdruck, Puls, Temperatur), Medikamente, Wundfotos, Symptom-Einsch\u00e4tzungen und Sprachnotizen. Diese Daten werden ausschlie\u00dflich auf Ihre Eingabe hin gespeichert und dienen der Dokumentation Ihres Genesungsverlaufs (Art. 9 Abs. 2 lit. a DSGVO \u2014 ausdr\u00fcckliche Einwilligung).\n\nc) Dokumente und Fotos\nVon Ihnen hochgeladene Dateien (z. B. Arztbriefe, OP-Berichte, Wunddokumentation) werden in Firebase Cloud Storage gespeichert.\n\nd) Termine und Aufgaben\nArzttermine, Checklisten und Timeline-Fortschritt werden in Cloud Firestore gespeichert, um Ihren Genesungsplan abzubilden.\n\ne) Werbung\nWenn Werbung in der App aktiviert ist, werden Werbebanner f\u00fcr Nutzer ohne aktives Pro-Abonnement geladen. Nutzer mit aktivem Pro-Abonnement sehen keine Werbung.\n\nf) Ger\u00e4te- und Nutzungsdaten\nPush-Token (Firebase Cloud Messaging) zur Zustellung von Erinnerungen. Im Dev/Test-Stand werden keine Werbe-IDs f\u00fcr Profilbildung gespeichert."},
    {"title": "3. Rechtsgrundlagen der Verarbeitung", "body": "\u2022 Art. 6 Abs. 1 lit. a DSGVO \u2014 Einwilligung (Gesundheitsdaten, Push-Benachrichtigungen)\n\u2022 Art. 6 Abs. 1 lit. b DSGVO \u2014 Vertragserf\u00fcllung (Nutzerkonto, Pro-Abonnement, werbefreie Nutzung mit Pro)\n\u2022 Art. 6 Abs. 1 lit. f DSGVO \u2014 Berechtigtes Interesse (Fehlerbehebung, Sicherheit)"},
    {"title": "4. Auftragsverarbeiter und Drittlandtransfer", "body": "Wir nutzen Dienste von Google Ireland Limited (Gordon House, Barrow Street, Dublin 4, Irland) als Auftragsverarbeiter:\n\n\u2022 Firebase Authentication \u2014 Kontoverwaltung\n\u2022 Cloud Firestore \u2014 Datenspeicherung\n\u2022 Firebase Cloud Storage \u2014 Dateispeicherung\n\u2022 Firebase Cloud Messaging \u2014 Push-Benachrichtigungen\n\nDaten k\u00f6nnen auf Servern innerhalb der EU/des EWR oder in den USA verarbeitet werden. Der Transfer in die USA erfolgt auf Grundlage des EU-US Data Privacy Framework (Angemessenheitsbeschluss der EU-Kommission) bzw. der Standardvertragsklauseln (Art. 46 Abs. 2 lit. c DSGVO)."},
    {"title": "5. Speicherdauer", "body": "Ihre Daten werden gespeichert, solange Ihr Nutzerkonto besteht. Nach L\u00f6schung des Kontos werden alle personenbezogenen Daten innerhalb von 30 Tagen aus unseren Systemen entfernt, sofern keine gesetzlichen Aufbewahrungspflichten entgegenstehen."},
    {"title": "6. Ihre Rechte", "body": "Sie haben jederzeit das Recht auf:\n\n\u2022 Auskunft \u00fcber Ihre gespeicherten Daten (Art. 15 DSGVO)\n\u2022 Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n\u2022 L\u00f6schung Ihrer Daten (Art. 17 DSGVO)\n\u2022 Einschr\u00e4nkung der Verarbeitung (Art. 18 DSGVO)\n\u2022 Daten\u00fcbertragbarkeit (Art. 20 DSGVO)\n\u2022 Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)\n\u2022 Widerruf einer erteilten Einwilligung mit Wirkung f\u00fcr die Zukunft (Art. 7 Abs. 3 DSGVO)\n\nRichten Sie Ihre Anfrage an: [E-MAIL-ADRESSE]"},
    {"title": "7. Beschwerderecht", "body": "Sie haben das Recht, sich bei einer Datenschutzaufsichtsbeh\u00f6rde \u00fcber die Verarbeitung Ihrer personenbezogenen Daten zu beschweren (Art. 77 DSGVO).\n\nZust\u00e4ndige Aufsichtsbeh\u00f6rde:\n[NAME DER ZUST\u00c4NDIGEN LANDESBEH\u00d6RDE]\n[ADRESSE DER AUFSICHTSBEH\u00d6RDE]"},
    {"title": "8. Datensicherheit", "body": "Die Kommunikation zwischen der App und den Servern erfolgt ausschlie\u00dflich \u00fcber verschl\u00fcsselte Verbindungen (TLS/SSL). Der Zugriff auf Ihre Daten in Cloud Firestore und Cloud Storage ist durch Firebase Security Rules auf Ihr Nutzerkonto beschr\u00e4nkt."},
    {"title": "9. \u00c4nderungen dieser Datenschutzerkl\u00e4rung", "body": "Wir behalten uns vor, diese Datenschutzerkl\u00e4rung anzupassen, um sie an ge\u00e4nderte Rechtslagen oder \u00c4nderungen der App anzupassen. Die aktuelle Fassung ist stets in der App unter Einstellungen \u2192 Datenschutz abrufbar.\n\nStand: [DATUM EINF\u00dcGEN]"},
]}

terms = {"sections": [
    {"title": "1. Geltungsbereich", "body": "Diese Allgemeinen Gesch\u00e4ftsbedingungen (AGB) gelten f\u00fcr die Nutzung der mobilen Anwendung \u201eOperationsbegleiter\u201c (nachfolgend \u201eApp\u201c), bereitgestellt von:\n\n[FIRMENNAME]\n[STRAßE UND HAUSNUMMER]\n[PLZ ORT]\n\nMit der Registrierung und Nutzung der App erkennen Sie diese AGB an."},
    {"title": "2. Leistungsbeschreibung", "body": "Die App unterst\u00fctzt Patientinnen und Patienten bei der Vor- und Nachbereitung eines operativen Eingriffs. Funktionen umfassen u. a.:\n\n\u2022 Genesungs-Timeline mit Aufgaben und Erinnerungen\n\u2022 Schmerztagebuch und Vitalzeichen-Dokumentation\n\u2022 Wunddokumentation mit Fotovergleich\n\u2022 Medikamenten- und Terminverwaltung\n\u2022 Dokumenten- und Foto-Upload\n\u2022 Arztbericht-Zusammenfassung\n\u2022 Sprachnotizen\n\nDie App stellt keine medizinische Beratung dar und ersetzt nicht die \u00e4rztliche Konsultation. Alle Gesundheitsinformationen dienen ausschlie\u00dflich der pers\u00f6nlichen Dokumentation."},
    {"title": "3. Nutzerkonto und Registrierung", "body": "Zur Nutzung der App ist die Erstellung eines Nutzerkontos mit einer g\u00fcltigen E-Mail-Adresse erforderlich. Sie sind verpflichtet, Ihre Zugangsdaten vertraulich zu behandeln und uns \u00fcber eine unbefugte Nutzung unverz\u00fcglich zu informieren.\n\nSie k\u00f6nnen Ihr Konto jederzeit \u00fcber die Einstellungen der App l\u00f6schen. Mit der L\u00f6schung werden alle gespeicherten Daten gem\u00e4\u00df unserer Datenschutzerkl\u00e4rung entfernt."},
    {"title": "4. Pro-Abonnement und In-App-K\u00e4ufe", "body": "Die App bietet eine kostenlose Basisversion sowie ein kostenpflichtiges Pro-Abonnement mit erweiterten Funktionen (z. B. Gamification, Warnsystem, erweiterte Analysen).\n\na) Abschluss\nDas Pro-Abonnement wird \u00fcber den jeweiligen App Store (Apple App Store / Google Play Store) abgeschlossen. Es gelten die Zahlungsbedingungen des Stores.\n\nb) Laufzeit und Verl\u00e4ngerung\nDas Abonnement verl\u00e4ngert sich automatisch um die gew\u00e4hlte Laufzeit, sofern es nicht mindestens 24 Stunden vor Ablauf der aktuellen Periode gek\u00fcndigt wird.\n\nc) K\u00fcndigung\nDie K\u00fcndigung erfolgt \u00fcber die Abo-Verwaltung des jeweiligen App Stores. Eine K\u00fcndigung in der App selbst ist nicht m\u00f6glich.\n\nd) Einl\u00f6se-Codes\nPro-Zug\u00e4nge k\u00f6nnen auch \u00fcber Einl\u00f6se-Codes (Redeem Keys) freigeschaltet werden. Diese sind nicht \u00fcbertragbar und nur einmal einl\u00f6sbar."},
    {"title": "5. Pflichten der Nutzer", "body": "Sie verpflichten sich:\n\n\u2022 Die App nur f\u00fcr den bestimmungsgem\u00e4\u00dfen Zweck zu nutzen\n\u2022 Keine falschen oder irref\u00fchrenden Angaben zu machen\n\u2022 Keine rechtswidrigen Inhalte hochzuladen\n\u2022 Die App nicht zu dekompilieren, zur\u00fcckzuentwickeln oder in anderer Weise zu manipulieren"},
    {"title": "6. Haftungsbeschr\u00e4nkung", "body": "a) Bei kostenloser Nutzung haften wir nur f\u00fcr Vorsatz und grobe Fahrl\u00e4ssigkeit.\n\nb) Bei kostenpflichtiger Nutzung (Pro) haften wir zus\u00e4tzlich f\u00fcr die Verletzung wesentlicher Vertragspflichten (Kardinalpflichten), begrenzt auf den vorhersehbaren, vertragstypischen Schaden.\n\nc) Die App ersetzt keine \u00e4rztliche Diagnose oder Behandlung. F\u00fcr gesundheitliche Entscheidungen auf Grundlage der App-Inhalte \u00fcbernehmen wir keine Haftung.\n\nd) Die vorstehenden Haftungsbeschr\u00e4nkungen gelten nicht f\u00fcr Sch\u00e4den aus der Verletzung des Lebens, des K\u00f6rpers oder der Gesundheit."},
    {"title": "7. Verf\u00fcgbarkeit", "body": "Wir bem\u00fchen uns um eine hohe Verf\u00fcgbarkeit der App, garantieren jedoch keine ununterbrochene Erreichbarkeit. Wartungsarbeiten, Updates und h\u00f6here Gewalt k\u00f6nnen zu vor\u00fcbergehenden Einschr\u00e4nkungen f\u00fchren."},
    {"title": "8. \u00c4nderungen dieser AGB", "body": "Wir behalten uns vor, diese AGB mit Wirkung f\u00fcr die Zukunft zu \u00e4ndern. \u00dcber wesentliche \u00c4nderungen werden Sie per E-Mail oder In-App-Benachrichtigung informiert. Widersprechen Sie den \u00c4nderungen nicht innerhalb von 30 Tagen nach Benachrichtigung, gelten die neuen AGB als akzeptiert."},
    {"title": "9. Schlussbestimmungen", "body": "a) Es gilt das Recht der Bundesrepublik Deutschland unter Ausschluss des UN-Kaufrechts.\n\nb) Gerichtsstand f\u00fcr alle Streitigkeiten aus oder im Zusammenhang mit diesen AGB ist, soweit gesetzlich zul\u00e4ssig, [ORT DES FIRMENSITZES].\n\nc) Sollten einzelne Bestimmungen dieser AGB unwirksam sein oder werden, bleibt die Wirksamkeit der \u00fcbrigen Bestimmungen unber\u00fchrt.\n\nStand: [DATUM EINF\u00dcGEN]"},
]}

imprint = {"sections": [
    {"title": "Angaben gem\u00e4\u00df \u00a7 5 TMG", "body": "[FIRMENNAME]\n[RECHTSFORM, z. B. GmbH, UG (haftungsbeschr\u00e4nkt)]\n[STRAßE UND HAUSNUMMER]\n[PLZ ORT]\nDeutschland"},
    {"title": "Vertreten durch", "body": "[VORNAME NACHNAME], Gesch\u00e4ftsf\u00fchrer/in"},
    {"title": "Kontakt", "body": "E-Mail: [E-MAIL-ADRESSE]\nTelefon: [TELEFONNUMMER]"},
    {"title": "Registereintrag", "body": "Eingetragen im Handelsregister.\nRegistergericht: [AMTSGERICHT]\nRegisternummer: [HRB-NUMMER]"},
    {"title": "Umsatzsteuer-ID", "body": "Umsatzsteuer-Identifikationsnummer gem\u00e4\u00df \u00a7 27a UStG:\n[DE XXXXXXXXX]"},
    {"title": "Verantwortlich f\u00fcr den Inhalt nach \u00a7 18 Abs. 2 MStV", "body": "[VORNAME NACHNAME]\n[STRAßE UND HAUSNUMMER]\n[PLZ ORT]"},
    {"title": "Haftungshinweis", "body": "Die Inhalte dieser App wurden mit gr\u00f6\u00dfter Sorgfalt erstellt. F\u00fcr die Richtigkeit, Vollst\u00e4ndigkeit und Aktualit\u00e4t der Inhalte \u00fcbernehmen wir jedoch keine Gew\u00e4hr. Die App stellt keine medizinische Beratung dar und ersetzt nicht die Konsultation eines Arztes oder einer \u00c4rztin.\n\nTrotz sorgf\u00e4ltiger inhaltlicher Kontrolle \u00fcbernehmen wir keine Haftung f\u00fcr die Inhalte externer Links. F\u00fcr den Inhalt der verlinkten Seiten sind ausschlie\u00dflich deren Betreiber verantwortlich."},
    {"title": "Streitbeilegung", "body": "Die Europ\u00e4ische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit: https://ec.europa.eu/consumers/odr\n\nWir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen."},
]}

def main():
    print("Hole Access Token...")
    token = get_access_token()
    print("Token erhalten. Erstelle Dokumente...\n")
    
    import urllib.parse  # already imported at top
    
    for doc_id, data in [("privacy", privacy), ("terms", terms), ("imprint", imprint)]:
        create_document(token, "legal", doc_id, data)
    
    print("\nFertig!")

if __name__ == "__main__":
    main()
