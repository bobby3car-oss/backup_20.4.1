import json
import sys

arb_files = {
    'de': 'lib/l10n/app_de.arb',
    'en': 'lib/l10n/app_en.arb',
    'ru': 'lib/l10n/app_ru.arb',
    'tr': 'lib/l10n/app_tr.arb',
    'ar': 'lib/l10n/app_ar.arb',
}

data = {}
for lang, path in arb_files.items():
    with open(path, encoding='utf-8') as f:
        data[lang] = json.load(f)

new_keys = {
    "onboardingSkip": {"de": "Überspringen", "en": "Skip", "ru": "Пропустить", "tr": "Atla", "ar": "تخطي"},
    "onboardingNext": {"de": "Weiter", "en": "Next", "ru": "Далее", "tr": "İleri", "ar": "التالي"},
    "onboardingGetStarted": {"de": "Los geht's", "en": "Let's go", "ru": "Начнём", "tr": "Haydi başlayalım", "ar": "هيا نبدأ"},
    "onboardingSlide1Title": {"de": "Dein digitaler\nOP-Begleiter", "en": "Your digital\nsurgery companion", "ru": "Ваш цифровой\nпомощник по операции", "tr": "Dijital ameliyat\nrehberiniz", "ar": "رفيقك الرقمي\nللعمليات"},
    "onboardingSlide1Subtitle": {"de": "Alle Informationen rund um deinen Eingriff –\nsicher und übersichtlich an einem Ort.", "en": "All information about your procedure –\nsafe and organized in one place.", "ru": "Вся информация о вашей операции –\nбезопасно и удобно в одном месте.", "tr": "Ameliyatınıza dair tüm bilgiler –\ngüvenli ve düzenli bir arada.", "ar": "جميع المعلومات حول عمليتك –\nآمنة ومنظمة في مكان واحد."},
    "onboardingSlide1Feature1": {"de": "Schritt-für-Schritt Begleitung", "en": "Step-by-step guidance", "ru": "Пошаговое сопровождение", "tr": "Adım adım rehberlik", "ar": "إرشاد خطوة بخطوة"},
    "onboardingSlide1Feature2": {"de": "Für Patienten entwickelt", "en": "Designed for patients", "ru": "Разработано для пациентов", "tr": "Hastalar için tasarlandı", "ar": "مصمم للمرضى"},
    "onboardingSlide1Feature3": {"de": "Alles an einem Ort", "en": "Everything in one place", "ru": "Всё в одном месте", "tr": "Her şey tek yerde", "ar": "كل شيء في مكان واحد"},
    "onboardingSlide2Title": {"de": "Deine OP\nim Überblick", "en": "Your surgery\nat a glance", "ru": "Ваша операция\nв обзоре", "tr": "Ameliyatınız\nbir bakışta", "ar": "عمليتك\nفي لمحة"},
    "onboardingSlide2Subtitle": {"de": "Von der Vorbereitung bis zur Nachsorge –\nalles übersichtlich geplant.", "en": "From preparation to aftercare –\neverything clearly planned.", "ru": "От подготовки до реабилитации –\nвсё чётко спланировано.", "tr": "Hazırlıktan bakıma kadar –\nher şey düzenli planlandı.", "ar": "من التحضير إلى الرعاية اللاحقة –\nكل شيء مخطط بوضوح."},
    "onboardingSlide2Feature1": {"de": "Vorbereitungs-Checkliste", "en": "Preparation checklist", "ru": "Чек-лист подготовки", "tr": "Hazırlık kontrol listesi", "ar": "قائمة التحضير"},
    "onboardingSlide2Feature2": {"de": "Packliste für die Klinik", "en": "Packing list for the clinic", "ru": "Список вещей для клиники", "tr": "Klinik için bavul listesi", "ar": "قائمة حقيبة المستشفى"},
    "onboardingSlide2Feature3": {"de": "Alle Termine im Blick", "en": "All appointments at a glance", "ru": "Все приёмы под контролем", "tr": "Tüm randevular bir bakışta", "ar": "جميع المواعيد في متناول يدك"},
    "onboardingSlide3Title": {"de": "Gesundheit\ntracken", "en": "Track your\nhealth", "ru": "Отслеживайте\nздоровье", "tr": "Sağlığınızı\ntakip edin", "ar": "تتبع\nصحتك"},
    "onboardingSlide3Subtitle": {"de": "Behalte deine Vitalwerte und Symptome\njederzeit im Auge.", "en": "Keep an eye on your vitals\nand symptoms at all times.", "ru": "Следите за показателями здоровья\nи симптомами в любое время.", "tr": "Vital değerlerinizi ve semptomlarınızı\nher zaman takip edin.", "ar": "راقب مؤشراتك الحيوية\nوأعراضك في أي وقت."},
    "onboardingSlide3Feature1": {"de": "Vitalwerte & Puls", "en": "Vitals & pulse", "ru": "Показатели и пульс", "tr": "Vital değerler ve nabız", "ar": "المؤشرات الحيوية والنبض"},
    "onboardingSlide3Feature2": {"de": "Schmerztagebuch", "en": "Pain diary", "ru": "Дневник боли", "tr": "Ağrı günlüğü", "ar": "مذكرة الألم"},
    "onboardingSlide3Feature3": {"de": "Symptom-Check", "en": "Symptom check", "ru": "Проверка симптомов", "tr": "Semptom kontrolü", "ar": "فحص الأعراض"},
    "onboardingSlide4Title": {"de": "Deine\nWundheilung", "en": "Your wound\nhealing", "ru": "Заживление\nран", "tr": "Yara\niyileşmeniz", "ar": "شفاء\nجروحك"},
    "onboardingSlide4Subtitle": {"de": "Dokumentiere deinen Heilungsverlauf\nmit Fotos und Vergleichen.", "en": "Document your healing progress\nwith photos and comparisons.", "ru": "Документируйте процесс заживления\nс помощью фото и сравнений.", "tr": "İyileşme sürecinizi\nfotoğraflar ve karşılaştırmalarla belgeleyin.", "ar": "وثّق تقدم شفائك\nبالصور والمقارنات."},
    "onboardingSlide4Feature1": {"de": "Foto-Dokumentation", "en": "Photo documentation", "ru": "Фотодокументация", "tr": "Fotoğraf belgeleme", "ar": "توثيق بالصور"},
    "onboardingSlide4Feature2": {"de": "Vergleichs-Funktion", "en": "Comparison feature", "ru": "Функция сравнения", "tr": "Karşılaştırma özelliği", "ar": "ميزة المقارنة"},
    "onboardingSlide4Feature3": {"de": "Intelligente Hinweise", "en": "Smart suggestions", "ru": "Умные подсказки", "tr": "Akıllı öneriler", "ar": "اقتراحات ذكية"},
    "onboardingSlide5Title": {"de": "Vernetzt mit\ndeinem Team", "en": "Connected with\nyour team", "ru": "На связи с\nвашей командой", "tr": "Ekibinizle\nbağlantıda", "ar": "متصل مع\nفريقك"},
    "onboardingSlide5Subtitle": {"de": "Binde Angehörige ein und teile\nwichtige Informationen mit deinem Arzt.", "en": "Involve family members and share\nimportant information with your doctor.", "ru": "Подключайте близких и делитесь\nважной информацией с врачом.", "tr": "Yakınlarınızı dahil edin ve\nönemli bilgileri doktorunuzla paylaşın.", "ar": "أشرك أفراد عائلتك وشارك\nالمعلومات المهمة مع طبيبك."},
    "onboardingSlide5Feature1": {"de": "Angehörige einladen", "en": "Invite family members", "ru": "Пригласить близких", "tr": "Yakınları davet et", "ar": "دعوة أفراد العائلة"},
    "onboardingSlide5Feature2": {"de": "Arztberichte teilen", "en": "Share medical reports", "ru": "Делиться отчётами", "tr": "Doktor raporlarını paylaş", "ar": "مشاركة التقارير الطبية"},
    "onboardingSlide5Feature3": {"de": "Direkte Kommunikation", "en": "Direct communication", "ru": "Прямое общение", "tr": "Doğrudan iletişim", "ar": "تواصل مباشر"},
    "authSlideTitle": {"de": "Bereit loszulegen?", "en": "Ready to get started?", "ru": "Готовы начать?", "tr": "Başlamaya hazır mısınız?", "ar": "مستعد للبدء؟"},
    "authSlideSubtitle": {"de": "Erstelle dein Konto oder melde dich an,\num deine OP-Begleitung zu starten.", "en": "Create your account or sign in\nto start your surgery companion.", "ru": "Создайте аккаунт или войдите,\nчтобы начать сопровождение операции.", "tr": "Hesabınızı oluşturun veya giriş yapın\nameliyat rehberinizi başlatmak için.", "ar": "أنشئ حسابك أو سجّل الدخول\nلبدء رفيق العمليات الخاص بك."},
    "authSlideRegister": {"de": "Jetzt registrieren", "en": "Register now", "ru": "Зарегистрироваться", "tr": "Şimdi kayıt ol", "ar": "سجّل الآن"},
    "authSlideLogin": {"de": "Anmelden", "en": "Sign in", "ru": "Войти", "tr": "Giriş yap", "ar": "تسجيل الدخول"},
    "authSlideDoctorRegister": {"de": "Als Arzt registrieren", "en": "Register as doctor", "ru": "Регистрация врача", "tr": "Doktor olarak kayıt ol", "ar": "التسجيل كطبيب"},
    "authSlideGuestMode": {"de": "App ohne Konto testen", "en": "Try app without account", "ru": "Попробовать без аккаунта", "tr": "Hesapsız deneyin", "ar": "جرّب التطبيق بدون حساب"},
    "loginWelcomeBack": {"de": "Willkommen\nzur\u00fcck", "en": "Welcome\nback", "ru": "С возвращением", "tr": "Tekrar\nhoş geldiniz", "ar": "مرحبًا\nبعودتك"},
    "loginSubtitle": {"de": "Melde dich mit deinem Konto an.", "en": "Sign in with your account.", "ru": "Войдите в свой аккаунт.", "tr": "Hesabınızla giriş yapın.", "ar": "سجّل الدخول بحسابك."},
    "loginPasswordResetSent": {"de": "Falls ein Konto existiert, wurde eine E\u2011Mail gesendet.", "en": "If an account exists, a reset email has been sent.", "ru": "Если аккаунт существует, письмо отправлено.", "tr": "Hesap varsa sıfırlama e-postası gönderildi.", "ar": "إذا كان الحساب موجودًا، فقد تم إرسال بريد إعادة التعيين."},
    "loginEnterEmailFirst": {"de": "Bitte gib zuerst deine E\u2011Mail ein.", "en": "Please enter your email first.", "ru": "Сначала введите вашу почту.", "tr": "Lütfen önce e-postanızı girin.", "ar": "يرجى إدخال بريدك الإلكتروني أولاً."},
    "loginForgotPassword": {"de": "Passwort vergessen?", "en": "Forgot password?", "ru": "Забыли пароль?", "tr": "Şifreyi unuttunuz mu?", "ar": "نسيت كلمة المرور؟"},
    "loginQuickLogin": {"de": "Schnellanmeldung", "en": "Quick login", "ru": "Быстрый вход", "tr": "Hızlı giriş", "ar": "تسجيل دخول سريع"},
    "loginQuickLoginHint": {"de": "Verf\u00fcgbar nach erstmaliger Anmeldung", "en": "Available after first login", "ru": "Доступно после первого входа", "tr": "İlk girişten sonra kullanılabilir", "ar": "متاح بعد أول تسجيل دخول"},
    "doctorRegTitle": {"de": "Arzt\u2011Registrierung", "en": "Doctor registration", "ru": "Регистрация врача", "tr": "Doktor kaydı", "ar": "تسجيل الطبيب"},
    "doctorRegRoleBadge": {"de": "Zugang f\u00fcr \u00c4rzt*innen", "en": "Access for physicians", "ru": "Доступ для врачей", "tr": "Doktorlar için erişim", "ar": "وصول للأطباء"},
    "doctorRegRoleBadgeSubtitle": {"de": "Nach der Registrierung pr\u00fcft unser Team Ihre Angaben.", "en": "After registration, our team will verify your details.", "ru": "После регистрации наша команда проверит ваши данные.", "tr": "Kayıt sonrası ekibimiz bilgilerinizi doğrulayacaktır.", "ar": "بعد التسجيل، سيتحقق فريقنا من بياناتك."},
    "doctorRegPersonalData": {"de": "Pers\u00f6nliche Daten", "en": "Personal data", "ru": "Личные данные", "tr": "Kişisel veriler", "ar": "البيانات الشخصية"},
    "doctorRegNameHint": {"de": "Dr. med. Max Mustermann", "en": "Dr. John Smith", "ru": "Д-р Иван Иванов", "tr": "Dr. Ahmet Yılmaz", "ar": "د. محمد أحمد"},
    "doctorRegServiceEmail": {"de": "Dienst\u2011E\u2011Mail", "en": "Work email", "ru": "Рабочая почта", "tr": "İş e-postası", "ar": "البريد الإلكتروني للعمل"},
    "doctorRegEmailHint": {"de": "arzt@klinik.de", "en": "doctor@clinic.com", "ru": "doctor@clinic.ru", "tr": "doktor@klinik.com", "ar": "doctor@clinic.com"},
    "doctorRegEmailRequired": {"de": "E\u2011Mail eingeben", "en": "Enter email", "ru": "Введите почту", "tr": "E-posta girin", "ar": "أدخل البريد الإلكتروني"},
    "doctorRegEmailInvalid": {"de": "G\u00fcltige E\u2011Mail eingeben", "en": "Enter a valid email", "ru": "Введите корректную почту", "tr": "Geçerli bir e-posta girin", "ar": "أدخل بريدًا إلكترونيًا صالحًا"},
    "doctorRegPasswordMin8": {"de": "Mindestens 8 Zeichen", "en": "At least 8 characters", "ru": "Минимум 8 символов", "tr": "En az 8 karakter", "ar": "8 أحرف على الأقل"},
    "doctorRegProfessionalData": {"de": "Berufliche Angaben", "en": "Professional details", "ru": "Профессиональные данные", "tr": "Mesleki bilgiler", "ar": "البيانات المهنية"},
    "doctorRegSpecialty": {"de": "Fachrichtung", "en": "Specialty", "ru": "Специальность", "tr": "Uzmanlık", "ar": "التخصص"},
    "doctorRegSelectSpecialty": {"de": "Fachrichtung w\u00e4hlen", "en": "Select specialty", "ru": "Выберите специальность", "tr": "Uzmanlık seçin", "ar": "اختر التخصص"},
    "doctorRegSpecialtyRequired": {"de": "Bitte Fachrichtung w\u00e4hlen", "en": "Please select a specialty", "ru": "Пожалуйста, выберите специальность", "tr": "Lütfen bir uzmanlık seçin", "ar": "يرجى اختيار التخصص"},
    "doctorRegApprobation": {"de": "Approbationsnummer", "en": "Medical license number", "ru": "Номер лицензии", "tr": "Tıbbi lisans numarası", "ar": "رقم الترخيص الطبي"},
    "doctorRegApprobationHint": {"de": "Ihre \u00e4rztliche Approbationsnummer", "en": "Your medical license number", "ru": "Ваш номер лицензии", "tr": "Tıbbi lisans numaranız", "ar": "رقم الترخيص الطبي الخاص بك"},
    "doctorRegApprobationRequired": {"de": "Approbationsnummer eingeben", "en": "Enter license number", "ru": "Введите номер лицензии", "tr": "Lisans numarası girin", "ar": "أدخل رقم الترخيص"},
    "doctorRegPractice": {"de": "Praxis / Klinik", "en": "Practice / Clinic", "ru": "Практика / Клиника", "tr": "Muayenehane / Klinik", "ar": "العيادة / المستشفى"},
    "doctorRegPracticeHint": {"de": "Name der Praxis oder Klinik", "en": "Name of practice or clinic", "ru": "Название практики или клиники", "tr": "Muayenehane veya klinik adı", "ar": "اسم العيادة أو المستشفى"},
    "doctorRegPracticeRequired": {"de": "Praxis/Klinik eingeben", "en": "Enter practice/clinic", "ru": "Введите название", "tr": "Muayenehane/klinik girin", "ar": "أدخل العيادة/المستشفى"},
    "doctorRegKvNumber": {"de": "KV\u2011Nummer (optional)", "en": "Insurance number (optional)", "ru": "Страховой номер (необязательно)", "tr": "Sigorta numarası (opsiyonel)", "ar": "رقم التأمين (اختياري)"},
    "doctorRegKvHint": {"de": "Falls vorhanden", "en": "If available", "ru": "Если есть", "tr": "Varsa", "ar": "إن وُجد"},
    "doctorRegSubmitting": {"de": "Wird gesendet \u2026", "en": "Sending\u2026", "ru": "Отправка\u2026", "tr": "G\u00f6nderiliyor\u2026", "ar": "جارٍ الإرسال\u2026"},
    "doctorRegSubmit": {"de": "Zugang beantragen", "en": "Request access", "ru": "Запросить доступ", "tr": "Erişim talep et", "ar": "طلب الوصول"},
    "doctorRegDisclaimer": {"de": "Ihre Angaben werden vertraulich behandelt und ausschließlich zur Verifizierung verwendet.", "en": "Your information is treated confidentially and used exclusively for verification.", "ru": "Ваши данные обрабатываются конфиденциально и используются только для верификации.", "tr": "Bilgileriniz gizli tutulacak ve yalnızca doğrulama için kullanılacaktır.", "ar": "يتم التعامل مع بياناتك بسرية وتُستخدم فقط للتحقق."},
}

for key, translations in new_keys.items():
    for lang, text in translations.items():
        data[lang][key] = text

for lang, path in arb_files.items():
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data[lang], f, ensure_ascii=False, indent=2)
        f.write('\n')

for lang in ['de','en','ru','tr','ar']:
    c = len([k for k in data[lang] if not k.startswith('@') and k != '@@locale'])
    print(f'{lang.upper()}: {c} keys')
print(f'Added {len(new_keys)} new keys')
