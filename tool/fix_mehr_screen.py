#!/usr/bin/env python3
"""Fix remaining emoji: callers in mehr_screen.dart"""
import sys

fpath = 'lib/screens/mehr_screen.dart'
with open(fpath, 'r', encoding='utf-8') as f:
    content = f.read()

# Map remaining emojis in this file to AppIcons constants
replacements = {
    "emoji: '\u2764\ufe0f',": 'icon: AppIcons.vitals, iconColor: AppIcons.vitalsColor,',
    "emoji: '\U0001f4ca',": 'icon: AppIcons.pain, iconColor: AppIcons.painColor,',
    "emoji: '\U0001f4c8',": 'icon: AppIcons.analytics, iconColor: AppIcons.analyticsColor,',
    "emoji: '\U0001f9d1\u200d\u2695\ufe0f',": 'icon: AppIcons.doctor, iconColor: AppIcons.doctorColor,',
    "emoji: '\U0001f91d',": 'icon: AppIcons.caregiver, iconColor: AppIcons.caregiverColor,',
    "emoji: '\U0001f468\u200d\u2695\ufe0f',": 'icon: AppIcons.doctor, iconColor: AppIcons.doctorColor,',
    "emoji: '\U0001f527',": 'icon: AppIcons.settings, iconColor: AppIcons.settingsColor,',
    "emoji: '\U0001f44b',": 'icon: AppIcons.support, iconColor: AppIcons.supportColor,',
    "emoji: '\U0001f511',": 'icon: AppIcons.privacy, iconColor: AppIcons.privacyColor,',
    "emoji: '\U0001f9ea',": 'icon: AppIcons.info, iconColor: AppIcons.infoColor,',
}

for old, new in replacements.items():
    if old in content:
        content = content.replace(old, new)
        print(f'  Replaced: {repr(old[:30])}...')

# Also fix rendering references
content = content.replace('section.emoji', 'section.icon')

with open(fpath, 'w', encoding='utf-8') as f:
    f.write(content)

# Verify
remaining = [l for l in content.split('\n') if 'emoji' in l.lower() and 'Icons.emoji' not in l and '//' not in l]
print(f'\n{len(remaining)} emoji references remain')
for l in remaining:
    print(f'  {l.strip()}')
