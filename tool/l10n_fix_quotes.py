#!/usr/bin/env python3
"""Fix remaining German typographic quote replacements."""
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# These files have German typographic quotes „" that need special handling
# The opening „ is U+201E, the closing " could be U+201C or U+201D
FILES_WITH_TYPO_QUOTES = [
    ("lib/features/ads/presentation/admin/ads_admin_tab.dart",
     "wird unwiderruflich gel\u00f6scht.", "l.unwiderruflichLoeschen(ad.title)"),
    ("lib/features/appointments/presentation/appointment_editor_sheet.dart",
     "unwiderruflich l\u00f6schen?", "l.unwiderruflichLoeschen(target.title)"),
    ("lib/features/doctor_notes/presentation/doctor_notes_tab.dart",
     "wirklich l\u00f6schen?", "l.notizLoeschenBestaetigung(note.title)"),
    ("lib/features/documents/presentation/document_preview_screen.dart",
     "wird unwiderruflich gel\u00f6scht.", "l.unwiderruflichLoeschen(item.title)"),
    ("lib/features/documents/presentation/documents_screen.dart",
     "gel\u00f6scht", "l.dokumentGeloescht(item.title)"),
    ("lib/screens/dokumente_screen.dart",
     "gel\u00f6scht", "l.dokumentGeloescht(item.title)"),
]

changed = []
for filepath, marker, replacement in FILES_WITH_TYPO_QUOTES:
    full_path = os.path.join(BASE, filepath)
    with open(full_path, 'r') as f:
        lines = f.readlines()

    modified = False
    for i, line in enumerate(lines):
        # Find lines with the marker text that still have German quotes
        if marker in line and ('\u201e' in line or '\u201c' in line or '\u201d' in line):
            # Extract the full Text('...') construct and replace
            import re
            # Match Text('...<marker>...')  or Text("...<marker>...")
            m = re.search(r"Text\(['\"].*?" + re.escape(marker) + r".*?['\"]\)", line)
            if m:
                old = m.group(0)
                lines[i] = line.replace(old, f"Text({replacement})")
                modified = True
                print(f"  Fixed {filepath} L{i+1}")

    if modified:
        with open(full_path, 'w') as f:
            f.writelines(lines)
        changed.append(filepath)

# Handle the dokumente_screen.dart second occurrence (unwiderruflich)
full_path2 = os.path.join(BASE, "lib/screens/dokumente_screen.dart")
with open(full_path2, 'r') as f:
    lines = f.readlines()
modified = False
for i, line in enumerate(lines):
    if 'unwiderruflich' in line and ('\u201e' in line or '\u201c' in line or '\u201d' in line):
        import re
        m = re.search(r"Text\(['\"].*?unwiderruflich.*?['\"]\)", line)
        if m:
            old = m.group(0)
            lines[i] = line.replace(old, "Text(l.unwiderruflichLoeschen(item.title))")
            modified = True
            print(f"  Fixed lib/screens/dokumente_screen.dart L{i+1} (unwiderruflich)")
if modified:
    with open(full_path2, 'w') as f:
        f.writelines(lines)
    if "lib/screens/dokumente_screen.dart" not in changed:
        changed.append("lib/screens/dokumente_screen.dart")

# Fix patient_detail_screen Aufgaben auswählen
full_path3 = os.path.join(BASE, "lib/features/doctor_patients/presentation/patient_detail_screen.dart")
with open(full_path3, 'r') as f:
    content = f.read()
old = "Text('Aufgaben ausw\u00e4hlen (${_selected.length}/${_tasks!.length}):')"
new = "Text(l.aufgabenAuswaehlenCount(_selected.length, _tasks!.length))"
if old in content:
    content = content.replace(old, new, 1)
    with open(full_path3, 'w') as f:
        f.write(content)
    changed.append("lib/features/doctor_patients/presentation/patient_detail_screen.dart")
    print("  Fixed patient_detail_screen.dart (Aufgaben)")

# Fix system_templates_tab Aufgaben count
full_path4 = os.path.join(BASE, "lib/roles/admin/system_templates_tab.dart")
with open(full_path4, 'r') as f:
    content = f.read()
old = "Text('Aufgaben (${_tasks.length})')"
new = "Text(l.aufgabenCount(_tasks.length))"
if old in content:
    content = content.replace(old, new, 1)
    with open(full_path4, 'w') as f:
        f.write(content)
    changed.append("lib/roles/admin/system_templates_tab.dart")
    print("  Fixed system_templates_tab.dart (Aufgaben)")

print(f"\nFixed {len(changed)} files")
