#!/usr/bin/env python3
"""Add Notfallinfo (Emergency Info) l10n keys to all 5 ARB files."""

import json
import pathlib

ROOT = pathlib.Path(__file__).parent.parent
L10N = ROOT / "lib" / "l10n"

# ---------------------------------------------------------------------------
# New keys: (key, de, en, ar, ru, tr)
# ---------------------------------------------------------------------------
KEYS = [
    # ── Common field labels ────────────────────────────────────────────────
    ("nichtHinterlegt",
     "Nicht hinterlegt",
     "Not provided",
     "غير مُدخَل",
     "Не указано",
     "Belirtilmedi"),
    ("fieldName",        "Name",           "Name",           "الاسم",          "Имя",               "Ad"),
    ("fieldPhone",       "Telefonnummer",  "Phone number",   "رقم الهاتف",    "Номер телефона",    "Telefon numarası"),
    ("fieldWeight",      "Gewicht",        "Weight",         "الوزن",          "Вес",               "Kilo"),
    ("fieldSmoker",      "Raucher",        "Smoker",         "مدخِّن",          "Курильщик",         "Sigara içen"),
    ("fieldOpType",      "OP-Art",         "Surgery type",   "نوع العملية",    "Вид операции",      "Ameliyat türü"),
    ("fieldOpDate",      "OP-Datum",       "Surgery date",   "تاريخ العملية",  "Дата операции",     "Ameliyat tarihi"),
    ("fieldOpModus",     "OP-Modus",       "Surgery mode",   "وضع العملية",    "Режим операции",    "Ameliyat modu"),
    ("fieldHospitalPhone", "KH-Telefon",   "Hospital phone", "هاتف المستشفى",  "Телефон больницы",  "Hastane telefonu"),
    ("fieldDoctorPhone", "Arzt-Telefon",   "Doctor's phone", "هاتف الطبيب",    "Телефон врача",     "Doktor telefonu"),

    # ── Emergency info labels (shared across screen, share text, profile) ──
    ("eiBloodType",   "Blutgruppe",      "Blood type",     "فصيلة الدم",      "Группа крови",      "Kan grubu"),
    ("eiAllergies",   "Allergien",       "Allergies",      "الحساسيات",       "Аллергии",          "Alerjiler"),
    ("eiInsurance",   "Versicherung",    "Insurance",      "التأمين",         "Страховка",         "Sigorta"),
    ("eiHospital",    "Krankenhaus",     "Hospital",       "المستشفى",        "Больница",          "Hastane"),
    ("eiConditions",  "Vorerkrankungen", "Pre-existing conditions", "أمراض سابقة", "Предшествующие заболевания", "Önceki hastalıklar"),
    ("eiMedications", "Medikamente",     "Medications",    "الأدوية",         "Лекарства",         "İlaçlar"),

    # ── Emergency screen specific ──────────────────────────────────────────
    ("eiOfflineBanner",
     "Keine Verbindung \u2013 bitte stelle sicher, dass du die Notfallinfos bei einer Gelegenheit mit Internet l\u00e4dst.",
     "No connection \u2013 please make sure to load the emergency info when you have internet access.",
     "\u0644\u0627 \u064a\u0648\u062c\u062f \u0627\u062a\u0635\u0627\u0644 \u2013 \u064a\u064f\u0631\u062c\u0649 \u062a\u062d\u0645\u064a\u0644 \u0645\u0639\u0644\u0648\u0645\u0627\u062a \u0627\u0644\u0637\u0648\u0627\u0631\u0626 \u0639\u0646\u062f \u062a\u0648\u0641\u0631 \u0627\u0644\u0625\u0646\u062a\u0631\u0646\u062a.",
     "\u041d\u0435\u0442 \u0441\u043e\u0435\u0434\u0438\u043d\u0435\u043d\u0438\u044f \u2013 \u043f\u043e\u0436\u0430\u043b\u0443\u0439\u0441\u0442\u0430, \u0437\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u044d\u043a\u0441\u0442\u0440\u0435\u043d\u043d\u0443\u044e \u0438\u043d\u0444\u043e\u0440\u043c\u0430\u0446\u0438\u044e \u043f\u0440\u0438 \u043d\u0430\u043b\u0438\u0447\u0438\u0438 \u0438\u043d\u0442\u0435\u0440\u043d\u0435\u0442\u0430.",
     "\u0411\u0430\u011flant\u0131 yok \u2013 l\u00fctfen internet ba\u011flant\u0131s\u0131 oldu\u011funda acil bilgilerini y\u00fckledi\u011finden emin ol."),
    ("eiNoDataHint",
     "Keine Notfalldaten hinterlegt.\nTrage deine Daten im Profil ein.",
     "No emergency data stored.\nEnter your data in your profile.",
     "\u0644\u0645 \u064a\u062a\u0645 \u062a\u062e\u0632\u064a\u0646 \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0637\u0648\u0627\u0631\u0626.\n\u0623\u062f\u062e\u0644 \u0628\u064a\u0627\u0646\u0627\u062a\u0643 \u0641\u064a \u0645\u0644\u0641\u0643 \u0627\u0644\u0634\u062e\u0635\u064a.",
     "\u0414\u0430\u043d\u043d\u044b\u0435 \u043e \u044d\u043a\u0441\u0442\u0440\u0435\u043d\u043d\u043e\u0439 \u0441\u0438\u0442\u0443\u0430\u0446\u0438\u0438 \u043d\u0435 \u0441\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u044b.\n\u0412\u043d\u0435\u0441\u0438\u0442\u0435 \u0434\u0430\u043d\u043d\u044b\u0435 \u0432 \u0441\u0432\u043e\u0451\u043c \u043f\u0440\u043e\u0444\u0438\u043b\u0435.",
     "Acil durum verisi kaydedilmedi.\nVerilerini profil\u00fcne gir."),
    ("eiOpenProfile",
     "Profil \u00f6ffnen",
     "Open profile",
     "\u0641\u062a\u062d \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a",
     "\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u043f\u0440\u043e\u0444\u0438\u043b\u044c",
     "Profili a\u00e7"),

    # ── Share text static labels ───────────────────────────────────────────
    ("eiShareHeader",
     "🆘 NOTFALL-INFORMATIONEN",
     "🆘 EMERGENCY INFORMATION",
     "🆘 معلومات الطوارئ",
     "🆘 ЭКСТРЕННАЯ ИНФОРМАЦИЯ",
     "🆘 ACİL DURUM BİLGİLERİ"),
    ("eiShareEmergency",
     "Notruf: 112",
     "Emergency: 112",
     "\u0637\u0648\u0627\u0631\u0626: 112",
     "\u0421\u043a\u043e\u0440\u0430\u044f \u043f\u043e\u043c\u043e\u0449\u044c: 112",
     "Acil: 112"),

    # ── Onboarding summary page specific ──────────────────────────────────
    ("eiSummaryNameHint",   "z.B. Max Mustermann",  "e.g. John Smith",       "\u0645\u062b\u0627\u0644: \u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f",   "\u043d\u0430\u043f\u0440.: \u0418\u0432\u0430\u043d \u0418\u0432\u0430\u043d\u043e\u0432",  "\u00f6rn. Ahmet Y\u0131lmaz"),
    ("eiSummaryPhoneHint",  "z.B. +49 170 1234567", "e.g. +1 555 1234567",   "\u0645\u062b\u0627\u0644: +966 50 1234567",  "\u043d\u0430\u043f\u0440.: +7 900 1234567",   "\u00f6rn. +90 555 1234567"),
    ("eiSummaryOpType",     "OP-Typ",               "Surgery Type",          "\u0646\u0648\u0639 \u0627\u0644\u0639\u0645\u0644\u064a\u0629",   "\u0422\u0438\u043f \u043e\u043f\u0435\u0440\u0430\u0446\u0438\u0438",    "Ameliyat T\u00fcr\u00fc"),
    ("eiSummaryOpDateUnknown",
     "Noch unbekannt",
     "Not yet known",
     "\u063a\u064a\u0631 \u0645\u0639\u0644\u0648\u0645 \u0628\u0639\u062f",
     "\u0415\u0449\u0451 \u043d\u0435 \u0438\u0437\u0432\u0435\u0441\u0442\u043d\u043e",
     "Hen\u00fcz bilinmiyor"),
    ("eiSummaryTreatment",  "Behandlung",           "Treatment",             "\u0627\u0644\u0639\u0644\u0627\u062c",     "\u041b\u0435\u0447\u0435\u043d\u0438\u0435",    "Tedavi"),
    ("eiSummaryAmbulant",   "Ambulant",             "Outpatient",            "\u0639\u0644\u0627\u062c \u062e\u0627\u0631\u062c\u064a",  "\u0410\u043c\u0431\u0443\u043b\u0430\u0442\u043e\u0440\u043d\u043e",  "Ayakta tedavi"),
]

# Keys with placeholders
PARAM_KEYS = [
    (
        "eiShareBloodType",
        "Blutgruppe: {value}", "Blood type: {value}",
        "\u0641\u0635\u064a\u0644\u0629 \u0627\u0644\u062f\u0645: {value}",
        "\u0413\u0440\u0443\u043f\u043f\u0430 \u043a\u0440\u043e\u0432\u0438: {value}",
        "Kan grubu: {value}",
        {"value": {"type": "String"}},
    ),
    (
        "eiShareAllergies",
        "Allergien: {value}", "Allergies: {value}",
        "\u0627\u0644\u062d\u0633\u0627\u0633\u064a\u0627\u062a: {value}",
        "\u0410\u043b\u043b\u0435\u0440\u0433\u0438\u0438: {value}",
        "Alerjiler: {value}",
        {"value": {"type": "String"}},
    ),
    (
        "eiShareContact",
        "Notfallkontakt: {name}", "Emergency contact: {name}",
        "\u062c\u0647\u0629 \u0627\u0644\u0627\u062a\u0635\u0627\u0644 \u0641\u064a \u062d\u0627\u0644\u0627\u062a \u0627\u0644\u0637\u0648\u0627\u0631\u0626: {name}",
        "\u041a\u043e\u043d\u0442\u0430\u043a\u0442 \u043f\u0440\u0438 \u0447\u0440\u0435\u0437\u0432\u044b\u0447\u0430\u0439\u043d\u043e\u0439 \u0441\u0438\u0442\u0443\u0430\u0446\u0438\u0438: {name}",
        "Acil iletişim: {name}",
        {"name": {"type": "String"}},
    ),
    (
        "eiSharePhone",
        "Tel: {value}", "Tel: {value}",
        "\u0647\u0627\u062a\u0641: {value}",
        "\u0422\u0435\u043b.: {value}",
        "Tel: {value}",
        {"value": {"type": "String"}},
    ),
    (
        "eiShareHospital",
        "Krankenhaus: {name}", "Hospital: {name}",
        "\u0627\u0644\u0645\u0633\u062a\u0634\u0641\u0649: {name}",
        "\u0411\u043e\u043b\u044c\u043d\u0438\u0446\u0430: {name}",
        "Hastane: {name}",
        {"name": {"type": "String"}},
    ),
    (
        "eiShareHospitalPhone",
        "KH-Tel: {value}", "Hospital tel: {value}",
        "\u0647\u0627\u062a\u0641 \u0627\u0644\u0645\u0633\u062a\u0634\u0641\u0649: {value}",
        "\u0422\u0435\u043b. \u0431\u043e\u043b\u044c\u043d\u0438\u0446\u044b: {value}",
        "Hastane tel: {value}",
        {"value": {"type": "String"}},
    ),
    (
        "eiShareDoctor",
        "Arzt: {name}", "Doctor: {name}",
        "\u0627\u0644\u0637\u0628\u064a\u0628: {name}",
        "\u0412\u0440\u0430\u0447: {name}",
        "Doktor: {name}",
        {"name": {"type": "String"}},
    ),
    (
        "eiShareDoctorPhone",
        "Arzt-Tel: {value}", "Doctor tel: {value}",
        "\u0647\u0627\u062a\u0641 \u0627\u0644\u0637\u0628\u064a\u0628: {value}",
        "\u0422\u0435\u043b. \u0432\u0440\u0430\u0447\u0430: {value}",
        "Doktor tel: {value}",
        {"value": {"type": "String"}},
    ),
    (
        "eiShareInsurance",
        "Versicherung: {value}", "Insurance: {value}",
        "\u0627\u0644\u062a\u0623\u0645\u064a\u0646: {value}",
        "\u0421\u0442\u0440\u0430\u0445\u043e\u0432\u043a\u0430: {value}",
        "Sigorta: {value}",
        {"value": {"type": "String"}},
    ),
]

LOCALES = ["de", "en", "ar", "ru", "tr"]


def insert_keys(arb_path: pathlib.Path, new_keys: dict) -> None:
    text = arb_path.read_text(encoding="utf-8")
    data = json.loads(text)
    added = 0
    for k, v in new_keys.items():
        if k not in data:
            data[k] = v
            added += 1
    if added == 0:
        print(f"  [{arb_path.name}] nothing to add")
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
        for row in KEYS:
            new_entries[row[0]] = row[idx]
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
