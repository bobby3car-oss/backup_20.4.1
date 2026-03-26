#!/usr/bin/env python3
"""
Batch l10n: Add ARB keys and replace hardcoded German strings in Dart files.

This script:
1. Reads hardcoded German strings from presentation layer Dart files
2. Generates ARB key names
3. Adds keys to all 5 ARB files (DE=original, others=German placeholder)
4. Replaces hardcoded strings in Dart with l.keyName
5. Adds import + final l declaration where needed

Only handles PLAIN strings (no $ interpolation). Interpolated strings are skipped.
Only handles presentation layer files (screens, tabs, cards, dialogs, etc.).
"""
import os
import re
import json
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N_DIR = os.path.join(ROOT, 'lib', 'l10n')
DRY_RUN = '--dry-run' in sys.argv

# ─── Load existing ARB ──────────────────────────────────────────────
arb_files = {
    'de': os.path.join(L10N_DIR, 'app_de.arb'),
    'en': os.path.join(L10N_DIR, 'app_en.arb'),
    'ar': os.path.join(L10N_DIR, 'app_ar.arb'),
    'ru': os.path.join(L10N_DIR, 'app_ru.arb'),
    'tr': os.path.join(L10N_DIR, 'app_tr.arb'),
}
arb_data = {}
for lang, path in arb_files.items():
    with open(path, encoding='utf-8') as f:
        arb_data[lang] = json.load(f)

existing_keys = {k for k in arb_data['de'] if not k.startswith('@') and k != '@@locale'}
existing_values = {}
for k, v in arb_data['de'].items():
    if not k.startswith('@') and isinstance(v, str):
        existing_values[v] = k

# ─── Key generation ──────────────────────────────────────────────────
def to_camel_case(text: str) -> str:
    s = text.strip()
    if len(s) > 60:
        s = s[:60]
    for old, new in {'ä':'ae','ö':'oe','ü':'ue','ß':'ss','Ä':'Ae','Ö':'Oe','Ü':'Ue'}.items():
        s = s.replace(old, new)
    s = re.sub(r'[^a-zA-Z0-9\s]', ' ', s)
    words = s.split()
    if not words:
        return 'unknown'
    result = words[0].lower()
    for w in words[1:]:
        if w:
            result += w[0].upper() + w[1:].lower()
    if result and result[0].isdigit():
        result = 'n' + result
    return result[:80]


# ─── Presentation file detection ─────────────────────────────────────
def is_presentation_file(filepath: str) -> bool:
    patterns = [
        '/screens/', '/presentation/', '/ui/', '/roles/',
        '_screen.dart', '_tab.dart', '_dialog.dart', '_sheet.dart',
        '_card.dart', '_tile.dart', '_page.dart', '_overlay.dart',
        '_banner.dart', '_widget.dart', '_indicator.dart',
    ]
    return any(p in filepath for p in patterns)


# ─── Find strings ────────────────────────────────────────────────────
def find_strings():
    """Find all hardcoded German strings, return dict: file -> [(line, string)]."""
    lib_dir = os.path.join(ROOT, 'lib')
    skip_dirs = {'l10n', 'generated'}
    skip_files = {'app_localizations', 'firebase_options'}
    results = {}

    for dirpath, dirnames, filenames in os.walk(lib_dir):
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for fn in filenames:
            if not fn.endswith('.dart'):
                continue
            if any(s in fn for s in skip_files):
                continue
            filepath = os.path.join(dirpath, fn)
            rel = os.path.relpath(filepath, ROOT)
            if not is_presentation_file(rel):
                continue

            with open(filepath, encoding='utf-8') as f:
                lines = f.read().split('\n')

            hits = []
            for i, line in enumerate(lines, 1):
                stripped = line.strip()
                if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
                    continue
                if stripped.startswith('import '):
                    continue

                matches = re.findall(r"'([^']{2,})'|\"([^\"]{2,})\"", line)
                for m in matches:
                    s = m[0] or m[1]
                    if not s or not re.search(r'[äöüÄÖÜß]', s):
                        continue
                    # Skip technical strings
                    if s.startswith(('http', '/', 'assets/', 'package:', 'firebase')):
                        continue
                    if '.' in s and ' ' not in s and len(s.split('.')) > 2:
                        continue
                    if 'l.' in s or 'l10n.' in s:
                        continue
                    # Skip interpolated strings (contain $)
                    if '$' in s:
                        continue
                    hits.append((i, s))

            if hits:
                results[rel] = hits
    return results


# ─── Calculate relative import path ──────────────────────────────────
def get_l10n_import(dart_file_rel: str) -> str:
    """Get the relative import path from a Dart file to app_localizations.dart."""
    file_dir = os.path.dirname(dart_file_rel)
    target = 'lib/l10n/app_localizations.dart'
    # Both are relative to ROOT
    from_parts = file_dir.split('/')
    to_parts = target.split('/')
    # Find common prefix
    common = 0
    for a, b in zip(from_parts, to_parts):
        if a == b:
            common += 1
        else:
            break
    ups = len(from_parts) - common
    remaining = '/'.join(to_parts[common:])
    if ups == 0:
        return f"'{remaining}'"
    return f"'{'../' * ups}{remaining}'"


# ─── Find insert point for final l ───────────────────────────────────
def find_l_insert_line(lines: list) -> int:
    """Find the line number (0-based) to insert 'final l = ...' after.
    Looks for `Widget build(BuildContext context)` method.
    Returns -1 if not found."""
    for i, line in enumerate(lines):
        stripped = line.strip()
        # Match build method patterns
        if re.search(r'Widget\s+build\s*\(\s*BuildContext\s+\w+\s*\)', stripped):
            # Find the opening brace
            if '{' in stripped:
                return i  # insert after this line
            # Brace might be on next line
            for j in range(i + 1, min(i + 3, len(lines))):
                if '{' in lines[j]:
                    return j
            return i
    return -1


# ─── Main ─────────────────────────────────────────────────────────────
def main():
    file_strings = find_strings()

    # Build key mapping
    new_keys = {}  # key -> german_value
    string_to_key = dict(existing_values)  # german_value -> key (starting with existing)
    used_keys = set(existing_keys)

    all_strings = set()
    for hits in file_strings.values():
        for _, s in hits:
            all_strings.add(s)

    for s in sorted(all_strings):
        if s in string_to_key:
            continue
        base_key = to_camel_case(s)
        key = base_key
        counter = 2
        while key in used_keys:
            key = f"{base_key}{counter}"
            counter += 1
        used_keys.add(key)
        string_to_key[s] = key
        new_keys[key] = s

    print(f"Files to process: {len(file_strings)}")
    print(f"New ARB keys: {len(new_keys)}")
    print(f"Total strings to replace: {sum(len(h) for h in file_strings.values())}")

    if DRY_RUN:
        print("\n=== DRY RUN — no files modified ===")
        for key in sorted(new_keys.keys())[:30]:
            print(f"  {key}: {repr(new_keys[key])}")
        if len(new_keys) > 30:
            print(f"  ... and {len(new_keys) - 30} more")
        return

    # ─── Add to ARB files ─────────────────────────────────────────────
    for key, de_value in new_keys.items():
        arb_data['de'][key] = de_value
        # Use German value as placeholder for all languages
        # (proper translations should be added separately)
        arb_data['en'][key] = de_value
        arb_data['ar'][key] = de_value
        arb_data['ru'][key] = de_value
        arb_data['tr'][key] = de_value

    for lang, path in arb_files.items():
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(arb_data[lang], f, ensure_ascii=False, indent=2)
            f.write('\n')
        count = len([k for k in arb_data[lang] if not k.startswith('@') and k != '@@locale'])
        print(f"  {lang.upper()}: {count} keys")

    # ─── Replace in Dart files ────────────────────────────────────────
    replaced_total = 0
    imports_added = 0
    l_vars_added = 0
    errors = []

    for rel_path, hits in sorted(file_strings.items()):
        filepath = os.path.join(ROOT, rel_path)
        with open(filepath, encoding='utf-8') as f:
            content = f.read()
        original = content
        lines = content.split('\n')

        # Track replacements for this file
        replaced_in_file = 0

        for line_no, german in hits:
            key = string_to_key.get(german)
            if not key:
                errors.append(f"  No key for: {repr(german)} in {rel_path}:{line_no}")
                continue

            l_ref = f'l.{key}'

            # Replace 'string' or "string" with l.key
            # Be careful to match the exact string with its quotes
            idx = line_no - 1
            if idx >= len(lines):
                continue

            line = lines[idx]
            # Try single quotes first, then double
            old_single = f"'{german}'"
            old_double = f'"{german}"'

            if old_single in line:
                lines[idx] = line.replace(old_single, l_ref, 1)
                replaced_in_file += 1
            elif old_double in line:
                lines[idx] = line.replace(old_double, l_ref, 1)
                replaced_in_file += 1
            else:
                # String might span or have escapes, skip
                errors.append(f"  Could not find exact string in {rel_path}:{line_no}: {repr(german[:50])}")

        if replaced_in_file == 0:
            continue

        replaced_total += replaced_in_file
        content = '\n'.join(lines)

        # Add import if needed
        if 'app_localizations.dart' not in content:
            import_path = get_l10n_import(rel_path)
            import_line = f"import {import_path};"
            # Add after last import
            import_idx = -1
            for i, line in enumerate(lines):
                if line.strip().startswith('import '):
                    import_idx = i
            if import_idx >= 0:
                lines.insert(import_idx + 1, import_line)
                imports_added += 1

        # Add final l if needed
        if 'final l = AppLocalizations.of(context)!' not in '\n'.join(lines):
            insert_at = find_l_insert_line(lines)
            if insert_at >= 0:
                # Find indentation
                indent = '    '
                if insert_at < len(lines):
                    m = re.match(r'^(\s+)', lines[insert_at])
                    if m:
                        indent = m.group(1) + '  '
                l_line = f"{indent}final l = AppLocalizations.of(context)!;"
                lines.insert(insert_at + 1, l_line)
                l_vars_added += 1

        content = '\n'.join(lines)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    print(f"\nResults:")
    print(f"  Strings replaced: {replaced_total}")
    print(f"  Imports added: {imports_added}")
    print(f"  'final l' added: {l_vars_added}")
    if errors:
        print(f"\n  Warnings ({len(errors)}):")
        for e in errors[:20]:
            print(e)
        if len(errors) > 20:
            print(f"  ... and {len(errors) - 20} more")


if __name__ == '__main__':
    main()
