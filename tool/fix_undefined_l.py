#!/usr/bin/env python3
"""
Fix undefined 'l' errors by adding l10n variable declarations in methods of
State/Widget classes, and reverting l10n calls in contexts without BuildContext.
"""
import json
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
ARB_FILE = os.path.join(LIB, 'l10n', 'app_de.arb')

def load_arb_reverse_map():
    """Load DE ARB file and create key -> German string map."""
    with open(ARB_FILE) as f:
        arb = json.load(f)
    return {k: v for k, v in arb.items() if not k.startswith('@') and not k.startswith('@@')}

def parse_errors(filepath):
    """Parse analyze output for undefined_identifier errors."""
    errors = defaultdict(list)
    with open(filepath) as f:
        for line in f:
            m = re.search(r"Undefined name 'l' • (lib/[^:]+):(\d+):\d+ • undefined_identifier", line)
            if m:
                fpath, lineno = m.group(1), int(m.group(2))
                errors[fpath].append(lineno)
    return errors


def find_enclosing_block_start(lines, error_idx):
    """
    Find the opening brace of the method/function containing error_idx.
    Returns (brace_line_idx, indent_level) or (None, None).
    """
    brace_depth = 0
    for i in range(error_idx, -1, -1):
        line = lines[i]
        # Count braces right to left on this line
        for ch in reversed(line):
            if ch == '}':
                brace_depth += 1
            elif ch == '{':
                if brace_depth == 0:
                    # This is the opening brace of the enclosing block
                    return i, len(line) - len(line.lstrip())
                brace_depth -= 1
    return None, None


def is_method_or_function_line(lines, brace_idx):
    """Check if the brace at brace_idx is a method/function opening brace."""
    # Look at this line and a few lines before for method signature patterns
    for offset in range(0, min(5, brace_idx + 1)):
        check_idx = brace_idx - offset
        line = lines[check_idx].strip()
        # Method patterns
        if re.search(r'(Widget|void|Future|String|int|double|bool|List|Map|Set|dynamic|var|Object|Color|IconData|TextStyle)\s', line):
            return True
        if re.search(r'@override', line):
            return True
        if re.search(r'\w+\s*\([^)]*\)\s*(async\s*)?\{?\s*$', line):
            return True
        if line.startswith('build(') or 'Widget build(' in line:
            return True
    return False


def has_context_access(lines, brace_idx):
    """Check if the method at brace_idx has access to BuildContext."""
    # Check method signature for BuildContext parameter
    sig = ''
    for offset in range(0, min(8, brace_idx + 1)):
        sig = lines[brace_idx - offset] + sig
    
    if 'BuildContext' in sig or 'context' in sig:
        return True
    return False


def is_in_state_class(lines, brace_idx):
    """Check if brace_idx is inside a State<> or ConsumerState<> class."""
    # Find the class declaration by searching backward
    brace_depth = 0
    for i in range(brace_idx, -1, -1):
        line = lines[i]
        for ch in reversed(line):
            if ch == '}':
                brace_depth += 1
            elif ch == '{':
                brace_depth -= 1
        
        if 'extends State<' in line or 'extends ConsumerState<' in line:
            return True
        if 'class ' in line and 'extends' in line:
            # Some other class
            if brace_depth < 0:
                # We've exited the class scope
                return False
    return False


def already_has_l_decl(lines, brace_idx):
    """Check if there's already an l declaration after this brace."""
    for i in range(brace_idx + 1, min(len(lines), brace_idx + 15)):
        line = lines[i].strip()
        if re.match(r'final\s+l\s*=\s*AppLocalizations', line):
            return True
        # Stop if we hit another method or return
        if line.startswith('return ') or line.startswith('if ') or line.startswith('for '):
            break
    return False


def fix_file(filepath, error_lines, arb_map):
    """Fix all undefined 'l' errors in a file."""
    full_path = os.path.join(ROOT, filepath)
    with open(full_path) as f:
        lines = f.readlines()
    
    original = list(lines)
    
    # Group error lines by their enclosing method
    # For each enclosing method, decide: add l decl, or revert
    methods_to_fix = {}  # brace_idx -> list of error line indices
    lines_to_revert = []  # error line indices without context
    
    for lineno in error_lines:
        idx = lineno - 1
        if idx < 0 or idx >= len(lines):
            continue
        
        brace_idx, indent = find_enclosing_block_start(lines, idx)
        if brace_idx is None:
            lines_to_revert.append(idx)
            continue
        
        # Check if this is a real method/function with context access
        in_state = is_in_state_class(lines, brace_idx)
        has_ctx = has_context_access(lines, brace_idx)
        
        if in_state or has_ctx:
            if brace_idx not in methods_to_fix:
                methods_to_fix[brace_idx] = []
            methods_to_fix[brace_idx].append(idx)
        else:
            lines_to_revert.append(idx)
    
    changes = 0
    
    # 1. Add l declaration in methods with context
    # Sort by brace_idx descending so insertions don't shift subsequent indices
    for brace_idx in sorted(methods_to_fix.keys(), reverse=True):
        if already_has_l_decl(lines, brace_idx):
            continue
        
        # Determine indentation (brace indent + 2 or 4 spaces)
        brace_line = lines[brace_idx]
        base_indent = len(brace_line) - len(brace_line.lstrip())
        # Look at the next non-empty line for actual body indentation
        body_indent = '    '
        for i in range(brace_idx + 1, min(len(lines), brace_idx + 5)):
            stripped = lines[i].strip()
            if stripped and not stripped.startswith('//'):
                body_indent = re.match(r'^(\s*)', lines[i]).group(1)
                break
        
        decl_line = f'{body_indent}final l = AppLocalizations.of(context)!;\n'
        lines.insert(brace_idx + 1, decl_line)
        changes += 1
        
        # Adjust revert indices
        lines_to_revert = [idx + 1 if idx > brace_idx else idx for idx in lines_to_revert]
    
    # 2. Revert l10n calls in lines without context
    for idx in sorted(set(lines_to_revert), reverse=True):
        if idx >= len(lines):
            continue
        line = lines[idx]
        new_line = revert_l10n_calls(line, arb_map)
        if new_line != line:
            lines[idx] = new_line
            changes += 1
    
    if lines != original:
        with open(full_path, 'w') as f:
            f.writelines(lines)
    
    return changes


def revert_l10n_calls(line, arb_map):
    """Replace l.someKey or l?.someKey with the German string from ARB."""
    def replace_match(m):
        key = m.group(1)
        if key in arb_map:
            value = arb_map[key]
            # Escape single quotes in the value
            value = value.replace("'", "\\'")
            return f"'{value}'"
        return m.group(0)
    
    # Replace l.key and l?.key patterns
    line = re.sub(r'\bl\.(\w+)', replace_match, line)
    line = re.sub(r'\bl\?\.(\w+)', replace_match, line)
    return line


def main():
    arb_map = load_arb_reverse_map()
    print(f"Loaded {len(arb_map)} ARB keys")
    
    errors = parse_errors('/tmp/analyze_output2.txt')
    print(f"Found {sum(len(v) for v in errors.values())} errors in {len(errors)} files")
    
    total_changes = 0
    total_files = 0
    
    for filepath, error_lines in sorted(errors.items()):
        try:
            c = fix_file(filepath, error_lines, arb_map)
            if c > 0:
                total_files += 1
                total_changes += c
                print(f"Fixed {c} issues in {filepath}")
        except Exception as e:
            print(f"ERROR in {filepath}: {e}")
    
    print(f"\nTotal: {total_changes} fixes in {total_files} files")


if __name__ == '__main__':
    main()
