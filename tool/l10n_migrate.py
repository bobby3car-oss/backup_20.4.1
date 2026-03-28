#!/usr/bin/env python3
"""
Adds new l10n keys for all remaining hardcoded strings.
Run: python3 tool/l10n_migrate.py
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DE_ARB = os.path.join(ROOT, 'lib', 'l10n', 'app_de.arb')
EN_ARB = os.path.join(ROOT, 'lib', 'l10n', 'app_en.arb')

# ── New keys: { key: { "de": ..., "en": ... } } ─────────────────────────

NEW_KEYS = {
    # ── Error helpers (error_helpers.dart) ──────────────────────────────
    "errorUserNotFound": {
        "de": "Kein Konto mit dieser E\u2011Mail gefunden.",
        "en": "No account found with this email address."
    },
    "errorWrongPassword": {
        "de": "Falsches Passwort.",
        "en": "Wrong password."
    },
    "errorInvalidEmail": {
        "de": "Ungültige E\u2011Mail-Adresse.",
        "en": "Invalid email address."
    },
    "errorEmailInUse": {
        "de": "Diese E\u2011Mail wird bereits verwendet.",
        "en": "This email address is already in use."
    },
    "errorWeakPassword": {
        "de": "Das Passwort ist zu schwach.",
        "en": "The password is too weak."
    },
    "errorUserDisabled": {
        "de": "Dieses Konto wurde deaktiviert.",
        "en": "This account has been disabled."
    },
    "errorTooManyRequests": {
        "de": "Zu viele Versuche. Bitte später erneut.",
        "en": "Too many attempts. Please try again later."
    },
    "errorRequiresRecentLogin": {
        "de": "Bitte melde dich erneut an, um fortzufahren.",
        "en": "Please sign in again to continue."
    },
    "errorNoInternet": {
        "de": "Keine Internetverbindung. Bitte prüfe dein Netzwerk.",
        "en": "No internet connection. Please check your network."
    },
    "errorOperationNotAllowed": {
        "de": "Dieser Vorgang ist nicht erlaubt.",
        "en": "This operation is not allowed."
    },
    "errorGeneric": {
        "de": "Ein Fehler ist aufgetreten. Bitte versuche es erneut.",
        "en": "An error occurred. Please try again."
    },
    "errorNotFound": {
        "de": "Nicht gefunden. Bitte prüfe die Eingabe.",
        "en": "Not found. Please check your input."
    },
    "errorAlreadyExists": {
        "de": "Existiert bereits.",
        "en": "Already exists."
    },
    "errorPermissionDenied": {
        "de": "Keine Berechtigung für diese Aktion.",
        "en": "No permission for this action."
    },
    "errorInvalidArgument": {
        "de": "Ungültige Eingabe.",
        "en": "Invalid input."
    },
    "errorFailedPrecondition": {
        "de": "Aktion kann nicht ausgeführt werden.",
        "en": "Action cannot be performed."
    },
    "errorServiceUnavailable": {
        "de": "Der Dienst ist vorübergehend nicht erreichbar. Bitte versuche es später.",
        "en": "The service is temporarily unavailable. Please try again later."
    },
    "errorDeadlineExceeded": {
        "de": "Zeitüberschreitung. Bitte versuche es erneut.",
        "en": "Timeout. Please try again."
    },
    "errorResourceExhausted": {
        "de": "Zu viele Anfragen. Bitte warte kurz.",
        "en": "Too many requests. Please wait a moment."
    },
    "errorNotFoundShort": {
        "de": "Nicht gefunden.",
        "en": "Not found."
    },
    "errorServiceUnavailableShort": {
        "de": "Der Dienst ist vorübergehend nicht erreichbar.",
        "en": "The service is temporarily unavailable."
    },
    "errorCancelled": {
        "de": "Vorgang abgebrochen.",
        "en": "Operation cancelled."
    },
    "errorPleaseSignIn": {
        "de": "Bitte melde dich an.",
        "en": "Please sign in."
    },

    # ── Mehr Screen ────────────────────────────────────────────────────
    "sectionRedFlags": {
        "de": "Red Flags",
        "en": "Red Flags"
    },
    "sectionSymptomCheck": {
        "de": "Symptom-Check",
        "en": "Symptom Check"
    },
    "sectionEmergencyInfo": {
        "de": "Notfall-Info",
        "en": "Emergency Info"
    },
    "sectionHealth": {
        "de": "Gesundheit",
        "en": "Health"
    },
    "sectionVitals": {
        "de": "Vitalwerte",
        "en": "Vital Signs"
    },
    "sectionPain": {
        "de": "Schmerz",
        "en": "Pain"
    },
    "sectionNutrition": {
        "de": "Ernährung",
        "en": "Nutrition"
    },
    "sectionMedication": {
        "de": "Medikamente",
        "en": "Medication"
    },
    "sectionMood": {
        "de": "Stimmung",
        "en": "Mood"
    },
    "sectionSleep": {
        "de": "Schlaf",
        "en": "Sleep"
    },
    "sectionDocumentation": {
        "de": "Dokumentation",
        "en": "Documentation"
    },
    "sectionDocuments": {
        "de": "Dokumente",
        "en": "Documents"
    },
    "sectionPhotos": {
        "de": "Fotos",
        "en": "Photos"
    },
    "sectionDoctorQuestions": {
        "de": "Arztfragen",
        "en": "Doctor Questions"
    },
    "sectionVoiceNotes": {
        "de": "Sprachnotizen",
        "en": "Voice Notes"
    },
    "sectionDoctorReport": {
        "de": "Arztbericht",
        "en": "Doctor Report"
    },
    "sectionOpPlanning": {
        "de": "OP & Planung",
        "en": "Surgery & Planning"
    },
    "sectionOpInfo": {
        "de": "OP-Infos",
        "en": "Surgery Info"
    },
    "sectionPackingList": {
        "de": "Packliste",
        "en": "Packing List"
    },
    "sectionRehabilitation": {
        "de": "Rehabilitation",
        "en": "Rehabilitation"
    },
    "sectionAnalysis": {
        "de": "Auswertung",
        "en": "Analysis"
    },
    "sectionAnalytics": {
        "de": "Analytics",
        "en": "Analytics"
    },
    "sectionProgress": {
        "de": "Fortschritt",
        "en": "Progress"
    },
    "sectionHealthReport": {
        "de": "Gesundheitsbericht",
        "en": "Health Report"
    },
    "sectionPeople": {
        "de": "Personen",
        "en": "People"
    },
    "sectionProfile": {
        "de": "Profil",
        "en": "Profile"
    },
    "sectionNotifications": {
        "de": "Mitteilungen",
        "en": "Notifications"
    },
    "sectionLanguage": {
        "de": "Sprache",
        "en": "Language"
    },
    "sectionHelp": {
        "de": "Hilfe",
        "en": "Help"
    },
    "sectionConnectDoctor": {
        "de": "Arzt verbinden",
        "en": "Connect Doctor"
    },
    "sectionAccompany": {
        "de": "Begleiten",
        "en": "Accompany"
    },
    "sectionDebugTools": {
        "de": "Debug-Tools",
        "en": "Debug Tools"
    },
    "sectionFirebaseTest": {
        "de": "Firebase Test",
        "en": "Firebase Test"
    },
    "sectionRoleDebug": {
        "de": "Role Debug",
        "en": "Role Debug"
    },
    "sectionAdsAdmin": {
        "de": "Ads Admin",
        "en": "Ads Admin"
    },
    "sectionRecentlyUsed": {
        "de": "Zuletzt genutzt",
        "en": "Recently Used"
    },
    "discoverTitle": {
        "de": "Entdecken",
        "en": "Discover"
    },
    "discoverSubtitle": {
        "de": "Alle Funktionen auf einen Blick",
        "en": "All features at a glance"
    },
    "searchHint": {
        "de": "Suchen…",
        "en": "Search…"
    },
    "noSearchResults": {
        "de": "Keine Treffer f\u00fcr \u201e{query}\u201c",
        "en": "No results for \u201c{query}\u201d"
    },
    "@noSearchResults": {
        "placeholders": {
            "query": {"type": "String"}
        }
    },
    "footerLoveMessage": {
        "de": "Mit Liebe gebaut für deine Genesung",
        "en": "Built with love for your recovery"
    },

    # ── Operation Detail Screen ────────────────────────────────────────
    "opDetails": {
        "de": "OP Details",
        "en": "Surgery Details"
    },
    "opActions": {
        "de": "Aktionen",
        "en": "Actions"
    },
    "opTimeline": {
        "de": "Zeitlicher Verlauf",
        "en": "Timeline"
    },
    "opName": {
        "de": "OP Name",
        "en": "Surgery Name"
    },
    "opDate": {
        "de": "Datum",
        "en": "Date"
    },
    "opClinic": {
        "de": "Klinik",
        "en": "Clinic"
    },
    "opType": {
        "de": "OP Typ",
        "en": "Surgery Type"
    },
    "opDocumentsLabel": {
        "de": "Dokumente",
        "en": "Documents"
    },
    "opSymptomsLabel": {
        "de": "Symptome",
        "en": "Symptoms"
    },
    "opManageCaregivers": {
        "de": "Angehörige\nverwalten",
        "en": "Manage\nCaregivers"
    },

    # ── Debug Screens ──────────────────────────────────────────────────
    "debugOnlyInDebug": {
        "de": "Nur in Debug-Builds verfügbar.",
        "en": "Only available in debug builds."
    },
    "debugOnlyForAdmins": {
        "de": "Nur fuer Admins verfuegbar.",
        "en": "Only available for admins."
    },
    "debugNotLoggedIn": {
        "de": "nicht eingeloggt",
        "en": "not logged in"
    },
    "debugNotAvailable": {
        "de": "nicht verfügbar",
        "en": "not available"
    },
    "debugUid": {
        "de": "uid: {uid}",
        "en": "uid: {uid}"
    },
    "@debugUid": {
        "placeholders": {
            "uid": {"type": "String"}
        }
    },
    "debugEmail": {
        "de": "email: {email}",
        "en": "email: {email}"
    },
    "@debugEmail": {
        "placeholders": {
            "email": {"type": "String"}
        }
    },
    "debugRole": {
        "de": "role: {role}",
        "en": "role: {role}"
    },
    "@debugRole": {
        "placeholders": {
            "role": {"type": "String"}
        }
    },
    "debugLinkedPatients": {
        "de": "Linked Patients",
        "en": "Linked Patients"
    },

    # ── Snackbar & Status Messages ─────────────────────────────────────
    "itemDeletedMessage": {
        "de": "\u201e{title}\u201c gelöscht",
        "en": "\"{title}\" deleted"
    },
    "@itemDeletedMessage": {
        "placeholders": {
            "title": {"type": "String"}
        }
    },
    "itemDeletedPermanently": {
        "de": "\u201e{title}\u201c wird unwiderruflich gelöscht.",
        "en": "\"{title}\" will be permanently deleted."
    },
    "@itemDeletedPermanently": {
        "placeholders": {
            "title": {"type": "String"}
        }
    },
    "caregiverRemoved": {
        "de": "{name} wurde entfernt",
        "en": "{name} has been removed"
    },
    "@caregiverRemoved": {
        "placeholders": {
            "name": {"type": "String"}
        }
    },
    "profileSaved": {
        "de": "Profil gespeichert.",
        "en": "Profile saved."
    },
    "userBlocked": {
        "de": "{name} wurde gesperrt.",
        "en": "{name} has been blocked."
    },
    "@userBlocked": {
        "placeholders": {
            "name": {"type": "String"}
        }
    },
    "userUnblocked": {
        "de": "{name} wurde entsperrt.",
        "en": "{name} has been unblocked."
    },
    "@userUnblocked": {
        "placeholders": {
            "name": {"type": "String"}
        }
    },
    "userDeleted": {
        "de": "{name} wurde gelöscht.",
        "en": "{name} has been deleted."
    },
    "@userDeleted": {
        "placeholders": {
            "name": {"type": "String"}
        }
    },
    "warningCheckSaved": {
        "de": "Warnzeichen-Check gespeichert ({level})",
        "en": "Warning check saved ({level})"
    },
    "@warningCheckSaved": {
        "placeholders": {
            "level": {"type": "String"}
        }
    },
    "measurementSaved": {
        "de": "Messung gespeichert",
        "en": "Measurement saved"
    },

    # ── Form Labels & Hints ────────────────────────────────────────────
    "labelLinkType": {
        "de": "Link Typ",
        "en": "Link Type"
    },
    "labelInviteCode": {
        "de": "Invite Code",
        "en": "Invite Code"
    },
    "labelObservation": {
        "de": "Beobachtung",
        "en": "Observation"
    },
    "labelTitle": {
        "de": "Titel",
        "en": "Title"
    },
    "labelCategory": {
        "de": "Kategorie",
        "en": "Category"
    },
    "labelDescriptionOptional": {
        "de": "Beschreibung (optional)",
        "en": "Description (optional)"
    },
    "labelContentOptional": {
        "de": "Inhalt (optional)",
        "en": "Content (optional)"
    },
    "labelTitleRequired": {
        "de": "Titel *",
        "en": "Title *"
    },
    "labelType": {
        "de": "Typ",
        "en": "Type"
    },
    "labelLocation": {
        "de": "Ort",
        "en": "Location"
    },
    "labelLocationDetails": {
        "de": "Ort Details",
        "en": "Location Details"
    },
    "labelNote": {
        "de": "Notiz",
        "en": "Note"
    },
    "labelReminder": {
        "de": "Erinnerung",
        "en": "Reminder"
    },
    "labelCustomMinutes": {
        "de": "Custom Minuten",
        "en": "Custom Minutes"
    },
    "labelSubject": {
        "de": "Betreff",
        "en": "Subject"
    },
    "hintShortDescription": {
        "de": "Kurze Beschreibung des Anliegens",
        "en": "Brief description of your concern"
    },
    "hintDescribeInDetail": {
        "de": "Beschreibe dein Anliegen so genau wie möglich…",
        "en": "Describe your concern in as much detail as possible…"
    },
    "labelInviteCodeValue": {
        "de": "Code: {code}",
        "en": "Code: {code}"
    },
    "@labelInviteCodeValue": {
        "placeholders": {
            "code": {"type": "String"}
        }
    },

    # ── Empty States ───────────────────────────────────────────────────
    "emptyTasksInPlan": {
        "de": "Noch keine Aufgaben im Plan.",
        "en": "No tasks in the plan yet."
    },
    "emptyNoEntries": {
        "de": "Noch keine Einträge",
        "en": "No entries yet"
    },
    "emptyWoundDocHint": {
        "de": "Dokumentiere deine Wundheilung mit Fotos,\nSchmerzwerten und Notizen.",
        "en": "Document your wound healing with photos,\npain levels, and notes."
    },
    "emptyNoPhotos": {
        "de": "Keine Fotos vorhanden",
        "en": "No photos available"
    },
    "emptyWoundCompareHint": {
        "de": "Dokumentiere mindestens zwei Einträge\nmit Foto, um den Verlauf zu vergleichen.",
        "en": "Document at least two entries\nwith a photo to compare progress."
    },
    "emptyNoNotifications": {
        "de": "Keine Benachrichtigungen",
        "en": "No notifications"
    },
    "emptyTodayNoEntries": {
        "de": "Heute: keine Einträge",
        "en": "Today: no entries"
    },
    "empty7DaysNoData": {
        "de": "7 Tage: keine Daten",
        "en": "7 days: no data"
    },
    "emptyNoVitals": {
        "de": "Noch keine Vitalwerte erfasst",
        "en": "No vital signs recorded yet"
    },
    "emptyNoVitalsShort": {
        "de": "Noch keine Vitalwerte",
        "en": "No vital signs yet"
    },
    "emptyNoRedFlags": {
        "de": "Keine offenen Red Flags",
        "en": "No open red flags"
    },
    "emptyNoMacros": {
        "de": "Keine Makros erfasst",
        "en": "No macros recorded"
    },

    # ── Analytics Tabs ─────────────────────────────────────────────────
    "analyticsOverview": {
        "de": "Übersicht",
        "en": "Overview"
    },
    "analyticsPain": {
        "de": "Schmerz",
        "en": "Pain"
    },
    "analyticsVitals": {
        "de": "Vitals",
        "en": "Vitals"
    },
    "analyticsWounds": {
        "de": "Wunden",
        "en": "Wounds"
    },
    "analyticsNutrition": {
        "de": "Ernährung",
        "en": "Nutrition"
    },

    # ── Notification Channels ──────────────────────────────────────────
    "notifObservationFrom": {
        "de": "Beobachtung von {name}",
        "en": "Observation from {name}"
    },
    "@notifObservationFrom": {
        "placeholders": {
            "name": {"type": "String"}
        }
    },
    "notifWoundAlarm": {
        "de": "Wundalarm",
        "en": "Wound Alert"
    },
    "notifDoctorAnswered": {
        "de": "Dr. {name} hat deine Frage beantwortet",
        "en": "Dr. {name} answered your question"
    },
    "@notifDoctorAnswered": {
        "placeholders": {
            "name": {"type": "String"}
        }
    },
    "notifChannelAppointments": {
        "de": "Erinnerungen fuer anstehende Termine",
        "en": "Reminders for upcoming appointments"
    },
    "notifChannelMedication": {
        "de": "Medikamentenwecker",
        "en": "Medication Reminder"
    },
    "notifChannelMedicationDesc": {
        "de": "Taegliche Erinnerungen fuer Medikamente",
        "en": "Daily reminders for medications"
    },
    "notifChannelVitals": {
        "de": "Vitalwerte Erinnerung",
        "en": "Vital Signs Reminder"
    },
    "notifChannelVitalsDesc": {
        "de": "Taegliche Erinnerung zur Vitalwerte-Messung",
        "en": "Daily reminder for vital sign measurements"
    },
    "notifMeasureVitals": {
        "de": "Vitalwerte messen",
        "en": "Measure vital signs"
    },

    # ── Gamification ───────────────────────────────────────────────────
    "badgeMedicationHero": {
        "de": "Medikamenten-Held",
        "en": "Medication Hero"
    },
    "badgeMedicationHeroDesc": {
        "de": "7 Tage keine Einnahme verpasst",
        "en": "7 days without a missed dose"
    },
    "badgePainTracker": {
        "de": "Schmerz-Tracker",
        "en": "Pain Tracker"
    },
    "badgePainTrackerDesc": {
        "de": "20× Schmerzen dokumentiert",
        "en": "Documented pain 20 times"
    },
    "badgeMoodTrackerDesc": {
        "de": "20× Stimmung dokumentiert",
        "en": "Documented mood 20 times"
    },

    # ── Quick Actions ──────────────────────────────────────────────────
    "actionUnlock": {
        "de": "Freischalten",
        "en": "Unlock"
    },
    "actionCall112": {
        "de": "112 anrufen",
        "en": "Call 112"
    },

    # ── Care Plan Templates (domain/care_plan_templates.dart) ──────────
    # Pre-operation
    "cpCheckDocuments": {
        "de": "Unterlagen prüfen",
        "en": "Check documents"
    },
    "cpCheckDocumentsDesc": {
        "de": "Versichertenkarte und Befunde bereitlegen",
        "en": "Prepare insurance card and medical records"
    },
    "cpInformCompanion": {
        "de": "Begleitperson informieren",
        "en": "Inform companion"
    },
    "cpInformCompanionDesc": {
        "de": "Anfahrt und Treffpunkt abstimmen",
        "en": "Coordinate travel and meeting point"
    },
    "cpPackHospitalBag": {
        "de": "Klinik-Tasche packen",
        "en": "Pack hospital bag"
    },
    "cpPackHospitalBagDesc": {
        "de": "Dokumente, Kleidung und Ladegerät einpacken",
        "en": "Pack documents, clothing, and charger"
    },
    "cpAdmission": {
        "de": "Aufnahme",
        "en": "Admission"
    },
    "cpAdmissionDesc": {
        "de": "Bitte pünktlich in der Klinik melden",
        "en": "Please report to the clinic on time"
    },
    "cpCheckFasting": {
        "de": "Nüchternheit prüfen",
        "en": "Check fasting status"
    },
    "cpCheckFastingDesc": {
        "de": "Nichts essen oder trinken laut Anweisung",
        "en": "No food or drink as instructed"
    },
    "cpConfirmOpInfo": {
        "de": "OP-Infos bestätigen",
        "en": "Confirm surgery info"
    },
    "cpConfirmOpInfoDesc": {
        "de": "Offene Rückfragen mit Team klären",
        "en": "Clarify open questions with the team"
    },
    # Post-operation Week 1
    "cpFirstMobilisation": {
        "de": "Erste Mobilisation",
        "en": "First mobilisation"
    },
    "cpFirstMobilisationDesc": {
        "de": "Mit Unterstützung kurz aufsetzen/aufstehen",
        "en": "Briefly sit up/stand with support"
    },
    "cpTakeWoundPhoto": {
        "de": "Wundfoto aufnehmen",
        "en": "Take wound photo"
    },
    "cpTakeWoundPhotoDesc": {
        "de": "Foto für Verlauf dokumentieren",
        "en": "Document photo for progress tracking"
    },
    "cpRecordPainLevel": {
        "de": "Schmerzstärke erfassen",
        "en": "Record pain level"
    },
    "cpRecordPainLevelDesc": {
        "de": "Schmerzlevel in der App eintragen",
        "en": "Enter pain level in the app"
    },
    "cpCheckVitals": {
        "de": "Vitalwerte prüfen",
        "en": "Check vital signs"
    },
    "cpCheckVitalsDesc": {
        "de": "Puls/Temperatur kurz notieren",
        "en": "Briefly note pulse/temperature"
    },
    "cpBandageCheck": {
        "de": "Verbandkontrolle",
        "en": "Bandage check"
    },
    "cpBandageCheckDesc": {
        "de": "Verbandzustand prüfen und dokumentieren",
        "en": "Check and document bandage condition"
    },
    "cpTakeMedication": {
        "de": "Medikation einnehmen",
        "en": "Take medication"
    },
    "cpMorningDose": {
        "de": "Morgendosis laut Plan",
        "en": "Morning dose as scheduled"
    },
    "cpNoonDose": {
        "de": "Mittagsdosis laut Plan",
        "en": "Noon dose as scheduled"
    },
    "cpEveningDose": {
        "de": "Abenddosis laut Plan",
        "en": "Evening dose as scheduled"
    },
    "cpCheckFluidIntake": {
        "de": "Trinkmenge prüfen",
        "en": "Check fluid intake"
    },
    "cpCheckFluidIntakeDesc": {
        "de": "Mindestens 1,5 Liter Flüssigkeit am Tag",
        "en": "At least 1.5 liters of fluids per day"
    },
    "cpCheckWarnings": {
        "de": "Warnsignale prüfen",
        "en": "Check warning signs"
    },
    "cpCheckWarningsDesc": {
        "de": "Fieber, Rötung, Schwellung, starke Schmerzen?",
        "en": "Fever, redness, swelling, severe pain?"
    },
    # Heart surgery specific
    "cpCompressionStockings": {
        "de": "Kompressionsstrümpfe prüfen",
        "en": "Check compression stockings"
    },
    "cpCompressionStockingsDesc": {
        "de": "Sitz und Zustand der Strümpfe kontrollieren",
        "en": "Check fit and condition of stockings"
    },
    "cpLegExercises": {
        "de": "Beinübungen durchführen",
        "en": "Perform leg exercises"
    },
    "cpLegExercisesDesc": {
        "de": "Füße kreisen, Beine anspannen – Thromboseprophylaxe",
        "en": "Circle feet, tense legs – thrombosis prevention"
    },
    "cpBreathingExercises": {
        "de": "Atemübungen",
        "en": "Breathing exercises"
    },
    "cpBreathingExercisesHeartDesc": {
        "de": "Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herz-OP",
        "en": "Deep breaths for lung care – especially important after heart surgery"
    },
    "cpSternumProtection": {
        "de": "Brustbein-Schonung",
        "en": "Sternum protection"
    },
    "cpSternumProtectionDesc": {
        "de": "Kein Heben über 5 kg, Arme eng am Körper halten",
        "en": "No lifting over 5 kg, keep arms close to body"
    },
    "cpCardiacRehabExercises": {
        "de": "Herzreha-Übungen",
        "en": "Cardiac rehab exercises"
    },
    "cpCardiacRehabExercisesDesc": {
        "de": "Leichtes Gehen, Kreislauf langsam aufbauen",
        "en": "Light walking, gradually build circulation"
    },
    # Abdominal surgery specific
    "cpDietProgression": {
        "de": "Kostaufbau",
        "en": "Diet progression"
    },
    "cpDietProgressionDesc": {
        "de": "Leichte Kost, Schonkost → langsam steigern",
        "en": "Light food, bland diet → gradually increase"
    },
    "cpAbdominalProtection": {
        "de": "Bauchmuskel-Schonung",
        "en": "Abdominal muscle protection"
    },
    "cpAbdominalProtectionDesc": {
        "de": "Nicht pressen, beim Aufstehen seitlich abrollen",
        "en": "No straining, roll to the side when getting up"
    },
    "cpAbdominalBelt": {
        "de": "Bauchgürtel/Stütze prüfen",
        "en": "Check abdominal belt/support"
    },
    "cpAbdominalBeltDesc": {
        "de": "Sitz und Trageweise kontrollieren",
        "en": "Check fit and wearing method"
    },
    "cpDocumentBowel": {
        "de": "Stuhlgang dokumentieren",
        "en": "Document bowel movements"
    },
    "cpDocumentBowelDesc": {
        "de": "Verdauung beobachten – wichtig für Kostaufbau",
        "en": "Monitor digestion – important for diet progression"
    },
    # Spinal surgery specific
    "cpSpineProtection": {
        "de": "Rücken-Schonhaltung",
        "en": "Back protection posture"
    },
    "cpSpineProtectionDesc": {
        "de": "Keine Dreh- oder Beugebewegungen der Wirbelsäule",
        "en": "No twisting or bending of the spine"
    },
    "cpCheckOrthosis": {
        "de": "Orthese/Korsett prüfen",
        "en": "Check orthosis/corset"
    },
    "cpCheckOrthosisDesc": {
        "de": "Sitz und Tragezeit kontrollieren",
        "en": "Check fit and wearing time"
    },
    "cpBreathingExercisesSpineDesc": {
        "de": "Tiefe Atemzüge – Rücken gerade, sanft atmen",
        "en": "Deep breaths – back straight, breathe gently"
    },
    "cpStabilisationExercises": {
        "de": "Stabilisationsübungen",
        "en": "Stabilisation exercises"
    },
    "cpStabilisationExercisesDesc": {
        "de": "Rumpf-Stabilisation nach Anleitung – langsam steigern",
        "en": "Core stabilisation as instructed – gradually increase"
    },
    # Recovery tracking
    "cpObserveWound": {
        "de": "Wunde beobachten",
        "en": "Observe wound"
    },
    "cpObserveWoundDesc": {
        "de": "Heilungsverlauf kontrollieren und dokumentieren",
        "en": "Monitor and document healing progress"
    },
    "cpPainDiary": {
        "de": "Schmerztagebuch",
        "en": "Pain diary"
    },
    "cpPainDiaryDesc": {
        "de": "Schmerzverlauf dokumentieren – wird es besser?",
        "en": "Document pain progression – is it improving?"
    },
    "cpGoForWalk": {
        "de": "Spaziergang machen",
        "en": "Go for a walk"
    },
    "cpGoForWalkDesc": {
        "de": "Täglich etwas weiter gehen – Kreislauf stärken",
        "en": "Walk a little further every day – strengthen circulation"
    },
    "cpPhysioExercises": {
        "de": "Physiotherapie-Übungen",
        "en": "Physiotherapy exercises"
    },
    "cpPhysioExercisesDesc": {
        "de": "Übungen laut Anleitung durchführen",
        "en": "Perform exercises as instructed"
    },
    "cpGaitTraining": {
        "de": "Gangtraining",
        "en": "Gait training"
    },
    "cpGaitTrainingDesc": {
        "de": "Sicheres Gehen mit/ohne Hilfsmittel üben",
        "en": "Practice safe walking with/without aids"
    },
    "cpCardiacRehabWalk": {
        "de": "Herzreha-Spaziergang",
        "en": "Cardiac rehab walk"
    },
    "cpCardiacRehabWalkDesc": {
        "de": "Gehstrecke langsam steigern, Puls beobachten",
        "en": "Gradually increase walking distance, monitor pulse"
    },
    "cpNormalDietProgression": {
        "de": "Normalkost aufbauen",
        "en": "Build up normal diet"
    },
    "cpNormalDietProgressionDesc": {
        "de": "Verdauung beobachten – langsam zur Normalkost",
        "en": "Monitor digestion – gradually return to normal diet"
    },
    "cpFollowUpAppointment": {
        "de": "Kontrolltermin",
        "en": "Follow-up appointment"
    },
    "cpFollowUpDesc1": {
        "de": "Verlaufskontrolle in der Praxis",
        "en": "Progress check at the clinic"
    },
    "cpFollowUpDesc2": {
        "de": "Zweite Verlaufskontrolle",
        "en": "Second progress check"
    },
    "cpFollowUpDesc3": {
        "de": "Dritte Verlaufskontrolle",
        "en": "Third progress check"
    },
    "cpScarCare": {
        "de": "Narbenpflege",
        "en": "Scar care"
    },
    "cpScarCareDesc": {
        "de": "Narbe sanft eincremen und beobachten",
        "en": "Gently apply cream to scar and monitor"
    },
    "cpIncreaseActivity": {
        "de": "Belastung steigern",
        "en": "Increase activity"
    },
    "cpIncreaseActivityDesc": {
        "de": "Aktivität langsam erhöhen – auf Körpersignale achten",
        "en": "Slowly increase activity – pay attention to body signals"
    },
    "cpTakeWoundPhotoProgress": {
        "de": "Wundfoto aufnehmen",
        "en": "Take wound photo"
    },
    "cpTakeWoundPhotoProgressDesc": {
        "de": "Heilungsverlauf weiter dokumentieren",
        "en": "Continue documenting healing progress"
    },
    "cpWeeklySelfCheck": {
        "de": "Wöchentlicher Selbst-Check",
        "en": "Weekly self-check"
    },
    "cpWeeklySelfCheckDesc": {
        "de": "Heilungsfortschritt bewerten und dokumentieren",
        "en": "Evaluate and document healing progress"
    },
    "cpFinalCheck": {
        "de": "Abschlusskontrolle",
        "en": "Final check-up"
    },
    "cpFinalCheckDesc": {
        "de": "Abschließende Untersuchung und Freigabe",
        "en": "Final examination and clearance"
    },

    # ── Pro Banner ─────────────────────────────────────────────────────
    "proActiveTitle": {
        "de": "Pro aktiv",
        "en": "Pro active"
    },
    "proActiveSubtitle": {
        "de": "Alle Funktionen freigeschaltet",
        "en": "All features unlocked"
    },
}


def insert_keys():
    for arb_path, lang in [(DE_ARB, 'de'), (EN_ARB, 'en')]:
        with open(arb_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        added = 0
        for key, translations in NEW_KEYS.items():
            if key.startswith('@') and not key.startswith('@@'):
                # Metadata entry – insert as-is
                if key not in data:
                    data[key] = translations
                    added += 1
            elif key not in data:
                data[key] = translations[lang]
                added += 1

        # Write back with sorted keys (@@locale first, then @ metadata near their keys)
        sorted_data = {}
        # Always put @@locale first
        if '@@locale' in data:
            sorted_data['@@locale'] = data.pop('@@locale')

        # Group regular keys with their @ metadata
        regular_keys = sorted(k for k in data if not k.startswith('@'))
        for k in regular_keys:
            sorted_data[k] = data[k]
            meta_key = f'@{k}'
            if meta_key in data:
                sorted_data[meta_key] = data[meta_key]

        with open(arb_path, 'w', encoding='utf-8') as f:
            json.dump(sorted_data, f, ensure_ascii=False, indent=2)
            f.write('\n')

        print(f'[{lang}] Added {added} new keys. Total: {len(sorted_data)}')


if __name__ == '__main__':
    insert_keys()
    print('Done! Run: flutter gen-l10n')
