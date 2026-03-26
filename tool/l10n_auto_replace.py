#!/usr/bin/env python3
"""
Automated l10n replacer: replaces hardcoded German strings in Dart files
with l10n calls (l.keyName) for strings that already exist in the ARB files.
Also adds the necessary import and variable declaration.
"""
import os
import re
import json
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N_DIR = os.path.join(ROOT, 'lib', 'l10n')
DRY_RUN = '--dry-run' in sys.argv

# Load ARB data
with open(os.path.join(L10N_DIR, 'app_de.arb')) as f:
    arb = json.load(f)

# Build value -> key mapping (prefer shorter keys for common words)
value_to_key = {}
for k, v in arb.items():
    if k.startswith('@') or not isinstance(v, str):
        continue
    if v not in value_to_key or len(k) < len(value_to_key[v]):
        value_to_key[v] = k

IMPORT_LINE = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';"
ALT_IMPORT = "import '../../../l10n/app_localizations.dart';"
ALT_IMPORT2 = "import '../../l10n/app_localizations.dart';"
ALT_IMPORT3 = "import '../l10n/app_localizations.dart';"

L_VAR_PATTERN = re.compile(r'final l = AppLocalizations\.of\(context\)')

skip_dirs = {'l10n', 'generated', '.dart_tool'}
skip_files = {'app_localizations', 'firebase_options'}

# Files where context isn't available (domain/data layers)
non_widget_dirs = {'domain', 'data'}

stats = {'files_modified': 0, 'replacements': 0, 'imports_added': 0, 'l_vars_added': 0}

def find_build_method_line(lines):
    """Find the first line inside build() or a StatelessWidget/State build method."""
    for i, line in enumerate(lines):
        stripped = line.strip()
        if re.match(r'Widget build\(BuildContext context', stripped):
            # Find the opening brace
            for j in range(i, min(i + 5, len(lines))):
                if '{' in lines[j]:
                    return j + 1
    return None

def get_indent(line):
    """Get the indentation of a line."""
    return len(line) - len(line.lstrip())

def has_any_import(content):
    """Check if file already has AppLocalizations import."""
    return ('app_localizations.dart' in content or 
            'AppLocalizations' in content)

def has_l_var(content):
    """Check if file already has the l variable."""
    return bool(L_VAR_PATTERN.search(content))

def process_file(filepath):
    """Process a single Dart file."""
    with open(filepath) as f:
        content = f.read()
    
    original = content
    lines = content.split('\n')
    
    # Find all hardcoded strings that match ARB values
    replacements = []
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('//') or stripped.startswith('import '):
            continue
        
        # Find quoted strings
        for match in re.finditer(r"'([^'\\]{2,})'|\"([^\"\\]{2,})\"", line):
            s = match.group(1) or match.group(2)
            if s in value_to_key:
                key = value_to_key[s]
                # Don't replace if it's already an l10n call
                before = line[:match.start()].rstrip()
                if before.endswith('l.') or before.endswith('l10n.'):
                    continue
                replacements.append((i, match.start(), match.end(), s, key))
    
    if not replacements:
        return False
    
    # Check if this is a widget file (has BuildContext)
    has_context = 'BuildContext' in content or 'State<' in content or 'StatelessWidget' in content
    if not has_context:
        # For non-widget files, we can't easily add l10n
        # Print warning but skip
        rel = os.path.relpath(filepath, ROOT)
        print(f"  SKIP (no context): {rel} ({len(replacements)} matches)")
        return False
    
    rel = os.path.relpath(filepath, ROOT)
    print(f"  Processing: {rel} ({len(replacements)} replacements)")
    
    # Perform replacements (reverse order to maintain positions)
    new_lines = list(lines)
    for i, start, end, old_str, key in reversed(replacements):
        line = new_lines[i]
        # Determine quote char used
        quote = line[start] if start < len(line) else "'"
        new_lines[i] = line[:start] + f'l.{key}' + line[end:]
        stats['replacements'] += 1
    
    new_content = '\n'.join(new_lines)
    
    # Add import if needed
    if not has_any_import(new_content):
        # Find the last import line
        import_insert = 0
        for i, line in enumerate(new_lines):
            if line.strip().startswith('import '):
                import_insert = i + 1
        
        # Calculate relative import path
        rel_path = os.path.relpath(filepath, os.path.join(ROOT, 'lib'))
        depth = len(rel_path.split(os.sep)) - 1
        if depth == 1:
            import_stmt = "import 'l10n/app_localizations.dart';"
        elif depth == 2:
            import_stmt = "import '../l10n/app_localizations.dart';"
        elif depth == 3:
            import_stmt = "import '../../l10n/app_localizations.dart';"
        elif depth == 4:
            import_stmt = "import '../../../l10n/app_localizations.dart';"
        else:
            import_stmt = "import '../../../../l10n/app_localizations.dart';"
        
        new_lines.insert(import_insert, import_stmt)
        stats['imports_added'] += 1
        new_content = '\n'.join(new_lines)
    
    # Add l variable if needed
    if not has_l_var(new_content):
        build_line = find_build_method_line(new_lines)
        if build_line is not None:
            indent = '    '  # Standard Flutter indent
            # Check what indent the next line uses
            if build_line < len(new_lines):
                next_line = new_lines[build_line]
                if next_line.strip():
                    indent = ' ' * get_indent(next_line)
            
            l_decl = f'{indent}final l = AppLocalizations.of(context)!;'
            new_lines.insert(build_line, l_decl)
            stats['l_vars_added'] += 1
            new_content = '\n'.join(new_lines)
    
    if new_content != original:
        if not DRY_RUN:
            with open(filepath, 'w') as f:
                f.write(new_content)
        stats['files_modified'] += 1
        return True
    
    return False

# Process all Dart files
lib_dir = os.path.join(ROOT, 'lib')
print(f"{'DRY RUN - ' if DRY_RUN else ''}Processing Dart files...\n")

for dirpath, dirnames, filenames in os.walk(lib_dir):
    dirnames[:] = [d for d in dirnames if d not in skip_dirs]
    for fn in filenames:
        if not fn.endswith('.dart'):
            continue
        if any(s in fn for s in skip_files):
            continue
        filepath = os.path.join(dirpath, fn)
        process_file(filepath)

print(f"\n=== RESULTS {'(DRY RUN)' if DRY_RUN else ''} ===")
print(f"Files modified: {stats['files_modified']}")
print(f"String replacements: {stats['replacements']}")
print(f"Imports added: {stats['imports_added']}")
print(f"l variables added: {stats['l_vars_added']}")
