#!/usr/bin/env python3
"""
Adds the 258 keys that exist in app_en.arb but are missing from app_de.arb.
German translations are provided for all keys.
@ metadata is copied from EN where it exists.
"""

import json
from collections import OrderedDict

DE_PATH = "lib/l10n/app_de.arb"
EN_PATH = "lib/l10n/app_en.arb"

# Full German translations for all 258 missing keys.
# Keys that already had German text in EN → use that text directly.
# Keys with English text in EN → provide proper German translation.
TRANSLATIONS = {
    "accountUndRechtliches": "Account & Rechtliches",
    "actionCall112": "112 anrufen",
    "actionUnlock": "Entsperren",
    "aktiveWarnungenUndNotfallaktionenPruefen": "Aktive Warnungen und Notfallaktionen prüfen.",
    "alertNotruf112": "Notruf 112",
    "alleAbwaehlen": "Alle abwählen",
    "alleAuswaehlen": "Alle auswählen",
    "alleKategorienErledigt": "Alle Kategorien erledigt!",
    "alleTermineImBlick": "Alle Termine im Blick",
    "allesErledigt": "Alles erledigt!",
    "analyticsNutrition": "Ernährung",
    "analyticsOverview": "Übersicht",
    "analyticsPain": "Schmerzen",
    "analyticsVitals": "Vitaldaten",
    "analyticsWounds": "Wunden",
    "apptAllDay": "Ganztägig",
    "arztAnrufen": "Arzt anrufen",
    "arztKontaktieren": "Arzt kontaktieren",
    "aufgabeHinzufuegen": "Aufgabe hinzufügen",
    "aufgabenUndTimeline": "Aufgaben & Timeline",
    "aufmerksamkeitErforderlich": "Aufmerksamkeit erforderlich",
    "ausGalerie": "Aus Galerie",
    "ausZwischenNablageEinfuegen": "Aus Zwischenablage einfügen",
    "authServiceGoogleSignInWasCancelledByTheUser": "Der Google-Anmeldevorgang wurde abgebrochen.",
    "badgeMedicationHero": "Medikamenten-Held",
    "badgeMedicationHeroDesc": "7 Tage ohne vergessene Dosis",
    "badgeMoodTrackerDesc": "Stimmung 20 Mal dokumentiert",
    "badgePainTracker": "Schmerz-Tracker",
    "badgePainTrackerDesc": "Schmerzen 20 Mal dokumentiert",
    "bandscheibenOP44Jahre": "Bandscheiben-OP, 44 Jahre",
    "befundeUndBerichte": "Befunde & Berichte",
    "begleitetWerden": "Begleitet werden",
    "bellaAIGespraechsexport": "Bella AI – Gesprächsexport",
    "bevorIchLoslegenKannBraucheIchKurzDeineEinwilligung": "Bevor ich loslegen kann, brauche ich kurz deine Einwilligung",
    "bevorstehendeArztUndKliniktermine": "Bevorstehende Arzt- und Kliniktermine",
    "bildAuswaehlen": "Bild auswählen",
    "bitteGibEinenKeyEin": "Bitte gib einen Key ein.",
    "blutwerteAbgegeben": "Blutwerte abgegeben",
    "caregiverRemoved": "{name} wurde entfernt",
    "challengeGeschafft": "Challenge geschafft!",
    "checklisteFuerDieKlinik": "Checkliste für die Klinik",
    "cpAbdominalBelt": "Bauchgurt/Stütze prüfen",
    "cpAbdominalBeltDesc": "Sitz und Trageweise prüfen",
    "cpAbdominalProtection": "Bauchmuskelschutz",
    "cpAbdominalProtectionDesc": "Nicht pressen, beim Aufstehen zur Seite rollen",
    "cpAdmission": "Aufnahme",
    "cpAdmissionDesc": "Bitte pünktlich in der Klinik melden",
    "cpBandageCheck": "Verband kontrollieren",
    "cpBandageCheckDesc": "Verbandszustand prüfen und dokumentieren",
    "cpBreathingExercises": "Atemübungen",
    "cpBreathingExercisesHeartDesc": "Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen",
    "cpBreathingExercisesSpineDesc": "Tiefe Atemzüge – Rücken gerade, sanft atmen",
    "cpCardiacRehabExercises": "Herzreha-Übungen",
    "cpCardiacRehabExercisesDesc": "Leichtes Gehen, Kreislauf langsam aufbauen",
    "cpCardiacRehabWalk": "Herzreha-Spaziergang",
    "cpCardiacRehabWalkDesc": "Gehstrecke langsam steigern, Puls beobachten",
    "cpCheckDocuments": "Dokumente prüfen",
    "cpCheckDocumentsDesc": "Krankenkassenkarte und Unterlagen vorbereiten",
    "cpCheckFasting": "Nüchternheit prüfen",
    "cpCheckFastingDesc": "Keine Nahrung oder Flüssigkeit wie angewiesen",
    "cpCheckFluidIntake": "Flüssigkeitszufuhr prüfen",
    "cpCheckFluidIntakeDesc": "Mindestens 1,5 Liter Flüssigkeit täglich",
    "cpCheckOrthosis": "Orthese/Korsett prüfen",
    "cpCheckOrthosisDesc": "Sitz und Tragezeit prüfen",
    "cpCheckVitals": "Vitalzeichen prüfen",
    "cpCheckVitalsDesc": "Puls/Temperatur kurz notieren",
    "cpCheckWarnings": "Warnzeichen prüfen",
    "cpCheckWarningsDesc": "Fieber, Rötung, Schwellung, starke Schmerzen?",
    "cpCompressionStockings": "Kompressionsstrümpfe prüfen",
    "cpCompressionStockingsDesc": "Sitz und Zustand der Strümpfe prüfen",
    "cpConfirmOpInfo": "OP-Informationen bestätigen",
    "cpConfirmOpInfoDesc": "Offene Fragen mit dem Team klären",
    "cpDietProgression": "Kostaufbau",
    "cpDietProgressionDesc": "Leichte Kost, Schonkost → langsam steigern",
    "cpDocumentBowel": "Stuhlgang dokumentieren",
    "cpDocumentBowelDesc": "Verdauung beobachten – wichtig für den Kostaufbau",
    "cpEveningDose": "Abenddosis wie vorgeschrieben",
    "cpFinalCheck": "Abschlusskontrolle",
    "cpFinalCheckDesc": "Abschlussuntersuchung und Entlassung",
    "cpFirstMobilisation": "Erste Mobilisation",
    "cpFirstMobilisationDesc": "Kurz aufsetzen/aufstehen mit Unterstützung",
    "cpFollowUpAppointment": "Nachsorgetermin",
    "cpFollowUpDesc1": "Fortschrittskontrolle in der Klinik",
    "cpFollowUpDesc2": "Zweite Fortschrittskontrolle",
    "cpFollowUpDesc3": "Dritte Fortschrittskontrolle",
    "cpGaitTraining": "Gangschulung",
    "cpGaitTrainingDesc": "Sicheres Gehen mit/ohne Hilfsmittel üben",
    "cpGoForWalk": "Spazieren gehen",
    "cpGoForWalkDesc": "Jeden Tag etwas weiter laufen – Kreislauf stärken",
    "cpIncreaseActivity": "Aktivität steigern",
    "cpIncreaseActivityDesc": "Aktivität langsam steigern – auf Körpersignale achten",
    "cpInformCompanion": "Begleitperson informieren",
    "cpInformCompanionDesc": "Fahrt und Treffpunkt abstimmen",
    "cpLegExercises": "Beinübungen durchführen",
    "cpLegExercisesDesc": "Füße kreisen, Beine anspannen – Thromboseprophylaxe",
    "cpMorningDose": "Morgendosis wie vorgeschrieben",
    "cpNoonDose": "Mittagsdosis wie vorgeschrieben",
    "cpNormalDietProgression": "Normale Ernährung aufbauen",
    "cpNormalDietProgressionDesc": "Verdauung beobachten – schrittweise zur normalen Ernährung",
    "cpObserveWound": "Wunde beobachten",
    "cpObserveWoundDesc": "Heilungsverlauf beobachten und dokumentieren",
    "cpPackHospitalBag": "Kliniktasche packen",
    "cpPackHospitalBagDesc": "Dokumente, Kleidung und Ladekabel einpacken",
    "cpPainDiary": "Schmerztagebuch",
    "cpPainDiaryDesc": "Schmerzverlauf dokumentieren – bessert es sich?",
    "cpPhysioExercises": "Physiotherapie-Übungen",
    "cpPhysioExercisesDesc": "Übungen wie angewiesen durchführen",
    "cpRecordPainLevel": "Schmerzniveau erfassen",
    "cpRecordPainLevelDesc": "Schmerzniveau in der App eingeben",
    "cpScarCare": "Narbenpflege",
    "cpScarCareDesc": "Narbe sanft eincremen und beobachten",
    "cpSpineProtection": "Rückenschutzhaltung",
    "cpSpineProtectionDesc": "Kein Verdrehen oder Beugen der Wirbelsäule",
    "cpStabilisationExercises": "Stabilisationsübungen",
    "cpStabilisationExercisesDesc": "Rumpfstabilisation wie angewiesen – schrittweise steigern",
    "cpSternumProtection": "Sternumschutz",
    "cpSternumProtectionDesc": "Kein Heben über 5 kg, Arme nah am Körper halten",
    "cpTakeMedication": "Medikamente einnehmen",
    "cpTakeWoundPhoto": "Wundfoto aufnehmen",
    "cpTakeWoundPhotoDesc": "Foto zur Fortschrittsverfolgung dokumentieren",
    "cpTakeWoundPhotoProgress": "Wundfoto aufnehmen",
    "cpTakeWoundPhotoProgressDesc": "Heilungsfortschritt weiter dokumentieren",
    "cpWeeklySelfCheck": "Wöchentliche Selbstkontrolle",
    "cpWeeklySelfCheckDesc": "Heilungsfortschritt auswerten und dokumentieren",
    "dasRehaSystemMitTimerIstGoldWert": "Das Reha-System mit Timer ist Gold wert.",
    "datenEingeben": "Daten eingeben",
    "debugEmail": "E-Mail: {email}",
    "debugLinkedPatients": "Verknüpfte Patienten",
    "debugNotAvailable": "nicht verfügbar",
    "debugNotLoggedIn": "nicht angemeldet",
    "debugOnlyForAdmins": "Nur für Admins verfügbar.",
    "debugOnlyInDebug": "Nur in Debug-Builds verfügbar.",
    "debugRole": "Rolle: {role}",
    "debugUid": "UID: {uid}",
    "deineHeutigeChallenge": "Deine heutige Challenge",
    "deineWochenZusammenfassung": "Deine Wochen-Zusammenfassung",
    "derNutzerVerliertSofortDenProZugang": "Der Nutzer verliert sofort den Pro-Zugang.",
    "dieserKeyIstAbgelaufen": "Dieser Key ist abgelaufen.",
    "dokuHubFuerKameraUndGalerie": "Doku-Hub für Kamera & Galerie",
    "dokumenteHochladen": "Dokumente hochladen",
    "duHastAlleAufgabenAbgeschlossenGoennDirEinePause": "Du hast alle Aufgaben abgeschlossen. Gönn dir eine Pause.",
    "duMusstAngemeldetSein": "Du musst angemeldet sein.",
    "einnahmeDokumentieren": "Einnahme dokumentieren",
    "empty7DaysNoData": "7 Tage: keine Daten",
    "emptyNoMacros": "Keine Makros erfasst",
    "emptyNoNotifications": "Keine Benachrichtigungen",
    "emptyNoRedFlags": "Keine offenen Red Flags",
    "emptyNoVitals": "Noch keine Vitaldaten erfasst",
    "emptyNoVitalsShort": "Noch keine Vitaldaten",
    "emptyTasksInPlan": "Noch keine Aufgaben im Plan.",
    "emptyTodayNoEntries": "Heute: keine Einträge",
    "erinnerungenAnMedikamenteneinnahme": "Erinnerungen an Medikamenteneinnahme",
    "erstelle": "Erstelle\u2026",
    "erstelleDeinKontoInWenigenSekunden": "Erstelle dein Konto in wenigen Sekunden.",
    "erstelleEineEigeneAufgabeFuerDeineOPVorbereitung": "Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.",
    "erstelleUndVerwalteDeineOPBezogenenTermine": "Erstelle und verwalte deine OP-bezogenen Termine.",
    "familyOverviewAufmerksamkeitErforderlich": "Aufmerksamkeit erforderlich",
    "fehlerBeimEinloesenBitteVersucheEsErneut": "Fehler beim Einlösen. Bitte versuche es erneut.",
    "fehlerBeimSpeichernErneut": "Fehler beim Speichern. Bitte erneut versuchen.",
    "fehlerGeneric": "Fehler: {error}",
    "fehlerMitDetails": "Fehler: {error}",
    "fotoAufnehmen": "Foto aufnehmen",
    "fragenUndNotizen": "Fragen & Notizen",
    "fuegeDeineOPInformationenHinzu": "Füge deine OP-Informationen hinzu.",
    "googleSignInWasCancelledByTheUser": "Der Google-Anmeldevorgang wurde abgebrochen.",
    "habenSieAtembeschwerdenOderKurzatmigkeit": "Haben Sie Atembeschwerden oder Kurzatmigkeit?",
    "halteEinenFreienEintragInDeinerTimelineFest": "Halte einen freien Eintrag in deiner Timeline fest.",
    "hintDescribeInDetail": "Beschreibe dein Anliegen so genau wie möglich\u2026",
    "hintShortDescription": "Kurze Beschreibung deines Anliegens",
    "ichWarNervoesVorDerOPDieRedFlagWarnung": "Ich war nervös vor der OP. Die Red-Flag Warnung",
    "itemDeletedMessage": "\u201e{title}\u201c gelöscht",
    "itemDeletedPermanently": "\u201e{title}\u201c wird dauerhaft gelöscht.",
    "keyNichtGefunden": "Key nicht gefunden.",
    "knieTEP58Jahre": "Knie-TEP, 58 Jahre",
    "kritischerSymptomCheck": "Kritischer Symptom-Check",
    "labelCategory": "Kategorie",
    "labelContentOptional": "Inhalt (optional)",
    "labelCustomMinutes": "Eigene Minuten",
    "labelDescriptionOptional": "Beschreibung (optional)",
    "labelInviteCode": "Einladungscode",
    "labelInviteCodeValue": "Code: {code}",
    "labelLinkType": "Link-Typ",
    "labelLocation": "Ort",
    "labelLocationDetails": "Ortsdetails",
    "labelNote": "Notiz",
    "labelObservation": "Beobachtung",
    "labelReminder": "Erinnerung",
    "labelSubject": "Betreff",
    "labelTitle": "Titel",
    "labelTitleRequired": "Titel *",
    "labelType": "Typ",
    "mahlzeitenUndEmpfehlungen": "Mahlzeiten & Empfehlungen",
    "measurementSaved": "Messung gespeichert",
    "meinePatienten": "Meine Patienten",
    "memoAufnehmen": "Memo aufnehmen",
    "n7Tage": "\u00d8 7 Tage",
    "nachDerOP": "Nach der OP",
    "nachMeinerKnieOPHatteIchHundertFragen": "Nach meiner Knie-OP hatte ich hundert Fragen.",
    "nachrichtNsenden": "Nachricht\nsenden",
    "notifChannelAppointments": "Erinnerungen für bevorstehende Termine",
    "notifChannelMedication": "Medikamentenerinnerung",
    "notifChannelMedicationDesc": "Tägliche Erinnerungen für Medikamente",
    "notifChannelVitals": "Vitaldaten-Erinnerung",
    "notifChannelVitalsDesc": "Tägliche Erinnerung für Vitaldatenmessungen",
    "notifDoctorAnswered": "Dr. {name} hat deine Frage beantwortet",
    "notifMeasureVitals": "Vitaldaten messen",
    "notifObservationFrom": "Beobachtung von {name}",
    "notifWoundAlarm": "Wund-Alarm",
    "notizErstellen": "Notiz erstellen",
    "nutritionProteinG1110": "Protein (g)",
    "oPAngelegt": "OP angelegt",
    "oPTag": "OP\u2011Tag",
    "oPTagWundeFrischVersorgtSterilerVerbandAngelegt": "OP\u2011Tag. Wunde frisch versorgt, steriler Verband angelegt.",
    "oeffnetDieRehaUebersichtFuerUebungenUndFortschritt": "Öffnet die Reha-Übersicht für Übungen und Fortschritt.",
    "operateurUndAnaesthesist": "Operateur & Anästhesist",
    "pain7Tage": "\u00d8 7 Tage",
    "painDiary7Tage": "\u00d8 7 Tage",
    "patientNhinzufuegen": "Patient\nhinzufügen",
    "planeHinUndRueckfahrtZurKlinik": "Plane Hin- und Rückfahrt zur Klinik.",
    "proActiveSubtitle": "Alle Funktionen freigeschaltet",
    "proActiveTitle": "Pro aktiv",
    "proEntziehen": "Pro entziehen",
    "proGeben": "Pro vergeben",
    "proStatusEntziehen": "Pro-Status entziehen?",
    "redFlagCockpit": "Red-Flag Cockpit",
    "rolleKonnteNichtGeladenWerden": "Rolle konnte nicht geladen werden.",
    "ruheBewahren": "Ruhe bewahren",
    "schmerzErfassen": "Schmerz erfassen",
    "setzenOderLegenSieSichHinAtmenSieRuhig": "Setzen oder legen Sie sich hin. Atmen Sie ruhig.",
    "sleepEntryEditorNotizOptional": "Notiz (optional)",
    "speichere": "Speichere\u2026",
    "speichert": "Speichert\u2026",
    "streakGerettet": "Streak gerettet!",
    "symptomCheckServiceNotruf112": "Notruf 112",
    "symptomU2011Check": "Symptom\u2011Check",
    "systemVorlageFehler": "Fehler: {error}",
    "timelineRoutesAufgabeHinzufuegen": "Aufgabe hinzufügen",
    "timelineRoutesNotizErstellen": "Notiz erstellen",
    "timelineTransportTitle": "Transportplanung",
    "trittMeinemOperationsbegleiterBeiNN": "Tritt meinem Operationsbegleiter bei!\n\n",
    "uebungenTimerUndFortschritt": "Übungen, Timer & Fortschritt",
    "updatesProStatusUndAppHinweise": "Updates, Pro-Status & App-Hinweise",
    "userBlocked": "{name} wurde gesperrt.",
    "userDeleted": "{name} wurde gelöscht.",
    "userGesperrtEntsperrt": "Nutzer {action}.",
    "userUnblocked": "{name} wurde entsperrt.",
    "vitalsNotizOptional": "Notiz (optional)",
    "vorlageErzeugen": "Vorlage erstellen",
    "vorWaehrendUndNachDerOP": "Vor, während & nach der OP",
    "warnungenBeiKritischenWundkontrollErgebnissen": "Warnungen bei kritischen Wundkontroll-Ergebnissen",
    "warnungenUndNotfall": "Warnungen & Notfall",
    "warningCheckSaved": "Warnüberprüfung gespeichert ({level})",
    "wieHastDuGeschlafen": "Wie hast du geschlafen?",
    "wieStarkSindIhreSchmerzenImOPBereich": "Wie stark sind Ihre Schmerzen im OP-Bereich?",
    "wirdZugewiesen": "Wird zugewiesen\u2026",
    "wunddokumentation": "Wunddokumentation",
    "wundenDokumentieren": "Wunden dokumentieren",
    "zusammenfassungFuerDenArzt": "Zusammenfassung für den Arzt",
}


def load_arb_ordered(path):
    """Load ARB file preserving insertion order."""
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f, object_pairs_hook=OrderedDict)


def save_arb(path, data):
    """Save ARB file with 2-space indent and UTF-8 encoding."""
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main():
    de = load_arb_ordered(DE_PATH)
    en = load_arb_ordered(EN_PATH)

    de_keys = {k for k in de if not k.startswith("@")}
    en_keys = {k for k in en if not k.startswith("@")}
    missing = sorted(en_keys - de_keys)

    if not missing:
        print("No missing keys found.")
        return

    added = 0
    not_covered = []

    for key in missing:
        if key not in TRANSLATIONS:
            not_covered.append(f"{key}  (EN: {en[key]})")
            continue

        de[key] = TRANSLATIONS[key]
        added += 1

        # Copy @metadata from EN if it exists
        meta_key = f"@{key}"
        if meta_key in en and meta_key not in de:
            de[meta_key] = en[meta_key]

    if not_covered:
        print("WARNING: No translation provided for:")
        for s in not_covered:
            print(f"  {s}")

    save_arb(DE_PATH, de)
    print(f"\n✅ Added {added} keys to {DE_PATH}")
    print(f"   DE now has {len([k for k in de if not k.startswith('@')])} keys")


if __name__ == "__main__":
    main()
