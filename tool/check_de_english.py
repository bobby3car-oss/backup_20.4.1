#!/usr/bin/env python3
"""Find DE keys where value equals EN value and appears to be English (no German chars)."""
import json, re

with open('lib/l10n/app_de.arb', 'r', encoding='utf-8') as f:
    de = json.load(f)
with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
    en = json.load(f)

german_chars = re.compile(r'[äöüÄÖÜß]')
# values that are purely non-linguistic (numbers, symbols, placeholders only)
nonlang = re.compile(r'^[\d\s\+\-\(\)\.\:\,\%\{\}\/\*\u20ac@#!?_\u2011\u00d8\n]+$')

suspicious = []
for k in de:
    if k.startswith('@'):
        continue
    dv = de[k]
    ev = en.get(k, '')
    if dv == ev and ev and not nonlang.match(ev) and not german_chars.search(ev):
        suspicious.append((k, dv))

print(f'Potentially English-only values in DE: {len(suspicious)} keys')
for k, v in suspicious[:50]:
    print(f'  {k}: {repr(v[:100])}')
if len(suspicious) > 50:
    print(f'  ... and {len(suspicious)-50} more')
