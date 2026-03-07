// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ameliyat Rehberi';

  @override
  String get languageLabel => 'Dil';

  @override
  String get languageName => 'Türkçe';

  @override
  String get languageChangeTitle => 'Dil Seçin';

  @override
  String get tabStart => 'Ana Sayfa';

  @override
  String get tabAppointments => 'Randevular';

  @override
  String get tabDocuments => 'Belgeler';

  @override
  String get tabMore => 'Daha Fazla';

  @override
  String get login => 'Giriş';

  @override
  String get loginAction => 'Giriş Yap';

  @override
  String get loginLoading => 'Giriş yapılıyor…';

  @override
  String loginFailed(String error) {
    return 'Giriş başarısız: $error';
  }

  @override
  String loginAppleFailed(String error) {
    return 'Apple ile giriş başarısız: $error';
  }

  @override
  String loginGoogleFailed(String error) {
    return 'Google ile giriş başarısız: $error';
  }

  @override
  String get loginWithApple => 'Apple ile giriş yap';

  @override
  String get loginWithGoogle => 'Google ile giriş yap';

  @override
  String get or => 'veya';

  @override
  String get noAccountYet => 'Hesabınız yok mu? Kayıt olun';

  @override
  String get signupTitle => 'Kayıt';

  @override
  String get createAccountTitle => 'Hesap\nOluştur';

  @override
  String get createAccountSubtitle => 'Başlamak için alanları doldurun.';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get creatingAccount => 'Hesap oluşturuluyor…';

  @override
  String get fieldName => 'İsim';

  @override
  String get fieldFullName => 'Tam Ad';

  @override
  String get fieldEmail => 'E-Posta';

  @override
  String get fieldPassword => 'Şifre';

  @override
  String get fieldConfirmPassword => 'Şifreyi Onayla';

  @override
  String get fieldRepeatPassword => 'Şifreyi Tekrarla';

  @override
  String get fieldBirthDate => 'Doğum Tarihi';

  @override
  String get fieldBirthDateHint => 'GG.AA.YYYY';

  @override
  String get fieldBirthDatePicker => 'Doğum tarihi seçin';

  @override
  String get validationNameRequired => 'İsim girin';

  @override
  String get validationEmailInvalid => 'Geçerli bir e-posta girin';

  @override
  String get validationBirthDateRequired => 'Doğum tarihi seçin';

  @override
  String get validationPasswordMin6 => 'En az 6 karakter';

  @override
  String get validationRepeatPassword => 'Şifreyi tekrarlayın';

  @override
  String get validationPasswordsMismatch => 'Şifreler uyuşmuyor';

  @override
  String get validationPasswordsMismatchLegacy => 'Şifreler uyuşmuyor.';

  @override
  String get errorEmailInUse => 'Bu e-posta zaten kullanılıyor.';

  @override
  String get errorInvalidEmail => 'Geçersiz e-posta adresi.';

  @override
  String get errorWeakPassword => 'Şifre çok zayıf.';

  @override
  String errorRegistrationFailed(String error) {
    return 'Kayıt başarısız: $error';
  }

  @override
  String get agbAcceptPrefix => 'Kabul ediyorum: ';

  @override
  String get agbAcceptLink => 'Kullanım Koşulları ve Gizlilik Politikası';

  @override
  String get datePickerCancel => 'İptal';

  @override
  String get datePickerConfirm => 'Onayla';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAccount => 'Hesap';

  @override
  String get settingsNotAvailable => 'Kullanılamıyor';

  @override
  String get settingsLogout => 'Çıkış';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsPush => 'Push';

  @override
  String get settingsEmailNotif => 'E-Posta';

  @override
  String get settingsPlaceholder => 'Yakında eklenecek';

  @override
  String get settingsData => 'Veriler';

  @override
  String get settingsExportData => 'Verileri Dışa Aktar';

  @override
  String get settingsExportPlaceholder => 'Dışa aktarma yakında';

  @override
  String get settingsExportSnack => 'Dışa aktarma yakında eklenecek';

  @override
  String get settingsResetData => 'Verileri Sıfırla';

  @override
  String get settingsResetPlaceholder => 'Sıfırlama yakında';

  @override
  String get settingsResetSnack => 'Sıfırlama yakında eklenecek';

  @override
  String get settingsPro => 'Pro';

  @override
  String get settingsProStatus => 'Pro Durumu';

  @override
  String get settingsProSubtitle => 'Abonelik & Geri Yükleme';

  @override
  String get settingsLegal => 'Hukuki';

  @override
  String get settingsImprint => 'Künye';

  @override
  String get settingsPrivacy => 'Gizlilik';

  @override
  String get settingsTerms => 'Koşullar';

  @override
  String get settingsTermsPlaceholder => 'Koşullar sayfası yakında';

  @override
  String get settingsTermsSnack => 'Koşullar yakında eklenecek';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonLoading => 'Yükleniyor…';

  @override
  String commonError(String error) {
    return 'Hata: $error';
  }

  @override
  String get commonInProgress => 'Yapım Aşamasında';

  @override
  String get commonUnnamed => 'İsimsiz';

  @override
  String get commonPatients => 'Hastalar';

  @override
  String get commonNoPatientsYet =>
      'Henüz hasta yok. Eklemek için + tuşuna basın';

  @override
  String commonPatientOpened(String name) {
    return 'Hasta açıldı: $name';
  }

  @override
  String get connectivityOfflineBanner =>
      'Çevrimdışısınız. Değişiklikler tekrar çevrimiçi olduğunuzda senkronize edilecektir.';

  @override
  String get connectivityRequiredTitle => 'İnternet bağlantısı yok';

  @override
  String get connectivityRequiredMessage =>
      'Bu özellik internet bağlantısı gerektirmektedir. Lütfen internete bağlanın ve tekrar deneyin.';
}
