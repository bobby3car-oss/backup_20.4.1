#!/usr/bin/env python3
"""Broad scan for English-looking values in DE ARB that may have been missed."""
import json, re

with open('lib/l10n/app_de.arb', 'r', encoding='utf-8') as f:
    de = json.load(f)
with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
    en = json.load(f)

english_pat = re.compile(
    r'\b(appointment|Appointment|calendar|Calendar|overview|Overview|'
    r'patient|Patient|doctor|Doctor|select|Select|create|Create|'
    r'delete|Delete|edit |Edit |cancel|Cancel|unlock|Unlock|medication|Medication|'
    r'wound doc|Choose|Upload|upload|share |Share |health|'
    r'question|Question|your |Your |the |The |for |with |and )\b'
)
german_chars = re.compile(r'[äöüÄÖÜß]')

found = []
for k, v in de.items():
    if k.startswith('@'):
        continue
    if not isinstance(v, str):
        continue
    if german_chars.search(v):
        continue
    if english_pat.search(v) and len(v) > 4:
        found.append((k, v))

print(f'DE keys with English-looking values: {len(found)}')
for k, dv in found:
    print(f'  {k}: {repr(dv[:100])}')
