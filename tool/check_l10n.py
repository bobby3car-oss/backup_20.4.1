#!/usr/bin/env python3
"""Check all ARB translation files for missing keys."""
import json
import os

BASE = os.path.join(os.path.dirname(__file__), '..', 'lib', 'l10n')

files = {
    'de': os.path.join(BASE, 'app_de.arb'),
    'en': os.path.join(BASE, 'app_en.arb'),
    'ar': os.path.join(BASE, 'app_ar.arb'),
    'ru': os.path.join(BASE, 'app_ru.arb'),
    'tr': os.path.join(BASE, 'app_tr.arb'),
}

data = {}
for lang, path in files.items():
    with open(path, 'r') as f:
        arb = json.load(f)
    keys = {k for k in arb.keys() if not k.startswith('@') and k != '@@locale'}
    data[lang] = keys

template_keys = data['de']
print(f"Template (de) has {len(template_keys)} translation keys\n")

for lang in ['en', 'ar', 'ru', 'tr']:
    keys = data[lang]
    missing = template_keys - keys
    extra = keys - template_keys
    print(f"=== {lang.upper()} ({len(keys)} keys) ===")
    if missing:
        print(f"  MISSING from template ({len(missing)} keys):")
        for k in sorted(missing):
            print(f"    - {k}")
    else:
        print("  No missing keys!")
    if extra:
        print(f"  EXTRA not in template ({len(extra)} keys):")
        for k in sorted(extra):
            print(f"    - {k}")
    print()
