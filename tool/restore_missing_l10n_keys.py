#!/usr/bin/env python3
"""
Restores l10n keys that were present in previous sessions but lost when
app_de.arb was restored from git (which was before the presentation-layer
l10n batch). Adds keys to all 5 locales (de, en, ar, ru, tr) if not present.
"""
import json, sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
L10N = ROOT / "lib" / "l10n"

# Keys to add per locale: (key, de_value, en_value, ar_value, ru_value, tr_value)
# Only the template (de) is strictly required; others fall back to de if missing.
KEYS = [
    # Key                          DE                                      EN                                         AR                                      RU                                           TR
    ("notfallInfoTeilen",          "Notfall-Info teilen",                  "Share Emergency Info",                    "مشاركة معلومات الطوارئ",               "Поделиться экстренной информацией",         "Acil Bilgiyi Paylaş"),
    ("notruf112",                  "Notruf 112",                           "Emergency Call 112",                      "الطوارئ 112",                          "Скорая помощь 112",                         "Acil 112"),
    ("fehlerSpeichernErneut",      "Fehler beim Speichern. Erneut versuchen.", "Error saving. Please try again.",    "خطأ في الحفظ. حاول مجدداً.",           "Ошибка сохранения. Попробуйте снова.",      "Kaydetme hatası. Tekrar deneyin."),
    ("fehlerBeimSpeichern",        "Fehler beim Speichern.",               "Error saving.",                           "خطأ في الحفظ.",                        "Ошибка сохранения.",                        "Kaydetme hatası."),
    ("woWirstDuBehandelt",         "Wo wirst du behandelt?",               "Where will you be treated?",              "أين ستتلقى العلاج؟",                   "Где вы будете проходить лечение?",          "Nerede tedavi göreceksiniz?"),
    ("fastGeschafft",              "Fast geschafft!",                      "Almost done!",                            "اقتربت من الانتهاء!",                  "Почти готово!",                             "Neredeyse bitti!"),
    ("opClinic",                   "Klinik",                               "Clinic",                                  "العيادة",                              "Клиника",                                   "Klinik"),
    ("deinGesundheitsprofil",      "Dein Gesundheitsprofil",               "Your Health Profile",                     "ملفك الصحي",                           "Ваш профиль здоровья",                      "Sağlık Profiliniz"),
    ("aktuelleMedikamente",        "Aktuelle Medikamente",                 "Current Medications",                     "الأدوية الحالية",                      "Текущие медикаменты",                       "Güncel İlaçlar"),
    ("oPTypEingeben",              "OP-Typ eingeben",                      "Enter operation type",                    "أدخل نوع العملية",                     "Введите тип операции",                      "Ameliyat türünü girin"),
    ("mitKrankenhausaufenthalt",   "Mit Krankenhausaufenthalt",            "With hospital stay",                      "مع إقامة في المستشفى",                 "С пребыванием в больнице",                  "Hastane konaklaması ile"),
    ("profilGespeichertKurz",      "Profil gespeichert",                   "Profile saved",                           "تم حفظ الملف الشخصي",                  "Профиль сохранён",                          "Profil kaydedildi"),
    ("koerperwerteUndGesundheit",  "Körperwerte & Gesundheit",             "Body Values & Health",                    "قيم الجسم والصحة",                     "Показатели тела и здоровье",                "Vücut Değerleri ve Sağlık"),
    ("notfallkontaktUndNotfallInfo","Notfallkontakt & Notfall-Info",       "Emergency Contact & Info",                "جهة الاتصال في حالات الطوارئ والمعلومات","Экстренный контакт и информация",          "Acil Kişi ve Bilgiler"),
    ("bezeichnungEingeben",        "Bezeichnung eingeben",                 "Enter label",                             "أدخل التسمية",                         "Введите название",                          "Etiket girin"),
    ("pINAktivieren",              "PIN aktivieren",                       "Activate PIN",                            "تفعيل رمز PIN",                        "Активировать PIN",                          "PIN'i etkinleştir"),
    ("n4StelligerZugangsPIN",      "4-stelliger Zugangs-PIN",              "4-digit access PIN",                      "رمز وصول مكون من 4 أرقام",             "4-значный PIN доступа",                     "4 haneli erişim PIN'i"),
    ("proEntdecken",               "Pro entdecken",                        "Discover Pro",                            "اكتشف Pro",                            "Открыть Pro",                               "Pro'yu keşfet"),
    ("aktuellesPasswort",          "Aktuelles Passwort",                   "Current Password",                        "كلمة المرور الحالية",                  "Текущий пароль",                            "Mevcut Şifre"),
    ("passwortSpeichern",          "Passwort speichern",                   "Save Password",                           "حفظ كلمة المرور",                      "Сохранить пароль",                          "Şifreyi kaydet"),
]

# Parameterized keys need placeholder metadata
PARAMETERIZED = {
    "labelHinzufuegen": {
        "de": "{label} hinzufügen",
        "en": "Add {label}",
        "ar": "أضف {label}",
        "ru": "Добавить {label}",
        "tr": "{label} ekle",
        "meta": {"placeholders": {"label": {"type": "String"}}},
    },
}

LOCALE_MAP = {"de": 0, "en": 1, "ar": 2, "ru": 3, "tr": 4}


def add_keys_to_arb(locale: str, path: Path):
    text = path.read_text(encoding="utf-8")
    data = json.loads(text)

    added = 0

    # Simple keys
    for entry in KEYS:
        key = entry[0]
        value = entry[LOCALE_MAP[locale] + 1]
        if key not in data:
            data[key] = value
            added += 1

    # Parameterized keys
    for key, info in PARAMETERIZED.items():
        if key not in data:
            data[key] = info[locale]
            data[f"@{key}"] = info["meta"]
            added += 1

    if added > 0:
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"  [{locale}] +{added} keys added")
    else:
        print(f"  [{locale}] all keys already present")


def main():
    for locale in ["de", "en", "ar", "ru", "tr"]:
        arb = L10N / f"app_{locale}.arb"
        if not arb.exists():
            print(f"  [{locale}] MISSING FILE – skipping")
            continue
        add_keys_to_arb(locale, arb)


if __name__ == "__main__":
    main()
