// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get tabStart => 'Başlangıç';

  @override
  String get tabAppointments => 'Randevular';

  @override
  String get tabMore => 'Daha Fazla';

  @override
  String get commonBack => 'Tamam';

  @override
  String get or => 'veya';

  @override
  String get connectivityOfflineBanner =>
      'Çevrimdışısınız. Tekrar çevrimiçi olduğunuzda değişiklikler senkronize edilecektir.';

  @override
  String get connectivityRequiredTitle => 'İnternet Bağlantısı Yok';

  @override
  String get connectivityRequiredMessage =>
      'Bu özellik internet bağlantısı gerektiriyor. Lütfen bağlanın ve tekrar deneyin.';

  @override
  String get syncIndicatorSynced => 'Tümü senkronize edildi';

  @override
  String syncIndicatorSyncing(int count) {
    return '$count kayıt senkronizasyon bekliyor';
  }

  @override
  String get syncIndicatorOffline => 'Çevrimdışı';

  @override
  String syncIndicatorOfflineWithCount(int count) {
    return 'Çevrimdışı – $count kayıt senkronizasyon bekliyor';
  }

  @override
  String get syncIndicatorTitle => 'Senkronizasyon';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingGetStarted => 'Başla';

  @override
  String get onboardingSlide1Title => 'Operationsbegleiter\'e Hoş Geldiniz';

  @override
  String get onboardingSlide1Subtitle =>
      'Ameliyat öncesi ve sonrası kişisel rehberiniz';

  @override
  String get onboardingSlide1Feature1 => 'Tüm önemli bilgiler bir bakışta';

  @override
  String get onboardingSlide1Feature2 =>
      'Ameliyatınız için kişisel kontrol listeleri';

  @override
  String get onboardingSlide1Feature3 => 'Adım adım süreç boyunca';

  @override
  String get onboardingSlide2Title => 'Hazırlık';

  @override
  String get onboardingSlide2Subtitle => 'Ameliyata en iyi şekilde hazırlanın';

  @override
  String get onboardingSlide2Feature1 => 'Bireysel hazırlık planları';

  @override
  String get onboardingSlide2Feature2 => 'Önemli randevu hatırlatıcıları';

  @override
  String get onboardingSlide2Feature3 => 'Belgeleri dijital olarak yönetin';

  @override
  String get onboardingSlide3Title => 'Bakım';

  @override
  String get onboardingSlide3Subtitle => 'Ameliyat sonrası destek';

  @override
  String get onboardingSlide3Feature1 => 'Günlük sağlık kontrolleri';

  @override
  String get onboardingSlide3Feature2 => 'İlaç hatırlatıcıları';

  @override
  String get onboardingSlide3Feature3 => 'İlerleme takibi';

  @override
  String get onboardingSlide4Title => 'Güvenlik';

  @override
  String get onboardingSlide4Subtitle => 'Verileriniz bizimle güvende';

  @override
  String get onboardingSlide4Feature1 => 'Uçtan uca şifreleme';

  @override
  String get onboardingSlide4Feature2 => 'KVKK uyumlu';

  @override
  String get onboardingSlide4Feature3 => 'Veriler yalnızca cihazınızda';

  @override
  String get onboardingSlide5Title => 'Hazır mısınız?';

  @override
  String get onboardingSlide5Subtitle => 'Şimdi profilinizi oluşturun';

  @override
  String get onboardingSlide5Feature1 => 'Ücretsiz kayıt olun';

  @override
  String get onboardingSlide5Feature2 => 'Birkaç dakika içinde hazır';

  @override
  String get onboardingSlide5Feature3 => 'İstediğiniz zaman silinebilir';

  @override
  String get authSlideTitle => 'Operationsbegleiter';

  @override
  String get authSlideSubtitle => 'Ameliyat için kişisel rehberiniz';

  @override
  String get authSlideRegister => 'Kayıt Ol';

  @override
  String get authSlideLogin => 'Giriş Yap';

  @override
  String get authSlideDoctorRegister => 'Doktor / Kuruluş olarak kayıt ol';

  @override
  String get authSlideGuestMode => 'Misafir Modu';

  @override
  String get registerContinueAsGuest => 'Kayıt olmadan devam et';

  @override
  String get loginWelcomeBack => 'Tekrar Hoş Geldiniz';

  @override
  String get loginSubtitle => 'Devam etmek için giriş yapın';

  @override
  String get loginForgotPassword => 'Şifremi Unuttum';

  @override
  String get loginEnterEmailFirst => 'Lütfen önce e-posta adresinizi girin.';

  @override
  String get loginPasswordResetSent => 'Şifre sıfırlama e-postası gönderildi.';

  @override
  String get loginWithGoogle => 'Google ile giriş yap';

  @override
  String get loginWithApple => 'Apple ile giriş yap';

  @override
  String get noAccountYet => 'Henüz hesabınız yok mu?';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get createAccountTitle => 'Hesap Oluştur';

  @override
  String get createAccountSubtitle => 'Başlamak için kayıt olun';

  @override
  String get fieldEmail => 'E-posta';

  @override
  String get fieldPassword => 'Şifre';

  @override
  String get fieldRepeatPassword => 'Şifreyi Tekrarla';

  @override
  String get fieldFullName => 'Ad Soyad';

  @override
  String get fieldBirthDate => 'Doğum Tarihi';

  @override
  String get fieldBirthDateHint => 'GG.AA.YYYY';

  @override
  String get fieldBirthDatePicker => 'Doğum tarihi seç';

  @override
  String get validationEmailInvalid =>
      'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get validationPasswordMin6 => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get validationPasswordsMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get validationNameRequired => 'Lütfen adınızı girin.';

  @override
  String get validationBirthDateRequired => 'Lütfen doğum tarihinizi girin.';

  @override
  String get validationRepeatPassword => 'Lütfen şifreyi tekrarlayın.';

  @override
  String get datePickerCancel => 'İptal';

  @override
  String get datePickerConfirm => 'Onayla';

  @override
  String get agbAcceptPrefix => 'Kabul ediyorum: ';

  @override
  String get agbTermsLink => 'Kullanım Koşulları';

  @override
  String get agbAndConnector => ' ve ';

  @override
  String get agbPrivacyLink => 'Gizlilik Politikası';

  @override
  String get languageLabel => 'Dil';

  @override
  String get medicalDisclaimer =>
      'Bu uygulama tıbbi tavsiyenin yerini almaz. Sağlık şikayetleriniz için doktorunuza başvurun.';

  @override
  String get doctorRegTitle => 'Doktor olarak kayıt ol';

  @override
  String get doctorRegRoleBadge => 'Doktor';

  @override
  String get doctorRegRoleBadgeSubtitle => 'Doğrulanmış tıp uzmanı';

  @override
  String get doctorRegPersonalData => 'Kişisel Bilgiler';

  @override
  String get doctorRegProfessionalData => 'Mesleki Bilgiler';

  @override
  String get doctorRegNameHint => 'Dr. Ahmet Yılmaz';

  @override
  String get doctorRegEmailHint => 'doktor@muayenehane.com';

  @override
  String get doctorRegEmailRequired => 'Lütfen e-posta adresinizi girin.';

  @override
  String get doctorRegEmailInvalid =>
      'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get doctorRegPasswordMin8 => 'Şifre en az 8 karakter olmalıdır.';

  @override
  String get doctorRegSpecialty => 'Uzmanlık Alanı';

  @override
  String get doctorRegSelectSpecialty => 'Uzmanlık alanı seçin';

  @override
  String get doctorRegApprobation => 'Diploma Numarası';

  @override
  String get doctorRegApprobationHint => 'ör. 12345678';

  @override
  String get doctorRegApprobationRequired => 'Lütfen diploma numaranızı girin.';

  @override
  String get doctorRegKvNumber => 'Sicil Numarası';

  @override
  String get doctorRegKvHint => 'İsteğe bağlı';

  @override
  String get doctorRegPractice => 'Muayenehane / Klinik';

  @override
  String get doctorRegPracticeHint => 'Muayenehane veya klinik adı';

  @override
  String get doctorRegPracticeRequired => 'Lütfen muayenehanenizi girin.';

  @override
  String get doctorRegServiceEmail => 'Mesleki e-posta adresi';

  @override
  String get doctorRegDisclaimer =>
      'Bilgileriniz incelenecek ve doğrulama sonrası hesabınız aktifleştirilecektir.';

  @override
  String get doctorRegSubmit => 'Kayıt Gönder';

  @override
  String get doctorRegSubmitting => 'Gönderiliyor…';

  @override
  String get orgRegTitle => 'Kuruluş olarak kayıt ol';

  @override
  String get orgRegRoleBadge => 'Kuruluş';

  @override
  String get orgRegRoleBadgeSubtitle =>
      'Hastaneler, klinikler ve rehabilitasyon merkezleri';

  @override
  String get orgRegGeneralData => 'Genel Bilgiler';

  @override
  String get orgRegOrgData => 'Kuruluş Bilgileri';

  @override
  String get orgRegOrgName => 'Kuruluş Adı';

  @override
  String get orgRegOrgNameHint => 'ör. Üniversite Hastanesi';

  @override
  String get orgRegNameRequired => 'Lütfen kuruluş adını girin.';

  @override
  String get orgRegOrgType => 'Kuruluş Türü';

  @override
  String get orgRegSelectOrgType => 'Kuruluş türü seçin';

  @override
  String get orgRegAddress => 'Adres';

  @override
  String get orgRegAddressHint => 'Sokak, Posta Kodu, Şehir';

  @override
  String get orgRegAddressRequired => 'Lütfen adresi girin.';

  @override
  String get orgRegContactPerson => 'İletişim Kişisi';

  @override
  String get orgRegContactPersonHint => 'Ad ve Soyad';

  @override
  String get orgRegContactPersonRequired => 'Lütfen bir iletişim kişisi girin.';

  @override
  String get orgRegEmail => 'Kuruluş E-postası';

  @override
  String get orgRegEmailHint => 'info@kurulus.com';

  @override
  String get orgRegPhone => 'Telefon';

  @override
  String get orgRegPhoneHint => '+90 212 345 6789';

  @override
  String get orgRegDisclaimer =>
      'Bilgileriniz incelenecek ve doğrulama sonrası hesabınız aktifleştirilecektir.';

  @override
  String get orgRegSubmit => 'Kayıt Gönder';

  @override
  String get orgRegSubmitting => 'Gönderiliyor…';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsNotAvailable => 'Ayarlar mevcut değil';

  @override
  String get settingsAccount => 'Hesap';

  @override
  String get settingsLogout => 'Çıkış Yap';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsPush => 'Push Bildirimleri';

  @override
  String get settingsEmailNotif => 'E-posta Bildirimleri';

  @override
  String get settingsData => 'Veriler';

  @override
  String get settingsExportData => 'Verileri Dışa Aktar';

  @override
  String get settingsResetData => 'Verileri Sıfırla';

  @override
  String get settingsPro => 'Pro Sürüm';

  @override
  String get settingsProStatus => 'Pro Durumu';

  @override
  String get settingsProSubtitle => 'Tüm özelliklerin kilidini aç';

  @override
  String get settingsLegal => 'Yasal';

  @override
  String get settingsImprint => 'Künye';

  @override
  String get settingsPrivacy => 'Gizlilik';

  @override
  String get settingsTerms => 'Kullanım Koşulları';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get tutorialSkip => 'Atla';

  @override
  String get tutorialNext => 'İleri';

  @override
  String get tutorialFinish => 'Tamamla';

  @override
  String get tutorialNeverShow => 'Bir daha gösterme';

  @override
  String get tutorialStep1Title => 'Hoş Geldiniz';

  @override
  String get tutorialStep1Desc =>
      'Ameliyatınız hakkındaki tüm önemli bilgileri burada bulabilirsiniz.';

  @override
  String get tutorialStep2Title => 'Randevular';

  @override
  String get tutorialStep2Desc =>
      'Doktor randevularınızı ve ameliyat hazırlıklarınızı yönetin.';

  @override
  String get tutorialStep3Title => 'Kontrol Listeleri';

  @override
  String get tutorialStep3Desc => 'Kişisel görevlerinizi adım adım tamamlayın.';

  @override
  String get tutorialStep4Title => 'Daha Fazlasını Keşfedin';

  @override
  String get tutorialStep4Desc =>
      '\'Daha Fazla\' bölümünde ayarlar, yardım ve ek özellikler bulunur.';

  @override
  String get profileCompleteness => 'Profil Tamamlanma';

  @override
  String get profileStillTodo => 'Yapılacaklar';

  @override
  String get profileMoreItems => 'daha fazla';

  @override
  String get profileComplete => 'Profili Tamamla';

  @override
  String get profileCheckName => 'Ad girin';

  @override
  String get profileCheckOpDate => 'Ameliyat tarihi girin';

  @override
  String get profileCheckOpType => 'Ameliyat türü seçin';

  @override
  String get profileCheckDoctor => 'Tedavi eden doktoru girin';

  @override
  String get profileCheckHospital => 'Hastane girin';

  @override
  String get profileCheckHeight => 'Boy girin';

  @override
  String get profileCheckWeight => 'Kilo girin';

  @override
  String get profileCheckEmergencyContact => 'Acil durum kişisi ekleyin';

  @override
  String get doctorRegSpecialtyRequired => 'Lütfen bir uzmanlık alanı seçin.';
}
