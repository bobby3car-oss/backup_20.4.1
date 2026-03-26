#!/usr/bin/env python3
"""
Comprehensive fix for l10n errors in Dart files.

Strategy:
1. Parse flutter analyze output for ALL l10n-related errors
2. For each file, use proper brace-depth tracking to find method scopes
3. Add l10n variable declarations where context is available
4. Revert l10n calls where context is NOT available
5. Remove unused l declarations
6. Fix const issues

This version uses a proper tokenizer approach instead of regex.
"""

import json
import os
import re
import subprocess
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
ARB_FILE = os.path.join(LIB, 'l10n', 'app_de.arb')


def load_arb():
    """Load DE ARB file."""
    with open(ARB_FILE) as f:
        arb = json.load(f)
    return {k: v for k, v in arb.items() if not k.startswith('@') and not k.startswith('@@')}


def run_analyze():
    """Run flutter analyze and return output."""
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True, text=True, cwd=ROOT
    )
    return result.stdout + result.stderr


def parse_all_errors(output):
    """Parse ALL errors from flutter analyze."""
    errors = defaultdict(lambda: defaultdict(list))
    # Match both error and warning/info lines
    pattern = re.compile(
        r'(?:error|warning|info) • (.+?) • (.+?):(\d+):(\d+) • (\w+)'
    )
    for line in output.splitlines():
        m = pattern.search(line)
        if m:
            msg, filepath, lineno, col, etype = m.group(1), m.group(2), int(m.group(3)), int(m.group(4)), m.group(5)
            errors[filepath][etype].append((lineno, col, msg))
    return errors


def find_scopes(lines):
    """
    Build a scope tree using brace counting.
    Returns a list of (start_line, end_line, indent, type) for each scope.
    type is 'class', 'method', 'closure', or 'block'.
    """
    scopes = []
    brace_stack = []  # stack of (line_idx, type)
    
    in_string = False
    string_char = None
    in_comment_block = False
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        # Skip block comments
        if in_comment_block:
            if '*/' in stripped:
                in_comment_block = False
            continue
        if '/*' in stripped:
            if '*/' not in stripped:
                in_comment_block = True
            continue
        
        # Skip line comments
        code = stripped
        if '//' in code:
            # Simple comment removal (not inside strings)
            code_parts = []
            in_str = False
            str_ch = None
            for j, ch in enumerate(code):
                if in_str:
                    if ch == str_ch and (j == 0 or code[j-1] != '\\'):
                        in_str = False
                elif ch in ('"', "'"):
                    in_str = True
                    str_ch = ch
                elif ch == '/' and j + 1 < len(code) and code[j+1] == '/':
                    break
                code_parts.append(ch)
            code = ''.join(code_parts)
        
        for ch in code:
            if ch == '{':
                # Determine scope type
                scope_type = 'block'
                full_line = line.strip()
                # Check lines above for class/method
                ctx = ''
                for back in range(max(0, i - 5), i + 1):
                    ctx += lines[back]
                
                if re.search(r'class\s+\w+', ctx) and not any(s[2] == 'class' for s in brace_stack):
                    scope_type = 'class'
                elif re.search(r'(Widget|void|Future|String|int|double|bool|List|Map|Set|dynamic|var|Object|Color|TextStyle|Size|Offset|Rect|EdgeInsets|Duration|DateTime|IconData)\s+\w+\s*[\(<]', ctx):
                    scope_type = 'method'
                elif re.search(r'@override', ctx):
                    scope_type = 'method'
                elif re.search(r'\)\s*(async\s*)?\{', code):
                    scope_type = 'method'
                
                brace_stack.append((i, scope_type))
            
            elif ch == '}':
                if brace_stack:
                    start_line, scope_type = brace_stack.pop()
                    indent = len(lines[start_line]) - len(lines[start_line].lstrip())
                    scopes.append((start_line, i, indent, scope_type))
    
    return scopes


def has_l_declaration(lines, start, end):
    """Check if there's a final l = AppLocalizations... declaration in this scope."""
    for i in range(start, min(end + 1, len(lines))):
        if re.search(r'final\s+l\s*=\s*AppLocalizations\.of\(context\)', lines[i]):
            return True
    return False


def has_context_param(lines, method_start):
    """Check if the method starting around method_start has a BuildContext parameter."""
    # Gather the signature by looking at lines around the {
    sig = ''
    for i in range(max(0, method_start - 8), method_start + 1):
        sig += lines[i]
    return 'BuildContext' in sig or 'context' in sig


def is_state_class_scope(lines, class_start):
    """Check if the class scope is a State<> class."""
    # Look at the class declaration line
    for i in range(class_start, min(len(lines), class_start + 3)):
        if 'extends State<' in lines[i] or 'extends ConsumerState<' in lines[i]:
            return True
    return False


def fix_file(filepath, file_errors, arb_map):
    """Fix all l10n-related errors in a file."""
    full_path = os.path.join(ROOT, filepath)
    if not os.path.exists(full_path):
        return 0
    
    with open(full_path) as f:
        content = f.read()
    original = content
    lines = content.split('\n')
    
    changes = 0
    
    # Get error lines by type
    undef_lines = set()
    invalid_const_lines = set()
    unused_l_lines = set()
    
    for etype, errs in file_errors.items():
        for lineno, col, msg in errs:
            if etype == 'undefined_identifier' and "'l'" in msg:
                undef_lines.add(lineno)
            elif etype in ('invalid_constant', 'non_constant_list_element',
                          'non_constant_map_value', 'non_constant_map_key',
                          'non_constant_record_field',
                          'const_initialized_with_non_constant_value',
                          'const_constructor_with_field_initialized_by_non_const'):
                invalid_const_lines.add(lineno)
            elif etype == 'unused_local_variable' and "'l'" in msg:
                unused_l_lines.add(lineno)
            elif etype == 'instance_member_access_from_static' and "l" in msg:
                undef_lines.add(lineno)  # Treat as if l is undefined in static
            elif etype == 'implicit_this_reference_in_initializer':
                undef_lines.add(lineno)
    
    if not undef_lines and not invalid_const_lines and not unused_l_lines:
        return 0
    
    # Fix 1: Handle const issues - remove const from lines containing l10n calls
    for lineno in sorted(invalid_const_lines):
        idx = lineno - 1
        if idx < 0 or idx >= len(lines):
            continue
        line = lines[idx]
        
        if 'l.' in line or 'l?.' in line:
            # Remove const from this line
            new_line = re.sub(r'\bconst\b\s*', '', line, count=1)
            if new_line != line:
                lines[idx] = new_line
                changes += 1
                continue
        
        # Search upward for the const that governs this expression
        for back in range(1, min(20, idx + 1)):
            check_idx = idx - back
            check_line = lines[check_idx]
            if re.search(r'\bconst\b', check_line):
                new_line = re.sub(r'\bconst\b\s*', '', check_line, count=1)
                if new_line != check_line:
                    lines[check_idx] = new_line
                    changes += 1
                    break
    
    # Fix 2: Remove unused l declarations
    indices_to_remove = set()
    for lineno in sorted(unused_l_lines):
        idx = lineno - 1
        if idx < 0 or idx >= len(lines):
            continue
        if re.search(r'final\s+l\s*=\s*AppLocalizations', lines[idx]):
            indices_to_remove.add(idx)
            changes += 1
    
    if indices_to_remove:
        lines = [line for i, line in enumerate(lines) if i not in indices_to_remove]
        # Recalculate line numbers for undef_lines
        # Build offset map
        offset = 0
        new_undef = set()
        for lineno in sorted(undef_lines):
            idx = lineno - 1
            removed_before = sum(1 for r in indices_to_remove if r < idx)
            new_undef.add(lineno - removed_before)
        undef_lines = new_undef
    
    # Fix 3: For undefined l - find enclosing scope and either add l or revert
    if undef_lines:
        # Find all method/class scopes
        # Simple approach: for each undefined l line, walk backward to find
        # the enclosing method's opening brace
        
        methods_need_l = set()  # Set of line indices where { starts a method
        lines_to_revert = set()  # Lines where l10n should be reverted
        
        for lineno in sorted(undef_lines):
            idx = lineno - 1
            if idx < 0 or idx >= len(lines):
                continue
            
            # Verify line uses l. or l?.
            if not re.search(r'\bl\.\w+', lines[idx]) and not re.search(r'\bl\?\.\w+', lines[idx]):
                continue
            
            # Find enclosing function/method by walking backward
            brace_depth = 0
            found_method = False
            
            for i in range(idx, max(-1, idx - 500), -1):
                line = lines[i]
                # Count braces (simplified - doesn't handle strings/comments)
                for ch in reversed(line):
                    if ch == '}':
                        brace_depth += 1
                    elif ch == '{':
                        if brace_depth == 0:
                            # Found enclosing opening brace
                            # Check if this is a method with context
                            sig_lines = '\n'.join(lines[max(0, i-5):i+1])
                            
                            # Check for State class
                            is_in_state = False
                            for j in range(max(0, i - 200), i):
                                if 'extends State<' in lines[j] or 'extends ConsumerState<' in lines[j]:
                                    is_in_state = True
                                    break
                            
                            has_ctx = 'BuildContext' in sig_lines or 'context' in sig_lines
                            
                            if is_in_state or has_ctx:
                                # Check if l already declared
                                already = False
                                for k in range(i + 1, min(len(lines), i + 15)):
                                    if re.search(r'final\s+l\s*=\s*AppLocalizations', lines[k]):
                                        already = True
                                        break
                                    if lines[k].strip() and not lines[k].strip().startswith('//'):
                                        # First non-comment line - stop checking
                                        break
                                
                                if not already:
                                    methods_need_l.add(i)
                                found_method = True
                            else:
                                lines_to_revert.add(idx)
                                found_method = True
                            break
                        brace_depth -= 1
                
                if found_method:
                    break
            
            if not found_method:
                lines_to_revert.add(idx)
        
        # Add l declarations (insert from bottom to top to preserve line numbers)
        for brace_idx in sorted(methods_need_l, reverse=True):
            # Get body indentation
            body_indent = '    '
            for i in range(brace_idx + 1, min(len(lines), brace_idx + 5)):
                stripped = lines[i].strip()
                if stripped and not stripped.startswith('//'):
                    m = re.match(r'^(\s*)', lines[i])
                    if m:
                        body_indent = m.group(1)
                    break
            
            decl = f'{body_indent}final l = AppLocalizations.of(context)!;'
            lines.insert(brace_idx + 1, decl)
            changes += 1
            
            # Adjust revert lines
            lines_to_revert = {(idx + 1 if idx > brace_idx else idx) for idx in lines_to_revert}
        
        # Revert l10n calls on lines without context
        for idx in sorted(lines_to_revert, reverse=True):
            if idx >= len(lines):
                continue
            line = lines[idx]
            new_line = revert_l10n_in_line(line, arb_map)
            if new_line != line:
                lines[idx] = new_line
                changes += 1
    
    new_content = '\n'.join(lines)
    if new_content != original:
        with open(full_path, 'w') as f:
            f.write(new_content)
    
    return changes


def revert_l10n_in_line(line, arb_map):
    """Replace l.someKey or l?.someKey with the original German string."""
    def replace_match(m):
        prefix = m.group(1)  # 'l.' or 'l?.'
        key = m.group(2)
        if key in arb_map:
            value = arb_map[key]
            # Escape single quotes
            value = value.replace("'", "\\'")
            return f"'{value}'"
        return m.group(0)
    
    result = re.sub(r'\b(l\??\.)([\w]+)', replace_match, line)
    return result


def main():
    arb_map = load_arb()
    print(f"Loaded {len(arb_map)} ARB keys")
    
    print("Running flutter analyze...")
    output = run_analyze()
    
    errors = parse_all_errors(output)
    
    # Only process files with l10n-related errors
    l10n_error_types = {
        'undefined_identifier', 'invalid_constant', 'unused_local_variable',
        'non_constant_list_element', 'non_constant_map_value', 'non_constant_map_key',
        'non_constant_record_field', 'const_initialized_with_non_constant_value',
        'const_constructor_with_field_initialized_by_non_const',
        'instance_member_access_from_static', 'implicit_this_reference_in_initializer',
    }
    
    total_changes = 0
    total_files = 0
    
    for filepath in sorted(errors.keys()):
        if not filepath.startswith('lib/'):
            continue
        
        file_errors = errors[filepath]
        # Filter to only l10n-related errors
        relevant = {}
        for etype, errs in file_errors.items():
            if etype in l10n_error_types:
                relevant[etype] = errs
        
        if not relevant:
            continue
        
        try:
            c = fix_file(filepath, relevant, arb_map)
            if c > 0:
                total_files += 1
                total_changes += c
                print(f"  Fixed {c} issues in {filepath}")
        except Exception as e:
            print(f"  ERROR in {filepath}: {e}")
            import traceback
            traceback.print_exc()
    
    print(f"\nTotal: {total_changes} fixes in {total_files} files")


if __name__ == '__main__':
    main()
