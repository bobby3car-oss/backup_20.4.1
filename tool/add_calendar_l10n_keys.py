#!/usr/bin/env python3
"""Add missing calendar/appointment l10n keys to all 5 locale ARB files."""

import json
import re
from pathlib import Path

L10N_DIR = Path(__file__).parent.parent / "lib" / "l10n"

KEYS = {
    "de": {
        "calendarTitle": "Kalender",
        "calendarWeek": "Woche",
        "calendarMonth": "Monat",
        "calendarNoEvents": "Keine Termine an diesem Tag",
        "calendarAddToCalendarBody": "Möchtest du diesen Termin zu deinem Geräte-Kalender hinzufügen oder als .ics-Datei teilen?",
        "calendarAddedSuccess": "Termin zum Kalender hinzugefügt",
        "calendarExportFailed": "Kalender-Export fehlgeschlagen",
        "apptRepeatUntilDate": "(bis {date})",
        "@apptRepeatUntilDate": {"placeholders": {"date": {"type": "String"}}},
    },
    "en": {
        "calendarTitle": "Calendar",
        "calendarWeek": "Week",
        "calendarMonth": "Month",
        "calendarNoEvents": "No appointments on this day",
        "calendarAddToCalendarBody": "Would you like to add this appointment to your device calendar or share it as an .ics file?",
        "calendarAddedSuccess": "Appointment added to calendar",
        "calendarExportFailed": "Calendar export failed",
        "apptRepeatUntilDate": "(until {date})",
        "@apptRepeatUntilDate": {"placeholders": {"date": {"type": "String"}}},
    },
    "ar": {
        "calendarTitle": "التقويم",
        "calendarWeek": "أسبوع",
        "calendarMonth": "شهر",
        "calendarNoEvents": "لا مواعيد في هذا اليوم",
        "calendarAddToCalendarBody": "هل تريد إضافة هذا الموعد إلى تقويم جهازك أو مشاركته كملف .ics؟",
        "calendarAddedSuccess": "تمت إضافة الموعد إلى التقويم",
        "calendarExportFailed": "فشل تصدير التقويم",
        "apptRepeatUntilDate": "(حتى {date})",
        "@apptRepeatUntilDate": {"placeholders": {"date": {"type": "String"}}},
    },
    "ru": {
        "calendarTitle": "Календарь",
        "calendarWeek": "Неделя",
        "calendarMonth": "Месяц",
        "calendarNoEvents": "Нет приёмов на этот день",
        "calendarAddToCalendarBody": "Хотите добавить эту запись в календарь устройства или поделиться как .ics-файл?",
        "calendarAddedSuccess": "Запись добавлена в календарь",
        "calendarExportFailed": "Экспорт в календарь не удался",
        "apptRepeatUntilDate": "(до {date})",
        "@apptRepeatUntilDate": {"placeholders": {"date": {"type": "String"}}},
    },
    "tr": {
        "calendarTitle": "Takvim",
        "calendarWeek": "Hafta",
        "calendarMonth": "Ay",
        "calendarNoEvents": "Bu günde randevu yok",
        "calendarAddToCalendarBody": "Bu randevuyu cihaz takviminize eklemek veya .ics dosyası olarak paylaşmak ister misiniz?",
        "calendarAddedSuccess": "Randevu takvime eklendi",
        "calendarExportFailed": "Takvim dışa aktarımı başarısız",
        "apptRepeatUntilDate": "({date} tarihine kadar)",
        "@apptRepeatUntilDate": {"placeholders": {"date": {"type": "String"}}},
    },
}

# Fix appointmentEditorRepeatUntil in de.arb (currently says "Repeat until")
FIXES = {
    "de": {"appointmentEditorRepeatUntil": "Wiederholung bis"},
    "en": {},
    "ar": {},
    "ru": {},
    "tr": {},
}


def load_arb(locale: str) -> tuple[dict, str]:
    path = L10N_DIR / f"app_{locale}.arb"
    text = path.read_text(encoding="utf-8")
    data = json.loads(text)
    return data, str(path)


def add_keys_to_arb(locale: str) -> None:
    path = L10N_DIR / f"app_{locale}.arb"
    text = path.read_text(encoding="utf-8")

    new_entries: list[str] = []
    locale_keys = KEYS[locale]

    # Collect keys that are not yet present
    data = json.loads(text)
    added = 0
    for key, value in locale_keys.items():
        if key.startswith("@"):
            continue  # handled with the base key below
        if key not in data:
            if isinstance(value, str):
                new_entries.append(f'  "{key}": "{value}"')
            meta_key = f"@{key}"
            if meta_key in locale_keys:
                meta_val = json.dumps(locale_keys[meta_key], ensure_ascii=False)
                new_entries.append(f'  "{meta_key}": {meta_val}')
            added += 1

    # Apply fixes
    for fix_key, fix_val in FIXES.get(locale, {}).items():
        if fix_key in data and data[fix_key] != fix_val:
            # Replace the value in the raw text
            old = f'"{fix_key}": "{data[fix_key]}"'
            new = f'"{fix_key}": "{fix_val}"'
            text = text.replace(old, new)
            print(f"[{locale}] Fixed {fix_key}: '{data[fix_key]}' -> '{fix_val}'")

    if not new_entries:
        print(f"[{locale}] No new keys to add")
    else:
        # Insert before closing }
        insert_text = ",\n".join(new_entries)
        text = re.sub(r'\n\}$', f',\n{insert_text}\n}}', text)
        print(f"[{locale}] Added {added} keys")

    path.write_text(text, encoding="utf-8")


for locale in ["de", "en", "ar", "ru", "tr"]:
    add_keys_to_arb(locale)

print("\nDone. Run: flutter gen-l10n")
