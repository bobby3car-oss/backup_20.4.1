// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get tabStart => 'الرئيسية';

  @override
  String get tabAppointments => 'المواعيد';

  @override
  String get tabMore => 'المزيد';

  @override
  String get commonBack => 'حسناً';

  @override
  String get or => 'أو';

  @override
  String get connectivityOfflineBanner =>
      'أنت غير متصل بالإنترنت. ستتم مزامنة التغييرات عند الاتصال مجدداً.';

  @override
  String get connectivityRequiredTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get connectivityRequiredMessage =>
      'تتطلب هذه الميزة اتصالاً بالإنترنت. يرجى الاتصال والمحاولة مرة أخرى.';

  @override
  String get syncIndicatorSynced => 'تمت المزامنة بالكامل';

  @override
  String syncIndicatorSyncing(int count) {
    return '$count إدخالات في انتظار المزامنة';
  }

  @override
  String get syncIndicatorOffline => 'غير متصل';

  @override
  String syncIndicatorOfflineWithCount(int count) {
    return 'غير متصل – $count إدخالات في انتظار المزامنة';
  }

  @override
  String get syncIndicatorTitle => 'المزامنة';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingSlide1Title => 'مرحباً بك في مرافق العمليات';

  @override
  String get onboardingSlide1Subtitle => 'مرافقك الشخصي قبل وبعد العملية';

  @override
  String get onboardingSlide1Feature1 => 'جميع المعلومات المهمة في لمحة واحدة';

  @override
  String get onboardingSlide1Feature2 => 'قوائم مراجعة شخصية لعمليتك';

  @override
  String get onboardingSlide1Feature3 => 'خطوة بخطوة خلال العملية';

  @override
  String get onboardingSlide2Title => 'التحضير';

  @override
  String get onboardingSlide2Subtitle => 'استعد بشكل مثالي للعملية';

  @override
  String get onboardingSlide2Feature1 => 'خطط تحضير فردية';

  @override
  String get onboardingSlide2Feature2 => 'تذكيرات بالمواعيد المهمة';

  @override
  String get onboardingSlide2Feature3 => 'إدارة المستندات رقمياً';

  @override
  String get onboardingSlide3Title => 'الرعاية اللاحقة';

  @override
  String get onboardingSlide3Subtitle => 'الدعم بعد العملية';

  @override
  String get onboardingSlide3Feature1 => 'فحوصات صحية يومية';

  @override
  String get onboardingSlide3Feature2 => 'تذكيرات بالأدوية';

  @override
  String get onboardingSlide3Feature3 => 'تتبع التقدم';

  @override
  String get onboardingSlide4Title => 'الأمان';

  @override
  String get onboardingSlide4Subtitle => 'بياناتك آمنة معنا';

  @override
  String get onboardingSlide4Feature1 => 'تشفير من طرف إلى طرف';

  @override
  String get onboardingSlide4Feature2 => 'متوافق مع GDPR';

  @override
  String get onboardingSlide4Feature3 => 'البيانات فقط على جهازك';

  @override
  String get onboardingSlide5Title => 'جاهز؟';

  @override
  String get onboardingSlide5Subtitle => 'أنشئ ملفك الشخصي الآن';

  @override
  String get onboardingSlide5Feature1 => 'سجل مجاناً';

  @override
  String get onboardingSlide5Feature2 => 'جاهز في دقائق قليلة';

  @override
  String get onboardingSlide5Feature3 => 'قابل للحذف في أي وقت';

  @override
  String get authSlideTitle => 'مرافق العمليات';

  @override
  String get authSlideSubtitle => 'مرافقك الشخصي للعملية';

  @override
  String get authSlideRegister => 'تسجيل';

  @override
  String get authSlideLogin => 'تسجيل الدخول';

  @override
  String get authSlideDoctorRegister => 'التسجيل كطبيب / مؤسسة';

  @override
  String get authSlideGuestMode => 'وضع الضيف';

  @override
  String get authSlideTrustSignals =>
      'TODO:ar: Kostenlos · Keine Kreditkarte · In 30 Sek. startklar';

  @override
  String get authSlideSocialProof =>
      'TODO:ar: 4,9 ★ · 2.500+ Patienten vertrauen der App';

  @override
  String get registerContinueAsGuest => 'المتابعة بدون تسجيل';

  @override
  String get loginWelcomeBack => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجل دخولك للمتابعة';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginEnterEmailFirst => 'يرجى إدخال بريدك الإلكتروني أولاً.';

  @override
  String get loginPasswordResetSent => 'تم إرسال بريد إعادة تعيين كلمة المرور.';

  @override
  String get loginWithGoogle => 'تسجيل الدخول بحساب Google';

  @override
  String get loginWithApple => 'تسجيل الدخول بحساب Apple';

  @override
  String get noAccountYet => 'ليس لديك حساب بعد؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get createAccountTitle => 'إنشاء حساب';

  @override
  String get createAccountSubtitle => 'سجل للبدء';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String get fieldRepeatPassword => 'تكرار كلمة المرور';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get fieldBirthDate => 'تاريخ الميلاد';

  @override
  String get fieldBirthDateHint => 'يي.شش.سسسس';

  @override
  String get fieldBirthDatePicker => 'اختر تاريخ الميلاد';

  @override
  String get fieldAge => 'TODO:ar: Alter';

  @override
  String get fieldAgeHint => 'TODO:ar: z.B. 45';

  @override
  String get fieldAgeYears => 'TODO:ar: Jahre';

  @override
  String get validationAgeRequired => 'TODO:ar: Bitte gib dein Alter ein.';

  @override
  String get validationAgeInvalid =>
      'TODO:ar: Bitte gib ein gültiges Alter ein (0–120).';

  @override
  String get validationEmailInvalid => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get validationPasswordMin6 =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل.';

  @override
  String get validationPasswordsMismatch => 'كلمات المرور غير متطابقة.';

  @override
  String get validationNameRequired => 'يرجى إدخال اسمك.';

  @override
  String get validationBirthDateRequired => 'يرجى إدخال تاريخ ميلادك.';

  @override
  String get parentalConsentAge => 'TODO:ar: Du bist unter 16 Jahre alt.';

  @override
  String get parentalConsentText =>
      'أؤكد أن والديّ أو أولياء أمري قد وافقوا صراحةً على استخدامي لهذا التطبيق ومعالجة بياناتي (GDPR المادة 8).';

  @override
  String get validationRepeatPassword => 'يرجى تكرار كلمة المرور.';

  @override
  String get datePickerCancel => 'إلغاء';

  @override
  String get datePickerConfirm => 'تأكيد';

  @override
  String get agbAcceptPrefix => 'أوافق على ';

  @override
  String get agbTermsLink => 'شروط الاستخدام';

  @override
  String get agbAndConnector => ' و ';

  @override
  String get agbPrivacyLink => 'سياسة الخصوصية';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get medicalDisclaimer =>
      'ملاحظة مهمة: هذا التطبيق لا يحل محل الاستشارة الطبية أو التشخيص أو العلاج. جميع المحتويات لأغراض إعلامية عامة فقط. للشكاوى الصحية يرجى الرجوع دائمًا إلى طبيبك.';

  @override
  String get doctorRegTitle => 'التسجيل كطبيب';

  @override
  String get doctorRegRoleBadge => 'طبيب';

  @override
  String get doctorRegRoleBadgeSubtitle => 'متخصص طبي معتمد';

  @override
  String get doctorRegPersonalData => 'البيانات الشخصية';

  @override
  String get doctorRegProfessionalData => 'البيانات المهنية';

  @override
  String get doctorRegNameHint => 'د. أحمد محمد';

  @override
  String get doctorRegEmailHint => 'doctor@clinic.com';

  @override
  String get doctorRegEmailRequired => 'يرجى إدخال بريدك الإلكتروني.';

  @override
  String get doctorRegEmailInvalid => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get doctorRegPasswordMin8 =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل.';

  @override
  String get doctorRegSpecialty => 'التخصص';

  @override
  String get doctorRegSelectSpecialty => 'اختر التخصص';

  @override
  String get doctorRegApprobation => 'رقم الترخيص الطبي';

  @override
  String get doctorRegApprobationHint => 'مثال 12345678';

  @override
  String get doctorRegApprobationRequired => 'يرجى إدخال رقم الترخيص الطبي.';

  @override
  String get doctorRegKvNumber => 'رقم التسجيل';

  @override
  String get doctorRegKvHint => 'اختياري';

  @override
  String get doctorRegPractice => 'العيادة / المستشفى';

  @override
  String get doctorRegPracticeHint => 'اسم العيادة أو المستشفى';

  @override
  String get doctorRegPracticeRequired => 'يرجى إدخال عيادتك.';

  @override
  String get doctorRegServiceEmail => 'البريد الإلكتروني المهني';

  @override
  String get doctorRegDisclaimer =>
      'سيتم مراجعة بياناتك وتفعيل حسابك بعد التحقق بنجاح.';

  @override
  String get doctorRegSubmit => 'إرسال التسجيل';

  @override
  String get doctorRegSubmitting => 'جارٍ الإرسال…';

  @override
  String get orgRegTitle => 'التسجيل كمؤسسة';

  @override
  String get orgRegRoleBadge => 'مؤسسة';

  @override
  String get orgRegRoleBadgeSubtitle => 'مستشفيات وعيادات ومراكز إعادة تأهيل';

  @override
  String get orgRegGeneralData => 'البيانات العامة';

  @override
  String get orgRegOrgData => 'بيانات المؤسسة';

  @override
  String get orgRegOrgName => 'اسم المؤسسة';

  @override
  String get orgRegOrgNameHint => 'مثال مستشفى جامعي';

  @override
  String get orgRegNameRequired => 'يرجى إدخال اسم المؤسسة.';

  @override
  String get orgRegOrgType => 'نوع المؤسسة';

  @override
  String get orgRegSelectOrgType => 'اختر نوع المؤسسة';

  @override
  String get orgRegAddress => 'العنوان';

  @override
  String get orgRegAddressHint => 'الشارع، الرمز البريدي، المدينة';

  @override
  String get orgRegAddressRequired => 'يرجى إدخال العنوان.';

  @override
  String get orgRegContactPerson => 'شخص الاتصال';

  @override
  String get orgRegContactPersonHint => 'الاسم الأول والأخير';

  @override
  String get orgRegContactPersonRequired => 'يرجى إدخال شخص اتصال.';

  @override
  String get orgRegEmail => 'بريد المؤسسة الإلكتروني';

  @override
  String get orgRegEmailHint => 'info@organisation.com';

  @override
  String get orgRegPhone => 'الهاتف';

  @override
  String get orgRegPhoneHint => '+966 12 345 6789';

  @override
  String get orgRegDisclaimer =>
      'سيتم مراجعة بياناتك وتفعيل حسابك بعد التحقق بنجاح.';

  @override
  String get orgRegSubmit => 'إرسال التسجيل';

  @override
  String get orgRegSubmitting => 'جارٍ الإرسال…';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsNotAvailable => 'الإعدادات غير متاحة';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsPush => 'إشعارات الدفع';

  @override
  String get settingsEmailNotif => 'إشعارات البريد الإلكتروني';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsExportData => 'تصدير البيانات';

  @override
  String get settingsResetData => 'إعادة تعيين البيانات';

  @override
  String get settingsPro => 'النسخة الاحترافية';

  @override
  String get settingsProStatus => 'حالة Pro';

  @override
  String get settingsProSubtitle => 'فتح جميع الميزات';

  @override
  String get settingsLegal => 'قانوني';

  @override
  String get settingsImprint => 'البيانات القانونية';

  @override
  String get settingsPrivacy => 'الخصوصية';

  @override
  String get settingsTerms => 'شروط الاستخدام';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get tutorialSkip => 'تخطي';

  @override
  String get tutorialNext => 'التالي';

  @override
  String get tutorialFinish => 'تم';

  @override
  String get tutorialNeverShow => 'لا تظهر مرة أخرى';

  @override
  String get tutorialStep1Title => 'مرحباً! 👋';

  @override
  String get tutorialStep1Desc =>
      'مرحباً، أنا بيلا! ستجد هنا كل ما هو مهم عن عمليتك في لمحة واحدة.';

  @override
  String get tutorialStep2Title => 'مواعيدك';

  @override
  String get tutorialStep2Desc =>
      'تابع مواعيد طبيبك والتحضيرات – سأذكرك في الوقت المناسب.';

  @override
  String get tutorialStep3Title => 'أنا دائماً هنا';

  @override
  String get tutorialStep3Desc =>
      'هذا أنا! 🐰 المسني في أي وقت – سأجيب على جميع أسئلتك حول تعافيك.';

  @override
  String get tutorialStep4Title => 'اكتشف المزيد';

  @override
  String get tutorialStep4Desc =>
      'تحت \'المزيد\' ستجد الإعدادات والمساعدة وميزات إضافية مفيدة.';

  @override
  String get profileCompleteness => 'اكتمال الملف الشخصي';

  @override
  String get profileStillTodo => 'مهام متبقية';

  @override
  String get profileMoreItems => 'المزيد';

  @override
  String get profileComplete => 'أكمل الملف الشخصي';

  @override
  String get profileCheckName => 'أدخل الاسم';

  @override
  String get profileCheckOpDate => 'أدخل تاريخ العملية';

  @override
  String get profileCheckOpType => 'اختر نوع العملية';

  @override
  String get profileCheckDoctor => 'أدخل الطبيب المعالج';

  @override
  String get profileCheckHospital => 'أدخل المستشفى';

  @override
  String get profileCheckHeight => 'أدخل الطول';

  @override
  String get profileCheckWeight => 'أدخل الوزن';

  @override
  String get profileCheckEmergencyContact => 'أضف جهة اتصال للطوارئ';

  @override
  String get doctorRegSpecialtyRequired => 'يرجى اختيار التخصص.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get done => 'تم';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get share => 'مشاركة';

  @override
  String get copy => 'نسخ';

  @override
  String get send => 'إرسال';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get activate => 'تفعيل';

  @override
  String get deactivate => 'إلغاء التفعيل';

  @override
  String get unlock => 'فتح القفل';

  @override
  String get create => 'إنشاء';

  @override
  String get update => 'تحديث';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get all => 'الكل';

  @override
  String get none => 'لا شيء';

  @override
  String get details => 'التفاصيل';

  @override
  String get info => 'معلومات';

  @override
  String get warning => 'تحذير';

  @override
  String get urgent => 'عاجل';

  @override
  String get critical => 'حرج';

  @override
  String get high => 'مرتفع';

  @override
  String get low => 'منخفض';

  @override
  String get normal => 'عادي';

  @override
  String get minimal => 'بسيط';

  @override
  String get daily => 'يومياً';

  @override
  String get weekdays => 'أيام الأسبوع';

  @override
  String get everyNDays => 'كل N يوم';

  @override
  String get customDay => 'يوم مخصص';

  @override
  String get repeatUntil => 'تكرار حتى';

  @override
  String get repetition => 'تكرار';

  @override
  String get recurring => 'متكرر';

  @override
  String get allDay => 'طوال اليوم';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'تسجيل الخروج؟';

  @override
  String get logoutAdminConfirm =>
      'هل تريد فعلاً تسجيل الخروج من منطقة الإدارة؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل';

  @override
  String get accountRequired => 'الحساب مطلوب';

  @override
  String get passwordConfirm => 'تأكيد كلمة المرور';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get passwordReset => 'إعادة تعيين كلمة المرور';

  @override
  String get passwordResetDone => 'تم إعادة تعيين كلمة المرور';

  @override
  String get passwordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordMin6 => '٦ أحرف على الأقل';

  @override
  String newPasswordFor(String name) {
    return 'كلمة مرور جديدة لـ $name';
  }

  @override
  String get deleteAccountTitle => 'حذف الحساب نهائياً؟';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteDataOnly => 'حذف البيانات فقط';

  @override
  String get deleteFinal => 'حذف نهائي';

  @override
  String get deleteUserAndData => 'تم حذف المستخدم وجميع البيانات.';

  @override
  String get resetDataTitle => 'إعادة تعيين البيانات';

  @override
  String get allDataIrreversible => 'حذف جميع البيانات بشكل لا رجعة فيه';

  @override
  String get guestDataFound => 'تم العثور على بيانات محلية';

  @override
  String get guestDataDiscard => 'لا، تجاهل';

  @override
  String get guestDataTransfer => 'نعم، نقل';

  @override
  String get settingSaveError => 'تعذر حفظ الإعداد.';

  @override
  String get settingSaved => 'تم حفظ الإعدادات.';

  @override
  String get tutorialRepeat => 'إعادة البرنامج التعليمي';

  @override
  String get tutorialRepeatSubtitle => 'عرض المقدمة مرة أخرى';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsActive => 'الإشعارات مفعّلة';

  @override
  String get notificationsManage => 'إدارة الإشعارات';

  @override
  String notificationsCountNew(int count) {
    return 'الإشعارات ($count جديدة)';
  }

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get adDisplays => 'الإعلانات';

  @override
  String get usageStats => 'إحصائيات الاستخدام';

  @override
  String get crashReports => 'تقارير الأعطال';

  @override
  String get bellaAiAssistant => 'مساعدة بيلا الذكية';

  @override
  String get exportAsPdf => 'تصدير كملف PDF';

  @override
  String get exportAsPdfSubtitle => 'تقرير نظرة عامة واضح';

  @override
  String get exportAsJson => 'تصدير كملف JSON';

  @override
  String get exportAsJsonSubtitle => 'جميع البيانات الخام للأرشفة';

  @override
  String get exportCreating => 'جارٍ إنشاء التصدير…';

  @override
  String get exportPreparing => 'جارٍ تحضير التصدير…';

  @override
  String get csvExporting => 'جارٍ تصدير CSV…';

  @override
  String get appointment => 'موعد';

  @override
  String get appointmentCreate => 'إنشاء موعد';

  @override
  String get appointmentAdd => 'إضافة موعد';

  @override
  String get appointmentConfirmed => 'تم تأكيد الموعد';

  @override
  String get appointmentDeclined => 'تم رفض الموعد';

  @override
  String get appointmentDeleteConfirm => 'حذف الموعد؟';

  @override
  String get appointmentSaveError => 'تعذر حفظ الموعد.';

  @override
  String get appointmentCreateError => 'تعذر إنشاء الموعد.';

  @override
  String get appointmentDeleteError => 'خطأ في حذف الموعد';

  @override
  String appointmentForPatient(String name) {
    return 'Appointment for $name';
  }

  @override
  String get practiceAppointment => 'موعد العيادة';

  @override
  String get practiceAppointmentOwn => 'إنشاء موعد داخلي خاص بالعيادة';

  @override
  String get practiceAppointmentSaveError => 'تعذر حفظ موعد العيادة.';

  @override
  String get practiceAppointmentDeleteConfirm => 'حذف موعد العيادة؟';

  @override
  String get calendarAddTitle => 'إضافة إلى التقويم؟';

  @override
  String get calendarNoThanks => 'لا، شكراً';

  @override
  String get calendarShareIcs => 'مشاركة كملف .ics';

  @override
  String get calendarAdd => 'إضافة إلى التقويم';

  @override
  String get medication => 'الدواء';

  @override
  String get medicationAdd => 'إضافة دواء';

  @override
  String get medicationPlan => 'خطة الأدوية';

  @override
  String get medicationHubOpen => 'فتح مركز الأدوية';

  @override
  String get medicationIntakeTimes => 'مواعيد التناول';

  @override
  String get medicationIntakeSaveError => 'خطأ في حفظ التناول';

  @override
  String get medicationStock => 'المخزون (اختياري)';

  @override
  String get medicationLocalAlarms => 'تنبيهات محلية للمواعيد المفعّلة';

  @override
  String get medicationAlarmDeleteError => 'خطأ في حذف التنبيه';

  @override
  String get patient => 'المريض';

  @override
  String get patientInvite => 'دعوة مريض';

  @override
  String get patientAdd => 'إضافة مريض';

  @override
  String get patientConnect => 'ربط مريض';

  @override
  String get patientLinked => 'تم ربط المريض بنجاح!';

  @override
  String get patientLinking => 'ربط المريض';

  @override
  String get patientPlan => 'خطة المريض';

  @override
  String get patientAppointment => 'موعد المريض';

  @override
  String get patientData => 'بيانات المريض';

  @override
  String get patientNoInvites => 'لا توجد دعوات للمرضى.';

  @override
  String get doctor => 'الطبيب';

  @override
  String get doctorAdd => 'إضافة طبيب';

  @override
  String get doctorRemove => 'إزالة الطبيب';

  @override
  String get doctorConfirm => 'تأكيد الطبيب';

  @override
  String get doctorDisconnect => 'فصل الطبيب';

  @override
  String get doctorDeleted => 'تم حذف الطبيب.';

  @override
  String get doctorCreated => 'تم إنشاء الطبيب';

  @override
  String get doctorDetails => 'تفاصيل الطبيب';

  @override
  String get doctorCreateInvite => 'إنشاء دعوة طبيب';

  @override
  String get doctorVerification => 'التحقق من الطبيب';

  @override
  String get doctorNoInvites => 'لا توجد دعوات للأطباء.';

  @override
  String get doctorManage => 'إدارة الأطباء';

  @override
  String get doctorEnterUid => 'يرجى إدخال معرف الطبيب.';

  @override
  String get doctorReportNotAvailable => 'تقرير الطبيب غير متوفر.';

  @override
  String get treatingDoctor => 'الطبيب المعالج';

  @override
  String get templateNew => 'قالب جديد';

  @override
  String get templateNone => 'لم يتم العثور على قوالب';

  @override
  String get templateDelete => 'حذف القالب؟';

  @override
  String templateDeleteConfirm(String name) {
    return 'هل تريد فعلاً حذف \"$name\"؟';
  }

  @override
  String get templateSaved => 'تم حفظ القالب';

  @override
  String get templateSave => 'حفظ القالب';

  @override
  String get templateApply => 'تطبيق القالب';

  @override
  String get templateFromTasks => 'قالب من المهام';

  @override
  String get templateFromTasksCreate => 'إنشاء قالب من المهام';

  @override
  String templateCreated(String name) {
    return 'تم إنشاء القالب \"$name\"';
  }

  @override
  String templateDuplicated(String name) {
    return 'تم إنشاء \"$name\"';
  }

  @override
  String get templateDuplicateError => 'خطأ في التكرار';

  @override
  String templateAdopted(String name) {
    return 'تم تبني \"$name\" إلى القوالب الخاصة';
  }

  @override
  String get templateAdoptError => 'خطأ في التبني';

  @override
  String get templateDeleteError => 'خطأ في حذف القالب';

  @override
  String get templateOwnTemplates => 'القوالب الخاصة';

  @override
  String get templateDuplicate => 'تكرار';

  @override
  String get templateAdopt => 'تبني';

  @override
  String get systemTemplates => 'قوالب النظام';

  @override
  String get systemTemplateDelete => 'حذف قالب النظام؟';

  @override
  String get systemTemplateNone => 'لا توجد قوالب نظام بعد';

  @override
  String get systemTemplateFirst => 'أول قالب نظام';

  @override
  String get task => 'مهمة';

  @override
  String get taskDefine => 'تحديد المهمة';

  @override
  String get taskCreate => 'إنشاء مهمة';

  @override
  String get taskCreateError => 'تعذر إنشاء المهمة.';

  @override
  String get taskAssign => 'تعيين المهمة';

  @override
  String get taskRequired => 'عنصر مطلوب';

  @override
  String tasksCount(int count) {
    return 'المهام ($count)';
  }

  @override
  String tasksSelectCount(int selected, int total) {
    return 'اختر المهام ($selected/$total):';
  }

  @override
  String get tasksSelectToApply => 'اختر المهام للتطبيق:';

  @override
  String get tasksNone => 'لا توجد مهام';

  @override
  String get tasksNoneYet => 'لا توجد مهام بعد';

  @override
  String get tasksNoneAdded => 'لم تتم إضافة مهام بعد';

  @override
  String get tasksNoneInPlan => 'لا توجد مهام في الخطة بعد.';

  @override
  String get tasksNoneAssigned => 'لم يتم العثور على مهام معيّنة.';

  @override
  String get taskSaveError => 'خطأ في حفظ المهمة';

  @override
  String get taskRepeatCount => 'عدد التكرارات';

  @override
  String get taskDayOffset => 'إزاحة الأيام';

  @override
  String get taskDueAfterHours => 'مستحقة بعد (ساعات)';

  @override
  String get taskTimeOfDay => 'وقت اليوم (اختياري)';

  @override
  String get taskMustNotForget => 'يجب عدم نسيانه';

  @override
  String get phase => 'مرحلة';

  @override
  String get phases => 'المراحل';

  @override
  String get phaseNone => 'بدون مرحلة';

  @override
  String get phasesNone => 'لا توجد مراحل – جميع المهام عامة.';

  @override
  String get phaseRename => 'إعادة تسمية المرحلة';

  @override
  String get inviteCreate => 'إنشاء دعوة';

  @override
  String get inviteCreated => 'تم إنشاء الدعوة';

  @override
  String get inviteCreateError => 'تعذر إنشاء الدعوة.';

  @override
  String get inviteAcceptError => 'تعذر قبول الدعوة.';

  @override
  String get inviteRevoke => 'إلغاء الدعوة؟';

  @override
  String get inviteRevoked => 'تم إلغاء الدعوة.';

  @override
  String get inviteAccepted => 'تم قبول الدعوة.';

  @override
  String get invitations => 'الدعوات';

  @override
  String get inviteCodeCopied => 'تم نسخ رمز الدعوة';

  @override
  String get linkCopied => 'تم نسخ الرابط';

  @override
  String get codeCopied => 'تم نسخ الرمز';

  @override
  String get codeCopiedExcl => 'تم نسخ الرمز!';

  @override
  String get codeEnter => 'إدخال الرمز';

  @override
  String get codeCopy => 'نسخ الرمز';

  @override
  String get inviteFamilyMember => 'دعوة أحد أفراد العائلة';

  @override
  String get observation => 'تسجيل ملاحظة';

  @override
  String get observationNew => 'ملاحظة جديدة';

  @override
  String get observationsNone => 'لم يتم تسجيل ملاحظات بعد.';

  @override
  String get myObservations => 'ملاحظاتي';

  @override
  String get woundDoc => 'توثيق الجرح';

  @override
  String get woundNoEntries => 'لا توجد إدخالات جروح بعد.';

  @override
  String get woundPhotoForAnalysis => 'صورة الجرح للتحليل';

  @override
  String get woundChoosePhoto =>
      'اختر صورة لتحليل الجرح بالذكاء الاصطناعي مع بيلا';

  @override
  String get woundNoPhotos => 'لا تتوفر صور جروح للتحليل.';

  @override
  String get woundNoPhoto => 'لا تتوفر صورة للتحليل.';

  @override
  String get woundTakePhoto => '📷  التقط صورة جديدة';

  @override
  String get woundFromGallery => '🖼️  اختر من المعرض';

  @override
  String get woundMinPhotos => 'يلزم صورتان على الأقل للمقارنة.';

  @override
  String get woundCompare => 'مقارنة';

  @override
  String get woundSliderMix => 'مزيج شريط التمرير أ/ب';

  @override
  String get painLevel => 'مستوى الألم';

  @override
  String get painComparison => 'مقارنة مستوى الألم';

  @override
  String get painCourse7d => 'مسار الألم (٧ أيام)';

  @override
  String get painSaved => 'تم حفظ قيمة الألم';

  @override
  String painScoreOf10(int score) {
    return 'الألم: $score/١٠';
  }

  @override
  String painLevelOf10(int level) {
    return 'مستوى الألم: $level/١٠';
  }

  @override
  String get unbearable => 'لا يُحتمل';

  @override
  String get moodSaved => 'تم حفظ المزاج';

  @override
  String get moodDeleteConfirm => 'هل تريد فعلاً حذف هذا الإدخال؟';

  @override
  String get nutritionDescribeMeal => 'يرجى وصف وجبتك';

  @override
  String get nutritionSaved => 'تم حفظ الوجبة';

  @override
  String get nutritionRecipes => 'الوصفات';

  @override
  String get nutritionDailyGoals => 'الأهداف اليومية';

  @override
  String get vitalsMeasurementSaved => 'تم حفظ القياس';

  @override
  String vitalsNewMeasurementsSync(int count) {
    return 'تمت مزامنة $count قياسات جديدة من Health';
  }

  @override
  String get bodyData => 'بيانات الجسم';

  @override
  String get packingListReset => 'إعادة تعيين قائمة التعبئة؟';

  @override
  String get packingListNoItems => 'لا تتوفر عناصر في قائمة التعبئة.';

  @override
  String get packingListDelete => 'حذف القائمة؟';

  @override
  String get packingListRename => 'إعادة تسمية القائمة';

  @override
  String get packingListNew => 'قائمة جديدة';

  @override
  String get packingListName => 'اسم القائمة';

  @override
  String get packingListAddItem => 'إضافة عنصر';

  @override
  String get documentUpload => 'تحميل مستند';

  @override
  String get documentDeleteConfirm => 'حذف المستند؟';

  @override
  String get documentSavedLocally => 'تم حفظ المستند محلياً.';

  @override
  String get documentsOpen => 'فتح المستندات';

  @override
  String get documentsAll => 'جميع المستندات';

  @override
  String get noteDelete => 'حذف الملاحظة';

  @override
  String get noteSave => 'حفظ الملاحظة';

  @override
  String get noteDeleteError => 'خطأ في حذف الملاحظة';

  @override
  String get noteSaveError => 'خطأ في حفظ الملاحظة';

  @override
  String get voiceMemoSaved => 'تم حفظ المذكرة';

  @override
  String get voiceMemoDelete => 'حذف المذكرة؟';

  @override
  String get voiceStartRecording => 'بدء التسجيل';

  @override
  String get voiceNoMemos => 'لم يتم العثور على مذكرات.';

  @override
  String get voiceTranscriptSaved => 'تم حفظ النص';

  @override
  String get voiceNoTranscript => 'لا يوجد نص – يرجى النسخ أولاً.';

  @override
  String get voiceAudioNotFoundLocal => 'ملف الصوت غير موجود محلياً.';

  @override
  String get voiceAudioNotFound => 'ملف الصوت غير موجود.';

  @override
  String get voiceMicPermissionMissing => 'إذن الميكروفون مفقود.';

  @override
  String get profileEdit => 'تعديل الملف الشخصي';

  @override
  String get profileSaved => 'تم حفظ الملف الشخصي';

  @override
  String get profileSaveError => 'تعذر حفظ الملف الشخصي.';

  @override
  String get yourDetails => 'بياناتك';

  @override
  String get smokerStatus => 'حالة التدخين';

  @override
  String get hospitalClinic => 'المستشفى / العيادة';

  @override
  String get treatmentType => 'نوع العلاج *';

  @override
  String get opDate => 'تاريخ العملية *';

  @override
  String get currentOperation => 'العملية الحالية';

  @override
  String get operationArchived => 'تم أرشفة العملية';

  @override
  String get markOpComplete => 'تحديد العملية الحالية كمكتملة';

  @override
  String get stayType => 'نوع الإقامة';

  @override
  String get startDateOpDate => 'تاريخ البدء (مثلاً تاريخ العملية)';

  @override
  String get emergencyContact => 'جهة اتصال الطوارئ';

  @override
  String get transportPlanSaved => 'تم حفظ خطة النقل';

  @override
  String get healthOverview => 'نظرة عامة على صحتك';

  @override
  String get proUnlock => 'فتح Pro';

  @override
  String get proRedeemKey => 'استرداد مفتاح Pro';

  @override
  String get proKeys => 'مفاتيح Pro';

  @override
  String get proKeysCreate => 'إنشاء مفاتيح Pro';

  @override
  String get proGrantAccess => 'منح وصول Pro';

  @override
  String get proHowManyDays => 'كم يوماً من وصول Pro؟';

  @override
  String get proStatusChangeError => 'تعذر تغيير حالة Pro.';

  @override
  String get proManageSubscription => 'إدارة الاشتراك';

  @override
  String get proRestorePurchase => 'استعادة الشراء';

  @override
  String staffMember(String action) {
    return 'عضو الطاقم $action';
  }

  @override
  String get staffUpdated => 'تم تحديث عضو الطاقم';

  @override
  String get staffRemove => 'إزالة عضو الطاقم';

  @override
  String get staffCreate => 'إنشاء عضو طاقم';

  @override
  String get staffCreated => 'تم إنشاء عضو الطاقم';

  @override
  String get orgJoin => 'الانضمام إلى المنظمة';

  @override
  String get orgJoinWithCode => 'الانضمام برمز الدعوة';

  @override
  String get orgConfirm => 'تأكيد المنظمة';

  @override
  String get orgVerification => 'التحقق من المنظمة';

  @override
  String get ticketNew => 'تذكرة جديدة';

  @override
  String get ticketCreated => 'تم إنشاء التذكرة!';

  @override
  String get ticketClosed => 'تم إغلاق التذكرة.';

  @override
  String get ticketCloseConfirm => 'إغلاق التذكرة؟';

  @override
  String get ticketCloseExplanation => 'سيتم تحديد التذكرة كمغلقة.';

  @override
  String get tickets => 'التذاكر';

  @override
  String ticketsCountOpen(int count) {
    return 'التذاكر ($count مفتوحة)';
  }

  @override
  String get myTickets => 'تذاكري';

  @override
  String get messageSendError => 'تعذر إرسال الرسالة.';

  @override
  String get message => 'رسالة';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد.';

  @override
  String get questionAdd => 'إضافة سؤال';

  @override
  String get questionNew => 'سؤال جديد';

  @override
  String get questionCreate => 'إنشاء سؤال';

  @override
  String get questionDelete => 'حذف السؤال؟';

  @override
  String get loginToSaveQuestions => 'يرجى تسجيل الدخول لحفظ الأسئلة.';

  @override
  String get bellaSummarize => 'تلخيص مع بيلا';

  @override
  String get bellaAnalyze => 'تحليل مع بيلا';

  @override
  String get bellaGenerate => 'إنشاء الآن';

  @override
  String get bellaRegenerate => 'إعادة الإنشاء';

  @override
  String get bellaBriefingCopied => 'تم نسخ الملخص إلى الحافظة';

  @override
  String redFlagSaved(String level) {
    return 'تم حفظ فحص علامات التحذير ($level)';
  }

  @override
  String get severityCourse => 'مسار الشدة';

  @override
  String get lastFlags => 'آخر العلامات';

  @override
  String get lastEntries => 'آخر الإدخالات:';

  @override
  String get photoSaved => 'تم حفظ الصورة ومزامنتها.';

  @override
  String get photo => 'صورة';

  @override
  String get cameraOpening => 'جارٍ فتح الكاميرا…';

  @override
  String get entryDeleted => 'تم حذف الإدخال';

  @override
  String get entryDeleteConfirm => 'حذف الإدخال؟';

  @override
  String get entryDeleteIrreversible => 'سيتم حذف هذا الإدخال نهائياً.';

  @override
  String get entryDetailed => 'إدخال مفصّل';

  @override
  String get entryNew => 'إدخال جديد';

  @override
  String get minTwoEntriesForComparison => 'يلزم إدخالان على الأقل للمقارنة.';

  @override
  String get saveError => 'خطأ في الحفظ';

  @override
  String get saveFailed => 'فشل الحفظ';

  @override
  String get saveFailedDot => 'فشل الحفظ.';

  @override
  String get deleteError => 'خطأ في الحذف';

  @override
  String get disconnectError => 'خطأ في قطع الاتصال';

  @override
  String get restoreError => 'خطأ في الاستعادة';

  @override
  String get pinError => 'خطأ في التثبيت';

  @override
  String get unlockFailed => 'فشل فتح القفل.';

  @override
  String get lockFailed => 'فشل القفل.';

  @override
  String get deleteFailed => 'فشل الحذف.';

  @override
  String get actionFailed => 'فشل الإجراء.';

  @override
  String get dataLoadError => 'تعذر تحميل البيانات.';

  @override
  String get pageOpenError => 'تعذر فتح هذه الصفحة.';

  @override
  String get noLocalFile => 'لا يوجد ملف محلي.';

  @override
  String get fileNotFound => 'الملف غير موجود.';

  @override
  String get fileReadError => 'تعذرت قراءة الملف.';

  @override
  String get uploadPending => 'التحميل معلق. جارٍ إعادة المحاولة.';

  @override
  String get uploadFailedLocal => 'فشل التحميل – تم الحفظ محلياً.';

  @override
  String get noEmailApp => 'لم يتم العثور على تطبيق بريد إلكتروني';

  @override
  String get titleRequired => 'يرجى إدخال عنوان';

  @override
  String get titleAndMessageRequired => 'يجب ألا يكون العنوان والرسالة فارغين.';

  @override
  String get titleAndUrlRequired => 'العنوان والرابط مطلوبان.';

  @override
  String get urlInvalid => 'يرجى إدخال رابط http(s) كامل.';

  @override
  String get imageRequired => 'يرجى اختيار صورة لإعلان الشريك.';

  @override
  String get resultSaved => 'تم حفظ النتيجة';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة!';

  @override
  String get reportCopied => 'تم نسخ التقرير إلى الحافظة';

  @override
  String get allCopied => 'تم نسخ جميع المفاتيح إلى الحافظة!';

  @override
  String get allCopy => 'نسخ الكل';

  @override
  String get selectSpecialty => 'يرجى اختيار التخصص';

  @override
  String get selectMinOneSection => 'اختر قسماً واحداً على الأقل.';

  @override
  String errorGeneric(String error) {
    return 'خطأ: $error';
  }

  @override
  String get testNotificationCreated => 'تم إنشاء إشعار تجريبي.';

  @override
  String get companion => 'المرافق';

  @override
  String get timeline => 'الجدول الزمني';

  @override
  String get toTimeline => 'إلى الجدول الزمني';

  @override
  String get openDiary => 'فتح اليوميات';

  @override
  String get openFullDiary => 'فتح اليوميات الكاملة';

  @override
  String get checklists => 'قوائم المراجعة';

  @override
  String get categories => 'الفئات';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get statisticsLoadError => 'تعذر تحديث الإحصائيات.';

  @override
  String get statisticsLoading => 'جارٍ تحميل الإحصائيات...';

  @override
  String get tags => 'الوسوم';

  @override
  String get permissions => 'الصلاحيات';

  @override
  String get permissionsUpdated => 'تم تحديث الصلاحيات';

  @override
  String get myPermissions => 'صلاحياتي';

  @override
  String get readAllowed => 'السماح بالقراءة';

  @override
  String get writeAllowed => 'السماح بالكتابة';

  @override
  String get readOnly => 'قراءة فقط';

  @override
  String get read => 'قراءة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get general => 'عام';

  @override
  String get practice => 'العيادة';

  @override
  String get history => 'السجل';

  @override
  String get preview => 'معاينة';

  @override
  String get status => 'الحالة';

  @override
  String get role => 'الدور';

  @override
  String get roleChange => 'تغيير الدور';

  @override
  String get roleChangeError => 'تعذر تغيير الدور.';

  @override
  String get roleDistribution => 'توزيع الأدوار';

  @override
  String get markAsRead => 'تحديد كمقروء';

  @override
  String get unread => 'غير مقروء';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get accepted => 'مقبول';

  @override
  String get declined => 'مرفوض';

  @override
  String get resolved => 'تم الحل';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get locked => 'مقفل';

  @override
  String get full => 'كامل';

  @override
  String get off => 'إيقاف';

  @override
  String get system => 'النظام';

  @override
  String get user => 'المستخدم';

  @override
  String get overlayMode => 'وضع التراكب';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get noAccess => 'لا يوجد وصول';

  @override
  String get sureQuestion => 'هل أنت متأكد؟';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get disconnectConfirm => 'قطع الاتصال؟';

  @override
  String get disconnected => 'تم قطع الاتصال';

  @override
  String get connect => 'اتصال';

  @override
  String get connectionRemove => 'إزالة الاتصال';

  @override
  String get archive => 'أرشفة';

  @override
  String get restore => 'استعادة';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get editTitle => 'تعديل العنوان';

  @override
  String get filterReset => 'إعادة تعيين الفلتر';

  @override
  String get sendEmail => 'إرسال بريد إلكتروني';

  @override
  String get day => 'يوم';

  @override
  String get moreTools => 'أدوات إضافية';

  @override
  String get checkAgain => 'تحقق مجدداً';

  @override
  String get adDelete => 'حذف الإعلان؟';

  @override
  String adDeleteMessage(String title) {
    return 'سيتم حذف \"$title\" نهائياً.';
  }

  @override
  String get adGlobalSettings => 'الإعدادات العامة';

  @override
  String get adEnabled => 'الإعلانات مفعّلة';

  @override
  String get adGoogleAds => 'إعلانات Google';

  @override
  String get adAdmobBanner => 'عرض إعلانات بانر AdMob';

  @override
  String get adPartnerAds => 'إعلانات الشركاء';

  @override
  String adPartnerAdsCount(int count) {
    return 'إعلانات الشركاء ($count)';
  }

  @override
  String get adFrequency => 'التكرار';

  @override
  String get adPartnerCreate => 'إنشاء إعلان شريك';

  @override
  String get adminActivities7d => 'أنشطة الإدارة (٧ أيام)';

  @override
  String get adminActionDistribution7d => 'توزيع الإجراءات (٧ أيام)';

  @override
  String get adminNewRegistrations30d => 'التسجيلات الجديدة (٣٠ يوماً)';

  @override
  String get adminRegistrations => 'التسجيلات';

  @override
  String get adminStatusOverview => 'نظرة عامة على الحالة';

  @override
  String get adminAllRoles => 'جميع الأدوار';

  @override
  String get adminUserManage => 'إدارة المستخدمين';

  @override
  String get adminUserLock => 'قفل المستخدم';

  @override
  String get adminAuditLog => 'سجل المراجعة';

  @override
  String get adminLogsAppear => 'ستظهر السجلات هنا.';

  @override
  String get adminMaintenanceMode => 'تفعيل وضع الصيانة';

  @override
  String get adminMaintenanceError => 'تعذر تغيير وضع الصيانة.';

  @override
  String get adminFirebaseSmokeTest => 'اختبار Firebase السريع';

  @override
  String get declineRequest => 'رفض الطلب';

  @override
  String get requestDeclined => 'تم رفض الطلب';

  @override
  String get requestNotFound => 'الطلب غير موجود.';

  @override
  String get requestReactivate => 'إعادة تفعيل الطلب؟';

  @override
  String requestReactivated(String name) {
    return 'تم إعادة تفعيل طلب $name.';
  }

  @override
  String get reactivate => 'إعادة تفعيل';

  @override
  String get reactivationFailed => 'فشلت إعادة التفعيل.';

  @override
  String get verificationFailed => 'فشل التحقق.';

  @override
  String get declineReason => 'سبب الرفض';

  @override
  String get declineReasonAlt => 'سبب الرفض';

  @override
  String get internalCommentOptional => 'تعليق داخلي اختياري:';

  @override
  String get decline => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get revoke => 'إلغاء';

  @override
  String pushTo(String target) {
    return 'إرسال إشعار إلى $target';
  }

  @override
  String pushSent(String target) {
    return 'تم إرسال الإشعار إلى $target.';
  }

  @override
  String get pushSendError => 'تعذر إرسال الإشعار.';

  @override
  String get kneeArthroscopy => 'تنظير الركبة';

  @override
  String get uniClinicMunich => 'مستشفى جامعة ميونيخ';

  @override
  String get wakeTimeMustBeAfterBed =>
      'يجب أن يكون وقت الاستيقاظ بعد وقت النوم.';

  @override
  String get qrCodeScan => 'مسح رمز QR';

  @override
  String get releaseAll => 'إصدار الكل';

  @override
  String get keyActivate => 'تفعيل المفتاح';

  @override
  String get keyDeactivate => 'إلغاء تفعيل المفتاح؟';

  @override
  String get keyDeactivated => 'تم إلغاء تفعيل المفتاح.';

  @override
  String get keyCreated => 'تم إنشاء المفتاح';

  @override
  String get keyDeactivateError => 'تعذر إلغاء تفعيل المفتاح.';

  @override
  String get keyCreateError => 'تعذر إنشاء المفتاح.';

  @override
  String get keysLoadError => 'تعذر تحميل المفاتيح.';

  @override
  String validForDays(int days) {
    return 'صالح لمدة $days أيام';
  }

  @override
  String get validityDuration => 'مدة الصلاحية:';

  @override
  String get targetGroup => 'المجموعة المستهدفة';

  @override
  String get endTimeSet => 'تعيين وقت الانتهاء';

  @override
  String get keineEintraege => '  Keine Einträge';

  @override
  String get n10Maerz2026 => '10. März 2026';

  @override
  String get n15Maerz2026 => '15. März 2026';

  @override
  String get n3NeueAufgabenJedenTagNurFuerPro =>
      '3 neue Aufgaben jeden Tag – nur für Pro';

  @override
  String get n5Eintraege => '5 Einträge';

  @override
  String get alleGesundheitsdatenWurdenGeloescht =>
      'Alle Gesundheitsdaten wurden gelöscht.';

  @override
  String get alleDeineAktivitaetenAufEinenBlick =>
      'Alle deine Aktivitäten auf einen Blick';

  @override
  String get allesImGruenenBereich => 'Alles im grünen Bereich';

  @override
  String get angehoerige => 'Angehörige';

  @override
  String get angehoeriger => 'Angehöriger';

  @override
  String get anweisungenOeffnen => 'Anweisungen öffnen';

  @override
  String get anzeigeGeloescht => 'Anzeige gelöscht.';

  @override
  String get anaesthesiologie => 'Anästhesiologie';

  @override
  String get arztLoeschen => 'Arzt löschen?';

  @override
  String get arztBriefingIstAufWebNichtVerfuegbar =>
      'Arzt-Briefing ist auf Web nicht verfügbar.';

  @override
  String get atmungMobilitaet => 'Atmung & Mobilität';

  @override
  String get auffaelligeAbsonderungAusDerWunde =>
      'Auffällige Absonderung aus der Wunde';

  @override
  String get aufklaerung => 'Aufklärung';

  @override
  String get aufklaerungsgespraech => 'Aufklärungsgespräch';

  @override
  String get auswaehlen => 'Auswählen';

  @override
  String get automatischeUeberwachung => 'Automatische Überwachung';

  @override
  String get bedarfsmedikationOderZusaetzlicheEinnahme =>
      'Bedarfsmedikation oder zusätzliche Einnahme';

  @override
  String get begruendung => 'Begründung';

  @override
  String get bellaGedaechtnis => 'Bella Gedächtnis';

  @override
  String get berechtigungenAendern => 'Berechtigungen ändern';

  @override
  String get berichtFuer714Oder30TageErstellen =>
      'Bericht für 7, 14 oder 30 Tage erstellen.';

  @override
  String get bestehtSchuettelfrost => 'Besteht Schüttelfrost?';

  @override
  String get bestaetigt => 'Bestätigt';

  @override
  String get bitteAuswaehlen => 'Bitte auswählen';

  @override
  String get bitteGebenSieEineGueltigeEMailEin =>
      'Bitte geben Sie eine gültige E-Mail ein.';

  @override
  String get breitetSichDieRoetungAus => 'Breitet sich die Rötung aus?';

  @override
  String get datumAuswaehlen => 'Datum auswählen';

  @override
  String get deinWochenRueckblick => 'Dein Wochen-Rückblick';

  @override
  String get deinPersoenlicherOpAssistent => 'Dein persönlicher OP-Assistent';

  @override
  String get deineAngehoerigenBleibenInformiertUndKoennenDichBesser =>
      'Deine Angehörigen bleiben informiert und können dich besser unterstützen.';

  @override
  String get deineSprachUndTextnotizenSindDirektMitDeinerOpDoku =>
      'Deine Sprach- und Textnotizen sind direkt mit deiner OP-Dokumentation verknüpft.';

  @override
  String get derAppStoreIstNichtVerfuegbarBittePruefeDeineNetzwer =>
      'Der App Store ist nicht verfügbar. Bitte prüfe deine Netzwerkverbindung.';

  @override
  String get derStoreIstGeradeNichtVerfuegbarBitteVersucheEsErne =>
      'Der Store ist gerade nicht verfügbar. Bitte versuche es erneut.';

  @override
  String get dieAppWirdWiederFuerAlleNutzerZugaenglich =>
      'Die App wird wieder für alle Nutzer zugänglich.';

  @override
  String get dieseInformationenHelfenUnsDeinenPersoenlichenCarePla =>
      'Diese Informationen helfen uns, deinen persönlichen Care Plan zu erstellen.';

  @override
  String get dosisFuerDiesenZeitpunktOptional =>
      'Dosis für diesen Zeitpunkt (optional)';

  @override
  String get duEntscheidestWelcheDatenDeineAngehoerigenSehenSchme =>
      'Du entscheidest, welche Daten deine Angehörigen sehen: Schmerz, Vitals, Termine und mehr.';

  @override
  String get duGehstMitKlarheitInsKontrollgespraechDasGibtSicherh =>
      'Du gehst mit Klarheit ins Kontrollgespräch. Das gibt Sicherheit – dir und deinem Arzt.';

  @override
  String get einPreisFuerDieGesamteOpUndNachsorgephase =>
      'Ein Preis für die gesamte OP- und Nachsorgephase.';

  @override
  String get eingeloest => 'Eingelöst';

  @override
  String get eingeloestVon => 'Eingelöst von';

  @override
  String get einigeDatenKonntenNichtGeloeschtWerden =>
      'Einige Daten konnten nicht gelöscht werden.';

  @override
  String get eintraege => 'Einträge';

  @override
  String get einzelneWerteLeichtAusserhalbDesNormalbereichsBitteBe =>
      'Einzelne Werte leicht außerhalb des Normalbereichs. Bitte beobachten.';

  @override
  String get entdeckeNeueFunktionenInDeinerAppJetztOeffnen =>
      'Entdecke neue Funktionen in deiner App. Jetzt öffnen!';

  @override
  String get erhalteAlleInfosSchrittFuerSchritt =>
      'Erhalte alle Infos Schritt für Schritt.';

  @override
  String get erhoehtesRisiko => 'Erhöhtes Risiko';

  @override
  String get erinnerungszeitWaehlen => 'Erinnerungszeit wählen';

  @override
  String get ernaehrung => 'Ernährung';

  @override
  String get ernaehrungHeute => 'Ernährung heute';

  @override
  String get ernaehrungstagebuch => 'Ernährungstagebuch';

  @override
  String get erstelleEinArztBriefingFuerMeinenNaechstenTermin =>
      'Erstelle ein Arzt-Briefing für meinen nächsten Termin.';

  @override
  String get erzaehlUnsVonDeinerOp => 'Erzähl uns von deiner OP';

  @override
  String get fehlerBeimLoeschen => 'Fehler beim Löschen.';

  @override
  String get flexibelJederzeitKuendbar => 'Flexibel – jederzeit kündbar';

  @override
  String get fragenFuerDenArzt => 'Fragen für den Arzt';

  @override
  String get fragenFuerDenArztNotieren => 'Fragen für den Arzt notieren →';

  @override
  String get faellig => 'Fällig';

  @override
  String get faelligeUndErledigteAufgaben => 'Fällige und erledigte Aufgaben';

  @override
  String get fuegeDeineOpInformationenHinzu =>
      'Füge deine OP‑Informationen hinzu.';

  @override
  String get fuehlenSieSichBenommenOderSchwindelig =>
      'Fühlen Sie sich benommen oder schwindelig?';

  @override
  String get fuehlenSieSichSchwindeligOderSchwach =>
      'Fühlen Sie sich schwindelig oder schwach?';

  @override
  String get fuerPushBenachrichtigungenBenoetigstDuEinKonto =>
      'Für Push-Benachrichtigungen benötigst du ein Konto.';

  @override
  String get gefaesschirurgie => 'Gefäßchirurgie';

  @override
  String get gespraecheFuerArztOderAngehoerigeTeilen =>
      'Gespräche für Arzt oder Angehörige teilen';

  @override
  String get gleichtaegigeEntlassung => 'Gleichtägige Entlassung';

  @override
  String get groesse => 'Größe';

  @override
  String get gruen => 'Grün';

  @override
  String get gynaekologie => 'Gynäkologie';

  @override
  String get gueltigkeitInTagen => 'Gültigkeit (in Tagen)';

  @override
  String get halteGedankenFragenUndNotizenAlsAudioFestJederzei =>
      'Halte Gedanken, Fragen und Notizen als Audio fest – jederzeit abhörbar.';

  @override
  String get haltenSieIhreTaeglicheRoutineBei =>
      'Halten Sie Ihre tägliche Routine bei';

  @override
  String get hatDasSekretEineUngewoehnlicheFarbe =>
      'Hat das Sekret eine ungewöhnliche Farbe?';

  @override
  String get hatSichDieMengeDesSekretsErhoeht =>
      'Hat sich die Menge des Sekrets erhöht?';

  @override
  String get helfenIhreUeblichenSchmerzmittelNichtMehr =>
      'Helfen Ihre üblichen Schmerzmittel nicht mehr?';

  @override
  String get heuteFaellig => 'Heute fällig';

  @override
  String get hinterlegeOptionalEinenNotfallkontaktUndUeberpruefeDeine =>
      'Hinterlege optional einen Notfallkontakt und überprüfe deine Angaben.';

  @override
  String get hoereZu => 'Höre zu …';

  @override
  String get huefte => 'Hüfte';

  @override
  String get in24HErneutPruefen => 'In 24 h erneut prüfen';

  @override
  String get istDerSchmerzbereichGeschwollenOderHeiss =>
      'Ist der Schmerzbereich geschwollen oder heiß?';

  @override
  String get istDerVerbandBereitsKomplettDurchnaesst =>
      'Ist der Verband bereits komplett durchnässt?';

  @override
  String get istDieStelleWarmOderHeiss => 'Ist die Stelle warm oder heiß?';

  @override
  String get jedeDokumentierteEinheitIstEinBeweisDuTustEtwasFuer =>
      'Jede dokumentierte Einheit ist ein Beweis: Du tust etwas für deine Genesung.';

  @override
  String get jedenMorgenDeinPersoenlicherUeberblick =>
      'Jeden Morgen dein persönlicher Überblick';

  @override
  String get kannIchMeinenAccountLoeschen => 'Kann ich meinen Account löschen?';

  @override
  String get keineBeruehrungDerWundeKeineManipulationKeineCremes =>
      'Keine Berührung der Wunde, keine Manipulation, keine Cremes/Salben';

  @override
  String get keineEintraege2 => 'Keine Einträge.';

  @override
  String get keineLueckenMehrImGespraech => 'Keine Lücken mehr im Gespräch';

  @override
  String get keineSchmerzeintraegeVorhanden =>
      'Keine Schmerzeinträge vorhanden.';

  @override
  String get keineUnsicherheitBeiDauerUndWiederholungenDerTimerF =>
      'Keine Unsicherheit bei Dauer und Wiederholungen. Der Timer führt dich durch jede Einheit.';

  @override
  String get keineWundeintraegeVorhanden => 'Keine Wundeinträge vorhanden.';

  @override
  String get keineFrueherenKaeufeGefunden => 'Keine früheren Käufe gefunden.';

  @override
  String get kritischeWerteErkanntSofortigeAerztlicheHilfeEmpfohlen =>
      'Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.';

  @override
  String get kraeftigung => 'Kräftigung';

  @override
  String get koerperregionHaeufigkeit => 'Körperregion-Häufigkeit';

  @override
  String get leichteAuffaelligkeit => 'Leichte Auffälligkeit';

  @override
  String get letzteAktivitaeten => 'Letzte Aktivitäten';

  @override
  String get liegtDieTemperaturUeber385C =>
      'Liegt die Temperatur über 38,5 °C?';

  @override
  String get linkZumDirektenOeffnenDerApp => 'Link zum direkten Öffnen der App';

  @override
  String get lizenzschluesselErstellenVerwalten =>
      'Lizenzschlüssel erstellen & verwalten';

  @override
  String get loeschen => 'LÖSCHEN';

  @override
  String get loeschung => 'Löschung';

  @override
  String get mehrereWerteAuffaelligKontaktierenSieIhrenArztZeitnah =>
      'Mehrere Werte auffällig. Kontaktieren Sie Ihren Arzt zeitnah.';

  @override
  String get meineAerzte => 'Meine Ärzte';

  @override
  String get mind2EintraegeFuerChart => 'Mind. 2 Einträge für Chart';

  @override
  String get mindestens2EintraegeFuerTrendanalyseBenoetigt =>
      'Mindestens 2 Einträge für Trendanalyse benötigt.';

  @override
  String get maessig => 'Mäßig';

  @override
  String get neueBeobachtungenVonAerztenBegleitern =>
      'Neue Beobachtungen von Ärzten & Begleitern';

  @override
  String get nichtVerfuegbareBereiche => 'Nicht verfügbare Bereiche';

  @override
  String get nochKeineErnaehrungseintraege => 'Noch keine Ernährungseinträge';

  @override
  String get nochKeineSchlafeintraege => 'Noch keine Schlafeinträge';

  @override
  String get nochKeineSchmerzeintraege => 'Noch keine Schmerzeinträge';

  @override
  String get nochKeineStimmungseintraege => 'Noch keine Stimmungseinträge';

  @override
  String get nochKeineWundeintraege => 'Noch keine Wundeinträge';

  @override
  String get nochKeineAerzteInDerOrganisation =>
      'Noch keine Ärzte in der Organisation.';

  @override
  String get nochKeinePatientenInDerOrganisation =>
      'TODO:ar: Noch keine Patienten in der Organisation.';

  @override
  String get nochNichtGenugGemeinsameTageFuerEineKorrelation =>
      'Noch nicht genug gemeinsame Tage für eine Korrelation.';

  @override
  String get notierenSieIhreAktuellenBeschwerdenUndDerenStaerke =>
      'Notieren Sie Ihre aktuellen Beschwerden und deren Stärke.';

  @override
  String get nurDieRelevantenDatenEinschliessen =>
      'Nur die relevanten Daten einschließen.';

  @override
  String get naechsteGeplanteEinnahme => 'Nächste geplante Einnahme.';

  @override
  String get naechsterSchritt => 'Nächster Schritt';

  @override
  String get naechte => 'Nächte';

  @override
  String get opAufklaerungen => 'OP-Aufklärungen';

  @override
  String get offlineEingeschraenkterModus => 'Offline • Eingeschränkter Modus';

  @override
  String get orgaRegistrierungenPruefen => 'Orga-Registrierungen prüfen';

  @override
  String get oSaettigung => 'O₂-Sättigung';

  @override
  String get pinBestaetigen => 'PIN bestätigen';

  @override
  String get pinsStimmenNichtUeberein => 'PINs stimmen nicht überein';

  @override
  String get passwortAendern => 'Passwort ändern';

  @override
  String get passwoerterStimmenNichtUeberein =>
      'Passwörter stimmen nicht überein.';

  @override
  String get patientenverknuepfung => 'Patientenverknüpfung';

  @override
  String get plaeneAnsehen => 'Pläne ansehen';

  @override
  String get ploetzlichZunehmendNichtKontrollierbar =>
      'Plötzlich zunehmend, nicht kontrollierbar';

  @override
  String get prioritaetAendern => 'Priorität ändern';

  @override
  String get praeOp => 'Prä-OP';

  @override
  String get qualitaet => 'Qualität';

  @override
  String get roetung => 'Rötung';

  @override
  String get ruecken => 'Rücken';

  @override
  String get rueckgaengig => 'Rückgängig';

  @override
  String get sammleErfahrungspunkteFuerJedeAktionUndSteigeImLevel =>
      'Sammle Erfahrungspunkte für jede Aktion und steige im Level auf.';

  @override
  String get schilddruesenOp36Jahre => 'Schilddrüsen-OP, 36 Jahre';

  @override
  String get schlafqualitaet => 'Schlafqualität';

  @override
  String get schmerzMedikamenteWundeUndVitalsGebuendeltDeinArzt =>
      'Schmerz, Medikamente, Wunde und Vitals gebündelt. Dein Arzt sieht sofort, was wichtig ist.';

  @override
  String get sektionenWaehlen => 'Sektionen wählen';

  @override
  String get sindDieSchmerzenDeutlichStaerkerAlsGewohnt =>
      'Sind die Schmerzen deutlich stärker als gewohnt?';

  @override
  String get stationaer => 'Stationär';

  @override
  String get statusAendern => 'Status ändern';

  @override
  String get strukturierteEinschaetzungDeinerWundheilung =>
      'Strukturierte Einschätzung deiner Wundheilung';

  @override
  String get stoerungen => 'Störungen';

  @override
  String get symptomePruefen => 'Symptome prüfen';

  @override
  String get saetze => 'Sätze';

  @override
  String get temperaturUeber385C => 'Temperatur über 38,5 °C';

  @override
  String get triggerHaeufigkeit => 'Trigger-Häufigkeit';

  @override
  String get tutorialWirdBeimNaechstenStartAngezeigt =>
      'Tutorial wird beim nächsten Start angezeigt.';

  @override
  String get umAngehoerigeEinzuladenBenoetigstDuEinKonto =>
      'Um Angehörige einzuladen, benötigst du ein Konto.';

  @override
  String get umPatientenZuBegleitenBenoetigstDuEinKonto =>
      'Um Patienten zu begleiten, benötigst du ein Konto.';

  @override
  String get umProFreizuschaltenBenoetigstDuEinKonto =>
      'Um Pro freizuschalten, benötigst du ein Konto.';

  @override
  String get umDeinProfilZuVerwaltenBenoetigstDuEinKonto =>
      'Um dein Profil zu verwalten, benötigst du ein Konto.';

  @override
  String get umEinenArztZuVerbindenBenoetigstDuEinKonto =>
      'Um einen Arzt zu verbinden, benötigst du ein Konto.';

  @override
  String get umAerzteZuVerwaltenBenoetigstDuEinKonto =>
      'Um Ärzte zu verwalten, benötigst du ein Konto.';

  @override
  String get ungueltigeServerAntwort => 'Ungültige Server-Antwort';

  @override
  String get universitaetsklinikumMuenchen => 'Universitätsklinikum München';

  @override
  String get unveraendert => 'Unverändert';

  @override
  String get userLoeschenDsgvo => 'User löschen (DSGVO)?';

  @override
  String get verbindungsfehlerBittePruefeDeineInternetverbindung =>
      'Verbindungsfehler. Bitte prüfe deine Internetverbindung.';

  @override
  String get verfolgeDeineWundheilungMitFotosUndEintraegenImZeitli =>
      'Verfolge deine Wundheilung mit Fotos und Einträgen im zeitlichen Verlauf.';

  @override
  String get verspuerenSieUebelkeitOderBrechreiz =>
      'Verspüren Sie Übelkeit oder Brechreiz?';

  @override
  String get visualisiereDeineTaeglicheAktivitaet =>
      'Visualisiere deine tägliche Aktivität';

  @override
  String get vollstaendigerExport => 'Vollständiger Export';

  @override
  String get vorbereitetStattUeberfordert => 'Vorbereitet statt überfordert';

  @override
  String get wieFuehlenSieSich => 'Wie fühlen Sie sich?';

  @override
  String get wieKannIchMeinProAboKuendigen =>
      'Wie kann ich mein Pro-Abo kündigen?';

  @override
  String get wiederOeffnen => 'Wieder öffnen';

  @override
  String get willkommenZurueck => 'Willkommen zurück!';

  @override
  String get wundbereichWirktEntzuendet => 'Wundbereich wirkt entzündet';

  @override
  String get waehleDeinenPlan => 'Wähle deinen Plan';

  @override
  String get waehleEinenModusZumVergleichen =>
      'Wähle einen Modus zum Vergleichen';

  @override
  String get zeigtDieWundeAuffaelligkeitenRoetungSekret =>
      'Zeigt die Wunde Auffälligkeiten (Rötung, Sekret)?';

  @override
  String get zeitraumWaehlbar => 'Zeitraum wählbar';

  @override
  String get zuletztGeaendertVor30Tagen => 'Zuletzt geändert vor 30 Tagen';

  @override
  String get zunehmendeRoetungSchwellung => 'Zunehmende Rötung / Schwellung';

  @override
  String get zusaetzlicheDetails => 'Zusätzliche Details…';

  @override
  String get stationaer2 => 'stationär';

  @override
  String get zBZahnbuerste => 'z.B. Zahnbürste';

  @override
  String get aeltesteZuerst => 'Älteste zuerst';

  @override
  String get aendern => 'Ändern';

  @override
  String get aenderungenSpeichern => 'Änderungen speichern';

  @override
  String get aerzte => 'Ärzte';

  @override
  String get aerztlichenRatEinholen => 'Ärztlichen Rat einholen';

  @override
  String get oeffnen => 'Öffnen';

  @override
  String get qualitaet2 => 'Ø Qualität';

  @override
  String get uebelRiechendesSekret => 'Übel riechendes Sekret';

  @override
  String get uebelkeit => 'Übelkeit';

  @override
  String get ueberfaellig => 'Überfällig';

  @override
  String get uebersicht => 'Übersicht';

  @override
  String get uebersichtlichesLayoutZumAusdrucken =>
      'Übersichtliches Layout zum Ausdrucken.';

  @override
  String get uebersprungen => 'Übersprungen';

  @override
  String get symptomHaeufigkeit => '⚠️ Symptom-Häufigkeit';

  @override
  String get scSeverityNone => 'لا شيء';

  @override
  String get scSeverityMild => 'خفيف';

  @override
  String get scSeverityModerate => 'متوسط';

  @override
  String get scSeveritySevere => 'شديد';

  @override
  String get scLevelGreen => 'أخضر';

  @override
  String get scLevelYellow => 'أصفر';

  @override
  String get scLevelRed => 'أحمر';

  @override
  String get scLevelTitleYellow => 'يرجى المراقبة';

  @override
  String get scRecommendGreen =>
      'أعراضك طبيعية. استمر في التوثيق المنتظم واتبع خطة تعافيك.';

  @override
  String get scRecommendYellow =>
      'بعض الأعراض طفيفة غير طبيعية. راقب التطور خلال الـ 24 ساعة القادمة. اتصل بطبيبك إذا تدهورت الحالة.';

  @override
  String get scRecommendRed =>
      'تشير أعراضك إلى احتمال وجود مضاعفات. اتصل بطبيبك فوراً أو اذهب إلى أقرب غرفة طوارئ.';

  @override
  String get scSymPain => 'ألم';

  @override
  String get scSymNausea => 'غثيان';

  @override
  String get scSymBreathing => 'التنفس';

  @override
  String get scSymDizziness => 'دوار';

  @override
  String get scSymWound => 'حالة الجرح';

  @override
  String get scSymPainSub => 'ما مدى شدة ألمك في منطقة العملية؟';

  @override
  String get scSymNauseaSub => 'هل تشعر بالغثيان أو الرغبة في التقيؤ؟';

  @override
  String get scSymBreathingSub =>
      'هل تعاني من صعوبة في التنفس أو ضيق في التنفس؟';

  @override
  String get scSymDizzinessSub => 'هل تشعر بالدوار أو بالدوخة؟';

  @override
  String get scSymWoundSub =>
      'هل تظهر على الجرح علامات غير طبيعية (احمرار، إفرازات)؟';

  @override
  String get scTitle => 'فحص الأعراض';

  @override
  String get scSymptomsSection => 'تقييم الأعراض';

  @override
  String get scYourInputs => 'بياناتك';

  @override
  String get scIntroBody =>
      'قيّم كل عَرَض. في النهاية ستحصل على تقييم مع توصية.';

  @override
  String get scSetDailyReminder => 'إعداد تذكير يومي';

  @override
  String get scActionsTitle => 'الإجراءات الموصى بها';

  @override
  String get scSaveResult => 'احفظ النتيجة';

  @override
  String get scSaving => 'جارٍ الحفظ…';

  @override
  String get scSaved => 'تم الحفظ ✓';

  @override
  String scResultBadge(String label) {
    return 'النتيجة: $label';
  }

  @override
  String scReminderActive(String time) {
    return 'تذكير: $time';
  }

  @override
  String scReminderSet(String time) {
    return 'تم ضبط التذكير على $time';
  }

  @override
  String get nichtHinterlegt => 'غير مُدخَل';

  @override
  String get fieldName => 'الاسم';

  @override
  String get fieldPhone => 'رقم الهاتف';

  @override
  String get fieldWeight => 'الوزن';

  @override
  String get fieldSmoker => 'مدخِّن';

  @override
  String get fieldOpType => 'نوع العملية';

  @override
  String get fieldOpDate => 'تاريخ العملية';

  @override
  String get fieldOpModus => 'وضع العملية';

  @override
  String get fieldHospitalPhone => 'هاتف المستشفى';

  @override
  String get fieldDoctorPhone => 'هاتف الطبيب';

  @override
  String get eiBloodType => 'فصيلة الدم';

  @override
  String get eiAllergies => 'الحساسيات';

  @override
  String get eiInsurance => 'التأمين';

  @override
  String get eiHospital => 'المستشفى';

  @override
  String get eiConditions => 'أمراض سابقة';

  @override
  String get eiMedications => 'الأدوية';

  @override
  String get eiOfflineBanner =>
      'لا يوجد اتصال – يُرجى تحميل معلومات الطوارئ عند توفر الإنترنت.';

  @override
  String get eiNoDataHint =>
      'لم يتم تخزين بيانات الطوارئ.\nأدخل بياناتك في ملفك الشخصي.';

  @override
  String get eiOpenProfile => 'فتح الملف الشخصي';

  @override
  String get eiShareHeader => '🆘 معلومات الطوارئ';

  @override
  String get eiShareEmergency => 'طوارئ: 112';

  @override
  String get eiSummaryNameHint => 'مثال: أحمد محمد';

  @override
  String get eiSummaryPhoneHint => 'مثال: +966 50 1234567';

  @override
  String get eiSummaryOpType => 'نوع العملية';

  @override
  String get eiSummaryOpDateUnknown => 'غير معلوم بعد';

  @override
  String get eiSummaryTreatment => 'العلاج';

  @override
  String get eiSummaryAmbulant => 'علاج خارجي';

  @override
  String eiShareBloodType(String value) {
    return 'فصيلة الدم: $value';
  }

  @override
  String eiShareAllergies(String value) {
    return 'الحساسيات: $value';
  }

  @override
  String eiShareContact(String name) {
    return 'جهة الاتصال في حالات الطوارئ: $name';
  }

  @override
  String eiSharePhone(String value) {
    return 'هاتف: $value';
  }

  @override
  String eiShareHospital(String name) {
    return 'المستشفى: $name';
  }

  @override
  String eiShareHospitalPhone(String value) {
    return 'هاتف المستشفى: $value';
  }

  @override
  String eiShareDoctor(String name) {
    return 'الطبيب: $name';
  }

  @override
  String eiShareDoctorPhone(String value) {
    return 'هاتف الطبيب: $value';
  }

  @override
  String eiShareInsurance(String value) {
    return 'التأمين: $value';
  }

  @override
  String get notfallInfoTeilen => 'مشاركة معلومات الطوارئ';

  @override
  String get notruf112 => 'الطوارئ 112';

  @override
  String get fehlerSpeichernErneut => 'خطأ في الحفظ. حاول مجدداً.';

  @override
  String get fehlerBeimSpeichern => 'خطأ في الحفظ.';

  @override
  String get woWirstDuBehandelt => 'أين ستتلقى العلاج؟';

  @override
  String get fastGeschafft => 'اقتربت من الانتهاء!';

  @override
  String get opClinic => 'العيادة';

  @override
  String get deinGesundheitsprofil => 'ملفك الصحي';

  @override
  String get aktuelleMedikamente => 'الأدوية الحالية';

  @override
  String get oPTypEingeben => 'أدخل نوع العملية';

  @override
  String get mitKrankenhausaufenthalt => 'مع إقامة في المستشفى';

  @override
  String get profilGespeichertKurz => 'تم حفظ الملف الشخصي';

  @override
  String get koerperwerteUndGesundheit => 'قيم الجسم والصحة';

  @override
  String get notfallkontaktUndNotfallInfo =>
      'جهة الاتصال في حالات الطوارئ والمعلومات';

  @override
  String get bezeichnungEingeben => 'أدخل التسمية';

  @override
  String get pINAktivieren => 'تفعيل رمز PIN';

  @override
  String get n4StelligerZugangsPIN => 'رمز وصول مكون من 4 أرقام';

  @override
  String get proEntdecken => 'اكتشف Pro';

  @override
  String get aktuellesPasswort => 'كلمة المرور الحالية';

  @override
  String get passwortSpeichern => 'حفظ كلمة المرور';

  @override
  String labelHinzufuegen(String label) {
    return 'أضف $label';
  }

  @override
  String get vitalwerte => 'المعايير الحيوية';

  @override
  String get neueMessung => 'قياس جديد';

  @override
  String get systolisch => 'الانقباضي';

  @override
  String get diastolisch => 'الانبساطي';

  @override
  String get puls => 'النبض';

  @override
  String get normalSystolisch => 'الطبيعي: 90–140';

  @override
  String get normalDiastolisch => 'الطبيعي: 60–90';

  @override
  String get normalPuls => 'الطبيعي: 60–100';

  @override
  String get weitereWerteOptional => 'قيم إضافية (اختياري)';

  @override
  String get vitalsErinnerung => 'تذكير';

  @override
  String get taeglicheMesserinnerung => 'تذكير يومي بالقياس';

  @override
  String get temperatur => 'درجة الحرارة';

  @override
  String get normalTemperatur => 'الطبيعي: 36.0–37.5 °C';

  @override
  String get normalO2Saettigung => 'الطبيعي: 95–100 %';

  @override
  String get notizOptional => 'ملاحظة (اختياري)';

  @override
  String get mindZweiEintraege => 'مدخلان على الأقل للعرض';

  @override
  String get vitalsTipp =>
      'نصيحة: سجّل مؤشراتك الحيوية يومياً لاكتشاف الاتجاهات مبكراً.';

  @override
  String get chartLast5 => '5 مدخلات';

  @override
  String get chartDays7 => '7 أيام';

  @override
  String get chartDays30 => '30 يومًا';

  @override
  String get blutdruck => 'ضغط الدم';

  @override
  String get trageVitalwerteEin => 'أدخل مؤشراتك الحيوية الحالية.';

  @override
  String normalbereichValue(String min, String max, String unit) {
    return 'النطاق الطبيعي: $min–$max $unit';
  }

  @override
  String neueMessungenSync(int count) {
    return 'تمت مزامنة $count قياسات جديدة';
  }

  @override
  String get neueMessungEintragen => 'إضافة قياس جديد';

  @override
  String get messungGespeichert => 'تم حفظ القياس';

  @override
  String get schmerzfrei => 'بلا ألم';

  @override
  String get sehrStark => 'شديد جدًا';

  @override
  String get schmerztagebuch => 'يوميات الألم';

  @override
  String get wieStarkSindDeineSchmerzen => 'ما مدى شدة ألمك؟';

  @override
  String get woTutEsWeh => 'أين يؤلمك؟';

  @override
  String get optionalTippeAufEineRegion => 'اختياري – اضغط على منطقة';

  @override
  String get artDerSchmerzen => 'نوع الألم';

  @override
  String get optionalWieFuehltEsSichAn => 'اختياري – كيف يبدو الأمر؟';

  @override
  String get avgSiebenTage => 'متوسط 7 أيام';

  @override
  String get gesamt => 'المجموع';

  @override
  String get trendLabel => 'الاتجاه';

  @override
  String get minMax => 'الحد الأدنى / الحد الأقصى';

  @override
  String eintraegeInsgesamt(int count) {
    return '$count إدخال إجمالي';
  }

  @override
  String get mehrMitPro => 'المزيد مع Pro';

  @override
  String letzteEintraege(int count) {
    return 'آخر $count إدخالات';
  }

  @override
  String letzteEintraegeGratis(int count) {
    return 'آخر $count إدخالات (5 مجانًا)';
  }

  @override
  String get letzteEintraegeHeader => 'الإدخالات الأخيرة';

  @override
  String get alleAnzeigen => 'الكل →';

  @override
  String get gradesEben => 'الآن';

  @override
  String vorMinuten(int min) {
    return 'منذ $min دقيقة';
  }

  @override
  String vorStunden(int h) {
    return 'منذ $h ساعة';
  }

  @override
  String get gestern => 'أمس';

  @override
  String vorTagen(int days) {
    return 'منذ $days أيام';
  }

  @override
  String get ortOptional => 'الموقع (اختياري)';

  @override
  String get ausloeserOptional => 'المحفز (اختياري)';

  @override
  String get painEntryEditorNotizOptional => 'ملاحظة (اختيارية)';

  @override
  String get eintragBearbeiten => 'تعديل الإدخال';

  @override
  String get schmerzlevel => 'مستوى الألم';

  @override
  String get wann => 'متى؟';

  @override
  String get datumLabel => 'التاريخ';

  @override
  String get uhrzeitLabel => 'الوقت';

  @override
  String get dauerLabel => 'المدة';

  @override
  String get dauerhaft => 'مستمر';

  @override
  String minMinuten(int min) {
    return '$min دقيقة';
  }

  @override
  String stundenLabel(int h) {
    return '$h ساعة';
  }

  @override
  String get medikationLabel => 'الدواء';

  @override
  String get eintragLoeschen => 'حذف الإدخال';

  @override
  String get kalender => 'تقويم';

  @override
  String get proLabel => 'Pro';

  @override
  String get filterAktiv => 'الفلتر نشط';

  @override
  String get filtern => 'فلترة';

  @override
  String get koerperregion => 'منطقة الجسم';

  @override
  String get schmerzart => 'نوع الألم';

  @override
  String get insights => 'رؤى';

  @override
  String haeufigstesGebiet(String region) {
    return 'المنطقة الأكثر تكرارًا: $region';
  }

  @override
  String get keineEintraegeFilter => 'لا توجد إدخالات بهذه الفلاتر';

  @override
  String get nochKeineEintraege => 'لا توجد إدخالات حتى الآن';

  @override
  String get tippeAufNeuenEintrag => 'اضغط على \"+ إدخال جديد\" للبدء';

  @override
  String avgWert(String val) {
    return 'متوسط $val';
  }

  @override
  String get heute => 'اليوم';

  @override
  String get montag => 'الاثنين';

  @override
  String get dienstag => 'الثلاثاء';

  @override
  String get mittwoch => 'الأربعاء';

  @override
  String get donnerstag => 'الخميس';

  @override
  String get freitag => 'الجمعة';

  @override
  String get samstag => 'السبت';

  @override
  String get sonntag => 'الأحد';

  @override
  String get moKurz => 'إث';

  @override
  String get diKurz => 'ثل';

  @override
  String get miKurz => 'أر';

  @override
  String get doKurz => 'خم';

  @override
  String get frKurz => 'جم';

  @override
  String get saKurz => 'سب';

  @override
  String get soKurz => 'أح';

  @override
  String get keinSchmerz => 'لا ألم';

  @override
  String get kalenderMitProFreischalten => 'افتح التقويم مع Pro';

  @override
  String get keineDetails => 'لا تفاصيل';

  @override
  String get minLabel => 'الحد الأدنى';

  @override
  String get maxLabel => 'الحد الأقصى';

  @override
  String get bellaAnalyse => 'تحليل بيلا';

  @override
  String get emptyNoEntries => 'لا توجد إدخالات بعد';

  @override
  String get emptyWoundDocHint => 'وثّق تقدم شفائك بصور يومية.';

  @override
  String get ersteDokumentationStarten => 'بدء أول توثيق';

  @override
  String get neuesFotoAufnehmen => 'التقاط صورة جديدة';

  @override
  String get woundHubKoerperstelle => 'موضع الجسم';

  @override
  String get neuErfassen => 'إدخال جديد';

  @override
  String get verlaufVergleichen => 'مقارنة التقدم';

  @override
  String get koerperstelle => 'موضع الجسم';

  @override
  String get keinFotoAnalyse => 'لا توجد صورة.';

  @override
  String get n1FotoPflaster => '١. صورة: الضمادة';

  @override
  String get zeigtDenZustandDesVerbands => 'يُظهر حالة الضمادة';

  @override
  String get n2FotoWunde => '٢. صورة: الجرح';

  @override
  String get nachAbnehmenDesPflasters => 'بعد إزالة الضمادة';

  @override
  String get linksA => 'يسار (أ)';

  @override
  String get rechtsB => 'يمين (ب)';

  @override
  String schmerzScore(int score) {
    return 'مستوى الألم: $score/10';
  }

  @override
  String get fotoLadeFehler => 'تعذّر تحميل الصورة.';

  @override
  String get fotoHinzufuegen => 'إضافة صورة';

  @override
  String get koerperstelleOptional => 'موضع الجسم (اختياري)';

  @override
  String get woundCompareTitle => 'مقارنة الجرح';

  @override
  String get woundCompareSlider => 'التقدم';

  @override
  String get woundCompareCompare => 'مقارنة';

  @override
  String get emptyNoPhotos => 'لا توجد صور بعد.';

  @override
  String get emptyWoundCompareHint =>
      'أضف صوراً إلى توثيق الجرح لمقارنة التقدم.';

  @override
  String get wundDokumentationTitle => 'توثيق الجرح';

  @override
  String get woundNoPhotoYet => 'لا توجد صورة بعد';

  @override
  String get woundNoteHint => 'كيف يبدو الجرح؟ أي ملاحظات؟';

  @override
  String get notizLabel => 'ملاحظة';

  @override
  String get woundHistoryTitle => 'تاريخ الجرح';

  @override
  String get woundDiaryTitle => 'يوميات الجرح';

  @override
  String get woundDiarySubtitle =>
      'نظرة عامة زمنية على شفاء جرحك بالصور والملاحظات.';

  @override
  String get woundPhotoGuideTitle => 'دليل التصوير';

  @override
  String get woundPhotoGuideSubtitle => 'للتوثيق الجيد نوصي بصورتين يومياً:';

  @override
  String get woundPhotoTip =>
      'نصيحة: تأكد من الإضاءة الجيدة والتصوير من نفس الزاوية.';

  @override
  String get woundNoNotiz => 'لا توجد ملاحظة';

  @override
  String get woundDetailTitle => 'تفاصيل الجرح';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get woundDeleteConfirmMessage => 'سيتم حذف هذا الإدخال نهائياً.';

  @override
  String get woundMinEntriesForCompare =>
      'يلزم توفر إدخالين على الأقل للمقارنة.';

  @override
  String get woundDiscoveryTip =>
      'نصيحة: صوّر جرحك بانتظام – ستلاحظ التغييرات بنظرة واحدة.';

  @override
  String woundEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إدخالات',
      one: '1 إدخال',
    );
    return '$_temp0';
  }

  @override
  String get woundNoPhotoCaptured => 'لا توجد صورة';

  @override
  String get woundTapForDetails => 'اضغط للتفاصيل';

  @override
  String get woundComparePick2 => 'اختر صورتين للمقارنة';

  @override
  String get woundModeSplit => 'تقسيم';

  @override
  String get woundModeOverlay => 'تراكب';

  @override
  String woundComparePhotosSelected(int count) {
    return '$count / 2 صور مختارة';
  }

  @override
  String get woundCompareTapInstruction =>
      'اضغط على الصور أدناه التي تريد مقارنتها.';

  @override
  String get before => 'قبل';

  @override
  String get after => 'بعد';

  @override
  String get woundHygieneStep1 => 'اغسل يديك جيداً';

  @override
  String get woundHygieneStep2 => '🩹 تغيير الضمادة الجافة';

  @override
  String get woundHygieneStep3 => 'فحص الجرح: جاف؟ غير أحمر؟ لا نزيف طازج؟';

  @override
  String get woundHygieneStep4 => 'لا تلمس الجرح، لا تدخل، لا كريمات';

  @override
  String get woundHygieneStep5 => 'استبدل الضمادة دون لمس الوسادة';

  @override
  String get woundHygieneStep6 => 'اغسل يديك مرة أخرى';

  @override
  String get woundHygieneTitle => '🧴 توصيات نظافة الجرح';

  @override
  String get woundHygieneWarning => 'في حالة الاحمرار، يرجى الاتصال بعيادتك';

  @override
  String woundHygieneAckLabel(String date) {
    return '✅ تمت القراءة في $date';
  }

  @override
  String get kalorienKcal => 'السعرات الحرارية (كيلوكالوري)';

  @override
  String get nutritionProteinG => 'البروتين (جم)';

  @override
  String get wasserMl => 'الماء (مل)';

  @override
  String get nameDerVorlage => 'اسم القالب';

  @override
  String get zBHaferbreiMitBeeren => 'مثل: شوفان مع توت';

  @override
  String get zbVollkornbrot => 'مثل: خبز كامل مع جبن';

  @override
  String get proteinG => 'البروتين (جم)';

  @override
  String get nutritionKohlenhG => 'الكربوهيدرات (جم)';

  @override
  String get nutritionFettG => 'الدهون (جم)';

  @override
  String templateWirdEntfernt(String name) {
    return 'سيتم إزالة \"$name\" من قوالبك.';
  }

  @override
  String get naehrwerteOptional => 'قيم غذائية (اختياري)';

  @override
  String get kohlenhG => 'الكربوهيدرات (جم)';

  @override
  String get fettG => 'الدهون (جم)';

  @override
  String get getrunkenMl => 'كمية المشروب (مل)';

  @override
  String get vertraeglichkeit => 'قابلية التحمل';

  @override
  String get mahlzeitSpeichern => 'حفظ الوجبة';

  @override
  String wasserMlDescription(int ml) {
    return 'ماء $ml مل';
  }

  @override
  String wasserMlAdded(int ml) {
    return '+$ml مل ماء تم تسجيله';
  }

  @override
  String get vorlageLabel => 'قالب';

  @override
  String get wasserTracking => 'تتبع الماء';

  @override
  String get favoriten => 'المفضلة';

  @override
  String get tippeZumSchnellenWiederholen => 'اضغط للتكرار السريع';

  @override
  String get mahlzeitLabel => 'وجبة';

  @override
  String get wasHastDuGegessen => 'ماذا أكلت؟';

  @override
  String get optionalWasserTeeEtc => 'اختياري – ماء، شاي، إلخ';

  @override
  String get optionalWieVertragen => 'اختياري – كيف تحملت الوجبة؟';

  @override
  String get symptomeNachDemEssen => 'أعراض بعد الأكل';

  @override
  String get optionalTippeAuf => 'اختياري – اضغط على الأعراض المنطبقة';

  @override
  String get naehrwerteTitle => 'قيم غذائية';

  @override
  String get optionalKalorienProtein =>
      'اختياري – سعرات، بروتين، كربوهيدرات، دهون';

  @override
  String get vorlagenTitle => 'قوالب';

  @override
  String empfehlungFuerOp(String opType) {
    return 'توصية لعملية $opType';
  }

  @override
  String empfehlungFuerOpTag(int day) {
    return ' · يوم $day';
  }

  @override
  String get empfehlungenTitle => 'التوصيات';

  @override
  String heuteMahlzeitenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وجبات',
      one: 'وجبة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get kcalLabel => 'ك.كال';

  @override
  String get proteinLabel => 'بروتين';

  @override
  String get wasserLabel => 'ماء';

  @override
  String symptomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعراض',
      one: 'عرض واحد',
    );
    return '$_temp0';
  }

  @override
  String keineFilterEintraege(String mealType) {
    return 'لا توجد إدخالات $mealType';
  }

  @override
  String get ersteMahlzeitTipp => 'اضغط + لإضافة وجبتك الأولى.';

  @override
  String get beschreibungLabel => 'وصف';

  @override
  String get zbVollkornbrotQuark => 'مثل: خبز كامل مع جبن قريش وطماطم';

  @override
  String get zbZahl => 'مثل: 250';

  @override
  String get symptomeLabel => 'الأعراض';

  @override
  String get notizZuSymptomenOptional => 'ملاحظة عن الأعراض (اختياري)';

  @override
  String get eintrBearbeiten => 'تعديل الإدخال';

  @override
  String get neueMahlzeit => 'وجبة جديدة';

  @override
  String get eintrLoeschen => 'حذف الإدخال';

  @override
  String get mealTypeFruehstueck => 'إفطار';

  @override
  String get mealTypeMittagessen => 'غداء';

  @override
  String get mealTypeAbendessen => 'عشاء';

  @override
  String get mealTypeSnack => 'وجبة خفيفة';

  @override
  String get symptomUebelkeit => 'غثيان';

  @override
  String get symptomBlaehungen => 'انتفاخ';

  @override
  String get symptomSchmerzen => 'آلام';

  @override
  String get symptomSodbrennen => 'حرقة المعدة';

  @override
  String get symptomDurchfall => 'إسهال';

  @override
  String get symptomVerstopfung => 'إمساك';

  @override
  String get symptomMuedigkeit => 'تعب';

  @override
  String get symptomSonstige => 'أخرى';

  @override
  String get nochmal => 'مرة أخرى';

  @override
  String get ablaufNarkoseEingriffe => 'TODO:ar: Ablauf, Narkose, Eingriffe';

  @override
  String get abmelden => 'TODO:ar: Abmelden';

  @override
  String get adminAbmeldenBestaetigung =>
      'TODO:ar: Wirklich aus dem Admin-Bereich abmelden?';

  @override
  String get adminAktionenUndEreignisprotokoll =>
      'TODO:ar: Admin-Aktionen & Ereignisprotokoll';

  @override
  String get adminBenachrichtigungenUndEreignisse =>
      'TODO:ar: Admin-Benachrichtigungen & Ereignisse';

  @override
  String get aktivDieseWoche => 'TODO:ar: Aktiv diese Woche';

  @override
  String get aktiveProLizenzen => 'TODO:ar: Aktive Pro-Lizenzen';

  @override
  String get aktiveTage => 'TODO:ar: Aktive Tage';

  @override
  String get aktivHeute => 'TODO:ar: Aktiv heute';

  @override
  String get aktivitaetsHeatmap => 'TODO:ar: Aktivitäts-Heatmap';

  @override
  String get alertArztKontaktieren => 'TODO:ar: Arzt kontaktieren';

  @override
  String get alle => 'TODO:ar: Alle';

  @override
  String get alleAlsGelesenMarkieren => 'TODO:ar: Alle als gelesen markieren';

  @override
  String get alleFunktionenOhneEinschraenkung =>
      'TODO:ar: Alle Funktionen ohne Einschränkung';

  @override
  String get alleMarkieren => 'TODO:ar: Alle →';

  @override
  String get alsGelesen => 'TODO:ar: Als gelesen';

  @override
  String get alsPDFTeilen => 'TODO:ar: Als PDF teilen';

  @override
  String get alsTextKopieren => 'TODO:ar: Als Text kopieren';

  @override
  String get angehoerigeEinladenUndGemeinsamBegleiten =>
      'TODO:ar: Angehörige einladen & gemeinsam begleiten';

  @override
  String get angehoerigenEinladen => 'TODO:ar: Angehörigen einladen';

  @override
  String get anweisungNotiz => 'TODO:ar: Anweisung / Notiz';

  @override
  String get appointmentEditorRepeatUntil => 'TODO:ar: Wiederholen bis';

  @override
  String get apptAddFirstHint => 'اضغط + لإضافة موعدك الأول.';

  @override
  String get apptCancelAppt => 'إلغاء الموعد';

  @override
  String get apptConfirmationPending => 'في انتظار التأكيد';

  @override
  String get apptConfirmDeclineHint => 'يرجى التأكيد أو الرفض.';

  @override
  String get apptCreatedByDoctor => 'أُنشئ من قِبل الطبيب';

  @override
  String get apptDeleteTitle => 'حذف الموعد';

  @override
  String get apptEditTitle => 'تعديل الموعد';

  @override
  String get apptHintCustomMinutes => 'دقائق';

  @override
  String get apptHintDoctor => 'مثال: د. أحمد';

  @override
  String get apptHintLocation => 'مثال: مستشفى المدينة';

  @override
  String get apptHintLocationDetails => 'التفاصيل (الجناح، الغرفة)';

  @override
  String get apptHintNote => 'ملاحظة اختيارية…';

  @override
  String get apptHintTitle => 'مثال: موعد فحص';

  @override
  String get apptLabelCustomMinutes => 'دقائق';

  @override
  String get apptLabelDate => 'التاريخ';

  @override
  String get apptLabelDoctor => 'الطبيب / المعالج';

  @override
  String get apptLabelEndTime => 'وقت الانتهاء';

  @override
  String get apptLabelFurtherDetails => 'مزيد من التفاصيل';

  @override
  String get apptLabelFurtherReminders => 'تذكيرات إضافية';

  @override
  String get apptLabelLocation => 'المكان';

  @override
  String get apptLabelNote => 'ملاحظة';

  @override
  String get apptLabelPriority => 'الأولوية';

  @override
  String get apptLabelReminder => 'تذكير';

  @override
  String get apptLabelRepeatUntil => 'حتى';

  @override
  String get apptLabelStartTime => 'وقت البدء';

  @override
  String get apptLabelTime => 'الوقت';

  @override
  String get apptLabelTitleRequired => 'العنوان *';

  @override
  String get apptLabelType => 'النوع';

  @override
  String get apptMarkAsDone => 'وضع علامة كمنجز';

  @override
  String get apptMarkAsPlanned => 'وضع علامة كمخطط';

  @override
  String get apptNewTitle => 'موعد جديد';

  @override
  String get apptNoAppointments => 'لا مواعيد حتى الآن';

  @override
  String get apptNoResults => 'لا توجد نتائج';

  @override
  String get apptNoResultsHint => 'جرّب مصطلحات بحث أو فلاتر مختلفة.';

  @override
  String get apptPriorityHigh => 'عالية';

  @override
  String get apptPriorityLow => 'منخفضة';

  @override
  String get apptPriorityMedium => 'متوسطة';

  @override
  String get apptPriorityUrgent => 'عاجل';

  @override
  String get apptReminderAtTime => 'في الوقت المحدد';

  @override
  String get apptReminderCustom => 'مخصص';

  @override
  String get apptReminderDay1 => 'قبل يوم';

  @override
  String get apptReminderDays2 => 'قبل يومين';

  @override
  String get apptReminderHour1 => 'قبل ساعة';

  @override
  String get apptReminderHours2 => 'قبل ساعتين';

  @override
  String get apptReminderMin15 => 'قبل 15 دقيقة';

  @override
  String get apptReminderMin30 => 'قبل 30 دقيقة';

  @override
  String get apptReminderNone => 'لا شيء';

  @override
  String get apptRepeatDaily => 'يومياً';

  @override
  String get apptRepeatMonthly => 'شهرياً';

  @override
  String get apptRepeatNone => 'لا شيء';

  @override
  String get apptRepeatWeekly => 'أسبوعياً';

  @override
  String get apptSaving => 'جارٍ الحفظ…';

  @override
  String get apptStatusCanceled => 'ملغى';

  @override
  String get apptStatusCompleted => 'مكتمل';

  @override
  String get apptStatusConfirmed => 'مؤكد';

  @override
  String get apptStatusDeclined => 'مرفوض';

  @override
  String get apptStatusDone => 'منجز';

  @override
  String get apptStatusPending => 'معلق';

  @override
  String get apptStatusPlanned => 'مخطط';

  @override
  String get apptTitleRequired => 'العنوان مطلوب.';

  @override
  String get apptTodayNone => 'لا مواعيد اليوم';

  @override
  String get apptTodayTitle => 'مواعيد اليوم';

  @override
  String get apptTypeCall => 'مكالمة';

  @override
  String get apptTypeFollowUp => 'متابعة';

  @override
  String get apptTypeImaging => 'تصوير';

  @override
  String get apptTypeOther => 'أخرى';

  @override
  String get apptTypePhysio => 'علاج طبيعي';

  @override
  String get apptTypeSurgery => 'جراحة';

  @override
  String get apptViewCalendar => 'تقويم';

  @override
  String get apptViewList => 'قائمة';

  @override
  String get apptYesterday => 'أمس';

  @override
  String get arztBehandler => 'TODO:ar: Arzt / Behandler';

  @override
  String get arztEntsperren => 'TODO:ar: Arzt entsperren?';

  @override
  String get arztSofortKontaktieren => 'TODO:ar: Arzt sofort kontaktieren';

  @override
  String get arztSperren => 'TODO:ar: Arzt sperren?';

  @override
  String get arztUndPatienteneinladungen =>
      'TODO:ar: Arzt- & Patienteneinladungen';

  @override
  String get aufbauUndRoutine => 'TODO:ar: Aufbau & Routine';

  @override
  String get aufnahmeStartFehler =>
      'TODO:ar: Aufnahme konnte nicht gestartet werden.';

  @override
  String get aufProUpgraden => 'TODO:ar: Auf Pro upgraden';

  @override
  String get auswertungAnzeigen => 'TODO:ar: Auswertung anzeigen';

  @override
  String get bedarfsmedikationOderSpontaneEinnahmen =>
      'TODO:ar: Bedarfsmedikation oder spontane Einnahmen.';

  @override
  String get begruendungEingeben => 'TODO:ar: Begründung eingeben …';

  @override
  String get beiAkuterVerschlechterung =>
      'TODO:ar: Bei akuter Verschlechterung';

  @override
  String get beiVerschlechterungAnrufen =>
      'TODO:ar: Bei Verschlechterung anrufen';

  @override
  String get bellaActionCancelled => 'تم الإلغاء';

  @override
  String get bellaActionCreated => 'تم إنشاء الإدخال ✓';

  @override
  String get bellaActionFailed => 'فشل الإنشاء';

  @override
  String get bellaArztBriefing => 'TODO:ar: Bella Arzt-Briefing';

  @override
  String get bellaAskDirectly => 'أو اطرح سؤالاً مباشرةً:';

  @override
  String get bellaBriefingGenerating => 'Bella تنشئ ملخصك الطبي …';

  @override
  String get bellaBriefingIsProFeature => 'الموجز الطبي ميزة Pro';

  @override
  String get bellaBriefingNotSignedIn => 'يرجى تسجيل الدخول.';

  @override
  String get bellaBriefingPersonalTitle => 'ملخصك الطبي الشخصي';

  @override
  String get bellaBriefingProDescription =>
      'مع Pro تنشئ Bella ملخصاً شخصياً لموعدك الطبي القادم.';

  @override
  String get bellaChipAddTask => 'أضف مهمة: فحص الجرح';

  @override
  String get bellaChipAppFunctions => 'ما هي ميزات التطبيق؟';

  @override
  String get bellaChipCallDoctor => 'متى يجب أن أتصل بالطبيب؟';

  @override
  String get bellaChipCreateAppointment => 'أنشئ موعداً غداً الساعة 10 صباحاً';

  @override
  String get bellaChipDoctorBroadcast =>
      'TODO:ar: Nachricht an alle Patienten senden';

  @override
  String get bellaChipDoctorCreateAppointment =>
      'TODO:ar: Termin für Patient erstellen';

  @override
  String get bellaChipDoctorCreateTask =>
      'TODO:ar: Aufgabe für Patient erstellen';

  @override
  String get bellaChipDoctorCreateRedFlag =>
      'TODO:ar: Warnung für Patient erstellen';

  @override
  String get bellaChipDoctorDashboard => 'كيف تعمل لوحة تحكم الطبيب؟';

  @override
  String get bellaChipDoctorInvitePatient =>
      'TODO:ar: Neuen Patienten einladen';

  @override
  String get bellaChipDoctorReport => 'كيف أنشئ تقرير طبي؟';

  @override
  String get bellaChipGeneralDashboard => 'كيف تعمل لوحة التحكم؟';

  @override
  String get bellaChipKneeTep => 'معلومات عن استبدال الركبة';

  @override
  String get bellaChipLinkPatient => 'كيف أربط مريضاً؟';

  @override
  String get bellaChipLogBloodPressure => 'سجّل ضغط الدم 120/80';

  @override
  String get bellaChipLogMedication => 'تناولت إيبوبروفين للتو';

  @override
  String get bellaChipLogPain => 'سجّل الألم: الركبة، مستوى 4';

  @override
  String get bellaChipMedications => 'كيف أسجّل أدويتي؟';

  @override
  String get bellaChipManageDoctors => 'TODO:ar: Wie verwalte ich meine Ärzte?';

  @override
  String get bellaChipMyTasks => 'ما هي مهامي؟';

  @override
  String get bellaChipOpDay => 'ماذا يحدث في يوم الجراحة؟';

  @override
  String get bellaChipOrgBillingInfo =>
      'TODO:ar: Wie ist unser Abonnement-Status?';

  @override
  String get bellaChipOrgBroadcast =>
      'TODO:ar: Nachricht an alle Patienten senden';

  @override
  String get bellaChipOrgDashboard =>
      'TODO:ar: Zeig mir unsere Organisations-Übersicht';

  @override
  String get bellaChipOrgInviteDoctor => 'TODO:ar: Einen neuen Arzt einladen';

  @override
  String get bellaChipOrgStats => 'TODO:ar: Zeig mir unsere Statistiken';

  @override
  String get bellaChipPrepareOp => 'كيف أستعد للجراحة؟';

  @override
  String get bellaChipStaffCreateAppointment =>
      'TODO:ar: Termin für Patient erstellen';

  @override
  String get bellaChipStaffCreateTask =>
      'TODO:ar: Aufgabe für Patient erstellen';

  @override
  String get bellaChipStaffLogVital =>
      'TODO:ar: Vitalwerte für Patient eintragen';

  @override
  String get bellaChipSymptomCheck => 'بدء فحص الأعراض';

  @override
  String get bellaChipTimeline => 'كيف يعمل الجدول الزمني؟';

  @override
  String get bellaChipVerifyAccount => 'كيف أتحقق من حسابي كطبيب؟';

  @override
  String get bellaChipViewPatientData => 'كيف أطّلع على بيانات المريض؟';

  @override
  String get bellaChipViewPatientDataStaff => 'كيف أطّلع على بيانات المريض؟';

  @override
  String get bellaConsentAccepted => 'تم الموافقة';

  @override
  String get bellaConsentBody =>
      'يستخدم المساعد الذكي (Bella AI) خدمات خارجية للإجابة على أسئلتك:\n\n• يتم إرسال رسائل الدردشة إلى OpenAI (الولايات المتحدة).\n• لمستخدمي Pro: يتم إرسال البيانات الصحية المحلية (سجل الألم، العلامات الحيوية، الأدوية، التغذية، التحذيرات، مرحلة العملية) كسياق لتقديم إجابات أفضل.\n• يتم معالجة تحليلات صور الجروح عبر OpenAI (الولايات المتحدة) ويتم حذفها بعد التحليل.\n\nلا يتم تخزين أي بيانات بشكل دائم لدى الخدمات الخارجية. يمكنك سحب موافقتك في أي وقت من الإعدادات.\n\nالأساس القانوني: المادة 6(1)(أ) والمادة 9(2)(أ) من اللائحة العامة لحماية البيانات.';

  @override
  String get bellaConsentDeclined => 'تم رفض الموافقة';

  @override
  String get bellaConsentTitle => 'إشعار الخصوصية';

  @override
  String get bellaConsentYes => 'نعم، أوافق';

  @override
  String get bellaDailyAnalysis => 'تحليل Bella اليومي';

  @override
  String get bellaDefaultWoundPrompt => 'يرجى تحليل صورة الجرح هذه.';

  @override
  String get bellaDescriptionDoctor =>
      'أساعدك في استخدام لوحة تحكم الطبيب، وإدارة المرضى والأسئلة السريرية.';

  @override
  String get bellaDescriptionOrganisation =>
      'TODO:ar: Ich helfe dir bei der Verwaltung deiner Organisation, Ärzten, Mitarbeitern und Statistiken.';

  @override
  String get bellaDescriptionPatient =>
      'أجيب على أسئلتك حول عمليتك الجراحية والرعاية اللاحقة والتطبيق.';

  @override
  String get bellaDescriptionStaff =>
      'أساعدك في استخدام لوحة تحكم الموظفين ورعاية المرضى.';

  @override
  String get bellaDisclaimer =>
      'بيلا ليست بديلاً عن الاستشارة الطبية. للشكاوى الصحية يرجى استشارة طبيبك.';

  @override
  String get bellaFeatureAftercare => 'الرعاية اللاحقة';

  @override
  String get bellaFeatureAppHelp => 'مساعدة التطبيق';

  @override
  String get bellaFeatureBilling => 'TODO:ar: Abrechnung';

  @override
  String get bellaFeatureDashboard => 'لوحة التحكم';

  @override
  String get bellaFeatureDoctors => 'TODO:ar: Ärzte';

  @override
  String get bellaFeatureMedicalKnowledge => 'معلومات الجراحة';

  @override
  String get bellaFeatureOrgStats => 'TODO:ar: Statistiken';

  @override
  String get bellaFeaturePatients => 'المرضى';

  @override
  String get bellaFeatureTasks => 'المهام';

  @override
  String get bellaFeatureTeam => 'TODO:ar: Team';

  @override
  String get bellaFeatureWarnings => 'علامات التحذير';

  @override
  String get bellaGreeting => 'مرحباً! أنا Bella AI 🐰';

  @override
  String get bellaNoAnswerReceived =>
      'لم يتم تلقي إجابة. يرجى المحاولة مجدداً. 🐰';

  @override
  String get bellaProactivePainTrend =>
      'مستوى ألمك في ارتفاع – هل تريد التحدث عن ذلك؟';

  @override
  String get bellaProUpgrade => 'الترقية إلى Pro الآن';

  @override
  String get bellaSays => 'Bella تقول:';

  @override
  String get bellaSubtitleDoctor => 'مساعدك السريري 🐰';

  @override
  String get bellaSubtitleOrganisation =>
      'TODO:ar: Dein Organisations-Assistent 🐰';

  @override
  String get bellaSubtitlePatient => 'مرشدك لعملية الجراحة 🐰';

  @override
  String get bellaSubtitleStaff => 'مساعد العيادة 🐰';

  @override
  String get bellaWoundAnalysisTitle => 'تحليل الجرح';

  @override
  String get bellaWoundDisclaimer =>
      'لا يغني عن التشخيص الطبي. عند الشك، تواصل مع فريقك الطبي.';

  @override
  String get bellaWoundObservations => 'الملاحظات';

  @override
  String get bellaWoundProgressComparison => 'مقارنة التقدم';

  @override
  String get beobachtenSieDieSymptomeGenau =>
      'TODO:ar: Beobachten Sie die Symptome genau';

  @override
  String get beobachtungHinzufuegen => 'TODO:ar: Beobachtung hinzufügen';

  @override
  String get beschreibeAnliegen =>
      'TODO:ar: Beschreibe dein Anliegen so genau wie möglich…';

  @override
  String get beschreibenSieIhreSymptome =>
      'TODO:ar: Beschreiben Sie Ihre Symptome';

  @override
  String get besterPreisProMonat => 'TODO:ar: Bester Preis pro Monat';

  @override
  String get broadcastSenden => 'TODO:ar: Broadcast senden';

  @override
  String get calendarAddedSuccess => 'تمت إضافة الموعد إلى التقويم';

  @override
  String get calendarAddToCalendarBody =>
      'هل تريد إضافة هذا الموعد إلى تقويم جهازك أو مشاركته كملف .ics؟';

  @override
  String get calendarExportFailed => 'فشل تصدير التقويم';

  @override
  String get calendarMonth => 'شهر';

  @override
  String get calendarNoEvents => 'لا مواعيد في هذا اليوم';

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get calendarWeek => 'أسبوع';

  @override
  String get chronologischDokumentierteEinnahmen =>
      'TODO:ar: Chronologisch dokumentierte Einnahmen.';

  @override
  String get codeZumManuellenEingeben => 'TODO:ar: Code zum manuellen Eingeben';

  @override
  String get csvExportieren => 'TODO:ar: CSV exportieren';

  @override
  String get dashboardPushSenden => 'TODO:ar: Push senden';

  @override
  String get dauer => 'TODO:ar: Ø Dauer';

  @override
  String get deepLink => 'TODO:ar: Deep Link';

  @override
  String get discoverSubtitle => 'TODO:ar: Alle Funktionen auf einen Blick';

  @override
  String get discoverTitle => 'TODO:ar: Entdecken';

  @override
  String get doctorProfileMeinProfil => 'TODO:ar: Mein Profil';

  @override
  String get doctorReportSchmerztagebuchLetzte7Tage =>
      'TODO:ar: Schmerztagebuch letzte 7 Tage';

  @override
  String get doctorReportWunddokuLetzte3 => 'TODO:ar: Wunddoku letzte 3';

  @override
  String get doctorStatsCardSchmerzlevel => 'TODO:ar: Ø Schmerzlevel';

  @override
  String get dokumenteLetzte3 => 'TODO:ar: Dokumente letzte 3';

  @override
  String get dokumenteOeffnenTeilen => 'TODO:ar: Öffnen / Teilen';

  @override
  String get dokumentiereWundenUnterWunddoku =>
      'TODO:ar: Dokumentiere Wunden unter Wunddoku';

  @override
  String get einladungscode => 'TODO:ar: Einladungscode';

  @override
  String get einladungTeilen => 'TODO:ar: Einladung teilen';

  @override
  String get erfasseMedikamenteImMedikamentenplan =>
      'TODO:ar: Erfasse Medikamente im Medikamentenplan';

  @override
  String get erfasseSchmerzwerteImSchmerztagebuch =>
      'TODO:ar: Erfasse Schmerzwerte im Schmerztagebuch';

  @override
  String get erfasseVitalwerteUnterVitals =>
      'TODO:ar: Erfasse Vitalwerte unter Vitaldaten';

  @override
  String get erinnerungErstellen => 'TODO:ar: Erinnerung erstellen';

  @override
  String get erneutPruefen => 'TODO:ar: Erneut prüfen';

  @override
  String get errorAlreadyExists => 'TODO:ar: Bereits vorhanden.';

  @override
  String get errorCancelled => 'TODO:ar: Vorgang abgebrochen.';

  @override
  String get errorDeadlineExceeded =>
      'TODO:ar: Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String get errorEmailInUse =>
      'TODO:ar: Diese E-Mail-Adresse wird bereits verwendet.';

  @override
  String get errorFailedPrecondition =>
      'TODO:ar: Aktion kann nicht durchgeführt werden.';

  @override
  String get errorInvalidArgument => 'TODO:ar: Ungültige Eingabe.';

  @override
  String get errorInvalidEmail => 'TODO:ar: Ungültige E-Mail-Adresse.';

  @override
  String get errorNoInternet =>
      'TODO:ar: Keine Internetverbindung. Bitte Netzwerk prüfen.';

  @override
  String get errorNotFound => 'TODO:ar: Nicht gefunden. Bitte Eingabe prüfen.';

  @override
  String get errorNotFoundShort => 'TODO:ar: Nicht gefunden.';

  @override
  String get errorOperationNotAllowed =>
      'TODO:ar: Diese Aktion ist nicht erlaubt.';

  @override
  String get errorPermissionDenied =>
      'TODO:ar: Keine Berechtigung für diese Aktion.';

  @override
  String get errorPleaseSignIn => 'TODO:ar: Bitte anmelden.';

  @override
  String get errorRequiresRecentLogin =>
      'TODO:ar: Bitte erneut anmelden, um fortzufahren.';

  @override
  String get errorResourceExhausted =>
      'TODO:ar: Zu viele Anfragen. Bitte einen Moment warten.';

  @override
  String get errorServiceUnavailable =>
      'TODO:ar: Der Dienst ist vorübergehend nicht verfügbar. Bitte später erneut versuchen.';

  @override
  String get errorServiceUnavailableShort =>
      'TODO:ar: Der Dienst ist vorübergehend nicht verfügbar.';

  @override
  String get errorTooManyRequests =>
      'TODO:ar: Zu viele Versuche. Bitte später erneut versuchen.';

  @override
  String get errorUserDisabled => 'TODO:ar: Dieses Konto wurde deaktiviert.';

  @override
  String get errorUserNotFound =>
      'TODO:ar: Kein Konto mit dieser E-Mail-Adresse gefunden.';

  @override
  String get errorWeakPassword => 'TODO:ar: Das Passwort ist zu schwach.';

  @override
  String get errorWrongPassword => 'TODO:ar: Falsches Passwort.';

  @override
  String get ersteListeErstellen => 'TODO:ar: Erste Liste erstellen';

  @override
  String get erstelltAm => 'TODO:ar: Erstellt am';

  @override
  String get ersteNotizErstellen => 'TODO:ar: Erste Notiz erstellen';

  @override
  String get erstesItemHinzufuegen => 'TODO:ar: Erstes Item hinzufügen';

  @override
  String get ersteVorlageErstellen => 'TODO:ar: Erste Vorlage erstellen';

  @override
  String get esIstEinFehlerAufgetretenBitteVersucheEsErneut =>
      'TODO:ar: Es ist ein Fehler aufgetreten. Bitte versuche es erneut.';

  @override
  String get exportFehlgeschlagen => 'TODO:ar: Export fehlgeschlagen.';

  @override
  String get familyMemberHubZBA1B2C3D4E5F6 => 'TODO:ar: z.B. A1B2C3D4E5F6';

  @override
  String get familyPatientsMeinePatienten => 'TODO:ar: Meine Patienten';

  @override
  String get familyPatientsZBA1B2C3D4E5F6 => 'TODO:ar: z.B. A1B2C3D4E5F6';

  @override
  String get familyProfileZBA1B2C3D4E5F6 => 'TODO:ar: z.B. A1B2C3D4E5F6';

  @override
  String get fehlerBeimErstellen => 'TODO:ar: Fehler beim Erstellen.';

  @override
  String get fehlerBeimLaden => 'TODO:ar: Fehler beim Laden.';

  @override
  String get firebaseUIDDesArztes => 'TODO:ar: Firebase UID des Arztes';

  @override
  String get footerLoveMessage =>
      'TODO:ar: Mit Liebe für deine Genesung entwickelt';

  @override
  String get fotosDurchsuchen =>
      'TODO:ar: Fotos suchen (Datum, Notiz, Kategorie)…';

  @override
  String get frageAnBella => 'TODO:ar: Frage an Bella …';

  @override
  String get frageBearbeiten => 'TODO:ar: Frage bearbeiten';

  @override
  String get frageStellen => 'TODO:ar: Frage stellen …';

  @override
  String get freischalten => 'TODO:ar: Freischalten';

  @override
  String get funktionenErklaert => 'TODO:ar: Funktionen erklärt';

  @override
  String get grundDerSperrung => 'TODO:ar: Grund der Sperrung…';

  @override
  String get grundEingeben => 'TODO:ar: Grund eingeben…';

  @override
  String get grundOptional => 'TODO:ar: Grund (optional)';

  @override
  String get helpHilfeUndSupport => 'TODO:ar: Hilfe & Support';

  @override
  String get heuteDokumentiert => 'TODO:ar: Heute dokumentiert';

  @override
  String get hilfeUndSupport => 'TODO:ar: Hilfe & Support';

  @override
  String get hinterlegeDeineOPDetailsImProfil =>
      'TODO:ar: Hinterlege deine OP-Details im Profil';

  @override
  String get hinweistextOptional => 'TODO:ar: Hinweistext (optional)';

  @override
  String get homeSummaryCardFaellig => 'TODO:ar: fällig';

  @override
  String get ihreAntwortEingeben => 'TODO:ar: Antwort eingeben…';

  @override
  String get inaktiv3Tage => 'TODO:ar: Inaktiv >3 Tage';

  @override
  String get itemBearbeiten => 'TODO:ar: Item bearbeiten';

  @override
  String get jaehrlich => 'TODO:ar: Jährlich';

  @override
  String get jederzeitNkuendbar => 'TODO:ar: Jederzeit\\nkündbar';

  @override
  String get keineAufgabenImPlan => 'TODO:ar: Noch keine Aufgaben im Plan.';

  @override
  String get keineEmailApp => 'TODO:ar: Keine E-Mail-App gefunden';

  @override
  String get keineOffenenEinladungen => 'TODO:ar: Keine offenen Einladungen.';

  @override
  String get keinePatienenGefunden => 'TODO:ar: Keine Patienten gefunden.';

  @override
  String get keinUebernachtenNurDasNoetigste =>
      'TODO:ar: Kein Übernachten – nur das Nötigste';

  @override
  String get keyIdOderUidSuchen => 'TODO:ar: Key-ID oder Einlöser-UID suchen…';

  @override
  String get kontaktierenSieIhrenArzt => 'TODO:ar: Kontaktieren Sie Ihren Arzt';

  @override
  String get kVNummerOptional => 'TODO:ar: KV-Nummer (optional)';

  @override
  String get letzteDokumente => 'TODO:ar: Letzte Dokumente';

  @override
  String get letzteEinnahmen => 'TODO:ar: Letzte Einnahmen';

  @override
  String get letzteVitalwerte => 'TODO:ar: Letzte Vitalwerte';

  @override
  String get linkKopieren => 'TODO:ar: Link kopieren';

  @override
  String get losGehts => 'TODO:ar: Los geht\'s!';

  @override
  String get medikament => 'TODO:ar: Medikament *';

  @override
  String get meilensteineUndZiele => 'TODO:ar: Meilensteine & Ziele';

  @override
  String get meinProfil => 'TODO:ar: Mein Profil';

  @override
  String get memosDurchsuchen => 'TODO:ar: Memos durchsuchen…';

  @override
  String get mitArztVerbinden => 'TODO:ar: Mit Arzt verbinden';

  @override
  String get mitMedikation => 'TODO:ar: Mit Medikation';

  @override
  String get mitUebernachtungVollstaendigeListe =>
      'TODO:ar: Mit Übernachtung – vollständige Liste';

  @override
  String get monatlichKuendbar => 'TODO:ar: monatlich kündbar';

  @override
  String get monthApril => 'أبريل';

  @override
  String get monthAugust => 'أغسطس';

  @override
  String get monthDecember => 'ديسمبر';

  @override
  String get monthFebruary => 'فبراير';

  @override
  String get monthJanuary => 'يناير';

  @override
  String get monthJuly => 'يوليو';

  @override
  String get monthJune => 'يونيو';

  @override
  String get monthMarch => 'مارس';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthNovember => 'نوفمبر';

  @override
  String get monthOctober => 'أكتوبر';

  @override
  String get monthSeptember => 'سبتمبر';

  @override
  String get n7TageTreue => 'TODO:ar: 7-Tage Treue';

  @override
  String get nachrichtSchreiben => 'TODO:ar: Nachricht schreiben...';

  @override
  String get nachRolleFiltern => 'TODO:ar: Nach Rolle filtern';

  @override
  String get naechsteTermine => 'TODO:ar: Nächste Termine';

  @override
  String get neuerKey => 'TODO:ar: Neuer Key';

  @override
  String get neuerName => 'TODO:ar: Neuer Name';

  @override
  String get neuesPacklistenItem => 'TODO:ar: Neues Packlisten-Item';

  @override
  String get neuesPasswort => 'TODO:ar: Neues Passwort';

  @override
  String get nochKeineAngehoerigenVerbunden =>
      'TODO:ar: Noch keine Angehörigen verbunden.';

  @override
  String get nochKeineBeobachtungen => 'TODO:ar: Noch keine Beobachtungen.';

  @override
  String get nochKeineDokumentation => 'TODO:ar: Noch keine Dokumentation';

  @override
  String get notaufnahmeAufsuchen => 'TODO:ar: Notaufnahme aufsuchen';

  @override
  String get notificationCenterNotizOptional => 'TODO:ar: Notiz (optional)';

  @override
  String get notruf112Anrufen => 'TODO:ar: Notruf 112 anrufen';

  @override
  String get nurInDebugBuilds => 'TODO:ar: Nur in Debug-Builds verfügbar.';

  @override
  String get nurVomArztVerwaltbar => 'TODO:ar: Nur vom Arzt verwaltbar';

  @override
  String get nutzerGesamt => 'TODO:ar: Nutzer gesamt';

  @override
  String get oeffnenTeilen => 'TODO:ar: Öffnen / Teilen';

  @override
  String get offeneFragen => 'TODO:ar: Offene Fragen';

  @override
  String get offeneRedFlags => 'TODO:ar: Offene Warnsignale';

  @override
  String get ohneMedikation => 'TODO:ar: Ohne Medikation';

  @override
  String get opActions => 'TODO:ar: Aktionen';

  @override
  String get oPDatum => 'TODO:ar: OP Datum';

  @override
  String opDatumKurz(int day, int month, int year) {
    return 'TODO:ar: OP: $day.$month.$year';
  }

  @override
  String get opDetails => 'TODO:ar: OP-Details';

  @override
  String get opDocumentsLabel => 'TODO:ar: Dokumente';

  @override
  String get opManageCaregivers => 'TODO:ar: Begleiter\nverwalten';

  @override
  String get opName => 'TODO:ar: OP-Name';

  @override
  String get opSymptomsLabel => 'TODO:ar: Symptome';

  @override
  String get opTimeline => 'TODO:ar: Timeline';

  @override
  String get opType => 'TODO:ar: OP-Typ';

  @override
  String get oPUndTimeline => 'TODO:ar: OP & Timeline';

  @override
  String get packingItemEditorSheetNotizOptional => 'TODO:ar: Notiz (optional)';

  @override
  String get patientAuswaehlen => 'TODO:ar: Patient auswählen';

  @override
  String get patientAuswaehlenUmDetailsAnzuzeigen =>
      'TODO:ar: Patient auswählen, um Details anzuzeigen';

  @override
  String get patientBasisdaten => 'TODO:ar: Patient Basisdaten';

  @override
  String get patientSuchen => 'TODO:ar: Patient suchen…';

  @override
  String get patienten => 'TODO:ar: Patienten';

  @override
  String patientenAnzahl(int count) {
    return 'TODO:ar: Patienten ($count)';
  }

  @override
  String get patientenBegleiten => 'TODO:ar: Patienten begleiten';

  @override
  String get perEMail => 'TODO:ar: Per E-Mail';

  @override
  String get placeholderLoading => 'جاري التحميل…';

  @override
  String get praxisnameOptional => 'TODO:ar: Praxisname (optional)';

  @override
  String get prioritaet => 'TODO:ar: Priorität';

  @override
  String get profilGespeichert => 'TODO:ar: Profil gespeichert.';

  @override
  String get proKeyErstellen => 'TODO:ar: Pro-Key erstellen';

  @override
  String get proSatz => 'TODO:ar: pro Satz';

  @override
  String get proStatus => 'TODO:ar: Pro Status';

  @override
  String get pushBenachrichtigungenVersenden =>
      'TODO:ar: Push-Benachrichtigungen versenden';

  @override
  String get pushPushSenden => 'TODO:ar: Push senden?';

  @override
  String get pushSenden => 'TODO:ar: Push';

  @override
  String get recoveryFeed => 'TODO:ar: Genesungs-Feed';

  @override
  String get redU2011FlagSystem => 'TODO:ar: Red\\u2011Flag System';

  @override
  String get reportSchmerz => 'TODO:ar: Schmerz-Ø';

  @override
  String get reportTagePostOP => 'TODO:ar: Tage post-OP';

  @override
  String get rfActiveWarnings => 'التحذيرات النشطة';

  @override
  String get rfCheckStart => 'بدء الفحص';

  @override
  String get rfEmergencyFollowSteps => 'اتبع هذه الخطوات بالترتيب.';

  @override
  String get rfEmergencyInstructions => 'تعليمات الطوارئ';

  @override
  String get rfEmergencyStep1Desc => 'اجلس أو استلقِ. تنفس بهدوء.';

  @override
  String get rfEmergencyStep1Title => 'ابقَ هادئاً';

  @override
  String get rfEmergencyStep2Desc => 'دوِّن شكاواك الحالية وشدتها.';

  @override
  String get rfEmergencyStep2Title => 'افحص الأعراض';

  @override
  String get rfEmergencyStep3Desc => 'اتصل بطبيبك أو العيادة وصف الأعراض.';

  @override
  String get rfEmergencyStep3Title => 'اتصل بالطبيب';

  @override
  String get rfEmergencyStep4Desc =>
      'عند ضيق التنفس أو فقدان الوعي أو النزيف الشديد اتصل بـ 112 فوراً.';

  @override
  String get rfEmergencySubtitle =>
      'إجراءات فورية عند ضيق التنفس أو فقدان الوعي أو النزيف الشديد.';

  @override
  String get rfEscalate => 'تصعيد';

  @override
  String get rfNoActiveWarnings => 'لا توجد تحذيرات نشطة. استمر!';

  @override
  String get rfNoFlags => 'لا توجد أعلام حمراء';

  @override
  String get rfProAutoDetect =>
      'مع Pro يكشف النظام تلقائياً عن القيم الحرجة من الألم والعلامات الحيوية والمزيد.';

  @override
  String get rfProFeatureSubtitle => 'أدخل الشكاوى يدوياً أو ترقَّ إلى Pro.';

  @override
  String get rfProFeatureTitle => 'الكشف التلقائي عن الأعلام الحمراء ميزة Pro.';

  @override
  String get rfSeverityDescGreen => 'قيمك ضمن النطاق الطبيعي. استمر!';

  @override
  String get rfSeverityDescOrange =>
      'قيم متعددة غير طبيعية. راجع طبيبك قريباً.';

  @override
  String get rfSeverityDescRed =>
      'تم رصد قيم حرجة. يُوصى بالرعاية الطبية الفورية.';

  @override
  String get rfSeverityDescYellow =>
      'بعض القيم خارج النطاق الطبيعي قليلاً. يرجى المراقبة.';

  @override
  String get rfSeverityOrange => 'برتقالي';

  @override
  String get rfSeverityRed => 'أحمر';

  @override
  String get rfSeverityTitleGreen => 'كل شيء على ما يرام';

  @override
  String get rfSeverityTitleOrange => 'خطر مرتفع';

  @override
  String get rfSeverityTitleRed => 'تصرف الآن';

  @override
  String get rfSeverityTitleYellow => 'اضطراب طفيف';

  @override
  String get rfSeverityYellow => 'أصفر';

  @override
  String get rfSourceManual => 'يدوي';

  @override
  String get rfSourceObservation => 'ملاحظة';

  @override
  String get rfSourcePain => 'ألم';

  @override
  String get rfSourceSymptomCheck => 'فحص الأعراض';

  @override
  String get rfSourceTimeline => 'مهمة الجدول الزمني';

  @override
  String get rfSourceVitals => 'العلامات الحيوية';

  @override
  String get rfSourceWarningCheck => 'فحص التحذير';

  @override
  String get rfSourceWound => 'بيانات الجرح';

  @override
  String get rfStatusAcknowledged => 'مشاهَد';

  @override
  String get rfStatusEscalated => 'متصاعد';

  @override
  String get rfStatusMonitoring => 'مراقبة';

  @override
  String get rfStatusOpen => 'مفتوح';

  @override
  String get rfStatusResolved => 'محلول';

  @override
  String get rfWarningCheckSubtitle =>
      'فحص سريع لأهم الأعراض – يستغرق 30 ثانية فقط.';

  @override
  String get roleDebug => 'TODO:ar: Role Debug';

  @override
  String get rolleAuswaehlen => 'TODO:ar: Rolle auswählen';

  @override
  String get scannbarerCodeZumBeitreten =>
      'TODO:ar: Scannbarer Code zum Beitreten';

  @override
  String get schalteLevelXPTrackingUndMehrFrei =>
      'TODO:ar: Schalte Level, XP-Tracking und mehr frei';

  @override
  String get schlaf => 'TODO:ar: Ø Schlaf';

  @override
  String get schlafOptional => 'TODO:ar: Schlaf (optional)';

  @override
  String get schmerz => 'TODO:ar: Ø Schmerz';

  @override
  String get schmerztagebuchLetzte7Tage =>
      'TODO:ar: Schmerztagebuch letzte 7 Tage';

  @override
  String get schmerztrend7Tage => 'TODO:ar: Schmerztrend (7 Tage)';

  @override
  String get searchHint => 'TODO:ar: Suchen…';

  @override
  String get sectionAccompany => 'TODO:ar: Begleitung';

  @override
  String get sectionAdsAdmin => 'TODO:ar: Ads Admin';

  @override
  String get sectionAnalysis => 'TODO:ar: Analyse';

  @override
  String get sectionAnalytics => 'TODO:ar: Analytik';

  @override
  String get sectionConnectDoctor => 'TODO:ar: Arzt verbinden';

  @override
  String get sectionDebugTools => 'TODO:ar: Debug Tools';

  @override
  String get sectionDoctorQuestions => 'TODO:ar: Arztfragen';

  @override
  String get sectionDoctorReport => 'TODO:ar: Arztbericht';

  @override
  String get sectionDocumentation => 'TODO:ar: Dokumentation';

  @override
  String get sectionDocuments => 'TODO:ar: Dokumente';

  @override
  String get sectionEmergencyInfo => 'TODO:ar: Notfallinformationen';

  @override
  String get sectionFirebaseTest => 'TODO:ar: Firebase Test';

  @override
  String get sectionHealth => 'TODO:ar: Gesundheit';

  @override
  String get sectionHealthReport => 'TODO:ar: Gesundheitsbericht';

  @override
  String get sectionHelp => 'TODO:ar: Hilfe';

  @override
  String get sectionLanguage => 'TODO:ar: Sprache';

  @override
  String get sectionMedication => 'TODO:ar: Medikamente';

  @override
  String get sectionMood => 'TODO:ar: Stimmung';

  @override
  String get sectionNotifications => 'TODO:ar: Benachrichtigungen';

  @override
  String get sectionNutrition => 'TODO:ar: Ernährung';

  @override
  String get sectionOpInfo => 'TODO:ar: OP-Informationen';

  @override
  String get sectionOpPlanning => 'TODO:ar: OP & Planung';

  @override
  String get sectionPackingList => 'TODO:ar: Packliste';

  @override
  String get sectionPain => 'TODO:ar: Schmerzen';

  @override
  String get sectionPeople => 'TODO:ar: Personen';

  @override
  String get sectionPhotos => 'TODO:ar: Fotos';

  @override
  String get sectionProfile => 'TODO:ar: Profil';

  @override
  String get sectionProgress => 'TODO:ar: Fortschritt';

  @override
  String get sectionRecentlyUsed => 'TODO:ar: Zuletzt genutzt';

  @override
  String get sectionRedFlags => 'TODO:ar: Warnsignale';

  @override
  String get sectionRehabilitation => 'TODO:ar: Rehabilitation';

  @override
  String get sectionRoleDebug => 'TODO:ar: Role Debug';

  @override
  String get sectionSleep => 'TODO:ar: Schlaf';

  @override
  String get sectionSymptomCheck => 'TODO:ar: Symptom-Check';

  @override
  String get sectionVitals => 'TODO:ar: Vitaldaten';

  @override
  String get sectionVoiceNotes => 'TODO:ar: Sprachnotizen';

  @override
  String get sichereNZahlung => 'TODO:ar: Sichere\\nZahlung';

  @override
  String get sofortDokumentieren => 'TODO:ar: Sofort dokumentieren';

  @override
  String get sonstige => 'TODO:ar: Sonstiges';

  @override
  String get spracheUndMemos => 'TODO:ar: Sprache & Memos';

  @override
  String get statistikenAktualisieren => 'TODO:ar: Statistiken aktualisieren';

  @override
  String get statsNichtAktualisiert =>
      'TODO:ar: Statistiken konnten nicht aktualisiert werden.';

  @override
  String get statusFiltern => 'TODO:ar: Filter status';

  @override
  String get stimmung => 'TODO:ar: Ø Stimmung';

  @override
  String get sucheInAktionenDetailsUID =>
      'TODO:ar: Suche in Aktionen, Details, UID…';

  @override
  String get sucheNachBetreffEMail => 'TODO:ar: Suche nach Betreff, E-Mail…';

  @override
  String get sucheNachTitelOderOrt => 'TODO:ar: Nach Titel oder Ort suchen…';

  @override
  String get suchenNameEMailFachrichtung =>
      'TODO:ar: Suchen (Name, E-Mail, Fachrichtung)…';

  @override
  String get suchenNameEmailUid => 'TODO:ar: Suchen (Name, E-Mail oder UID)…';

  @override
  String get taeglicheChallenges => 'TODO:ar: Tägliche Challenges';

  @override
  String get tagEingeben => 'TODO:ar: Tag eingeben…';

  @override
  String get tagePostOP => 'TODO:ar: Tage post-OP';

  @override
  String get templateFollowupActivitySubtitle =>
      'زد النشاط تدريجياً – استمع لإشارات جسمك';

  @override
  String get templateFollowupActivityTitle => 'زيادة النشاط';

  @override
  String get templateFollowupDay14Subtitle => 'الفحص الثاني للتقدم';

  @override
  String get templateFollowupDay21Subtitle => 'الفحص الثالث للتقدم';

  @override
  String get templateFollowupDay28Subtitle => 'الفحص النهائي والموافقة';

  @override
  String get templateFollowupDay28Title => 'الفحص النهائي';

  @override
  String get templateFollowupDay7Subtitle => 'فحص التقدم في العيادة';

  @override
  String get templateFollowupDay7Title => 'موعد المتابعة';

  @override
  String get templateFollowupScarCareSubtitle => 'رطّب الندبة بلطف وراقبها';

  @override
  String get templateFollowupScarCareTitle => 'العناية بالندبة';

  @override
  String get templateFollowupWeeklyCheckSubtitle => 'قيّم ووثّق تقدم الشفاء';

  @override
  String get templateFollowupWeeklyCheckTitle => 'الفحص الذاتي الأسبوعي';

  @override
  String get templateFollowupWoundPhotoSubtitle => 'استمر في توثيق تقدم الشفاء';

  @override
  String get templateFollowupWoundPhotoTitle => 'التقاط صورة للجرح';

  @override
  String get templateMedsEveningSubtitle => 'جرعة المساء حسب الخطة';

  @override
  String get templateMedsMiddaySubtitle => 'جرعة الظهيرة حسب الخطة';

  @override
  String get templateMedsMorningSubtitle => 'الجرعة الصباحية حسب الخطة';

  @override
  String get templateMedsMorningTitle => 'تناول الدواء';

  @override
  String get templateOpdayAdmissionSubtitle =>
      'يرجى الحضور إلى المستشفى في الموعد';

  @override
  String get templateOpdayAdmissionTitle => 'الاستقبال';

  @override
  String get templateOpdayFastingSubtitle => 'لا تأكل أو تشرب وفقاً للتعليمات';

  @override
  String get templateOpdayFastingTitle => 'التحقق من الصيام';

  @override
  String get templateOpdayInfoSubtitle => 'وضّح الأسئلة المفتوحة مع الفريق';

  @override
  String get templateOpdayInfoTitle => 'تأكيد معلومات العملية';

  @override
  String get templateOpdayMobilizationSubtitle => 'اجلس/قف لفترة قصيرة بمساعدة';

  @override
  String get templateOpdayMobilizationTitle => 'التحريك الأول';

  @override
  String get templatePreopBagSubtitle => 'ضع المستندات والملابس والشاحن';

  @override
  String get templatePreopBagTitle => 'تجهيز حقيبة المستشفى';

  @override
  String get templatePreopCompanionSubtitle => 'تنسيق الوصول ونقطة الالتقاء';

  @override
  String get templatePreopCompanionTitle => 'إبلاغ المرافق';

  @override
  String get templatePreopDocumentsSubtitle => 'جهّز بطاقة التأمين والنتائج';

  @override
  String get templatePreopDocumentsTitle => 'مراجعة المستندات';

  @override
  String get templateWeek1AbdominalSupportSubtitle =>
      'تحقق من الملاءمة وطريقة الارتداء';

  @override
  String get templateWeek1AbdominalSupportTitle => 'فحص حزام البطن/الدعامة';

  @override
  String get templateWeek1BackPostureSubtitle =>
      'لا دوران أو انحناء للعمود الفقري';

  @override
  String get templateWeek1BackPostureTitle => 'وضعية حماية الظهر';

  @override
  String get templateWeek1BloodPressureSubtitle => 'وثّق القيم صباحاً ومساءً';

  @override
  String get templateWeek1BloodPressureTitle => 'قياس ضغط الدم';

  @override
  String get templateWeek1BowelDiarySubtitle =>
      'راقب الهضم – مهم لبناء النظام الغذائي';

  @override
  String get templateWeek1BowelDiaryTitle => 'توثيق حركة الأمعاء';

  @override
  String get templateWeek1BreathingCardioSubtitle =>
      'تنفس عميق للعناية بالرئتين – مهم بشكل خاص بعد جراحة القلب';

  @override
  String get templateWeek1BreathingCardioTitle => 'تمارين التنفس';

  @override
  String get templateWeek1BreathingSpineSubtitle =>
      'تنفس عميق – ظهر مستقيم، تنفس بلطف';

  @override
  String get templateWeek1BreathingSpineTitle => 'تمارين التنفس';

  @override
  String get templateWeek1CardiacRehabSubtitle =>
      'المشي الخفيف، بناء الدورة الدموية ببطء';

  @override
  String get templateWeek1CardiacRehabTitle => 'تمارين تأهيل القلب';

  @override
  String get templateWeek1CompressionSubtitle => 'تحقق من ملاءمة وحالة الجوارب';

  @override
  String get templateWeek1CompressionTitle => 'فحص جوارب الضغط';

  @override
  String get templateWeek1DietBuildupSubtitle =>
      'طعام خفيف، نظام لطيف → زيادة تدريجية';

  @override
  String get templateWeek1DietBuildupTitle => 'بناء النظام الغذائي';

  @override
  String get templateWeek1DressingSubtitle => 'تحقق من حالة الضماد ووثّقها';

  @override
  String get templateWeek1DressingTitle => 'فحص الضماد';

  @override
  String get templateWeek1HydrationSubtitle =>
      'على الأقل 1.5 لتر من السوائل يومياً';

  @override
  String get templateWeek1HydrationTitle => 'التحقق من كمية السوائل';

  @override
  String get templateWeek1JointRomSubtitle => 'اختبر الانحناء والاستقامة بحذر';

  @override
  String get templateWeek1JointRomTitle => 'فحص حركة المفصل';

  @override
  String get templateWeek1LegExercisesSubtitle =>
      'دوّر القدمين، شدّ الساقين – الوقاية من التخثر';

  @override
  String get templateWeek1LegExercisesTitle => 'تمارين الساق';

  @override
  String get templateWeek1MobilizationSubtitle =>
      'تحرّك ببطء – حتى الخطوات الصغيرة تُحسب';

  @override
  String get templateWeek1MobilizationTitle => 'الوقوف والحركة لفترة قصيرة';

  @override
  String get templateWeek1NoStrainingSubtitle =>
      'تجنب الضغط، تدحرج جانبياً عند النهوض';

  @override
  String get templateWeek1NoStrainingTitle => 'حماية عضلات البطن';

  @override
  String get templateWeek1OrthosisSubtitle => 'تحقق من الملاءمة ووقت الارتداء';

  @override
  String get templateWeek1OrthosisTitle => 'فحص الدعامة/المشد';

  @override
  String get templateWeek1PainScoreSubtitle => 'أدخل مستوى الألم في التطبيق';

  @override
  String get templateWeek1PainScoreTitle => 'تسجيل مستوى الألم';

  @override
  String get templateWeek1RedFlagsSubtitle => 'حمّى، احمرار، تورم، ألم شديد؟';

  @override
  String get templateWeek1RedFlagsTitle => 'التحقق من علامات التحذير';

  @override
  String get templateWeek1SpineStabilizationSubtitle =>
      'تثبيت الجذع حسب التعليمات – زيادة تدريجية';

  @override
  String get templateWeek1SpineStabilizationTitle => 'تمارين الاستقرار';

  @override
  String get templateWeek1SternumSubtitle =>
      'لا ترفع أكثر من 5 كغ، أبقِ الذراعين قريبين من الجسم';

  @override
  String get templateWeek1SternumTitle => 'حماية عظم القص';

  @override
  String get templateWeek1VitalsSubtitle => 'سجّل النبض/الحرارة بإيجاز';

  @override
  String get templateWeek1VitalsTitle => 'فحص العلامات الحيوية';

  @override
  String get templateWeek1WoundPhotoSubtitle => 'وثّق الصورة لتتبع التقدم';

  @override
  String get templateWeek1WoundPhotoTitle => 'التقاط صورة للجرح';

  @override
  String get templateWeek2CardiacWalkSubtitle =>
      'زد مسافة المشي تدريجياً، راقب النبض';

  @override
  String get templateWeek2CardiacWalkTitle => 'نزهة تأهيل القلب';

  @override
  String get templateWeek2DietNormalizeSubtitle =>
      'راقب الهضم – انتقل ببطء للنظام الغذائي الطبيعي';

  @override
  String get templateWeek2DietNormalizeTitle => 'بناء نظام غذائي طبيعي';

  @override
  String get templateWeek2GaitSubtitle =>
      'تدرّب على المشي الآمن مع/بدون مساعدات';

  @override
  String get templateWeek2GaitTitle => 'تدريب المشي';

  @override
  String get templateWeek2PainSubtitle => 'وثّق تطور الألم – هل يتحسن؟';

  @override
  String get templateWeek2PainTitle => 'مذكرة الألم';

  @override
  String get templateWeek2PhysioSubtitle => 'نفّذ التمارين حسب التعليمات';

  @override
  String get templateWeek2PhysioTitle => 'تمارين العلاج الطبيعي';

  @override
  String get templateWeek2WalkSubtitle =>
      'امشِ أبعد قليلاً كل يوم – قوّ الدورة الدموية';

  @override
  String get templateWeek2WalkTitle => 'الذهاب في نزهة';

  @override
  String get templateWeek2WoundObserveSubtitle => 'راقب ووثّق تقدم الشفاء';

  @override
  String get templateWeek2WoundObserveTitle => 'مراقبة الجرح';

  @override
  String get termineNaechste14Tage => 'TODO:ar: Termine nächste 14 Tage';

  @override
  String get testBenachrichtigungErstellen =>
      'TODO:ar: Testbenachrichtigung erstellen';

  @override
  String get ticketChatNachrichtSchreiben => 'TODO:ar: Nachricht schreiben…';

  @override
  String get ticketErstellen => 'TODO:ar: Ticket erstellen';

  @override
  String get timelineAddNoteContent => 'المحتوى (اختياري)';

  @override
  String get timelineAddTaskDescription => 'الوصف (اختياري)';

  @override
  String get timelineAddTaskTitle => 'العنوان';

  @override
  String get timelineBesserOrganisieren =>
      'TODO:ar: Timeline besser organisieren';

  @override
  String get timelineDue => 'مستحق';

  @override
  String get timelineFriday => 'الجمعة';

  @override
  String get timelineMonday => 'الاثنين';

  @override
  String get timelineMyPlan => 'خطتي';

  @override
  String get timelineNoOpenTasks => 'لا توجد مهام مفتوحة اليوم';

  @override
  String get timelinePhaseDefault => 'المرحلة';

  @override
  String get timelinePhaseFollowup => 'المتابعة';

  @override
  String get timelinePhaseOpday => 'يوم العملية';

  @override
  String get timelinePhasePersonal => 'إدخالاتي';

  @override
  String get timelinePhasePreop => 'التحضير';

  @override
  String get timelinePhaseWeek1 => 'الأسبوع 1 · الشفاء والمراقبة';

  @override
  String get timelinePhaseWeek2 => 'الأسبوع 2 · التنشيط';

  @override
  String get timelinePlanComplete => 'خطتك مكتملة حالياً';

  @override
  String get timelineRouteAppointment => 'إضافة موعد';

  @override
  String get timelineRouteAppointmentDesc =>
      'أنشئ وأدِر مواعيدك المتعلقة بالعملية.';

  @override
  String get timelineRouteDocuments => 'رفع المستندات';

  @override
  String get timelineRouteMedication => 'الأدوية';

  @override
  String get timelineRouteMoodLog => 'مذكرة المزاج';

  @override
  String get timelineRouteMoodLogDesc =>
      'سجّل مزاجك واكتشف الأنماط في رفاهيتك العاطفية.';

  @override
  String get timelineRouteNoteAdd => 'إنشاء ملاحظة';

  @override
  String get timelineRouteNoteAddDesc => 'أضف إدخالاً حراً في جدولك الزمني.';

  @override
  String get timelineRouteNutrition => 'مذكرة التغذية';

  @override
  String get timelineRouteNutritionDesc =>
      'يمكنك توثيق وجباتك والحصول على توصيات غذائية.';

  @override
  String get timelineRoutePainLog => 'مذكرة الألم';

  @override
  String get timelineRoutePainLogDesc =>
      'يمكنك توثيق مستوى الألم على مقياس من 1 إلى 10.';

  @override
  String get timelineRouteQuestions => 'أسئلة وملاحظات';

  @override
  String get timelineRouteQuestionsDesc =>
      'دوّن أسئلتك لجرّاحك وملاحظاتك الشخصية.';

  @override
  String get timelineRouteRedFlag => 'لوحة الإنذار';

  @override
  String get timelineRouteRedFlagDesc =>
      'تحقق من التحذيرات النشطة وإجراءات الطوارئ.';

  @override
  String get timelineRouteRehab => 'إعادة التأهيل';

  @override
  String get timelineRouteRehabDesc =>
      'يفتح نظرة عامة على إعادة التأهيل للتمارين والتقدم.';

  @override
  String get timelineRouteSleepLog => 'مذكرة النوم';

  @override
  String get timelineRouteSleepLogDesc => 'يمكنك توثيق مدة وجودة نومك.';

  @override
  String get timelineRoutesNotizErstellen854 => 'TODO:ar: Notiz erstellen';

  @override
  String get timelineRouteSymptomCheck => 'فحص الأعراض';

  @override
  String get timelineRouteTaskAdd => 'إضافة مهمة';

  @override
  String get timelineRouteTaskAddDesc => 'أنشئ مهمة خاصة لتحضيرات عمليتك.';

  @override
  String get timelineRouteTransport => 'النقل';

  @override
  String get timelineRouteTransportDesc =>
      'خطط لرحلة الذهاب والعودة من المستشفى.';

  @override
  String get timelineRouteVitals => 'العلامات الحيوية';

  @override
  String get timelineRouteWoundDoc => 'توثيق الجرح';

  @override
  String get timelineSaturday => 'السبت';

  @override
  String get timelineSheetDocUpload => 'تحميل المستند';

  @override
  String get timelineSheetPainLevel => 'مستوى الألم';

  @override
  String get timelineSheetWoundPhoto => 'صورة الجرح';

  @override
  String get timelineSunday => 'الأحد';

  @override
  String get timelineThursday => 'الخميس';

  @override
  String get timelineToday => 'اليوم';

  @override
  String get timelineTomorrow => 'غداً';

  @override
  String get timelineTransportDriver => 'السائق/ة';

  @override
  String get timelineTransportHint => 'خطط لرحلة الذهاب والعودة من المستشفى.';

  @override
  String get timelineTransportNotes => 'ملاحظات';

  @override
  String get timelineTransportOutbound => 'الذهاب (الوقت / نقطة الالتقاء)';

  @override
  String get timelineTransportReturn => 'العودة (الوقت / نقطة الالتقاء)';

  @override
  String get timelineTuesday => 'الثلاثاء';

  @override
  String get timelineVerknuepfung => 'TODO:ar: Timeline-Verknüpfung';

  @override
  String get timelineViewFullPlan => 'عرض الخطة الكاملة';

  @override
  String get timelineWednesday => 'الأربعاء';

  @override
  String get timelineZusammenfassung => 'TODO:ar: Timeline Zusammenfassung';

  @override
  String get timerStarten => 'TODO:ar: Timer starten';

  @override
  String get titelBeschreibung => 'TODO:ar: Titel / Beschreibung';

  @override
  String get transkriptBearbeiten => 'TODO:ar: Transkript bearbeiten…';

  @override
  String get uebungSuchen => 'TODO:ar: Übung suchen…';

  @override
  String get userSuchen => 'TODO:ar: User suchen';

  @override
  String get userUID => 'TODO:ar: User UID';

  @override
  String get verbindungFehlgeschlagen =>
      'TODO:ar: Verbindung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get verbindungTrennen => 'TODO:ar: Verbindung trennen';

  @override
  String get verfolgeDeineRecoveryMeilensteine =>
      'TODO:ar: Verfolge deine Recovery-Meilensteine';

  @override
  String get voiceMemosMemosDurchsuchen => 'TODO:ar: Memos durchsuchen…';

  @override
  String get vordefinierteVorlagenVerwalten =>
      'TODO:ar: Vordefinierte Vorlagen verwalten';

  @override
  String get vorDerOP => 'TODO:ar: Vor der OP';

  @override
  String get vorlage => 'TODO:ar: Vorlage';

  @override
  String get vorlagenDurchsuchen => 'TODO:ar: Vorlagen suchen...';

  @override
  String get wannZumArzt => 'TODO:ar: Wann zum Arzt?';

  @override
  String get warnCall112 => 'اتصل بـ 112';

  @override
  String get warnCheckLabel => 'فحص سريع:';

  @override
  String get warnContactClinic => 'اتصل بالعيادة عند ظهور هذه العلامات:';

  @override
  String get warnEmergencySubtitle => 'للأعراض المهددة للحياة!';

  @override
  String get warnEmergencyTitle => 'طوارئ؟';

  @override
  String get warnItemBleedingQ1 => 'هل النزيف نشط ولا يمكن إيقافه؟';

  @override
  String get warnItemBleedingQ2 => 'هل الضماد منقوع بالكامل بالفعل؟';

  @override
  String get warnItemBleedingQ3 => 'هل تشعر بالدوخة أو الضعف؟';

  @override
  String get warnItemBleedingSubtitle => 'الدم يوشِّح الضماد بسرعة';

  @override
  String get warnItemBleedingTitle => 'نزيف شديد';

  @override
  String get warnItemBreathQ1 => 'هل يحدث ضيق التنفس أثناء الراحة؟';

  @override
  String get warnItemBreathQ2 => 'هل يزداد ضيق التنفس سوءاً؟';

  @override
  String get warnItemBreathQ3 => 'هل تشعر بألم عند التنفس؟';

  @override
  String get warnItemBreathSubtitle => 'قِصَر النفَس أو الشعور بضيق';

  @override
  String get warnItemBreathTitle => 'ضيق التنفس';

  @override
  String get warnItemFeverQ1 => 'هل قِست درجة حرارتك؟';

  @override
  String get warnItemFeverQ2 => 'هل درجة الحرارة فوق 38.5 درجة مئوية؟';

  @override
  String get warnItemFeverQ3 => 'هل تعاني قشعريرة؟';

  @override
  String get warnItemFeverSubtitle => 'درجة الحرارة فوق 38.5 درجة مئوية';

  @override
  String get warnItemFeverTitle => 'حمى شديدة';

  @override
  String get warnItemPainQ1 => 'هل الألم أشد بكثير من المعتاد؟';

  @override
  String get warnItemPainQ2 => 'هل مسكِّنات الألم المعتادة لم تعد تساعد؟';

  @override
  String get warnItemPainQ3 => 'هل منطقة الألم منتفخة أو ساخنة؟';

  @override
  String get warnItemPainSubtitle => 'متزايد فجأة وغير قابل للسيطرة';

  @override
  String get warnItemPainTitle => 'آلام شديدة';

  @override
  String get warnItemRednessQ1 => 'هل ينتشر الاحمرار؟';

  @override
  String get warnItemRednessQ2 => 'هل المنطقة دافئة أو ساخنة؟';

  @override
  String get warnItemRednessQ3 => 'هل يخرج قيح أو إفراز؟';

  @override
  String get warnItemRednessSubtitle => 'منطقة الجرح تبدو ملتهبة';

  @override
  String get warnItemRednessTitle => 'احمرار / تورم متزايد';

  @override
  String get warnItemSmellQ1 => 'هل للإفراز لون غير عادي؟';

  @override
  String get warnItemSmellQ2 => 'هل ينبعث من الجرح رائحة كريهة واضحة؟';

  @override
  String get warnItemSmellQ3 => 'هل زادت كمية الإفراز؟';

  @override
  String get warnItemSmellSubtitle => 'إفراز غير عادي من الجرح';

  @override
  String get warnItemSmellTitle => 'إفراز كريه الرائحة';

  @override
  String get warnSaveCheck => 'حفظ الفحص';

  @override
  String get warnTitle => 'علامات التحذير';

  @override
  String get warnzeichenStatus => 'TODO:ar: Warnzeichen Status';

  @override
  String get wartungsmodusDeaktivieren => 'TODO:ar: Wartungsmodus deaktivieren';

  @override
  String get wasBeschaeftigtDich => 'TODO:ar: Was beschäftigt dich gerade?';

  @override
  String get wasBeschreibtDeineStimmung =>
      'TODO:ar: Was beschreibt deine Stimmung?';

  @override
  String get wasHastDuBeobachtet => 'TODO:ar: Was hast du beobachtet?';

  @override
  String get weekdayShortFri => 'جم';

  @override
  String get weekdayShortMon => 'إث';

  @override
  String get weekdayShortSat => 'سب';

  @override
  String get weekdayShortSun => 'أح';

  @override
  String get weekdayShortThu => 'خم';

  @override
  String get weekdayShortTue => 'ثل';

  @override
  String get weekdayShortWed => 'أر';

  @override
  String get weiterDokumentieren => 'TODO:ar: Weiter dokumentieren';

  @override
  String get weiterenPatientenHinzufuegen =>
      'TODO:ar: Weiteren Patienten hinzufügen';

  @override
  String get werbungUndDatenschutz => 'TODO:ar: Werbung & Datenschutz';

  @override
  String get wieGehtEsDir => 'TODO:ar: Wie geht es dir?';

  @override
  String get woche1 => 'TODO:ar: Woche 1';

  @override
  String get wochentage => 'TODO:ar: Wochentage';

  @override
  String get woundDocumentationNeuesFotoAufnehmen =>
      'TODO:ar: Neues Foto aufnehmen';

  @override
  String get wunddetailFehlendeArgumente =>
      'TODO:ar: Wunddetail (fehlende Argumente)';

  @override
  String get wunddokuLetzte3 => 'TODO:ar: Wunddoku letzte 3';

  @override
  String get wundeSchmerzBewegung => 'TODO:ar: Wunde, Schmerz, Bewegung';

  @override
  String get wundschmerz => 'TODO:ar: Ø Wundschmerz';

  @override
  String get wundvergleichFehlendeArgumente =>
      'TODO:ar: Wundvergleich (fehlende Argumente)';

  @override
  String get xPUndLevelSystem => 'TODO:ar: XP & Level-System';

  @override
  String get zBA1B2C3D4 => 'TODO:ar: z.B. A1B2C3D4';

  @override
  String get zBA1B2C3D4E5F6 => 'TODO:ar: z.B. A1B2C3D4E5F6';

  @override
  String get zBArztAnrufen => 'TODO:ar: z.B. Arzt anrufen';

  @override
  String get zbBefund => 'TODO:ar: z.B. Befund';

  @override
  String get zbDieBlaue => 'TODO:ar: z. B. Die blaue, nicht die rote';

  @override
  String get zbNachDemEssen =>
      'TODO:ar: z. B. mit Wasser nach dem Essen einnehmen';

  @override
  String get zBRehaBadNauheim => 'TODO:ar: z.B. Reha Bad Nauheim';

  @override
  String get zBRehaKlinikMustermann => 'TODO:ar: z. B. Reha-Klinik Mustermann';

  @override
  String get zbUpdateWirdEingespielt =>
      'TODO:ar: z.B. Update wird eingespielt…';

  @override
  String get zeitfilterZuruecksetzen => 'TODO:ar: Zeitfilter zurücksetzen';

  @override
  String get zeitraumFiltern => 'TODO:ar: Zeitraum filtern';

  @override
  String get zuDenEinstellungen => 'TODO:ar: Zu den Einstellungen';

  @override
  String get zurueckZurTimeline => 'TODO:ar: Zurück zur Timeline';

  @override
  String anfrageAblehnenBestaetigung(String name) {
    return 'TODO:ar: Möchtest du die Anfrage von $name ablehnen?';
  }

  @override
  String apptCalendarDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مواعيد',
      many: '$count موعيدًا',
      few: '$count مواعيد',
      two: 'موعدان',
      one: 'موعد واحد',
      zero: 'لا مواعيد',
    );
    return '$_temp0';
  }

  @override
  String apptCreatedBy(String name) {
    return 'أُنشئ بواسطة $name';
  }

  @override
  String apptDeleteContent(String title) {
    return 'هل تريد حذف \"$title\" بشكل دائم؟';
  }

  @override
  String apptReminderMinutes(int minutes) {
    return 'قبل $minutes دقيقة';
  }

  @override
  String apptRepeatUntilDate(String date) {
    return '(حتى $date)';
  }

  @override
  String aufgabenAuswaehlenCount(int selected, int total) {
    return 'TODO:ar: Aufgaben auswählen ($selected/$total):';
  }

  @override
  String aufgabenCount(int count) {
    return 'TODO:ar: Aufgaben ($count)';
  }

  @override
  String aufgabenCountSelected(int count, String suffix) {
    return 'TODO:ar: $count Aufgabe$suffix ausgewählt';
  }

  @override
  String bellaActionStatusCancelled(String label) {
    return '$label — تم الإلغاء';
  }

  @override
  String bellaActionStatusCreated(String label) {
    return '$label — تم الإنشاء';
  }

  @override
  String bellaActionStatusFailed(String label) {
    return '$label — فشل';
  }

  @override
  String bellaBriefingHttpError(int statusCode) {
    return 'خطأ في إنشاء الموجز (HTTP $statusCode).';
  }

  @override
  String bellaDailyUsage(int used, int limit) {
    return '$used / $limit رسائل اليوم';
  }

  @override
  String bellaProactiveDocGap(int days) {
    return 'لم تُسجّل أي شيء منذ $days أيام';
  }

  @override
  String bellaProactiveMedReminder(String name) {
    return 'هل تناولت $name اليوم؟';
  }

  @override
  String bellaProactiveMedReminderMultiple(int count) {
    return 'هل تناولت دوائك اليوم؟ ($count معلق)';
  }

  @override
  String bellaProactiveOpenTasks(int count) {
    return 'لا يزال لديك $count مهام مفتوحة لليوم';
  }

  @override
  String bellaProactiveStreakAtRisk(int streak) {
    return 'سلسلة $streak يوم في خطر!';
  }

  @override
  String benachrichtigungenCountNeu(int count) {
    return 'TODO:ar: Benachrichtigungen ($count neu)';
  }

  @override
  String caregiverEntfernt(String name) {
    return 'TODO:ar: $name wurde entfernt';
  }

  @override
  String cloneErstellt(String name) {
    return 'TODO:ar: \"$name\" erstellt';
  }

  @override
  String doctorEntfernt(String name) {
    return 'TODO:ar: $name wurde entfernt';
  }

  @override
  String doctorHinzugefuegt(String name) {
    return 'TODO:ar: $name wurde hinzugefügt';
  }

  @override
  String dokumentGeloescht(String title) {
    return 'TODO:ar: „$title“ gelöscht';
  }

  @override
  String erstelltVon(String name) {
    return 'TODO:ar: Created by: $name';
  }

  @override
  String fehlerMitError(String error) {
    return 'TODO:ar: Fehler: $error';
  }

  @override
  String gueltigFuerTage(int days) {
    return 'TODO:ar: Gültig für $days Tage';
  }

  @override
  String keysErstellt(int count) {
    return 'TODO:ar: $count Keys erstellt';
  }

  @override
  String medikamentEntfernt(String name) {
    return 'TODO:ar: $name entfernt';
  }

  @override
  String medikamentWiederhergestellt(String name) {
    return 'TODO:ar: $name wiederhergestellt';
  }

  @override
  String medikamentWirdEntfernt(String name) {
    return 'TODO:ar: $name wird entfernt.';
  }

  @override
  String mitarbeiterAction(String action) {
    return 'TODO:ar: Mitarbeiter $action';
  }

  @override
  String mitarbeiterEntfernt(String name) {
    return 'TODO:ar: $name wurde entfernt';
  }

  @override
  String nameWurdeEntsperrt(String name) {
    return 'TODO:ar: $name wurde entsperrt.';
  }

  @override
  String nameWurdeGeloescht(String name) {
    return 'TODO:ar: $name wurde gelöscht.';
  }

  @override
  String nameWurdeGesperrt(String name) {
    return 'TODO:ar: $name wurde gesperrt.';
  }

  @override
  String neuesPasswortFuer(String name) {
    return 'TODO:ar: Neues Passwort für $name';
  }

  @override
  String noSearchResults(String query) {
    return 'TODO:ar: Keine Ergebnisse für „$query\"';
  }

  @override
  String notizLoeschenBestaetigung(String title) {
    return 'TODO:ar: „$title“ wirklich löschen?';
  }

  @override
  String partnerAnzeigenCount(int count) {
    return 'TODO:ar: Partner-Anzeigen ($count)';
  }

  @override
  String pushAnEmail(String email) {
    return 'TODO:ar: Push to $email';
  }

  @override
  String pushAnEmailGesendet(String email) {
    return 'TODO:ar: Push sent to $email.';
  }

  @override
  String pushAnTargetGesendet(String target) {
    return 'TODO:ar: Push to $target sent!';
  }

  @override
  String rfActiveBadge(int count) {
    return '$count نشط';
  }

  @override
  String rfActiveCount(int count) {
    return 'نشط ($count)';
  }

  @override
  String rfLevelBadge(String level) {
    return 'المستوى: $level';
  }

  @override
  String rfResolvedCount(int count) {
    return 'السجل ($count)';
  }

  @override
  String rolleGeaendert(String role) {
    return 'TODO:ar: Rolle geändert zu „$role\".';
  }

  @override
  String statusMitLabel(String label) {
    return 'TODO:ar: Status: $label';
  }

  @override
  String tageVergeben(int days) {
    return 'TODO:ar: $days Tage gewährt';
  }

  @override
  String ticketsCountOffen(int count) {
    return 'TODO:ar: Tickets ($count open)';
  }

  @override
  String timelineDoneOfTotal(int done, int total) {
    return '$done/$total مكتمل';
  }

  @override
  String timelineDueAttention(int count) {
    return '$count تحتاج انتباهك اليوم';
  }

  @override
  String timelineNextUp(String title) {
    return 'التالي: $title';
  }

  @override
  String timelinePhaseProgress(int done, int total) {
    return '$done/$total مكتمل';
  }

  @override
  String timelineProgressPercent(int percent) {
    return '$percent% مكتمل – استمر!';
  }

  @override
  String timelineStickyDoneOfTotal(int done, int total) {
    return '$done من $total مكتمل';
  }

  @override
  String timelineStickyDue(int count) {
    return '$count مستحق';
  }

  @override
  String timelineStickyToday(int count) {
    return '$count اليوم';
  }

  @override
  String timelineStreakDays(int count) {
    return '$count أيام';
  }

  @override
  String timelineTasksPlanned(int count) {
    return '$count مهام مخططة لليوم';
  }

  @override
  String unwiderruflichLoeschen(String title) {
    return 'TODO:ar: „$title“ wird dauerhaft gelöscht.';
  }

  @override
  String userAktionFehler(String action) {
    return 'TODO:ar: Nutzer konnte nicht ${action}t werden.';
  }

  @override
  String vorlageErstellt(String name) {
    return 'TODO:ar: Vorlage „$name\" erstellt';
  }

  @override
  String vorlageLoeschenBestaetigung(String name) {
    return 'TODO:ar: Möchtest du \"$name\" wirklich löschen?';
  }

  @override
  String vorlageUebernommen(String name) {
    return 'TODO:ar: „$name\" in eigene Vorlagen kopiert';
  }

  @override
  String warnLastCheck(String label, String date) {
    return 'آخر فحص: $label · $date';
  }

  @override
  String warnzeichenGespeichert(String level) {
    return 'TODO:ar: Warnzeichen-Check gespeichert ($level)';
  }

  @override
  String get accountUndRechtliches => 'TODO:ar: Account & Rechtliches';

  @override
  String get actionCall112 => 'TODO:ar: 112 anrufen';

  @override
  String get actionUnlock => 'TODO:ar: Entsperren';

  @override
  String get aktiveWarnungenUndNotfallaktionenPruefen =>
      'TODO:ar: Aktive Warnungen und Notfallaktionen prüfen.';

  @override
  String get alertNotruf112 => 'TODO:ar: Notruf 112';

  @override
  String get alleAbwaehlen => 'TODO:ar: Alle abwählen';

  @override
  String get alleAuswaehlen => 'TODO:ar: Alle auswählen';

  @override
  String get alleKategorienErledigt => 'TODO:ar: Alle Kategorien erledigt!';

  @override
  String get alleTermineImBlick => 'TODO:ar: Alle Termine im Blick';

  @override
  String get allesErledigt => 'TODO:ar: Alles erledigt!';

  @override
  String get analyticsNutrition => 'TODO:ar: Ernährung';

  @override
  String get analyticsOverview => 'TODO:ar: Übersicht';

  @override
  String get analyticsPain => 'TODO:ar: Schmerzen';

  @override
  String get analyticsVitals => 'TODO:ar: Vitaldaten';

  @override
  String get analyticsWounds => 'TODO:ar: Wunden';

  @override
  String get apptAllDay => 'طوال اليوم';

  @override
  String get arztAnrufen => 'TODO:ar: Arzt anrufen';

  @override
  String get arztKontaktieren => 'TODO:ar: Arzt kontaktieren';

  @override
  String get aufgabeHinzufuegen => 'TODO:ar: Aufgabe hinzufügen';

  @override
  String get aufgabenUndTimeline => 'TODO:ar: Aufgaben & Timeline';

  @override
  String get aufmerksamkeitErforderlich =>
      'TODO:ar: Aufmerksamkeit erforderlich';

  @override
  String get ausGalerie => 'TODO:ar: Aus Galerie';

  @override
  String get ausZwischenNablageEinfuegen =>
      'TODO:ar: Aus Zwischenablage einfügen';

  @override
  String get authServiceGoogleSignInWasCancelledByTheUser =>
      'TODO:ar: Der Google-Anmeldevorgang wurde abgebrochen.';

  @override
  String get badgeMedicationHero => 'TODO:ar: Medikamenten-Held';

  @override
  String get badgeMedicationHeroDesc => 'TODO:ar: 7 Tage ohne vergessene Dosis';

  @override
  String get badgeMoodTrackerDesc => 'TODO:ar: Stimmung 20 Mal dokumentiert';

  @override
  String get badgePainTracker => 'TODO:ar: Schmerz-Tracker';

  @override
  String get badgePainTrackerDesc => 'TODO:ar: Schmerzen 20 Mal dokumentiert';

  @override
  String get bandscheibenOP44Jahre => 'TODO:ar: Bandscheiben-OP, 44 Jahre';

  @override
  String get befundeUndBerichte => 'TODO:ar: Befunde & Berichte';

  @override
  String get begleitetWerden => 'TODO:ar: Begleitet werden';

  @override
  String get bellaAIGespraechsexport => 'TODO:ar: Bella AI – Gesprächsexport';

  @override
  String get bevorIchLoslegenKannBraucheIchKurzDeineEinwilligung =>
      'TODO:ar: Bevor ich loslegen kann, brauche ich kurz deine Einwilligung';

  @override
  String get bevorstehendeArztUndKliniktermine =>
      'TODO:ar: Bevorstehende Arzt- und Kliniktermine';

  @override
  String get bildAuswaehlen => 'TODO:ar: Bild auswählen';

  @override
  String get bitteGibEinenKeyEin => 'TODO:ar: Bitte gib einen Key ein.';

  @override
  String get blutwerteAbgegeben => 'TODO:ar: Blutwerte abgegeben';

  @override
  String caregiverRemoved(String name) {
    return 'TODO:ar: $name wurde entfernt';
  }

  @override
  String get challengeGeschafft => 'TODO:ar: Challenge geschafft!';

  @override
  String get checklisteFuerDieKlinik => 'TODO:ar: Checkliste für die Klinik';

  @override
  String get cpAbdominalBelt => 'TODO:ar: Bauchgurt/Stütze prüfen';

  @override
  String get cpAbdominalBeltDesc => 'TODO:ar: Sitz und Trageweise prüfen';

  @override
  String get cpAbdominalProtection => 'TODO:ar: Bauchmuskelschutz';

  @override
  String get cpAbdominalProtectionDesc =>
      'TODO:ar: Nicht pressen, beim Aufstehen zur Seite rollen';

  @override
  String get cpAdmission => 'TODO:ar: Aufnahme';

  @override
  String get cpAdmissionDesc => 'TODO:ar: Bitte pünktlich in der Klinik melden';

  @override
  String get cpBandageCheck => 'TODO:ar: Verband kontrollieren';

  @override
  String get cpBandageCheckDesc =>
      'TODO:ar: Verbandszustand prüfen und dokumentieren';

  @override
  String get cpBreathingExercises => 'TODO:ar: Atemübungen';

  @override
  String get cpBreathingExercisesHeartDesc =>
      'TODO:ar: Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen';

  @override
  String get cpBreathingExercisesSpineDesc =>
      'TODO:ar: Tiefe Atemzüge – Rücken gerade, sanft atmen';

  @override
  String get cpCardiacRehabExercises => 'TODO:ar: Herzreha-Übungen';

  @override
  String get cpCardiacRehabExercisesDesc =>
      'TODO:ar: Leichtes Gehen, Kreislauf langsam aufbauen';

  @override
  String get cpCardiacRehabWalk => 'TODO:ar: Herzreha-Spaziergang';

  @override
  String get cpCardiacRehabWalkDesc =>
      'TODO:ar: Gehstrecke langsam steigern, Puls beobachten';

  @override
  String get cpCheckDocuments => 'TODO:ar: Dokumente prüfen';

  @override
  String get cpCheckDocumentsDesc =>
      'TODO:ar: Krankenkassenkarte und Unterlagen vorbereiten';

  @override
  String get cpCheckFasting => 'TODO:ar: Nüchternheit prüfen';

  @override
  String get cpCheckFastingDesc =>
      'TODO:ar: Keine Nahrung oder Flüssigkeit wie angewiesen';

  @override
  String get cpCheckFluidIntake => 'TODO:ar: Flüssigkeitszufuhr prüfen';

  @override
  String get cpCheckFluidIntakeDesc =>
      'TODO:ar: Mindestens 1,5 Liter Flüssigkeit täglich';

  @override
  String get cpCheckOrthosis => 'TODO:ar: Orthese/Korsett prüfen';

  @override
  String get cpCheckOrthosisDesc => 'TODO:ar: Sitz und Tragezeit prüfen';

  @override
  String get cpCheckVitals => 'TODO:ar: Vitalzeichen prüfen';

  @override
  String get cpCheckVitalsDesc => 'TODO:ar: Puls/Temperatur kurz notieren';

  @override
  String get cpCheckWarnings => 'TODO:ar: Warnzeichen prüfen';

  @override
  String get cpCheckWarningsDesc =>
      'TODO:ar: Fieber, Rötung, Schwellung, starke Schmerzen?';

  @override
  String get cpCompressionStockings => 'TODO:ar: Kompressionsstrümpfe prüfen';

  @override
  String get cpCompressionStockingsDesc =>
      'TODO:ar: Sitz und Zustand der Strümpfe prüfen';

  @override
  String get cpConfirmOpInfo => 'TODO:ar: OP-Informationen bestätigen';

  @override
  String get cpConfirmOpInfoDesc =>
      'TODO:ar: Offene Fragen mit dem Team klären';

  @override
  String get cpDietProgression => 'TODO:ar: Kostaufbau';

  @override
  String get cpDietProgressionDesc =>
      'TODO:ar: Leichte Kost, Schonkost → langsam steigern';

  @override
  String get cpDocumentBowel => 'TODO:ar: Stuhlgang dokumentieren';

  @override
  String get cpDocumentBowelDesc =>
      'TODO:ar: Verdauung beobachten – wichtig für den Kostaufbau';

  @override
  String get cpEveningDose => 'TODO:ar: Abenddosis wie vorgeschrieben';

  @override
  String get cpFinalCheck => 'TODO:ar: Abschlusskontrolle';

  @override
  String get cpFinalCheckDesc =>
      'TODO:ar: Abschlussuntersuchung und Entlassung';

  @override
  String get cpFirstMobilisation => 'TODO:ar: Erste Mobilisation';

  @override
  String get cpFirstMobilisationDesc =>
      'TODO:ar: Kurz aufsetzen/aufstehen mit Unterstützung';

  @override
  String get cpFollowUpAppointment => 'TODO:ar: Nachsorgetermin';

  @override
  String get cpFollowUpDesc1 => 'TODO:ar: Fortschrittskontrolle in der Klinik';

  @override
  String get cpFollowUpDesc2 => 'TODO:ar: Zweite Fortschrittskontrolle';

  @override
  String get cpFollowUpDesc3 => 'TODO:ar: Dritte Fortschrittskontrolle';

  @override
  String get cpGaitTraining => 'TODO:ar: Gangschulung';

  @override
  String get cpGaitTrainingDesc =>
      'TODO:ar: Sicheres Gehen mit/ohne Hilfsmittel üben';

  @override
  String get cpGoForWalk => 'TODO:ar: Spazieren gehen';

  @override
  String get cpGoForWalkDesc =>
      'TODO:ar: Jeden Tag etwas weiter laufen – Kreislauf stärken';

  @override
  String get cpIncreaseActivity => 'TODO:ar: Aktivität steigern';

  @override
  String get cpIncreaseActivityDesc =>
      'TODO:ar: Aktivität langsam steigern – auf Körpersignale achten';

  @override
  String get cpInformCompanion => 'TODO:ar: Begleitperson informieren';

  @override
  String get cpInformCompanionDesc => 'TODO:ar: Fahrt und Treffpunkt abstimmen';

  @override
  String get cpLegExercises => 'TODO:ar: Beinübungen durchführen';

  @override
  String get cpLegExercisesDesc =>
      'TODO:ar: Füße kreisen, Beine anspannen – Thromboseprophylaxe';

  @override
  String get cpMorningDose => 'TODO:ar: Morgendosis wie vorgeschrieben';

  @override
  String get cpNoonDose => 'TODO:ar: Mittagsdosis wie vorgeschrieben';

  @override
  String get cpNormalDietProgression => 'TODO:ar: Normale Ernährung aufbauen';

  @override
  String get cpNormalDietProgressionDesc =>
      'TODO:ar: Verdauung beobachten – schrittweise zur normalen Ernährung';

  @override
  String get cpObserveWound => 'TODO:ar: Wunde beobachten';

  @override
  String get cpObserveWoundDesc =>
      'TODO:ar: Heilungsverlauf beobachten und dokumentieren';

  @override
  String get cpPackHospitalBag => 'TODO:ar: Kliniktasche packen';

  @override
  String get cpPackHospitalBagDesc =>
      'TODO:ar: Dokumente, Kleidung und Ladekabel einpacken';

  @override
  String get cpPainDiary => 'TODO:ar: Schmerztagebuch';

  @override
  String get cpPainDiaryDesc =>
      'TODO:ar: Schmerzverlauf dokumentieren – bessert es sich?';

  @override
  String get cpPhysioExercises => 'TODO:ar: Physiotherapie-Übungen';

  @override
  String get cpPhysioExercisesDesc =>
      'TODO:ar: Übungen wie angewiesen durchführen';

  @override
  String get cpRecordPainLevel => 'TODO:ar: Schmerzniveau erfassen';

  @override
  String get cpRecordPainLevelDesc =>
      'TODO:ar: Schmerzniveau in der App eingeben';

  @override
  String get cpScarCare => 'TODO:ar: Narbenpflege';

  @override
  String get cpScarCareDesc => 'TODO:ar: Narbe sanft eincremen und beobachten';

  @override
  String get cpSpineProtection => 'TODO:ar: Rückenschutzhaltung';

  @override
  String get cpSpineProtectionDesc =>
      'TODO:ar: Kein Verdrehen oder Beugen der Wirbelsäule';

  @override
  String get cpStabilisationExercises => 'TODO:ar: Stabilisationsübungen';

  @override
  String get cpStabilisationExercisesDesc =>
      'TODO:ar: Rumpfstabilisation wie angewiesen – schrittweise steigern';

  @override
  String get cpSternumProtection => 'TODO:ar: Sternumschutz';

  @override
  String get cpSternumProtectionDesc =>
      'TODO:ar: Kein Heben über 5 kg, Arme nah am Körper halten';

  @override
  String get cpTakeMedication => 'TODO:ar: Medikamente einnehmen';

  @override
  String get cpTakeWoundPhoto => 'TODO:ar: Wundfoto aufnehmen';

  @override
  String get cpTakeWoundPhotoDesc =>
      'TODO:ar: Foto zur Fortschrittsverfolgung dokumentieren';

  @override
  String get cpTakeWoundPhotoProgress => 'TODO:ar: Wundfoto aufnehmen';

  @override
  String get cpTakeWoundPhotoProgressDesc =>
      'TODO:ar: Heilungsfortschritt weiter dokumentieren';

  @override
  String get cpWeeklySelfCheck => 'TODO:ar: Wöchentliche Selbstkontrolle';

  @override
  String get cpWeeklySelfCheckDesc =>
      'TODO:ar: Heilungsfortschritt auswerten und dokumentieren';

  @override
  String get dasRehaSystemMitTimerIstGoldWert =>
      'TODO:ar: Das Reha-System mit Timer ist Gold wert.';

  @override
  String get datenEingeben => 'TODO:ar: Daten eingeben';

  @override
  String debugEmail(String email) {
    return 'TODO:ar: E-Mail: $email';
  }

  @override
  String get debugLinkedPatients => 'TODO:ar: Verknüpfte Patienten';

  @override
  String get debugNotAvailable => 'TODO:ar: nicht verfügbar';

  @override
  String get debugNotLoggedIn => 'TODO:ar: nicht angemeldet';

  @override
  String get debugOnlyForAdmins => 'TODO:ar: Nur für Admins verfügbar.';

  @override
  String get debugOnlyInDebug => 'TODO:ar: Nur in Debug-Builds verfügbar.';

  @override
  String debugRole(String role) {
    return 'TODO:ar: Rolle: $role';
  }

  @override
  String debugUid(String uid) {
    return 'TODO:ar: UID: $uid';
  }

  @override
  String get deineHeutigeChallenge => 'TODO:ar: Deine heutige Challenge';

  @override
  String get deineWochenZusammenfassung =>
      'TODO:ar: Deine Wochen-Zusammenfassung';

  @override
  String get derNutzerVerliertSofortDenProZugang =>
      'TODO:ar: Der Nutzer verliert sofort den Pro-Zugang.';

  @override
  String get dieserKeyIstAbgelaufen => 'TODO:ar: Dieser Key ist abgelaufen.';

  @override
  String get dokuHubFuerKameraUndGalerie =>
      'TODO:ar: Doku-Hub für Kamera & Galerie';

  @override
  String get dokumenteHochladen => 'TODO:ar: Dokumente hochladen';

  @override
  String get duHastAlleAufgabenAbgeschlossenGoennDirEinePause =>
      'TODO:ar: Du hast alle Aufgaben abgeschlossen. Gönn dir eine Pause.';

  @override
  String get duMusstAngemeldetSein => 'TODO:ar: Du musst angemeldet sein.';

  @override
  String get einnahmeDokumentieren => 'TODO:ar: Einnahme dokumentieren';

  @override
  String get empty7DaysNoData => 'TODO:ar: 7 Tage: keine Daten';

  @override
  String get emptyNoMacros => 'TODO:ar: Keine Makros erfasst';

  @override
  String get emptyNoNotifications => 'TODO:ar: Keine Benachrichtigungen';

  @override
  String get emptyNoRedFlags => 'TODO:ar: Keine offenen Red Flags';

  @override
  String get emptyNoVitals => 'TODO:ar: Noch keine Vitaldaten erfasst';

  @override
  String get emptyNoVitalsShort => 'TODO:ar: Noch keine Vitaldaten';

  @override
  String get emptyTasksInPlan => 'TODO:ar: Noch keine Aufgaben im Plan.';

  @override
  String get emptyTodayNoEntries => 'TODO:ar: Heute: keine Einträge';

  @override
  String get erinnerungenAnMedikamenteneinnahme =>
      'TODO:ar: Erinnerungen an Medikamenteneinnahme';

  @override
  String get erstelle => 'TODO:ar: Erstelle…';

  @override
  String get erstelleDeinKontoInWenigenSekunden =>
      'TODO:ar: Erstelle dein Konto in wenigen Sekunden.';

  @override
  String get erstelleEineEigeneAufgabeFuerDeineOPVorbereitung =>
      'TODO:ar: Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.';

  @override
  String get erstelleUndVerwalteDeineOPBezogenenTermine =>
      'TODO:ar: Erstelle und verwalte deine OP-bezogenen Termine.';

  @override
  String get familyOverviewAufmerksamkeitErforderlich =>
      'TODO:ar: Aufmerksamkeit erforderlich';

  @override
  String get fehlerBeimEinloesenBitteVersucheEsErneut =>
      'TODO:ar: Fehler beim Einlösen. Bitte versuche es erneut.';

  @override
  String get fehlerBeimSpeichernErneut =>
      'TODO:ar: Fehler beim Speichern. Bitte erneut versuchen.';

  @override
  String fehlerGeneric(String error) {
    return 'TODO:ar: Fehler: $error';
  }

  @override
  String fehlerMitDetails(String error) {
    return 'TODO:ar: Fehler: $error';
  }

  @override
  String get fotoAufnehmen => 'TODO:ar: Foto aufnehmen';

  @override
  String get fragenUndNotizen => 'TODO:ar: Fragen & Notizen';

  @override
  String get fuegeDeineOPInformationenHinzu =>
      'TODO:ar: Füge deine OP-Informationen hinzu.';

  @override
  String get googleSignInWasCancelledByTheUser =>
      'TODO:ar: Der Google-Anmeldevorgang wurde abgebrochen.';

  @override
  String get habenSieAtembeschwerdenOderKurzatmigkeit =>
      'TODO:ar: Haben Sie Atembeschwerden oder Kurzatmigkeit?';

  @override
  String get halteEinenFreienEintragInDeinerTimelineFest =>
      'TODO:ar: Halte einen freien Eintrag in deiner Timeline fest.';

  @override
  String get hintDescribeInDetail =>
      'TODO:ar: Beschreibe dein Anliegen so genau wie möglich…';

  @override
  String get hintShortDescription =>
      'TODO:ar: Kurze Beschreibung deines Anliegens';

  @override
  String get ichWarNervoesVorDerOPDieRedFlagWarnung =>
      'TODO:ar: Ich war nervös vor der OP. Die Red-Flag Warnung';

  @override
  String itemDeletedMessage(String title) {
    return 'TODO:ar: „$title“ gelöscht';
  }

  @override
  String itemDeletedPermanently(String title) {
    return 'TODO:ar: „$title“ wird dauerhaft gelöscht.';
  }

  @override
  String get keyNichtGefunden => 'TODO:ar: Key nicht gefunden.';

  @override
  String get knieTEP58Jahre => 'TODO:ar: Knie-TEP, 58 Jahre';

  @override
  String get kritischerSymptomCheck => 'TODO:ar: Kritischer Symptom-Check';

  @override
  String get labelCategory => 'TODO:ar: Kategorie';

  @override
  String get labelContentOptional => 'TODO:ar: Inhalt (optional)';

  @override
  String get labelCustomMinutes => 'TODO:ar: Eigene Minuten';

  @override
  String get labelDescriptionOptional => 'TODO:ar: Beschreibung (optional)';

  @override
  String get labelInviteCode => 'TODO:ar: Einladungscode';

  @override
  String labelInviteCodeValue(String code) {
    return 'TODO:ar: Code: $code';
  }

  @override
  String get labelLinkType => 'TODO:ar: Link-Typ';

  @override
  String get labelLocation => 'TODO:ar: Ort';

  @override
  String get labelLocationDetails => 'TODO:ar: Ortsdetails';

  @override
  String get labelNote => 'TODO:ar: Notiz';

  @override
  String get labelObservation => 'TODO:ar: Beobachtung';

  @override
  String get labelReminder => 'TODO:ar: Erinnerung';

  @override
  String get labelSubject => 'TODO:ar: Betreff';

  @override
  String get labelTitle => 'TODO:ar: Titel';

  @override
  String get labelTitleRequired => 'TODO:ar: Titel *';

  @override
  String get labelType => 'TODO:ar: Typ';

  @override
  String get mahlzeitenUndEmpfehlungen => 'TODO:ar: Mahlzeiten & Empfehlungen';

  @override
  String get measurementSaved => 'TODO:ar: Messung gespeichert';

  @override
  String get meinePatienten => 'TODO:ar: Meine Patienten';

  @override
  String get memoAufnehmen => 'TODO:ar: Memo aufnehmen';

  @override
  String get n7Tage => 'TODO:ar: Ø 7 Tage';

  @override
  String get nachDerOP => 'TODO:ar: Nach der OP';

  @override
  String get nachMeinerKnieOPHatteIchHundertFragen =>
      'TODO:ar: Nach meiner Knie-OP hatte ich hundert Fragen.';

  @override
  String get nachrichtNsenden => 'TODO:ar: Nachricht\nsenden';

  @override
  String get notifChannelAppointments =>
      'TODO:ar: Erinnerungen für bevorstehende Termine';

  @override
  String get notifChannelMedication => 'TODO:ar: Medikamentenerinnerung';

  @override
  String get notifChannelMedicationDesc =>
      'TODO:ar: Tägliche Erinnerungen für Medikamente';

  @override
  String get notifChannelVitals => 'TODO:ar: Vitaldaten-Erinnerung';

  @override
  String get notifChannelVitalsDesc =>
      'TODO:ar: Tägliche Erinnerung für Vitaldatenmessungen';

  @override
  String notifDoctorAnswered(String name) {
    return 'TODO:ar: Dr. $name hat deine Frage beantwortet';
  }

  @override
  String get notifMeasureVitals => 'TODO:ar: Vitaldaten messen';

  @override
  String notifObservationFrom(String name) {
    return 'TODO:ar: Beobachtung von $name';
  }

  @override
  String get notifWoundAlarm => 'TODO:ar: Wund-Alarm';

  @override
  String get notizErstellen => 'TODO:ar: Notiz erstellen';

  @override
  String get nutritionProteinG1110 => 'TODO:ar: Protein (g)';

  @override
  String get oPAngelegt => 'TODO:ar: OP angelegt';

  @override
  String get oPTag => 'TODO:ar: OP‑Tag';

  @override
  String get oPTagWundeFrischVersorgtSterilerVerbandAngelegt =>
      'TODO:ar: OP‑Tag. Wunde frisch versorgt, steriler Verband angelegt.';

  @override
  String get oeffnetDieRehaUebersichtFuerUebungenUndFortschritt =>
      'TODO:ar: Öffnet die Reha-Übersicht für Übungen und Fortschritt.';

  @override
  String get operateurUndAnaesthesist => 'TODO:ar: Operateur & Anästhesist';

  @override
  String get pain7Tage => 'TODO:ar: Ø 7 Tage';

  @override
  String get painDiary7Tage => 'TODO:ar: Ø 7 Tage';

  @override
  String get patientNhinzufuegen => 'TODO:ar: Patient\nhinzufügen';

  @override
  String get planeHinUndRueckfahrtZurKlinik =>
      'TODO:ar: Plane Hin- und Rückfahrt zur Klinik.';

  @override
  String get proActiveSubtitle => 'TODO:ar: Alle Funktionen freigeschaltet';

  @override
  String get proActiveTitle => 'TODO:ar: Pro aktiv';

  @override
  String get proEntziehen => 'TODO:ar: Pro entziehen';

  @override
  String get proGeben => 'TODO:ar: Pro vergeben';

  @override
  String get proStatusEntziehen => 'TODO:ar: Pro-Status entziehen?';

  @override
  String get redFlagCockpit => 'TODO:ar: Red-Flag Cockpit';

  @override
  String redFlagCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flags',
      one: 'Flag',
    );
    return 'TODO:ar: $count $_temp0';
  }

  @override
  String get rolleKonnteNichtGeladenWerden =>
      'TODO:ar: Rolle konnte nicht geladen werden.';

  @override
  String get ruheBewahren => 'TODO:ar: Ruhe bewahren';

  @override
  String get schmerzErfassen => 'TODO:ar: Schmerz erfassen';

  @override
  String get setzenOderLegenSieSichHinAtmenSieRuhig =>
      'TODO:ar: Setzen oder legen Sie sich hin. Atmen Sie ruhig.';

  @override
  String get sleepEntryEditorNotizOptional => 'TODO:ar: Notiz (optional)';

  @override
  String get speichere => 'TODO:ar: Speichere…';

  @override
  String get speichert => 'TODO:ar: Speichert…';

  @override
  String get streakGerettet => 'TODO:ar: Streak gerettet!';

  @override
  String get symptomCheckServiceNotruf112 => 'TODO:ar: Notruf 112';

  @override
  String get symptomU2011Check => 'TODO:ar: Symptom‑Check';

  @override
  String systemVorlageFehler(String error) {
    return 'TODO:ar: Fehler: $error';
  }

  @override
  String get timelineRoutesAufgabeHinzufuegen => 'TODO:ar: Aufgabe hinzufügen';

  @override
  String get timelineRoutesNotizErstellen => 'TODO:ar: Notiz erstellen';

  @override
  String get timelineTransportTitle => 'تخطيط النقل';

  @override
  String get trittMeinemOperationsbegleiterBeiNN =>
      'TODO:ar: Tritt meinem Operationsbegleiter bei!\n\n';

  @override
  String get uebungenTimerUndFortschritt =>
      'TODO:ar: Übungen, Timer & Fortschritt';

  @override
  String get updatesProStatusUndAppHinweise =>
      'TODO:ar: Updates, Pro-Status & App-Hinweise';

  @override
  String userBlocked(String name) {
    return 'TODO:ar: $name wurde gesperrt.';
  }

  @override
  String userDeleted(String name) {
    return 'TODO:ar: $name wurde gelöscht.';
  }

  @override
  String userGesperrtEntsperrt(String action) {
    return 'TODO:ar: Nutzer $action.';
  }

  @override
  String userUnblocked(String name) {
    return 'TODO:ar: $name wurde entsperrt.';
  }

  @override
  String get vitalsNotizOptional => 'TODO:ar: Notiz (optional)';

  @override
  String get vorWaehrendUndNachDerOP => 'TODO:ar: Vor, während & nach der OP';

  @override
  String get vorlageErzeugen => 'TODO:ar: Vorlage erstellen';

  @override
  String warningCheckSaved(String level) {
    return 'TODO:ar: Warnüberprüfung gespeichert ($level)';
  }

  @override
  String get warnungenBeiKritischenWundkontrollErgebnissen =>
      'TODO:ar: Warnungen bei kritischen Wundkontroll-Ergebnissen';

  @override
  String get warnungenUndNotfall => 'TODO:ar: Warnungen & Notfall';

  @override
  String get wieHastDuGeschlafen => 'TODO:ar: Wie hast du geschlafen?';

  @override
  String get wieStarkSindIhreSchmerzenImOPBereich =>
      'TODO:ar: Wie stark sind Ihre Schmerzen im OP-Bereich?';

  @override
  String get wirdZugewiesen => 'TODO:ar: Wird zugewiesen…';

  @override
  String get wunddokumentation => 'TODO:ar: Wunddokumentation';

  @override
  String get wundenDokumentieren => 'TODO:ar: Wunden dokumentieren';

  @override
  String get zusammenfassungFuerDenArzt =>
      'TODO:ar: Zusammenfassung für den Arzt';

  @override
  String get rtsTitle => 'اختبار العودة إلى الرياضة';

  @override
  String get rtsNewAssessment => 'بدء اختبار جديد';

  @override
  String get rtsLatestResult => 'آخر نتيجة';

  @override
  String get rtsHistory => 'سجل الاختبارات';

  @override
  String get rtsScore => 'النتيجة الكلية';

  @override
  String get rtsCleared => 'معتمد ✓';

  @override
  String get rtsAlmostReady => 'قريباً';

  @override
  String get rtsNotReady => 'غير جاهز بعد';

  @override
  String get rtsClearedMessage =>
      'درجتك أعلى من الحد المطلوب. يمكنك العودة إلى الرياضة – استشر طبيبك أولاً.';

  @override
  String get rtsAlmostReadyMessage =>
      'أنت تتقدم بشكل جيد. واصل التدريب وأعد الاختبار خلال بضعة أسابيع.';

  @override
  String get rtsNotReadyMessage =>
      'جسمك يحتاج مزيداً من الوقت. ركز على إعادة التأهيل قبل ممارسة الرياضة.';

  @override
  String get rtsEmptyTitle => 'هل أنت مستعد للعودة إلى الرياضة?';

  @override
  String get rtsEmptySubtitle =>
      'Start your first fitness test. Instead of arbitrary time rules, measure strength, balance, and stability.';

  @override
  String get rtsAssessmentTitle => 'اختبار اللياقة';

  @override
  String get rtsResultTitle => 'نتيجة الاختبار';

  @override
  String get rtsBreakdown => 'النتائج الفردية';

  @override
  String get rtsFinishAssessment => 'حساب النتيجة';

  @override
  String get rtsDeleteTitle => 'حذف الاختبار';

  @override
  String get rtsDeleteConfirm => 'سيتم حذف هذه النتيجة نهائياً.';

  @override
  String get rtsValidationHint => 'يرجى ملء جميع الحقول المطلوبة.';

  @override
  String get rtsNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get rtsNotesHint => 'مثال: الحالة اليومية …';

  @override
  String rtsStepOf(String current, String total) {
    return 'خطوة $current/$total';
  }

  @override
  String get rtsTestLsiTitle => 'تناظر الطرفين (LSI)';

  @override
  String get rtsTestLsiDesc => 'قارن أداء الجانب المتأثر بالجانب السليم.';

  @override
  String get rtsTestLsiHint => 'LSI ≥ 90% هو الحد الموصى به.';

  @override
  String get rtsLsiSeconds => 'ثواني';

  @override
  String get rtsLsiReps => 'تكرارات';

  @override
  String rtsLsiAffected(String unit) {
    return 'الجانب المتأثر ($unit)';
  }

  @override
  String rtsLsiHealthy(String unit) {
    return 'الجانب السليم ($unit)';
  }

  @override
  String rtsLsiDetailValue(
    String affected,
    String healthy,
    String unit,
    String percent,
  ) {
    return 'متأثر: $affected $unit / سليم: $healthy $unit → LSI: $percent';
  }

  @override
  String get rtsTestBalanceTitle => 'توازن الساق الواحدة';

  @override
  String get rtsTestBalanceDesc => 'قف على الساق المتأثرة أطول فترة ممكنة.';

  @override
  String get rtsTestBalanceHint => '30 ثانية = نقاط كاملة.';

  @override
  String get rtsBalanceSeconds => 'مدة الثبات (ثواني)';

  @override
  String rtsBalanceDetailValue(String seconds) {
    return '$seconds ثانية';
  }

  @override
  String get rtsTestStabilityTitle => 'الاستقرارية (قرفصة أحادية)';

  @override
  String get rtsTestStabilityDesc =>
      'كيف يمكنك إجراء قرفصة أحادية على الساق المتأثرة?';

  @override
  String get rtsStability1 => '1 – غير ممكن، ألم شديد.';

  @override
  String get rtsStability2 => '2 – بالكاد ممكن، مع قيود كبيرة.';

  @override
  String get rtsStability3 => '3 – ممكن مع تعويضات.';

  @override
  String get rtsStability4 => '4 – طبيعي تقريباً.';

  @override
  String get rtsStability5 => '5 – تحكم كامل، بدون ألم.';

  @override
  String rtsStabilityDetailValue(String rating) {
    return 'التقييم الذاتي: $rating / 5';
  }

  @override
  String get rtsTestPainTitle => 'الألم خلال النشاط';

  @override
  String get rtsTestPainDesc =>
      'كم حدة ألمك خلال الأنشطة الرياضية? الدرجة من 0 إلى 10.';

  @override
  String get rtsPainNoKein => '0 – لا ألم';

  @override
  String get rtsPainSevere => '10 – أشد ألم';

  @override
  String rtsPainDetailValue(String level) {
    return 'NRS: $level / 10';
  }

  @override
  String get rtsSportTypeTitle => 'نوع الرياضة';

  @override
  String get rtsSportTypeDesc => 'ما هي الرياضة التي تريد العودة إليها؟';

  @override
  String get rtsSportRunning => 'الجري';

  @override
  String get rtsSportSoccer => 'كرة القدم / الرياضات الجماعية';

  @override
  String get rtsSportStrength => 'تدريب القوة';

  @override
  String get rtsSportCycling => 'ركوب الدراجات';

  @override
  String get rtsSportSwimming => 'السباحة';

  @override
  String get rtsSportMartialArts => 'فنون القتال';

  @override
  String get rtsSportOther => 'أخرى';

  @override
  String get rtsTestHopTitle => 'اختبار القفز بساق واحدة';

  @override
  String get rtsTestHopDesc =>
      'اقفز بأقصى بُعد ممكن على الساق المصابة وقِس المسافة. كرر على الجانب السليم.';

  @override
  String get rtsTestHopHint =>
      'قم بـ 3 محاولات وسجّل أفضل قفزة. LSI ≥ 90٪ هو الحد الأمثل للعودة إلى الرياضة.';

  @override
  String get rtsHopAffected => 'الجانب المصاب (سم)';

  @override
  String get rtsHopHealthy => 'الجانب السليم (سم)';

  @override
  String rtsHopDetailValue(String affected, String healthy, String percent) {
    return 'المصاب: $affected سم / السليم: $healthy سم → LSI: $percent';
  }

  @override
  String get rtsTestTugTitle => 'اختبار النهوض والمشي (TUG)';

  @override
  String get rtsTestTugDesc =>
      'انهض من كرسي، امشِ 3 أمتار، ارجع واجلس. قِس الوقت الإجمالي.';

  @override
  String get rtsTestTugHint =>
      'استخدم زر المؤقت أو أدخل الوقت يدويًا. أقل من 10 ثوانٍ يُعتبر ممتازًا.';

  @override
  String rtsTugDetailValue(String seconds) {
    return '$seconds ثانية';
  }

  @override
  String get rtsTimerStart => 'بدء المؤقت';

  @override
  String get rtsTimerStop => 'إيقاف';

  @override
  String get rtsTimerReset => 'إعادة تعيين';

  @override
  String get rtsTimerRestart => 'إعادة البدء';

  @override
  String get rtsTimerOrManual => 'أو أدخل يدويًا:';

  @override
  String get rtsTimerManualLabel => 'الوقت بالثواني';

  @override
  String get rtsScoreTrend => 'اتجاه النقاط';

  @override
  String get actionActivate => 'Aktivieren';

  @override
  String get actionDeactivate => 'Deaktivieren';

  @override
  String get activePatients => 'Aktive Patienten';

  @override
  String get addDoctorsToOrg => 'Ärzte hinzufügen';

  @override
  String get adDisplayDesc =>
      'Werbung anzeigen, um die kostenlose Version zu unterstützen';

  @override
  String get analyticsDesc =>
      'Anonyme Nutzungsdaten teilen, um die App zu verbessern';

  @override
  String get appointmentEdit => 'Termin bearbeiten';

  @override
  String get backupDesc => 'Automatische Datensicherung aktivieren';

  @override
  String get backupTitle => 'Datensicherung';

  @override
  String get basicFeaturesActive => 'Basis-Funktionen aktiv';

  @override
  String get bellaConsentDesc =>
      'Ich stimme zu, dass meine Gesundheitsdaten für KI-Auswertungen genutzt werden';

  @override
  String get calendarDay => 'Tag';

  @override
  String get changeButton => 'Ändern';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get crashReportsDesc => 'Absturzberichte senden, um Fehler zu beheben';

  @override
  String get createDoctor => 'Arzt anlegen';

  @override
  String get createNewDoctor => 'Neuen Arzt anlegen';

  @override
  String get creating => 'Wird erstellt…';

  @override
  String get datenExportErfolgreich => 'Daten erfolgreich exportiert';

  @override
  String get datenExportFehler => 'Export fehlgeschlagen';

  @override
  String get datenExportieren => 'Daten exportieren';

  @override
  String get datenExportierenDsgvo => 'Daten exportieren (DSGVO)';

  @override
  String get deleteDialogContent =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get doctorProfileAccountSupport => 'Konto & Support';

  @override
  String get doctorProfileClosed => 'Geschlossen';

  @override
  String get doctorProfileImageUploadError =>
      'Foto konnte nicht hochgeladen werden';

  @override
  String get doctorProfileNewSpecialtyHint => 'Neue Fachrichtung eingeben';

  @override
  String get doctorProfileNoSpecialties => 'Keine Fachrichtungen angegeben';

  @override
  String get doctorProfileNotSpecified => 'Nicht angegeben';

  @override
  String get doctorProfileOpeningHours => 'Öffnungszeiten';

  @override
  String get doctorProfilePracticeInfo => 'Praxisinformationen';

  @override
  String get doctorProfilePracticeName => 'Praxisname';

  @override
  String get doctorProfileProfessionalInfo => 'Berufliche Informationen';

  @override
  String get doctorProfileProSubscription => 'Pro-Abonnement';

  @override
  String get doctorProfileSpecialties => 'Fachrichtungen';

  @override
  String get doctorProfileStaffMember => 'Mitarbeiter';

  @override
  String get doctorProfileVerificationPending => 'Verifizierung ausstehend';

  @override
  String get doctorProfileVerified => 'Verifiziert';

  @override
  String get doctorProfileWebsite => 'Website';

  @override
  String get doctorProfileYourProfile => 'Mein Profil';

  @override
  String get errorLoadingDoctors => 'Ärzte konnten nicht geladen werden';

  @override
  String get fieldType => 'Typ';

  @override
  String get freeTier => 'Kostenlos';

  @override
  String get greetingDay => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get guestBannerButton => 'Jetzt registrieren';

  @override
  String get guestBannerSubtitle =>
      'Erstelle ein Konto, um deine Daten zu sichern';

  @override
  String get guestBannerTitle => 'Gast-Modus';

  @override
  String get healthConnectRequired => 'Health Connect wird benötigt';

  @override
  String get healthPermissionDenied => 'Gesundheitsdaten-Zugriff verweigert';

  @override
  String get healthSyncDesc =>
      'Schritt- und Aktivitätsdaten aus Health synchronisieren';

  @override
  String get healthSyncNotSupported =>
      'Gesundheitssynchronisation nicht unterstützt';

  @override
  String get healthSyncSectionTitle => 'Gesundheitsdaten';

  @override
  String get healthSyncTitle => 'Gesundheits-Synchronisation';

  @override
  String get helpContactDesc => 'Schreibe uns eine E-Mail – wir helfen gerne';

  @override
  String get helpContactTitle => 'Kontakt';

  @override
  String get helpEmailSubject => 'Operationsbegleiter Support';

  @override
  String get helpFaq1Question => 'Wie lege ich meinen OP-Termin fest?';

  @override
  String get helpFaq1Answer =>
      'Tippe auf dein Profil und wähle \'OP-Datum festlegen\'. Gib das Datum deiner Operation ein.';

  @override
  String get helpFaq2Question => 'Wie verbinde ich mich mit meinem Arzt?';

  @override
  String get helpFaq2Answer =>
      'Dein Arzt teilt dir einen Einladungscode mit. Gib diesen unter Einstellungen → Arzt verbinden ein.';

  @override
  String get helpFaq3Question => 'Sind meine Daten sicher?';

  @override
  String get helpFaq3Answer =>
      'Ja. Alle Daten werden verschlüsselt gespeichert und nur du und dein Behandlungsteam haben Zugriff.';

  @override
  String get helpFaq4Question => 'Wie funktioniert Bella, die KI-Assistentin?';

  @override
  String get helpFaq4Answer =>
      'Bella analysiert deine Gesundheitsdaten und gibt personalisierte Empfehlungen für deine Genesung.';

  @override
  String get helpFaq5Question => 'Kann ich die App offline nutzen?';

  @override
  String get helpFaq5Answer =>
      'Ja. Die App funktioniert offline und synchronisiert Daten, sobald du wieder online bist.';

  @override
  String get helpFaq6Question => 'Wie kündige ich mein Abonnement?';

  @override
  String get helpFaq6Answer =>
      'Abonnements können über die Einstellungen deines App-Store-Kontos (App Store / Play Store) gekündigt werden.';

  @override
  String get helpFaqTitle => 'Häufige Fragen';

  @override
  String get inviteCode => 'Einladungscode';

  @override
  String get inviteCodeDescription => 'Teile diesen Code mit deinen Patienten';

  @override
  String get inviteCodeLoadError => 'Code konnte nicht geladen werden';

  @override
  String get myPatients => 'Meine Patienten';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get noArchivedOperations => 'Keine archivierten Operationen';

  @override
  String get noDoctorsYet => 'Noch keine Ärzte';

  @override
  String get noPatientsInCategory => 'Keine Patienten in dieser Kategorie';

  @override
  String get noPatientsLinked => 'Keine Patienten verknüpft';

  @override
  String get noPatientsLinkedYet => 'Noch keine Patienten verknüpft';

  @override
  String get noStaffYet => 'Noch keine Mitarbeiter';

  @override
  String get noStaffYetSubtitle =>
      'Lade Mitarbeiter ein, um die Praxisorganisation zu verbessern';

  @override
  String get notes => 'Notizen';

  @override
  String get notifCatAppointments => 'Termine';

  @override
  String get notifCatAppointmentsSub =>
      'Erinnerungen für bevorstehende Termine';

  @override
  String get notifCategories => 'Benachrichtigungskategorien';

  @override
  String get notifCatMedication => 'Medikamente';

  @override
  String get notifCatMedicationSub => 'Erinnerungen für Medikamenteneinnahme';

  @override
  String get notifCatObservations => 'Beobachtungen';

  @override
  String get notifCatObservationsSub =>
      'Hinweise zur Dokumentation von Symptomen';

  @override
  String get notifCatSystem => 'System';

  @override
  String get notifCatSystemSub => 'Wichtige Systemnachrichten';

  @override
  String get notifCatTasks => 'Aufgaben';

  @override
  String get notifCatTasksSub => 'Erinnerungen für Genesungsaufgaben';

  @override
  String get notifCatWounds => 'Wunden';

  @override
  String get notifCatWoundsSub => 'Hinweise zur Wunddokumentation';

  @override
  String get notifCenter => 'Benachrichtigungen';

  @override
  String get notifCenterSubtitle =>
      'Alle deine Benachrichtigungen im Überblick';

  @override
  String get notifGlobalDisabled => 'Benachrichtigungen deaktiviert';

  @override
  String get notifGlobalEnabled => 'Benachrichtigungen aktiviert';

  @override
  String get notifSettingsTitle => 'Benachrichtigungseinstellungen';

  @override
  String get operationHistory => 'Operationsverlauf';

  @override
  String get operationHistoryDesc => 'Deine vergangenen Operationen';

  @override
  String get opInformationTitle => 'Operationsinformationen';

  @override
  String get orgExportEmpty => 'Keine Daten zum Exportieren';

  @override
  String get orgExportError => 'Export fehlgeschlagen';

  @override
  String get orgManagedByOrg => 'Von Organisation verwaltet';

  @override
  String get orgManagementSection => 'Verwaltung';

  @override
  String get orgPatientAppointments => 'Termine';

  @override
  String get orgPatientDoctor => 'Behandelnder Arzt';

  @override
  String get orgPatientNoAppointments => 'Keine Termine vorhanden';

  @override
  String get orgPatientNoTimeline => 'Kein Zeitplan vorhanden';

  @override
  String get orgPatientReadOnly => 'Nur-Lesen-Ansicht';

  @override
  String get orgPatientTimeline => 'Zeitplan';

  @override
  String get orgProfileNotFound => 'Organisationsprofil nicht gefunden';

  @override
  String get orgProfileSaved => 'Profil gespeichert';

  @override
  String get orgProfileSaveError => 'Profil konnte nicht gespeichert werden';

  @override
  String get orgSettingsContactInfo => 'Kontaktinformationen';

  @override
  String get orgSettingsDataExport => 'Datenexport';

  @override
  String get orgSettingsGeneralInfo => 'Allgemeine Informationen';

  @override
  String get orgSettingsOpeningHours => 'Öffnungszeiten';

  @override
  String get orgSettingsWebsite => 'Website';

  @override
  String get passwordMin8Chars => 'Mindestens 8 Zeichen';

  @override
  String get patientListLoadError =>
      'Patientenliste konnte nicht geladen werden';

  @override
  String get pdTabNotes => 'Notizen';

  @override
  String get phaseDischarged => 'Entlassen';

  @override
  String get phaseDistribution => 'Phasenverteilung';

  @override
  String get phaseEntlassen => 'Entlassen';

  @override
  String get phaseOpDay => 'OP-Tag';

  @override
  String get phasePostOp => 'Post-OP';

  @override
  String get phasePreOp => 'Prä-OP';

  @override
  String get planMonthly => 'Monatlich';

  @override
  String get planProMembership => 'Pro-Mitgliedschaft';

  @override
  String get planYearly => 'Jährlich';

  @override
  String get practiceAppointmentCreate => 'Termin erstellen';

  @override
  String get practiceAppointmentEdit => 'Termin bearbeiten';

  @override
  String get praxisPro => 'Praxis Pro';

  @override
  String get praxisProSubtitle => 'Für professionelle Anwender';

  @override
  String get proActive => 'Pro aktiv';

  @override
  String get profileFullComplete => 'Profil vollständig ausgefüllt';

  @override
  String get profileOpToday => 'OP heute';

  @override
  String get profileProMember => 'Pro-Mitglied';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpgradePro => 'Auf Pro upgraden';

  @override
  String get profileVerified => 'Verifiziert';

  @override
  String get profileYourProfile => 'Dein Profil';

  @override
  String get proUnlockNow => 'Jetzt freischalten';

  @override
  String get proUpsellText => 'Schalte alle Pro-Funktionen frei';

  @override
  String get qrScanHint => 'Halte die Kamera auf den QR-Code';

  @override
  String get reauthHint => 'Bitte bestätige dein Passwort, um fortzufahren';

  @override
  String get redeemKey => 'Key einlösen';

  @override
  String get resetDialogContent =>
      'Möchtest du wirklich alle lokalen Daten zurücksetzen?';

  @override
  String get saving => 'Wird gespeichert…';

  @override
  String get searchPatient => 'Patient suchen';

  @override
  String get sectionDoctors => 'Ärzte';

  @override
  String get sectionPatients => 'Patienten';

  @override
  String get sectionSupplements => 'Nahrungsergänzung';

  @override
  String get selectDoctorForDetails =>
      'Wähle einen Arzt aus, um Details zu sehen';

  @override
  String get smokerFormer => 'Ehemaliger Raucher';

  @override
  String get smokerFormerShort => 'Ex';

  @override
  String get smokerNo => 'Nichtraucher';

  @override
  String get smokerNoShort => 'Nein';

  @override
  String get smokerYes => 'Raucher';

  @override
  String get smokerYesShort => 'Ja';

  @override
  String get specialtyAnesthesiology => 'Anästhesiologie';

  @override
  String get specialtyCardiacSurgery => 'Herzchirurgie';

  @override
  String get specialtyEnt => 'Hals-Nasen-Ohren';

  @override
  String get specialtyGeneralSurgery => 'Allgemeinchirurgie';

  @override
  String get specialtyGynecology => 'Gynäkologie';

  @override
  String get specialtyInternalMedicine => 'Innere Medizin';

  @override
  String get specialtyNeurosurgery => 'Neurochirurgie';

  @override
  String get specialtyOphthalmology => 'Augenheilkunde';

  @override
  String get specialtyOrthopedics => 'Orthopädie';

  @override
  String get specialtyOther => 'Sonstige';

  @override
  String get specialtyPlasticSurgery => 'Plastische Chirurgie';

  @override
  String get specialtyUrology => 'Urologie';

  @override
  String get specialtyVascularSurgery => 'Gefäßchirurgie';

  @override
  String get specialtyVisceralSurgery => 'Viszeralchirurgie';

  @override
  String get staffLoadError => 'Mitarbeiter konnten nicht geladen werden';

  @override
  String get staffSectionTitle => 'Mitarbeiter';

  @override
  String get statusActive => 'Aktiv';

  @override
  String get statusDisabled => 'Deaktiviert';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get supplementAddNew => 'Neu hinzufügen';

  @override
  String get supplementBrand => 'Marke / Hersteller';

  @override
  String get supplementCategoryAminosaeuren => 'Aminosäuren';

  @override
  String get supplementCategoryFettsaeuren => 'Fettsäuren';

  @override
  String get supplementCategoryKraeuter => 'Kräuter';

  @override
  String get supplementCategoryLabel => 'Kategorie';

  @override
  String get supplementCategoryMineralien => 'Mineralien';

  @override
  String get supplementCategoryProbiotika => 'Probiotika';

  @override
  String get supplementCategoryProteine => 'Proteine';

  @override
  String get supplementCategorySonstiges => 'Sonstiges';

  @override
  String get supplementCategoryVitamine => 'Vitamine';

  @override
  String get supplementDeleteBody =>
      'Das Nahrungsergänzungsmittel wird dauerhaft gelöscht.';

  @override
  String get supplementDeleteTitle => 'Löschen bestätigen';

  @override
  String get supplementDose => 'Dosierung';

  @override
  String get supplementDoseGuidance => 'Empfohlene Dosierung';

  @override
  String get supplementEdit => 'Bearbeiten';

  @override
  String get supplementEmptyState => 'Noch keine Nahrungsergänzungsmittel';

  @override
  String get supplementLogManual => 'Manuell eintragen';

  @override
  String get supplementLogSuccess => 'Einnahme erfasst';

  @override
  String get supplementName => 'Name';

  @override
  String get supplementNoRecommendations => 'Keine Empfehlungen verfügbar';

  @override
  String get supplementSave => 'Speichern';

  @override
  String get supplementStockEmpty => 'Vorrat aufgebraucht';

  @override
  String get supplementStockLow => 'Vorrat niedrig';

  @override
  String get supplementTabMine => 'Meine';

  @override
  String get supplementTabRecommendations => 'Empfehlungen';

  @override
  String get supplementTabToday => 'Heute';

  @override
  String get supplementTimeSlots => 'Einnahmezeitpunkte';

  @override
  String get supplementTodayHistory => 'Heutige Einnahmen';

  @override
  String get supplementTodayProgress => 'Fortschritt heute';

  @override
  String get syncing => 'Synchronisiert…';

  @override
  String get syncJustNow => 'Gerade eben';

  @override
  String get syncNever => 'Noch nie synchronisiert';

  @override
  String get syncNowButton => 'Jetzt synchronisieren';

  @override
  String get tabCalendar => 'Kalender';

  @override
  String get tabDoctors => 'Ärzte';

  @override
  String get tabOverview => 'Übersicht';

  @override
  String get tabPatients => 'Patienten';

  @override
  String get tabTeam => 'Team';

  @override
  String get teamHeader => 'Team';

  @override
  String get tierBasic => 'Basic';

  @override
  String get title => 'Titel';

  @override
  String get totalPatients => 'Patienten gesamt';

  @override
  String get type => 'Typ';

  @override
  String get upgradeNow => 'Jetzt upgraden';

  @override
  String get upgradeNowArrow => 'Jetzt upgraden →';

  @override
  String get validationInvalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get validationMinChars8 => 'Mindestens 8 Zeichen erforderlich';

  @override
  String get validationRequired => 'Pflichtfeld';

  @override
  String get weekdayFriday => 'Freitag';

  @override
  String get weekdayMonday => 'Montag';

  @override
  String get weekdaySaturday => 'Samstag';

  @override
  String get weekdaySunday => 'Sonntag';

  @override
  String get weekdayThursday => 'Donnerstag';

  @override
  String get weekdayTuesday => 'Dienstag';

  @override
  String get weekdayWednesday => 'Mittwoch';

  @override
  String syncMinutesAgo(int n) {
    return 'Vor $n Minuten';
  }

  @override
  String syncHoursAgo(int n) {
    return 'Vor $n Stunden';
  }

  @override
  String syncDaysAgo(int n) {
    return 'Vor $n Tagen';
  }

  @override
  String lastSyncLabel(String time) {
    return 'Zuletzt: $time';
  }

  @override
  String pendingSyncEntries(int n) {
    return '$n ausstehend';
  }

  @override
  String healthSyncCount(int n) {
    return '$n Datenpunkte synchronisiert';
  }

  @override
  String profilePercentComplete(int n) {
    return '$n% vollständig';
  }

  @override
  String profileAgeYears(int n) {
    return '$n Jahre';
  }

  @override
  String profileOpIn(int n) {
    return 'In $n Tagen';
  }

  @override
  String profileOpAgo(int n) {
    return 'Vor $n Tagen';
  }

  @override
  String validUntil(String date) {
    return 'Gültig bis $date';
  }

  @override
  String datenExportierenBeschreibung(String email) {
    return 'Export wird an $email gesendet';
  }

  @override
  String appointmentDeleteMessage(String title, String patientName) {
    return 'Termin \"$title\" für $patientName löschen?';
  }

  @override
  String eventDeleteMessage(String title) {
    return 'Ereignis \"$title\" löschen?';
  }

  @override
  String confirmAddDoctorToOrg(String name) {
    return '$name zur Organisation hinzufügen?';
  }

  @override
  String confirmRemoveDoctorFromOrg(String name) {
    return '$name aus der Organisation entfernen?';
  }

  @override
  String countActive(int n) {
    return '$n aktiv';
  }

  @override
  String joinedOn(String date) {
    return 'Beigetreten am $date';
  }

  @override
  String joinRequestsCountLabel(int n) {
    return '$n Anfragen';
  }

  @override
  String notifActiveCount(int active, int total) {
    return '$active von $total aktiv';
  }

  @override
  String staffConfirmActivateBody(String name) {
    return '$name wirklich aktivieren?';
  }

  @override
  String staffConfirmDeactivateBody(String name) {
    return '$name wirklich deaktivieren?';
  }

  @override
  String staffWasActivated(String name) {
    return '$name wurde aktiviert';
  }

  @override
  String staffWasDeactivated(String name) {
    return '$name wurde deaktiviert';
  }

  @override
  String staffRemoveConfirmBody(String name) {
    return 'Möchtest du $name wirklich entfernen?';
  }

  @override
  String terminFuerPatient(String name) {
    return 'Termin für $name';
  }

  @override
  String staffActivateConfirmBody(String name) {
    return '$name wirklich aktivieren?';
  }

  @override
  String staffActivated(String name) {
    return '$name wurde aktiviert';
  }

  @override
  String staffDeactivateConfirmBody(String name) {
    return '$name wirklich deaktivieren?';
  }

  @override
  String staffDeactivated(String name) {
    return '$name wurde deaktiviert';
  }

  @override
  String staffCountLabel(int n) {
    return '$n Mitarbeiter';
  }

  @override
  String staffPermissionsSummary(int readCount, int writeCount) {
    return '$readCount Lese-, $writeCount Schreibrechte';
  }

  @override
  String timeAgoMinutes(int n) {
    return 'Vor $n Minuten';
  }

  @override
  String timeAgoHours(int n) {
    return 'Vor $n Stunden';
  }

  @override
  String timeAgoDays(int n) {
    return 'Vor $n Tagen';
  }

  @override
  String disconnectConfirmBody(String name) {
    return 'Verbindung zu $name wirklich trennen?';
  }
}
