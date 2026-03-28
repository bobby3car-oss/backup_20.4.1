#!/usr/bin/env python3
"""Fix the third (and hopefully final) batch of English values in app_de.arb."""

import json
from collections import OrderedDict

DE_PATH = "lib/l10n/app_de.arb"

FIXES = {
    # Appointments / Calendar
    "appointmentEditorRepeatUntil": "Wiederholen bis",
    "apptNoAppointments": "Noch keine Termine",
    "apptNoResults": "Keine Ergebnisse",
    "apptTodayNone": "Heute keine Termine",
    "apptTodayTitle": "Heutige Termine",
    "calendarNoEvents": "Keine Termine an diesem Tag",

    # Input hints
    "begruendungEingeben": "Begründung eingeben …",
    "grundEingeben": "Grund eingeben…",
    "tagEingeben": "Tag eingeben…",

    # Bella AI chips
    "bellaChipAppFunctions": "Welche App-Funktionen gibt es?",
    "bellaChipMedications": "Wie dokumentiere ich meine Medikamente?",
    "bellaChipMyTasks": "Was sind meine Aufgaben?",
    "bellaChipOpDay": "Was passiert am OP-Tag?",
    "bellaWoundAnalysisTitle": "Wundanalyse",

    # Misc UI
    "keineEmailApp": "Keine E-Mail-App gefunden",

    # Red flags / Emergency
    "rfEmergencyStep2Title": "Symptome prüfen",
    "rfNoActiveWarnings": "Keine aktiven Warnungen. Weiter so!",
    "rfNoFlags": "Keine Red Flags",
    "rfSourceWound": "Wunddaten",

    # Template titles
    "templateFollowupWeeklyCheckTitle": "Wöchentliche Selbstkontrolle",
    "templateOpdayFastingTitle": "Nüchternheit prüfen",
    "templatePreopDocumentsTitle": "Dokumente prüfen",
    "templateWeek1AbdominalSupportTitle": "Bauchgurt prüfen",
    "templateWeek1CompressionTitle": "Kompressionsstrümpfe prüfen",
    "templateWeek1HydrationTitle": "Flüssigkeitszufuhr prüfen",
    "templateWeek1JointRomTitle": "Gelenkbeweglichkeit prüfen",
    "templateWeek1OrthosisTitle": "Orthese/Korsett prüfen",
    "templateWeek1RedFlagsTitle": "Warnzeichen prüfen",
    "templateWeek1VitalsTitle": "Vitaldaten prüfen",
    "templateWeek2PainTitle": "Schmerztagebuch",

    # Timeline routes & labels
    "timelineNoOpenTasks": "Heute keine offenen Aufgaben",
    "timelineRouteMoodLog": "Stimmungstagebuch",
    "timelineRouteNutrition": "Ernährungstagebuch",
    "timelineRoutePainLog": "Schmerztagebuch",
    "timelineRouteSleepLog": "Schlaftagebuch",
    "timelineRouteWoundDoc": "Wunddokumentation",
    "timelineSheetPainLevel": "Schmerzniveau",
    "timelineSheetWoundPhoto": "Wundfoto",
    "timelineViewFullPlan": "Gesamtplan anzeigen",

    # Warnings
    "warnItemRednessSubtitle": "Wundbereich erscheint entzündet",
    "warnSaveCheck": "Prüfung speichern",
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
        print(f"Keys not in DE (skipped): {not_found}")

    save_arb(DE_PATH, de)
    print(f"\n✅ Fixed {fixed} English values in {DE_PATH}")
    print(f"   DE total keys: {len([k for k in de if not k.startswith('@')])}")


if __name__ == "__main__":
    main()
