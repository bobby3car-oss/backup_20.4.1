#!/usr/bin/env python3
"""Fix remaining English values in app_de.arb (batch 4)."""
import json, re

ARB_PATH = "lib/l10n/app_de.arb"

FIXES = {
    # Appointment priority
    "apptPriorityHigh":        "Hoch",
    "apptPriorityLow":         "Niedrig",
    "apptPriorityMedium":      "Mittel",
    "apptPriorityUrgent":      "Dringend",
    # Appointment reminders
    "apptReminderCustom":      "Benutzerdefiniert",
    "apptReminderDay1":        "1 Tag vorher",
    "apptReminderDays2":       "2 Tage vorher",
    "apptReminderHour1":       "1 Stunde vorher",
    "apptReminderHours2":      "2 Stunden vorher",
    "apptReminderMin15":       "15 Min. vorher",
    "apptReminderMin30":       "30 Min. vorher",
    "apptReminderNone":        "Keine",
    # Appointment repeat
    "apptRepeatDaily":         "Täglich",
    "apptRepeatMonthly":       "Monatlich",
    "apptRepeatNone":          "Keine",
    "apptRepeatWeekly":        "Wöchentlich",
    # Appointment status
    "apptStatusCanceled":      "Abgesagt",
    "apptStatusCompleted":     "Abgeschlossen",
    "apptStatusConfirmed":     "Bestätigt",
    "apptStatusDeclined":      "Abgelehnt",
    "apptStatusDone":          "Erledigt",
    "apptStatusPending":       "Ausstehend",
    "apptStatusPlanned":       "Geplant",
    # Appointment types
    "apptTypeCall":            "Telefonat",
    "apptTypeFollowUp":        "Nachsorge",
    "apptTypeImaging":         "Bildgebung",
    "apptTypeOther":           "Sonstiges",
    "apptTypePhysio":          "Physiotherapie",
    "apptTypeSurgery":         "Operation",
    # Appointment view
    "apptViewList":            "Liste",
    # Bella AI features
    "bellaDailyAnalysis":      "Bella Tagesanalyse",
    "bellaFeatureAppHelp":     "App-Hilfe",
    "bellaFeatureMedicalKnowledge": "Medizinisches Wissen",
    "bellaWoundProgressComparison": "Wundverlauf-Vergleich",
    # Vital hint
    "erfasseVitalwerteUnterVitals": "Erfasse Vitalwerte unter Vitaldaten",
    # Red flags / open items
    "offeneRedFlags":          "Offene Warnsignale",
    # OP/Surgery labels
    "opDetails":               "OP-Details",
    "opDocumentsLabel":        "Dokumente",
    "opName":                  "OP-Name",
    "opType":                  "OP-Typ",
    # Red flag sources
    "rfEmergencyInstructions": "Notfallanweisungen",
    "rfSourcePain":            "Schmerzen",
    "rfSourceSymptomCheck":    "Symptom-Check",
    "rfSourceVitals":          "Vitaldaten",
    # Section labels (Mehr-Menü and elsewhere)
    "sectionAccompany":        "Begleitung",
    "sectionAnalysis":         "Analyse",
    "sectionAnalytics":        "Analytik",
    "sectionDocumentation":    "Dokumentation",
    "sectionDocuments":        "Dokumente",
    "sectionEmergencyInfo":    "Notfallinformationen",
    "sectionHealth":           "Gesundheit",
    "sectionHealthReport":     "Gesundheitsbericht",
    "sectionHelp":             "Hilfe",
    "sectionLanguage":         "Sprache",
    "sectionMood":             "Stimmung",
    "sectionNotifications":    "Benachrichtigungen",
    "sectionNutrition":        "Ernährung",
    "sectionOpInfo":           "OP-Informationen",
    "sectionOpPlanning":       "OP & Planung",
    "sectionPackingList":      "Packliste",
    "sectionPain":             "Schmerzen",
    "sectionPeople":           "Personen",
    "sectionPhotos":           "Fotos",
    "sectionProfile":          "Profil",
    "sectionProgress":         "Fortschritt",
    "sectionRecentlyUsed":     "Zuletzt genutzt",
    "sectionRedFlags":         "Warnsignale",
    "sectionSleep":            "Schlaf",
    "sectionSymptomCheck":     "Symptom-Check",
    "sectionVitals":           "Vitaldaten",
    "sectionVoiceNotes":       "Sprachnotizen",
    # Misc
    "sonstige":                "Sonstiges",
    # Template titles
    "templateOpdayInfoTitle":      "OP-Infos bestätigen",
    "templateWeek1PainScoreTitle": "Schmerzniveau erfassen",
    # Timeline
    "timelinePhaseFollowup":    "Nachsorge",
    "timelinePhaseOpday":       "OP-Tag",
    "timelineRouteSymptomCheck":"Symptom-Check",
    "timelineRouteVitals":      "Vitaldaten",
    # Warnings
    "warnCall112":             "112 anrufen",
    "warnEmergencyTitle":      "Notfall?",
    "warnItemFeverTitle":      "Hohes Fieber",
    "warnItemPainTitle":       "Starke Schmerzen",
}

with open(ARB_PATH, encoding="utf-8") as f:
    text = f.read()

data = json.loads(text)

fixed = 0
not_found = []
for key, german_val in FIXES.items():
    if key in data:
        old = data[key]
        data[key] = german_val
        print(f"  FIXED  {key}: '{old}' → '{german_val}'")
        fixed += 1
    else:
        not_found.append(key)
        print(f"  SKIP   {key} (not found in ARB)")

with open(ARB_PATH, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"\nFixed {fixed} keys.")
if not_found:
    print(f"Not found ({len(not_found)}): {not_found}")
