#!/usr/bin/env python3
"""
Careful batch l10n replacement for presentation layer Dart files.

Key improvements over v1:
1. Detects multi-line string concatenation and treats them as single strings
2. Skips strings in const contexts
3. Only replaces in files that already have 'final l = AppLocalizations.of(context)!'
   OR files where we can safely add it (clear build method)
4. Skips non-widget files (no BuildContext)
5. Validates each replacement doesn't break syntax

Strategy: CONSERVATIVE replacement
- Only replace simple, single-line, non-const, non-interpolated strings
- Only in files that already have l10n set up OR simple widgets
- Skip anything ambiguous
"""
import os
import re
import json
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N_DIR = os.path.join(ROOT, 'lib', 'l10n')
DRY_RUN = '--dry-run' in sys.argv

# ─── Load existing ARB ──────────────────────────────────────────────
arb_files_paths = {
    'de': os.path.join(L10N_DIR, 'app_de.arb'),
    'en': os.path.join(L10N_DIR, 'app_en.arb'),
    'ar': os.path.join(L10N_DIR, 'app_ar.arb'),
    'ru': os.path.join(L10N_DIR, 'app_ru.arb'),
    'tr': os.path.join(L10N_DIR, 'app_tr.arb'),
}
arb_data = {}
for lang, path in arb_files_paths.items():
    with open(path, encoding='utf-8') as f:
        arb_data[lang] = json.load(f)

existing_keys = {k for k in arb_data['de'] if not k.startswith('@') and k != '@@locale'}
existing_values = {}
for k, v in arb_data['de'].items():
    if not k.startswith('@') and isinstance(v, str):
        existing_values[v] = k


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


def is_presentation_file(filepath: str) -> bool:
    patterns = [
        '/screens/', '/presentation/', '/roles/',
        '_screen.dart', '_tab.dart', '_dialog.dart', '_sheet.dart',
        '_card.dart', '_tile.dart', '_page.dart', '_overlay.dart',
        '_banner.dart',
    ]
    return any(p in filepath for p in patterns)


def is_in_const_context(lines: list, line_idx: int, col: int) -> bool:
    """Check if position is inside a const expression."""
    line = lines[line_idx]
    before = line[:col]
    # Check for 'const ' on this line before the position
    if 'const ' in before or 'const[' in before or 'const(' in before:
        return True
    # Check if a const constructor precedes within a few lines
    for back in range(1, 6):
        prev_idx = line_idx - back
        if prev_idx < 0:
            break
        prev = lines[prev_idx].strip()
        if prev.startswith('const ') or 'const ' in prev:
            # Very rough check: if we find const and no closing paren/bracket after it
            return True
        if prev.endswith(';') or prev.endswith('{') or prev.endswith('}'):
            break
    return False


def is_multiline_concat(lines: list, line_idx: int, string_value: str) -> bool:
    """Check if this string is part of a multi-line concatenation."""
    line = lines[line_idx].rstrip()
    # If the line ends with just a quote (string continues on next line)
    if line.endswith("'") or line.endswith('"'):
        next_idx = line_idx + 1
        if next_idx < len(lines):
            next_stripped = lines[next_idx].strip()
            if next_stripped.startswith("'") or next_stripped.startswith('"'):
                return True

    # If the previous line ends with a string that continues here
    if line_idx > 0:
        prev_stripped = lines[line_idx - 1].rstrip()
        if prev_stripped.endswith("'") or prev_stripped.endswith('"'):
            return True

    # Check for string adjacency on same line (e.g., 'part1' 'part2')
    # by looking for two quote pairs near each other
    quote_char = "'" if f"'{string_value}'" in lines[line_idx] else '"'
    full_pattern = f"{quote_char}{re.escape(string_value)}{quote_char}"
    match = re.search(full_pattern, lines[line_idx])
    if match:
        after = lines[line_idx][match.end():].strip()
        if after and after[0] in ("'", '"'):
            return True
        before = lines[line_idx][:match.start()].rstrip()
        if before and before[-1] in ("'", '"'):
            return True

    return False


def has_build_method(content: str) -> bool:
    return bool(re.search(r'Widget\s+build\s*\(\s*BuildContext', content))


def find_build_method_brace(lines: list) -> int:
    """Find the opening brace line of the build() method. Returns -1 if not found."""
    for i, line in enumerate(lines):
        if re.search(r'Widget\s+build\s*\(\s*BuildContext', line.strip()):
            # Find opening brace
            for j in range(i, min(i + 4, len(lines))):
                if '{' in lines[j]:
                    return j
    return -1


def get_l10n_import(dart_file_rel: str) -> str:
    file_dir = os.path.dirname(dart_file_rel)
    from_parts = file_dir.split('/')
    to_parts = 'lib/l10n/app_localizations.dart'.split('/')
    common = 0
    for a, b in zip(from_parts, to_parts):
        if a == b:
            common += 1
        else:
            break
    ups = len(from_parts) - common
    remaining = '/'.join(to_parts[common:])
    return f"'{'../' * ups}{remaining}'"


def find_safe_strings(filepath_rel: str) -> list:
    """Find all safely replaceable German strings in a presentation file.
    Returns list of (line_idx, col, string, quote_char)."""
    filepath = os.path.join(ROOT, filepath_rel)
    with open(filepath, encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\n')

    if not is_presentation_file(filepath_rel):
        return []

    # Check if file has BuildContext
    if 'BuildContext' not in content and 'context' not in content:
        return []

    results = []
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
            continue
        if stripped.startswith('import '):
            continue

        # Find quoted strings
        for m in re.finditer(r"'([^'\\]{2,})'|\"([^\"\\]{2,})\"", line):
            s = m.group(1) or m.group(2)
            if not s:
                continue
            # Must contain German umlaut
            if not re.search(r'[äöüÄÖÜß]', s):
                continue
            # Skip technical strings
            if s.startswith(('http', '/', 'assets/', 'package:', 'firebase')):
                continue
            if '.' in s and ' ' not in s and len(s.split('.')) > 2:
                continue
            if 'l.' in s or 'l10n.' in s:
                continue
            # Skip interpolated strings
            if '$' in s:
                continue
            # Skip strings with braces (ICU conflict)
            if '{' in s or '}' in s:
                continue
            # Skip multiline concatenation
            if is_multiline_concat(lines, i, s):
                continue
            # Skip const contexts
            col = m.start()
            if is_in_const_context(lines, i, col):
                continue

            quote = "'" if m.group(1) is not None else '"'
            results.append((i, col, s, quote))

    return results


def main():
    lib_dir = os.path.join(ROOT, 'lib')
    skip_dirs = {'l10n', 'generated'}

    # Find all presentation files with hardcoded German strings
    all_files = {}
    for dirpath, dirnames, filenames in os.walk(lib_dir):
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for fn in filenames:
            if not fn.endswith('.dart'):
                continue
            filepath = os.path.join(dirpath, fn)
            rel = os.path.relpath(filepath, ROOT)
            if not is_presentation_file(rel):
                continue
            strings = find_safe_strings(rel)
            if strings:
                all_files[rel] = strings

    # Build key mapping
    new_keys = {}
    string_to_key = dict(existing_values)
    used_keys = set(existing_keys)

    all_unique_strings = set()
    for strings in all_files.values():
        for _, _, s, _ in strings:
            all_unique_strings.add(s)

    for s in sorted(all_unique_strings):
        if s in string_to_key:
            continue
        base = to_camel_case(s)
        key = base
        counter = 2
        while key in used_keys:
            key = f"{base}{counter}"
            counter += 1
        used_keys.add(key)
        string_to_key[s] = key
        new_keys[key] = s

    total_strings = sum(len(v) for v in all_files.values())
    print(f"Files to process: {len(all_files)}")
    print(f"New ARB keys: {len(new_keys)}")
    print(f"Total safe strings to replace: {total_strings}")

    if DRY_RUN:
        print("\n=== DRY RUN ===")
        for f, strings in sorted(all_files.items()):
            skipped_str = [s for _, _, s, _ in strings if s not in string_to_key]
            print(f"  {f}: {len(strings)} strings")
        return

    # ─── Add to ARB ──────────────────────────────────────────────────
    for key, de_value in new_keys.items():
        for lang in arb_data:
            arb_data[lang][key] = de_value  # German as placeholder

    for lang, path in arb_files_paths.items():
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(arb_data[lang], f, ensure_ascii=False, indent=2)
            f.write('\n')

    key_count = len([k for k in arb_data['de'] if not k.startswith('@') and k != '@@locale'])
    print(f"  ARB keys total: {key_count}")

    # ─── Replace in Dart files ────────────────────────────────────────
    replaced_total = 0
    imports_added = 0
    l_vars_added = 0
    skipped = 0

    for rel_path, strings in sorted(all_files.items()):
        filepath = os.path.join(ROOT, rel_path)
        with open(filepath, encoding='utf-8') as f:
            content = f.read()
        lines = content.split('\n')

        has_l10n = 'final l = AppLocalizations.of(context)!' in content
        has_import = 'app_localizations.dart' in content
        has_build = has_build_method(content)

        # Only process files that:
        # 1. Already have l10n setup, OR
        # 2. Have a build method where we can add it
        if not has_l10n and not has_build:
            skipped += len(strings)
            continue

        replaced_in_file = 0

        # Replace strings from bottom to top to preserve line numbers
        for line_idx, col, german, quote in sorted(strings, reverse=True):
            key = string_to_key.get(german)
            if not key:
                continue

            l_ref = f'l.{key}'
            line = lines[line_idx]

            # Build the exact quoted string to replace
            old = f"{quote}{german}{quote}"
            if old not in line:
                continue

            # Replace first occurrence on this line
            new_line = line.replace(old, l_ref, 1)

            # Validate: the replacement shouldn't break obvious syntax
            # Check the char before l_ref isn't another identifier char
            ref_pos = new_line.find(l_ref)
            if ref_pos > 0:
                char_before = new_line[ref_pos - 1]
                if char_before.isalnum() or char_before == '_':
                    # Would merge with another identifier
                    skipped += 1
                    continue

            lines[line_idx] = new_line
            replaced_in_file += 1

        if replaced_in_file == 0:
            continue

        replaced_total += replaced_in_file

        # Add import if needed
        if not has_import:
            import_path = get_l10n_import(rel_path)
            import_line = f"import {import_path};"
            # Find last import line
            last_import = -1
            for i, line in enumerate(lines):
                if line.strip().startswith('import '):
                    last_import = i
            if last_import >= 0:
                lines.insert(last_import + 1, import_line)
                imports_added += 1
                # Shift all line indices since we added a line
                # (This is OK because we already did the replacements)

        # Add final l if needed
        content_after = '\n'.join(lines)
        if 'final l = AppLocalizations.of(context)!' not in content_after:
            build_brace = find_build_method_brace(lines)
            if build_brace >= 0:
                # Determine indent
                m = re.match(r'^(\s*)', lines[build_brace])
                base = m.group(1) if m else ''
                indent = base + '    '
                l_line = f"{indent}final l = AppLocalizations.of(context)!;"
                lines.insert(build_brace + 1, l_line)
                l_vars_added += 1

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))

    print(f"\nResults:")
    print(f"  Strings replaced: {replaced_total}")
    print(f"  Imports added: {imports_added}")
    print(f"  'final l' added: {l_vars_added}")
    print(f"  Skipped (unsafe): {skipped}")


if __name__ == '__main__':
    main()
