#!/usr/bin/env python3
"""Find hardcoded English strings in Dart files (multi-word English phrases in string literals)."""
import os, re

# English-marker words that appear in typical UI strings
ENGLISH_MARKERS = re.compile(
    r'\b(the |The |and |for |with |your |Your |has |have |been |not |from |'
    r'saved|removed|linked|blocked|deleted|available|Please|please|Only |only |'
    r'assigned|loading|Saving |Update|update|Delete|Create|Add |Select|Cancel|'
    r'Submit|Confirm|Close|Back |Next |Done |Edit |View |Show |Hide |Check |'
    r'Enter |Choose|Upload|Download|Share|Search|Filter|Refresh|Reload)\b'
)

GERMAN_CHARS = re.compile(r'[äöüÄÖÜß]|Bitte|bitte|Klick|klick|Kein|kein|Alle|alle|'
                           r'Neue|neue|Mein|mein|Dein|dein|Wähle|wähle|Erstell')

# Match single-quoted or double-quoted string literals
STRING_LIT = re.compile(r"'([^'\\]{4,})'|\"([^\"\\]{4,})\"")

results = []

for root, dirs, files in os.walk('lib'):
    # Skip generated files
    dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'generated', 'gen']]
    for fname in files:
        if not fname.endswith('.dart'):
            continue
        path = os.path.join(root, fname)
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
        for i, line in enumerate(lines, 1):
            # Skip comments and import lines
            stripped = line.strip()
            if stripped.startswith('//') or stripped.startswith('import ') or stripped.startswith('///'):
                continue
            for m in STRING_LIT.finditer(line):
                val = m.group(1) or m.group(2)
                if (ENGLISH_MARKERS.search(val)
                        and not GERMAN_CHARS.search(val)
                        and len(val) > 6):
                    results.append((path, i, val))

print(f'Found {len(results)} potentially hardcoded English strings:\n')
# Group by file
from collections import defaultdict
by_file = defaultdict(list)
for path, lineno, val in results:
    by_file[path].append((lineno, val))

for path in sorted(by_file):
    print(f'\n{path}:')
    for lineno, val in by_file[path]:
        print(f'  L{lineno}: {repr(val[:100])}')
