// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مرافق العملية';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageName => 'العربية';

  @override
  String get languageChangeTitle => 'اختيار اللغة';

  @override
  String get tabStart => 'اليوم';

  @override
  String get tabAppointments => 'المواعيد';

  @override
  String get tabDocuments => 'المستندات';

  @override
  String get tabMore => 'المزيد';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginAction => 'تسجيل الدخول';

  @override
  String get loginLoading => 'جارٍ تسجيل الدخول…';

  @override
  String loginFailed(String error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String loginAppleFailed(String error) {
    return 'فشل تسجيل الدخول عبر Apple: $error';
  }

  @override
  String loginGoogleFailed(String error) {
    return 'فشل تسجيل الدخول عبر Google: $error';
  }

  @override
  String get loginWithApple => 'تسجيل الدخول عبر Apple';

  @override
  String get loginWithGoogle => 'تسجيل الدخول عبر Google';

  @override
  String get or => 'أو';

  @override
  String get noAccountYet => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get signupTitle => 'التسجيل';

  @override
  String get createAccountTitle => 'إنشاء\nحساب';

  @override
  String get createAccountSubtitle => 'املأ الحقول للبدء.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get creatingAccount => 'جارٍ إنشاء الحساب…';

  @override
  String get fieldName => 'الاسم';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String get fieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fieldRepeatPassword => 'إعادة كلمة المرور';

  @override
  String get fieldBirthDate => 'تاريخ الميلاد';

  @override
  String get fieldBirthDateHint => 'يي.شش.سسسس';

  @override
  String get fieldBirthDatePicker => 'اختيار تاريخ الميلاد';

  @override
  String get validationNameRequired => 'أدخل الاسم';

  @override
  String get validationEmailInvalid => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get validationBirthDateRequired => 'اختر تاريخ الميلاد';

  @override
  String get validationPasswordMin6 => '6 أحرف على الأقل';

  @override
  String get validationRepeatPassword => 'أعد كلمة المرور';

  @override
  String get validationPasswordsMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get validationPasswordsMismatchLegacy => 'كلمات المرور غير متطابقة.';

  @override
  String get errorEmailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get errorInvalidEmail => 'عنوان بريد إلكتروني غير صالح.';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة جداً.';

  @override
  String errorRegistrationFailed(String error) {
    return 'فشل التسجيل: $error';
  }

  @override
  String get agbAcceptPrefix => 'أوافق على ';

  @override
  String get agbAcceptLink => 'الشروط وسياسة الخصوصية';

  @override
  String get agbTermsLink => 'الشروط';

  @override
  String get agbAndConnector => ' و';

  @override
  String get agbPrivacyLink => 'سياسة الخصوصية';

  @override
  String get datePickerCancel => 'إلغاء';

  @override
  String get datePickerConfirm => 'تأكيد';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsNotAvailable => 'غير متوفر';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsPush => 'Push';

  @override
  String get settingsEmailNotif => 'البريد الإلكتروني';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsExportData => 'تصدير البيانات';

  @override
  String get settingsExportSnack => 'التصدير سيتم إضافته قريباً';

  @override
  String get settingsResetData => 'إعادة تعيين البيانات';

  @override
  String get settingsResetSnack => 'إعادة التعيين قريباً';

  @override
  String get settingsPro => 'Pro';

  @override
  String get settingsProStatus => 'حالة Pro';

  @override
  String get settingsProSubtitle => 'الاشتراك والاستعادة';

  @override
  String get settingsLegal => 'قانوني';

  @override
  String get settingsImprint => 'بيانات النشر';

  @override
  String get settingsPrivacy => 'الخصوصية';

  @override
  String get settingsTerms => 'الشروط';

  @override
  String get settingsTermsSnack => 'الشروط قريباً';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String commonError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get commonInProgress => 'جارِ التحميل…';

  @override
  String get commonUnnamed => 'بدون اسم';

  @override
  String get commonPatients => 'المرضى';

  @override
  String get commonNoPatientsYet => 'لا يوجد مرضى بعد. اضغط + للإضافة';

  @override
  String commonPatientOpened(String name) {
    return 'تم فتح المريض: $name';
  }

  @override
  String get connectivityOfflineBanner =>
      'أنت غير متصل بالإنترنت. سيتم مزامنة التغييرات عند الاتصال بالإنترنت.';

  @override
  String get connectivityRequiredTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get connectivityRequiredMessage =>
      'تتطلب هذه الميزة اتصالاً بالإنترنت. يرجى الاتصال بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get staffTeam => 'TODO:ar: Team';

  @override
  String get staffInvite => 'TODO:ar: Einladen';

  @override
  String get staffInviteTitle => 'TODO:ar: Mitarbeiter einladen';

  @override
  String get staffInviteSubtitle =>
      'TODO:ar: Teilen Sie diesen Code mit Ihrem/Ihrer Mitarbeiter/in';

  @override
  String get staffInviteValid => 'TODO:ar: Gültig für 7 Tage';

  @override
  String get staffInviteCopy => 'TODO:ar: Kopieren';

  @override
  String get staffInviteShare => 'TODO:ar: Teilen';

  @override
  String get staffInviteCodeLabel => 'TODO:ar: Einladungscode';

  @override
  String get staffAcceptTitle => 'TODO:ar: Mitarbeiter-Einladung';

  @override
  String get staffAcceptCodeHint => 'TODO:ar: CODE EINGEBEN';

  @override
  String get staffAcceptSubmit => 'TODO:ar: Code einlösen';

  @override
  String get staffAcceptSuccess => 'TODO:ar: Willkommen im Team!';

  @override
  String get staffAcceptSuccessBody =>
      'TODO:ar: Sie sind jetzt als Mitarbeiter/in registriert.\nStarten Sie die App neu, um das Dashboard zu sehen.';

  @override
  String get staffAcceptDone => 'TODO:ar: Fertig';

  @override
  String get staffRevokedTitle => 'TODO:ar: Zugang widerrufen';

  @override
  String get staffRevokedBody =>
      'TODO:ar: Ihr Mitarbeiter-Zugang wurde deaktiviert. Bitte wenden Sie sich an Ihren Arzt.';

  @override
  String get staffPermissionsTitle => 'TODO:ar: Berechtigungen';

  @override
  String get staffPermissionsSave => 'TODO:ar: Speichern';

  @override
  String get staffRemoveTitle => 'TODO:ar: Mitarbeiter entfernen';

  @override
  String get staffRemoveConfirm => 'TODO:ar: Wirklich entfernen?';

  @override
  String get staffRemoveAction => 'TODO:ar: Entfernen';

  @override
  String get staffEmptyTitle => 'TODO:ar: Noch kein Team';

  @override
  String get staffEmptySubtitle =>
      'TODO:ar: Laden Sie Ihre Mitarbeitenden ein, um Ihr Praxis-Dashboard zu teilen.';

  @override
  String get staffRole => 'TODO:ar: Mitarbeiter/in';

  @override
  String get staffPractice => 'TODO:ar: Praxis';

  @override
  String get staffMyPermissions => 'TODO:ar: Meine Berechtigungen';

  @override
  String get staffAccessNone => 'TODO:ar: Kein Zugriff';

  @override
  String get staffAccessRead => 'TODO:ar: Lesen';

  @override
  String get staffAccessReadWrite => 'TODO:ar: Lesen & Schreiben';

  @override
  String get staffPendingInvites => 'TODO:ar: Offene Einladungen';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'هيا نبدأ';

  @override
  String get onboardingSlide1Title => 'رفيقك الرقمي\nللعمليات';

  @override
  String get onboardingSlide1Subtitle =>
      'جميع المعلومات حول عمليتك –\nآمنة ومنظمة في مكان واحد.';

  @override
  String get onboardingSlide1Feature1 => 'إرشاد خطوة بخطوة';

  @override
  String get onboardingSlide1Feature2 => 'مصمم للمرضى';

  @override
  String get onboardingSlide1Feature3 => 'كل شيء في مكان واحد';

  @override
  String get onboardingSlide2Title => 'عمليتك\nفي لمحة';

  @override
  String get onboardingSlide2Subtitle =>
      'من التحضير إلى الرعاية اللاحقة –\nكل شيء مخطط بوضوح.';

  @override
  String get onboardingSlide2Feature1 => 'قائمة التحضير';

  @override
  String get onboardingSlide2Feature2 => 'قائمة حقيبة المستشفى';

  @override
  String get onboardingSlide2Feature3 => 'جميع المواعيد في متناول يدك';

  @override
  String get onboardingSlide3Title => 'تتبع\nصحتك';

  @override
  String get onboardingSlide3Subtitle =>
      'راقب مؤشراتك الحيوية\nوأعراضك في أي وقت.';

  @override
  String get onboardingSlide3Feature1 => 'المؤشرات الحيوية والنبض';

  @override
  String get onboardingSlide3Feature2 => 'مذكرة الألم';

  @override
  String get onboardingSlide3Feature3 => 'فحص الأعراض';

  @override
  String get onboardingSlide4Title => 'شفاء\nجروحك';

  @override
  String get onboardingSlide4Subtitle => 'وثّق تقدم شفائك\nبالصور والمقارنات.';

  @override
  String get onboardingSlide4Feature1 => 'توثيق بالصور';

  @override
  String get onboardingSlide4Feature2 => 'ميزة المقارنة';

  @override
  String get onboardingSlide4Feature3 => 'اقتراحات ذكية';

  @override
  String get onboardingSlide5Title => 'متصل مع\nفريقك';

  @override
  String get onboardingSlide5Subtitle =>
      'أشرك أفراد عائلتك وشارك\nالمعلومات المهمة مع طبيبك.';

  @override
  String get onboardingSlide5Feature1 => 'دعوة أفراد العائلة';

  @override
  String get onboardingSlide5Feature2 => 'مشاركة التقارير الطبية';

  @override
  String get onboardingSlide5Feature3 => 'تواصل مباشر';

  @override
  String get authSlideTitle => 'مستعد للبدء؟';

  @override
  String get authSlideSubtitle =>
      'أنشئ حسابك أو سجّل الدخول\nلبدء رفيق العمليات الخاص بك.';

  @override
  String get authSlideRegister => 'سجّل الآن';

  @override
  String get authSlideLogin => 'تسجيل الدخول';

  @override
  String get authSlideDoctorRegister => 'التسجيل كطبيب';

  @override
  String get authSlideGuestMode => 'جرّب التطبيق بدون حساب';

  @override
  String get loginWelcomeBack => 'مرحبًا\nبعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول بحسابك.';

  @override
  String get loginPasswordResetSent =>
      'إذا كان الحساب موجودًا، فقد تم إرسال بريد إعادة التعيين.';

  @override
  String get loginEnterEmailFirst => 'يرجى إدخال بريدك الإلكتروني أولاً.';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginQuickLogin => 'تسجيل دخول سريع';

  @override
  String get loginQuickLoginHint => 'متاح بعد أول تسجيل دخول';

  @override
  String get doctorRegTitle => 'تسجيل الطبيب';

  @override
  String get doctorRegRoleBadge => 'وصول للأطباء';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'بعد التسجيل، سيتحقق فريقنا من بياناتك.';

  @override
  String get doctorRegPersonalData => 'البيانات الشخصية';

  @override
  String get doctorRegNameHint => 'د. محمد أحمد';

  @override
  String get doctorRegServiceEmail => 'البريد الإلكتروني للعمل';

  @override
  String get doctorRegEmailHint => 'doctor@clinic.com';

  @override
  String get doctorRegEmailRequired => 'أدخل البريد الإلكتروني';

  @override
  String get doctorRegEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get doctorRegPasswordMin8 => '8 أحرف على الأقل';

  @override
  String get doctorRegProfessionalData => 'البيانات المهنية';

  @override
  String get doctorRegSpecialty => 'التخصص';

  @override
  String get doctorRegSelectSpecialty => 'اختر التخصص';

  @override
  String get doctorRegSpecialtyRequired => 'يرجى اختيار التخصص';

  @override
  String get doctorRegApprobation => 'رقم الترخيص الطبي';

  @override
  String get doctorRegApprobationHint => 'رقم الترخيص الطبي الخاص بك';

  @override
  String get doctorRegApprobationRequired => 'أدخل رقم الترخيص';

  @override
  String get doctorRegPractice => 'العيادة / المستشفى';

  @override
  String get doctorRegPracticeHint => 'اسم العيادة أو المستشفى';

  @override
  String get doctorRegPracticeRequired => 'أدخل العيادة/المستشفى';

  @override
  String get doctorRegKvNumber => 'رقم التأمين (اختياري)';

  @override
  String get doctorRegKvHint => 'إن وُجد';

  @override
  String get doctorRegSubmitting => 'جارٍ الإرسال…';

  @override
  String get doctorRegSubmit => 'طلب الوصول';

  @override
  String get doctorRegDisclaimer =>
      'يتم التعامل مع بياناتك بسرية وتُستخدم فقط للتحقق.';

  @override
  String get medicalDisclaimer =>
      'هذا التطبيق ليس جهازًا طبيًا ولا يحل محل العلاج الطبي.';
}
