#!/usr/bin/env python3
"""Add red-flag / warning-system l10n keys to all 5 ARB files."""

import json, re, pathlib, sys

ROOT = pathlib.Path(__file__).parent.parent
L10N = ROOT / "lib" / "l10n"

# ---------------------------------------------------------------------------
# New keys: (key, de, en, ar, ru, tr)
# ---------------------------------------------------------------------------
KEYS = [
    # ── Severity colour labels ──────────────────────────────────────────────
    ("rfSeverityYellow",  "Gelb",    "Yellow",   "أصفر",     "Жёлтый",    "Sarı"),
    ("rfSeverityOrange",  "Orange",  "Orange",   "برتقالي",  "Оранжевый", "Turuncu"),
    ("rfSeverityRed",     "Rot",     "Red",      "أحمر",     "Красный",   "Kırmızı"),

    # ── Status labels ───────────────────────────────────────────────────────
    ("rfStatusOpen",         "Offen",       "Open",       "مفتوح",       "Открыт",          "Açık"),
    ("rfStatusAcknowledged", "Gesehen",     "Seen",       "مشاهَد",      "Просмотрен",      "Görüldü"),
    ("rfStatusMonitoring",   "Beobachtung", "Monitoring", "مراقبة",      "Наблюдение",      "İzleme"),
    ("rfStatusEscalated",    "Eskaliert",   "Escalated",  "متصاعد",      "Эскалирован",     "Eskalatif"),
    ("rfStatusResolved",     "Gelöst",      "Resolved",   "محلول",       "Решён",           "Çözüldü"),

    # ── Source labels ───────────────────────────────────────────────────────
    ("rfSourceWarningCheck", "Warnzeichen-Check",  "Warning Check",       "فحص التحذير",          "Проверка предупреждений", "Uyarı Kontrolü"),
    ("rfSourcePain",         "Schmerz",            "Pain",                "ألم",                  "Боль",                    "Ağrı"),
    ("rfSourceVitals",       "Vitalwerte",         "Vital Signs",         "العلامات الحيوية",     "Жизненные показатели",    "Yaşamsal Bulgular"),
    ("rfSourceObservation",  "Beobachtung",        "Observation",         "ملاحظة",               "Наблюдение",              "Gözlem"),
    ("rfSourceWound",        "Wunddaten",          "Wound Data",          "بيانات الجرح",         "Данные о ране",           "Yara Verileri"),
    ("rfSourceTimeline",     "Timeline-Aufgabe",   "Timeline Task",       "مهمة الجدول الزمني",   "Задача временной шкалы",  "Zaman Çizelgesi Görevi"),
    ("rfSourceManual",       "Manuell",            "Manual",              "يدوي",                 "Вручную",                 "Manuel"),
    ("rfSourceSymptomCheck", "Symptom-Check",      "Symptom Check",       "فحص الأعراض",          "Проверка симптомов",      "Belirti Kontrolü"),

    # ── Severity titles (used in status banner & level dots) ────────────────
    ("rfSeverityTitleGreen",  "Alles in Ordnung",      "All OK",                   "كل شيء على ما يرام",          "Всё в порядке",            "Her Şey Yolunda"),
    ("rfSeverityTitleYellow", "Leichte Auffälligkeit", "Slight Abnormality",        "اضطراب طفيف",                 "Лёгкое отклонение",        "Hafif Anormallik"),
    ("rfSeverityTitleOrange", "Erhöhtes Risiko",       "Elevated Risk",             "خطر مرتفع",                   "Повышенный риск",          "Yüksek Risk"),
    ("rfSeverityTitleRed",    "Sofort handeln",        "Act Now",                   "تصرف الآن",                   "Действуйте немедленно",    "Hemen Hareket Et"),

    # ── Severity descriptions ───────────────────────────────────────────────
    ("rfSeverityDescGreen",
     "Ihre Werte sind im Normalbereich. Weiter so!",
     "Your values are within normal range. Keep it up!",
     "قيمك ضمن النطاق الطبيعي. استمر!",
     "Ваши показатели в норме. Так держать!",
     "Değerleriniz normal aralıkta. Böyle devam edin!"),
    ("rfSeverityDescYellow",
     "Einzelne Werte leicht außerhalb des Normalbereichs. Bitte beobachten.",
     "Some values slightly outside normal range. Please monitor.",
     "بعض القيم خارج النطاق الطبيعي قليلاً. يرجى المراقبة.",
     "Некоторые показатели слегка за пределами нормы. Наблюдайте.",
     "Bazı değerler normalin biraz dışında. Lütfen izleyin."),
    ("rfSeverityDescOrange",
     "Mehrere Werte auffällig. Kontaktieren Sie Ihren Arzt zeitnah.",
     "Several values abnormal. Contact your doctor soon.",
     "قيم متعددة غير طبيعية. راجع طبيبك قريباً.",
     "Несколько показателей отклонены. Обратитесь к врачу скоро.",
     "Birkaç değer anormal. Yakında doktorunuzla iletişime geçin."),
    ("rfSeverityDescRed",
     "Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.",
     "Critical values detected. Immediate medical attention recommended.",
     "تم رصد قيم حرجة. يُوصى بالرعاية الطبية الفورية.",
     "Обнаружены критические показатели. Рекомендована немедленная медицинская помощь.",
     "Kritik değerler tespit edildi. Acil tıbbi yardım önerilir."),

    # ── Alert screen ────────────────────────────────────────────────────────
    ("rfProFeatureTitle",
     "Automatische Red-Flag-Erkennung ist ein Pro-Feature.",
     "Automatic red flag detection is a Pro feature.",
     "الكشف التلقائي عن الأعلام الحمراء ميزة Pro.",
     "Автоматическое обнаружение красных флажков — функция Pro.",
     "Otomatik kırmızı bayrak tespiti Pro özelliğidir."),
    ("rfProFeatureSubtitle",
     "Trage manuell Beschwerden ein oder upgrade auf Pro.",
     "Enter complaints manually or upgrade to Pro.",
     "أدخل الشكاوى يدوياً أو ترقَّ إلى Pro.",
     "Вводите жалобы вручную или обновитесь до Pro.",
     "Şikayetleri manuel olarak girin veya Pro'ya geçin."),
    ("rfProAutoDetect",
     "Mit Pro erkennt das System kritische Werte automatisch aus Schmerz, Vitaldaten & mehr.",
     "With Pro, the system automatically detects critical values from pain, vitals & more.",
     "مع Pro يكشف النظام تلقائياً عن القيم الحرجة من الألم والعلامات الحيوية والمزيد.",
     "С Pro система автоматически обнаруживает критические значения из боли, виталов и других данных.",
     "Pro ile sistem, ağrı, vital bulgular ve daha fazlasından kritik değerleri otomatik olarak algılar."),
    ("rfActiveWarnings",  "Aktive Warnungen",   "Active Warnings",   "التحذيرات النشطة",       "Активные предупреждения",  "Aktif Uyarılar"),
    ("rfWarningCheckSubtitle",
     "Schnellprüfung der wichtigsten Symptome – dauert nur 30 Sekunden.",
     "Quick check of the most important symptoms – takes only 30 seconds.",
     "فحص سريع لأهم الأعراض – يستغرق 30 ثانية فقط.",
     "Быстрая проверка важнейших симптомов – занимает всего 30 секунд.",
     "En önemli semptomların hızlı kontrolü – yalnızca 30 saniye sürer."),
    ("rfCheckStart",        "Check starten",          "Start Check",           "بدء الفحص",             "Начать проверку",          "Kontrolü Başlat"),
    ("rfEmergencyInstructions", "Notfallanweisungen", "Emergency Instructions", "تعليمات الطوارئ",       "Экстренные инструкции",    "Acil Talimatlar"),
    ("rfEmergencySubtitle",
     "Sofortmaßnahmen bei Atemnot, Bewusstlosigkeit oder starker Blutung.",
     "Immediate measures for shortness of breath, unconsciousness or severe bleeding.",
     "إجراءات فورية عند ضيق التنفس أو فقدان الوعي أو النزيف الشديد.",
     "Немедленные меры при одышке, потере сознания или сильном кровотечении.",
     "Nefes darlığı, bilinç kaybı veya ciddi kanama için acil önlemler."),
    ("rfNoActiveWarnings",
     "Keine aktiven Warnungen. Weiter so!",
     "No active warnings. Keep it up!",
     "لا توجد تحذيرات نشطة. استمر!",
     "Нет активных предупреждений. Продолжайте!",
     "Aktif uyarı yok. Böyle devam edin!"),
    ("rfEscalate",  "Eskalieren",  "Escalate",  "تصعيد",  "Эскалировать",  "Eskalatif"),
    # ── Emergency sheet ─────────────────────────────────────────────────────
    ("rfEmergencyFollowSteps",
     "Folgen Sie diesen Schritten der Reihe nach.",
     "Follow these steps in order.",
     "اتبع هذه الخطوات بالترتيب.",
     "Следуйте этим шагам по порядку.",
     "Bu adımları sırayla takip edin."),
    ("rfEmergencyStep1Title", "Ruhe bewahren",    "Stay calm",           "ابقَ هادئاً",     "Сохраняйте спокойствие",  "Sakin olun"),
    ("rfEmergencyStep1Desc",
     "Setzen oder legen Sie sich hin. Atmen Sie ruhig.",
     "Sit or lie down. Breathe calmly.",
     "اجلس أو استلقِ. تنفس بهدوء.",
     "Сядьте или лягте. Дышите спокойно.",
     "Oturun veya uzanın. Sakin nefes alın."),
    ("rfEmergencyStep2Title", "Symptome prüfen",  "Check symptoms",      "افحص الأعراض",   "Проверьте симптомы",      "Semptomları kontrol edin"),
    ("rfEmergencyStep2Desc",
     "Notieren Sie Ihre aktuellen Beschwerden und deren Stärke.",
     "Note your current complaints and their severity.",
     "دوِّن شكاواك الحالية وشدتها.",
     "Запишите текущие жалобы и их интенсивность.",
     "Mevcut şikayetlerinizi ve şiddetini not edin."),
    ("rfEmergencyStep3Title", "Arzt anrufen",     "Call doctor",         "اتصل بالطبيب",   "Позвоните врачу",         "Doktoru arayın"),
    ("rfEmergencyStep3Desc",
     "Rufen Sie Ihren Arzt oder die Klinik an und schildern Sie die Symptome.",
     "Call your doctor or clinic and describe the symptoms.",
     "اتصل بطبيبك أو العيادة وصف الأعراض.",
     "Позвоните своему врачу или в клинику и опишите симптомы.",
     "Doktorunuzu veya kliniği arayın ve semptomları anlatın."),
    ("rfEmergencyStep4Desc",
     "Bei Atemnot, Bewusstlosigkeit oder starker Blutung sofort 112 anrufen.",
     "For shortness of breath, unconsciousness or severe bleeding, immediately call 112.",
     "عند ضيق التنفس أو فقدان الوعي أو النزيف الشديد اتصل بـ 112 فوراً.",
     "При одышке, потере сознания или сильном кровотечении немедленно звоните 112.",
     "Nefes darlığı, bilinç kaybı veya ciddi kanama durumunda hemen 112'yi arayın."),

    # ── rfLevelBadge / rfActiveBadge ─────────────────────────────────────────
    # (placeholders handled separately below)

    # ── Warnings screen ──────────────────────────────────────────────────────
    ("warnTitle",       "Warnzeichen",   "Warning Signs",          "علامات التحذير",                  "Предупреждения",         "Uyarı İşaretleri"),
    ("warnEmergencyTitle",    "Notfall?",  "Emergency?",           "طوارئ؟",                           "Экстренный случай?",     "Acil Durum?"),
    ("warnEmergencySubtitle",
     "Bei lebensbedrohlichen Symptomen!",
     "For life-threatening symptoms!",
     "للأعراض المهددة للحياة!",
     "При угрожающих жизни симптомах!",
     "Hayatı tehdit eden semptomlar için!"),
    ("warnCall112",          "112 anrufen",   "Call 112",           "اتصل بـ 112",                     "Позвонить 112",          "112'yi Ara"),
    ("warnContactClinic",
     "Bei diesen Zeichen Klinik kontaktieren:",
     "Contact the clinic for these signs:",
     "اتصل بالعيادة عند ظهور هذه العلامات:",
     "Свяжитесь с клиникой при этих признаках:",
     "Bu işaretlerde kliniği arayın:"),
    ("warnCheckLabel",       "Schnell-Check:",  "Quick check:",       "فحص سريع:",                       "Быстрая проверка:",      "Hızlı kontrol:"),
    ("warnSaveCheck",        "Check speichern", "Save check",         "حفظ الفحص",                       "Сохранить проверку",     "Kontrolü kaydet"),

    # ── Warning items ─────────────────────────────────────────────────────────
    ("warnItemBleedingTitle",    "Starke Blutung",             "Severe Bleeding",             "نزيف شديد",                 "Сильное кровотечение",         "Şiddetli Kanama"),
    ("warnItemBleedingSubtitle", "Blut durchnässt Verband schnell", "Blood soaks through bandage quickly", "الدم يوشِّح الضماد بسرعة", "Кровь быстро пропитывает повязку", "Kan bandajı hızla ıslatıyor"),
    ("warnItemBleedingQ1", "Ist die Blutung aktiv und nicht stoppbar?",  "Is the bleeding active and cannot be stopped?",   "هل النزيف نشط ولا يمكن إيقافه؟",      "Кровотечение активное и не останавливается?",    "Kanama aktif ve durdurulamıyor mu?"),
    ("warnItemBleedingQ2", "Ist der Verband bereits komplett durchnässt?", "Is the bandage already completely soaked through?", "هل الضماد منقوع بالكامل بالفعل؟",  "Повязка уже полностью пропитана?",              "Bandaj zaten tamamen ıslandı mı?"),
    ("warnItemBleedingQ3", "Fühlen Sie sich schwindelig oder schwach?",  "Do you feel dizzy or weak?",                      "هل تشعر بالدوخة أو الضعف؟",           "Чувствуете головокружение или слабость?",       "Baş dönmesi veya halsizlik hissediyor musunuz?"),

    ("warnItemFeverTitle",    "Hohes Fieber",              "High Fever",                 "حمى شديدة",                    "Высокая температура",           "Yüksek Ateş"),
    ("warnItemFeverSubtitle", "Temperatur über 38,5 °C",   "Temperature above 38.5 °C",  "درجة الحرارة فوق 38.5 درجة مئوية", "Температура выше 38,5 °C",   "Sıcaklık 38,5 °C üzerinde"),
    ("warnItemFeverQ1", "Haben Sie Ihre Temperatur gemessen?",    "Have you taken your temperature?",       "هل قِست درجة حرارتك؟",           "Вы измерили температуру?",        "Sıcaklığınızı ölçtünüz mü?"),
    ("warnItemFeverQ2", "Liegt die Temperatur über 38,5 °C?",     "Is the temperature above 38.5 °C?",      "هل درجة الحرارة فوق 38.5 درجة مئوية؟", "Температура выше 38,5 °C?",  "Sıcaklık 38,5 °C üzerinde mi?"),
    ("warnItemFeverQ3", "Besteht Schüttelfrost?",                 "Do you have chills?",                    "هل تعاني قشعريرة؟",               "Есть озноб?",                     "Titreme var mı?"),

    ("warnItemBreathTitle",    "Atemnot",                       "Shortness of Breath",          "ضيق التنفس",                     "Одышка",                              "Nefes Darlığı"),
    ("warnItemBreathSubtitle", "Kurzatmigkeit oder Luftnot",    "Shortness of breath or air hunger", "قِصَر النفَس أو الشعور بضيق", "Нехватка воздуха или затруднённое дыхание", "Nefes kısalığı veya hava açlığı"),
    ("warnItemBreathQ1", "Tritt die Atemnot in Ruhe auf?",      "Does the shortness of breath occur at rest?", "هل يحدث ضيق التنفس أثناء الراحة؟", "Одышка возникает в покое?",         "Nefes darlığı dinlenirken oluyor mu?"),
    ("warnItemBreathQ2", "Verschlimmert sich die Atemnot?",      "Is the shortness of breath getting worse?",   "هل يزداد ضيق التنفس سوءاً؟",      "Одышка усиливается?",               "Nefes darlığı kötüleşiyor mu?"),
    ("warnItemBreathQ3", "Haben Sie Schmerzen beim Atmen?",      "Do you have pain when breathing?",            "هل تشعر بألم عند التنفس؟",         "Есть боль при дыхании?",            "Nefes alırken ağrı var mı?"),

    ("warnItemPainTitle",    "Starke Schmerzen",                        "Severe Pain",                       "آلام شديدة",                   "Сильная боль",                           "Şiddetli Ağrı"),
    ("warnItemPainSubtitle", "Plötzlich zunehmend, nicht kontrollierbar", "Suddenly increasing, uncontrollable", "متزايد فجأة وغير قابل للسيطرة", "Внезапно усиливающаяся, неконтролируемая", "Aniden artan, kontrol edilemeyen"),
    ("warnItemPainQ1", "Sind die Schmerzen deutlich stärker als gewohnt?", "Is the pain significantly stronger than usual?",  "هل الألم أشد بكثير من المعتاد؟",            "Боль значительно сильнее, чем обычно?",         "Ağrı alışılmıştan çok daha şiddetli mi?"),
    ("warnItemPainQ2", "Helfen Ihre üblichen Schmerzmittel nicht mehr?",   "Do your usual pain medications no longer help?",  "هل مسكِّنات الألم المعتادة لم تعد تساعد؟",  "Обычные обезболивающие больше не помогают?",    "Olağan ağrı kesicileriniz artık yardımcı olmuyor mu?"),
    ("warnItemPainQ3", "Ist der Schmerzbereich geschwollen oder heiß?",    "Is the painful area swollen or hot?",             "هل منطقة الألم منتفخة أو ساخنة؟",           "Область боли опухла или горячая?",              "Ağrı bölgesi şişmiş veya sıcak mı?"),

    ("warnItemRednessTitle",    "Zunehmende Rötung / Schwellung", "Increasing Redness / Swelling", "احمرار / تورم متزايد",           "Нарастающее покраснение / отёк",     "Artan Kızarıklık / Şişlik"),
    ("warnItemRednessSubtitle", "Wundbereich wirkt entzündet",   "Wound area appears inflamed",   "منطقة الجرح تبدو ملتهبة",        "Область раны выглядит воспалённой",  "Yara bölgesi iltihaplanmış görünüyor"),
    ("warnItemRednessQ1", "Breitet sich die Rötung aus?",         "Is the redness spreading?",     "هل ينتشر الاحمرار؟",             "Покраснение распространяется?",      "Kızarıklık yayılıyor mu?"),
    ("warnItemRednessQ2", "Ist die Stelle warm oder heiß?",       "Is the area warm or hot?",      "هل المنطقة دافئة أو ساخنة؟",     "Место тёплое или горячее?",          "Bölge ılık veya sıcak mı?"),
    ("warnItemRednessQ3", "Tritt Eiter oder Sekret aus?",         "Is there pus or discharge?",    "هل يخرج قيح أو إفراز؟",          "Есть гной или выделения?",           "İrinli akıntı var mı?"),

    ("warnItemSmellTitle",    "Übel riechendes Sekret",            "Foul-smelling Discharge",         "إفراز كريه الرائحة",             "Зловонные выделения",               "Kötü Kokulu Akıntı"),
    ("warnItemSmellSubtitle", "Auffällige Absonderung aus der Wunde", "Unusual discharge from the wound", "إفراز غير عادي من الجرح",      "Необычные выделения из раны",       "Yaradan olağandışı akıntı"),
    ("warnItemSmellQ1", "Hat das Sekret eine ungewöhnliche Farbe?",   "Does the discharge have an unusual color?",    "هل للإفراز لون غير عادي؟",    "Выделения имеют необычный цвет?",    "Akıntının rengi olağandışı mı?"),
    ("warnItemSmellQ2", "Riecht die Wunde deutlich unangenehm?",       "Does the wound smell distinctly unpleasant?",  "هل ينبعث من الجرح رائحة كريهة واضحة؟", "От раны отчётливо неприятный запах?", "Yaradan belirgin şekilde hoş olmayan koku geliyor mu?"),
    ("warnItemSmellQ3", "Hat sich die Menge des Sekrets erhöht?",      "Has the amount of discharge increased?",       "هل زادت كمية الإفراز؟",       "Объём выделений увеличился?",        "Akıntı miktarı arttı mı?"),

    # ── Patient tab ───────────────────────────────────────────────────────────
    ("rfNoFlags",  "Keine Red Flags",  "No Red Flags",  "لا توجد أعلام حمراء",  "Нет красных флажков",  "Kırmızı Bayrak Yok"),
]

# Keys with placeholders – add separately
PARAM_KEYS = [
    # (key, de, en, ar, ru, tr, placeholders_dict)
    (
        "rfLevelBadge",
        "Stufe: {level}", "Level: {level}", "المستوى: {level}", "Уровень: {level}", "Düzey: {level}",
        {"level": {"type": "String"}},
    ),
    (
        "rfActiveBadge",
        "{count} aktiv", "{count} active", "{count} نشط", "{count} активных", "{count} aktif",
        {"count": {"type": "int"}},
    ),
    (
        "warnLastCheck",
        "Letzter Check: {label} · {date}",
        "Last check: {label} · {date}",
        "آخر فحص: {label} · {date}",
        "Последняя проверка: {label} · {date}",
        "Son kontrol: {label} · {date}",
        {"label": {"type": "String"}, "date": {"type": "String"}},
    ),
    (
        "rfActiveCount",
        "Aktiv ({count})", "Active ({count})", "نشط ({count})", "Активных ({count})", "Aktif ({count})",
        {"count": {"type": "int"}},
    ),
    (
        "rfResolvedCount",
        "Verlauf ({count})", "History ({count})", "السجل ({count})", "История ({count})", "Geçmiş ({count})",
        {"count": {"type": "int"}},
    ),
]

LOCALES = ["de", "en", "ar", "ru", "tr"]


def load_arb(locale: str) -> tuple[dict, str]:
    path = L10N / f"app_{locale}.arb"
    text = path.read_text(encoding="utf-8")
    data = json.loads(text)
    return data, text


def save_arb(locale: str, data: dict, original_text: str) -> None:
    path = L10N / f"app_{locale}.arb"
    # Insert new keys before the closing brace
    new_entries = ""
    for key, value in data.items():
        if key not in json.loads(original_text):
            if isinstance(value, dict):
                new_entries += f',\n  "@{key[1:]}": {json.dumps(value, ensure_ascii=False)}'
            else:
                new_entries += f',\n  "{key}": {json.dumps(value, ensure_ascii=False)}'
    # Rebuild properly by writing sorted JSON minus the closing brace then appending
    # Actually just use json.dumps to rewrite cleanly
    output = json.dumps(data, ensure_ascii=False, indent=2)
    path.write_text(output + "\n", encoding="utf-8")


def insert_keys(arb_path: pathlib.Path, new_keys: dict) -> None:
    """Insert new_keys (key→value) before the final closing brace."""
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

    # Write back with same indent style
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
            key = row[0]
            value = row[idx]
            new_entries[key] = value

        # Param keys
        for row in PARAM_KEYS:
            key = row[0]
            value = row[idx]
            placeholders = row[6]
            new_entries[key] = value
            meta: dict = {"placeholders": {}}
            for ph_name, ph_meta in placeholders.items():
                meta["placeholders"][ph_name] = ph_meta
            new_entries[f"@{key}"] = meta

        insert_keys(path, new_entries)

    print("Done.")


if __name__ == "__main__":
    main()
