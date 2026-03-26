#!/usr/bin/env python3
"""Replace hardcoded German strings in Dart files with l10n key references."""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ARB_PATH = os.path.join(ROOT, 'lib', 'l10n', 'app_de.arb')
LIB_DIR = os.path.join(ROOT, 'lib')

# Files/directories to skip
SKIP_DIRS = {'l10n', 'generated'}
SKIP_FILES = {'firebase_options.dart'}

def load_arb():
    with open(ARB_PATH, 'r') as f:
        data = json.load(f)
    simple = {}
    for k, v in data.items():
        if k.startswith('@') or k.startswith('@@'):
            continue
        if '{' not in str(v):
            simple[v] = k
    return simple

def find_dart_files():
    result = []
    for dirpath, dirnames, filenames in os.walk(LIB_DIR):
        rel = os.path.relpath(dirpath, LIB_DIR)
        parts = rel.split(os.sep)
        if any(p in SKIP_DIRS for p in parts):
            continue
        for fn in filenames:
            if fn.endswith('.dart') and fn not in SKIP_FILES:
                result.append(os.path.join(dirpath, fn))
    return sorted(result)

def has_localizations_import(content):
    return 'AppLocalizations' in content or "import 'package:flutter_gen/gen_l10n/app_localizations.dart'" in content

def has_l_variable(content):
    return re.search(r'final\s+l\s*=\s*AppLocalizations\.of\(context\)', content) is not None

def process_file(filepath, mapping, dry_run=False):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    replacements = []
    
    # Sort by length (longest first) to avoid partial matches  
    sorted_texts = sorted(mapping.keys(), key=len, reverse=True)
    
    for text in sorted_texts:
        key = mapping[text]
        # Escape for regex
        escaped = re.escape(text)
        
        # Match patterns like: 'Text string' or "Text string"
        # In Text(), title:, subtitle:, label:, hint:, message:, etc.
        for quote in ["'", '"']:
            pattern = re.escape(quote) + escaped + re.escape(quote)
            
            # Find all occurrences
            for m in re.finditer(pattern, content):
                start = m.start()
                end = m.end()
                
                # Check what comes before - look for common widget/parameter patterns
                before = content[max(0, start-200):start]
                
                # Skip if it's in a comment
                line_start = content.rfind('\n', 0, start) + 1
                line_content = content[line_start:start].strip()
                if line_content.startswith('//') or line_content.startswith('*') or line_content.startswith('///'):
                    continue
                
                # Skip if it's in an import or part of a key/map literal that's not a UI string
                if 'import ' in before.split('\n')[-1]:
                    continue
                
                # Check if this looks like a UI string context
                # (after Text(, title:, label:, subtitle:, hintText:, content:, message:, etc.)
                before_stripped = before.rstrip()
                is_ui_context = any(kw in before_stripped[-80:] for kw in [
                    'Text(', 'text:', 'title:', 'subtitle:', 'label:', 'hintText:', 
                    'content:', 'message:', 'Text.rich(', 'tooltip:', 'semanticsLabel:',
                    'SnackBar(', 'showDialog', 'AlertDialog(', 'errorText:', 'helperText:',
                    'AppBar(', 'body:', 'hint:', 'Tab(', 'headerText:', 'Text(',
                    'ScaffoldMessenger', 'showSnackBar', 'child:', 'description:',
                    'hintStyle', 'dialogTitle:', 'confirmText:', 'cancelText:',
                    'dropdownMenuEntries', 'DropdownMenuEntry(', 'debugPrint(',
                ])
                
                replacements.append({
                    'start': start,
                    'end': end,
                    'old': content[start:end],
                    'new': f'l.{key}',
                    'key': key,
                    'text': text,
                    'is_ui': is_ui_context,
                    'line': content[:start].count('\n') + 1,
                })
    
    return replacements

def main():
    dry_run = '--dry-run' in sys.argv
    verbose = '--verbose' in sys.argv
    file_filter = None
    for arg in sys.argv[1:]:
        if not arg.startswith('--'):
            file_filter = arg
    
    mapping = load_arb()
    print(f"Loaded {len(mapping)} simple translation keys")
    
    dart_files = find_dart_files()
    if file_filter:
        dart_files = [f for f in dart_files if file_filter in f]
    
    print(f"Scanning {len(dart_files)} Dart files...")
    
    total_replacements = 0
    files_with_replacements = 0
    
    for filepath in dart_files:
        replacements = process_file(filepath, mapping, dry_run)
        ui_replacements = [r for r in replacements if r['is_ui']]
        
        if ui_replacements:
            files_with_replacements += 1
            rel = os.path.relpath(filepath, ROOT)
            print(f"\n{rel}: {len(ui_replacements)} replacements")
            for r in ui_replacements:
                print(f"  L{r['line']}: {r['old']} -> l.{r['key']}")
            total_replacements += len(ui_replacements)
    
    print(f"\n{'='*60}")
    print(f"Total: {total_replacements} UI string replacements in {files_with_replacements} files")
    if dry_run:
        print("(dry run - no files modified)")

if __name__ == '__main__':
    main()
