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
      'هذا التطبيق لا يحل محل الاستشارة الطبية. للشكاوى الصحية يرجى مراجعة طبيبك.';

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
  String get settingsImprint => 'بصمة';

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
  String get tutorialStep1Title => 'مرحباً';

  @override
  String get tutorialStep1Desc =>
      'ستجد هنا كل ما هو مهم عن عمليتك في لمحة واحدة.';

  @override
  String get tutorialStep2Title => 'المواعيد';

  @override
  String get tutorialStep2Desc => 'إدارة مواعيد الطبيب والتحضيرات للعملية.';

  @override
  String get tutorialStep3Title => 'قوائم المراجعة';

  @override
  String get tutorialStep3Desc => 'أنجز مهامك الشخصية خطوة بخطوة.';

  @override
  String get tutorialStep4Title => 'اكتشف المزيد';

  @override
  String get tutorialStep4Desc =>
      'تحت \'المزيد\' ستجد الإعدادات والمساعدة وميزات إضافية.';

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
}
