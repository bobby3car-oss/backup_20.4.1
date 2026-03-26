#!/usr/bin/env python3
"""Check ARB files for missing keys and find l10n keys used in code but missing from ARB."""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N_DIR = os.path.join(ROOT, 'lib', 'l10n')

files = {
    'de': os.path.join(L10N_DIR, 'app_de.arb'),
    'en': os.path.join(L10N_DIR, 'app_en.arb'),
    'ar': os.path.join(L10N_DIR, 'app_ar.arb'),
    'ru': os.path.join(L10N_DIR, 'app_ru.arb'),
    'tr': os.path.join(L10N_DIR, 'app_tr.arb'),
}

data = {}
for lang, path in files.items():
    with open(path) as f:
        data[lang] = json.load(f)

def get_keys(d):
    return {k for k in d.keys() if not k.startswith('@')}

de_keys = get_keys(data['de'])
print(f"DE (template): {len(de_keys)} keys")

all_match = True
for lang in ['en', 'ar', 'ru', 'tr']:
    lang_keys = get_keys(data[lang])
    missing = de_keys - lang_keys
    extra = lang_keys - de_keys
    print(f"{lang.upper()}: {len(lang_keys)} keys")
    if missing:
        print(f"  MISSING in {lang.upper()}: {sorted(missing)}")
        all_match = False
    if extra:
        print(f"  EXTRA in {lang.upper()}: {sorted(extra)}")
        all_match = False

if all_match:
    print("\n=== All keys match across all 5 languages! ===")
else:
    print("\n=== KEY MISMATCH FOUND ===")

# Now find l10n keys used in Dart code
print("\n--- Checking for l10n keys used in code ---")
l10n_pattern = re.compile(r'l10n\.(\w+)')
localizations_pattern = re.compile(r'AppLocalizations\.of\(context\)[\!]?\.(\w+)')

used_keys = set()
lib_dir = os.path.join(ROOT, 'lib')
for dirpath, dirnames, filenames in os.walk(lib_dir):
    # Skip generated files
    if '.dart_tool' in dirpath or 'generated' in dirpath:
        continue
    for fn in filenames:
        if fn.endswith('.dart') and not fn.startswith('app_localizations'):
            filepath = os.path.join(dirpath, fn)
            with open(filepath) as f:
                content = f.read()
            for m in l10n_pattern.finditer(content):
                used_keys.add(m.group(1))
            for m in localizations_pattern.finditer(content):
                used_keys.add(m.group(1))

# Filter out non-translation properties
used_keys.discard('localeName')

missing_in_arb = used_keys - de_keys
unused_in_code = de_keys - used_keys

if missing_in_arb:
    print(f"\nKeys used in code but MISSING from ARB files ({len(missing_in_arb)}):")
    for k in sorted(missing_in_arb):
        print(f"  - {k}")
else:
    print("\nNo keys used in code are missing from ARB files.")

if unused_in_code:
    print(f"\nKeys in ARB but NOT found in code ({len(unused_in_code)}):")
    for k in sorted(unused_in_code):
        print(f"  - {k}")
else:
    print("\nAll ARB keys are used in code.")

print(f"\nSummary: {len(de_keys)} ARB keys, {len(used_keys)} keys used in code")
