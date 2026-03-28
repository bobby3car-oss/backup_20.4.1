#!/usr/bin/env python3
"""Fix all remaining English values in app_de.arb with proper German translations."""

import json
from collections import OrderedDict

DE_PATH = "lib/l10n/app_de.arb"

FIXES = {
    # Appointment strings
    "apptCancelAppt": "Termin absagen",
    "apptCreatedByDoctor": "Vom Arzt erstellt",
    "apptDeleteTitle": "Termin löschen",
    "apptEditTitle": "Termin bearbeiten",
    "apptHintTitle": "z. B. Nachsorgetermin",
    "apptLabelDoctor": "Arzt / Behandler",
    "apptNewTitle": "Neuer Termin",
    "apptViewCalendar": "Kalender",
    "apptCalendarDayCount": "{count, plural, one{{count} Termin} other{{count} Termine}}",

    # Calendar
    "calendarAddedSuccess": "Termin zum Kalender hinzugefügt",
    "calendarExportFailed": "Kalenderexport fehlgeschlagen",
    "calendarTitle": "Kalender",

    # Bella AI chips / actions
    "bellaActionFailed": "Erstellen fehlgeschlagen",
    "bellaAskDirectly": "Oder stelle direkt eine Frage:",
    "bellaBriefingIsProFeature": "Arzt-Briefing ist eine Pro-Funktion",
    "bellaChipAddTask": "Aufgabe hinzufügen: Wunde prüfen",
    "bellaChipCreateAppointment": "Einen Termin für morgen um 10 Uhr erstellen",
    "bellaChipDoctorReport": "Wie erstelle ich einen Arztbericht?",
    "bellaChipLinkPatient": "Wie verknüpfe ich einen Patienten?",
    "bellaChipVerifyAccount": "Wie verifiziere ich mein Arzt-Konto?",
    "bellaChipViewPatientData": "Wie sehe ich Patientendaten?",
    "bellaChipViewPatientDataStaff": "Wie sehe ich Patientendaten?",

    # Patient / role selection
    "patientAuswaehlen": "Patient auswählen",
    "patientLinking": "Patientenverknüpfung",
    "rolleAuswaehlen": "Rolle auswählen",
    "weiterenPatientenHinzufuegen": "Weiteren Patienten hinzufügen",
    "aufgabenAuswaehlenCount": "Aufgaben auswählen ({selected}/{total}):",

    # Timeline routes
    "timelineRouteAppointment": "Termin hinzufügen",
    "timelineRouteTaskAdd": "Aufgabe hinzufügen",
    "timelineRouteDocuments": "Dokumente hochladen",
    "timelineRouteMedication": "Medikamente",
    "timelineRouteNoteAdd": "Notiz erstellen",
    "timelineSheetDocUpload": "Dokument hochladen",

    # Section labels (Mehr-Menü)
    "sectionConnectDoctor": "Arzt verbinden",
    "sectionDoctorQuestions": "Arztfragen",
    "sectionDoctorReport": "Arztbericht",
    "sectionMedication": "Medikamente",

    # Templates
    "templateFollowupDay7Title": "Nachsorgetermin",
    "templateMedsMorningTitle": "Medikamente nehmen",

    # Red flags / emergency
    "rfEmergencyStep3Title": "Arzt anrufen",

    # Misc UI
    "freischalten": "Freischalten",
    "monatlichKuendbar": "monatlich kündbar",
    "notizLoeschenBestaetigung": "\u201e{title}\u201c wirklich löschen?",
    "testBenachrichtigungErstellen": "Testbenachrichtigung erstellen",
    "ticketErstellen": "Ticket erstellen",
    "transkriptBearbeiten": "Transkript bearbeiten\u2026",
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
    not_found = []
    for key, german_value in FIXES.items():
        if key in de:
            de[key] = german_value
            fixed += 1
        else:
            not_found.append(key)

    if not_found:
        print(f"WARNING: keys not in DE (will be skipped): {not_found}")

    save_arb(DE_PATH, de)
    print(f"\n✅ Fixed {fixed} English values in {DE_PATH}")
    print(f"   DE total keys: {len([k for k in de if not k.startswith('@')])}")


if __name__ == "__main__":
    main()
