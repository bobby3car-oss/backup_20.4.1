#!/usr/bin/env python3
"""Find all hardcoded German strings in Dart files that should be localized."""
import os
import re
import json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N_DIR = os.path.join(ROOT, 'lib', 'l10n')

# Load existing ARB keys/values
with open(os.path.join(L10N_DIR, 'app_de.arb')) as f:
    arb = json.load(f)

arb_values = set()
arb_key_for_value = {}
for k, v in arb.items():
    if not k.startswith('@') and isinstance(v, str):
        arb_values.add(v)
        arb_key_for_value[v] = k

results = {}
lib_dir = os.path.join(ROOT, 'lib')
skip_dirs = {'l10n', 'generated'}
skip_files = {'app_localizations', 'firebase_options'}

for dirpath, dirnames, filenames in os.walk(lib_dir):
    dirnames[:] = [d for d in dirnames if d not in skip_dirs]
    for fn in filenames:
        if not fn.endswith('.dart'):
            continue
        if any(s in fn for s in skip_files):
            continue
        filepath = os.path.join(dirpath, fn)
        with open(filepath) as f:
            content = f.read()
            lines = content.split('\n')

        # Check if file already uses l10n
        has_l10n = 'AppLocalizations' in content or 'final l = ' in content

        file_hits = []
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            # Skip comments
            if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
                continue
            # Skip imports
            if stripped.startswith('import '):
                continue

            # Find strings with German umlauts or sharp s
            matches = re.findall(r"'([^']{2,})'|\"([^\"]{2,})\"", line)
            for m in matches:
                s = m[0] or m[1]
                if not s:
                    continue
                # Must contain at least one German-specific char or be a known German phrase
                has_german = bool(re.search(r'[äöüÄÖÜß]', s))
                if not has_german:
                    continue
                # Skip technical strings
                if s.startswith('http') or s.startswith('/') or s.startswith('assets/'):
                    continue
                if s.startswith('package:') or s.startswith('firebase'):
                    continue
                if '.' in s and not ' ' in s and len(s.split('.')) > 2:
                    continue
                # Skip if already using l10n reference
                if 'l.' in s or 'l10n.' in s:
                    continue

                in_arb = s in arb_values
                arb_key = arb_key_for_value.get(s, '')
                file_hits.append((i, s, in_arb, arb_key))

        if file_hits:
            rel_path = os.path.relpath(filepath, ROOT)
            results[rel_path] = (file_hits, has_l10n)

# Print summary
total = sum(len(v[0]) for v in results.values())
in_arb_count = sum(1 for hits, _ in results.values() for _, _, in_arb, _ in hits if in_arb)
not_in_arb = total - in_arb_count

print(f"=== HARDCODED GERMAN STRINGS REPORT ===")
print(f"Total: {total} strings in {len(results)} files")
print(f"  Already in ARB (need Dart replacement): {in_arb_count}")
print(f"  NOT in ARB (need ARB entry + Dart replacement): {not_in_arb}")
print()

# Group by status
print("--- FILES WITH STRINGS ALREADY IN ARB (just need Dart update) ---")
for filepath in sorted(results.keys()):
    hits, has_l10n = results[filepath]
    arb_hits = [(l, s, k) for l, s, ia, k in hits if ia]
    if arb_hits:
        l10n_status = "HAS l10n" if has_l10n else "NEEDS l10n setup"
        print(f"\n{filepath} [{l10n_status}] ({len(arb_hits)} strings):")
        for line_no, s, key in arb_hits:
            print(f"  L{line_no}: \"{s}\" -> l.{key}")

print("\n\n--- STRINGS NOT YET IN ARB (need new ARB entries) ---")
for filepath in sorted(results.keys()):
    hits, has_l10n = results[filepath]
    new_hits = [(l, s) for l, s, ia, _ in hits if not ia]
    if new_hits:
        print(f"\n{filepath} ({len(new_hits)} strings):")
        for line_no, s in new_hits:
            print(f"  L{line_no}: \"{s}\"")
