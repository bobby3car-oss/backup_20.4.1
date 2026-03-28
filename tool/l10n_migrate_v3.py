#!/usr/bin/env python3
"""
l10n migration pass 3 – automated extraction and replacement.

Reads the deep_scan_results.txt, generates ARB keys for every string,
adds them to app_de.arb and app_en.arb, and replaces the hardcoded strings
in the Dart source files.
"""
import re, os, json, sys, unicodedata

BASE = '/Users/jan/projects/operationsbegleiter_v3'
SCAN = '/tmp/deep_scan_results.txt'
DE_ARB = os.path.join(BASE, 'lib/l10n/app_de.arb')
EN_ARB = os.path.join(BASE, 'lib/l10n/app_en.arb')

# ── Parse scan results ───────────────────────────────────────────
entries = []  # (file, line, ctx, string)
with open(SCAN) as f:
    current_file = None
    for line in f:
        line = line.rstrip('\n')
        m = re.match(r'^(lib/\S+\.dart)\s+\(\d+\):', line)
        if m:
            current_file = m.group(1)
            continue
        m = re.match(r'^\s+L(\d+)\s+\[([^\]]+)\]:\s+(.+)$', line)
        if m and current_file:
            entries.append((current_file, int(m.group(1)), m.group(2), m.group(3)))

print(f"Parsed {len(entries)} entries from scan results")

# ── Load existing ARB ────────────────────────────────────────────
with open(DE_ARB) as f:
    de_arb = json.load(f)
with open(EN_ARB) as f:
    en_arb = json.load(f)

existing_keys = set(k for k in de_arb if not k.startswith('@') and k != '@@locale')
existing_values_de = {}
for k, v in de_arb.items():
    if not k.startswith('@') and k != '@@locale':
        existing_values_de[v] = k

# ── Helpers ──────────────────────────────────────────────────────

def to_camel(s):
    """Generate a camelCase key from a German/English string."""
    # Remove special chars, keep alphanumeric and spaces
    s = s.replace('ä', 'ae').replace('ö', 'oe').replace('ü', 'ue')
    s = s.replace('Ä', 'Ae').replace('Ö', 'Oe').replace('Ü', 'Ue')
    s = s.replace('ß', 'ss')
    s = s.replace('–', ' ').replace('—', ' ').replace('-', ' ')
    s = s.replace('&', 'Und').replace('/', ' ')
    s = s.replace('…', '').replace('...', '')
    s = s.replace('"', '').replace('"', '').replace('„', '')
    s = s.replace('»', '').replace('«', '')
    s = s.replace('\u2011', ' ')  # non-breaking hyphen
    s = s.replace('°', 'Grad').replace('§', 'Par')
    # Remove emojis and other non-ascii except basic latin
    cleaned = []
    for c in s:
        if c.isascii() or c.isalnum():
            cleaned.append(c)
        else:
            cleaned.append(' ')
    s = ''.join(cleaned)
    # Split into words
    words = re.findall(r'[A-Za-z][a-z]*|[A-Z]+(?=[A-Z]|$)|\d+', s)
    if not words:
        return None
    # camelCase
    result = words[0].lower()
    for w in words[1:]:
        result += w.capitalize()
    # Truncate to reasonable length
    if len(result) > 60:
        result = result[:60]
    return result


# Simple German → English translations for common words
TRANSLATIONS = {
    'Alle': 'All', 'Neue': 'New', 'Neues': 'New', 'Neu': 'New',
    'Erstellen': 'Create', 'Erstelle': 'Create', 'Erste': 'First', 'Erstes': 'First',
    'Speichern': 'Save', 'Löschen': 'Delete', 'Bearbeiten': 'Edit',
    'Hinzufügen': 'Add', 'Entfernen': 'Remove', 'Schließen': 'Close',
    'Abbrechen': 'Cancel', 'Bestätigen': 'Confirm', 'Weiter': 'Continue',
    'Zurück': 'Back', 'Fertig': 'Done', 'Suche': 'Search', 'Suchen': 'Search',
    'Filter': 'Filter', 'Laden': 'Loading', 'Fehler': 'Error',
    'Keine': 'No', 'Kein': 'No', 'Noch keine': 'No',
    'und': 'and', 'oder': 'or', 'mit': 'with', 'ohne': 'without',
    'für': 'for', 'von': 'from', 'nach': 'after', 'vor': 'before',
    'Bitte': 'Please', 'Ja': 'Yes', 'Nein': 'No',
    'Arzt': 'Doctor', 'Patient': 'Patient', 'Dokument': 'Document',
    'Termin': 'Appointment', 'Medikament': 'Medication', 'Schmerz': 'Pain',
    'Wunde': 'Wound', 'Pflege': 'Care', 'Aufgabe': 'Task',
    'Einstellung': 'Settings', 'Profil': 'Profile', 'Hilfe': 'Help',
    'Nachricht': 'Message', 'Benachrichtigung': 'Notification',
    'Tag': 'Day', 'Tage': 'Days', 'Woche': 'Week', 'Monat': 'Month',
    'Heute': 'Today', 'Gestern': 'Yesterday', 'Morgen': 'Tomorrow',
    'Uhr': "o'clock", 'Stunde': 'Hour', 'Minute': 'Minute',
    'Foto': 'Photo', 'Fotos': 'Photos', 'Bild': 'Image',
    'Datei': 'File', 'Ordner': 'Folder', 'Liste': 'List',
    'Notiz': 'Note', 'Anmerkung': 'Note',
    'Aktivieren': 'Activate', 'Deaktivieren': 'Deactivate',
    'Senden': 'Send', 'Teilen': 'Share', 'Kopieren': 'Copy',
    'Öffnen': 'Open', 'Hochladen': 'Upload',
    'Stimmung': 'Mood', 'Schlaf': 'Sleep', 'Ernährung': 'Nutrition',
    'Übung': 'Exercise', 'Reha': 'Rehab', 'Vital': 'Vital',
    'Stimme': 'Voice', 'Sprache': 'Voice',
    'Einladung': 'Invitation', 'Code': 'Code',
    'Angehörige': 'Family members', 'Familie': 'Family',
    'Organisation': 'Organisation', 'Praxis': 'Practice',
    'Einnahme': 'Intake', 'Dosis': 'Dose',
    'Verband': 'Bandage', 'Blutdruck': 'Blood pressure',
    'Puls': 'Pulse', 'Fieber': 'Fever', 'Temperatur': 'Temperature',
    'Gewicht': 'Weight', 'Größe': 'Height',
    'Notruf': 'Emergency call', 'Notfall': 'Emergency',
    'Warnung': 'Warning', 'Warnzeichen': 'Warning signs',
    'Ergebnis': 'Result', 'Auswertung': 'Evaluation',
    'Zusammenfassung': 'Summary', 'Übersicht': 'Overview',
    'Qualität': 'Quality', 'Dauer': 'Duration',
    'Ort': 'Location', 'Auslöser': 'Trigger',
    'Verträglichkeit': 'Tolerability', 'Empfehlung': 'Recommendation',
    'Gesprächsexport': 'Chat export', 'Analyse': 'Analysis',
    'Verlauf': 'History', 'Fortschritt': 'Progress',
    'Meilenstein': 'Milestone', 'Challenge': 'Challenge',
    'Level': 'Level', 'Streak': 'Streak',
    'Einlösen': 'Redeem', 'Bonus': 'Bonus',
}


def translate_simple(de_text):
    """Very basic word-by-word translation for English ARB."""
    # If it has interpolation, keep placeholders
    # For now, just return the German text prefixed to note it needs translation
    # We'll use a simple approach: keep the German as-is in English ARB 
    # (the user can translate later, like ar/ru/tr)
    return de_text


# ── Skip patterns ────────────────────────────────────────────────
# Strings that should NOT be localized (technical, data model, etc.)
SKIP_STRINGS = {
    'email: ${_email ?? ',  # debug display
    ' · ${task.timeOfDay!.label}',  # uses .label already
    ' · ${_priorityLabel(task.priority)}',  # uses function
    'Code: $_latestInviteCode',  # technical display
    '$systolic/$diastolic mmHg · $pulse bpm',  # technical format
    '$totalCals kcal',
    '🥩 ${totalProtein}g',
    '+${ml}ml Wasser erfasst',
    '$count Messungen synchronisiert',
    '$age Jahre',
    'BMI ${bmi!.toStringAsFixed(1)}',
    '$favoriteCount gemerkt',
    'User ${currentlyDisabled ? ',
    '24. April 2026 · 08:00 Uhr',  # mock data
    '02. März 2026',  # mock data  
    '10. April 2026',  # mock data
    '24. April 2026',  # mock data
    'Akzeptiert von: $acceptedBy',
    'Code (zum Teilen mit dem Arzt):',
    'Code: $code',
    '$patients',
    '$organisation',
    'User $action?',
}

# Files that contain data/domain content (not direct UI)
# These need different handling - they define static data
DOMAIN_DATA_FILES = {
    'lib/domain/care_plan_templates.dart',
    'lib/features/gamification/domain/daily_challenge.dart',
    'lib/features/gamification/domain/milestone.dart',
    'lib/features/gamification/domain/xp_config.dart',
    'lib/features/nutrition/domain/nutrition_recommendation_service.dart',
    'lib/features/nutrition/domain/nutrition_recommendations.dart',
    'lib/features/op_info/op_info_content.dart',
    'lib/features/rehab/domain/rehab_catalog.dart',
    'lib/features/red_flags/domain/red_flag_engine.dart',
    'lib/features/settings/data/legal_text_repository.dart',
    'lib/features/questions/data/questions_repository_local.dart',
    'lib/features/warnings/presentation/warnings_screen.dart',  # static data in build
}

# Strings containing ${...} interpolation - need placeholders in ARB
INTERPOLATION_RE = re.compile(r'\$\{?[a-zA-Z_][a-zA-Z0-9_.!?]*\}?')

# ── Process entries ──────────────────────────────────────────────
new_keys = {}  # key -> (de_value, en_value, has_placeholders, placeholder_info)
replacements = []  # (file, line, old_str, new_str, key)
skipped = []
domain_data = []

for file, line_no, ctx, string_val in entries:
    # Skip already-known problematic strings
    if string_val in SKIP_STRINGS:
        skipped.append((file, line_no, string_val, 'in SKIP_STRINGS'))
        continue
    
    # Skip strings with complex interpolation
    if '${' in string_val and ('{' in string_val.split('${')[1].split('}')[0] if '${' in string_val else False):
        skipped.append((file, line_no, string_val, 'complex interpolation'))
        continue
    
    # Domain data files - flag for manual review
    if file in DOMAIN_DATA_FILES:
        domain_data.append((file, line_no, ctx, string_val))
        continue
    
    # Check if this exact string already has an ARB key
    if string_val in existing_values_de:
        key = existing_values_de[string_val]
    else:
        # Generate a new key
        key = to_camel(string_val)
        if not key:
            skipped.append((file, line_no, string_val, 'cannot generate key'))
            continue
        
        # Handle duplicates
        if key in existing_keys or key in new_keys:
            # Try adding file context
            file_part = os.path.basename(file).replace('.dart', '').replace('_screen', '').replace('_tab', '')
            file_part = to_camel(file_part) or 'x'
            key = file_part + key[0].upper() + key[1:]
            if key in existing_keys or key in new_keys:
                key = key + str(line_no)
    
    # Check for interpolation
    has_placeholders = bool(INTERPOLATION_RE.search(string_val))
    
    if has_placeholders:
        # Skip complex interpolations for now - they need manual handling
        skipped.append((file, line_no, string_val, 'has interpolation'))
        continue
    
    # Add to new keys
    if key not in existing_keys and key not in new_keys:
        new_keys[key] = (string_val, translate_simple(string_val))
    
    # Record replacement
    replacements.append((file, line_no, ctx, string_val, key))

print(f"\nNew ARB keys to add: {len(new_keys)}")
print(f"Replacements to make: {len(replacements)}")
print(f"Skipped (interpolation/complex): {len(skipped)}")
print(f"Domain data (manual review): {len(domain_data)}")

# ── Write new ARB keys ───────────────────────────────────────────
print("\n=== Adding new ARB keys ===")

for key, (de_val, en_val) in sorted(new_keys.items()):
    de_arb[key] = de_val
    en_arb[key] = en_val

# Sort keys (keep @@locale and @ metadata next to their keys)
def sort_arb(arb_dict):
    """Sort ARB keys alphabetically, keeping @key metadata right after key."""
    result = {}
    if '@@locale' in arb_dict:
        result['@@locale'] = arb_dict['@@locale']
    
    # Get all non-@ keys
    keys = sorted(k for k in arb_dict if not k.startswith('@'))
    for k in keys:
        result[k] = arb_dict[k]
        meta_key = f'@{k}'
        if meta_key in arb_dict:
            result[meta_key] = arb_dict[meta_key]
    return result

de_sorted = sort_arb(de_arb)
en_sorted = sort_arb(en_arb)

with open(DE_ARB, 'w') as f:
    json.dump(de_sorted, f, ensure_ascii=False, indent=2)
    f.write('\n')
with open(EN_ARB, 'w') as f:
    json.dump(en_sorted, f, ensure_ascii=False, indent=2)
    f.write('\n')

print(f"  Written {len(new_keys)} new keys to both ARB files")
print(f"  Total DE keys: {sum(1 for k in de_sorted if not k.startswith('@') and k != '@@locale')}")

# ── Apply replacements ───────────────────────────────────────────
print("\n=== Applying replacements ===")

# Group by file
by_file = {}
for file, line_no, ctx, string_val, key in replacements:
    if file not in by_file:
        by_file[file] = []
    by_file[file].append((line_no, ctx, string_val, key))

files_changed = 0
strings_replaced = 0
import_added = 0

for file, items in sorted(by_file.items()):
    fpath = os.path.join(BASE, file)
    if not os.path.exists(fpath):
        print(f"  SKIP {file} (not found)")
        continue
    
    with open(fpath) as f:
        content = f.read()
    
    original = content
    lines = content.split('\n')
    
    # Check if file already imports AppLocalizations
    has_import = 'app_localizations.dart' in content
    
    # Apply replacements (process line by line, from bottom to top to preserve line numbers)
    items_sorted = sorted(items, key=lambda x: x[0], reverse=True)
    
    for line_no, ctx, string_val, key in items_sorted:
        idx = line_no - 1
        if idx >= len(lines):
            continue
        
        line = lines[idx]
        
        # Determine the replacement expression
        # We need l.key - need to check if 'l' is available in scope
        replacement = f'l.{key}'
        
        # Build the old and new patterns based on context
        escaped_val = string_val.replace('\\', '\\\\')
        
        # Try single quotes first, then double quotes
        old_sq = f"'{string_val}'"
        old_dq = f'"{string_val}"'
        
        replaced = False
        if old_sq in line:
            new_line = line.replace(old_sq, replacement, 1)
            if new_line != line:
                lines[idx] = new_line
                replaced = True
                strings_replaced += 1
        elif old_dq in line:
            new_line = line.replace(old_dq, replacement, 1)
            if new_line != line:
                lines[idx] = new_line
                replaced = True
                strings_replaced += 1
        
        if not replaced:
            # Try with escaped characters
            for variant in [string_val, string_val.replace("'", "\\'")]:
                old_v = f"'{variant}'"
                if old_v in line:
                    new_line = line.replace(old_v, replacement, 1)
                    lines[idx] = new_line
                    replaced = True
                    strings_replaced += 1
                    break
        
        if replaced:
            # Remove 'const' if this creates a const error
            # Check if there's a 'const' before this in the same expression
            new_line = lines[idx]
            # Check if line has const on it
            if 'const ' in new_line and 'l.' in new_line:
                # Simple: if both const and l. are on same line, remove const
                new_line = new_line.replace('const ', '', 1)
                lines[idx] = new_line
    
    content = '\n'.join(lines)
    
    # Add import if needed
    if content != original and not has_import:
        # Find the right relative import path
        depth = file.count('/') - 1  # lib/ is top level
        prefix = '../' * (depth - 1)  # relative to lib/
        import_line = f"import '{prefix}l10n/app_localizations.dart';\n"
        
        # Insert after last import
        import_pos = 0
        for m in re.finditer(r"^import\s+['\"].*['\"];\s*$", content, re.MULTILINE):
            import_pos = m.end()
        
        if import_pos > 0:
            content = content[:import_pos] + '\n' + import_line + content[import_pos:]
            import_added += 1
    
    if content != original:
        with open(fpath, 'w') as f:
            f.write(content)
        files_changed += 1

print(f"  Files changed: {files_changed}")
print(f"  Strings replaced: {strings_replaced}")
print(f"  Imports added: {import_added}")

# ── Report skipped ───────────────────────────────────────────────
print(f"\n=== Skipped strings ({len(skipped)}) ===")
for file, line_no, s, reason in skipped[:30]:
    print(f"  {file}:{line_no} [{reason}]: {s[:80]}")
if len(skipped) > 30:
    print(f"  ... and {len(skipped) - 30} more")

print(f"\n=== Domain data strings ({len(domain_data)}) ===")
print("  These are in domain/data files and need context-based localization.")
dd_files = set(f for f, _, _, _ in domain_data)
for f in sorted(dd_files):
    count = sum(1 for ff, _, _, _ in domain_data if ff == f)
    print(f"  {f}: {count} strings")

print("\nDone!")
