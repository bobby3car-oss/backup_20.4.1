#!/usr/bin/env python3
"""
Fix compilation errors introduced by batch l10n replacement.

Handles:
1. invalid_constant / const_initialized_with_non_constant_value: Remove 'const' from expressions using l.xxx
2. non_constant_list_element / non_constant_map_value / non_constant_record_field: Remove 'const' from collections
3. undefined_identifier for 'l': Add 'final l = AppLocalizations.of(context)!;' in the correct scope
4. expected_token / extra_positional_arguments: Revert broken replacements

Run: python3 tool/fix_batch_l10n_errors.py
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FLUTTER = '/Users/jan/development/flutter/bin/flutter'


def get_errors():
    """Run flutter analyze and parse errors."""
    result = subprocess.run(
        [FLUTTER, 'analyze', '--no-pub'],
        capture_output=True, text=True, cwd=ROOT
    )
    output = result.stdout + result.stderr
    errors = []
    for line in output.split('\n'):
        if ' error • ' not in line:
            continue
        # Parse: "  error • Message • file:line:col • code"
        parts = line.strip().split(' • ')
        if len(parts) < 4:
            continue
        msg = parts[1].strip()
        loc = parts[2].strip()
        code = parts[3].strip()
        # Parse location
        loc_parts = loc.rsplit(':', 2)
        if len(loc_parts) >= 3:
            filepath = loc_parts[0]
            try:
                line_no = int(loc_parts[1])
                col = int(loc_parts[2])
            except ValueError:
                continue
            errors.append({
                'msg': msg, 'file': filepath, 'line': line_no,
                'col': col, 'code': code
            })
    return errors


def read_file(filepath):
    full = os.path.join(ROOT, filepath)
    with open(full, encoding='utf-8') as f:
        return f.read().split('\n')


def write_file(filepath, lines):
    full = os.path.join(ROOT, filepath)
    with open(full, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))


def fix_const_errors(errors):
    """Remove 'const' from expressions that contain l.xxx references."""
    const_codes = {
        'invalid_constant', 'const_initialized_with_non_constant_value',
        'non_constant_list_element', 'non_constant_map_value',
        'non_constant_record_field', 'const_with_non_constant_argument',
        'const_eval_throws_exception',
    }
    const_errors = [e for e in errors if e['code'] in const_codes]
    if not const_errors:
        return 0

    # Group by file
    by_file = {}
    for e in const_errors:
        by_file.setdefault(e['file'], []).append(e)

    fixed = 0
    for filepath, file_errors in by_file.items():
        lines = read_file(filepath)
        changed = False

        for err in sorted(file_errors, key=lambda e: -e['line']):
            idx = err['line'] - 1
            if idx >= len(lines):
                continue
            line = lines[idx]
            col = err['col'] - 1

            # The error points to the non-const value (l.xxx)
            # We need to find the 'const' keyword that makes this invalid
            # Look backwards from the error position for 'const'

            # Strategy 1: Check if this line has 'const' before the error col
            before = line[:col]
            # Find last 'const' on this line before the error
            const_pos = before.rfind('const ')
            if const_pos >= 0:
                # Verify this const is the one causing the issue
                # Remove it (replace 'const ' with '')
                new_line = line[:const_pos] + line[const_pos + 6:]
                lines[idx] = new_line
                changed = True
                fixed += 1
                continue

            # Strategy 2: Check the previous line(s) for 'const'
            for back in range(1, 5):
                prev_idx = idx - back
                if prev_idx < 0:
                    break
                prev_line = lines[prev_idx]
                if 'const ' in prev_line:
                    # Find last const on that line
                    cp = prev_line.rfind('const ')
                    if cp >= 0:
                        lines[prev_idx] = prev_line[:cp] + prev_line[cp + 6:]
                        changed = True
                        fixed += 1
                        break

        if changed:
            write_file(filepath, lines)

    return fixed


def fix_undefined_l(errors):
    """Add 'final l = AppLocalizations.of(context)!;' where l is undefined."""
    undef_errors = [e for e in errors if e['code'] == 'undefined_identifier' and "Undefined name 'l'" in e['msg']]
    if not undef_errors:
        return 0

    by_file = {}
    for e in undef_errors:
        by_file.setdefault(e['file'], []).append(e['line'])

    fixed_files = 0
    for filepath, error_lines in by_file.items():
        lines = read_file(filepath)
        content = '\n'.join(lines)

        # Skip files without BuildContext access
        has_context = 'BuildContext' in content or 'context' in content

        if not has_context:
            # Revert l.xxx back to the German strings
            # This is a fallback - we'll handle these separately
            continue

        # Find all method bodies that contain l.xxx references on error lines
        # Strategy: for each error line, find the enclosing method/function
        # and add 'final l = AppLocalizations.of(context)!;' at its start

        # Find method starts (lines with { at end after function signature)
        method_starts = []  # (start_line_idx, indent)
        for i, line in enumerate(lines):
            stripped = line.strip()
            # Match various method patterns that have BuildContext
            if re.search(r'Widget\s+build\s*\(', stripped):
                method_starts.append(i)
            elif re.search(r'\)\s*\{', stripped) and 'context' in stripped.lower():
                method_starts.append(i)
            elif re.search(r'\)\s*(async\s*)?\{', stripped):
                method_starts.append(i)

        # For each error line, find the enclosing method and add l there
        methods_needing_l = set()
        for err_line in error_lines:
            err_idx = err_line - 1
            # Find the nearest method start before this error line
            best = -1
            for ms in method_starts:
                # Find the actual opening brace
                brace_line = ms
                for j in range(ms, min(ms + 3, len(lines))):
                    if '{' in lines[j]:
                        brace_line = j
                        break
                if brace_line < err_idx:
                    best = brace_line
            if best >= 0:
                methods_needing_l.add(best)

        if not methods_needing_l:
            # Try to add at the first build method
            for i, line in enumerate(lines):
                if re.search(r'Widget\s+build\s*\(', line.strip()):
                    for j in range(i, min(i + 3, len(lines))):
                        if '{' in lines[j]:
                            methods_needing_l.add(j)
                            break
                    break

        if not methods_needing_l:
            continue

        # Add final l after each method's opening brace, from bottom to top
        added = 0
        for brace_idx in sorted(methods_needing_l, reverse=True):
            # Check if there's already a 'final l = ' near this line
            already = False
            for j in range(brace_idx, min(brace_idx + 5, len(lines))):
                if 'final l = AppLocalizations.of(context)!' in lines[j]:
                    already = True
                    break
            if already:
                continue

            # Determine indent (2 more than the brace line)
            m = re.match(r'^(\s*)', lines[brace_idx])
            base_indent = m.group(1) if m else ''
            indent = base_indent + '  ' if '{' in lines[brace_idx].strip()[:5] else base_indent + '    '

            # For lines like "  Widget build(BuildContext context) {"
            # indent should be base_indent + 4 spaces
            if lines[brace_idx].strip().endswith('{'):
                m2 = re.match(r'^(\s*)', lines[brace_idx])
                indent = m2.group(1) + '    ' if m2 else '    '

            l_line = f"{indent}final l = AppLocalizations.of(context)!;"
            lines.insert(brace_idx + 1, l_line)
            added += 1

        if added > 0:
            # Ensure import exists
            if 'app_localizations.dart' not in '\n'.join(lines):
                # Calculate relative import
                file_dir = os.path.dirname(filepath)
                target = 'lib/l10n/app_localizations.dart'
                from_parts = file_dir.split('/')
                to_parts = target.split('/')
                common = 0
                for a, b in zip(from_parts, to_parts):
                    if a == b:
                        common += 1
                    else:
                        break
                ups = len(from_parts) - common
                remaining = '/'.join(to_parts[common:])
                import_path = f"'{'../' * ups}{remaining}'"
                import_line = f"import {import_path};"

                # Find last import
                last_import = -1
                for i, line in enumerate(lines):
                    if line.strip().startswith('import '):
                        last_import = i
                if last_import >= 0:
                    lines.insert(last_import + 1, import_line)

            write_file(filepath, lines)
            fixed_files += 1

    return fixed_files


def main():
    print("Fixing batch l10n errors...")
    print("Running flutter analyze...")
    errors = get_errors()
    print(f"Found {len(errors)} errors")

    # Fix const errors first (most mechanical)
    const_fixed = fix_const_errors(errors)
    print(f"Fixed {const_fixed} const-related errors")

    # Fix undefined l
    l_fixed = fix_undefined_l(errors)
    print(f"Fixed undefined 'l' in {l_fixed} files")

    # Re-run analyze to check remaining
    print("\nRe-running analyze...")
    errors2 = get_errors()
    print(f"Remaining errors: {len(errors2)}")

    # Categorize remaining
    by_code = {}
    for e in errors2:
        by_code.setdefault(e['code'], []).append(e)
    for code, errs in sorted(by_code.items(), key=lambda x: -len(x[1])):
        print(f"  {len(errs):4d}  {code}")


if __name__ == '__main__':
    main()
