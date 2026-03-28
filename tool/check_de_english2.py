#!/usr/bin/env python3
"""Find DE keys that have clearly English values (same as EN, English construction markers)."""
import json, re

with open('lib/l10n/app_de.arb', 'r', encoding='utf-8') as f:
    de = json.load(f)
with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
    en = json.load(f)

english_markers = re.compile(
    r'\b(the|The|and |And |for |For |with |With |your|Your|You |you |has |have |been |'
    r'not |all |from |From |saved|removed|linked|blocked|deleted|'
    r'available|Please|please|Only |only |assigned|loading|Saving )\b'
)
german_chars = re.compile(r'[äöüÄÖÜß]')

clearly_english = []
for k in de:
    if k.startswith('@'):
        continue
    dv = de[k]
    ev = en.get(k, '')
    if (dv == ev and ev
            and not german_chars.search(ev)
            and english_markers.search(ev)
            and len(ev) > 5):
        clearly_english.append((k, dv))

print(f'Clearly English values in DE template: {len(clearly_english)}')
for k, v in clearly_english:
    print(f'  {k}: {repr(v[:100])}')
