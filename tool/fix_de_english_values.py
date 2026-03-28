#!/usr/bin/env python3
"""
Fixes 140 DE ARB keys that still have English values.
Provides proper German translations for all of them.
"""

import json
from collections import OrderedDict

DE_PATH = "lib/l10n/app_de.arb"

FIXES = {
    "adminAbmeldenBestaetigung": "Wirklich aus dem Admin-Bereich abmelden?",
    "alleAlsGelesenMarkieren": "Alle als gelesen markieren",
    "apptAddFirstHint": "Tippe auf +, um deinen ersten Termin hinzuzufügen.",
    "apptConfirmDeclineHint": "Bitte bestätigen oder ablehnen.",
    "apptReminderAtTime": "Pünktlich",
    "aufnahmeStartFehler": "Aufnahme konnte nicht gestartet werden.",
    "bellaBriefingGenerating": "Bella erstellt dein Arzt-Briefing\u2026",
    "bellaBriefingNotSignedIn": "Bitte anmelden.",
    "bellaBriefingPersonalTitle": "Dein persönliches Arzt-Briefing",
    "bellaBriefingProDescription": "Mit Pro erstellt Bella eine persönliche Zusammenfassung für deinen nächsten Arzttermin.",
    "bellaChipCallDoctor": "Wann sollte ich den Arzt anrufen?",
    "bellaChipDoctorDashboard": "Wie funktioniert das Arzt-Dashboard?",
    "bellaChipGeneralDashboard": "Wie funktioniert das Dashboard?",
    "bellaChipPrepareOp": "Wie bereite ich mich auf die OP vor?",
    "bellaChipTimeline": "Wie funktioniert die Timeline?",
    "bellaConsentBody": "Der KI-Assistent (Bella AI) nutzt einen externen Dienst (NVIDIA Corporation, USA), um deine Fragen zu beantworten. Mit deiner Zustimmung werden deine Eingaben an diesen Dienst übertragen. Keine persönlichen Gesundheitsdaten werden dauerhaft gespeichert.",
    "bellaDefaultWoundPrompt": "Bitte analysiere dieses Wundfoto.",
    "bellaDescriptionDoctor": "Ich helfe dir beim Arzt-Dashboard, der Patientenverwaltung und bei klinischen Fragen.",
    "bellaDescriptionPatient": "Ich beantworte deine Fragen zu deiner OP, der Nachsorge und der App.",
    "bellaDescriptionStaff": "Ich helfe dir beim Mitarbeiter-Dashboard und der Patientenbetreuung.",
    "bellaDisclaimer": "Kein medizinischer Rat – bei Beschwerden bitte einen Arzt aufsuchen.",
    "bellaNoAnswerReceived": "Keine Antwort erhalten. Bitte erneut versuchen. 🐰",
    "bellaProactivePainTrend": "Dein Schmerzniveau steigt – möchtest du darüber sprechen?",
    "bellaSubtitleDoctor": "Dein klinischer Assistent 🐰",
    "bellaSubtitlePatient": "Dein OP-Begleiter 🐰",
    "bellaSubtitleStaff": "Dein Praxis-Assistent 🐰",
    "bellaWoundDisclaimer": "Kein Ersatz für eine medizinische Diagnose. Im Zweifel das medizinische Team kontaktieren.",
    "beschreibeAnliegen": "Beschreibe dein Anliegen so genau wie möglich\u2026",
    "calendarAddToCalendarBody": "Möchtest du diesen Termin zu deinem Gerätekalender hinzufügen oder als .ics-Datei teilen?",
    "errorDeadlineExceeded": "Zeitüberschreitung. Bitte erneut versuchen.",
    "errorNoInternet": "Keine Internetverbindung. Bitte Netzwerk prüfen.",
    "errorNotFound": "Nicht gefunden. Bitte Eingabe prüfen.",
    "errorOperationNotAllowed": "Diese Aktion ist nicht erlaubt.",
    "errorPermissionDenied": "Keine Berechtigung für diese Aktion.",
    "errorPleaseSignIn": "Bitte anmelden.",
    "errorRequiresRecentLogin": "Bitte erneut anmelden, um fortzufahren.",
    "errorResourceExhausted": "Zu viele Anfragen. Bitte einen Moment warten.",
    "errorServiceUnavailable": "Der Dienst ist vorübergehend nicht verfügbar. Bitte später erneut versuchen.",
    "errorServiceUnavailableShort": "Der Dienst ist vorübergehend nicht verfügbar.",
    "errorTooManyRequests": "Zu viele Versuche. Bitte später erneut versuchen.",
    "errorUserDisabled": "Dieses Konto wurde deaktiviert.",
    "errorUserNotFound": "Kein Konto mit dieser E-Mail-Adresse gefunden.",
    "errorWeakPassword": "Das Passwort ist zu schwach.",
    "footerLoveMessage": "Mit Liebe für deine Genesung entwickelt",
    "grundDerSperrung": "Grund der Sperrung\u2026",
    "ihreAntwortEingeben": "Antwort eingeben\u2026",
    "keineAufgabenImPlan": "Noch keine Aufgaben im Plan.",
    "nurInDebugBuilds": "Nur in Debug-Builds verfügbar.",
    "profilGespeichert": "Profil gespeichert.",
    "rfEmergencyStep2Desc": "Aktuelle Beschwerden und deren Schweregrad notieren.",
    "rfEmergencyStep3Desc": "Arzt oder Klinik anrufen und Symptome beschreiben.",
    "rfEmergencyStep4Desc": "Bei Atemnot, Bewusstlosigkeit oder starker Blutung sofort 112 anrufen.",
    "rfEmergencySubtitle": "Sofortmaßnahmen bei Atemnot, Bewusstlosigkeit oder starker Blutung.",
    "rfProAutoDetect": "Mit Pro erkennt das System automatisch kritische Werte aus Schmerzen, Vitaldaten und mehr.",
    "rfSeverityDescGreen": "Deine Werte liegen im Normalbereich. Weiter so!",
    "rfSeverityDescOrange": "Mehrere Werte auffällig. Bald einen Arzt aufsuchen.",
    "rfSeverityDescYellow": "Einige Werte leicht außerhalb des Normalbereichs. Bitte beobachten.",
    "rfWarningCheckSubtitle": "Schnellcheck der wichtigsten Symptome – dauert nur 30 Sekunden.",
    "statsNichtAktualisiert": "Statistiken konnten nicht aktualisiert werden.",
    "templateFollowupActivitySubtitle": "Aktivität schrittweise steigern – auf den Körper hören",
    "templateFollowupDay28Subtitle": "Abschlussuntersuchung und Entlassung",
    "templateFollowupDay7Subtitle": "Fortschrittskontrolle in der Praxis",
    "templateFollowupScarCareSubtitle": "Narbe sanft eincremen und beobachten",
    "templateFollowupWeeklyCheckSubtitle": "Heilungsfortschritt auswerten und dokumentieren",
    "templateOpdayAdmissionSubtitle": "Bitte pünktlich in der Klinik erscheinen",
    "templateOpdayFastingSubtitle": "Keine Nahrung oder Flüssigkeit wie angewiesen",
    "templateOpdayInfoSubtitle": "Offene Fragen mit dem Team klären",
    "templateOpdayMobilizationSubtitle": "Kurz aufsetzen/aufstehen mit Unterstützung",
    "templatePreopBagSubtitle": "Dokumente, Kleidung und Ladekabel einpacken",
    "templatePreopCompanionSubtitle": "Fahrt und Treffpunkt abstimmen",
    "templatePreopDocumentsSubtitle": "Krankenkassenkarte und Befunde vorbereiten",
    "templateWeek1AbdominalSupportSubtitle": "Sitz und Trageweise prüfen",
    "templateWeek1BackPostureSubtitle": "Kein Verdrehen oder Beugen der Wirbelsäule",
    "templateWeek1BloodPressureSubtitle": "Werte morgens und abends dokumentieren",
    "templateWeek1BowelDiarySubtitle": "Verdauung beobachten – wichtig für den Kostaufbau",
    "templateWeek1BreathingCardioSubtitle": "Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen",
    "templateWeek1CompressionSubtitle": "Sitz und Zustand der Strümpfe prüfen",
    "templateWeek1DressingSubtitle": "Verbandszustand prüfen und dokumentieren",
    "templateWeek1JointRomSubtitle": "Beugen und Strecken vorsichtig testen",
    "templateWeek1OrthosisSubtitle": "Sitz und Tragezeit prüfen",
    "templateWeek1PainScoreSubtitle": "Schmerzniveau in der App eingeben",
    "templateWeek1WoundPhotoSubtitle": "Foto zur Fortschrittsverfolgung dokumentieren",
    "templateWeek2WoundObserveSubtitle": "Heilungsverlauf beobachten und dokumentieren",
    "timelinePlanComplete": "Dein Plan ist aktuell vollständig erledigt",
    "timelineRouteAppointmentDesc": "Erstelle und verwalte deine OP-bezogenen Termine.",
    "timelineRouteMoodLogDesc": "Erfasse deine Stimmung und erkenne Muster in deinem emotionalen Wohlbefinden.",
    "timelineRouteNoteAddDesc": "Halte einen freien Eintrag in deiner Timeline fest.",
    "timelineRouteNutritionDesc": "Dokumentiere deine Mahlzeiten und erhalte Ernährungsempfehlungen.",
    "timelineRoutePainLogDesc": "Dokumentiere dein Schmerzniveau auf einer Skala von 1–10.",
    "timelineRouteQuestionsDesc": "Behalte den Überblick über Fragen für deinen Operateur und persönliche Notizen.",
    "timelineRouteRedFlagDesc": "Aktive Warnungen und Notfallaktionen prüfen.",
    "timelineRouteRehabDesc": "Öffnet die Reha-Übersicht für Übungen und Fortschritt.",
    "timelineRouteSleepLogDesc": "Dokumentiere deine Schlafdauer und -qualität.",
    "timelineRouteTaskAddDesc": "Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.",
    "timelineRouteTransportDesc": "Plane deine Hin- und Rückfahrt zur Klinik.",
    "timelineTransportHint": "Plane deine Hin- und Rückfahrt zur Klinik.",
    "verbindungFehlgeschlagen": "Verbindung fehlgeschlagen. Bitte erneut versuchen.",
    "warnContactClinic": "Kontaktiere die Klinik bei diesen Zeichen:",
    "warnEmergencySubtitle": "Bei lebensbedrohlichen Symptomen!",
    "warnItemBleedingQ1": "Ist die Blutung aktiv und lässt sich nicht stoppen?",
    "warnItemBleedingQ2": "Ist der Verband schon vollständig durchgeblutet?",
    "warnItemBleedingQ3": "Fühlst du dich schwindelig oder schwach?",
    "warnItemBreathQ1": "Tritt die Atemnot in Ruhe auf?",
    "warnItemBreathQ2": "Wird die Atemnot schlimmer?",
    "warnItemBreathQ3": "Hast du Schmerzen beim Atmen?",
    "warnItemFeverQ1": "Hast du Fieber gemessen?",
    "warnItemFeverQ2": "Ist die Temperatur über 38,5 °C?",
    "warnItemFeverQ3": "Hast du Schüttelfrost?",
    "warnItemPainQ1": "Sind die Schmerzen deutlich stärker als sonst?",
    "warnItemPainQ2": "Helfen deine üblichen Schmerzmittel nicht mehr?",
    "warnItemPainQ3": "Ist die schmerzende Stelle geschwollen oder heiß?",
    "warnItemRednessQ1": "Breitet sich die Rötung aus?",
    "warnItemRednessQ2": "Ist die Stelle warm oder heiß?",
    "warnItemSmellQ1": "Hat das Sekret eine ungewöhnliche Farbe?",
    "warnItemSmellQ2": "Riecht die Wunde deutlich unangenehm?",
    "warnItemSmellQ3": "Hat sich die Sekretmenge erhöht?",
    "warnItemSmellSubtitle": "Ungewöhnliches Sekret aus der Wunde",
    "wasBeschaeftigtDich": "Was beschäftigt dich gerade?",
    "zbDieBlaue": "z. B. Die blaue, nicht die rote",
    "zbNachDemEssen": "z. B. mit Wasser nach dem Essen einnehmen",
    # Keys with placeholders
    "anfrageAblehnenBestaetigung": "Möchtest du die Anfrage von {name} ablehnen?",
    "apptDeleteContent": "Möchtest du \"{title}\" wirklich dauerhaft löschen?",
    "bellaProactiveDocGap": "Du hast {days} Tage lang nichts eingetragen",
    "bellaProactiveMedReminder": "Hast du heute dein {name} eingenommen?",
    "bellaProactiveMedReminderMultiple": "Hast du heute deine Medikamente eingenommen? ({count} ausstehend)",
    "bellaProactiveOpenTasks": "Du hast noch {count} offene Aufgaben für heute",
    "bellaProactiveStreakAtRisk": "Dein {streak}-Tage-Streak ist in Gefahr!",
    "caregiverEntfernt": "{name} wurde entfernt",
    "doctorEntfernt": "{name} wurde entfernt",
    "dokumentGeloescht": "\u201e{title}\u201c gelöscht",
    "medikamentEntfernt": "{name} entfernt",
    "medikamentWirdEntfernt": "{name} wird entfernt.",
    "mitarbeiterEntfernt": "{name} wurde entfernt",
    "nameWurdeGeloescht": "{name} wurde gelöscht.",
    "nameWurdeGesperrt": "{name} wurde gesperrt.",
    "timelineTasksPlanned": "{count} Aufgaben für heute geplant",
    "unwiderruflichLoeschen": "\u201e{title}\u201c wird dauerhaft gelöscht.",
    "userAktionFehler": "Nutzer konnte nicht {action}t werden.",
    "vorlageLoeschenBestaetigung": "Möchtest du \"{name}\" wirklich löschen?",
    "warnzeichenGespeichert": "Warnzeichen-Check gespeichert ({level})",
}


def load_arb_ordered(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f, object_pairs_hook=OrderedDict)


def save_arb(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main():
    de = load_arb_ordered(DE_PATH)

    fixed = 0
    for key, german_value in FIXES.items():
        if key in de:
            de[key] = german_value
            fixed += 1
        else:
            print(f"WARNING: key not found in DE: {key}")

    save_arb(DE_PATH, de)
    print(f"\n✅ Fixed {fixed} English values in {DE_PATH}")
    print(f"   DE total keys: {len([k for k in de if not k.startswith('@')])}")


if __name__ == "__main__":
    main()
