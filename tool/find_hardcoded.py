#!/usr/bin/env python3
"""Find all remaining hardcoded German UI strings in Dart files."""
import re
import os

patterns = [
    r"Text\('([^']{3,})'",
    r'Text\("([^"]{3,})"',
    r"label:\s*Text\('([^']{3,})'",
    r"title:\s*Text\('([^']{3,})'",
    r"hintText:\s*'([^']{3,})'",
    r"labelText:\s*'([^']{3,})'",
    r"content:\s*Text\('([^']{3,})'",
    r"tooltip:\s*'([^']{3,})'",
    r"child:\s*Text\('([^']{3,})'",
    r"subtitle:\s*Text\('([^']{3,})'",
    r"'fallback':\s*'([^']{3,})'",
    r"fallback:\s*'([^']{3,})'",
]

german_chars = set('äöüÄÖÜß')
german_words = [
    'und', 'oder', 'ist', 'die', 'der', 'das', 'ein', 'eine', 'nicht',
    'Bitte', 'Fehler', 'Keine', 'Kein', 'Alle', 'Neu', 'Speicher',
    'Erstell', 'Hinzu', 'Entfern', 'Wirklich', 'Abbrechen',
    'Bearbeit', 'Gespeichert', 'Geladen', 'Verbind', 'Trennen',
    'auswählen', 'eingeben', 'Aufgabe', 'Vorlage', 'Mitarbeiter',
    'Einnahme', 'Wochentag', 'Benachrichtig', 'Passwort', 'Dokument',
    'Termin', 'Pflege', 'Wunde', 'Schmerz', 'Medikament', 'Mahlzeit',
    'Warnung', 'Analyse', 'Aufnahme', 'Ticket', 'Push', 'Status',
    'Rolle', 'Debug', 'Partner', 'Anzeige', 'Export', 'Foto',
    'gesendet', 'gesperrt', 'entsperrt', 'entfernt', 'vergeben',
    'konnte', 'wurde', 'werden', 'bereits', 'letzten', 'diesem',
]


def has_german(s):
    if any(c in german_chars for c in s):
        return True
    for gw in german_words:
        if gw.lower() in s.lower():
            return True
    return False


results = {}
for root, dirs, files in os.walk('lib'):
    dirs[:] = [d for d in dirs if d not in ['l10n', 'generated']]
    for f in files:
        if not f.endswith('.dart') or f.endswith('.g.dart'):
            continue
        path = os.path.join(root, f)
        with open(path) as fh:
            for i, line in enumerate(fh, 1):
                stripped = line.strip()
                if stripped.startswith('//') or stripped.startswith('///'):
                    continue
                for pat in patterns:
                    for m in re.finditer(pat, line):
                        s = m.group(1)
                        if has_german(s):
                            if path not in results:
                                results[path] = []
                            results[path].append((i, s))

total = sum(len(v) for v in results.values())
print(f'Total: {total} hardcoded strings in {len(results)} files\n')
for path in sorted(results.keys()):
    print(f'{path} ({len(results[path])}):')
    for line, s in results[path]:
        print(f'  L{line}: {s[:100]}')
    print()
