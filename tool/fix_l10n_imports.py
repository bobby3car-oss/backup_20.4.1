#!/usr/bin/env python3
"""Fix incorrect l10n import paths in Dart files."""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
L10N_FILE = os.path.join(LIB, 'l10n', 'app_localizations.dart')

# The various wrong import patterns
WRONG_IMPORTS = [
    re.compile(r"import\s+'[^']*l10n/app_localizations\.dart'\s*;"),
    re.compile(r'import\s+"[^"]*l10n/app_localizations\.dart"\s*;'),
]

fixed = 0
for dirpath, dirnames, filenames in os.walk(LIB):
    for fn in filenames:
        if not fn.endswith('.dart'):
            continue
        filepath = os.path.join(dirpath, fn)
        with open(filepath) as f:
            content = f.read()
        
        if 'l10n/app_localizations.dart' not in content:
            continue
        
        # Already using correct generated import?
        if 'package:flutter_gen/gen_l10n/app_localizations.dart' in content:
            continue
        
        # Calculate correct relative path from this file to lib/l10n/app_localizations.dart
        file_dir = os.path.dirname(filepath)
        rel = os.path.relpath(os.path.join(LIB, 'l10n', 'app_localizations.dart'), file_dir)
        # Normalize to forward slashes
        rel = rel.replace(os.sep, '/')
        correct_import = f"import '{rel}';"
        
        new_content = content
        for pattern in WRONG_IMPORTS:
            new_content = pattern.sub(correct_import, new_content)
        
        if new_content != content:
            with open(filepath, 'w') as f:
                f.write(new_content)
            print(f"Fixed: {os.path.relpath(filepath, ROOT)}")
            print(f"  -> {correct_import}")
            fixed += 1

print(f"\nFixed {fixed} files")
