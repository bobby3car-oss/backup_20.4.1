#!/usr/bin/env python3
"""
Simple script: add 'final l = AppLocalizations.of(context)!;'
to build methods that use l.xxx but lack the declaration.
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path('/Users/jan/projects/operationsbegleiter_v3')

L_DECL = 'final l = AppLocalizations.of(context)!;'
L_IMPORT = "import '../l10n/app_localizations.dart';"

def run_analyze():
    """Run flutter analyze and return lines."""
    res = subprocess.run(
        ['flutter', 'analyze', '--no-fatal-infos'],
        capture_output=True, text=True, cwd=str(ROOT)
    )
    return res.stdout.splitlines()

def get_undefined_l_errors(analyze_lines):
    """Extract file -> [line_numbers] for undefined 'l' errors."""
    errors = {}
    for line in analyze_lines:
        if 'undefined_identifier' not in line:
            continue
        if '/test/' in line:
            continue
        m = re.search(r'lib/(.+?):(\d+):\d+', line)
        if m:
            rel, lineno = m.group(1), int(m.group(2))
            errors.setdefault(rel, []).append(lineno)
    return errors

def find_method_open_brace(lines, error_idx):
    """
    Walk backwards from error_idx to find the opening brace
    of the innermost method/function that has a BuildContext parameter.
    Returns the line index of that '{' line, or -1 if not found.
    """
    # walk back counting braces
    depth = 0
    for i in range(error_idx, -1, -1):
        line = lines[i]
        # count braces right to left
        for ch in reversed(line):
            if ch == '}':
                depth += 1
            elif ch == '{':
                if depth == 0:
                    # Check if this is a method with BuildContext in its signature
                    # Look at lines from max(0,i-6) to i+1
                    sig = ''.join(lines[max(0, i-6):i+1])
                    if 'BuildContext' in sig or ('context' in sig and 'Widget' in sig):
                        return i
                    # If it's in a State class, context is accessible from that class
                    # Check if it's a method at all (has a return type or @override)
                    if re.search(r'@override\s*$', lines[max(0,i-2)].strip()) or \
                       re.search(r'@override\s*$', lines[max(0,i-1)].strip()):
                        # If inside a State class, context is accessible
                        return i
                    # Also check for => methods up above
                    # Skip non-method braces (class body, if/for/while)
                    # Just track depth and continue
                    depth -= 1
                else:
                    depth -= 1
    return -1

def already_has_l(lines, brace_idx):
    """Check if l is already declared within the next ~20 lines after brace_idx."""
    for i in range(brace_idx + 1, min(len(lines), brace_idx + 25)):
        if re.match(r'\s*final l\s*=\s*AppLocalizations', lines[i]):
            return True
        stripped = lines[i].strip()
        # stop at end of block
        if stripped.startswith('}') and not stripped.startswith('//'):
            break
    return False

def get_indent(lines, brace_idx):
    """Get indentation of the next statement after the opening brace."""
    for i in range(brace_idx + 1, min(len(lines), brace_idx + 10)):
        stripped = lines[i].strip()
        if stripped and not stripped.startswith('//'):
            return len(lines[i]) - len(lines[i].lstrip())
    # fallback: opening brace indent + 4
    bl = lines[brace_idx]
    return (len(bl) - len(bl.lstrip())) + 4

def fix_file(rel_path, error_lines):
    full_path = ROOT / 'lib' / rel_path
    if not full_path.exists():
        print(f'  SKIP (missing): {rel_path}')
        return False
    
    text = full_path.read_text()
    lines = text.splitlines(keepends=True)
    
    # Find all unique method braces to insert into
    braces_to_fix = set()
    for err_line in error_lines:
        idx = err_line - 1  # 0-indexed
        if idx >= len(lines):
            continue
        brace_idx = find_method_open_brace(lines, idx)
        if brace_idx == -1:
            print(f'  WARNING: could not find enclosing method for line {err_line}')
            continue
        if already_has_l(lines, brace_idx):
            continue
        braces_to_fix.add(brace_idx)
    
    if not braces_to_fix:
        print(f'  Already OK: {rel_path}')
        return False
    
    # Insert l declaration in each method, processing in reverse order
    for brace_idx in sorted(braces_to_fix, reverse=True):
        indent = get_indent(lines, brace_idx)
        decl = ' ' * indent + L_DECL + '\n'
        lines.insert(brace_idx + 1, decl)
    
    full_path.write_text(''.join(lines))
    print(f'  Fixed {len(braces_to_fix)} method(s): {rel_path}')
    return True

def main():
    print('Running flutter analyze...')
    analyze_lines = run_analyze()
    errors = get_undefined_l_errors(analyze_lines)
    print(f'Found undefined l in {len(errors)} files')
    
    fixed = 0
    for rel_path, error_lines in sorted(errors.items()):
        print(f'\n{rel_path} (error lines: {sorted(set(error_lines))[:8]}{"..." if len(error_lines)>8 else ""})')
        if fix_file(rel_path, error_lines):
            fixed += 1
    
    print(f'\nDone. Modified {fixed} files.')

if __name__ == '__main__':
    main()
