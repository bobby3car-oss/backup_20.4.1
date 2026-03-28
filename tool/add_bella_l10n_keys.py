#!/usr/bin/env python3
"""Add Bella AI feature l10n keys to all 5 ARB files."""

import json
import os

ARB_DIR = os.path.join(os.path.dirname(__file__), '..', 'lib', 'l10n')

# Keys with German values (template)
DE_KEYS = {
    # ── Header subtitles ─────────────────────────────────────────────────
    "bellaSubtitleDoctor":          "Dein klinischer Assistent 🐰",
    "bellaSubtitleStaff":           "Dein Praxis-Assistent 🐰",
    "bellaSubtitlePatient":         "Dein OP-Wissenshelfer 🐰",
    # placeholder: used / limit
    "bellaDailyUsage":              "{used} / {limit} Nachrichten heute",
    "@bellaDailyUsage": {
        "placeholders": {
            "used":  {"type": "int"},
            "limit": {"type": "int"},
        }
    },

    # ── Empty-state greeting & descriptions ──────────────────────────────
    "bellaGreeting":                "Hallo! Ich bin Bella AI 🐰",
    "bellaDescriptionDoctor":       "Ich unterstütze dich bei der Nutzung des "
                                    "Arzt-Dashboards, Patientenverwaltung und "
                                    "klinischen Fragen.",
    "bellaDescriptionStaff":        "Ich helfe dir bei der Nutzung des "
                                    "Mitarbeiter-Dashboards und der "
                                    "Patientenbetreuung.",
    "bellaDescriptionPatient":      "Ich helfe dir bei Fragen rund um deine "
                                    "Operation, Nachsorge und die App.",

    # ── Feature pill labels ──────────────────────────────────────────────
    "bellaFeatureDashboard":        "Dashboard",
    "bellaFeaturePatients":         "Patienten",
    "bellaFeatureAppHelp":          "App-Hilfe",
    "bellaFeatureMedicalKnowledge": "OP-Wissen",
    "bellaFeatureTasks":            "Aufgaben",
    "bellaFeatureAftercare":        "Nachsorge",
    "bellaFeatureWarnings":         "Warnzeichen",

    # ── Input bar ────────────────────────────────────────────────────────
    "bellaDisclaimer":              "Keine medizinische Beratung – bei "
                                    "Beschwerden Arzt kontaktieren.",
    "bellaDefaultWoundPrompt":      "Bitte analysiere dieses Wundfoto.",

    # ── Consent card ─────────────────────────────────────────────────────
    "bellaConsentTitle":            "Datenschutzhinweis",
    "bellaConsentAccepted":         "Einwilligung erteilt",
    "bellaConsentDeclined":         "Einwilligung abgelehnt",
    "bellaConsentBody":             "Der KI-Assistent (Bella AI) nutzt einen "
                                    "externen Dienst (NVIDIA Corporation, USA), "
                                    "um deine Fragen zu beantworten.\n\n"
                                    "Dabei werden deine Chat-Nachrichten an "
                                    "diesen Dienst übermittelt. Es werden keine "
                                    "weiteren personenbezogenen Daten "
                                    "übertragen.\n\n"
                                    "Du kannst diese Einwilligung jederzeit in "
                                    "den Einstellungen widerrufen.\n\n"
                                    "Rechtsgrundlage: Art. 6 Abs. 1 lit. a, "
                                    "Art. 9 Abs. 2 lit. a DSGVO.",
    "bellaConsentYes":              "Ja, einverstanden",

    # ── Action card ──────────────────────────────────────────────────────
    "bellaActionCreated":           "Eintrag erstellt ✓",
    "bellaActionCancelled":         "Abgebrochen",
    "bellaActionFailed":            "Fehler beim Erstellen",
    "bellaActionStatusCreated":     "{label} — erstellt",
    "@bellaActionStatusCreated": {
        "placeholders": {"label": {"type": "String"}}
    },
    "bellaActionStatusCancelled":   "{label} — abgebrochen",
    "@bellaActionStatusCancelled": {
        "placeholders": {"label": {"type": "String"}}
    },
    "bellaActionStatusFailed":      "{label} — fehlgeschlagen",
    "@bellaActionStatusFailed": {
        "placeholders": {"label": {"type": "String"}}
    },

    # ── Wound analysis card ──────────────────────────────────────────────
    "bellaWoundAnalysisTitle":      "Wundanalyse",
    "bellaWoundObservations":       "Beobachtungen",
    "bellaWoundProgressComparison": "Verlaufsvergleich",
    "bellaWoundDisclaimer":         "Kein Ersatz für ärztliche Diagnose. "
                                    "Bei Bedenken kontaktiere dein "
                                    "medizinisches Team.",

    # ── Pro upsell card ──────────────────────────────────────────────────
    "bellaProUpgrade":              "Jetzt auf Pro upgraden",

    # ── Assistant screen ─────────────────────────────────────────────────
    "bellaAskDirectly":             "Oder stell direkt eine Frage:",
    "bellaNoAnswerReceived":        "Keine Antwort erhalten. Bitte versuche es erneut. 🐰",

    # ── Briefing screen ──────────────────────────────────────────────────
    "bellaBriefingNotSignedIn":     "Bitte melde dich an.",
    "bellaBriefingHttpError":       "Fehler beim Erstellen des Briefings (HTTP {statusCode}).",
    "@bellaBriefingHttpError": {
        "placeholders": {"statusCode": {"type": "int"}}
    },
    "bellaBriefingGenerating":      "Bella erstellt dein Arzt-Briefing …",
    "bellaBriefingPersonalTitle":   "Dein persönliches Arzt-Briefing",
    "bellaBriefingIsProFeature":    "Arzt-Briefing ist ein Pro-Feature",
    "bellaBriefingProDescription":  "Mit Pro erstellt Bella eine persönliche "
                                    "Zusammenfassung für deinen nächsten Arzttermin.",

    # ── Proactive card ───────────────────────────────────────────────────
    "bellaSays":                    "Bella sagt:",
    "bellaProactiveDocGap":         "Du hast seit {days} Tagen nichts dokumentiert",
    "@bellaProactiveDocGap": {
        "placeholders": {"days": {"type": "int"}}
    },
    "bellaProactivePainTrend":      "Dein Schmerzlevel steigt – möchtest du darüber sprechen?",
    "bellaProactiveOpenTasks":      "Du hast noch {count} offene Aufgaben für heute",
    "@bellaProactiveOpenTasks": {
        "placeholders": {"count": {"type": "int"}}
    },
    "bellaProactiveStreakAtRisk":   "Dein {streak}-Tage Streak ist in Gefahr!",
    "@bellaProactiveStreakAtRisk": {
        "placeholders": {"streak": {"type": "int"}}
    },
    "bellaProactiveMedReminder":    "Hast du heute dein {name} genommen?",
    "@bellaProactiveMedReminder": {
        "placeholders": {"name": {"type": "String"}}
    },
    "bellaProactiveMedReminderMultiple":
                                    "Hast du heute deine Medikamente genommen? ({count} ausstehend)",
    "@bellaProactiveMedReminderMultiple": {
        "placeholders": {"count": {"type": "int"}}
    },

    # ── Daily analysis card ──────────────────────────────────────────────
    "bellaDailyAnalysis":           "Bella Tagesanalyse",

    # ── Suggestion chips – patient ───────────────────────────────────────
    "bellaChipPrepareOp":           "Wie bereite ich mich auf die OP vor?",
    "bellaChipOpDay":               "Was passiert am OP-Tag?",
    "bellaChipTimeline":            "Wie funktioniert die Timeline?",
    "bellaChipCallDoctor":          "Wann sollte ich den Arzt rufen?",
    "bellaChipMedications":         "Wie erfasse ich meine Medikamente?",
    "bellaChipKneeTep":             "Infos zur Knie-TEP",

    # ── Suggestion chips – doctor ────────────────────────────────────────
    "bellaChipLinkPatient":         "Wie verknüpfe ich einen Patienten?",
    "bellaChipDoctorDashboard":     "Wie funktioniert das Arzt-Dashboard?",
    "bellaChipViewPatientData":     "Wie sehe ich Patientendaten ein?",
    "bellaChipVerifyAccount":       "Wie verifiziere ich mein Arztkonto?",
    "bellaChipAppFunctions":        "Welche App-Funktionen gibt es?",
    "bellaChipDoctorReport":        "Wie erstelle ich einen Arztbericht?",

    # ── Suggestion chips – staff ─────────────────────────────────────────
    "bellaChipMyTasks":             "Was sind meine Aufgaben?",
    "bellaChipViewPatientDataStaff":"Wie sehe ich Patientendaten?",
    "bellaChipGeneralDashboard":    "Wie funktioniert das Dashboard?",

    # ── Suggestion chips – pro actions ───────────────────────────────────
    "bellaChipCreateAppointment":   "Erstelle einen Termin morgen um 10 Uhr",
    "bellaChipAddTask":             "Füge eine Aufgabe hinzu: Wunde kontrollieren",
    "bellaChipLogBloodPressure":    "Trage Blutdruck 120/80 ein",
    "bellaChipLogMedication":       "Ich habe gerade Ibuprofen genommen",
    "bellaChipLogPain":             "Logge Schmerz: Knie, Stärke 4",

    # ── Symptom check ────────────────────────────────────────────────────
    "bellaChipSymptomCheck":        "Symptom-Check starten",
}

# Translations for each locale
TRANSLATIONS = {
    "en": {
        "bellaSubtitleDoctor":          "Your clinical assistant 🐰",
        "bellaSubtitleStaff":           "Your practice assistant 🐰",
        "bellaSubtitlePatient":         "Your surgery guide 🐰",
        "bellaDailyUsage":              "{used} / {limit} messages today",
        "bellaGreeting":                "Hello! I'm Bella AI 🐰",
        "bellaDescriptionDoctor":       "I help you with the doctor dashboard, "
                                        "patient management, and clinical questions.",
        "bellaDescriptionStaff":        "I help you with the staff dashboard and "
                                        "patient care.",
        "bellaDescriptionPatient":      "I answer your questions about your surgery, "
                                        "aftercare, and the app.",
        "bellaFeatureDashboard":        "Dashboard",
        "bellaFeaturePatients":         "Patients",
        "bellaFeatureAppHelp":          "App Help",
        "bellaFeatureMedicalKnowledge": "Surgery",
        "bellaFeatureTasks":            "Tasks",
        "bellaFeatureAftercare":        "Aftercare",
        "bellaFeatureWarnings":         "Warning Signs",
        "bellaDisclaimer":              "Not medical advice – consult a doctor for any complaints.",
        "bellaDefaultWoundPrompt":      "Please analyse this wound photo.",
        "bellaConsentTitle":            "Privacy Notice",
        "bellaConsentAccepted":         "Consent given",
        "bellaConsentDeclined":         "Consent declined",
        "bellaConsentBody":             "The AI assistant (Bella AI) uses an external "
                                        "service (NVIDIA Corporation, USA) to answer "
                                        "your questions.\n\n"
                                        "Your chat messages are transmitted to this "
                                        "service. No other personal data is shared.\n\n"
                                        "You can withdraw your consent at any time "
                                        "in Settings.\n\n"
                                        "Legal basis: Art. 6(1)(a) and Art. 9(2)(a) GDPR.",
        "bellaConsentYes":              "Yes, I agree",
        "bellaActionCreated":           "Entry created ✓",
        "bellaActionCancelled":         "Cancelled",
        "bellaActionFailed":            "Failed to create",
        "bellaActionStatusCreated":     "{label} — created",
        "bellaActionStatusCancelled":   "{label} — cancelled",
        "bellaActionStatusFailed":      "{label} — failed",
        "bellaWoundAnalysisTitle":      "Wound Analysis",
        "bellaWoundObservations":       "Observations",
        "bellaWoundProgressComparison": "Progress Comparison",
        "bellaWoundDisclaimer":         "Not a substitute for medical diagnosis. "
                                        "If in doubt, contact your medical team.",
        "bellaProUpgrade":              "Upgrade to Pro now",
        "bellaAskDirectly":             "Or ask a question directly:",
        "bellaNoAnswerReceived":        "No answer received. Please try again. 🐰",
        "bellaBriefingNotSignedIn":     "Please sign in.",
        "bellaBriefingHttpError":       "Error creating briefing (HTTP {statusCode}).",
        "bellaBriefingGenerating":      "Bella is creating your doctor briefing …",
        "bellaBriefingPersonalTitle":   "Your personal doctor briefing",
        "bellaBriefingIsProFeature":    "Doctor Briefing is a Pro feature",
        "bellaBriefingProDescription":  "With Pro, Bella creates a personal summary "
                                        "for your next doctor's appointment.",
        "bellaSays":                    "Bella says:",
        "bellaProactiveDocGap":         "You haven't logged anything in {days} days",
        "bellaProactivePainTrend":      "Your pain level is rising – would you like to talk about it?",
        "bellaProactiveOpenTasks":      "You still have {count} open tasks for today",
        "bellaProactiveStreakAtRisk":   "Your {streak}-day streak is at risk!",
        "bellaProactiveMedReminder":    "Have you taken your {name} today?",
        "bellaProactiveMedReminderMultiple":
                                        "Have you taken your medication today? ({count} pending)",
        "bellaDailyAnalysis":           "Bella Daily Analysis",
        "bellaChipPrepareOp":           "How do I prepare for surgery?",
        "bellaChipOpDay":               "What happens on surgery day?",
        "bellaChipTimeline":            "How does the timeline work?",
        "bellaChipCallDoctor":          "When should I call the doctor?",
        "bellaChipMedications":         "How do I log my medications?",
        "bellaChipKneeTep":             "Info on knee replacement",
        "bellaChipLinkPatient":         "How do I link a patient?",
        "bellaChipDoctorDashboard":     "How does the doctor dashboard work?",
        "bellaChipViewPatientData":     "How do I view patient data?",
        "bellaChipVerifyAccount":       "How do I verify my doctor account?",
        "bellaChipAppFunctions":        "What app features are there?",
        "bellaChipDoctorReport":        "How do I create a doctor report?",
        "bellaChipMyTasks":             "What are my tasks?",
        "bellaChipViewPatientDataStaff":"How do I view patient data?",
        "bellaChipGeneralDashboard":    "How does the dashboard work?",
        "bellaChipCreateAppointment":   "Create an appointment tomorrow at 10 AM",
        "bellaChipAddTask":             "Add a task: check wound",
        "bellaChipLogBloodPressure":    "Log blood pressure 120/80",
        "bellaChipLogMedication":       "I just took ibuprofen",
        "bellaChipLogPain":             "Log pain: knee, level 4",
        "bellaChipSymptomCheck":        "Start symptom check",
    },
    "ar": {
        "bellaSubtitleDoctor":          "مساعدك السريري 🐰",
        "bellaSubtitleStaff":           "مساعد العيادة 🐰",
        "bellaSubtitlePatient":         "مرشدك لعملية الجراحة 🐰",
        "bellaDailyUsage":              "{used} / {limit} رسائل اليوم",
        "bellaGreeting":                "مرحباً! أنا Bella AI 🐰",
        "bellaDescriptionDoctor":       "أساعدك في استخدام لوحة تحكم الطبيب، "
                                        "وإدارة المرضى والأسئلة السريرية.",
        "bellaDescriptionStaff":        "أساعدك في استخدام لوحة تحكم الموظفين "
                                        "ورعاية المرضى.",
        "bellaDescriptionPatient":      "أجيب على أسئلتك حول عمليتك الجراحية "
                                        "والرعاية اللاحقة والتطبيق.",
        "bellaFeatureDashboard":        "لوحة التحكم",
        "bellaFeaturePatients":         "المرضى",
        "bellaFeatureAppHelp":          "مساعدة التطبيق",
        "bellaFeatureMedicalKnowledge": "معلومات الجراحة",
        "bellaFeatureTasks":            "المهام",
        "bellaFeatureAftercare":        "الرعاية اللاحقة",
        "bellaFeatureWarnings":         "علامات التحذير",
        "bellaDisclaimer":              "ليست نصيحة طبية – استشر طبيباً عند الشعور بأعراض.",
        "bellaDefaultWoundPrompt":      "يرجى تحليل صورة الجرح هذه.",
        "bellaConsentTitle":            "إشعار الخصوصية",
        "bellaConsentAccepted":         "تم الموافقة",
        "bellaConsentDeclined":         "تم رفض الموافقة",
        "bellaConsentBody":             "يستخدم المساعد الذكي (Bella AI) خدمة خارجية "
                                        "(NVIDIA Corporation, USA) للإجابة على أسئلتك.\n\n"
                                        "يتم إرسال رسائل الدردشة الخاصة بك إلى هذه الخدمة. "
                                        "لا يتم مشاركة أي بيانات شخصية أخرى.\n\n"
                                        "يمكنك سحب موافقتك في أي وقت من الإعدادات.\n\n"
                                        "الأساس القانوني: المادة 6(1)(أ) والمادة 9(2)(أ) من اللائحة العامة لحماية البيانات.",
        "bellaConsentYes":              "نعم، أوافق",
        "bellaActionCreated":           "تم إنشاء الإدخال ✓",
        "bellaActionCancelled":         "تم الإلغاء",
        "bellaActionFailed":            "فشل الإنشاء",
        "bellaActionStatusCreated":     "{label} — تم الإنشاء",
        "bellaActionStatusCancelled":   "{label} — تم الإلغاء",
        "bellaActionStatusFailed":      "{label} — فشل",
        "bellaWoundAnalysisTitle":      "تحليل الجرح",
        "bellaWoundObservations":       "الملاحظات",
        "bellaWoundProgressComparison": "مقارنة التقدم",
        "bellaWoundDisclaimer":         "لا يغني عن التشخيص الطبي. "
                                        "عند الشك، تواصل مع فريقك الطبي.",
        "bellaProUpgrade":              "الترقية إلى Pro الآن",
        "bellaAskDirectly":             "أو اطرح سؤالاً مباشرةً:",
        "bellaNoAnswerReceived":        "لم يتم تلقي إجابة. يرجى المحاولة مجدداً. 🐰",
        "bellaBriefingNotSignedIn":     "يرجى تسجيل الدخول.",
        "bellaBriefingHttpError":       "خطأ في إنشاء الموجز (HTTP {statusCode}).",
        "bellaBriefingGenerating":      "Bella تنشئ ملخصك الطبي …",
        "bellaBriefingPersonalTitle":   "ملخصك الطبي الشخصي",
        "bellaBriefingIsProFeature":    "الموجز الطبي ميزة Pro",
        "bellaBriefingProDescription":  "مع Pro تنشئ Bella ملخصاً شخصياً "
                                        "لموعدك الطبي القادم.",
        "bellaSays":                    "Bella تقول:",
        "bellaProactiveDocGap":         "لم تُسجّل أي شيء منذ {days} أيام",
        "bellaProactivePainTrend":      "مستوى ألمك في ارتفاع – هل تريد التحدث عن ذلك؟",
        "bellaProactiveOpenTasks":      "لا يزال لديك {count} مهام مفتوحة لليوم",
        "bellaProactiveStreakAtRisk":   "سلسلة {streak} يوم في خطر!",
        "bellaProactiveMedReminder":    "هل تناولت {name} اليوم؟",
        "bellaProactiveMedReminderMultiple":
                                        "هل تناولت دوائك اليوم؟ ({count} معلق)",
        "bellaDailyAnalysis":           "تحليل Bella اليومي",
        "bellaChipPrepareOp":           "كيف أستعد للجراحة؟",
        "bellaChipOpDay":               "ماذا يحدث في يوم الجراحة؟",
        "bellaChipTimeline":            "كيف يعمل الجدول الزمني؟",
        "bellaChipCallDoctor":          "متى يجب أن أتصل بالطبيب؟",
        "bellaChipMedications":         "كيف أسجّل أدويتي؟",
        "bellaChipKneeTep":             "معلومات عن استبدال الركبة",
        "bellaChipLinkPatient":         "كيف أربط مريضاً؟",
        "bellaChipDoctorDashboard":     "كيف تعمل لوحة تحكم الطبيب؟",
        "bellaChipViewPatientData":     "كيف أطّلع على بيانات المريض؟",
        "bellaChipVerifyAccount":       "كيف أتحقق من حسابي كطبيب؟",
        "bellaChipAppFunctions":        "ما هي ميزات التطبيق؟",
        "bellaChipDoctorReport":        "كيف أنشئ تقرير طبي؟",
        "bellaChipMyTasks":             "ما هي مهامي؟",
        "bellaChipViewPatientDataStaff":"كيف أطّلع على بيانات المريض؟",
        "bellaChipGeneralDashboard":    "كيف تعمل لوحة التحكم؟",
        "bellaChipCreateAppointment":   "أنشئ موعداً غداً الساعة 10 صباحاً",
        "bellaChipAddTask":             "أضف مهمة: فحص الجرح",
        "bellaChipLogBloodPressure":    "سجّل ضغط الدم 120/80",
        "bellaChipLogMedication":       "تناولت إيبوبروفين للتو",
        "bellaChipLogPain":             "سجّل الألم: الركبة، مستوى 4",
        "bellaChipSymptomCheck":        "بدء فحص الأعراض",
    },
    "ru": {
        "bellaSubtitleDoctor":          "Ваш клинический ассистент 🐰",
        "bellaSubtitleStaff":           "Ваш ассистент клиники 🐰",
        "bellaSubtitlePatient":         "Ваш помощник по операции 🐰",
        "bellaDailyUsage":              "{used} / {limit} сообщений сегодня",
        "bellaGreeting":                "Привет! Я Bella AI 🐰",
        "bellaDescriptionDoctor":       "Я помогаю вам с панелью врача, "
                                        "управлением пациентами и клиническими вопросами.",
        "bellaDescriptionStaff":        "Я помогаю вам с панелью сотрудников "
                                        "и уходом за пациентами.",
        "bellaDescriptionPatient":      "Я отвечаю на ваши вопросы об операции, "
                                        "послеоперационном уходе и приложении.",
        "bellaFeatureDashboard":        "Панель",
        "bellaFeaturePatients":         "Пациенты",
        "bellaFeatureAppHelp":          "Помощь по приложению",
        "bellaFeatureMedicalKnowledge": "Об операции",
        "bellaFeatureTasks":            "Задачи",
        "bellaFeatureAftercare":        "Послеоперационный уход",
        "bellaFeatureWarnings":         "Предупреждения",
        "bellaDisclaimer":              "Не является медицинской консультацией – при жалобах обратитесь к врачу.",
        "bellaDefaultWoundPrompt":      "Пожалуйста, проанализируйте это фото раны.",
        "bellaConsentTitle":            "Уведомление о конфиденциальности",
        "bellaConsentAccepted":         "Согласие дано",
        "bellaConsentDeclined":         "Согласие отклонено",
        "bellaConsentBody":             "ИИ-ассистент (Bella AI) использует внешний "
                                        "сервис (NVIDIA Corporation, США) для ответов "
                                        "на ваши вопросы.\n\n"
                                        "Ваши сообщения чата передаются в этот сервис. "
                                        "Никакие другие персональные данные не передаются.\n\n"
                                        "Вы можете отозвать своё согласие в любое время "
                                        "в Настройках.\n\n"
                                        "Правовое основание: ст. 6(1)(а) и ст. 9(2)(а) GDPR.",
        "bellaConsentYes":              "Да, согласен",
        "bellaActionCreated":           "Запись создана ✓",
        "bellaActionCancelled":         "Отменено",
        "bellaActionFailed":            "Ошибка создания",
        "bellaActionStatusCreated":     "{label} — создано",
        "bellaActionStatusCancelled":   "{label} — отменено",
        "bellaActionStatusFailed":      "{label} — ошибка",
        "bellaWoundAnalysisTitle":      "Анализ раны",
        "bellaWoundObservations":       "Наблюдения",
        "bellaWoundProgressComparison": "Сравнение прогресса",
        "bellaWoundDisclaimer":         "Не заменяет медицинский диагноз. "
                                        "При сомнениях обратитесь к своей медицинской команде.",
        "bellaProUpgrade":              "Перейти на Pro сейчас",
        "bellaAskDirectly":             "Или задайте вопрос напрямую:",
        "bellaNoAnswerReceived":        "Ответ не получен. Попробуйте снова. 🐰",
        "bellaBriefingNotSignedIn":     "Пожалуйста, войдите в систему.",
        "bellaBriefingHttpError":       "Ошибка создания брифинга (HTTP {statusCode}).",
        "bellaBriefingGenerating":      "Bella создаёт ваш врачебный брифинг …",
        "bellaBriefingPersonalTitle":   "Ваш персональный врачебный брифинг",
        "bellaBriefingIsProFeature":    "Врачебный брифинг — функция Pro",
        "bellaBriefingProDescription":  "С Pro Bella создаёт персональное резюме "
                                        "для вашего следующего визита к врачу.",
        "bellaSays":                    "Bella говорит:",
        "bellaProactiveDocGap":         "Вы ничего не документировали {days} дней",
        "bellaProactivePainTrend":      "Уровень боли растёт – хотите поговорить об этом?",
        "bellaProactiveOpenTasks":      "У вас ещё {count} открытых задач на сегодня",
        "bellaProactiveStreakAtRisk":   "Ваша серия из {streak} дней под угрозой!",
        "bellaProactiveMedReminder":    "Вы принимали {name} сегодня?",
        "bellaProactiveMedReminderMultiple":
                                        "Вы принимали лекарства сегодня? ({count} осталось)",
        "bellaDailyAnalysis":           "Ежедневный анализ Bella",
        "bellaChipPrepareOp":           "Как подготовиться к операции?",
        "bellaChipOpDay":               "Что происходит в день операции?",
        "bellaChipTimeline":            "Как работает расписание?",
        "bellaChipCallDoctor":          "Когда мне звонить врачу?",
        "bellaChipMedications":         "Как вносить мои лекарства?",
        "bellaChipKneeTep":             "Информация о протезировании колена",
        "bellaChipLinkPatient":         "Как привязать пациента?",
        "bellaChipDoctorDashboard":     "Как работает панель врача?",
        "bellaChipViewPatientData":     "Как просматривать данные пациентов?",
        "bellaChipVerifyAccount":       "Как верифицировать аккаунт врача?",
        "bellaChipAppFunctions":        "Какие функции есть в приложении?",
        "bellaChipDoctorReport":        "Как создать отчёт врача?",
        "bellaChipMyTasks":             "Каковы мои задачи?",
        "bellaChipViewPatientDataStaff":"Как просматривать данные пациентов?",
        "bellaChipGeneralDashboard":    "Как работает панель управления?",
        "bellaChipCreateAppointment":   "Создай приём завтра в 10:00",
        "bellaChipAddTask":             "Добавь задачу: проверить рану",
        "bellaChipLogBloodPressure":    "Записать давление 120/80",
        "bellaChipLogMedication":       "Я только что принял ибупрофен",
        "bellaChipLogPain":             "Записать боль: колено, уровень 4",
        "bellaChipSymptomCheck":        "Начать проверку симптомов",
    },
    "tr": {
        "bellaSubtitleDoctor":          "Klinik asistanınız 🐰",
        "bellaSubtitleStaff":           "Klinik asistanınız 🐰",
        "bellaSubtitlePatient":         "Ameliyat rehberiniz 🐰",
        "bellaDailyUsage":              "Bugün {used} / {limit} mesaj",
        "bellaGreeting":                "Merhaba! Ben Bella AI 🐰",
        "bellaDescriptionDoctor":       "Doktor paneli, hasta yönetimi ve "
                                        "klinik sorularda size yardımcı oluyorum.",
        "bellaDescriptionStaff":        "Personel paneli ve hasta bakımında "
                                        "size yardımcı oluyorum.",
        "bellaDescriptionPatient":      "Ameliyatınız, ameliyat sonrası bakım "
                                        "ve uygulama hakkındaki sorularınızı yanıtlıyorum.",
        "bellaFeatureDashboard":        "Gösterge Paneli",
        "bellaFeaturePatients":         "Hastalar",
        "bellaFeatureAppHelp":          "Uygulama Yardımı",
        "bellaFeatureMedicalKnowledge": "Ameliyat Bilgisi",
        "bellaFeatureTasks":            "Görevler",
        "bellaFeatureAftercare":        "Ameliyat Sonrası Bakım",
        "bellaFeatureWarnings":         "Uyarı İşaretleri",
        "bellaDisclaimer":              "Tıbbi tavsiye değildir – şikayetiniz varsa doktora başvurun.",
        "bellaDefaultWoundPrompt":      "Lütfen bu yara fotoğrafını analiz et.",
        "bellaConsentTitle":            "Gizlilik Bildirimi",
        "bellaConsentAccepted":         "Onay verildi",
        "bellaConsentDeclined":         "Onay reddedildi",
        "bellaConsentBody":             "Yapay zeka asistanı (Bella AI), sorularınızı "
                                        "yanıtlamak için harici bir hizmet "
                                        "(NVIDIA Corporation, ABD) kullanmaktadır.\n\n"
                                        "Sohbet mesajlarınız bu hizmete iletilmektedir. "
                                        "Başka kişisel veri paylaşılmamaktadır.\n\n"
                                        "Onayınızı istediğiniz zaman Ayarlar'dan geri alabilirsiniz.\n\n"
                                        "Hukuki dayanak: GDPR Madde 6(1)(a) ve Madde 9(2)(a).",
        "bellaConsentYes":              "Evet, kabul ediyorum",
        "bellaActionCreated":           "Kayıt oluşturuldu ✓",
        "bellaActionCancelled":         "İptal edildi",
        "bellaActionFailed":            "Oluşturma başarısız",
        "bellaActionStatusCreated":     "{label} — oluşturuldu",
        "bellaActionStatusCancelled":   "{label} — iptal edildi",
        "bellaActionStatusFailed":      "{label} — başarısız",
        "bellaWoundAnalysisTitle":      "Yara Analizi",
        "bellaWoundObservations":       "Gözlemler",
        "bellaWoundProgressComparison": "İlerleme Karşılaştırması",
        "bellaWoundDisclaimer":         "Tıbbi tanının yerini tutmaz. "
                                        "Şüphe durumunda tıbbi ekibinizle iletişime geçin.",
        "bellaProUpgrade":              "Şimdi Pro'ya geç",
        "bellaAskDirectly":             "Ya da doğrudan soru sorun:",
        "bellaNoAnswerReceived":        "Yanıt alınamadı. Lütfen tekrar deneyin. 🐰",
        "bellaBriefingNotSignedIn":     "Lütfen giriş yapın.",
        "bellaBriefingHttpError":       "Brifing oluşturulurken hata (HTTP {statusCode}).",
        "bellaBriefingGenerating":      "Bella doktor brifinginizi oluşturuyor …",
        "bellaBriefingPersonalTitle":   "Kişisel doktor brifinginiz",
        "bellaBriefingIsProFeature":    "Doktor Brifingı Pro özelliğidir",
        "bellaBriefingProDescription":  "Pro ile Bella, bir sonraki doktor randevunuz için "
                                        "kişisel bir özet oluşturur.",
        "bellaSays":                    "Bella diyor ki:",
        "bellaProactiveDocGap":         "{days} gündür hiçbir şey kaydetmediniz",
        "bellaProactivePainTrend":      "Ağrı düzeyiniz artıyor – bunu konuşmak ister misiniz?",
        "bellaProactiveOpenTasks":      "Bugün için hâlâ {count} açık göreviniz var",
        "bellaProactiveStreakAtRisk":   "{streak} günlük seriniz tehlikede!",
        "bellaProactiveMedReminder":    "Bugün {name} aldınız mı?",
        "bellaProactiveMedReminderMultiple":
                                        "Bugün ilaçlarınızı aldınız mı? ({count} beklemede)",
        "bellaDailyAnalysis":           "Bella Günlük Analizi",
        "bellaChipPrepareOp":           "Ameliyata nasıl hazırlanırım?",
        "bellaChipOpDay":               "Ameliyat günü ne olur?",
        "bellaChipTimeline":            "Zaman çizelgesi nasıl çalışır?",
        "bellaChipCallDoctor":          "Doktoru ne zaman aramalıyım?",
        "bellaChipMedications":         "İlaçlarımı nasıl kaydederim?",
        "bellaChipKneeTep":             "Diz protezi hakkında bilgi",
        "bellaChipLinkPatient":         "Bir hastayı nasıl bağlarım?",
        "bellaChipDoctorDashboard":     "Doktor paneli nasıl çalışır?",
        "bellaChipViewPatientData":     "Hasta verilerini nasıl görüntülerim?",
        "bellaChipVerifyAccount":       "Doktor hesabımı nasıl doğrularım?",
        "bellaChipAppFunctions":        "Hangi uygulama özellikleri var?",
        "bellaChipDoctorReport":        "Doktor raporu nasıl oluştururum?",
        "bellaChipMyTasks":             "Görevlerim nelerdir?",
        "bellaChipViewPatientDataStaff":"Hasta verilerini nasıl görüntülerim?",
        "bellaChipGeneralDashboard":    "Gösterge paneli nasıl çalışır?",
        "bellaChipCreateAppointment":   "Yarın saat 10'da randevu oluştur",
        "bellaChipAddTask":             "Görev ekle: yarayı kontrol et",
        "bellaChipLogBloodPressure":    "Tansiyon 120/80 kaydet",
        "bellaChipLogMedication":       "Az önce ibuprofen aldım",
        "bellaChipLogPain":             "Ağrı kaydet: diz, seviye 4",
        "bellaChipSymptomCheck":        "Semptom kontrolü başlat",
    },
}


def load_arb(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_arb(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


def insert_keys(arb: dict, keys_dict: dict) -> int:
    """Insert keys from keys_dict that are not already present. Returns count added."""
    added = 0
    for key, value in keys_dict.items():
        if key not in arb:
            arb[key] = value
            added += 1
    return added


def main():
    locales = ['de', 'en', 'ar', 'ru', 'tr']

    for locale in locales:
        path = os.path.join(ARB_DIR, f'app_{locale}.arb')
        arb = load_arb(path)

        if locale == 'de':
            keys_to_add = DE_KEYS
        else:
            # Build locale dict: include @-annotations from DE_KEYS, values from TRANSLATIONS
            trans = TRANSLATIONS[locale]
            keys_to_add = {}
            for key, de_value in DE_KEYS.items():
                if key.startswith('@'):
                    # Copy @-annotation as-is from DE_KEYS
                    keys_to_add[key] = de_value
                else:
                    keys_to_add[key] = trans.get(key, de_value)

        added = insert_keys(arb, keys_to_add)
        save_arb(path, arb)
        print(f'[{locale}] Added {added} keys → {path}')


if __name__ == '__main__':
    main()
