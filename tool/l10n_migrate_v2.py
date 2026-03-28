#!/usr/bin/env python3
"""
Comprehensive l10n migration script.
Adds missing ARB keys and replaces hardcoded strings in Dart files.
"""
import json
import os
import re

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DE_ARB = os.path.join(BASE, 'lib', 'l10n', 'app_de.arb')
EN_ARB = os.path.join(BASE, 'lib', 'l10n', 'app_en.arb')

# ─── New ARB keys to add ───────────────────────────────────────
NEW_KEYS_DE = {
    # General / shared
    "fehlerGeneric": "Fehler: {error}",
    "@fehlerGeneric": {"placeholders": {"error": {"type": "String"}}},
    "nurInDebugBuilds": "Nur in Debug-Builds verf\u00fcgbar.",
    "roleDebug": "Role Debug",
    "verbindungTrennen": "Verbindung trennen",
    "verbindungFehlgeschlagen": "Verbindung fehlgeschlagen. Bitte versuche es erneut.",
    "exportFehlgeschlagen": "Export fehlgeschlagen.",
    "csvExportieren": "CSV exportieren",
    "profilGespeichert": "Profil gespeichert.",
    "fehlerBeimSpeichern": "Fehler beim Speichern.",
    "fehlerBeimSpeichernErneut": "Fehler beim Speichern. Bitte versuche es erneut.",
    "neuesPasswort": "Neues Passwort",
    "neuesPasswortFuer": "Neues Passwort f\u00fcr {name}",
    "@neuesPasswortFuer": {"placeholders": {"name": {"type": "String"}}},
    "mitarbeiterAction": "Mitarbeiter {action}",
    "@mitarbeiterAction": {"placeholders": {"action": {"type": "String"}}},
    "mitarbeiterEntfernt": "{name} wurde entfernt",
    "@mitarbeiterEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "einladungscode": "Einladungscode",
    "prioritaet": "Priorit\u00e4t",
    "wochentage": "Wochentage",
    "alleMarkieren": "Alle \u2192",
    "ticketErstellen": "Ticket erstellen",
    "ticketsCountOffen": "Tickets ({count} offen)",
    "@ticketsCountOffen": {"placeholders": {"count": {"type": "int"}}},
    "statusMitLabel": "Status: {label}",
    "@statusMitLabel": {"placeholders": {"label": {"type": "String"}}},

    # Snackbar / feedback messages
    "aufnahmeStartFehler": "Aufnahme konnte nicht gestartet werden.",
    "fotoLadeFehler": "Foto konnte nicht geladen werden.",
    "keinFotoAnalyse": "Kein Foto f\u00fcr die Analyse vorhanden.",
    "schmerzScore": "Schmerz: {score}/10",
    "@schmerzScore": {"placeholders": {"score": {"type": "int"}}},
    "schmerzlevel": "Schmerzlevel: {level}/10",
    "@schmerzlevel": {"placeholders": {"level": {"type": "int"}}},
    "warnzeichenGespeichert": "Warnzeichen-Check gespeichert ({level})",
    "@warnzeichenGespeichert": {"placeholders": {"level": {"type": "String"}}},

    # Templates/tasks
    "nameDerVorlage": "Name der Vorlage",
    "vorlagenDurchsuchen": "Vorlagen durchsuchen...",
    "vorlageErstellt": "Vorlage \"{name}\" erstellt",
    "@vorlageErstellt": {"placeholders": {"name": {"type": "String"}}},
    "vorlageUebernommen": "\"{name}\" in eigene Vorlagen \u00fcbernommen",
    "@vorlageUebernommen": {"placeholders": {"name": {"type": "String"}}},
    "vorlageLoeschenBestaetigung": "M\u00f6chten Sie \"{name}\" wirklich l\u00f6schen?",
    "@vorlageLoeschenBestaetigung": {"placeholders": {"name": {"type": "String"}}},
    "tagEingeben": "Tag eingeben...",
    "aufgabenAuswaehlenCount": "Aufgaben ausw\u00e4hlen ({selected}/{total}):",
    "@aufgabenAuswaehlenCount": {"placeholders": {"selected": {"type": "int"}, "total": {"type": "int"}}},
    "aufgabenCountSelected": "{count} Aufgabe{suffix} ausgew\u00e4hlt",
    "@aufgabenCountSelected": {"placeholders": {"count": {"type": "int"}, "suffix": {"type": "String"}}},
    "sonstige": "Sonstige",
    "alleAbwaehlen": "Alle abw\u00e4hlen",
    "alleAuswaehlen": "Alle ausw\u00e4hlen",

    # Appointment/calendar
    "patientAuswaehlen": "Patient ausw\u00e4hlen",
    "unwiderruflichLoeschen": "\"{title}\" wird unwiderruflich gel\u00f6scht.",
    "@unwiderruflichLoeschen": {"placeholders": {"title": {"type": "String"}}},

    # Doctor staff/patients
    "ihreAntwortEingeben": "Ihre Antwort eingeben\u2026",
    "wunddokumentation": "Wunddokumentation",

    # Medication
    "medikamentEntfernt": "{name} entfernt",
    "@medikamentEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "medikamentWiederhergestellt": "{name} wiederhergestellt",
    "@medikamentWiederhergestellt": {"placeholders": {"name": {"type": "String"}}},
    "medikamentWirdEntfernt": "{name} wird entfernt.",
    "@medikamentWirdEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "einnahmeDokumentieren": "Einnahme dokumentieren",
    "zbNachDemEssen": "z.B. nach dem Essen mit Wasser einnehmen",

    # Nutrition
    "zbVollkornbrot": "z. B. Vollkornbrot mit Quark und Tomaten",
    "templateWirdEntfernt": "\"{name}\" wird entfernt.",
    "@templateWirdEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "mahlzeitSpeichern": "Mahlzeit speichern",

    # Mood
    "wasBeschaeftigtDich": "Was besch\u00e4ftigt dich gerade?",

    # Packing
    "zbDieBlaue": "z.B. Die blaue, nicht die rote",
    "neuerName": "Neuer Name",
    "fotosDurchsuchen": "Fotos durchsuchen (Datum, Notiz, Kategorie)\u2026",

    # Rehab
    "uebungSuchen": "\u00dcbung suchen\u2026",

    # Pro
    "monatlichKuendbar": "monatlich k\u00fcndbar",

    # Sleep
    "fehlerMitDetails": "Fehler: {error}",
    "@fehlerMitDetails": {"placeholders": {"error": {"type": "String"}}},

    # Voice
    "zbBefund": "z.B. Befund",
    "transkriptBearbeiten": "Transkript bearbeiten\u2026",

    # Support
    "beschreibeAnliegen": "Beschreibe dein Anliegen so genau wie m\u00f6glich\u2026",

    # Vitals
    "neueMessungenSync": "{count} neue Messungen aus Health synchronisiert",
    "@neueMessungenSync": {"placeholders": {"count": {"type": "int"}}},

    # Onboarding
    "fehlerSpeichernErneut": "Fehler beim Speichern. Bitte versuche es erneut.",

    # Organisation
    "doctorHinzugefuegt": "{name} wurde hinzugef\u00fcgt",
    "@doctorHinzugefuegt": {"placeholders": {"name": {"type": "String"}}},
    "anfrageAblehnenBestaetigung": "M\u00f6chten Sie die Anfrage von {name} ablehnen?",
    "@anfrageAblehnenBestaetigung": {"placeholders": {"name": {"type": "String"}}},
    "grundOptional": "Grund (optional)",
    "doctorEntfernt": "{name} wurde entfernt",
    "@doctorEntfernt": {"placeholders": {"name": {"type": "String"}}},

    # Family
    "weiterenPatientenHinzufuegen": "Weiteren Patienten hinzuf\u00fcgen",

    # Wound
    "koerperstelleOptional": "K\u00f6rperstelle (optional)",

    # Documents
    "dokumentGeloescht": "\"{title}\" gel\u00f6scht",
    "@dokumentGeloescht": {"placeholders": {"title": {"type": "String"}}},

    # Admin
    "adminAbmeldenBestaetigung": "Wirklich aus dem Admin-Bereich abmelden?",
    "benachrichtigungenCountNeu": "Benachrichtigungen ({count} neu)",
    "@benachrichtigungenCountNeu": {"placeholders": {"count": {"type": "int"}}},
    "testBenachrichtigungErstellen": "Test-Benachrichtigung erstellen",
    "alleAlsGelesenMarkieren": "Alle als gelesen markieren",
    "suchenNameEmailUid": "Suchen (Name, E-Mail oder UID)\u2026",
    "statsNichtAktualisiert": "Stats konnten nicht aktualisiert werden.",
    "hinweistextOptional": "Hinweistext (optional)",
    "zbUpdateWirdEingespielt": "z.B. Update wird eingespielt\u2026",
    "statistikenAktualisieren": "Statistiken aktualisieren",
    "rolleGeaendert": "Rolle auf \"{role}\" ge\u00e4ndert.",
    "@rolleGeaendert": {"placeholders": {"role": {"type": "String"}}},
    "grundDerSperrung": "Grund der Sperrung \u2026",
    "userAktionFehler": "User konnte nicht {action}t werden.",
    "@userAktionFehler": {"placeholders": {"action": {"type": "String"}}},
    "pushAnEmail": "Push an {email}",
    "@pushAnEmail": {"placeholders": {"email": {"type": "String"}}},
    "pushAnEmailGesendet": "Push an {email} gesendet.",
    "@pushAnEmailGesendet": {"placeholders": {"email": {"type": "String"}}},
    "nachRolleFiltern": "Nach Rolle filtern",
    "pushSenden": "Push",
    "tageVergeben": "{days} Tage vergeben",
    "@tageVergeben": {"placeholders": {"days": {"type": "int"}}},
    "nameWurdeGesperrt": "{name} wurde gesperrt.",
    "@nameWurdeGesperrt": {"placeholders": {"name": {"type": "String"}}},
    "nameWurdeEntsperrt": "{name} wurde entsperrt.",
    "@nameWurdeEntsperrt": {"placeholders": {"name": {"type": "String"}}},
    "nameWurdeGeloescht": "{name} wurde gel\u00f6scht.",
    "@nameWurdeGeloescht": {"placeholders": {"name": {"type": "String"}}},
    "begruendungEingeben": "Begr\u00fcndung eingeben \u2026",
    "gueltigFuerTage": "G\u00fcltig f\u00fcr {days} Tage",
    "@gueltigFuerTage": {"placeholders": {"days": {"type": "int"}}},
    "fehlerMitError": "Fehler: {error}",
    "@fehlerMitError": {"placeholders": {"error": {"type": "String"}}},
    "statusFiltern": "Status filtern",
    "erstelltVon": "Erstellt von: {name}",
    "@erstelltVon": {"placeholders": {"name": {"type": "String"}}},
    "grundEingeben": "Grund eingeben\u2026",
    "keysErstellt": "{count} Keys erstellt",
    "@keysErstellt": {"placeholders": {"count": {"type": "int"}}},
    "neuerKey": "Neuer Key",
    "keyIdOderUidSuchen": "Key-ID oder Einl\u00f6ser-UID suchen\u2026",
    "pushAnTargetGesendet": "Push an {target} gesendet!",
    "@pushAnTargetGesendet": {"placeholders": {"target": {"type": "String"}}},
    "rolleAuswaehlen": "Rolle ausw\u00e4hlen",
    "vorlage": "Vorlage",
    "systemVorlageFehler": "Fehler: {error}",
    "@systemVorlageFehler": {"placeholders": {"error": {"type": "String"}}},
    "aufgabenCount": "Aufgaben ({count})",
    "@aufgabenCount": {"placeholders": {"count": {"type": "int"}}},

    # Caregiver
    "caregiverEntfernt": "{name} wurde entfernt",
    "@caregiverEntfernt": {"placeholders": {"name": {"type": "String"}}},

    # Help screen
    "keineEmailApp": "Keine E-Mail-App gefunden",

    # Profile settings
    "profilGespeichertKurz": "Profil gespeichert",
    "auswaehlen": "Ausw\u00e4hlen",
    "labelHinzufuegen": "{label} hinzuf\u00fcgen",
    "@labelHinzufuegen": {"placeholders": {"label": {"type": "String"}}},
    "bezeichnungEingeben": "Bezeichnung eingeben",

    # Vital signs screen
    "messungGespeichert": "Messung gespeichert",

    # Partner ads
    "partnerAnzeigenCount": "Partner-Anzeigen ({count})",
    "@partnerAnzeigenCount": {"placeholders": {"count": {"type": "int"}}},
    "fehlerBeimErstellen": "Fehler beim Erstellen.",

    # doctor_notes
    "notizLoeschenBestaetigung": "\"{title}\" wirklich l\u00f6schen?",
    "@notizLoeschenBestaetigung": {"placeholders": {"title": {"type": "String"}}},

    # doctor_overview
    "cloneErstellt": "\"{name}\" erstellt",
    "@cloneErstellt": {"placeholders": {"name": {"type": "String"}}},

    # Zeitfilter
    "zeitfilterZuruecksetzen": "Zeitfilter zur\u00fccksetzen",

    # family_member_hub
    "userGesperrtEntsperrt": "User {action}.",
    "@userGesperrtEntsperrt": {"placeholders": {"action": {"type": "String"}}},

    # Speichert / Erstelle states
    "speichert": "Speichert...",
    "erstelle": "Erstelle...",
    "wirdZugewiesen": "Wird zugewiesen...",
    "speichere": "Speichere...",
    "vorlageErzeugen": "Vorlage erstellen",

    # Misc
    "bildAuswaehlen": "Bild ausw\u00e4hlen",
    "proEntziehen": "Pro entziehen",
    "proGeben": "Pro geben",
    "losGehts": "Los geht\u2019s",
    "freischalten": "Freischalten",
}

NEW_KEYS_EN = {
    "fehlerGeneric": "Error: {error}",
    "@fehlerGeneric": {"placeholders": {"error": {"type": "String"}}},
    "nurInDebugBuilds": "Only available in debug builds.",
    "roleDebug": "Role Debug",
    "verbindungTrennen": "Disconnect",
    "verbindungFehlgeschlagen": "Connection failed. Please try again.",
    "exportFehlgeschlagen": "Export failed.",
    "csvExportieren": "Export CSV",
    "profilGespeichert": "Profile saved.",
    "fehlerBeimSpeichern": "Error saving.",
    "fehlerBeimSpeichernErneut": "Error saving. Please try again.",
    "neuesPasswort": "New password",
    "neuesPasswortFuer": "New password for {name}",
    "@neuesPasswortFuer": {"placeholders": {"name": {"type": "String"}}},
    "mitarbeiterAction": "Staff member {action}",
    "@mitarbeiterAction": {"placeholders": {"action": {"type": "String"}}},
    "mitarbeiterEntfernt": "{name} was removed",
    "@mitarbeiterEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "einladungscode": "Invitation code",
    "prioritaet": "Priority",
    "wochentage": "Weekdays",
    "alleMarkieren": "All \u2192",
    "ticketErstellen": "Create ticket",
    "ticketsCountOffen": "Tickets ({count} open)",
    "@ticketsCountOffen": {"placeholders": {"count": {"type": "int"}}},
    "statusMitLabel": "Status: {label}",
    "@statusMitLabel": {"placeholders": {"label": {"type": "String"}}},
    "aufnahmeStartFehler": "Could not start recording.",
    "fotoLadeFehler": "Could not load photo.",
    "keinFotoAnalyse": "No photo available for analysis.",
    "schmerzScore": "Pain: {score}/10",
    "@schmerzScore": {"placeholders": {"score": {"type": "int"}}},
    "schmerzlevel": "Pain level: {level}/10",
    "@schmerzlevel": {"placeholders": {"level": {"type": "int"}}},
    "warnzeichenGespeichert": "Warning sign check saved ({level})",
    "@warnzeichenGespeichert": {"placeholders": {"level": {"type": "String"}}},
    "nameDerVorlage": "Template name",
    "vorlagenDurchsuchen": "Search templates...",
    "vorlageErstellt": "Template \"{name}\" created",
    "@vorlageErstellt": {"placeholders": {"name": {"type": "String"}}},
    "vorlageUebernommen": "\"{name}\" copied to own templates",
    "@vorlageUebernommen": {"placeholders": {"name": {"type": "String"}}},
    "vorlageLoeschenBestaetigung": "Do you really want to delete \"{name}\"?",
    "@vorlageLoeschenBestaetigung": {"placeholders": {"name": {"type": "String"}}},
    "tagEingeben": "Enter day...",
    "aufgabenAuswaehlenCount": "Select tasks ({selected}/{total}):",
    "@aufgabenAuswaehlenCount": {"placeholders": {"selected": {"type": "int"}, "total": {"type": "int"}}},
    "aufgabenCountSelected": "{count} task{suffix} selected",
    "@aufgabenCountSelected": {"placeholders": {"count": {"type": "int"}, "suffix": {"type": "String"}}},
    "sonstige": "Other",
    "alleAbwaehlen": "Deselect all",
    "alleAuswaehlen": "Select all",
    "patientAuswaehlen": "Select patient",
    "unwiderruflichLoeschen": "\"{title}\" will be permanently deleted.",
    "@unwiderruflichLoeschen": {"placeholders": {"title": {"type": "String"}}},
    "ihreAntwortEingeben": "Enter your answer\u2026",
    "wunddokumentation": "Wound documentation",
    "medikamentEntfernt": "{name} removed",
    "@medikamentEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "medikamentWiederhergestellt": "{name} restored",
    "@medikamentWiederhergestellt": {"placeholders": {"name": {"type": "String"}}},
    "medikamentWirdEntfernt": "{name} will be removed.",
    "@medikamentWirdEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "einnahmeDokumentieren": "Document intake",
    "zbNachDemEssen": "e.g. take with water after meals",
    "zbVollkornbrot": "e.g. whole grain bread with cream cheese and tomatoes",
    "templateWirdEntfernt": "\"{name}\" will be removed.",
    "@templateWirdEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "mahlzeitSpeichern": "Save meal",
    "wasBeschaeftigtDich": "What's on your mind right now?",
    "zbDieBlaue": "e.g. The blue one, not the red one",
    "neuerName": "New name",
    "fotosDurchsuchen": "Search photos (date, note, category)\u2026",
    "uebungSuchen": "Search exercise\u2026",
    "monatlichKuendbar": "cancel monthly",
    "fehlerMitDetails": "Error: {error}",
    "@fehlerMitDetails": {"placeholders": {"error": {"type": "String"}}},
    "zbBefund": "e.g. Finding",
    "transkriptBearbeiten": "Edit transcript\u2026",
    "beschreibeAnliegen": "Describe your issue as precisely as possible\u2026",
    "neueMessungenSync": "{count} new measurements synced from Health",
    "@neueMessungenSync": {"placeholders": {"count": {"type": "int"}}},
    "fehlerSpeichernErneut": "Error saving. Please try again.",
    "doctorHinzugefuegt": "{name} was added",
    "@doctorHinzugefuegt": {"placeholders": {"name": {"type": "String"}}},
    "anfrageAblehnenBestaetigung": "Do you want to reject the request from {name}?",
    "@anfrageAblehnenBestaetigung": {"placeholders": {"name": {"type": "String"}}},
    "grundOptional": "Reason (optional)",
    "doctorEntfernt": "{name} was removed",
    "@doctorEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "weiterenPatientenHinzufuegen": "Add another patient",
    "koerperstelleOptional": "Body location (optional)",
    "dokumentGeloescht": "\"{title}\" deleted",
    "@dokumentGeloescht": {"placeholders": {"title": {"type": "String"}}},
    "adminAbmeldenBestaetigung": "Really sign out of the admin area?",
    "benachrichtigungenCountNeu": "Notifications ({count} new)",
    "@benachrichtigungenCountNeu": {"placeholders": {"count": {"type": "int"}}},
    "testBenachrichtigungErstellen": "Create test notification",
    "alleAlsGelesenMarkieren": "Mark all as read",
    "suchenNameEmailUid": "Search (name, email or UID)\u2026",
    "statsNichtAktualisiert": "Stats could not be updated.",
    "hinweistextOptional": "Notice text (optional)",
    "zbUpdateWirdEingespielt": "e.g. Update is being applied\u2026",
    "statistikenAktualisieren": "Refresh statistics",
    "rolleGeaendert": "Role changed to \"{role}\".",
    "@rolleGeaendert": {"placeholders": {"role": {"type": "String"}}},
    "grundDerSperrung": "Reason for blocking \u2026",
    "userAktionFehler": "User could not be {action}ed.",
    "@userAktionFehler": {"placeholders": {"action": {"type": "String"}}},
    "pushAnEmail": "Push to {email}",
    "@pushAnEmail": {"placeholders": {"email": {"type": "String"}}},
    "pushAnEmailGesendet": "Push sent to {email}.",
    "@pushAnEmailGesendet": {"placeholders": {"email": {"type": "String"}}},
    "nachRolleFiltern": "Filter by role",
    "pushSenden": "Push",
    "tageVergeben": "{days} days granted",
    "@tageVergeben": {"placeholders": {"days": {"type": "int"}}},
    "nameWurdeGesperrt": "{name} was blocked.",
    "@nameWurdeGesperrt": {"placeholders": {"name": {"type": "String"}}},
    "nameWurdeEntsperrt": "{name} was unblocked.",
    "@nameWurdeEntsperrt": {"placeholders": {"name": {"type": "String"}}},
    "nameWurdeGeloescht": "{name} was deleted.",
    "@nameWurdeGeloescht": {"placeholders": {"name": {"type": "String"}}},
    "begruendungEingeben": "Enter reason \u2026",
    "gueltigFuerTage": "Valid for {days} days",
    "@gueltigFuerTage": {"placeholders": {"days": {"type": "int"}}},
    "fehlerMitError": "Error: {error}",
    "@fehlerMitError": {"placeholders": {"error": {"type": "String"}}},
    "statusFiltern": "Filter status",
    "erstelltVon": "Created by: {name}",
    "@erstelltVon": {"placeholders": {"name": {"type": "String"}}},
    "grundEingeben": "Enter reason\u2026",
    "keysErstellt": "{count} keys created",
    "@keysErstellt": {"placeholders": {"count": {"type": "int"}}},
    "neuerKey": "New key",
    "keyIdOderUidSuchen": "Search key ID or redeemer UID\u2026",
    "pushAnTargetGesendet": "Push to {target} sent!",
    "@pushAnTargetGesendet": {"placeholders": {"target": {"type": "String"}}},
    "rolleAuswaehlen": "Select role",
    "vorlage": "Template",
    "systemVorlageFehler": "Error: {error}",
    "@systemVorlageFehler": {"placeholders": {"error": {"type": "String"}}},
    "aufgabenCount": "Tasks ({count})",
    "@aufgabenCount": {"placeholders": {"count": {"type": "int"}}},
    "caregiverEntfernt": "{name} was removed",
    "@caregiverEntfernt": {"placeholders": {"name": {"type": "String"}}},
    "keineEmailApp": "No email app found",
    "profilGespeichertKurz": "Profile saved",
    "auswaehlen": "Select",
    "labelHinzufuegen": "Add {label}",
    "@labelHinzufuegen": {"placeholders": {"label": {"type": "String"}}},
    "bezeichnungEingeben": "Enter label",
    "messungGespeichert": "Measurement saved",
    "partnerAnzeigenCount": "Partner ads ({count})",
    "@partnerAnzeigenCount": {"placeholders": {"count": {"type": "int"}}},
    "fehlerBeimErstellen": "Error creating.",
    "notizLoeschenBestaetigung": "Really delete \"{title}\"?",
    "@notizLoeschenBestaetigung": {"placeholders": {"title": {"type": "String"}}},
    "cloneErstellt": "\"{name}\" created",
    "@cloneErstellt": {"placeholders": {"name": {"type": "String"}}},
    "zeitfilterZuruecksetzen": "Reset time filter",
    "userGesperrtEntsperrt": "User {action}.",
    "@userGesperrtEntsperrt": {"placeholders": {"action": {"type": "String"}}},
    "speichert": "Saving...",
    "erstelle": "Creating...",
    "wirdZugewiesen": "Assigning...",
    "speichere": "Saving...",
    "vorlageErzeugen": "Create template",
    "bildAuswaehlen": "Choose image",
    "proEntziehen": "Remove Pro",
    "proGeben": "Give Pro",
    "losGehts": "Let\u2019s go",
    "freischalten": "Unlock",
}


def add_arb_keys(filepath, new_keys):
    """Add new keys to an ARB file, skipping existing ones."""
    with open(filepath, 'r') as f:
        data = json.load(f)

    added = 0
    for key, value in new_keys.items():
        if key not in data:
            data[key] = value
            added += 1

    # Sort keys (@ keys follow their parent)
    sorted_data = {"@@locale": data.get("@@locale", "de")}
    regular_keys = sorted(k for k in data if not k.startswith("@"))
    for k in regular_keys:
        if k == "@@locale":
            continue
        sorted_data[k] = data[k]
        meta_key = f"@{k}"
        if meta_key in data:
            sorted_data[meta_key] = data[meta_key]

    with open(filepath, 'w') as f:
        json.dump(sorted_data, f, ensure_ascii=False, indent=2)
        f.write('\n')

    return added


# ─── Dart file replacements ───────────────────────────────────
# Each entry: (file_glob_pattern, [(old_text, new_text), ...])
# We use exact string matching on the old text.

DART_REPLACEMENTS = [
    # ── role_debug_screen.dart ──
    ("lib/auth/role_debug_screen.dart", [
        ("Text('Nur in Debug-Builds verfuegbar.')", "Text(AppLocalizations.of(context)!.nurInDebugBuilds)"),
        ("const Text('Role Debug')", "Text(AppLocalizations.of(context)!.roleDebug)"),
    ]),

    # ── firebase_smoke_test_screen.dart ──
    ("lib/debug/firebase_smoke_test_screen.dart", [
        ("Text('Nur in Debug-Builds verf\u00fcgbar.')", "Text(AppLocalizations.of(context)!.nurInDebugBuilds)"),
    ]),

    # ── ads_admin_tab.dart ──
    ("lib/features/ads/presentation/admin/ads_admin_tab.dart", [
        ("'Fehler beim Erstellen.'", "l.fehlerBeimErstellen"),
        ("'Partner-Anzeigen (${_allAds.length})'", "l.partnerAnzeigenCount(_allAds.length)"),
    ]),

    # ── appointment_filter_bar.dart ──
    ("lib/features/appointments/presentation/appointment_filter_bar.dart", [
        ("'Suche nach Titel oder Ort\u2026'", "AppLocalizations.of(context)!.sucheNachTitelOderOrt"),
    ]),

    # ── connect_doctor_screen.dart ──
    ("lib/features/doctor_invite/presentation/connect_doctor_screen.dart", [
        ("'Verbindung fehlgeschlagen. Bitte versuche es erneut.'",
         "l.verbindungFehlgeschlagen"),
    ]),

    # ── doctor_overview_tab.dart ──
    ("lib/features/doctor_overview/presentation/doctor_overview_tab.dart", [
        ("Text('Priorit\u00e4t'", "Text(l.prioritaet"),
    ]),

    # ── patient_detail_screen.dart ──
    ("lib/features/doctor_patients/presentation/patient_detail_screen.dart", [
        ("Text('Verbindung trennen')", "Text(l.verbindungTrennen)"),
        ("Text('Priorit\u00e4t'", "Text(l.prioritaet"),
        ("value: TaskType.custom, child: Text('Sonstige')", "value: TaskType.custom, child: Text(l.sonstige)"),
        ("'Name der Vorlage'", "l.nameDerVorlage"),
    ]),

    # ── patient_questions_tab.dart ──
    ("lib/features/doctor_patients/presentation/tabs/patient_questions_tab.dart", [
        ("'Ihre Antwort eingeben\u2026'", "l.ihreAntwortEingeben"),
    ]),

    # ── doctor_staff_tab.dart ──
    ("lib/features/doctor_staff/presentation/doctor_staff_tab.dart", [
        ("'Neues Passwort'", "l.neuesPasswort"),
    ]),

    # ── template_management_screen.dart ──
    ("lib/features/doctor_templates/presentation/template_management_screen.dart", [
        ("'Vorlagen durchsuchen...'", "l.vorlagenDurchsuchen"),
        ("'Name der Vorlage'", "l.nameDerVorlage"),
        ("'Tag eingeben...'", "l.tagEingeben"),
        ("Text('Priorit\u00e4t'", "Text(l.prioritaet"),
        ("child: Text('Sonstige')", "child: Text(l.sonstige)"),
    ]),

    # ── document_preview_screen.dart ──
    ("lib/features/documents/presentation/document_preview_screen.dart", []),

    # ── data_export_service.dart ──
    ("lib/features/settings/data/data_export_service.dart", [
        ("'Export fehlgeschlagen.'", "l?.exportFehlgeschlagen ?? 'Export fehlgeschlagen.'"),
    ]),

    # ── doctor_calendar_tab.dart ──
    ("lib/features/doctor_calendar/presentation/doctor_calendar_tab.dart", [
        ("'Patient ausw\u00e4hlen'", "l.patientAuswaehlen"),
    ]),

    # ── medication_screen.dart ──
    ("lib/features/medication/presentation/medication_screen.dart", [
        ("Text('Wochentage'", "Text(l.wochentage"),
    ]),

    # ── mood_entry_editor_screen.dart ──
    ("lib/features/mood/presentation/mood_entry_editor_screen.dart", [
        ("'Was besch\u00e4ftigt dich gerade?'", "l.wasBeschaeftigtDich"),
    ]),

    # ── nutrition_screen.dart ──
    ("lib/features/nutrition/presentation/nutrition_screen.dart", [
        ("'Name der Vorlage'", "l.nameDerVorlage"),
        ("'Fehler beim Speichern.'", "l.fehlerBeimSpeichern"),
    ]),

    # ── nutrition_entry_editor_screen.dart ──
    ("lib/features/nutrition/presentation/nutrition_entry_editor_screen.dart", [
        ("'Mahlzeit speichern'", "l.mahlzeitSpeichern"),
    ]),

    # ── onboarding_questionnaire_screen.dart ──
    ("lib/features/onboarding_questionnaire/presentation/onboarding_questionnaire_screen.dart", [
        ("'Fehler beim Speichern. Bitte versuche es erneut.'", "l.fehlerSpeichernErneut"),
    ]),

    # ── join_org_sheet.dart ──
    ("lib/features/organisation/presentation/join_org_sheet.dart", [
        ("'Einladungscode'", "l.einladungscode"),
    ]),

    # ── org_doctors_tab.dart ──
    ("lib/features/organisation/presentation/org_doctors_tab.dart", [
        ("'Grund (optional)'", "l.grundOptional"),
    ]),

    # ── org_staff_tab.dart ──
    ("lib/features/organisation/presentation/org_staff_tab.dart", [
        ("'Neues Passwort'", "l.neuesPasswort"),
    ]),

    # ── packing_item_editor_sheet.dart ──
    ("lib/features/packing/presentation/packing_item_editor_sheet.dart", [
        ("'z.B. Die blaue, nicht die rote'", "l.zbDieBlaue"),
    ]),

    # ── packing_lists_screen.dart ──
    ("lib/features/packing/presentation/packing_lists_screen.dart", [
        ("'Neuer Name'", "l.neuerName"),
    ]),

    # ── photos_screen.dart ──
    ("lib/features/photos/presentation/photos_screen.dart", [
        ("'Fotos durchsuchen (Datum, Notiz, Kategorie)\u2026'", "l.fotosDurchsuchen"),
    ]),

    # ── paywall_screen.dart ──
    ("lib/features/pro/presentation/paywall_screen.dart", [
        ("'monatlich k\u00fcndbar'", "l.monatlichKuendbar"),
    ]),

    # ── smart_upsell_card.dart ──
    ("lib/features/pro/presentation/smart_upsell_card.dart", [
        ("const Text('Freischalten')", "Text(AppLocalizations.of(context)!.freischalten)"),
    ]),

    # ── rehab_screen.dart ──
    ("lib/features/rehab/presentation/rehab_screen.dart", [
        ("'\u00dcbung suchen\u2026'", "l.uebungSuchen"),
    ]),

    # ── create_ticket_screen.dart ──
    ("lib/features/support/presentation/create_ticket_screen.dart", [
        ("'Beschreibe dein Anliegen so genau wie m\u00f6glich\u2026'", "l.beschreibeAnliegen"),
        ("const Text('Ticket erstellen')", "Text(l.ticketErstellen)"),
    ]),

    # ── voice_memo_detail_screen.dart ──
    ("lib/features/voice/presentation/voice_memo_detail_screen.dart", [
        ("'z.B. Befund'", "l.zbBefund"),
        ("'Transkript bearbeiten\u2026'", "l.transkriptBearbeiten"),
    ]),

    # ── voice_memos_screen.dart ──
    ("lib/features/voice/presentation/voice_memos_screen.dart", [
        ("'Aufnahme konnte nicht gestartet werden.'", "l.aufnahmeStartFehler"),
        ("'Fehler beim Speichern.'", "l.fehlerBeimSpeichern"),
    ]),

    # ── speech_screen.dart ──
    ("lib/features/voice/presentation/speech_screen.dart", [
        ("'Aufnahme konnte nicht gestartet werden.'", "l.aufnahmeStartFehler"),
        ("'Fehler beim Speichern.'", "l.fehlerBeimSpeichern"),
    ]),

    # ── wound_compare_screen.dart ──
    ("lib/features/wound/presentation/wound_compare_screen.dart", [
        ("'Schmerz: $score/10'", "l.schmerzScore(score)"),
    ]),

    # ── wound_entry_detail_screen.dart ──
    ("lib/features/wound/presentation/wound_entry_detail_screen.dart", [
        ("'Kein Foto f\u00fcr die Analyse vorhanden.'", "l.keinFotoAnalyse"),
    ]),

    # ── wound_screen.dart ──
    ("lib/features/wound/presentation/wound_screen.dart", [
        ("'Foto konnte nicht geladen werden.'", "l.fotoLadeFehler"),
        ("'K\u00f6rperstelle (optional)'", "l.koerperstelleOptional"),
    ]),

    # ── family_overview_tab.dart ──
    ("lib/features/family/presentation/family_overview_tab.dart", [
        ("'Einladungscode'", "l.einladungscode"),
    ]),

    # ── family_patients_tab.dart ──
    ("lib/features/family/presentation/family_patients_tab.dart", [
        ("'Weiteren Patienten hinzuf\u00fcgen'", "l.weiterenPatientenHinzufuegen"),
        ("'Einladungscode'", "l.einladungscode"),
    ]),

    # ── family_profile_tab.dart ──
    ("lib/features/family/presentation/family_profile_tab.dart", [
        ("'Einladungscode'", "l.einladungscode"),
    ]),

    # ── pro_success_screen.dart ──
    ("lib/features/pro/presentation/pro_success_screen.dart", [
        ("const Text('Los geht\\u2019s')", "Text(l.losGehts)"),
    ]),

    # ── admin_notifications_tab.dart ──
    ("lib/roles/admin/admin_notifications_tab.dart", [
        ("'Test-Benachrichtigung erstellen'", "l.testBenachrichtigungErstellen"),
        ("'Alle als gelesen markieren'", "l.alleAlsGelesenMarkieren"),
    ]),

    # ── admin_patient_view_screen.dart ──
    ("lib/roles/admin/admin_patient_view_screen.dart", [
        ("'Suchen (Name, E-Mail oder UID)\u2026'", "l.suchenNameEmailUid"),
    ]),

    # ── audit_log_tab.dart ──
    ("lib/roles/admin/audit_log_tab.dart", [
        ("'CSV exportieren'", "l.csvExportieren"),
        ("'Zeitfilter zur\u00fccksetzen'", "l.zeitfilterZuruecksetzen"),
    ]),

    # ── dashboard_tab.dart ──
    ("lib/roles/admin/dashboard_tab.dart", [
        ("'Hinweistext (optional)'", "l.hinweistextOptional"),
        ("'z.B. Update wird eingespielt\u2026'", "l.zbUpdateWirdEingespielt"),
        ("'Statistiken aktualisieren'", "l.statistikenAktualisieren"),
        ("Text('Alle \u2192')", "Text(l.alleMarkieren)"),
    ]),

    # ── doctor_verification_tab.dart ──
    ("lib/roles/admin/doctor_verification_tab.dart", [
        ("'Begr\u00fcndung eingeben \u2026'", "l.begruendungEingeben"),
    ]),

    # ── invites_tab.dart ──
    ("lib/roles/admin/invites_tab.dart", [
        ("'Status filtern'", "l.statusFiltern"),
    ]),

    # ── orgs_admin_tab.dart ──
    ("lib/roles/admin/orgs_admin_tab.dart", [
        ("'Grund eingeben\u2026'", "l.grundEingeben"),
    ]),

    # ── pro_keys_tab.dart ──
    ("lib/roles/admin/pro_keys_tab.dart", [
        ("'CSV exportieren'", "l.csvExportieren"),
        ("'Neuer Key'", "l.neuerKey"),
        ("'Key-ID oder Einl\u00f6ser-UID suchen\u2026'", "l.keyIdOderUidSuchen"),
    ]),

    # ── push_tab.dart ──
    ("lib/roles/admin/push_tab.dart", [
        ("'Rolle ausw\u00e4hlen'", "l.rolleAuswaehlen"),
        ("'Vorlage'", "l.vorlage"),
    ]),

    # ── system_templates_tab.dart ──
    ("lib/roles/admin/system_templates_tab.dart", [
        ("'Name der Vorlage'", "l.nameDerVorlage"),
        ("Text('Priorit\u00e4t'", "Text(l.prioritaet"),
    ]),

    # ── tickets_tab.dart ──
    ("lib/roles/admin/tickets_tab.dart", []),

    # ── users_tab.dart ──
    ("lib/roles/admin/users_tab.dart", [
        ("'Grund der Sperrung \u2026'", "l.grundDerSperrung"),
        ("'CSV exportieren'", "l.csvExportieren"),
        ("'Nach Rolle filtern'", "l.nachRolleFiltern"),
        ("'Suchen (Name, E-Mail oder UID)\u2026'", "l.suchenNameEmailUid"),
        ("Text('Push')", "Text(l.pushSenden)"),
    ]),

    # ── family_member_hub_screen.dart ──
    ("lib/screens/family_member_hub_screen.dart", [
        ("'Einladungscode'", "l.einladungscode"),
    ]),

    # ── help_screen.dart ──
    ("lib/screens/help_screen.dart", [
        ("'Keine E-Mail-App gefunden'", "l.keineEmailApp"),
    ]),

    # ── profile_settings_screen.dart ──
    ("lib/screens/profile_settings_screen.dart", [
        ("'Bezeichnung eingeben'", "l.bezeichnungEingeben"),
    ]),
]


def apply_dart_replacements():
    """Apply all Dart string replacements."""
    changed_files = []
    total_replacements = 0
    failed = []

    for filepath, replacements in DART_REPLACEMENTS:
        if not replacements:
            continue

        full_path = os.path.join(BASE, filepath)
        if not os.path.exists(full_path):
            failed.append((filepath, "FILE NOT FOUND"))
            continue

        with open(full_path, 'r') as f:
            content = f.read()

        original = content
        file_count = 0

        for old, new in replacements:
            if old in content:
                content = content.replace(old, new, 1)
                file_count += 1
            else:
                failed.append((filepath, f"NOT FOUND: {old[:60]}"))

        if content != original:
            # Ensure l10n import exists
            if 'AppLocalizations' in content or 'l.' in content:
                if "import 'package:flutter_gen/gen_l10n/app_localizations.dart'" not in content:
                    # Add import after last import line
                    lines = content.split('\n')
                    last_import = 0
                    for i, line in enumerate(lines):
                        if line.startswith('import '):
                            last_import = i
                    lines.insert(last_import + 1,
                                 "import 'package:flutter_gen/gen_l10n/app_localizations.dart';")
                    content = '\n'.join(lines)

            with open(full_path, 'w') as f:
                f.write(content)

            changed_files.append(filepath)
            total_replacements += file_count

    return changed_files, total_replacements, failed


def main():
    print("=" * 60)
    print("L10N MIGRATION SCRIPT")
    print("=" * 60)

    # Step 1: Add ARB keys
    print("\n--- Adding ARB keys ---")
    de_added = add_arb_keys(DE_ARB, NEW_KEYS_DE)
    en_added = add_arb_keys(EN_ARB, NEW_KEYS_EN)
    print(f"  DE: {de_added} new keys added")
    print(f"  EN: {en_added} new keys added")

    # Step 2: Apply Dart replacements
    print("\n--- Applying Dart replacements ---")
    changed, total, failed = apply_dart_replacements()
    print(f"  {total} replacements in {len(changed)} files")

    if failed:
        print(f"\n--- {len(failed)} FAILED replacements ---")
        for path, reason in failed:
            print(f"  {path}: {reason}")

    print(f"\n--- Changed files ---")
    for f in sorted(changed):
        print(f"  {f}")

    print("\nDone! Run 'flutter gen-l10n' to regenerate.")


if __name__ == '__main__':
    main()
