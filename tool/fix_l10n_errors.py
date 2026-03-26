#!/usr/bin/env python3
"""
Fix l10n-related analysis errors introduced by the auto-replace script.

Handles:
1. invalid_constant: Remove 'const' where l10n calls exist
2. undefined_identifier 'l': Add l variable in methods with context, or revert
3. unused_local_variable 'l': Remove unused l declarations
4. non_constant_list_element, non_constant_map_key/value, etc.
"""

import os
import re
import subprocess
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def parse_errors(analyze_output):
    """Parse flutter analyze output into structured errors."""
    errors = defaultdict(list)
    pattern = re.compile(
        r'error • .+? • (.+?):(\d+):\d+ • (\w+)'
    )
    warning_pattern = re.compile(
        r'warning • .+? • (.+?):(\d+):\d+ • (\w+)'
    )
    info_pattern = re.compile(
        r'info • .+? • (.+?):(\d+):\d+ • (\w+)'
    )
    for line in analyze_output.splitlines():
        for pat in [pattern, warning_pattern, info_pattern]:
            m = pat.search(line)
            if m:
                filepath, line_no, error_type = m.group(1), int(m.group(2)), m.group(3)
                errors[filepath].append((line_no, error_type))
                break
    return errors


def fix_const_issues(filepath, lines, error_lines_by_type):
    """Remove 'const' from lines/expressions containing l. calls."""
    const_lines = set()
    for ln, etype in error_lines_by_type:
        if etype in ('invalid_constant', 'non_constant_list_element',
                     'non_constant_map_value', 'non_constant_map_key',
                     'non_constant_record_field',
                     'const_initialized_with_non_constant_value'):
            const_lines.add(ln)
    
    if not const_lines:
        return lines, 0
    
    changes = 0
    new_lines = list(lines)
    
    for ln in sorted(const_lines):
        idx = ln - 1
        if idx < 0 or idx >= len(new_lines):
            continue
        line = new_lines[idx]
        
        # Try to remove const on this line
        if 'const ' in line and ('l.' in line or 'l?' in line):
            # Remove the first 'const ' on this line
            new_line = line.replace('const ', '', 1)
            if new_line != line:
                new_lines[idx] = new_line
                changes += 1
                continue
        
        # If const is not on the same line as l., look upward for enclosing const
        # e.g.: const Text(l.someKey) — const is on a previous line or same line
        # Search upward for 'const' that governs this expression
        for back in range(0, min(15, idx + 1)):
            check_idx = idx - back
            check_line = new_lines[check_idx]
            if 'const ' in check_line:
                # Check if this is a const constructor or const declaration
                new_line = check_line.replace('const ', '', 1)
                if new_line != check_line:
                    new_lines[check_idx] = new_line
                    changes += 1
                    break
    
    return new_lines, changes


def fix_undefined_l(filepath, lines, error_lines_by_type):
    """Add 'final l = AppLocalizations.of(context)!;' where l is undefined."""
    undef_lines = set()
    for ln, etype in error_lines_by_type:
        if etype == 'undefined_identifier':
            undef_lines.add(ln)
    
    if not undef_lines:
        return lines, 0
    
    # Find all methods/functions that contain undefined 'l' references
    # and check if they have 'context' available
    changes = 0
    new_lines = list(lines)
    l_decl = '    final l = AppLocalizations.of(context)!;\n'
    
    # Find methods that need l variable
    # Strategy: for each undefined l line, find the enclosing method/function
    # and add l declaration at its start
    
    methods_fixed = set()  # Track which method start lines already got l added
    
    for ln in sorted(undef_lines):
        idx = ln - 1
        if idx < 0 or idx >= len(new_lines):
            continue
        
        # Verify the line actually uses 'l.' or 'l?.'
        line = new_lines[idx]
        if not re.search(r'\bl\.', line) and not re.search(r'\bl\?\.', line):
            continue
        
        # Search backward for the enclosing method/function opening brace
        method_start = find_method_start(new_lines, idx)
        if method_start is None:
            continue
        
        if method_start in methods_fixed:
            continue
        
        # Check if context is available in method signature or as class member
        method_sig = new_lines[method_start]
        # Look a few lines around for the full signature
        sig_text = ''
        for i in range(max(0, method_start - 3), min(len(new_lines), method_start + 3)):
            sig_text += new_lines[i]
        
        has_context = 'context' in sig_text or 'BuildContext' in sig_text
        
        # In State classes, context is always available
        # Check if we're in a State class by looking for 'extends State' before this method
        if not has_context:
            for i in range(max(0, method_start - 100), method_start):
                if 'extends State<' in new_lines[i] or 'extends ConsumerState<' in new_lines[i]:
                    has_context = True
                    break
        
        if has_context:
            # Find the opening brace of this method
            brace_line = find_opening_brace(new_lines, method_start)
            if brace_line is not None and brace_line not in methods_fixed:
                # Check if l is already declared in this scope
                already_has_l = False
                for i in range(brace_line + 1, min(len(new_lines), brace_line + 10)):
                    if re.search(r'final\s+l\s*=\s*AppLocalizations', new_lines[i]):
                        already_has_l = True
                        break
                
                if not already_has_l:
                    # Determine indentation
                    indent = get_indent(new_lines, brace_line + 1)
                    decl = f'{indent}final l = AppLocalizations.of(context)!;\n'
                    new_lines.insert(brace_line + 1, decl)
                    methods_fixed.add(brace_line)
                    changes += 1
                    # Adjust all subsequent line numbers
                    undef_lines = {x + 1 if x > brace_line + 1 else x for x in undef_lines}
    
    return new_lines, changes


def find_method_start(lines, from_idx):
    """Find the start line of the method containing from_idx."""
    brace_count = 0
    # Walk backward from from_idx to find the method start
    for i in range(from_idx, max(-1, from_idx - 500), -1):
        line = lines[i]
        brace_count += line.count('}') - line.count('{')
        
        # When we find a line that looks like a method declaration
        if brace_count <= 0:
            stripped = line.strip()
            # Method/function patterns
            if (re.match(r'(Widget|void|Future|String|int|double|bool|List|Map|Set|dynamic|var|final|static|@override)', stripped)
                or re.match(r'\w+\s+\w+\s*\(', stripped)
                or re.match(r'\w+\s*\(', stripped)
                or stripped.startswith('build(')
                or 'Widget build(' in stripped):
                return i
    return None


def find_opening_brace(lines, method_start):
    """Find the opening brace of a method starting at method_start."""
    for i in range(method_start, min(len(lines), method_start + 10)):
        if '{' in lines[i]:
            return i
    return None


def get_indent(lines, line_idx):
    """Get the indentation of a nearby line."""
    if line_idx < len(lines):
        line = lines[line_idx]
        match = re.match(r'^(\s+)', line)
        if match:
            return match.group(1)
    return '    '


def fix_unused_l(filepath, lines, error_lines_by_type):
    """Remove unused l variable declarations."""
    unused_lines = set()
    for ln, etype in error_lines_by_type:
        if etype == 'unused_local_variable':
            unused_lines.add(ln)
    
    if not unused_lines:
        return lines, 0
    
    changes = 0
    indices_to_remove = []
    
    for ln in sorted(unused_lines):
        idx = ln - 1
        if idx < 0 or idx >= len(lines):
            continue
        line = lines[idx]
        if re.search(r'final\s+l\s*=\s*AppLocalizations', line):
            indices_to_remove.append(idx)
            changes += 1
    
    # Remove lines in reverse order to keep indices valid
    new_lines = list(lines)
    for idx in sorted(indices_to_remove, reverse=True):
        del new_lines[idx]
    
    return new_lines, changes


def main():
    # Run flutter analyze and capture output
    print("Running flutter analyze...")
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True, text=True,
        cwd=ROOT
    )
    output = result.stdout + result.stderr
    
    errors = parse_errors(output)
    
    total_files = 0
    total_changes = 0
    
    for filepath, file_errors in sorted(errors.items()):
        full_path = os.path.join(ROOT, filepath)
        if not os.path.exists(full_path):
            continue
        
        with open(full_path) as f:
            lines = f.readlines()
        
        original_lines = list(lines)
        file_changes = 0
        
        # 1. Fix const issues
        lines, c = fix_const_issues(filepath, lines, file_errors)
        file_changes += c
        
        # 2. Fix unused l (do before undefined to avoid double-work)
        lines, c = fix_unused_l(filepath, lines, file_errors)
        file_changes += c
        
        # 3. Fix undefined l variable  
        lines, c = fix_undefined_l(filepath, lines, file_errors)
        file_changes += c
        
        if file_changes > 0:
            with open(full_path, 'w') as f:
                f.writelines(lines)
            total_files += 1
            total_changes += file_changes
            print(f"Fixed {file_changes} issues in {filepath}")
    
    print(f"\nTotal: {total_changes} fixes in {total_files} files")


if __name__ == '__main__':
    main()
