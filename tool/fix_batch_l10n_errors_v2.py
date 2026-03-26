#!/usr/bin/env python3
"""
Fix broken multi-line string replacements.

When l10n replacement replaced only ONE part of a multi-line concatenated string
like:
    'First part with Ü ' 
    'second part without umlauts',
It became:
    l.firstPartWithUe
    'second part without umlauts',
Which is invalid syntax. This script reverts these broken replacements.

It also fixes remaining const errors and undefined l issues.
"""
import os
import re
import subprocess
import json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FLUTTER = '/Users/jan/development/flutter/bin/flutter'
L10N_DIR = os.path.join(ROOT, 'lib', 'l10n')


def get_git_diff_lines():
    """Get all changed lines from git diff HEAD."""
    result = subprocess.run(
        ['git', 'diff', 'HEAD', '--unified=0', '--', 'lib/'],
        capture_output=True, text=True, cwd=ROOT
    )
    # Parse diff to find changed lines per file
    changes = {}  # file -> {line_no: (old_line, new_line)}
    current_file = None

    for line in result.stdout.split('\n'):
        if line.startswith('diff --git'):
            # Extract file path
            parts = line.split(' b/')
            if len(parts) >= 2:
                current_file = parts[1]
        elif line.startswith('@@'):
            # Parse hunk header: @@ -old_start,old_count +new_start,new_count @@
            pass
    return changes


def fix_multiline_string_breaks():
    """Find and revert l.xxx replacements that broke multi-line strings."""
    lib_dir = os.path.join(ROOT, 'lib')
    fixed = 0

    # Load ARB to get key->value mapping
    with open(os.path.join(L10N_DIR, 'app_de.arb'), encoding='utf-8') as f:
        arb = json.load(f)
    key_to_value = {}
    for k, v in arb.items():
        if not k.startswith('@') and isinstance(v, str):
            key_to_value[k] = v

    # Scan all Dart files in lib/
    for dirpath, dirnames, filenames in os.walk(lib_dir):
        dirnames[:] = [d for d in dirnames if d not in {'l10n', 'generated'}]
        for fn in filenames:
            if not fn.endswith('.dart'):
                continue
            filepath = os.path.join(dirpath, fn)
            with open(filepath, encoding='utf-8') as f:
                lines = f.read().split('\n')

            changed = False
            i = 0
            while i < len(lines) - 1:
                line = lines[i]
                next_line = lines[i + 1].strip()

                # Pattern: line ends with l.someKey (no comma, no semicolon, no closing paren)
                # AND next line starts with a string literal (continuation)
                m = re.search(r'\bl\.([a-zA-Z][a-zA-Z0-9]*)\s*$', line.rstrip())
                if m and (next_line.startswith("'") or next_line.startswith('"')):
                    key = m.group(1)
                    if key in key_to_value:
                        # This is a broken multi-line replacement - revert
                        german = key_to_value[key]
                        # Restore the original quoted string
                        original = f"'{german}'"
                        lines[i] = line[:m.start()] + original
                        changed = True
                        fixed += 1

                # Also fix: l.someKey followed by comma on same line but next line has orphan string
                # Pattern: `l.key,` or `l.key)` at end of line is fine
                # Pattern: line has l.key and next line has 'string' without proper separator
                m2 = re.search(r'\bl\.([a-zA-Z][a-zA-Z0-9]*)\s*\n', line + '\n')
                if m2 and not m:
                    # Check if next line is an orphan string continuation
                    if next_line and next_line[0] in ("'", '"') and not next_line.startswith("'//"):
                        # Check if the string on next_line ends with a quote+comma or quote+paren
                        # which means it was meant to be concatenated
                        if re.match(r"^['\"].*['\"][,);]?\s*$", next_line):
                            key = m2.group(1)
                            if key in key_to_value:
                                german = key_to_value[key]
                                original = f"'{german}'"
                                idx = line.index(f'l.{key}')
                                lines[i] = line[:idx] + original
                                changed = True
                                fixed += 1

                i += 1

            if changed:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write('\n'.join(lines))

    return fixed


def fix_remaining_const():
    """Another pass at fixing const errors."""
    result = subprocess.run(
        [FLUTTER, 'analyze', '--no-pub'],
        capture_output=True, text=True, cwd=ROOT
    )
    output = result.stdout + result.stderr
    const_codes = {
        'invalid_constant', 'const_initialized_with_non_constant_value',
        'non_constant_list_element', 'non_constant_map_value',
        'non_constant_record_field', 'const_with_non_constant_argument',
    }

    errors_by_file = {}
    for line in output.split('\n'):
        if ' error • ' not in line:
            continue
        parts = line.strip().split(' • ')
        if len(parts) < 4:
            continue
        code = parts[3].strip()
        if code not in const_codes:
            continue
        loc = parts[2].strip()
        loc_parts = loc.rsplit(':', 2)
        if len(loc_parts) >= 3:
            filepath = loc_parts[0]
            try:
                line_no = int(loc_parts[1])
                col = int(loc_parts[2])
            except ValueError:
                continue
            errors_by_file.setdefault(filepath, []).append((line_no, col))

    fixed = 0
    for filepath, positions in errors_by_file.items():
        full = os.path.join(ROOT, filepath)
        with open(full, encoding='utf-8') as f:
            lines = f.read().split('\n')

        for line_no, col in sorted(positions, reverse=True):
            idx = line_no - 1
            if idx >= len(lines):
                continue
            line = lines[idx]

            # Look for 'const' before the error position on this line
            before = line[:col - 1]
            # Find const closest to error
            pos = before.rfind('const ')
            if pos >= 0:
                lines[idx] = line[:pos] + line[pos + 6:]
                fixed += 1
                continue

            # Check previous lines
            for back in range(1, 8):
                prev_idx = idx - back
                if prev_idx < 0:
                    break
                prev = lines[prev_idx]
                cp = prev.rfind('const ')
                if cp >= 0:
                    lines[prev_idx] = prev[:cp] + prev[cp + 6:]
                    fixed += 1
                    break

        with open(full, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))

    return fixed


def fix_l_in_non_build_methods():
    """Add final l in methods that use l.xxx but don't have it defined."""
    result = subprocess.run(
        [FLUTTER, 'analyze', '--no-pub'],
        capture_output=True, text=True, cwd=ROOT
    )
    output = result.stdout + result.stderr

    # Get undefined l errors
    undef_by_file = {}
    for line in output.split('\n'):
        if "Undefined name 'l'" not in line:
            continue
        parts = line.strip().split(' • ')
        if len(parts) < 4:
            continue
        loc = parts[2].strip()
        loc_parts = loc.rsplit(':', 2)
        if len(loc_parts) >= 3:
            filepath = loc_parts[0]
            try:
                line_no = int(loc_parts[1])
            except ValueError:
                continue
            undef_by_file.setdefault(filepath, []).append(line_no)

    fixed = 0
    for filepath, error_lines in undef_by_file.items():
        full = os.path.join(ROOT, filepath)
        with open(full, encoding='utf-8') as f:
            lines = f.read().split('\n')

        # For each error line, find the enclosing scope's opening brace
        # and add final l there if not present
        insert_points = set()
        for err_line in error_lines:
            err_idx = err_line - 1
            if err_idx >= len(lines):
                continue
            # Walk backwards to find function/method start
            brace_depth = 0
            for j in range(err_idx, -1, -1):
                for ch in reversed(lines[j]):
                    if ch == '}':
                        brace_depth += 1
                    elif ch == '{':
                        if brace_depth == 0:
                            # This is our enclosing scope
                            # Check if it's a method with context
                            # Look at this line and a few before for 'context'
                            scope_lines = '\n'.join(lines[max(0, j-3):j+1])
                            if 'context' in scope_lines.lower() or 'build' in scope_lines.lower():
                                insert_points.add(j)
                            break
                        brace_depth -= 1
                else:
                    continue
                break

        if not insert_points:
            continue

        # Insert from bottom to top
        added = 0
        for ip in sorted(insert_points, reverse=True):
            # Check if final l already exists in next few lines
            already = False
            for j in range(ip, min(ip + 5, len(lines))):
                if 'final l = AppLocalizations' in lines[j]:
                    already = True
                    break
            if already:
                continue

            # Determine indent
            m = re.match(r'^(\s*)', lines[ip])
            base = m.group(1) if m else ''
            indent = base + '    '

            lines.insert(ip + 1, f"{indent}final l = AppLocalizations.of(context)!;")
            added += 1

        if added > 0:
            # Ensure import
            content = '\n'.join(lines)
            if 'app_localizations.dart' not in content:
                rel = os.path.relpath(full, os.path.join(ROOT, 'lib'))
                depth = rel.count('/')
                import_path = '../' * depth + 'l10n/app_localizations.dart'
                import_line = f"import '{import_path}';"
                last_import = -1
                for i, line in enumerate(lines):
                    if line.strip().startswith('import '):
                        last_import = i
                if last_import >= 0:
                    lines.insert(last_import + 1, import_line)

            with open(full, 'w', encoding='utf-8') as f:
                f.write('\n'.join(lines))
            fixed += 1

    return fixed


def revert_l_in_nonwidget_files():
    """For files that don't have BuildContext (utility files, etc.),
    revert l.xxx back to the original German strings."""
    with open(os.path.join(L10N_DIR, 'app_de.arb'), encoding='utf-8') as f:
        arb = json.load(f)
    key_to_value = {}
    for k, v in arb.items():
        if not k.startswith('@') and isinstance(v, str):
            key_to_value[k] = v

    # Files known to not have BuildContext
    problem_files = [
        'lib/ui/error_helpers.dart',
        'lib/screens/home/home_view_model.dart',
        'lib/navigation/timeline_routes.dart',
        'lib/navigation/quick_actions_config.dart',
    ]

    fixed = 0
    for rel in problem_files:
        filepath = os.path.join(ROOT, rel)
        if not os.path.exists(filepath):
            continue
        with open(filepath, encoding='utf-8') as f:
            content = f.read()

        # Find all l.keyName references and revert to German strings
        def replace_l_ref(match):
            key = match.group(1)
            if key in key_to_value:
                nonlocal fixed
                fixed += 1
                return f"'{key_to_value[key]}'"
            return match.group(0)

        content = re.sub(r'\bl\.([a-zA-Z][a-zA-Z0-9]*)', replace_l_ref, content)

        # Remove the added final l line if present
        lines = content.split('\n')
        lines = [l for l in lines if 'final l = AppLocalizations.of(context)!' not in l]

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))

    return fixed


def main():
    print("=== Phase 1: Fix multiline string breaks ===")
    ml_fixed = fix_multiline_string_breaks()
    print(f"Reverted {ml_fixed} broken multiline replacements")

    print("\n=== Phase 2: Revert l10n in non-widget files ===")
    nw_fixed = revert_l_in_nonwidget_files()
    print(f"Reverted {nw_fixed} references in non-widget files")

    print("\n=== Phase 3: Fix remaining const errors ===")
    c_fixed = fix_remaining_const()
    print(f"Fixed {c_fixed} const errors")

    print("\n=== Phase 4: Fix remaining undefined l ===")
    l_fixed = fix_l_in_non_build_methods()
    print(f"Fixed l in {l_fixed} files")

    print("\n=== Final analysis ===")
    result = subprocess.run(
        [FLUTTER, 'analyze', '--no-pub'],
        capture_output=True, text=True, cwd=ROOT
    )
    output = result.stdout + result.stderr
    error_count = output.count(' error • ')
    warning_count = output.count(' warning • ')
    print(f"Errors: {error_count}, Warnings: {warning_count}")

    # Show error breakdown
    by_code = {}
    for line in output.split('\n'):
        if ' error • ' not in line:
            continue
        parts = line.strip().split(' • ')
        if len(parts) >= 4:
            code = parts[3].strip()
            by_code[code] = by_code.get(code, 0) + 1
    for code, cnt in sorted(by_code.items(), key=lambda x: -x[1]):
        print(f"  {cnt:4d}  {code}")


if __name__ == '__main__':
    main()
