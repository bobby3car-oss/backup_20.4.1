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
  String get appointmentForPatient => 'إنشاء موعد للمريض';

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
}
