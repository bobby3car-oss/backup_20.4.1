#!/usr/bin/env python3
"""Find remaining English strings in generated app_localizations_de.dart."""
import re

patterns = re.compile(
    r"=> '((?:No |Add |Create |Edit |Delete |Cancel |Select |Upload |"
    r"Update |Save |View |Show |Check |Enter |Choose |Tap [a-z]|Unlock |"
    r"Please |Your |The |Repeat |Failed |Or [a-z]|Today'|Tomorrow'|"
    r"appointment|Reminders? for|Daily |Monthly |Weekly |Do you |Would you |Really |"
    r"Doctor |Clinic |Patient |Medication |Wound |Pain |Sleep |Mood |Nutrition |"
    r"How |When |What |Who |Where |Why )[a-zA-Z])"
)

german_check = re.compile(r'[äöüÄÖÜß]|Bitte |bitte |keine |Keine |Heute |heute |Termin |Arzt ')

results = []
with open('lib/l10n/app_localizations_de.dart', 'r', encoding='utf-8') as f:
    for i, line in enumerate(f, 1):
        if patterns.search(line):
            val_m = re.search(r"=> '([^']+)'", line)
            if val_m:
                val = val_m.group(1)
                if not german_check.search(val):
                    results.append((i, line.strip()))

print(f'Remaining English strings in generated DE file: {len(results)}')
for lineno, line in results:
    print(f'  L{lineno}: {line}')
