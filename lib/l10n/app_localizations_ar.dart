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
  String get tabStart => 'الرئيسية';

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
  String get settingsPlaceholder => 'قريباً';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsExportData => 'تصدير البيانات';

  @override
  String get settingsExportPlaceholder => 'التصدير قريباً';

  @override
  String get settingsExportSnack => 'التصدير سيتم إضافته قريباً';

  @override
  String get settingsResetData => 'إعادة تعيين البيانات';

  @override
  String get settingsResetPlaceholder => 'إعادة التعيين قريباً';

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
  String get settingsTermsPlaceholder => 'صفحة الشروط قريباً';

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
  String get commonInProgress => 'قيد التطوير';

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
}
