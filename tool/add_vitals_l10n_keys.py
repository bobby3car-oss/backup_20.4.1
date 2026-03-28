#!/usr/bin/env python3
"""Adds Vitalwerte l10n keys to all 5 locale ARB files (idempotent)."""
import json
from pathlib import Path

ROOT = Path(__file__).parent.parent
L10N = ROOT / "lib" / "l10n"

SIMPLE = [
    # key, de, en, ar, ru, tr
    ("vitalwerte",            "Vitalwerte",                                 "Vitals",                                        "المعايير الحيوية",               "Жизненные показатели",                            "Yaşamsal Değerler"),
    ("neueMessung",           "Neue Messung",                               "New Measurement",                               "قياس جديد",                      "Новое измерение",                                 "Yeni Ölçüm"),
    ("systolisch",            "Systolisch",                                 "Systolic",                                      "الانقباضي",                      "Систолическое",                                   "Sistolik"),
    ("diastolisch",           "Diastolisch",                                "Diastolic",                                     "الانبساطي",                      "Диастолическое",                                  "Diastolik"),
    ("puls",                  "Puls",                                       "Pulse",                                         "النبض",                          "Пульс",                                           "Nabız"),
    ("normalSystolisch",      "Normal: 90–140",                             "Normal: 90–140",                                "الطبيعي: 90–140",                "Норма: 90–140",                                   "Normal: 90–140"),
    ("normalDiastolisch",     "Normal: 60–90",                              "Normal: 60–90",                                 "الطبيعي: 60–90",                 "Норма: 60–90",                                    "Normal: 60–90"),
    ("normalPuls",            "Normal: 60–100",                             "Normal: 60–100",                                "الطبيعي: 60–100",                "Норма: 60–100",                                   "Normal: 60–100"),
    ("weitereWerteOptional",  "Weitere Werte (optional)",                   "More Values (optional)",                        "قيم إضافية (اختياري)",           "Дополнительные показатели (необязательно)",       "Ek Değerler (isteğe bağlı)"),
    ("vitalsErinnerung",      "Erinnerung",                                 "Reminder",                                      "تذكير",                          "Напоминание",                                     "Hatırlatıcı"),
    ("taeglicheMesserinnerung","Tägliche Messerinnerung",                   "Daily Measurement Reminder",                    "تذكير يومي بالقياس",             "Ежедневное напоминание об измерении",             "Günlük Ölçüm Hatırlatıcısı"),
    ("temperatur",            "Temperatur",                                 "Temperature",                                   "درجة الحرارة",                   "Температура",                                     "Sıcaklık"),
    ("normalTemperatur",      "Normal: 36.0–37.5 °C",                      "Normal: 36.0–37.5 °C",                          "الطبيعي: 36.0–37.5 °C",          "Норма: 36,0–37,5 °C",                             "Normal: 36.0–37.5 °C"),
    ("normalO2Saettigung",    "Normal: 95–100 %",                           "Normal: 95–100 %",                              "الطبيعي: 95–100 %",              "Норма: 95–100 %",                                 "Normal: 95–100 %"),
    ("notizOptional",         "Notiz (optional)",                           "Note (optional)",                               "ملاحظة (اختياري)",               "Заметка (необязательно)",                         "Not (isteğe bağlı)"),
    ("mindZweiEintraege",     "Mind. 2 Einträge für den Verlauf",           "Min. 2 entries for the chart",                  "مدخلان على الأقل للعرض",         "Мин. 2 записи для графика",                       "Grafik için min. 2 kayıt"),
    ("vitalsTipp",            "Tipp: Trage deine Vitalwerte täglich ein – so erkennst du Trends frühzeitig.",
                                                                            "Tip: Log your vitals daily – this helps you spot trends early.",
                                                                                                                             "نصيحة: سجّل مؤشراتك الحيوية يومياً لاكتشاف الاتجاهات مبكراً.",
                                                                                                                                                               "Совет: записывайте показатели каждый день – это поможет замечать тенденции заранее.",
                                                                                                                                                                                                                  "İpucu: Yaşamsal değerlerinizi her gün kaydedin – böylece eğilimleri erken fark edersiniz."),
    ("chartLast5",            "5 Einträge",                                 "5 entries",                                     "5 مدخلات",                       "5 записей",                                       "5 kayıt"),
    ("chartDays7",            "7 Tage",                                     "7 days",                                        "7 أيام",                         "7 дней",                                          "7 gün"),
    ("chartDays30",           "30 Tage",                                    "30 days",                                       "30 يومًا",                       "30 дней",                                         "30 gün"),
    ("blutdruck",             "Blutdruck",                                  "Blood Pressure",                                "ضغط الدم",                       "Артериальное давление",                           "Tansiyon"),
    ("trageVitalwerteEin",    "Trage deine aktuellen Vitalwerte ein.",      "Enter your current vitals.",                    "أدخل مؤشراتك الحيوية الحالية.",  "Введите ваши текущие показатели.",                "Güncel değerlerinizi girin."),
]

PARAMETERIZED = {
    "normalbereichValue": {
        "de": "Normalbereich: {min}–{max} {unit}",
        "en": "Normal range: {min}–{max} {unit}",
        "ar": "النطاق الطبيعي: {min}–{max} {unit}",
        "ru": "Норма: {min}–{max} {unit}",
        "tr": "Normal aralık: {min}–{max} {unit}",
        "meta": {
            "placeholders": {
                "min": {"type": "String"},
                "max": {"type": "String"},
                "unit": {"type": "String"},
            }
        },
    },
}

LOCALE_MAP = {"de": 0, "en": 1, "ar": 2, "ru": 3, "tr": 4}


def add_keys(locale: str, path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    added = 0

    for row in SIMPLE:
        key = row[0]
        value = row[LOCALE_MAP[locale] + 1]
        if key not in data:
            data[key] = value
            added += 1

    for key, info in PARAMETERIZED.items():
        if key not in data:
            data[key] = info[locale]
            data[f"@{key}"] = info["meta"]
            added += 1

    if added:
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    print(f"  [{locale}] +{added} keys added")


for locale in ["de", "en", "ar", "ru", "tr"]:
    arb = L10N / f"app_{locale}.arb"
    add_keys(locale, arb)
