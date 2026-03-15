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
    {"title": "1. Verantwortlicher", "body": "Verantwortlich im Sinne der Datenschutz-Grundverordnung (DSGVO) ist:\n\nJan Goede\nHalmweg 15b\n31228 Peine\nDeutschland\n\nE-Mail: operationsbegleiter@gmail.com"},
    {"title": "2. Erhobene Daten und Zweck der Verarbeitung", "body": "Im Rahmen der Nutzung der App \u201eOperationsbegleiter\u201c (nachfolgend \u201eApp\u201c) werden folgende personenbezogene Daten verarbeitet:\n\na) Kontodaten\nE-Mail-Adresse und Passwort zur Authentifizierung \u00fcber Firebase Authentication (Art. 6 Abs. 1 lit. b DSGVO \u2014 Vertragserf\u00fcllung).\n\nb) Gesundheitsbezogene Daten (Art. 9 DSGVO)\nSchmerzwerte, Vitalzeichen (Blutdruck, Puls, Temperatur), Medikamente, Wundfotos, Symptom-Einsch\u00e4tzungen und Sprachnotizen. Diese Daten werden ausschlie\u00dflich auf Ihre aktive Eingabe hin gespeichert und dienen allein der pers\u00f6nlichen Dokumentation Ihres Genesungsverlaufs (Art. 9 Abs. 2 lit. a DSGVO \u2014 ausdr\u00fcckliche Einwilligung). Eine medizinische Auswertung oder Diagnose findet ausdr\u00fccklich nicht statt.\n\nc) Dokumente und Fotos\nVon Ihnen hochgeladene Dateien (z. B. Arztbriefe, OP-Berichte, Wunddokumentation) werden in Firebase Cloud Storage gespeichert.\n\nd) Termine und Aufgaben\nArzttermine, Checklisten und Timeline-Fortschritt werden in Cloud Firestore gespeichert, um Ihren pers\u00f6nlichen Genesungsplan abzubilden.\n\ne) Werbung\nWenn Werbung in der App aktiviert ist, werden Werbebanner \u00fcber Google AdMob f\u00fcr Nutzer ohne aktives Pro-Abonnement angezeigt. Nutzer mit aktivem Pro-Abonnement sehen keine Werbung. Google AdMob kann dabei Ger\u00e4te-IDs und Nutzungsdaten gem\u00e4\u00df der Google-Datenschutzrichtlinie verarbeiten.\n\nf) Ger\u00e4te- und Nutzungsdaten\nPush-Token (Firebase Cloud Messaging) zur Zustellung von Erinnerungen.\n\ng) KI-Assistent (Bella AI)\nWenn Sie den KI-Assistenten nutzen, werden Ihre Chat-Nachrichten an einen externen KI-Dienst (NVIDIA Corporation) \u00fcbermittelt, um eine Antwort zu generieren. Es werden ausschlie\u00dflich die von Ihnen eingegebenen Nachrichten und der Gespr\u00e4chsverlauf \u00fcbertragen \u2014 keine weiteren personenbezogenen Daten. Die Nutzung erfolgt auf Grundlage Ihrer Einwilligung (Art. 6 Abs. 1 lit. a, Art. 9 Abs. 2 lit. a DSGVO). Sie k\u00f6nnen den KI-Assistenten jederzeit nicht nutzen, um die Daten\u00fcbermittlung zu vermeiden.\n\nh) Analyse- und Absturzdaten\nFirebase Analytics erfasst anonymisierte Nutzungsstatistiken zur Verbesserung der App. Firebase Crashlytics protokolliert Absturzberichte zur Fehlerbehebung. Beide Dienste k\u00f6nnen in den Einstellungen deaktiviert werden (Art. 6 Abs. 1 lit. a DSGVO \u2014 Einwilligung)."},
    {"title": "3. Rechtsgrundlagen der Verarbeitung", "body": "\u2022 Art. 6 Abs. 1 lit. a DSGVO \u2014 Einwilligung (Gesundheitsdaten, Push-Benachrichtigungen, personalisierte Werbung)\n\u2022 Art. 6 Abs. 1 lit. b DSGVO \u2014 Vertragserf\u00fcllung (Nutzerkonto, Pro-Abonnement, werbefreie Nutzung mit Pro)\n\u2022 Art. 6 Abs. 1 lit. f DSGVO \u2014 Berechtigtes Interesse (Fehlerbehebung, App-Sicherheit, Missbrauchspr\u00e4vention)"},
    {"title": "4. Auftragsverarbeiter und Drittlandtransfer", "body": "Zur Erbringung der App-Funktionen werden Dienste von Google Ireland Limited (Gordon House, Barrow Street, Dublin 4, Irland) als Auftragsverarbeiter genutzt:\n\n\u2022 Firebase Authentication \u2014 Kontoverwaltung\n\u2022 Cloud Firestore \u2014 Datenspeicherung\n\u2022 Firebase Cloud Storage \u2014 Dateispeicherung\n\u2022 Firebase Cloud Messaging \u2014 Push-Benachrichtigungen\n\u2022 Google AdMob \u2014 Werbeanzeigen (nur Basis-Version)\n\u2022 Firebase Analytics \u2014 anonymisierte Nutzungsstatistiken\n\u2022 Firebase Crashlytics \u2014 Absturzberichte\n\nF\u00fcr den KI-Assistenten (Bella AI) wird zus\u00e4tzlich ein Dienst der NVIDIA Corporation (2788 San Tomas Expressway, Santa Clara, CA 95051, USA) als Auftragsverarbeiter genutzt. Die \u00dcbermittlung Ihrer Chat-Nachrichten an NVIDIA erfolgt ausschlie\u00dflich zur Generierung von KI-Antworten.\n\nDaten k\u00f6nnen auf Servern innerhalb der EU/des EWR oder in den USA verarbeitet werden. Der Transfer in die USA erfolgt auf Grundlage des EU-US Data Privacy Framework (Angemessenheitsbeschluss der EU-Kommission vom 10.07.2023) bzw. der Standardvertragsklauseln (Art. 46 Abs. 2 lit. c DSGVO)."},
    {"title": "5. Speicherdauer", "body": "Ihre Daten werden gespeichert, solange Ihr Nutzerkonto besteht. Nach L\u00f6schung des Kontos werden alle personenbezogenen Daten innerhalb von 30 Tagen aus den Systemen entfernt, sofern keine gesetzlichen Aufbewahrungspflichten (z. B. steuerrechtlich) entgegenstehen."},
    {"title": "6. Ihre Rechte", "body": "Sie haben jederzeit das Recht auf:\n\n\u2022 Auskunft \u00fcber Ihre gespeicherten Daten (Art. 15 DSGVO)\n\u2022 Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n\u2022 L\u00f6schung Ihrer Daten (Art. 17 DSGVO)\n\u2022 Einschr\u00e4nkung der Verarbeitung (Art. 18 DSGVO)\n\u2022 Daten\u00fcbertragbarkeit (Art. 20 DSGVO)\n\u2022 Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)\n\u2022 Widerruf einer erteilten Einwilligung mit Wirkung f\u00fcr die Zukunft (Art. 7 Abs. 3 DSGVO)\n\nRichten Sie Ihre Anfrage an: operationsbegleiter@gmail.com"},
    {"title": "7. Beschwerderecht", "body": "Sie haben das Recht, sich bei einer Datenschutzaufsichtsbeh\u00f6rde \u00fcber die Verarbeitung Ihrer personenbezogenen Daten zu beschweren (Art. 77 DSGVO).\n\nZust\u00e4ndige Aufsichtsbeh\u00f6rde:\nDie Landesbeauftragte f\u00fcr den Datenschutz Niedersachsen\nPrinzenstra\u00dfe 5\n30159 Hannover\nhttps://www.lfd.niedersachsen.de"},
    {"title": "8. Datensicherheit", "body": "Die Kommunikation zwischen der App und den Servern erfolgt ausschlie\u00dflich \u00fcber verschl\u00fcsselte Verbindungen (TLS/SSL). Der Zugriff auf Ihre Daten in Cloud Firestore und Cloud Storage ist durch Firebase Security Rules auf Ihr Nutzerkonto beschr\u00e4nkt. Trotz angemessener technischer und organisatorischer Ma\u00dfnahmen kann keine absolute Sicherheit der Daten\u00fcbertragung und -speicherung im Internet garantiert werden."},
    {"title": "9. \u00c4nderungen dieser Datenschutzerkl\u00e4rung", "body": "Diese Datenschutzerkl\u00e4rung kann angepasst werden, um sie an ge\u00e4nderte Rechtslagen oder \u00c4nderungen der App anzupassen. Die aktuelle Fassung ist stets in der App unter Einstellungen \u2192 Datenschutz abrufbar.\n\nStand: 14. M\u00e4rz 2026"},
]}

terms = {"sections": [
    {"title": "1. Geltungsbereich", "body": "Diese Nutzungsbedingungen gelten f\u00fcr die Nutzung der mobilen Anwendung \u201eOperationsbegleiter\u201c (nachfolgend \u201eApp\u201c), bereitgestellt von:\n\nJan Goede\nHalmweg 15b\n31228 Peine\nDeutschland\n\nE-Mail: operationsbegleiter@gmail.com\n\nMit der Registrierung und Nutzung der App erkennen Sie diese Nutzungsbedingungen an."},
    {"title": "2. Leistungsbeschreibung und wichtiger Hinweis", "body": "Die App unterst\u00fctzt Patientinnen und Patienten bei der pers\u00f6nlichen Dokumentation rund um einen operativen Eingriff. Funktionen umfassen u. a.:\n\n\u2022 Genesungs-Timeline mit Aufgaben und Erinnerungen\n\u2022 Schmerztagebuch und Vitalzeichen-Dokumentation\n\u2022 Wunddokumentation mit Fotovergleich\n\u2022 Medikamenten- und Terminverwaltung\n\u2022 Dokumenten- und Foto-Upload\n\u2022 Arztbericht-Zusammenfassung\n\u2022 Sprachnotizen\n\nWICHTIGER HINWEIS: Die App stellt ausdr\u00fccklich keine medizinische Beratung, Diagnose oder Behandlung dar und ersetzt in keinem Fall die Konsultation eines Arztes, einer \u00c4rztin oder sonstiger medizinischer Fachkr\u00e4fte. Alle in der App dargestellten Gesundheitsinformationen dienen ausschlie\u00dflich der pers\u00f6nlichen Dokumentation des Nutzers. Gesundheitsbezogene Entscheidungen d\u00fcrfen niemals allein auf Grundlage der App-Inhalte getroffen werden."},
    {"title": "3. Nutzerkonto und Registrierung", "body": "Zur Nutzung der App ist die Erstellung eines Nutzerkontos mit einer g\u00fcltigen E-Mail-Adresse erforderlich. Sie sind verpflichtet, Ihre Zugangsdaten vertraulich zu behandeln und den Betreiber \u00fcber eine unbefugte Nutzung unverz\u00fcglich zu informieren. F\u00fcr Sch\u00e4den, die aus der Weitergabe Ihrer Zugangsdaten entstehen, wird keine Haftung \u00fcbernommen.\n\nSie k\u00f6nnen Ihr Konto jederzeit \u00fcber die Einstellungen der App l\u00f6schen. Mit der L\u00f6schung werden alle gespeicherten Daten gem\u00e4\u00df der Datenschutzerkl\u00e4rung entfernt."},
    {"title": "4. Pro-Abonnement und In-App-K\u00e4ufe", "body": "Die App bietet eine kostenlose Basisversion sowie ein kostenpflichtiges Pro-Abonnement mit erweiterten Funktionen (z. B. Gamification, Warnsystem, erweiterte Analysen).\n\na) Abschluss\nDas Pro-Abonnement wird \u00fcber den jeweiligen App Store (Apple App Store / Google Play Store) abgeschlossen. Es gelten die Zahlungsbedingungen des jeweiligen Stores.\n\nb) Laufzeit und Verl\u00e4ngerung\nDas Abonnement verl\u00e4ngert sich automatisch um die gew\u00e4hlte Laufzeit, sofern es nicht mindestens 24 Stunden vor Ablauf der aktuellen Periode gek\u00fcndigt wird.\n\nc) K\u00fcndigung\nDie K\u00fcndigung erfolgt ausschlie\u00dflich \u00fcber die Abo-Verwaltung des jeweiligen App Stores. Eine K\u00fcndigung in der App selbst ist nicht m\u00f6glich.\n\nd) Einl\u00f6se-Codes\nPro-Zug\u00e4nge k\u00f6nnen auch \u00fcber Einl\u00f6se-Codes (Redeem Keys) freigeschaltet werden. Diese sind nicht \u00fcbertragbar und nur einmal einl\u00f6sbar."},
    {"title": "5. Pflichten der Nutzer", "body": "Sie verpflichten sich:\n\n\u2022 Die App nur f\u00fcr den bestimmungsgem\u00e4\u00dfen Zweck zu nutzen\n\u2022 Keine falschen oder irref\u00fchrenden Angaben zu machen\n\u2022 Keine rechtswidrigen Inhalte hochzuladen\n\u2022 Die App nicht zu dekompilieren, zur\u00fcckzuentwickeln oder in anderer Weise zu manipulieren\n\u2022 Die App-Inhalte nicht als medizinischen Rat zu interpretieren oder als Grundlage f\u00fcr gesundheitsbezogene Entscheidungen zu verwenden"},
    {"title": "6. Haftungsbeschr\u00e4nkung", "body": "a) Die App wird \u201ewie besehen\u201c (as is) bereitgestellt. F\u00fcr die ununterbrochene, fehlerfreie oder sichere Bereitstellung der App wird keine Gew\u00e4hr \u00fcbernommen.\n\nb) Bei kostenloser Nutzung wird nur f\u00fcr Vorsatz und grobe Fahrl\u00e4ssigkeit gehaftet.\n\nc) Bei kostenpflichtiger Nutzung (Pro) wird zus\u00e4tzlich f\u00fcr die Verletzung wesentlicher Vertragspflichten (Kardinalpflichten) gehaftet, begrenzt auf den vorhersehbaren, vertragstypischen Schaden.\n\nd) Die App ersetzt ausdr\u00fccklich keine \u00e4rztliche Diagnose, Behandlung oder Beratung. F\u00fcr gesundheitliche Entscheidungen, die auf Grundlage der App-Inhalte getroffen werden, wird keinerlei Haftung \u00fcbernommen.\n\ne) F\u00fcr die Richtigkeit, Vollst\u00e4ndigkeit und Aktualit\u00e4t der durch die App bereitgestellten Informationen (insbesondere Timelines, Checklisten, Erinnerungen) wird keine Gew\u00e4hr \u00fcbernommen.\n\nf) F\u00fcr den Verlust von Daten, die der Nutzer in der App gespeichert hat, wird keine Haftung \u00fcbernommen, soweit nicht Vorsatz oder grobe Fahrl\u00e4ssigkeit vorliegen.\n\ng) Die vorstehenden Haftungsbeschr\u00e4nkungen gelten nicht f\u00fcr Sch\u00e4den aus der Verletzung des Lebens, des K\u00f6rpers oder der Gesundheit sowie f\u00fcr Anspr\u00fcche nach dem Produkthaftungsgesetz."},
    {"title": "7. Verf\u00fcgbarkeit", "body": "Es wird eine m\u00f6glichst hohe Verf\u00fcgbarkeit der App angestrebt, jedoch keine ununterbrochene Erreichbarkeit garantiert. Wartungsarbeiten, Updates, h\u00f6here Gewalt, St\u00f6rungen bei Drittanbietern oder sonstige technische Schwierigkeiten k\u00f6nnen zu vor\u00fcbergehenden Einschr\u00e4nkungen f\u00fchren. Ein Anspruch auf st\u00e4ndige Verf\u00fcgbarkeit besteht nicht."},
    {"title": "8. Gew\u00e4hrleistungsausschluss", "body": "Es wird keine Garantie oder Zusicherung daf\u00fcr \u00fcbernommen, dass die App frei von Fehlern ist, bestimmte Ergebnisse erzielt werden oder die App f\u00fcr einen bestimmten Zweck geeignet ist. Die Nutzung der App erfolgt auf eigenes Risiko des Nutzers."},
    {"title": "9. \u00c4nderungen dieser Nutzungsbedingungen", "body": "Diese Nutzungsbedingungen k\u00f6nnen mit Wirkung f\u00fcr die Zukunft ge\u00e4ndert werden. \u00dcber wesentliche \u00c4nderungen werden Sie per E-Mail oder In-App-Benachrichtigung informiert. Widersprechen Sie den \u00c4nderungen nicht innerhalb von 30 Tagen nach Benachrichtigung, gelten die neuen Nutzungsbedingungen als akzeptiert."},
    {"title": "10. Schlussbestimmungen", "body": "a) Es gilt das Recht der Bundesrepublik Deutschland unter Ausschluss des UN-Kaufrechts.\n\nb) Gerichtsstand f\u00fcr alle Streitigkeiten aus oder im Zusammenhang mit diesen Nutzungsbedingungen ist, soweit gesetzlich zul\u00e4ssig, Peine.\n\nc) Sollten einzelne Bestimmungen dieser Nutzungsbedingungen unwirksam sein oder werden, bleibt die Wirksamkeit der \u00fcbrigen Bestimmungen unber\u00fchrt. An die Stelle der unwirksamen Bestimmung tritt eine wirksame Regelung, die dem wirtschaftlichen Zweck der unwirksamen Bestimmung am n\u00e4chsten kommt.\n\nStand: 14. M\u00e4rz 2026"},
]}

imprint = {"sections": [
    {"title": "Angaben gem\u00e4\u00df \u00a7 5 TMG", "body": "Jan Goede\nHalmweg 15b\n31228 Peine\nDeutschland"},
    {"title": "Kontakt", "body": "E-Mail: operationsbegleiter@gmail.com"},
    {"title": "Verantwortlich f\u00fcr den Inhalt nach \u00a7 18 Abs. 2 MStV", "body": "Jan Goede\nHalmweg 15b\n31228 Peine"},
    {"title": "Haftungsausschluss", "body": "Die Inhalte dieser App wurden mit gr\u00f6\u00dfter Sorgfalt erstellt. F\u00fcr die Richtigkeit, Vollst\u00e4ndigkeit und Aktualit\u00e4t der Inhalte wird jedoch keine Gew\u00e4hr \u00fcbernommen.\n\nDie App stellt ausdr\u00fccklich keine medizinische Beratung, Diagnose oder Behandlungsempfehlung dar und ersetzt in keinem Fall die Konsultation eines Arztes, einer \u00c4rztin oder sonstiger medizinischer Fachkr\u00e4fte. Jegliche Nutzung der App-Inhalte erfolgt auf eigenes Risiko.\n\nTrotz sorgf\u00e4ltiger inhaltlicher Kontrolle wird keine Haftung f\u00fcr die Inhalte externer Links \u00fcbernommen. F\u00fcr den Inhalt der verlinkten Seiten sind ausschlie\u00dflich deren Betreiber verantwortlich."},
    {"title": "Streitbeilegung", "body": "Die Europ\u00e4ische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit:\nhttps://ec.europa.eu/consumers/odr\n\nZur Teilnahme an einem Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle besteht weder Bereitschaft noch Verpflichtung."},
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
