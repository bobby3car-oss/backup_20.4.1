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
  String get loginForgotPassword => 'Şifremi Unuttum?';

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
  String get tutorialStep1Title => 'Hoş Geldiniz! 👋';

  @override
  String get tutorialStep1Desc =>
      'Merhaba, ben Bella! Ameliyatınız hakkındaki tüm önemli bilgileri burada bulabilirsiniz.';

  @override
  String get tutorialStep2Title => 'Randevularınız';

  @override
  String get tutorialStep2Desc =>
      'Doktor randevularınızı ve hazırlıklarınızı takip edin – sizi zamanında hatırlatırım.';

  @override
  String get tutorialStep3Title => 'Her Zaman Buradayım';

  @override
  String get tutorialStep3Desc =>
      'Bu benim! 🐰 Her an bana dokunun – iyileşmenizle ilgili tüm sorularınızı yanıtlarım.';

  @override
  String get tutorialStep4Title => 'Daha Fazlasını Keşfedin';

  @override
  String get tutorialStep4Desc =>
      '\'Daha Fazla\' bölümünde ayarlar, yardım ve ek yararlı özellikler bulunur.';

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

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get save => 'Kaydet';

  @override
  String get edit => 'Düzenle';

  @override
  String get done => 'Tamam';

  @override
  String get confirm => 'Onayla';

  @override
  String get close => 'Kapat';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get add => 'Ekle';

  @override
  String get remove => 'Kaldır';

  @override
  String get share => 'Paylaş';

  @override
  String get copy => 'Kopyala';

  @override
  String get send => 'Gönder';

  @override
  String get next => 'İleri';

  @override
  String get back => 'Geri';

  @override
  String get reset => 'Sıfırla';

  @override
  String get activate => 'Etkinleştir';

  @override
  String get deactivate => 'Devre dışı bırak';

  @override
  String get unlock => 'Kilidi aç';

  @override
  String get create => 'Oluştur';

  @override
  String get update => 'Güncelle';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get all => 'Tümü';

  @override
  String get none => 'Hiçbiri';

  @override
  String get details => 'Ayrıntılar';

  @override
  String get info => 'Bilgi';

  @override
  String get warning => 'Uyarı';

  @override
  String get urgent => 'Acil';

  @override
  String get critical => 'Kritik';

  @override
  String get high => 'Yüksek';

  @override
  String get low => 'Düşük';

  @override
  String get normal => 'Normal';

  @override
  String get minimal => 'Minimal';

  @override
  String get daily => 'Günlük';

  @override
  String get weekdays => 'Hafta içi';

  @override
  String get everyNDays => 'Her N gün';

  @override
  String get customDay => 'Özel gün';

  @override
  String get repeatUntil => 'Tekrarla (bitiş)';

  @override
  String get repetition => 'Tekrar';

  @override
  String get recurring => 'Tekrarlayan';

  @override
  String get allDay => 'Tüm gün';

  @override
  String get notAvailable => 'Mevcut değil';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get logoutConfirm => 'Çıkış yapılsın mı?';

  @override
  String get logoutAdminConfirm =>
      'Yönetici alanından gerçekten çıkmak istiyor musunuz?';

  @override
  String get login => 'Giriş yap';

  @override
  String get register => 'Kayıt ol';

  @override
  String get accountRequired => 'Hesap gerekli';

  @override
  String get passwordConfirm => 'Şifreyi onayla';

  @override
  String get passwordChanged => 'Şifre değiştirildi';

  @override
  String get passwordReset => 'Şifre sıfırla';

  @override
  String get passwordResetDone => 'Şifre sıfırlandı';

  @override
  String get passwordsMismatch => 'Şifreler uyuşmuyor';

  @override
  String get passwordMin6 => 'En az 6 karakter';

  @override
  String newPasswordFor(String name) {
    return '$name için yeni şifre';
  }

  @override
  String get deleteAccountTitle => 'Hesap kalıcı olarak silinsin mi?';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get deleteDataOnly => 'Yalnızca verileri sil';

  @override
  String get deleteFinal => 'Kalıcı olarak sil';

  @override
  String get deleteUserAndData => 'Kullanıcı ve tüm veriler silindi.';

  @override
  String get resetDataTitle => 'Verileri sıfırla';

  @override
  String get allDataIrreversible => 'Tüm verileri geri dönüşümsüz olarak sil';

  @override
  String get guestDataFound => 'Yerel veri bulundu';

  @override
  String get guestDataDiscard => 'Hayır, at';

  @override
  String get guestDataTransfer => 'Evet, aktar';

  @override
  String get settingSaveError => 'Ayar kaydedilemedi.';

  @override
  String get settingSaved => 'Ayarlar kaydedildi.';

  @override
  String get tutorialRepeat => 'Öğreticiyi tekrarla';

  @override
  String get tutorialRepeatSubtitle => 'Tanıtımı tekrar göster';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationsActive => 'Bildirimler etkin';

  @override
  String get notificationsManage => 'Bildirimleri yönet';

  @override
  String notificationsCountNew(int count) {
    return 'Bildirimler ($count yeni)';
  }

  @override
  String get pushNotifications => 'Push bildirimleri';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfUse => 'Kullanım Koşulları';

  @override
  String get adDisplays => 'Reklamlar';

  @override
  String get usageStats => 'Kullanım istatistikleri';

  @override
  String get crashReports => 'Çökme raporları';

  @override
  String get bellaAiAssistant => 'Bella Yapay Zeka Asistanı';

  @override
  String get exportAsPdf => 'PDF olarak dışa aktar';

  @override
  String get exportAsPdfSubtitle => 'Açık genel bakış raporu';

  @override
  String get exportAsJson => 'JSON olarak dışa aktar';

  @override
  String get exportAsJsonSubtitle => 'Arşivleme için tüm ham veriler';

  @override
  String get exportCreating => 'Dışa aktarma oluşturuluyor…';

  @override
  String get exportPreparing => 'Dışa aktarma hazırlanıyor…';

  @override
  String get csvExporting => 'CSV dışa aktarılıyor…';

  @override
  String get appointment => 'Randevu';

  @override
  String get appointmentCreate => 'Randevu oluştur';

  @override
  String get appointmentAdd => 'Randevu ekle';

  @override
  String get appointmentConfirmed => 'Randevu onaylandı';

  @override
  String get appointmentDeclined => 'Randevu reddedildi';

  @override
  String get appointmentDeleteConfirm => 'Randevu silinsin mi?';

  @override
  String get appointmentSaveError => 'Randevu kaydedilemedi.';

  @override
  String get appointmentCreateError => 'Randevu oluşturulamadı.';

  @override
  String get appointmentDeleteError => 'Randevu silinirken hata';

  @override
  String get appointmentForPatient => 'Hasta için randevu oluştur';

  @override
  String get practiceAppointment => 'Muayenehane randevusu';

  @override
  String get practiceAppointmentOwn =>
      'Kendi dahili muayenehane randevusu oluştur';

  @override
  String get practiceAppointmentSaveError =>
      'Muayenehane randevusu kaydedilemedi.';

  @override
  String get practiceAppointmentDeleteConfirm =>
      'Muayenehane randevusu silinsin mi?';

  @override
  String get calendarAddTitle => 'Takvime eklensin mi?';

  @override
  String get calendarNoThanks => 'Hayır, teşekkürler';

  @override
  String get calendarShareIcs => '.ics olarak paylaş';

  @override
  String get calendarAdd => 'Takvime ekle';

  @override
  String get medication => 'İlaç';

  @override
  String get medicationAdd => 'İlaç ekle';

  @override
  String get medicationPlan => 'İlaç planı';

  @override
  String get medicationHubOpen => 'İlaç merkezini aç';

  @override
  String get medicationIntakeTimes => 'Alım saatleri';

  @override
  String get medicationIntakeSaveError => 'Alım kaydedilirken hata';

  @override
  String get medicationStock => 'Stok (isteğe bağlı)';

  @override
  String get medicationLocalAlarms =>
      'Etkinleştirilmiş saatler için yerel alarmlar';

  @override
  String get medicationAlarmDeleteError => 'Alarm silinirken hata';

  @override
  String get patient => 'Hasta';

  @override
  String get patientInvite => 'Hasta davet et';

  @override
  String get patientAdd => 'Hasta ekle';

  @override
  String get patientConnect => 'Hasta bağla';

  @override
  String get patientLinked => 'Hasta başarıyla bağlandı!';

  @override
  String get patientLinking => 'Hasta Bağlama';

  @override
  String get patientPlan => 'Hasta planı';

  @override
  String get patientAppointment => 'Hasta randevusu';

  @override
  String get patientData => 'Hasta verileri';

  @override
  String get patientNoInvites => 'Hasta daveti yok.';

  @override
  String get doctor => 'Doktor';

  @override
  String get doctorAdd => 'Doktor ekle';

  @override
  String get doctorRemove => 'Doktoru kaldır';

  @override
  String get doctorConfirm => 'Doktoru onayla';

  @override
  String get doctorDisconnect => 'Doktoru bağlantısını kes';

  @override
  String get doctorDeleted => 'Doktor silindi.';

  @override
  String get doctorCreated => 'Doktor oluşturuldu';

  @override
  String get doctorDetails => 'Doktor ayrıntıları';

  @override
  String get doctorCreateInvite => 'Doktor daveti oluştur';

  @override
  String get doctorVerification => 'Doktor doğrulaması';

  @override
  String get doctorNoInvites => 'Doktor daveti yok.';

  @override
  String get doctorManage => 'Doktorları yönet';

  @override
  String get doctorEnterUid => 'Lütfen bir doktor UID girin.';

  @override
  String get doctorReportNotAvailable => 'Doktor raporu mevcut değil.';

  @override
  String get treatingDoctor => 'Tedavi eden doktor';

  @override
  String get templateNew => 'Yeni şablon';

  @override
  String get templateNone => 'Şablon bulunamadı';

  @override
  String get templateDelete => 'Şablon silinsin mi?';

  @override
  String templateDeleteConfirm(String name) {
    return '\"$name\" gerçekten silinsin mi?';
  }

  @override
  String get templateSaved => 'Şablon kaydedildi';

  @override
  String get templateSave => 'Şablonu kaydet';

  @override
  String get templateApply => 'Şablonu uygula';

  @override
  String get templateFromTasks => 'Görevlerden şablon';

  @override
  String get templateFromTasksCreate => 'Görevlerden şablon oluştur';

  @override
  String templateCreated(String name) {
    return '\"$name\" şablonu oluşturuldu';
  }

  @override
  String templateDuplicated(String name) {
    return '\"$name\" oluşturuldu';
  }

  @override
  String get templateDuplicateError => 'Çoğaltma hatası';

  @override
  String templateAdopted(String name) {
    return '\"$name\" kendi şablonlara eklendi';
  }

  @override
  String get templateAdoptError => 'Alma hatası';

  @override
  String get templateDeleteError => 'Şablon silinirken hata';

  @override
  String get templateOwnTemplates => 'Kendi şablonlar';

  @override
  String get templateDuplicate => 'Çoğalt';

  @override
  String get templateAdopt => 'Al';

  @override
  String get systemTemplates => 'Sistem şablonları';

  @override
  String get systemTemplateDelete => 'Sistem şablonu silinsin mi?';

  @override
  String get systemTemplateNone => 'Henüz sistem şablonu yok';

  @override
  String get systemTemplateFirst => 'İlk sistem şablonu';

  @override
  String get task => 'Görev';

  @override
  String get taskDefine => 'Görev tanımla';

  @override
  String get taskCreate => 'Görev oluştur';

  @override
  String get taskCreateError => 'Görev oluşturulamadı.';

  @override
  String get taskAssign => 'Görev ata';

  @override
  String get taskRequired => 'Zorunlu öğe';

  @override
  String tasksCount(int count) {
    return 'Görevler ($count)';
  }

  @override
  String tasksSelectCount(int selected, int total) {
    return 'Görevleri seçin ($selected/$total):';
  }

  @override
  String get tasksSelectToApply => 'Uygulanacak görevleri seçin:';

  @override
  String get tasksNone => 'Görev yok';

  @override
  String get tasksNoneYet => 'Henüz görev yok';

  @override
  String get tasksNoneAdded => 'Henüz görev eklenmedi';

  @override
  String get tasksNoneInPlan => 'Planda henüz görev yok.';

  @override
  String get tasksNoneAssigned => 'Atanmış görev bulunamadı.';

  @override
  String get taskSaveError => 'Görev kaydedilirken hata';

  @override
  String get taskRepeatCount => 'Tekrar sayısı';

  @override
  String get taskDayOffset => 'Gün kaydırma';

  @override
  String get taskDueAfterHours => 'Son tarih (saat sonra)';

  @override
  String get taskTimeOfDay => 'Günün saati (isteğe bağlı)';

  @override
  String get taskMustNotForget => 'Unutulmamalı';

  @override
  String get phase => 'Aşama';

  @override
  String get phases => 'Aşamalar';

  @override
  String get phaseNone => 'Aşama yok';

  @override
  String get phasesNone => 'Aşama yok – tüm görevler geneldir.';

  @override
  String get phaseRename => 'Aşamayı yeniden adlandır';

  @override
  String get inviteCreate => 'Davet oluştur';

  @override
  String get inviteCreated => 'Davet oluşturuldu';

  @override
  String get inviteCreateError => 'Davet oluşturulamadı.';

  @override
  String get inviteAcceptError => 'Davet kabul edilemedi.';

  @override
  String get inviteRevoke => 'Davet iptal edilsin mi?';

  @override
  String get inviteRevoked => 'Davet iptal edildi.';

  @override
  String get inviteAccepted => 'Davet kabul edildi.';

  @override
  String get invitations => 'Davetler';

  @override
  String get inviteCodeCopied => 'Davet kodu kopyalandı';

  @override
  String get linkCopied => 'Bağlantı kopyalandı';

  @override
  String get codeCopied => 'Kod kopyalandı';

  @override
  String get codeCopiedExcl => 'Kod kopyalandı!';

  @override
  String get codeEnter => 'Kodu girin';

  @override
  String get codeCopy => 'Kodu kopyala';

  @override
  String get inviteFamilyMember => 'Aile üyesi davet et';

  @override
  String get observation => 'Gözlem kaydet';

  @override
  String get observationNew => 'Yeni gözlem';

  @override
  String get observationsNone => 'Henüz gözlem kaydedilmedi.';

  @override
  String get myObservations => 'Gözlemlerim';

  @override
  String get woundDoc => 'Yara belgeleme';

  @override
  String get woundNoEntries => 'Henüz yara kaydı yok.';

  @override
  String get woundPhotoForAnalysis => 'Analiz için yara fotoğrafı';

  @override
  String get woundChoosePhoto =>
      'Bella ile yapay zeka yara analizi için bir fotoğraf seçin';

  @override
  String get woundNoPhotos => 'Analiz için yara fotoğrafı mevcut değil.';

  @override
  String get woundNoPhoto => 'Analiz için fotoğraf mevcut değil.';

  @override
  String get woundTakePhoto => '📷  Yeni fotoğraf çek';

  @override
  String get woundFromGallery => '🖼️  Galeriden seç';

  @override
  String get woundMinPhotos => 'Karşılaştırma için en az 2 fotoğraf gerekli.';

  @override
  String get woundCompare => 'Karşılaştır';

  @override
  String get woundSliderMix => 'A/B kaydırıcı karışımı';

  @override
  String get painLevel => 'Ağrı seviyesi';

  @override
  String get painComparison => 'Ağrı seviyesi karşılaştırması';

  @override
  String get painCourse7d => 'Ağrı seyri (7 gün)';

  @override
  String get painSaved => 'Ağrı değeri kaydedildi';

  @override
  String painScoreOf10(int score) {
    return 'Ağrı: $score/10';
  }

  @override
  String painLevelOf10(int level) {
    return 'Ağrı seviyesi: $level/10';
  }

  @override
  String get unbearable => 'Dayanılmaz';

  @override
  String get moodSaved => 'Ruh hali kaydedildi';

  @override
  String get moodDeleteConfirm =>
      'Bu ruh hali kaydını gerçekten silmek istiyor musunuz?';

  @override
  String get nutritionDescribeMeal => 'Lütfen yemeğinizi tanımlayın';

  @override
  String get nutritionSaved => 'Yemek kaydedildi';

  @override
  String get nutritionRecipes => 'Tarifler';

  @override
  String get nutritionDailyGoals => 'Günlük hedefler';

  @override
  String get vitalsMeasurementSaved => 'Ölçüm kaydedildi';

  @override
  String vitalsNewMeasurementsSync(int count) {
    return 'Health\'ten $count yeni ölçüm senkronize edildi';
  }

  @override
  String get bodyData => 'Vücut verileri';

  @override
  String get packingListReset => 'Bavul listesi sıfırlansın mı?';

  @override
  String get packingListNoItems => 'Bavul listesi öğesi mevcut değil.';

  @override
  String get packingListDelete => 'Liste silinsin mi?';

  @override
  String get packingListRename => 'Listeyi yeniden adlandır';

  @override
  String get packingListNew => 'Yeni liste';

  @override
  String get packingListName => 'Liste adı';

  @override
  String get packingListAddItem => 'Öğe ekle';

  @override
  String get documentUpload => 'Belge yükle';

  @override
  String get documentDeleteConfirm => 'Belge silinsin mi?';

  @override
  String get documentSavedLocally => 'Belge yerel olarak kaydedildi.';

  @override
  String get documentsOpen => 'Belgeleri aç';

  @override
  String get documentsAll => 'Tüm belgeler';

  @override
  String get noteDelete => 'Notu sil';

  @override
  String get noteSave => 'Notu kaydet';

  @override
  String get noteDeleteError => 'Not silinirken hata';

  @override
  String get noteSaveError => 'Not kaydedilirken hata';

  @override
  String get voiceMemoSaved => 'Not kaydedildi';

  @override
  String get voiceMemoDelete => 'Not silinsin mi?';

  @override
  String get voiceStartRecording => 'Kaydı başlat';

  @override
  String get voiceNoMemos => 'Not bulunamadı.';

  @override
  String get voiceTranscriptSaved => 'Transkript kaydedildi';

  @override
  String get voiceNoTranscript =>
      'Transkript yok – lütfen önce yazıya çevirin.';

  @override
  String get voiceAudioNotFoundLocal => 'Ses dosyası yerel olarak bulunamadı.';

  @override
  String get voiceAudioNotFound => 'Ses dosyası bulunamadı.';

  @override
  String get voiceMicPermissionMissing => 'Mikrofon izni eksik.';

  @override
  String get profileEdit => 'Profili düzenle';

  @override
  String get profileSaved => 'Profil kaydedildi';

  @override
  String get profileSaveError => 'Profil kaydedilemedi.';

  @override
  String get yourDetails => 'Bilgileriniz';

  @override
  String get smokerStatus => 'Sigara durumu';

  @override
  String get hospitalClinic => 'Hastane / Klinik';

  @override
  String get treatmentType => 'Tedavi türü *';

  @override
  String get opDate => 'Ameliyat tarihi *';

  @override
  String get currentOperation => 'Mevcut ameliyat';

  @override
  String get operationArchived => 'Ameliyat arşivlendi';

  @override
  String get markOpComplete => 'Mevcut ameliyatı tamamlandı olarak işaretle';

  @override
  String get stayType => 'Kalış türü';

  @override
  String get startDateOpDate => 'Başlangıç tarihi (ör. ameliyat tarihi)';

  @override
  String get emergencyContact => 'Acil durum kişisi';

  @override
  String get transportPlanSaved => 'Ulaşım planlaması kaydedildi';

  @override
  String get healthOverview => 'Sağlık genel bakışınız';

  @override
  String get proUnlock => 'Pro\'yu aç';

  @override
  String get proRedeemKey => 'Pro anahtarı kullan';

  @override
  String get proKeys => 'Pro Anahtarları';

  @override
  String get proKeysCreate => 'Pro anahtarları oluştur';

  @override
  String get proGrantAccess => 'Pro erişimi ver';

  @override
  String get proHowManyDays => 'Kaç gün Pro erişimi?';

  @override
  String get proStatusChangeError => 'Pro durumu değiştirilemedi.';

  @override
  String get proManageSubscription => 'Aboneliği yönet';

  @override
  String get proRestorePurchase => 'Satın almayı geri yükle';

  @override
  String staffMember(String action) {
    return 'Personel $action';
  }

  @override
  String get staffUpdated => 'Personel güncellendi';

  @override
  String get staffRemove => 'Personeli kaldır';

  @override
  String get staffCreate => 'Personel oluştur';

  @override
  String get staffCreated => 'Personel oluşturuldu';

  @override
  String get orgJoin => 'Kuruluşa katıl';

  @override
  String get orgJoinWithCode => 'Davet koduyla katıl';

  @override
  String get orgConfirm => 'Kuruluşu onayla';

  @override
  String get orgVerification => 'Kuruluş doğrulaması';

  @override
  String get ticketNew => 'Yeni bilet';

  @override
  String get ticketCreated => 'Bilet oluşturuldu!';

  @override
  String get ticketClosed => 'Bilet kapatıldı.';

  @override
  String get ticketCloseConfirm => 'Bilet kapatılsın mı?';

  @override
  String get ticketCloseExplanation => 'Bilet kapalı olarak işaretlenecek.';

  @override
  String get tickets => 'Biletler';

  @override
  String ticketsCountOpen(int count) {
    return 'Biletler ($count açık)';
  }

  @override
  String get myTickets => 'Biletlerim';

  @override
  String get messageSendError => 'Mesaj gönderilemedi.';

  @override
  String get message => 'Mesaj';

  @override
  String get noMessagesYet => 'Henüz mesaj yok.';

  @override
  String get questionAdd => 'Soru ekle';

  @override
  String get questionNew => 'Yeni soru';

  @override
  String get questionCreate => 'Soru oluştur';

  @override
  String get questionDelete => 'Soru silinsin mi?';

  @override
  String get loginToSaveQuestions =>
      'Soruları kaydetmek için lütfen giriş yapın.';

  @override
  String get bellaSummarize => 'Bella ile özetle';

  @override
  String get bellaAnalyze => 'Bella ile analiz et';

  @override
  String get bellaGenerate => 'Şimdi oluştur';

  @override
  String get bellaRegenerate => 'Yeniden oluştur';

  @override
  String get bellaBriefingCopied => 'Brifing panoya kopyalandı';

  @override
  String redFlagSaved(String level) {
    return 'Uyarı işareti kontrolü kaydedildi ($level)';
  }

  @override
  String get severityCourse => 'Şiddet seyri';

  @override
  String get lastFlags => 'Son işaretler';

  @override
  String get lastEntries => 'Son kayıtlar:';

  @override
  String get photoSaved => 'Fotoğraf kaydedildi ve senkronize edildi.';

  @override
  String get photo => 'Fotoğraf';

  @override
  String get cameraOpening => 'Kamera açılıyor…';

  @override
  String get entryDeleted => 'Kayıt silindi';

  @override
  String get entryDeleteConfirm => 'Kayıt silinsin mi?';

  @override
  String get entryDeleteIrreversible => 'Bu kayıt kalıcı olarak silinecek.';

  @override
  String get entryDetailed => 'Ayrıntılı kayıt';

  @override
  String get entryNew => 'Yeni kayıt';

  @override
  String get minTwoEntriesForComparison =>
      'Karşılaştırma için en az 2 kayıt gerekli.';

  @override
  String get saveError => 'Kaydetme hatası';

  @override
  String get saveFailed => 'Kaydetme başarısız';

  @override
  String get saveFailedDot => 'Kaydetme başarısız.';

  @override
  String get deleteError => 'Silme hatası';

  @override
  String get disconnectError => 'Bağlantı kesme hatası';

  @override
  String get restoreError => 'Geri yükleme hatası';

  @override
  String get pinError => 'Sabitleme hatası';

  @override
  String get unlockFailed => 'Kilit açma başarısız.';

  @override
  String get lockFailed => 'Kilitleme başarısız.';

  @override
  String get deleteFailed => 'Silme başarısız.';

  @override
  String get actionFailed => 'İşlem başarısız.';

  @override
  String get dataLoadError => 'Veriler yüklenemedi.';

  @override
  String get pageOpenError => 'Bu sayfa açılamadı.';

  @override
  String get noLocalFile => 'Yerel dosya mevcut değil.';

  @override
  String get fileNotFound => 'Dosya bulunamadı.';

  @override
  String get fileReadError => 'Dosya okunamadı.';

  @override
  String get uploadPending => 'Yükleme bekliyor. Tekrar deneniyor.';

  @override
  String get uploadFailedLocal =>
      'Yükleme başarısız – yerel olarak kaydedildi.';

  @override
  String get noEmailApp => 'E-posta uygulaması bulunamadı';

  @override
  String get titleRequired => 'Lütfen bir başlık girin';

  @override
  String get titleAndMessageRequired => 'Başlık ve mesaj boş olmamalıdır.';

  @override
  String get titleAndUrlRequired => 'Başlık ve URL gereklidir.';

  @override
  String get urlInvalid => 'Lütfen tam bir http(s) URL girin.';

  @override
  String get imageRequired => 'Lütfen partner reklam için bir resim seçin.';

  @override
  String get resultSaved => 'Sonuç kaydedildi';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı!';

  @override
  String get reportCopied => 'Rapor panoya kopyalandı';

  @override
  String get allCopied => 'Tüm anahtarlar panoya kopyalandı!';

  @override
  String get allCopy => 'Tümünü kopyala';

  @override
  String get selectSpecialty => 'Lütfen bir uzmanlık alanı seçin';

  @override
  String get selectMinOneSection => 'En az bir bölüm seçin.';

  @override
  String errorGeneric(String error) {
    return 'Hata: $error';
  }

  @override
  String get testNotificationCreated => 'Test bildirimi oluşturuldu.';

  @override
  String get companion => 'Refakatçi';

  @override
  String get timeline => 'Zaman çizelgesi';

  @override
  String get toTimeline => 'Zaman çizelgesine';

  @override
  String get openDiary => 'Günlüğü aç';

  @override
  String get openFullDiary => 'Tam günlüğü aç';

  @override
  String get checklists => 'Kontrol listesi';

  @override
  String get categories => 'Kategoriler';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get statisticsLoadError => 'İstatistikler güncellenemedi.';

  @override
  String get statisticsLoading => 'İstatistikler yükleniyor...';

  @override
  String get tags => 'Etiketler';

  @override
  String get permissions => 'İzinler';

  @override
  String get permissionsUpdated => 'İzinler güncellendi';

  @override
  String get myPermissions => 'İzinlerim';

  @override
  String get readAllowed => 'Okumaya izin ver';

  @override
  String get writeAllowed => 'Yazmaya izin ver';

  @override
  String get readOnly => 'Salt okunur';

  @override
  String get read => 'Oku';

  @override
  String get settings => 'Ayarlar';

  @override
  String get general => 'Genel';

  @override
  String get practice => 'Muayenehane';

  @override
  String get history => 'Geçmiş';

  @override
  String get preview => 'Önizleme';

  @override
  String get status => 'Durum';

  @override
  String get role => 'Rol';

  @override
  String get roleChange => 'Rol değiştir';

  @override
  String get roleChangeError => 'Rol değiştirilemedi.';

  @override
  String get roleDistribution => 'Rol dağılımı';

  @override
  String get markAsRead => 'Okundu olarak işaretle';

  @override
  String get unread => 'Okunmamış';

  @override
  String get pending => 'Bekliyor';

  @override
  String get accepted => 'Kabul edildi';

  @override
  String get declined => 'Reddedildi';

  @override
  String get resolved => 'Çözüldü';

  @override
  String get inProgress => 'Devam ediyor';

  @override
  String get locked => 'Kilitli';

  @override
  String get full => 'Tam';

  @override
  String get off => 'Kapalı';

  @override
  String get system => 'Sistem';

  @override
  String get user => 'Kullanıcı';

  @override
  String get overlayMode => 'Kaplama modu';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get noAccess => 'Erişim yok';

  @override
  String get sureQuestion => 'Emin misiniz?';

  @override
  String get disconnect => 'Bağlantıyı kes';

  @override
  String get disconnectConfirm => 'Bağlantı kesilsin mi?';

  @override
  String get disconnected => 'Bağlantı kesildi';

  @override
  String get connect => 'Bağlan';

  @override
  String get connectionRemove => 'Bağlantıyı kaldır';

  @override
  String get archive => 'Arşivle';

  @override
  String get restore => 'Geri yükle';

  @override
  String get rename => 'Yeniden adlandır';

  @override
  String get editTitle => 'Başlığı düzenle';

  @override
  String get filterReset => 'Filtreyi sıfırla';

  @override
  String get sendEmail => 'E-posta gönder';

  @override
  String get day => 'Gün';

  @override
  String get moreTools => 'Daha fazla araç';

  @override
  String get checkAgain => 'Tekrar kontrol et';

  @override
  String get adDelete => 'Reklam silinsin mi?';

  @override
  String adDeleteMessage(String title) {
    return '\"$title\" kalıcı olarak silinecek.';
  }

  @override
  String get adGlobalSettings => 'Genel ayarlar';

  @override
  String get adEnabled => 'Reklamlar etkin';

  @override
  String get adGoogleAds => 'Google Ads';

  @override
  String get adAdmobBanner => 'AdMob banner reklamları göster';

  @override
  String get adPartnerAds => 'Partner reklamları';

  @override
  String adPartnerAdsCount(int count) {
    return 'Partner reklamları ($count)';
  }

  @override
  String get adFrequency => 'Sıklık';

  @override
  String get adPartnerCreate => 'Partner reklam oluştur';

  @override
  String get adminActivities7d => 'Yönetici etkinlikleri (7 gün)';

  @override
  String get adminActionDistribution7d => 'İşlem dağılımı (7 gün)';

  @override
  String get adminNewRegistrations30d => 'Yeni kayıtlar (30 gün)';

  @override
  String get adminRegistrations => 'Kayıtlar';

  @override
  String get adminStatusOverview => 'Durum genel bakışı';

  @override
  String get adminAllRoles => 'Tüm roller';

  @override
  String get adminUserManage => 'Kullanıcıları yönet';

  @override
  String get adminUserLock => 'Kullanıcıyı kilitle';

  @override
  String get adminAuditLog => 'Denetim günlüğü';

  @override
  String get adminLogsAppear => 'Günlükler burada görünecek.';

  @override
  String get adminMaintenanceMode => 'Bakım modunu etkinleştir';

  @override
  String get adminMaintenanceError => 'Bakım modu değiştirilemedi.';

  @override
  String get adminFirebaseSmokeTest => 'Firebase Smoke Test';

  @override
  String get declineRequest => 'Talebi reddet';

  @override
  String get requestDeclined => 'Talep reddedildi';

  @override
  String get requestNotFound => 'Talep bulunamadı.';

  @override
  String get requestReactivate => 'Talep yeniden etkinleştirilsin mi?';

  @override
  String requestReactivated(String name) {
    return '$name talebi yeniden etkinleştirildi.';
  }

  @override
  String get reactivate => 'Yeniden etkinleştir';

  @override
  String get reactivationFailed => 'Yeniden etkinleştirme başarısız.';

  @override
  String get verificationFailed => 'Doğrulama başarısız.';

  @override
  String get declineReason => 'Ret nedeni';

  @override
  String get declineReasonAlt => 'Ret nedeni';

  @override
  String get internalCommentOptional => 'İsteğe bağlı dahili yorum:';

  @override
  String get decline => 'Reddet';

  @override
  String get accept => 'Kabul et';

  @override
  String get revoke => 'İptal et';

  @override
  String pushTo(String target) {
    return '$target için push gönder';
  }

  @override
  String pushSent(String target) {
    return '$target için push gönderildi.';
  }

  @override
  String get pushSendError => 'Push gönderilemedi.';

  @override
  String get kneeArthroscopy => 'Diz artroskopisi';

  @override
  String get uniClinicMunich => 'Münih Üniversite Hastanesi';

  @override
  String get wakeTimeMustBeAfterBed =>
      'Uyanma saati yatma saatinden sonra olmalıdır.';

  @override
  String get qrCodeScan => 'QR kodu tara';

  @override
  String get releaseAll => 'Tümünü yayınla';

  @override
  String get keyActivate => 'Anahtarı etkinleştir';

  @override
  String get keyDeactivate => 'Anahtar devre dışı bırakılsın mı?';

  @override
  String get keyDeactivated => 'Anahtar devre dışı bırakıldı.';

  @override
  String get keyCreated => 'Anahtar oluşturuldu';

  @override
  String get keyDeactivateError => 'Anahtar devre dışı bırakılamadı.';

  @override
  String get keyCreateError => 'Anahtar oluşturulamadı.';

  @override
  String get keysLoadError => 'Anahtarlar yüklenemedi.';

  @override
  String validForDays(int days) {
    return '$days gün geçerli';
  }

  @override
  String get validityDuration => 'Geçerlilik süresi:';

  @override
  String get targetGroup => 'Hedef grup';

  @override
  String get endTimeSet => 'Bitiş saatini ayarla';
}
