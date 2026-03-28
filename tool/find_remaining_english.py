#!/usr/bin/env python3
"""Find all remaining English values in the generated DE dart file."""
import re

with open("lib/l10n/app_localizations_de.dart") as f:
    content = f.read()

# Find all getter methods
getters = re.findall(r"String get (\w+) => '([^']*)'", content)

german_chars = re.compile(r"[äöüÄÖÜß]")
german_words = re.compile(
    r"\b(Termin|Arzt|Konto|Wund|Reha|Notfall|Patient|Upload|OP|Tage|Tag|"
    r"Minute|Stunde|nach|vor|und|der|die|das|kein|Nein|Ja|ist|im|am|vom|"
    r"Ihr|Ihre|Kein|Keine|Haben|Noch|Neue|Neues|Bisher|Rote|Symptom-Check)\b"
    , re.I)

english_words = re.compile(
    r"\b(High|Low|Medium|Urgent|Daily|Weekly|Monthly|None|Custom|Call|"
    r"Imaging|Surgery|Follow.up|Accompany|Analysis|Analytics|Documentation|"
    r"Documents|Emergency|Health|Report|Help|Language|Mood|Notifications|"
    r"Nutrition|Planning|Packing|Pain|People|Photos|Profile|Progress|"
    r"Recently Used|Red Flags|Rehabilitation|Sleep|Symptom Check|Vitals|"
    r"Voice Notes|before|hour|day|min\.|List|Done|Pending|Planned|"
    r"Confirmed|Declined|Canceled|Completed|Physio|Other|Surgery Info|"
    r"Surgery & Planning|Accompany|Vital Signs|Voice Notes|Symptom Check|"
    r"Recently Used|Packing List|Emergency Info|Health Report|Mood|Sleep|"
    r"Red Flags)\b"
)

results = []
for key, val in getters:
    if val and not german_chars.search(val) and not german_words.search(val) and english_words.search(val):
        results.append((key, val))

for k, v in sorted(results):
    print(f"  {k}: '{v}'")
print(f"\nTotal: {len(results)}")
