#!/usr/bin/env python3
"""
L10n migration pass 2 - handle interpolated strings and remaining hardcoded text.
Uses line-based replacement for precision.
"""
import os
import re

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Format: (filepath, [(line_number, old_text_fragment, new_text_fragment), ...])
# line_number is 1-based, used for disambiguation when multiple matches.
# We match old_text_fragment as a substring of the line and replace it.

REPLACEMENTS = [
    # ads_admin_tab.dart
    ("lib/features/ads/presentation/admin/ads_admin_tab.dart", [
        (144, "Text('\u201e${ad.title}\u201c wird unwiderruflich gel\u00f6scht.')",
              "Text(l.unwiderruflichLoeschen(ad.title))"),
    ]),

    # appointment_editor_sheet.dart
    ("lib/features/appointments/presentation/appointment_editor_sheet.dart", [
        (863, "Text('\u201e${target.title}\u201c unwiderruflich l\u00f6schen?')",
              "Text(l.unwiderruflichLoeschen(target.title))"),
    ]),

    # doctor_notes_tab.dart
    ("lib/features/doctor_notes/presentation/doctor_notes_tab.dart", [
        (113, "Text('\u201e${note.title}\u201c wirklich l\u00f6schen?')",
              "Text(l.notizLoeschenBestaetigung(note.title))"),
    ]),

    # document_preview_screen.dart
    ("lib/features/documents/presentation/document_preview_screen.dart", [
        (186, "Text('\u201e${item.title}\u201c wird unwiderruflich gel\u00f6scht.')",
              "Text(l.unwiderruflichLoeschen(item.title))"),
    ]),

    # documents_screen.dart
    ("lib/features/documents/presentation/documents_screen.dart", [
        (499, "Text('\u201e${item.title}\u201c gel\u00f6scht')",
              "Text(l.dokumentGeloescht(item.title))"),
    ]),

    # dokumente_screen.dart
    ("lib/screens/dokumente_screen.dart", [
        (377, "Text('\u201e${item.title}\u201c gel\u00f6scht')",
              "Text(l.dokumentGeloescht(item.title))"),
        (1885, "Text('\u201e${item.title}\u201c wird unwiderruflich gel\u00f6scht.')",
               "Text(l.unwiderruflichLoeschen(item.title))"),
    ]),

    # doctor_patients/patient_detail_screen.dart
    ("lib/features/doctor_patients/presentation/patient_detail_screen.dart", [
        (1358, """Text('Vorlage "$name" erstellt')""",
               "Text(l.vorlageErstellt(name))"),
        (1422, "Text('Aufgaben ausw\u00e4hlen (${_selected.length}/${_tasks!.length}):')",
               "Text(l.aufgabenAuswaehlenCount(_selected.length, _tasks!.length))"),
    ]),

    # doctor_staff_tab.dart
    ("lib/features/doctor_staff/presentation/doctor_staff_tab.dart", [
        (136, "Text('Neues Passwort f\u00fcr ${member.displayName}')",
              "Text(l.neuesPasswortFuer(member.displayName))"),
        (217, "title: Text('Mitarbeiter $action')",
              "title: Text(l.mitarbeiterAction(action))"),
        (295, "Text('${member.displayName} wurde entfernt')",
              "Text(l.mitarbeiterEntfernt(member.displayName))"),
    ]),

    # org_staff_tab.dart
    ("lib/features/organisation/presentation/org_staff_tab.dart", [
        (125, "Text('Neues Passwort f\u00fcr ${member.displayName}')",
              "Text(l.neuesPasswortFuer(member.displayName))"),
        (206, "title: Text('Mitarbeiter $action')",
              "title: Text(l.mitarbeiterAction(action))"),
        (284, "Text('${member.displayName} wurde entfernt')",
              "Text(l.mitarbeiterEntfernt(member.displayName))"),
    ]),

    # doctor_templates/template_management_screen.dart
    ("lib/features/doctor_templates/presentation/template_management_screen.dart", [
        (296, """Text('"${clone.name}" erstellt')""",
              "Text(l.cloneErstellt(clone.name))"),
        (325, """Text('"${clone.name}" in eigene Vorlagen \u00fcbernommen')""",
              "Text(l.vorlageUebernommen(clone.name))"),
        (343, """Text('M\u00f6chten Sie "${template.name}" wirklich l\u00f6schen?')""",
              "Text(l.vorlageLoeschenBestaetigung(template.name))"),
        (1392, "const Text('Alle ')", "Text('${l.alle} ')"),
    ]),

    # health_report_screen.dart
    ("lib/features/export/presentation/health_report_screen.dart", [
        (267, "Text('Fehler: $e')", "Text(l.fehlerMitError(e.toString()))"),
    ]),

    # family_patient_detail_screen.dart
    ("lib/features/family/presentation/family_patient_detail_screen.dart", [
        (767, "Text('Schmerzlevel: $level/10')", "Text(l.schmerzlevel(level))"),
    ]),

    # medication_screen.dart
    ("lib/features/medication/presentation/medication_screen.dart", [
        (301, "Text('${reminder.medicationName} entfernt')",
              "Text(l.medikamentEntfernt(reminder.medicationName))"),
        (311, "Text('${reminder.medicationName} wiederhergestellt')",
              "Text(l.medikamentWiederhergestellt(reminder.medicationName))"),
        (390, "Text('${intake.name} entfernt')",
              "Text(l.medikamentEntfernt(intake.name))"),
        (1839, "Text('${item.name} wird entfernt.')",
               "Text(l.medikamentWirdEntfernt(item.name))"),
        (2373, "'z.B. nach dem Essen mit Wasser einnehmen'",
               "l.zbNachDemEssen"),
    ]),

    # nutrition_screen.dart
    ("lib/features/nutrition/presentation/nutrition_screen.dart", [
        (840, "'z. B. Vollkornbrot mit Quark und Tomaten'",
              "l.zbVollkornbrot"),
        (1182, """Text('"${t.name}" wird entfernt.')""",
               "Text(l.templateWirdEntfernt(t.name))"),
    ]),

    # org_doctors_tab.dart
    ("lib/features/organisation/presentation/org_doctors_tab.dart", [
        (79, "Text('${request.doctorName} wurde hinzugef\u00fcgt')",
             "Text(l.doctorHinzugefuegt(request.doctorName))"),
        (102, "Text('M\u00f6chten Sie die Anfrage von ${request.doctorName} ablehnen?')",
              "Text(l.anfrageAblehnenBestaetigung(request.doctorName))"),
        (196, "Text('${doctor.name} wurde entfernt')",
              "Text(l.doctorEntfernt(doctor.name))"),
    ]),

    # sleep_entry_editor.dart
    ("lib/features/sleep/presentation/sleep_entry_editor.dart", [
        (175, "Text('Fehler: $e')", "Text(l.fehlerMitError(e.toString()))"),
    ]),

    # sleep_screen.dart
    ("lib/features/sleep/presentation/sleep_screen.dart", [
        (133, "Text('Fehler: $e')", "Text(l.fehlerMitError(e.toString()))"),
    ]),

    # ticket_chat_screen.dart
    ("lib/features/support/presentation/ticket_chat_screen.dart", [
        (209, "Text('Status: ${status.label}')", "Text(l.statusMitLabel(status.label))"),
    ]),

    # vitals_screen.dart
    ("lib/features/vitals/presentation/vitals_screen.dart", [
        (124, "Text('$count neue Messungen aus Health synchronisiert')",
              "Text(l.neueMessungenSync(count))"),
    ]),

    # warnings_screen.dart
    ("lib/features/warnings/presentation/warnings_screen.dart", [
        (179, "Text('Warnzeichen-Check gespeichert (${engine.level.name})')",
              "Text(l.warnzeichenGespeichert(engine.level.name))"),
    ]),

    # admin_home.dart
    ("lib/roles/admin/admin_home.dart", [
        (211, "Text('Wirklich aus dem Admin-Bereich abmelden?')",
              "Text(l.adminAbmeldenBestaetigung)"),
        (210, "Text('Abmelden?')", "Text(l.abmelden)"),
        (215, "Text('Abbrechen')", "Text(l.cancel)"),
        (216, "Text('Abmelden')", "Text(l.abmelden)"),
    ]),

    # admin_notifications_tab.dart
    ("lib/roles/admin/admin_notifications_tab.dart", [
        (49, "Text('Benachrichtigungen ($count neu)')",
             "Text(l.benachrichtigungenCountNeu(count))"),
    ]),

    # dashboard_tab.dart
    ("lib/roles/admin/dashboard_tab.dart", [
        (34, "const SnackBar(content: Text('Stats konnten nicht aktualisiert werden.'))",
             "SnackBar(content: Text(l.statsNichtAktualisiert))"),
    ]),

    # doctor_admin_detail_sheet.dart
    ("lib/roles/admin/doctor_admin_detail_sheet.dart", [
        (201, "Text('Profil gespeichert.')", "Text(l.profilGespeichert)"),
    ]),

    # doctor_management_tab.dart
    ("lib/roles/admin/doctor_management_tab.dart", [
        (94, "Text('$name wurde gesperrt.')", "Text(l.nameWurdeGesperrt(name))"),
        (124, "Text('$name wurde entsperrt.')", "Text(l.nameWurdeEntsperrt(name))"),
        (155, "Text('$name wurde gel\u00f6scht.')", "Text(l.nameWurdeGeloescht(name))"),
    ]),

    # invites_tab.dart
    ("lib/roles/admin/invites_tab.dart", [
        (152, "Text('G\u00fcltig f\u00fcr $result Tage')",
              "Text(l.gueltigFuerTage(result))"),
        (178, "Text('Fehler: ${userFacingError(e)}')",
              "Text(l.fehlerMitError(userFacingError(e)))"),
        (432, "Text('Erstellt von: $createdBy')",
              "Text(l.erstelltVon(createdBy))"),
    ]),

    # pro_keys_tab.dart
    ("lib/roles/admin/pro_keys_tab.dart", [
        (168, "Text('${keys.length} Keys erstellt')",
              "Text(l.keysErstellt(keys.length))"),
    ]),

    # push_tab.dart
    ("lib/roles/admin/push_tab.dart", [
        (100, "Text('Push an $targetDesc gesendet!')",
              "Text(l.pushAnTargetGesendet(targetDesc))"),
    ]),

    # system_templates_tab.dart
    ("lib/roles/admin/system_templates_tab.dart", [
        (221, "Text('Fehler: $e')", "Text(l.fehlerMitError(e.toString()))"),
        (290, "Text('Aufgaben (${_tasks.length})')",
              "Text(l.aufgabenCount(_tasks.length))"),
    ]),

    # tickets_tab.dart
    ("lib/roles/admin/tickets_tab.dart", [
        (33, "Text('Tickets ($count offen)')",
             "Text(l.ticketsCountOffen(count))"),
    ]),

    # users_tab.dart
    ("lib/roles/admin/users_tab.dart", [
        (129, """Text('Rolle auf "${adminRoleLabels[newRole]}" ge\u00e4ndert.')""",
              "Text(l.rolleGeaendert(adminRoleLabels[newRole] ?? ''))"),
        (236, "Text('User konnte nicht ${action}t werden.')",
              "Text(l.userAktionFehler(action))"),
        (328, "Text('Push an $email')", "Text(l.pushAnEmail(email))"),
        (372, "Text('Push an $email gesendet.')", "Text(l.pushAnEmailGesendet(email))"),
        (787, "Text('$_days Tage vergeben')", "Text(l.tageVergeben(_days))"),
    ]),

    # caregiver_home.dart
    ("lib/roles/caregiver_home.dart", [
        (186, "Text('Noch keine Aufgaben im Plan.')",
              "Text(l.keineAufgabenImPlan)"),
    ]),

    # caregiver_screen.dart
    ("lib/screens/caregiver_screen.dart", [
        (444, "Text('${caregiver.name} wurde entfernt')",
              "Text(l.caregiverEntfernt(caregiver.name))"),
    ]),

    # profile_settings_screen.dart
    ("lib/screens/profile_settings_screen.dart", [
        (265, "Text('Profil gespeichert')", "Text(l.profilGespeichertKurz)"),
        (281, "'Fehler beim Speichern.'", "l.fehlerBeimSpeichern"),
        (1708, "Text('Ausw\u00e4hlen')", "Text(l.auswaehlen)"),
        (1940, "Text('$label hinzuf\u00fcgen')", "Text(l.labelHinzufuegen(label))"),
    ]),

    # vital_signs_screen.dart
    ("lib/screens/vital_signs_screen.dart", [
        (753, "Text('Messung gespeichert')", "Text(l.messungGespeichert)"),
    ]),
]

# Additional ARB keys that might be missing
EXTRA_DE_KEYS = {
    "keineAufgabenImPlan": "Noch keine Aufgaben im Plan.",
    "abmelden": "Abmelden",
    "alle": "Alle",
}
EXTRA_EN_KEYS = {
    "keineAufgabenImPlan": "No tasks in the plan yet.",
    "abmelden": "Sign out",
    "alle": "All",
}


def apply_replacements():
    changed = []
    total = 0
    failed = []

    for filepath, repls in REPLACEMENTS:
        if not repls:
            continue

        full_path = os.path.join(BASE, filepath)
        if not os.path.exists(full_path):
            failed.append((filepath, "FILE NOT FOUND"))
            continue

        with open(full_path, 'r') as f:
            lines = f.readlines()

        original = list(lines)
        file_count = 0

        for target_line, old_frag, new_frag in repls:
            found = False
            # Search around the target line (allow +-5 lines drift)
            for offset in range(0, 10):
                for idx in [target_line - 1 + offset, target_line - 1 - offset]:
                    if 0 <= idx < len(lines) and old_frag in lines[idx]:
                        lines[idx] = lines[idx].replace(old_frag, new_frag, 1)
                        file_count += 1
                        found = True
                        break
                if found:
                    break

            if not found:
                failed.append((filepath, f"L{target_line}: {old_frag[:60]}"))

        if lines != original:
            content = ''.join(lines)
            # Ensure l10n import exists
            if 'l.' in content and "import 'package:flutter_gen/gen_l10n/app_localizations.dart'" not in content:
                import_lines = content.split('\n')
                last_import = 0
                for i, line in enumerate(import_lines):
                    if line.startswith('import '):
                        last_import = i
                import_lines.insert(last_import + 1,
                                    "import 'package:flutter_gen/gen_l10n/app_localizations.dart';")
                content = '\n'.join(import_lines)

            with open(full_path, 'w') as f:
                f.write(content)

            changed.append(filepath)
            total += file_count

    return changed, total, failed


def add_extra_arb_keys():
    import json
    for arb_path, keys in [(os.path.join(BASE, 'lib', 'l10n', 'app_de.arb'), EXTRA_DE_KEYS),
                            (os.path.join(BASE, 'lib', 'l10n', 'app_en.arb'), EXTRA_EN_KEYS)]:
        with open(arb_path, 'r') as f:
            data = json.load(f)
        added = 0
        for k, v in keys.items():
            if k not in data:
                data[k] = v
                added += 1
        if added:
            # Sort
            sorted_data = {"@@locale": data.get("@@locale", "de")}
            regular_keys = sorted(k for k in data if not k.startswith("@"))
            for k in regular_keys:
                if k == "@@locale":
                    continue
                sorted_data[k] = data[k]
                meta_key = f"@{k}"
                if meta_key in data:
                    sorted_data[meta_key] = data[meta_key]
            with open(arb_path, 'w') as f:
                json.dump(sorted_data, f, ensure_ascii=False, indent=2)
                f.write('\n')
        print(f"  {os.path.basename(arb_path)}: {added} extra keys added")


def main():
    print("=" * 60)
    print("L10N MIGRATION PASS 2 - Interpolated strings")
    print("=" * 60)

    print("\n--- Adding extra ARB keys ---")
    add_extra_arb_keys()

    print("\n--- Applying replacements ---")
    changed, total, failed = apply_replacements()
    print(f"  {total} replacements in {len(changed)} files")

    if failed:
        print(f"\n--- {len(failed)} FAILED ---")
        for path, reason in failed:
            print(f"  {path}: {reason}")

    print(f"\n--- Changed files ---")
    for f in sorted(changed):
        print(f"  {f}")

    print("\nDone!")


if __name__ == '__main__':
    main()
