#!/usr/bin/env python3
"""Fix quote escaping in l10n_migrate.py"""
import re

with open('tool/l10n_migrate.py', 'r') as f:
    content = f.read()

# Pattern: find lines where \u201e...{something}" has a bare ASCII " closing
# Replace: "de": "\u201e{title}" gelöscht" -> "de": "\u201e{title}\u201c gelöscht"
# The issue: the right quote after {title} is an ASCII " not \u201c

# Fix 1: itemDeletedMessage
old = '        "de": "\\u201e{title}" gel'
new = '        "de": "\\u201e{title}\\u201c gel'
content = content.replace(old, new)

# Fix 2: itemDeletedPermanently
old2 = '        "de": "\\u201e{title}" wird'
new2 = '        "de": "\\u201e{title}\\u201c wird'
content = content.replace(old2, new2)

# Also fix any remaining ö that appears after Unicode escapes in same strings
# (these are fine syntactically but let's keep consistency)

with open('tool/l10n_migrate.py', 'w') as f:
    f.write(content)

# Verify the fix
with open('tool/l10n_migrate.py', 'r') as f:
    lines = f.read().split('\n')

for i, line in enumerate(lines):
    if 'itemDeleted' in line or ('201e' in line and 'title' in line):
        print(f"L{i+1}: {line.strip()}")

print("\nDone fixing.")
