#!/usr/bin/env python3
"""Add Symptom-Check l10n keys to all 5 ARB files."""

import json
import pathlib

ROOT = pathlib.Path(__file__).parent.parent
L10N = ROOT / "lib" / "l10n"

# ---------------------------------------------------------------------------
# New keys: (key, de, en, ar, ru, tr)
# ---------------------------------------------------------------------------
KEYS = [
    # ── Severity labels ──────────────────────────────────────────────────────
    ("scSeverityNone",     "Keine",   "None",     "لا شيء",    "Нет",        "Yok"),
    ("scSeverityMild",     "Leicht",  "Mild",     "خفيف",      "Лёгкое",     "Hafif"),
    ("scSeverityModerate", "Mittel",  "Moderate", "متوسط",     "Умеренное",  "Orta"),
    ("scSeveritySevere",   "Stark",   "Severe",   "شديد",      "Сильное",    "Şiddetli"),

    # ── Traffic-light level labels ────────────────────────────────────────────
    ("scLevelGreen",  "Grün",  "Green",  "أخضر",  "Зелёный",  "Yeşil"),
    ("scLevelYellow", "Gelb",  "Yellow", "أصفر",  "Жёлтый",   "Sarı"),
    ("scLevelRed",    "Rot",   "Red",    "أحمر",  "Красный",  "Kırmızı"),

    # ── Level title (green → allesImGruenenBereich, red → aerztlichenRatEinholen) ──
    ("scLevelTitleYellow",
     "Bitte beobachten",
     "Please observe",
     "يرجى المراقبة",
     "Пожалуйста, наблюдайте",
     "Lütfen gözlemleyin"),

    # ── Level recommendations ─────────────────────────────────────────────────
    ("scRecommendGreen",
     "Ihre Symptome sind unauffällig. Dokumentieren Sie weiterhin regelmäßig und halten Sie sich an Ihren Genesungsplan.",
     "Your symptoms are unremarkable. Continue to document regularly and follow your recovery plan.",
     "أعراضك طبيعية. استمر في التوثيق المنتظم واتبع خطة تعافيك.",
     "Ваши симптомы в норме. Продолжайте регулярно фиксировать данные и следуйте плану восстановления.",
     "Semptomlarınız normal. Düzenli olarak kayıt tutmaya devam edin ve iyileşme planınıza uyun."),
    ("scRecommendYellow",
     "Einzelne Symptome sind leicht auffällig. Beobachten Sie die Entwicklung in den nächsten 24 Stunden. Bei Verschlechterung kontaktieren Sie Ihren Arzt.",
     "Some symptoms are slightly abnormal. Monitor the development over the next 24 hours. Contact your doctor if symptoms worsen.",
     "بعض الأعراض طفيفة غير طبيعية. راقب التطور خلال الـ 24 ساعة القادمة. اتصل بطبيبك إذا تدهورت الحالة.",
     "Некоторые симптомы незначительно отклонены. Наблюдайте за развитием в течение следующих 24 часов. Обратитесь к врачу при ухудшении.",
     "Bazı semptomlar hafifçe anormal. Sonraki 24 saat içinde gelişimi izleyin. Semptomlar kötüleşirse doktorunuzla iletişime geçin."),
    ("scRecommendRed",
     "Ihre Symptome deuten auf eine Komplikation hin. Kontaktieren Sie umgehend Ihren Arzt oder suchen Sie die nächste Notaufnahme auf.",
     "Your symptoms indicate a possible complication. Contact your doctor immediately or go to the nearest emergency room.",
     "تشير أعراضك إلى احتمال وجود مضاعفات. اتصل بطبيبك فوراً أو اذهب إلى أقرب غرفة طوارئ.",
     "Ваши симптомы указывают на возможное осложнение. Немедленно обратитесь к врачу или в ближайшее отделение неотложной помощи.",
     "Semptomlarınız olası bir komplikasyona işaret ediyor. Hemen doktorunuzla iletişime geçin veya en yakın acil servise gidin."),

    # ── Symptom question titles ───────────────────────────────────────────────
    ("scSymPain",      "Schmerzen",  "Pain",         "ألم",        "Боль",              "Ağrı"),
    ("scSymNausea",    "Übelkeit",   "Nausea",       "غثيان",      "Тошнота",           "Bulantı"),
    ("scSymBreathing", "Atmung",     "Breathing",    "التنفس",     "Дыхание",           "Nefes"),
    ("scSymDizziness", "Schwindel",  "Dizziness",    "دوار",       "Головокружение",    "Baş dönmesi"),
    ("scSymWound",     "Wundstatus", "Wound Status", "حالة الجرح", "Состояние раны",    "Yara Durumu"),

    # ── Symptom question subtitles ────────────────────────────────────────────
    ("scSymPainSub",
     "Wie stark sind Ihre Schmerzen im OP-Bereich?",
     "How severe is your pain in the surgical area?",
     "ما مدى شدة ألمك في منطقة العملية؟",
     "Насколько сильна ваша боль в области операции?",
     "Ameliyat bölgesindeki ağrınız ne kadar şiddetli?"),
    ("scSymNauseaSub",
     "Verspüren Sie Übelkeit oder Brechreiz?",
     "Do you have nausea or the urge to vomit?",
     "هل تشعر بالغثيان أو الرغبة في التقيؤ؟",
     "Испытываете ли вы тошноту или позывы к рвоте?",
     "Bulantı veya kusma isteği hissediyor musunuz?"),
    ("scSymBreathingSub",
     "Haben Sie Atembeschwerden oder Kurzatmigkeit?",
     "Do you have breathing difficulties or shortness of breath?",
     "هل تعاني من صعوبة في التنفس أو ضيق في التنفس؟",
     "Испытываете ли вы затруднение дыхания или одышку?",
     "Nefes almada güçlük veya nefes darlığı var mı?"),
    ("scSymDizzinessSub",
     "Fühlen Sie sich benommen oder schwindelig?",
     "Do you feel dizzy or lightheaded?",
     "هل تشعر بالدوار أو بالدوخة؟",
     "Чувствуете ли вы головокружение или слабость?",
     "Başınız dönüyor mu veya sersemliyor musunuz?"),
    ("scSymWoundSub",
     "Zeigt die Wunde Auffälligkeiten (Rötung, Sekret)?",
     "Does the wound show abnormalities (redness, discharge)?",
     "هل تظهر على الجرح علامات غير طبيعية (احمرار، إفرازات)؟",
     "Проявляет ли рана отклонения (покраснение, выделения)?",
     "Yarada anormallikler (kızarıklık, akıntı) var mı?"),

    # ── Screen UI ─────────────────────────────────────────────────────────────
    ("scTitle",           "Symptom\u2011Check",  "Symptom Check",            "فحص الأعراض",          "Проверка симптомов",       "Semptom Kontrolü"),
    ("scSymptomsSection", "Symptome bewerten",   "Evaluate Symptoms",        "تقييم الأعراض",        "Оценка симптомов",         "Semptomları Değerlendir"),
    ("scYourInputs",      "Ihre Angaben",        "Your Inputs",              "بياناتك",              "Ваши данные",              "Bilgileriniz"),
    ("scIntroBody",
     "Bewerten Sie jedes Symptom. Am Ende erhalten Sie eine Einschätzung mit Empfehlung.",
     "Rate each symptom. At the end you will receive an assessment with a recommendation.",
     "قيّم كل عَرَض. في النهاية ستحصل على تقييم مع توصية.",
     "Оцените каждый симптом. В конце вы получите заключение с рекомендацией.",
     "Her semptomu değerlendirin. Sonunda bir öneri ile değerlendirme alacaksınız."),
    ("scSetDailyReminder",
     "Tägliche Erinnerung einrichten",
     "Set Daily Reminder",
     "إعداد تذكير يومي",
     "Установить ежедневное напоминание",
     "Günlük Hatırlatıcı Kur"),

    # ── Actions card ──────────────────────────────────────────────────────────
    ("scActionsTitle",
     "Empfohlene Aktionen",
     "Recommended Actions",
     "الإجراءات الموصى بها",
     "Рекомендуемые действия",
     "Önerilen Eylemler"),
    ("scSaveResult",
     "Ergebnis speichern",
     "Save Result",
     "احفظ النتيجة",
     "Сохранить результат",
     "Sonucu Kaydet"),
    ("scSaving",  "Speichert…", "Saving…",    "جارٍ الحفظ…",  "Сохранение…",   "Kaydediliyor…"),
    ("scSaved",   "Gespeichert ✓", "Saved ✓", "تم الحفظ ✓",   "Сохранено ✓",   "Kaydedildi ✓"),
]

# Keys with placeholders
PARAM_KEYS = [
    (
        "scResultBadge",
        "Ergebnis: {label}", "Result: {label}",
        "النتيجة: {label}", "Результат: {label}", "Sonuç: {label}",
        {"label": {"type": "String"}},
    ),
    (
        "scReminderActive",
        "Erinnerung: {time}", "Reminder: {time}",
        "تذكير: {time}", "Напоминание: {time}", "Hatırlatıcı: {time}",
        {"time": {"type": "String"}},
    ),
    (
        "scReminderSet",
        "Erinnerung gesetzt für {time}",
        "Reminder set for {time}",
        "تم ضبط التذكير على {time}",
        "Напоминание установлено на {time}",
        "Hatırlatıcı {time} için ayarlandı",
        {"time": {"type": "String"}},
    ),
]

LOCALES = ["de", "en", "ar", "ru", "tr"]


def insert_keys(arb_path: pathlib.Path, new_keys: dict) -> None:
    """Insert new_keys (key→value) into the ARB file if not already present."""
    text = arb_path.read_text(encoding="utf-8")
    data = json.loads(text)

    added = 0
    for k, v in new_keys.items():
        if k not in data:
            data[k] = v
            added += 1

    if added == 0:
        print(f"  [{arb_path.name}] nothing to add (all keys already present)")
        return

    out = json.dumps(data, ensure_ascii=False, indent=2)
    arb_path.write_text(out + "\n", encoding="utf-8")
    print(f"  [{arb_path.name}] +{added} keys")


def main() -> None:
    locale_index = {"de": 1, "en": 2, "ar": 3, "ru": 4, "tr": 5}

    for locale in LOCALES:
        path = L10N / f"app_{locale}.arb"
        if not path.exists():
            print(f"WARNING: {path} not found, skipping")
            continue

        idx = locale_index[locale]
        new_entries: dict = {}

        # Plain keys
        for row in KEYS:
            new_entries[row[0]] = row[idx]

        # Param keys
        for row in PARAM_KEYS:
            key = row[0]
            new_entries[key] = row[idx]
            meta: dict = {"placeholders": {}}
            for ph_name, ph_meta in row[6].items():
                meta["placeholders"][ph_name] = ph_meta
            new_entries[f"@{key}"] = meta

        insert_keys(path, new_entries)

    print("Done.")


if __name__ == "__main__":
    main()
