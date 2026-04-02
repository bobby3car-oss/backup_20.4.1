"""Append Phase-2 RTS l10n keys to all five ARB files."""
import json
import pathlib

L10N = pathlib.Path("/Users/jan/projects/operationsbegleiter_v3/lib/l10n")

NEW_KEYS = {
    "app_de.arb": {
        "rtsSportTypeTitle": "Sportart",
        "rtsSportTypeDesc": "Welchen Sport möchtest du wieder ausüben?",
        "rtsSportRunning": "Laufen",
        "rtsSportSoccer": "Fußball / Teamsport",
        "rtsSportStrength": "Kraftsport",
        "rtsSportCycling": "Radfahren",
        "rtsSportSwimming": "Schwimmen",
        "rtsSportMartialArts": "Kampfsport",
        "rtsSportOther": "Sonstige",
        "rtsTestHopTitle": "Sprungkraft-Seitenvergleich (Hop-Test)",
        "rtsTestHopDesc": "Springe auf dem betroffenen Bein so weit wie möglich vorwärts und messe die Weite. Wiederhole den Test auf der gesunden Seite.",
        "rtsTestHopHint": "Führe 3 Versuche durch und nimm die beste Weite. Ein LSI ≥ 90 % gilt als optimale Freigabeschwelle.",
        "rtsHopAffected": "Betroffene Seite (cm)",
        "rtsHopHealthy": "Gesunde Seite (cm)",
        "@rtsHopDetailValue": {"placeholders": {"affected": {"type": "String"}, "healthy": {"type": "String"}, "percent": {"type": "String"}}},
        "rtsHopDetailValue": "Betroffen: {affected} cm / Gesund: {healthy} cm → LSI: {percent}",
        "rtsTestTugTitle": "Timed Up and Go (TUG)",
        "rtsTestTugDesc": "Stehe von einem Stuhl auf, gehe 3 Meter geradeaus, kehre um und setze dich wieder. Miss die Gesamtzeit.",
        "rtsTestTugHint": "Verwende den Stoppuhr-Button oder trage die Zeit manuell ein. Unter 10 Sekunden gilt als sehr gut.",
        "@rtsTugDetailValue": {"placeholders": {"seconds": {"type": "String"}}},
        "rtsTugDetailValue": "{seconds} Sekunden",
        "rtsTimerStart": "Stoppuhr starten",
        "rtsTimerStop": "Stopp",
        "rtsTimerReset": "Zurücksetzen",
        "rtsTimerRestart": "Neu starten",
        "rtsTimerOrManual": "Oder manuell eingeben:",
        "rtsTimerManualLabel": "Zeit in Sekunden",
        "rtsScoreTrend": "Score-Verlauf",
    },
    "app_en.arb": {
        "rtsSportTypeTitle": "Sport Type",
        "rtsSportTypeDesc": "Which sport do you want to return to?",
        "rtsSportRunning": "Running",
        "rtsSportSoccer": "Soccer / Team Sports",
        "rtsSportStrength": "Strength Training",
        "rtsSportCycling": "Cycling",
        "rtsSportSwimming": "Swimming",
        "rtsSportMartialArts": "Martial Arts",
        "rtsSportOther": "Other",
        "rtsTestHopTitle": "Single-Leg Hop Test",
        "rtsTestHopDesc": "Hop as far as possible on your affected leg and measure the distance. Repeat on the healthy side.",
        "rtsTestHopHint": "Perform 3 attempts and record the best jump. An LSI ≥ 90% is the optimal return-to-sport threshold.",
        "rtsHopAffected": "Affected side (cm)",
        "rtsHopHealthy": "Healthy side (cm)",
        "@rtsHopDetailValue": {"placeholders": {"affected": {"type": "String"}, "healthy": {"type": "String"}, "percent": {"type": "String"}}},
        "rtsHopDetailValue": "Affected: {affected} cm / Healthy: {healthy} cm → LSI: {percent}",
        "rtsTestTugTitle": "Timed Up and Go (TUG)",
        "rtsTestTugDesc": "Stand up from a chair, walk 3 meters, turn around and sit back down. Measure the total time.",
        "rtsTestTugHint": "Use the stopwatch button or enter the time manually. Below 10 seconds is considered excellent.",
        "@rtsTugDetailValue": {"placeholders": {"seconds": {"type": "String"}}},
        "rtsTugDetailValue": "{seconds} seconds",
        "rtsTimerStart": "Start Stopwatch",
        "rtsTimerStop": "Stop",
        "rtsTimerReset": "Reset",
        "rtsTimerRestart": "Restart",
        "rtsTimerOrManual": "Or enter manually:",
        "rtsTimerManualLabel": "Time in seconds",
        "rtsScoreTrend": "Score Trend",
    },
    "app_tr.arb": {
        "rtsSportTypeTitle": "Spor Türü",
        "rtsSportTypeDesc": "Hangi spora geri dönmek istiyorsunuz?",
        "rtsSportRunning": "Koşu",
        "rtsSportSoccer": "Futbol / Takım Sporları",
        "rtsSportStrength": "Güç Antrenmanı",
        "rtsSportCycling": "Bisiklet",
        "rtsSportSwimming": "Yüzme",
        "rtsSportMartialArts": "Dövüş Sanatları",
        "rtsSportOther": "Diğer",
        "rtsTestHopTitle": "Tek Bacak Sıçrama Testi",
        "rtsTestHopDesc": "Etkilenen bacakla mümkün olduğunca ileri sıçrayın ve mesafeyi ölçün. Sağlıklı tarafla tekrarlayın.",
        "rtsTestHopHint": "3 deneme yapın ve en iyi sıçramayı kaydedin. LSI ≥ %90 spora dönüş için optimal eşik değeridir.",
        "rtsHopAffected": "Etkilenen taraf (cm)",
        "rtsHopHealthy": "Sağlıklı taraf (cm)",
        "@rtsHopDetailValue": {"placeholders": {"affected": {"type": "String"}, "healthy": {"type": "String"}, "percent": {"type": "String"}}},
        "rtsHopDetailValue": "Etkilenen: {affected} cm / Sağlıklı: {healthy} cm → LSI: {percent}",
        "rtsTestTugTitle": "Kalk ve Yürü Testi (TUG)",
        "rtsTestTugDesc": "Bir sandalyeden kalkın, 3 metre yürüyün, geri dönün ve oturun. Toplam süreyi ölçün.",
        "rtsTestTugHint": "Kronometre düğmesini kullanın veya süreyi manuel girin. 10 saniyenin altı mükemmel kabul edilir.",
        "@rtsTugDetailValue": {"placeholders": {"seconds": {"type": "String"}}},
        "rtsTugDetailValue": "{seconds} saniye",
        "rtsTimerStart": "Kronometre Başlat",
        "rtsTimerStop": "Durdur",
        "rtsTimerReset": "Sıfırla",
        "rtsTimerRestart": "Yeniden Başlat",
        "rtsTimerOrManual": "Veya manuel girin:",
        "rtsTimerManualLabel": "Saniye cinsinden süre",
        "rtsScoreTrend": "Puan Trendi",
    },
    "app_ar.arb": {
        "rtsSportTypeTitle": "نوع الرياضة",
        "rtsSportTypeDesc": "ما هي الرياضة التي تريد العودة إليها؟",
        "rtsSportRunning": "الجري",
        "rtsSportSoccer": "كرة القدم / الرياضات الجماعية",
        "rtsSportStrength": "تدريب القوة",
        "rtsSportCycling": "ركوب الدراجات",
        "rtsSportSwimming": "السباحة",
        "rtsSportMartialArts": "فنون القتال",
        "rtsSportOther": "أخرى",
        "rtsTestHopTitle": "اختبار القفز بساق واحدة",
        "rtsTestHopDesc": "اقفز بأقصى بُعد ممكن على الساق المصابة وقِس المسافة. كرر على الجانب السليم.",
        "rtsTestHopHint": "قم بـ 3 محاولات وسجّل أفضل قفزة. LSI ≥ 90٪ هو الحد الأمثل للعودة إلى الرياضة.",
        "rtsHopAffected": "الجانب المصاب (سم)",
        "rtsHopHealthy": "الجانب السليم (سم)",
        "@rtsHopDetailValue": {"placeholders": {"affected": {"type": "String"}, "healthy": {"type": "String"}, "percent": {"type": "String"}}},
        "rtsHopDetailValue": "المصاب: {affected} سم / السليم: {healthy} سم → LSI: {percent}",
        "rtsTestTugTitle": "اختبار النهوض والمشي (TUG)",
        "rtsTestTugDesc": "انهض من كرسي، امشِ 3 أمتار، ارجع واجلس. قِس الوقت الإجمالي.",
        "rtsTestTugHint": "استخدم زر المؤقت أو أدخل الوقت يدويًا. أقل من 10 ثوانٍ يُعتبر ممتازًا.",
        "@rtsTugDetailValue": {"placeholders": {"seconds": {"type": "String"}}},
        "rtsTugDetailValue": "{seconds} ثانية",
        "rtsTimerStart": "بدء المؤقت",
        "rtsTimerStop": "إيقاف",
        "rtsTimerReset": "إعادة تعيين",
        "rtsTimerRestart": "إعادة البدء",
        "rtsTimerOrManual": "أو أدخل يدويًا:",
        "rtsTimerManualLabel": "الوقت بالثواني",
        "rtsScoreTrend": "اتجاه النقاط",
    },
    "app_ru.arb": {
        "rtsSportTypeTitle": "Вид спорта",
        "rtsSportTypeDesc": "К какому виду спорта вы хотите вернуться?",
        "rtsSportRunning": "Бег",
        "rtsSportSoccer": "Футбол / Командные виды",
        "rtsSportStrength": "Силовые тренировки",
        "rtsSportCycling": "Велоспорт",
        "rtsSportSwimming": "Плавание",
        "rtsSportMartialArts": "Единоборства",
        "rtsSportOther": "Другое",
        "rtsTestHopTitle": "Прыжок на одной ноге (Hop-Test)",
        "rtsTestHopDesc": "Прыгните как можно дальше на повреждённой ноге и измерьте расстояние. Повторите на здоровой стороне.",
        "rtsTestHopHint": "Выполните 3 попытки и запишите лучший результат. LSI ≥ 90 % — оптимальный порог для возврата к спорту.",
        "rtsHopAffected": "Пострадавшая сторона (см)",
        "rtsHopHealthy": "Здоровая сторона (см)",
        "@rtsHopDetailValue": {"placeholders": {"affected": {"type": "String"}, "healthy": {"type": "String"}, "percent": {"type": "String"}}},
        "rtsHopDetailValue": "Поврежд.: {affected} см / Здоров.: {healthy} см → LSI: {percent}",
        "rtsTestTugTitle": "Тест «Встань и иди» (TUG)",
        "rtsTestTugDesc": "Встаньте со стула, пройдите 3 метра, вернитесь и сядьте. Измерьте общее время.",
        "rtsTestTugHint": "Используйте секундомер или введите время вручную. Менее 10 секунд — отличный результат.",
        "@rtsTugDetailValue": {"placeholders": {"seconds": {"type": "String"}}},
        "rtsTugDetailValue": "{seconds} секунд",
        "rtsTimerStart": "Запустить секундомер",
        "rtsTimerStop": "Остановить",
        "rtsTimerReset": "Сбросить",
        "rtsTimerRestart": "Перезапустить",
        "rtsTimerOrManual": "Или введите вручную:",
        "rtsTimerManualLabel": "Время в секундах",
        "rtsScoreTrend": "Динамика счёта",
    },
}


def append_keys(filename: str, new_entries: dict) -> None:
    path = L10N / filename
    text = path.read_text(encoding="utf-8")
    # The file ends with `\n}` – insert before the closing brace
    if not text.rstrip().endswith("}"):
        print(f"  WARN: {filename} does not end with }}")
        return

    lines = []
    for key, value in new_entries.items():
        if key.startswith("@"):
            # metadata entry – value is a dict
            entry = f'  "{key}": {json.dumps(value, ensure_ascii=False)}'
        else:
            entry = f'  "{key}": {json.dumps(value, ensure_ascii=False)}'
        lines.append(entry)

    insert = ",\n" + ",\n".join(lines) + "\n"
    # Insert before the final closing brace
    new_text = text.rstrip()
    if new_text.endswith("}"):
        new_text = new_text[:-1].rstrip() + insert + "}\n"
    path.write_text(new_text, encoding="utf-8")
    print(f"  updated {filename} (+{len([k for k in new_entries if not k.startswith('@')])} keys)")


for fname, entries in NEW_KEYS.items():
    print(f"Processing {fname}…")
    append_keys(fname, entries)

print("Done.")
