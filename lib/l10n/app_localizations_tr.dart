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
  String get authSlideTrustSignals =>
      'TODO:tr: Kostenlos · Keine Kreditkarte · In 30 Sek. startklar';

  @override
  String get authSlideSocialProof =>
      'TODO:tr: 4,9 ★ · 2.500+ Patienten vertrauen der App';

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
  String get fieldAge => 'TODO:tr: Alter';

  @override
  String get fieldAgeHint => 'TODO:tr: z.B. 45';

  @override
  String get fieldAgeYears => 'TODO:tr: Jahre';

  @override
  String get validationAgeRequired => 'TODO:tr: Bitte gib dein Alter ein.';

  @override
  String get validationAgeInvalid =>
      'TODO:tr: Bitte gib ein gültiges Alter ein (0–120).';

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
  String get parentalConsentAge => 'TODO:tr: Du bist unter 16 Jahre alt.';

  @override
  String get parentalConsentText =>
      'Ebeveynlerimin veya yasal vasilerimin bu uygulamayı kullanmama ve verilerimin işlenmesine açıkça onay verdiğini onaylıyorum (GDPR Madde 8).';

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
  String appointmentForPatient(String name) {
    return 'Appointment for $name';
  }

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
      'TODO:tr: Noch keine Patienten in der Organisation.';

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
  String get scSeverityNone => 'Yok';

  @override
  String get scSeverityMild => 'Hafif';

  @override
  String get scSeverityModerate => 'Orta';

  @override
  String get scSeveritySevere => 'Şiddetli';

  @override
  String get scLevelGreen => 'Yeşil';

  @override
  String get scLevelYellow => 'Sarı';

  @override
  String get scLevelRed => 'Kırmızı';

  @override
  String get scLevelTitleYellow => 'Lütfen gözlemleyin';

  @override
  String get scRecommendGreen =>
      'Semptomlarınız normal. Düzenli olarak kayıt tutmaya devam edin ve iyileşme planınıza uyun.';

  @override
  String get scRecommendYellow =>
      'Bazı semptomlar hafifçe anormal. Sonraki 24 saat içinde gelişimi izleyin. Semptomlar kötüleşirse doktorunuzla iletişime geçin.';

  @override
  String get scRecommendRed =>
      'Semptomlarınız olası bir komplikasyona işaret ediyor. Hemen doktorunuzla iletişime geçin veya en yakın acil servise gidin.';

  @override
  String get scSymPain => 'Ağrı';

  @override
  String get scSymNausea => 'Bulantı';

  @override
  String get scSymBreathing => 'Nefes';

  @override
  String get scSymDizziness => 'Baş dönmesi';

  @override
  String get scSymWound => 'Yara Durumu';

  @override
  String get scSymPainSub => 'Ameliyat bölgesindeki ağrınız ne kadar şiddetli?';

  @override
  String get scSymNauseaSub => 'Bulantı veya kusma isteği hissediyor musunuz?';

  @override
  String get scSymBreathingSub =>
      'Nefes almada güçlük veya nefes darlığı var mı?';

  @override
  String get scSymDizzinessSub =>
      'Başınız dönüyor mu veya sersemliyor musunuz?';

  @override
  String get scSymWoundSub =>
      'Yarada anormallikler (kızarıklık, akıntı) var mı?';

  @override
  String get scTitle => 'Semptom Kontrolü';

  @override
  String get scSymptomsSection => 'Semptomları Değerlendir';

  @override
  String get scYourInputs => 'Bilgileriniz';

  @override
  String get scIntroBody =>
      'Her semptomu değerlendirin. Sonunda bir öneri ile değerlendirme alacaksınız.';

  @override
  String get scSetDailyReminder => 'Günlük Hatırlatıcı Kur';

  @override
  String get scActionsTitle => 'Önerilen Eylemler';

  @override
  String get scSaveResult => 'Sonucu Kaydet';

  @override
  String get scSaving => 'Kaydediliyor…';

  @override
  String get scSaved => 'Kaydedildi ✓';

  @override
  String scResultBadge(String label) {
    return 'Sonuç: $label';
  }

  @override
  String scReminderActive(String time) {
    return 'Hatırlatıcı: $time';
  }

  @override
  String scReminderSet(String time) {
    return 'Hatırlatıcı $time için ayarlandı';
  }

  @override
  String get nichtHinterlegt => 'Belirtilmedi';

  @override
  String get fieldName => 'Ad';

  @override
  String get fieldPhone => 'Telefon numarası';

  @override
  String get fieldWeight => 'Kilo';

  @override
  String get fieldSmoker => 'Sigara içen';

  @override
  String get fieldOpType => 'Ameliyat türü';

  @override
  String get fieldOpDate => 'Ameliyat tarihi';

  @override
  String get fieldOpModus => 'Ameliyat modu';

  @override
  String get fieldHospitalPhone => 'Hastane telefonu';

  @override
  String get fieldDoctorPhone => 'Doktor telefonu';

  @override
  String get eiBloodType => 'Kan grubu';

  @override
  String get eiAllergies => 'Alerjiler';

  @override
  String get eiInsurance => 'Sigorta';

  @override
  String get eiHospital => 'Hastane';

  @override
  String get eiConditions => 'Önceki hastalıklar';

  @override
  String get eiMedications => 'İlaçlar';

  @override
  String get eiOfflineBanner =>
      'Баğlantı yok – lütfen internet bağlantısı olduğunda acil bilgilerini yüklediğinden emin ol.';

  @override
  String get eiNoDataHint =>
      'Acil durum verisi kaydedilmedi.\nVerilerini profilüne gir.';

  @override
  String get eiOpenProfile => 'Profili aç';

  @override
  String get eiShareHeader => '🆘 ACİL DURUM BİLGİLERİ';

  @override
  String get eiShareEmergency => 'Acil: 112';

  @override
  String get eiSummaryNameHint => 'örn. Ahmet Yılmaz';

  @override
  String get eiSummaryPhoneHint => 'örn. +90 555 1234567';

  @override
  String get eiSummaryOpType => 'Ameliyat Türü';

  @override
  String get eiSummaryOpDateUnknown => 'Henüz bilinmiyor';

  @override
  String get eiSummaryTreatment => 'Tedavi';

  @override
  String get eiSummaryAmbulant => 'Ayakta tedavi';

  @override
  String eiShareBloodType(String value) {
    return 'Kan grubu: $value';
  }

  @override
  String eiShareAllergies(String value) {
    return 'Alerjiler: $value';
  }

  @override
  String eiShareContact(String name) {
    return 'Acil iletişim: $name';
  }

  @override
  String eiSharePhone(String value) {
    return 'Tel: $value';
  }

  @override
  String eiShareHospital(String name) {
    return 'Hastane: $name';
  }

  @override
  String eiShareHospitalPhone(String value) {
    return 'Hastane tel: $value';
  }

  @override
  String eiShareDoctor(String name) {
    return 'Doktor: $name';
  }

  @override
  String eiShareDoctorPhone(String value) {
    return 'Doktor tel: $value';
  }

  @override
  String eiShareInsurance(String value) {
    return 'Sigorta: $value';
  }

  @override
  String get notfallInfoTeilen => 'Acil Bilgiyi Paylaş';

  @override
  String get notruf112 => 'Acil 112';

  @override
  String get fehlerSpeichernErneut => 'Kaydetme hatası. Tekrar deneyin.';

  @override
  String get fehlerBeimSpeichern => 'Kaydetme hatası.';

  @override
  String get woWirstDuBehandelt => 'Nerede tedavi göreceksiniz?';

  @override
  String get fastGeschafft => 'Neredeyse bitti!';

  @override
  String get opClinic => 'Klinik';

  @override
  String get deinGesundheitsprofil => 'Sağlık Profiliniz';

  @override
  String get aktuelleMedikamente => 'Güncel İlaçlar';

  @override
  String get oPTypEingeben => 'Ameliyat türünü girin';

  @override
  String get mitKrankenhausaufenthalt => 'Hastane konaklaması ile';

  @override
  String get profilGespeichertKurz => 'Profil kaydedildi';

  @override
  String get koerperwerteUndGesundheit => 'Vücut Değerleri ve Sağlık';

  @override
  String get notfallkontaktUndNotfallInfo => 'Acil Kişi ve Bilgiler';

  @override
  String get bezeichnungEingeben => 'Etiket girin';

  @override
  String get pINAktivieren => 'PIN\'i etkinleştir';

  @override
  String get n4StelligerZugangsPIN => '4 haneli erişim PIN\'i';

  @override
  String get proEntdecken => 'Pro\'yu keşfet';

  @override
  String get aktuellesPasswort => 'Mevcut Şifre';

  @override
  String get passwortSpeichern => 'Şifreyi kaydet';

  @override
  String labelHinzufuegen(String label) {
    return '$label ekle';
  }

  @override
  String get vitalwerte => 'Yaşamsal Değerler';

  @override
  String get neueMessung => 'Yeni Ölçüm';

  @override
  String get systolisch => 'Sistolik';

  @override
  String get diastolisch => 'Diastolik';

  @override
  String get puls => 'Nabız';

  @override
  String get normalSystolisch => 'Normal: 90–140';

  @override
  String get normalDiastolisch => 'Normal: 60–90';

  @override
  String get normalPuls => 'Normal: 60–100';

  @override
  String get weitereWerteOptional => 'Ek Değerler (isteğe bağlı)';

  @override
  String get vitalsErinnerung => 'Hatırlatıcı';

  @override
  String get taeglicheMesserinnerung => 'Günlük Ölçüm Hatırlatıcısı';

  @override
  String get temperatur => 'Sıcaklık';

  @override
  String get normalTemperatur => 'Normal: 36.0–37.5 °C';

  @override
  String get normalO2Saettigung => 'Normal: 95–100 %';

  @override
  String get notizOptional => 'Not (isteğe bağlı)';

  @override
  String get mindZweiEintraege => 'Grafik için min. 2 kayıt';

  @override
  String get vitalsTipp =>
      'İpucu: Yaşamsal değerlerinizi her gün kaydedin – böylece eğilimleri erken fark edersiniz.';

  @override
  String get chartLast5 => '5 kayıt';

  @override
  String get chartDays7 => '7 gün';

  @override
  String get chartDays30 => '30 gün';

  @override
  String get blutdruck => 'Tansiyon';

  @override
  String get trageVitalwerteEin => 'Güncel değerlerinizi girin.';

  @override
  String normalbereichValue(String min, String max, String unit) {
    return 'Normal aralık: $min–$max $unit';
  }

  @override
  String neueMessungenSync(int count) {
    return '$count yeni ölçüm senkronize edildi';
  }

  @override
  String get neueMessungEintragen => 'Yeni ölçüm ekle';

  @override
  String get messungGespeichert => 'Ölçüm kaydedildi';

  @override
  String get schmerzfrei => 'Ağrısız';

  @override
  String get sehrStark => 'Çok şiddetli';

  @override
  String get schmerztagebuch => 'Ağrı Günlüğü';

  @override
  String get wieStarkSindDeineSchmerzen => 'Ağrınız ne kadar şiddetli?';

  @override
  String get woTutEsWeh => 'Nerede acıyor?';

  @override
  String get optionalTippeAufEineRegion => 'İsteğe bağlı – bir bölgeye dokunun';

  @override
  String get artDerSchmerzen => 'Ağrı türü';

  @override
  String get optionalWieFuehltEsSichAn => 'İsteğe bağlı – nasıl hissettiriyor?';

  @override
  String get avgSiebenTage => 'Ø 7 Gün';

  @override
  String get gesamt => 'Toplam';

  @override
  String get trendLabel => 'Eğilim';

  @override
  String get minMax => 'Min / Maks';

  @override
  String eintraegeInsgesamt(int count) {
    return 'Toplam $count giriş';
  }

  @override
  String get mehrMitPro => 'Pro ile daha fazla';

  @override
  String letzteEintraege(int count) {
    return 'Son $count giriş';
  }

  @override
  String letzteEintraegeGratis(int count) {
    return 'Son $count giriş (5 ücretsiz)';
  }

  @override
  String get letzteEintraegeHeader => 'Son girişler';

  @override
  String get alleAnzeigen => 'Hepsi →';

  @override
  String get gradesEben => 'Az önce';

  @override
  String vorMinuten(int min) {
    return '$min dk. önce';
  }

  @override
  String vorStunden(int h) {
    return '$h sa. önce';
  }

  @override
  String get gestern => 'Dün';

  @override
  String vorTagen(int days) {
    return '$days gün önce';
  }

  @override
  String get ortOptional => 'Konum (isteğe bağlı)';

  @override
  String get ausloeserOptional => 'Tetikleyici (isteğe bağlı)';

  @override
  String get painEntryEditorNotizOptional => 'Not (isteğe bağlı)';

  @override
  String get eintragBearbeiten => 'Girişi düzenle';

  @override
  String get schmerzlevel => 'Ağrı düzeyi';

  @override
  String get wann => 'Ne zaman?';

  @override
  String get datumLabel => 'Tarih';

  @override
  String get uhrzeitLabel => 'Saat';

  @override
  String get dauerLabel => 'Süre';

  @override
  String get dauerhaft => 'Sürekli';

  @override
  String minMinuten(int min) {
    return '$min dk.';
  }

  @override
  String stundenLabel(int h) {
    return '$h sa.';
  }

  @override
  String get medikationLabel => 'İlaç';

  @override
  String get eintragLoeschen => 'Girişi sil';

  @override
  String get kalender => 'Takvim';

  @override
  String get proLabel => 'Pro';

  @override
  String get filterAktiv => 'Filtre aktif';

  @override
  String get filtern => 'Filtrele';

  @override
  String get koerperregion => 'Vücut bölgesi';

  @override
  String get schmerzart => 'Ağrı türü';

  @override
  String get insights => 'İçgörüler';

  @override
  String haeufigstesGebiet(String region) {
    return 'En sık bölge: $region';
  }

  @override
  String get keineEintraegeFilter => 'Bu filtrelerle giriş bulunamadı';

  @override
  String get nochKeineEintraege => 'Henüz giriş yok';

  @override
  String get tippeAufNeuenEintrag =>
      'Başlamak için \"+ Yeni giriş\" üzerine dokunun';

  @override
  String avgWert(String val) {
    return 'Ø $val';
  }

  @override
  String get heute => 'Bugün';

  @override
  String get montag => 'Pazartesi';

  @override
  String get dienstag => 'Salı';

  @override
  String get mittwoch => 'Çarşamba';

  @override
  String get donnerstag => 'Perşembe';

  @override
  String get freitag => 'Cuma';

  @override
  String get samstag => 'Cumartesi';

  @override
  String get sonntag => 'Pazar';

  @override
  String get moKurz => 'Pt';

  @override
  String get diKurz => 'Sa';

  @override
  String get miKurz => 'Ça';

  @override
  String get doKurz => 'Pe';

  @override
  String get frKurz => 'Cu';

  @override
  String get saKurz => 'Ct';

  @override
  String get soKurz => 'Pa';

  @override
  String get keinSchmerz => 'Yok';

  @override
  String get kalenderMitProFreischalten => 'Pro ile takvimi aç';

  @override
  String get keineDetails => 'Ayrıntı yok';

  @override
  String get minLabel => 'Min';

  @override
  String get maxLabel => 'Maks';

  @override
  String get bellaAnalyse => 'Bella Analizi';

  @override
  String get emptyNoEntries => 'Henüz giriş yok';

  @override
  String get emptyWoundDocHint =>
      'İyileşme sürecinizi günlük fotoğraflarla belgeleyin.';

  @override
  String get ersteDokumentationStarten => 'İlk belgelemeyi başlat';

  @override
  String get neuesFotoAufnehmen => 'Yeni fotoğraf çek';

  @override
  String get woundHubKoerperstelle => 'Vücut bölgesi';

  @override
  String get neuErfassen => 'Yeni kayıt';

  @override
  String get verlaufVergleichen => 'İlerlemeyi karşılaştır';

  @override
  String get koerperstelle => 'Vücut bölgesi';

  @override
  String get keinFotoAnalyse => 'Fotoğraf yok.';

  @override
  String get n1FotoPflaster => '1. Fotoğraf: Pansuman';

  @override
  String get zeigtDenZustandDesVerbands => 'Pansumanın durumunu gösterir';

  @override
  String get n2FotoWunde => '2. Fotoğraf: Yara';

  @override
  String get nachAbnehmenDesPflasters => 'Pansumanı çıkardıktan sonra';

  @override
  String get linksA => 'Sol (A)';

  @override
  String get rechtsB => 'Sağ (B)';

  @override
  String schmerzScore(int score) {
    return 'Ağrı düzeyi: $score/10';
  }

  @override
  String get fotoLadeFehler => 'Fotoğraf yüklenemedi.';

  @override
  String get fotoHinzufuegen => 'Fotoğraf ekle';

  @override
  String get koerperstelleOptional => 'Vücut bölgesi (isteğe bağlı)';

  @override
  String get woundCompareTitle => 'Yara karşılaştırması';

  @override
  String get woundCompareSlider => 'İlerleme';

  @override
  String get woundCompareCompare => 'Karşılaştır';

  @override
  String get emptyNoPhotos => 'Henüz fotoğraf yok.';

  @override
  String get emptyWoundCompareHint =>
      'İlerlemeyi karşılaştırmak için yara belgelerine fotoğraf ekleyin.';

  @override
  String get wundDokumentationTitle => 'Yara dokümantasyonu';

  @override
  String get woundNoPhotoYet => 'Henüz fotoğraf yok';

  @override
  String get woundNoteHint =>
      'Yara nasıl görünüyor? Dikkat çeken bir şey var mı?';

  @override
  String get notizLabel => 'Not';

  @override
  String get woundHistoryTitle => 'Yara geçmişi';

  @override
  String get woundDiaryTitle => 'Yara günlüğü';

  @override
  String get woundDiarySubtitle =>
      'Yara iyileşmenizin fotoğraf ve notlarla kronolojik özeti.';

  @override
  String get woundPhotoGuideTitle => 'Fotoğraf rehberi';

  @override
  String get woundPhotoGuideSubtitle =>
      'İyi bir belgeleme için günlük 2 fotoğraf öneririz:';

  @override
  String get woundPhotoTip =>
      'İpucu: İyi aydınlatmaya dikkat edin ve aynı açıdan fotoğraf çekin.';

  @override
  String get woundNoNotiz => 'Not yok';

  @override
  String get woundDetailTitle => 'Yara detayı';

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String get woundDeleteConfirmMessage =>
      'Bu yara girişi kalıcı olarak silinecek.';

  @override
  String get woundMinEntriesForCompare =>
      'Karşılaştırma için en az 2 yara girişi gerekli.';

  @override
  String get woundDiscoveryTip =>
      'İpucu: Yaranızı düzenli olarak fotoğraflayın – böylece değişiklikleri bir bakışta fark edersiniz.';

  @override
  String woundEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giriş',
      one: '1 giriş',
    );
    return '$_temp0';
  }

  @override
  String get woundNoPhotoCaptured => 'Fotoğraf yok';

  @override
  String get woundTapForDetails => 'Ayrıntılar için dokunun';

  @override
  String get woundComparePick2 => 'Karşılaştırmak için iki fotoğraf seçin';

  @override
  String get woundModeSplit => 'Böl';

  @override
  String get woundModeOverlay => 'Katman';

  @override
  String woundComparePhotosSelected(int count) {
    return '$count / 2 fotoğraf seçildi';
  }

  @override
  String get woundCompareTapInstruction =>
      'Karşılaştırmak istediğiniz fotoğraflara aşağıdan dokunun.';

  @override
  String get before => 'Önce';

  @override
  String get after => 'Sonra';

  @override
  String get woundHygieneStep1 => 'Ellerinizi iyice yıkayın';

  @override
  String get woundHygieneStep2 => '🩹 Kuru pansuman değişimi';

  @override
  String get woundHygieneStep3 =>
      'Yara kontrolü: Kuru mu? Kırmızı değil mi? Taze kanama yok mu?';

  @override
  String get woundHygieneStep4 =>
      'Yaraya dokunmayın, müdahale etmeyin, krem sürmeyin';

  @override
  String get woundHygieneStep5 => 'Pedi dokunmadan pansuman değiştirin';

  @override
  String get woundHygieneStep6 => 'Ellerinizi tekrar yıkayın';

  @override
  String get woundHygieneTitle => '🧴 Yara hijyeni önerileri';

  @override
  String get woundHygieneWarning =>
      'Kızarıklık durumunda lütfen kliniğinizle iletişime geçin';

  @override
  String woundHygieneAckLabel(String date) {
    return '✅ $date tarihinde okundu';
  }

  @override
  String get kalorienKcal => 'Kalori (kkal)';

  @override
  String get nutritionProteinG => 'Protein (g)';

  @override
  String get wasserMl => 'Su (ml)';

  @override
  String get nameDerVorlage => 'Şablon adı';

  @override
  String get zBHaferbreiMitBeeren => 'örn. meyveli yulaf lapası';

  @override
  String get zbVollkornbrot => 'örn. tam tahıllı ekmek ile peynir';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get nutritionKohlenhG => 'Karbonhidrat (g)';

  @override
  String get nutritionFettG => 'Yağ (g)';

  @override
  String templateWirdEntfernt(String name) {
    return '«$name» şablonlarınızdan kaldırılacak.';
  }

  @override
  String get naehrwerteOptional => 'Besin değerleri (isteğe bağlı)';

  @override
  String get kohlenhG => 'Karbonhidrat (g)';

  @override
  String get fettG => 'Yağ (g)';

  @override
  String get getrunkenMl => 'İçilen su (ml)';

  @override
  String get vertraeglichkeit => 'Tolerabilite';

  @override
  String get mahlzeitSpeichern => 'Öğünü kaydet';

  @override
  String wasserMlDescription(int ml) {
    return 'Su ${ml}ml';
  }

  @override
  String wasserMlAdded(int ml) {
    return '+${ml}ml su eklendi';
  }

  @override
  String get vorlageLabel => 'Şablon';

  @override
  String get wasserTracking => 'Su Takibi';

  @override
  String get favoriten => 'Favoriler';

  @override
  String get tippeZumSchnellenWiederholen => 'Hızlı tekrar için dokun';

  @override
  String get mahlzeitLabel => 'Öğün';

  @override
  String get wasHastDuGegessen => 'Ne yediniz?';

  @override
  String get optionalWasserTeeEtc => 'İsteğe bağlı – su, çay vb.';

  @override
  String get optionalWieVertragen =>
      'İsteğe bağlı – öğünü nasıl tolere ettiniz?';

  @override
  String get symptomeNachDemEssen => 'Yemekten sonraki belirtiler';

  @override
  String get optionalTippeAuf => 'İsteğe bağlı – uygun belirtilere dokunun';

  @override
  String get naehrwerteTitle => 'Besin değerleri';

  @override
  String get optionalKalorienProtein =>
      'İsteğe bağlı – kalori, protein, karbonhidrat, yağ';

  @override
  String get vorlagenTitle => 'Şablonlar';

  @override
  String empfehlungFuerOp(String opType) {
    return '$opType ameliyatı tavsiyesi';
  }

  @override
  String empfehlungFuerOpTag(int day) {
    return ' · Gün $day';
  }

  @override
  String get empfehlungenTitle => 'Tavsiyeler';

  @override
  String heuteMahlzeitenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğün',
      one: '1 öğün',
    );
    return '$_temp0';
  }

  @override
  String get kcalLabel => 'kkal';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get wasserLabel => 'Su';

  @override
  String symptomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count belirti',
      one: '1 belirti',
    );
    return '$_temp0';
  }

  @override
  String keineFilterEintraege(String mealType) {
    return '$mealType girişi yok';
  }

  @override
  String get ersteMahlzeitTipp =>
      'İlk öğününüzü eklemek için + tuşuna dokunun.';

  @override
  String get beschreibungLabel => 'Açıklama';

  @override
  String get zbVollkornbrotQuark => 'örn. tam tahıllı ekmek ile lor peyniri';

  @override
  String get zbZahl => 'örn. 250';

  @override
  String get symptomeLabel => 'Belirtiler';

  @override
  String get notizZuSymptomenOptional =>
      'Belirtilerle ilgili not (isteğe bağlı)';

  @override
  String get eintrBearbeiten => 'Girişi düzenle';

  @override
  String get neueMahlzeit => 'Yeni öğün';

  @override
  String get eintrLoeschen => 'Girişi sil';

  @override
  String get mealTypeFruehstueck => 'Kahvaltı';

  @override
  String get mealTypeMittagessen => 'Öğle yemeği';

  @override
  String get mealTypeAbendessen => 'Akşam yemeği';

  @override
  String get mealTypeSnack => 'Atıştırmalık';

  @override
  String get symptomUebelkeit => 'Bulantı';

  @override
  String get symptomBlaehungen => 'Şişkinlik';

  @override
  String get symptomSchmerzen => 'Ağrı';

  @override
  String get symptomSodbrennen => 'Mide yanması';

  @override
  String get symptomDurchfall => 'İshal';

  @override
  String get symptomVerstopfung => 'Kabızlık';

  @override
  String get symptomMuedigkeit => 'Yorgunluk';

  @override
  String get symptomSonstige => 'Diğer';

  @override
  String get nochmal => 'Tekrar';

  @override
  String get ablaufNarkoseEingriffe => 'TODO:tr: Ablauf, Narkose, Eingriffe';

  @override
  String get abmelden => 'TODO:tr: Abmelden';

  @override
  String get adminAbmeldenBestaetigung =>
      'TODO:tr: Wirklich aus dem Admin-Bereich abmelden?';

  @override
  String get adminAktionenUndEreignisprotokoll =>
      'TODO:tr: Admin-Aktionen & Ereignisprotokoll';

  @override
  String get adminBenachrichtigungenUndEreignisse =>
      'TODO:tr: Admin-Benachrichtigungen & Ereignisse';

  @override
  String get aktivDieseWoche => 'TODO:tr: Aktiv diese Woche';

  @override
  String get aktiveProLizenzen => 'TODO:tr: Aktive Pro-Lizenzen';

  @override
  String get aktiveTage => 'TODO:tr: Aktive Tage';

  @override
  String get aktivHeute => 'TODO:tr: Aktiv heute';

  @override
  String get aktivitaetsHeatmap => 'TODO:tr: Aktivitäts-Heatmap';

  @override
  String get alertArztKontaktieren => 'TODO:tr: Arzt kontaktieren';

  @override
  String get alle => 'TODO:tr: Alle';

  @override
  String get alleAlsGelesenMarkieren => 'TODO:tr: Alle als gelesen markieren';

  @override
  String get alleFunktionenOhneEinschraenkung =>
      'TODO:tr: Alle Funktionen ohne Einschränkung';

  @override
  String get alleMarkieren => 'TODO:tr: Alle →';

  @override
  String get alsGelesen => 'TODO:tr: Als gelesen';

  @override
  String get alsPDFTeilen => 'TODO:tr: Als PDF teilen';

  @override
  String get alsTextKopieren => 'TODO:tr: Als Text kopieren';

  @override
  String get angehoerigeEinladenUndGemeinsamBegleiten =>
      'TODO:tr: Angehörige einladen & gemeinsam begleiten';

  @override
  String get angehoerigenEinladen => 'TODO:tr: Angehörigen einladen';

  @override
  String get anweisungNotiz => 'TODO:tr: Anweisung / Notiz';

  @override
  String get appointmentEditorRepeatUntil => 'TODO:tr: Wiederholen bis';

  @override
  String get apptAddFirstHint => 'İlk randevunuzu eklemek için + tuşuna basın.';

  @override
  String get apptCancelAppt => 'Randevuyu iptal et';

  @override
  String get apptConfirmationPending => 'Onay bekliyor';

  @override
  String get apptConfirmDeclineHint => 'Lütfen onaylayın veya reddedin.';

  @override
  String get apptCreatedByDoctor => 'Doktor tarafından oluşturuldu';

  @override
  String get apptDeleteTitle => 'Randevuyu sil';

  @override
  String get apptEditTitle => 'Randevuyu düzenle';

  @override
  String get apptHintCustomMinutes => 'Dakikalar';

  @override
  String get apptHintDoctor => 'örn. Dr. Yılmaz';

  @override
  String get apptHintLocation => 'örn. Şehir Hastanesi';

  @override
  String get apptHintLocationDetails => 'Ayrıntılar (koğuş, oda)';

  @override
  String get apptHintNote => 'İsteğe bağlı not…';

  @override
  String get apptHintTitle => 'örn. kontrol randevusu';

  @override
  String get apptLabelCustomMinutes => 'Dakikalar';

  @override
  String get apptLabelDate => 'Tarih';

  @override
  String get apptLabelDoctor => 'Doktor / Uygulayıcı';

  @override
  String get apptLabelEndTime => 'Bitiş saati';

  @override
  String get apptLabelFurtherDetails => 'Daha fazla ayrıntı';

  @override
  String get apptLabelFurtherReminders => 'Ek hatırlatıcılar';

  @override
  String get apptLabelLocation => 'Konum';

  @override
  String get apptLabelNote => 'Not';

  @override
  String get apptLabelPriority => 'Öncelik';

  @override
  String get apptLabelReminder => 'Hatırlatıcı';

  @override
  String get apptLabelRepeatUntil => 'Kadar';

  @override
  String get apptLabelStartTime => 'Başlangıç saati';

  @override
  String get apptLabelTime => 'Saat';

  @override
  String get apptLabelTitleRequired => 'Başlık *';

  @override
  String get apptLabelType => 'Tür';

  @override
  String get apptMarkAsDone => 'Tamamlandı olarak işaretle';

  @override
  String get apptMarkAsPlanned => 'Planlandı olarak işaretle';

  @override
  String get apptNewTitle => 'Yeni randevu';

  @override
  String get apptNoAppointments => 'Henüz randevu yok';

  @override
  String get apptNoResults => 'Sonuç yok';

  @override
  String get apptNoResultsHint =>
      'Farklı arama terimleri veya filtreler deneyin.';

  @override
  String get apptPriorityHigh => 'Yüksek';

  @override
  String get apptPriorityLow => 'Düşük';

  @override
  String get apptPriorityMedium => 'Orta';

  @override
  String get apptPriorityUrgent => 'Acil';

  @override
  String get apptReminderAtTime => 'Zamanında';

  @override
  String get apptReminderCustom => 'Özel';

  @override
  String get apptReminderDay1 => '1 gün önce';

  @override
  String get apptReminderDays2 => '2 gün önce';

  @override
  String get apptReminderHour1 => '1 saat önce';

  @override
  String get apptReminderHours2 => '2 saat önce';

  @override
  String get apptReminderMin15 => '15 dakika önce';

  @override
  String get apptReminderMin30 => '30 dakika önce';

  @override
  String get apptReminderNone => 'Yok';

  @override
  String get apptRepeatDaily => 'Günlük';

  @override
  String get apptRepeatMonthly => 'Aylık';

  @override
  String get apptRepeatNone => 'Yok';

  @override
  String get apptRepeatWeekly => 'Haftalık';

  @override
  String get apptSaving => 'Kaydediliyor…';

  @override
  String get apptStatusCanceled => 'İptal edildi';

  @override
  String get apptStatusCompleted => 'Tamamlandı';

  @override
  String get apptStatusConfirmed => 'Onaylandı';

  @override
  String get apptStatusDeclined => 'Reddedildi';

  @override
  String get apptStatusDone => 'Tamamlandı';

  @override
  String get apptStatusPending => 'Bekliyor';

  @override
  String get apptStatusPlanned => 'Planlandı';

  @override
  String get apptTitleRequired => 'Başlık gereklidir.';

  @override
  String get apptTodayNone => 'Bugün randevu yok';

  @override
  String get apptTodayTitle => 'Bugünkü randevular';

  @override
  String get apptTypeCall => 'Arama';

  @override
  String get apptTypeFollowUp => 'Takip';

  @override
  String get apptTypeImaging => 'Görüntüleme';

  @override
  String get apptTypeOther => 'Diğer';

  @override
  String get apptTypePhysio => 'Fizyoterapi';

  @override
  String get apptTypeSurgery => 'Ameliyat';

  @override
  String get apptViewCalendar => 'Takvim';

  @override
  String get apptViewList => 'Liste';

  @override
  String get apptYesterday => 'Dün';

  @override
  String get arztBehandler => 'TODO:tr: Arzt / Behandler';

  @override
  String get arztEntsperren => 'TODO:tr: Arzt entsperren?';

  @override
  String get arztSofortKontaktieren => 'TODO:tr: Arzt sofort kontaktieren';

  @override
  String get arztSperren => 'TODO:tr: Arzt sperren?';

  @override
  String get arztUndPatienteneinladungen =>
      'TODO:tr: Arzt- & Patienteneinladungen';

  @override
  String get aufbauUndRoutine => 'TODO:tr: Aufbau & Routine';

  @override
  String get aufnahmeStartFehler =>
      'TODO:tr: Aufnahme konnte nicht gestartet werden.';

  @override
  String get aufProUpgraden => 'TODO:tr: Auf Pro upgraden';

  @override
  String get auswertungAnzeigen => 'TODO:tr: Auswertung anzeigen';

  @override
  String get bedarfsmedikationOderSpontaneEinnahmen =>
      'TODO:tr: Bedarfsmedikation oder spontane Einnahmen.';

  @override
  String get begruendungEingeben => 'TODO:tr: Begründung eingeben …';

  @override
  String get beiAkuterVerschlechterung =>
      'TODO:tr: Bei akuter Verschlechterung';

  @override
  String get beiVerschlechterungAnrufen =>
      'TODO:tr: Bei Verschlechterung anrufen';

  @override
  String get bellaActionCancelled => 'İptal edildi';

  @override
  String get bellaActionCreated => 'Kayıt oluşturuldu ✓';

  @override
  String get bellaActionFailed => 'Oluşturma başarısız';

  @override
  String get bellaArztBriefing => 'TODO:tr: Bella Arzt-Briefing';

  @override
  String get bellaAskDirectly => 'Ya da doğrudan soru sorun:';

  @override
  String get bellaBriefingGenerating =>
      'Bella doktor brifinginizi oluşturuyor …';

  @override
  String get bellaBriefingIsProFeature => 'Doktor Brifingı Pro özelliğidir';

  @override
  String get bellaBriefingNotSignedIn => 'Lütfen giriş yapın.';

  @override
  String get bellaBriefingPersonalTitle => 'Kişisel doktor brifinginiz';

  @override
  String get bellaBriefingProDescription =>
      'Pro ile Bella, bir sonraki doktor randevunuz için kişisel bir özet oluşturur.';

  @override
  String get bellaChipAddTask => 'Görev ekle: yarayı kontrol et';

  @override
  String get bellaChipAppFunctions => 'Hangi uygulama özellikleri var?';

  @override
  String get bellaChipCallDoctor => 'Doktoru ne zaman aramalıyım?';

  @override
  String get bellaChipCreateAppointment => 'Yarın saat 10\'da randevu oluştur';

  @override
  String get bellaChipDoctorBroadcast =>
      'TODO:tr: Nachricht an alle Patienten senden';

  @override
  String get bellaChipDoctorCreateAppointment =>
      'TODO:tr: Termin für Patient erstellen';

  @override
  String get bellaChipDoctorCreateTask =>
      'TODO:tr: Aufgabe für Patient erstellen';

  @override
  String get bellaChipDoctorCreateRedFlag =>
      'TODO:tr: Warnung für Patient erstellen';

  @override
  String get bellaChipDoctorDashboard => 'Doktor paneli nasıl çalışır?';

  @override
  String get bellaChipDoctorInvitePatient =>
      'TODO:tr: Neuen Patienten einladen';

  @override
  String get bellaChipDoctorReport => 'Doktor raporu nasıl oluştururum?';

  @override
  String get bellaChipGeneralDashboard => 'Gösterge paneli nasıl çalışır?';

  @override
  String get bellaChipKneeTep => 'Diz protezi hakkında bilgi';

  @override
  String get bellaChipLinkPatient => 'Bir hastayı nasıl bağlarım?';

  @override
  String get bellaChipLogBloodPressure => 'Tansiyon 120/80 kaydet';

  @override
  String get bellaChipLogMedication => 'Az önce ibuprofen aldım';

  @override
  String get bellaChipLogPain => 'Ağrı kaydet: diz, seviye 4';

  @override
  String get bellaChipMedications => 'İlaçlarımı nasıl kaydederim?';

  @override
  String get bellaChipManageDoctors => 'TODO:tr: Wie verwalte ich meine Ärzte?';

  @override
  String get bellaChipMyTasks => 'Görevlerim nelerdir?';

  @override
  String get bellaChipOpDay => 'Ameliyat günü ne olur?';

  @override
  String get bellaChipOrgBillingInfo =>
      'TODO:tr: Wie ist unser Abonnement-Status?';

  @override
  String get bellaChipOrgBroadcast =>
      'TODO:tr: Nachricht an alle Patienten senden';

  @override
  String get bellaChipOrgDashboard =>
      'TODO:tr: Zeig mir unsere Organisations-Übersicht';

  @override
  String get bellaChipOrgInviteDoctor => 'TODO:tr: Einen neuen Arzt einladen';

  @override
  String get bellaChipOrgStats => 'TODO:tr: Zeig mir unsere Statistiken';

  @override
  String get bellaChipPrepareOp => 'Ameliyata nasıl hazırlanırım?';

  @override
  String get bellaChipStaffCreateAppointment =>
      'TODO:tr: Termin für Patient erstellen';

  @override
  String get bellaChipStaffCreateTask =>
      'TODO:tr: Aufgabe für Patient erstellen';

  @override
  String get bellaChipStaffLogVital =>
      'TODO:tr: Vitalwerte für Patient eintragen';

  @override
  String get bellaChipSymptomCheck => 'Semptom kontrolü başlat';

  @override
  String get bellaChipTimeline => 'Zaman çizelgesi nasıl çalışır?';

  @override
  String get bellaChipVerifyAccount => 'Doktor hesabımı nasıl doğrularım?';

  @override
  String get bellaChipViewPatientData => 'Hasta verilerini nasıl görüntülerim?';

  @override
  String get bellaChipViewPatientDataStaff =>
      'Hasta verilerini nasıl görüntülerim?';

  @override
  String get bellaConsentAccepted => 'Onay verildi';

  @override
  String get bellaConsentBody =>
      'Yapay zeka asistanı (Bella AI), sorularınızı yanıtlamak için harici hizmetler kullanmaktadır:\n\n• Sohbet mesajlarınız OpenAI\'a (ABD) iletilmektedir.\n• Pro kullanıcılar için: Yerel sağlık verileri (ağrı günlüğü, vital değerler, ilaçlar, beslenme, uyarılar, ameliyat evresi) daha iyi yanıtlar sağlamak amacıyla bağlam olarak gönderilmektedir.\n• Yara fotoğrafı analizleri OpenAI (ABD) üzerinden işlenmekte ve analizden sonra silinmektedir.\n\nHarici hizmetlerde hiçbir veri kalıcı olarak saklanmaz. Onayınızı istediğiniz zaman Ayarlar\'dan geri alabilirsiniz.\n\nHukuki dayanak: GDPR Madde 6(1)(a) ve Madde 9(2)(a).';

  @override
  String get bellaConsentDeclined => 'Onay reddedildi';

  @override
  String get bellaConsentTitle => 'Gizlilik Bildirimi';

  @override
  String get bellaConsentYes => 'Evet, kabul ediyorum';

  @override
  String get bellaDailyAnalysis => 'Bella Günlük Analizi';

  @override
  String get bellaDefaultWoundPrompt => 'Lütfen bu yara fotoğrafını analiz et.';

  @override
  String get bellaDescriptionDoctor =>
      'Doktor paneli, hasta yönetimi ve klinik sorularda size yardımcı oluyorum.';

  @override
  String get bellaDescriptionOrganisation =>
      'TODO:tr: Ich helfe dir bei der Verwaltung deiner Organisation, Ärzten, Mitarbeitern und Statistiken.';

  @override
  String get bellaDescriptionPatient =>
      'Ameliyatınız, ameliyat sonrası bakım ve uygulama hakkındaki sorularınızı yanıtlıyorum.';

  @override
  String get bellaDescriptionStaff =>
      'Personel paneli ve hasta bakımında size yardımcı oluyorum.';

  @override
  String get bellaDisclaimer =>
      'Tıbbi tavsiye değildir – şikayetiniz varsa doktora başvurun.';

  @override
  String get bellaFeatureAftercare => 'Ameliyat Sonrası Bakım';

  @override
  String get bellaFeatureAppHelp => 'Uygulama Yardımı';

  @override
  String get bellaFeatureBilling => 'TODO:tr: Abrechnung';

  @override
  String get bellaFeatureDashboard => 'Gösterge Paneli';

  @override
  String get bellaFeatureDoctors => 'TODO:tr: Ärzte';

  @override
  String get bellaFeatureMedicalKnowledge => 'Ameliyat Bilgisi';

  @override
  String get bellaFeatureOrgStats => 'TODO:tr: Statistiken';

  @override
  String get bellaFeaturePatients => 'Hastalar';

  @override
  String get bellaFeatureTasks => 'Görevler';

  @override
  String get bellaFeatureTeam => 'TODO:tr: Team';

  @override
  String get bellaFeatureWarnings => 'Uyarı İşaretleri';

  @override
  String get bellaGreeting => 'Merhaba! Ben Bella AI 🐰';

  @override
  String get bellaNoAnswerReceived =>
      'Yanıt alınamadı. Lütfen tekrar deneyin. 🐰';

  @override
  String get bellaProactivePainTrend =>
      'Ağrı düzeyiniz artıyor – bunu konuşmak ister misiniz?';

  @override
  String get bellaProUpgrade => 'Şimdi Pro\'ya geç';

  @override
  String get bellaSays => 'Bella diyor ki:';

  @override
  String get bellaSubtitleDoctor => 'Klinik asistanınız 🐰';

  @override
  String get bellaSubtitleOrganisation =>
      'TODO:tr: Dein Organisations-Assistent 🐰';

  @override
  String get bellaSubtitlePatient => 'Ameliyat rehberiniz 🐰';

  @override
  String get bellaSubtitleStaff => 'Klinik asistanınız 🐰';

  @override
  String get bellaWoundAnalysisTitle => 'Yara Analizi';

  @override
  String get bellaWoundDisclaimer =>
      'Tıbbi tanının yerini tutmaz. Şüphe durumunda tıbbi ekibinizle iletişime geçin.';

  @override
  String get bellaWoundObservations => 'Gözlemler';

  @override
  String get bellaWoundProgressComparison => 'İlerleme Karşılaştırması';

  @override
  String get beobachtenSieDieSymptomeGenau =>
      'TODO:tr: Beobachten Sie die Symptome genau';

  @override
  String get beobachtungHinzufuegen => 'TODO:tr: Beobachtung hinzufügen';

  @override
  String get beschreibeAnliegen =>
      'TODO:tr: Beschreibe dein Anliegen so genau wie möglich…';

  @override
  String get beschreibenSieIhreSymptome =>
      'TODO:tr: Beschreiben Sie Ihre Symptome';

  @override
  String get besterPreisProMonat => 'TODO:tr: Bester Preis pro Monat';

  @override
  String get broadcastSenden => 'TODO:tr: Broadcast senden';

  @override
  String get calendarAddedSuccess => 'Randevu takvime eklendi';

  @override
  String get calendarAddToCalendarBody =>
      'Bu randevuyu cihaz takviminize eklemek veya .ics dosyası olarak paylaşmak ister misiniz?';

  @override
  String get calendarExportFailed => 'Takvim dışa aktarımı başarısız';

  @override
  String get calendarMonth => 'Ay';

  @override
  String get calendarNoEvents => 'Bu günde randevu yok';

  @override
  String get calendarTitle => 'Takvim';

  @override
  String get calendarWeek => 'Hafta';

  @override
  String get chronologischDokumentierteEinnahmen =>
      'TODO:tr: Chronologisch dokumentierte Einnahmen.';

  @override
  String get codeZumManuellenEingeben => 'TODO:tr: Code zum manuellen Eingeben';

  @override
  String get csvExportieren => 'TODO:tr: CSV exportieren';

  @override
  String get dashboardPushSenden => 'TODO:tr: Push senden';

  @override
  String get dauer => 'TODO:tr: Ø Dauer';

  @override
  String get deepLink => 'TODO:tr: Deep Link';

  @override
  String get discoverSubtitle => 'TODO:tr: Alle Funktionen auf einen Blick';

  @override
  String get discoverTitle => 'TODO:tr: Entdecken';

  @override
  String get doctorProfileMeinProfil => 'TODO:tr: Mein Profil';

  @override
  String get doctorReportSchmerztagebuchLetzte7Tage =>
      'TODO:tr: Schmerztagebuch letzte 7 Tage';

  @override
  String get doctorReportWunddokuLetzte3 => 'TODO:tr: Wunddoku letzte 3';

  @override
  String get doctorStatsCardSchmerzlevel => 'TODO:tr: Ø Schmerzlevel';

  @override
  String get dokumenteLetzte3 => 'TODO:tr: Dokumente letzte 3';

  @override
  String get dokumenteOeffnenTeilen => 'TODO:tr: Öffnen / Teilen';

  @override
  String get dokumentiereWundenUnterWunddoku =>
      'TODO:tr: Dokumentiere Wunden unter Wunddoku';

  @override
  String get einladungscode => 'TODO:tr: Einladungscode';

  @override
  String get einladungTeilen => 'TODO:tr: Einladung teilen';

  @override
  String get erfasseMedikamenteImMedikamentenplan =>
      'TODO:tr: Erfasse Medikamente im Medikamentenplan';

  @override
  String get erfasseSchmerzwerteImSchmerztagebuch =>
      'TODO:tr: Erfasse Schmerzwerte im Schmerztagebuch';

  @override
  String get erfasseVitalwerteUnterVitals =>
      'TODO:tr: Erfasse Vitalwerte unter Vitaldaten';

  @override
  String get erinnerungErstellen => 'TODO:tr: Erinnerung erstellen';

  @override
  String get erneutPruefen => 'TODO:tr: Erneut prüfen';

  @override
  String get errorAlreadyExists => 'TODO:tr: Bereits vorhanden.';

  @override
  String get errorCancelled => 'TODO:tr: Vorgang abgebrochen.';

  @override
  String get errorDeadlineExceeded =>
      'TODO:tr: Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String get errorEmailInUse =>
      'TODO:tr: Diese E-Mail-Adresse wird bereits verwendet.';

  @override
  String get errorFailedPrecondition =>
      'TODO:tr: Aktion kann nicht durchgeführt werden.';

  @override
  String get errorInvalidArgument => 'TODO:tr: Ungültige Eingabe.';

  @override
  String get errorInvalidEmail => 'TODO:tr: Ungültige E-Mail-Adresse.';

  @override
  String get errorNoInternet =>
      'TODO:tr: Keine Internetverbindung. Bitte Netzwerk prüfen.';

  @override
  String get errorNotFound => 'TODO:tr: Nicht gefunden. Bitte Eingabe prüfen.';

  @override
  String get errorNotFoundShort => 'TODO:tr: Nicht gefunden.';

  @override
  String get errorOperationNotAllowed =>
      'TODO:tr: Diese Aktion ist nicht erlaubt.';

  @override
  String get errorPermissionDenied =>
      'TODO:tr: Keine Berechtigung für diese Aktion.';

  @override
  String get errorPleaseSignIn => 'TODO:tr: Bitte anmelden.';

  @override
  String get errorRequiresRecentLogin =>
      'TODO:tr: Bitte erneut anmelden, um fortzufahren.';

  @override
  String get errorResourceExhausted =>
      'TODO:tr: Zu viele Anfragen. Bitte einen Moment warten.';

  @override
  String get errorServiceUnavailable =>
      'TODO:tr: Der Dienst ist vorübergehend nicht verfügbar. Bitte später erneut versuchen.';

  @override
  String get errorServiceUnavailableShort =>
      'TODO:tr: Der Dienst ist vorübergehend nicht verfügbar.';

  @override
  String get errorTooManyRequests =>
      'TODO:tr: Zu viele Versuche. Bitte später erneut versuchen.';

  @override
  String get errorUserDisabled => 'TODO:tr: Dieses Konto wurde deaktiviert.';

  @override
  String get errorUserNotFound =>
      'TODO:tr: Kein Konto mit dieser E-Mail-Adresse gefunden.';

  @override
  String get errorWeakPassword => 'TODO:tr: Das Passwort ist zu schwach.';

  @override
  String get errorWrongPassword => 'TODO:tr: Falsches Passwort.';

  @override
  String get ersteListeErstellen => 'TODO:tr: Erste Liste erstellen';

  @override
  String get erstelltAm => 'TODO:tr: Erstellt am';

  @override
  String get ersteNotizErstellen => 'TODO:tr: Erste Notiz erstellen';

  @override
  String get erstesItemHinzufuegen => 'TODO:tr: Erstes Item hinzufügen';

  @override
  String get ersteVorlageErstellen => 'TODO:tr: Erste Vorlage erstellen';

  @override
  String get esIstEinFehlerAufgetretenBitteVersucheEsErneut =>
      'TODO:tr: Es ist ein Fehler aufgetreten. Bitte versuche es erneut.';

  @override
  String get exportFehlgeschlagen => 'TODO:tr: Export fehlgeschlagen.';

  @override
  String get familyMemberHubZBA1B2C3D4E5F6 => 'TODO:tr: z.B. A1B2C3D4E5F6';

  @override
  String get familyPatientsMeinePatienten => 'TODO:tr: Meine Patienten';

  @override
  String get familyPatientsZBA1B2C3D4E5F6 => 'TODO:tr: z.B. A1B2C3D4E5F6';

  @override
  String get familyProfileZBA1B2C3D4E5F6 => 'TODO:tr: z.B. A1B2C3D4E5F6';

  @override
  String get fehlerBeimErstellen => 'TODO:tr: Fehler beim Erstellen.';

  @override
  String get fehlerBeimLaden => 'TODO:tr: Fehler beim Laden.';

  @override
  String get firebaseUIDDesArztes => 'TODO:tr: Firebase UID des Arztes';

  @override
  String get footerLoveMessage =>
      'TODO:tr: Mit Liebe für deine Genesung entwickelt';

  @override
  String get fotosDurchsuchen =>
      'TODO:tr: Fotos suchen (Datum, Notiz, Kategorie)…';

  @override
  String get frageAnBella => 'TODO:tr: Frage an Bella …';

  @override
  String get frageBearbeiten => 'TODO:tr: Frage bearbeiten';

  @override
  String get frageStellen => 'TODO:tr: Frage stellen …';

  @override
  String get freischalten => 'TODO:tr: Freischalten';

  @override
  String get funktionenErklaert => 'TODO:tr: Funktionen erklärt';

  @override
  String get grundDerSperrung => 'TODO:tr: Grund der Sperrung…';

  @override
  String get grundEingeben => 'TODO:tr: Grund eingeben…';

  @override
  String get grundOptional => 'TODO:tr: Grund (optional)';

  @override
  String get helpHilfeUndSupport => 'TODO:tr: Hilfe & Support';

  @override
  String get heuteDokumentiert => 'TODO:tr: Heute dokumentiert';

  @override
  String get hilfeUndSupport => 'TODO:tr: Hilfe & Support';

  @override
  String get hinterlegeDeineOPDetailsImProfil =>
      'TODO:tr: Hinterlege deine OP-Details im Profil';

  @override
  String get hinweistextOptional => 'TODO:tr: Hinweistext (optional)';

  @override
  String get homeSummaryCardFaellig => 'TODO:tr: fällig';

  @override
  String get ihreAntwortEingeben => 'TODO:tr: Antwort eingeben…';

  @override
  String get inaktiv3Tage => 'TODO:tr: Inaktiv >3 Tage';

  @override
  String get itemBearbeiten => 'TODO:tr: Item bearbeiten';

  @override
  String get jaehrlich => 'TODO:tr: Jährlich';

  @override
  String get jederzeitNkuendbar => 'TODO:tr: Jederzeit\\nkündbar';

  @override
  String get keineAufgabenImPlan => 'TODO:tr: Noch keine Aufgaben im Plan.';

  @override
  String get keineEmailApp => 'TODO:tr: Keine E-Mail-App gefunden';

  @override
  String get keineOffenenEinladungen => 'TODO:tr: Keine offenen Einladungen.';

  @override
  String get keinePatienenGefunden => 'TODO:tr: Keine Patienten gefunden.';

  @override
  String get keinUebernachtenNurDasNoetigste =>
      'TODO:tr: Kein Übernachten – nur das Nötigste';

  @override
  String get keyIdOderUidSuchen => 'TODO:tr: Key-ID oder Einlöser-UID suchen…';

  @override
  String get kontaktierenSieIhrenArzt => 'TODO:tr: Kontaktieren Sie Ihren Arzt';

  @override
  String get kVNummerOptional => 'TODO:tr: KV-Nummer (optional)';

  @override
  String get letzteDokumente => 'TODO:tr: Letzte Dokumente';

  @override
  String get letzteEinnahmen => 'TODO:tr: Letzte Einnahmen';

  @override
  String get letzteVitalwerte => 'TODO:tr: Letzte Vitalwerte';

  @override
  String get linkKopieren => 'TODO:tr: Link kopieren';

  @override
  String get losGehts => 'TODO:tr: Los geht\'s!';

  @override
  String get medikament => 'TODO:tr: Medikament *';

  @override
  String get meilensteineUndZiele => 'TODO:tr: Meilensteine & Ziele';

  @override
  String get meinProfil => 'TODO:tr: Mein Profil';

  @override
  String get memosDurchsuchen => 'TODO:tr: Memos durchsuchen…';

  @override
  String get mitArztVerbinden => 'TODO:tr: Mit Arzt verbinden';

  @override
  String get mitMedikation => 'TODO:tr: Mit Medikation';

  @override
  String get mitUebernachtungVollstaendigeListe =>
      'TODO:tr: Mit Übernachtung – vollständige Liste';

  @override
  String get monatlichKuendbar => 'TODO:tr: monatlich kündbar';

  @override
  String get monthApril => 'Nisan';

  @override
  String get monthAugust => 'Ağustos';

  @override
  String get monthDecember => 'Aralık';

  @override
  String get monthFebruary => 'Şubat';

  @override
  String get monthJanuary => 'Ocak';

  @override
  String get monthJuly => 'Temmuz';

  @override
  String get monthJune => 'Haziran';

  @override
  String get monthMarch => 'Mart';

  @override
  String get monthMay => 'Mayıs';

  @override
  String get monthNovember => 'Kasım';

  @override
  String get monthOctober => 'Ekim';

  @override
  String get monthSeptember => 'Eylül';

  @override
  String get n7TageTreue => 'TODO:tr: 7-Tage Treue';

  @override
  String get nachrichtSchreiben => 'TODO:tr: Nachricht schreiben...';

  @override
  String get nachRolleFiltern => 'TODO:tr: Nach Rolle filtern';

  @override
  String get naechsteTermine => 'TODO:tr: Nächste Termine';

  @override
  String get neuerKey => 'TODO:tr: Neuer Key';

  @override
  String get neuerName => 'TODO:tr: Neuer Name';

  @override
  String get neuesPacklistenItem => 'TODO:tr: Neues Packlisten-Item';

  @override
  String get neuesPasswort => 'TODO:tr: Neues Passwort';

  @override
  String get nochKeineAngehoerigenVerbunden =>
      'TODO:tr: Noch keine Angehörigen verbunden.';

  @override
  String get nochKeineBeobachtungen => 'TODO:tr: Noch keine Beobachtungen.';

  @override
  String get nochKeineDokumentation => 'TODO:tr: Noch keine Dokumentation';

  @override
  String get notaufnahmeAufsuchen => 'TODO:tr: Notaufnahme aufsuchen';

  @override
  String get notificationCenterNotizOptional => 'TODO:tr: Notiz (optional)';

  @override
  String get notruf112Anrufen => 'TODO:tr: Notruf 112 anrufen';

  @override
  String get nurInDebugBuilds => 'TODO:tr: Nur in Debug-Builds verfügbar.';

  @override
  String get nurVomArztVerwaltbar => 'TODO:tr: Nur vom Arzt verwaltbar';

  @override
  String get nutzerGesamt => 'TODO:tr: Nutzer gesamt';

  @override
  String get oeffnenTeilen => 'TODO:tr: Öffnen / Teilen';

  @override
  String get offeneFragen => 'TODO:tr: Offene Fragen';

  @override
  String get offeneRedFlags => 'TODO:tr: Offene Warnsignale';

  @override
  String get ohneMedikation => 'TODO:tr: Ohne Medikation';

  @override
  String get opActions => 'TODO:tr: Aktionen';

  @override
  String get oPDatum => 'TODO:tr: OP Datum';

  @override
  String opDatumKurz(int day, int month, int year) {
    return 'TODO:tr: OP: $day.$month.$year';
  }

  @override
  String get opDetails => 'TODO:tr: OP-Details';

  @override
  String get opDocumentsLabel => 'TODO:tr: Dokumente';

  @override
  String get opManageCaregivers => 'TODO:tr: Begleiter\nverwalten';

  @override
  String get opName => 'TODO:tr: OP-Name';

  @override
  String get opSymptomsLabel => 'TODO:tr: Symptome';

  @override
  String get opTimeline => 'TODO:tr: Timeline';

  @override
  String get opType => 'TODO:tr: OP-Typ';

  @override
  String get oPUndTimeline => 'TODO:tr: OP & Timeline';

  @override
  String get packingItemEditorSheetNotizOptional => 'TODO:tr: Notiz (optional)';

  @override
  String get patientAuswaehlen => 'TODO:tr: Patient auswählen';

  @override
  String get patientAuswaehlenUmDetailsAnzuzeigen =>
      'TODO:tr: Patient auswählen, um Details anzuzeigen';

  @override
  String get patientBasisdaten => 'TODO:tr: Patient Basisdaten';

  @override
  String get patientSuchen => 'TODO:tr: Patient suchen…';

  @override
  String get patienten => 'TODO:tr: Patienten';

  @override
  String patientenAnzahl(int count) {
    return 'TODO:tr: Patienten ($count)';
  }

  @override
  String get patientenBegleiten => 'TODO:tr: Patienten begleiten';

  @override
  String get perEMail => 'TODO:tr: Per E-Mail';

  @override
  String get placeholderLoading => 'Yükleniyor…';

  @override
  String get praxisnameOptional => 'TODO:tr: Praxisname (optional)';

  @override
  String get prioritaet => 'TODO:tr: Priorität';

  @override
  String get profilGespeichert => 'TODO:tr: Profil gespeichert.';

  @override
  String get proKeyErstellen => 'TODO:tr: Pro-Key erstellen';

  @override
  String get proSatz => 'TODO:tr: pro Satz';

  @override
  String get proStatus => 'TODO:tr: Pro Status';

  @override
  String get pushBenachrichtigungenVersenden =>
      'TODO:tr: Push-Benachrichtigungen versenden';

  @override
  String get pushPushSenden => 'TODO:tr: Push senden?';

  @override
  String get pushSenden => 'TODO:tr: Push';

  @override
  String get recoveryFeed => 'TODO:tr: Genesungs-Feed';

  @override
  String get redU2011FlagSystem => 'TODO:tr: Red\\u2011Flag System';

  @override
  String get reportSchmerz => 'TODO:tr: Schmerz-Ø';

  @override
  String get reportTagePostOP => 'TODO:tr: Tage post-OP';

  @override
  String get rfActiveWarnings => 'Aktif Uyarılar';

  @override
  String get rfCheckStart => 'Kontrolü Başlat';

  @override
  String get rfEmergencyFollowSteps => 'Bu adımları sırayla takip edin.';

  @override
  String get rfEmergencyInstructions => 'Acil Talimatlar';

  @override
  String get rfEmergencyStep1Desc => 'Oturun veya uzanın. Sakin nefes alın.';

  @override
  String get rfEmergencyStep1Title => 'Sakin olun';

  @override
  String get rfEmergencyStep2Desc =>
      'Mevcut şikayetlerinizi ve şiddetini not edin.';

  @override
  String get rfEmergencyStep2Title => 'Semptomları kontrol edin';

  @override
  String get rfEmergencyStep3Desc =>
      'Doktorunuzu veya kliniği arayın ve semptomları anlatın.';

  @override
  String get rfEmergencyStep3Title => 'Doktoru arayın';

  @override
  String get rfEmergencyStep4Desc =>
      'Nefes darlığı, bilinç kaybı veya ciddi kanama durumunda hemen 112\'yi arayın.';

  @override
  String get rfEmergencySubtitle =>
      'Nefes darlığı, bilinç kaybı veya ciddi kanama için acil önlemler.';

  @override
  String get rfEscalate => 'Eskalatif';

  @override
  String get rfNoActiveWarnings => 'Aktif uyarı yok. Böyle devam edin!';

  @override
  String get rfNoFlags => 'Kırmızı Bayrak Yok';

  @override
  String get rfProAutoDetect =>
      'Pro ile sistem, ağrı, vital bulgular ve daha fazlasından kritik değerleri otomatik olarak algılar.';

  @override
  String get rfProFeatureSubtitle =>
      'Şikayetleri manuel olarak girin veya Pro\'ya geçin.';

  @override
  String get rfProFeatureTitle =>
      'Otomatik kırmızı bayrak tespiti Pro özelliğidir.';

  @override
  String get rfSeverityDescGreen =>
      'Değerleriniz normal aralıkta. Böyle devam edin!';

  @override
  String get rfSeverityDescOrange =>
      'Birkaç değer anormal. Yakında doktorunuzla iletişime geçin.';

  @override
  String get rfSeverityDescRed =>
      'Kritik değerler tespit edildi. Acil tıbbi yardım önerilir.';

  @override
  String get rfSeverityDescYellow =>
      'Bazı değerler normalin biraz dışında. Lütfen izleyin.';

  @override
  String get rfSeverityOrange => 'Turuncu';

  @override
  String get rfSeverityRed => 'Kırmızı';

  @override
  String get rfSeverityTitleGreen => 'Her Şey Yolunda';

  @override
  String get rfSeverityTitleOrange => 'Yüksek Risk';

  @override
  String get rfSeverityTitleRed => 'Hemen Hareket Et';

  @override
  String get rfSeverityTitleYellow => 'Hafif Anormallik';

  @override
  String get rfSeverityYellow => 'Sarı';

  @override
  String get rfSourceManual => 'Manuel';

  @override
  String get rfSourceObservation => 'Gözlem';

  @override
  String get rfSourcePain => 'Ağrı';

  @override
  String get rfSourceSymptomCheck => 'Belirti Kontrolü';

  @override
  String get rfSourceTimeline => 'Zaman Çizelgesi Görevi';

  @override
  String get rfSourceVitals => 'Yaşamsal Bulgular';

  @override
  String get rfSourceWarningCheck => 'Uyarı Kontrolü';

  @override
  String get rfSourceWound => 'Yara Verileri';

  @override
  String get rfStatusAcknowledged => 'Görüldü';

  @override
  String get rfStatusEscalated => 'Eskalatif';

  @override
  String get rfStatusMonitoring => 'İzleme';

  @override
  String get rfStatusOpen => 'Açık';

  @override
  String get rfStatusResolved => 'Çözüldü';

  @override
  String get rfWarningCheckSubtitle =>
      'En önemli semptomların hızlı kontrolü – yalnızca 30 saniye sürer.';

  @override
  String get roleDebug => 'TODO:tr: Role Debug';

  @override
  String get rolleAuswaehlen => 'TODO:tr: Rolle auswählen';

  @override
  String get scannbarerCodeZumBeitreten =>
      'TODO:tr: Scannbarer Code zum Beitreten';

  @override
  String get schalteLevelXPTrackingUndMehrFrei =>
      'TODO:tr: Schalte Level, XP-Tracking und mehr frei';

  @override
  String get schlaf => 'TODO:tr: Ø Schlaf';

  @override
  String get schlafOptional => 'TODO:tr: Schlaf (optional)';

  @override
  String get schmerz => 'TODO:tr: Ø Schmerz';

  @override
  String get schmerztagebuchLetzte7Tage =>
      'TODO:tr: Schmerztagebuch letzte 7 Tage';

  @override
  String get schmerztrend7Tage => 'TODO:tr: Schmerztrend (7 Tage)';

  @override
  String get searchHint => 'TODO:tr: Suchen…';

  @override
  String get sectionAccompany => 'TODO:tr: Begleitung';

  @override
  String get sectionAdsAdmin => 'TODO:tr: Ads Admin';

  @override
  String get sectionAnalysis => 'TODO:tr: Analyse';

  @override
  String get sectionAnalytics => 'TODO:tr: Analytik';

  @override
  String get sectionConnectDoctor => 'TODO:tr: Arzt verbinden';

  @override
  String get sectionDebugTools => 'TODO:tr: Debug Tools';

  @override
  String get sectionDoctorQuestions => 'TODO:tr: Arztfragen';

  @override
  String get sectionDoctorReport => 'TODO:tr: Arztbericht';

  @override
  String get sectionDocumentation => 'TODO:tr: Dokumentation';

  @override
  String get sectionDocuments => 'TODO:tr: Dokumente';

  @override
  String get sectionEmergencyInfo => 'TODO:tr: Notfallinformationen';

  @override
  String get sectionFirebaseTest => 'TODO:tr: Firebase Test';

  @override
  String get sectionHealth => 'TODO:tr: Gesundheit';

  @override
  String get sectionHealthReport => 'TODO:tr: Gesundheitsbericht';

  @override
  String get sectionHelp => 'TODO:tr: Hilfe';

  @override
  String get sectionLanguage => 'TODO:tr: Sprache';

  @override
  String get sectionMedication => 'TODO:tr: Medikamente';

  @override
  String get sectionMood => 'TODO:tr: Stimmung';

  @override
  String get sectionNotifications => 'TODO:tr: Benachrichtigungen';

  @override
  String get sectionNutrition => 'TODO:tr: Ernährung';

  @override
  String get sectionOpInfo => 'TODO:tr: OP-Informationen';

  @override
  String get sectionOpPlanning => 'TODO:tr: OP & Planung';

  @override
  String get sectionPackingList => 'TODO:tr: Packliste';

  @override
  String get sectionPain => 'TODO:tr: Schmerzen';

  @override
  String get sectionPeople => 'TODO:tr: Personen';

  @override
  String get sectionPhotos => 'TODO:tr: Fotos';

  @override
  String get sectionProfile => 'TODO:tr: Profil';

  @override
  String get sectionProgress => 'TODO:tr: Fortschritt';

  @override
  String get sectionRecentlyUsed => 'TODO:tr: Zuletzt genutzt';

  @override
  String get sectionRedFlags => 'TODO:tr: Warnsignale';

  @override
  String get sectionRehabilitation => 'TODO:tr: Rehabilitation';

  @override
  String get sectionRoleDebug => 'TODO:tr: Role Debug';

  @override
  String get sectionSleep => 'TODO:tr: Schlaf';

  @override
  String get sectionSymptomCheck => 'TODO:tr: Symptom-Check';

  @override
  String get sectionVitals => 'TODO:tr: Vitaldaten';

  @override
  String get sectionVoiceNotes => 'TODO:tr: Sprachnotizen';

  @override
  String get sichereNZahlung => 'TODO:tr: Sichere\\nZahlung';

  @override
  String get sofortDokumentieren => 'TODO:tr: Sofort dokumentieren';

  @override
  String get sonstige => 'TODO:tr: Sonstiges';

  @override
  String get spracheUndMemos => 'TODO:tr: Sprache & Memos';

  @override
  String get statistikenAktualisieren => 'TODO:tr: Statistiken aktualisieren';

  @override
  String get statsNichtAktualisiert =>
      'TODO:tr: Statistiken konnten nicht aktualisiert werden.';

  @override
  String get statusFiltern => 'TODO:tr: Filter status';

  @override
  String get stimmung => 'TODO:tr: Ø Stimmung';

  @override
  String get sucheInAktionenDetailsUID =>
      'TODO:tr: Suche in Aktionen, Details, UID…';

  @override
  String get sucheNachBetreffEMail => 'TODO:tr: Suche nach Betreff, E-Mail…';

  @override
  String get sucheNachTitelOderOrt => 'TODO:tr: Nach Titel oder Ort suchen…';

  @override
  String get suchenNameEMailFachrichtung =>
      'TODO:tr: Suchen (Name, E-Mail, Fachrichtung)…';

  @override
  String get suchenNameEmailUid => 'TODO:tr: Suchen (Name, E-Mail oder UID)…';

  @override
  String get taeglicheChallenges => 'TODO:tr: Tägliche Challenges';

  @override
  String get tagEingeben => 'TODO:tr: Tag eingeben…';

  @override
  String get tagePostOP => 'TODO:tr: Tage post-OP';

  @override
  String get templateFollowupActivitySubtitle =>
      'Aktiviteyi yavaşça artırın – vücudunuzun sinyallerini dinleyin';

  @override
  String get templateFollowupActivityTitle => 'Aktiviteyi Artır';

  @override
  String get templateFollowupDay14Subtitle => 'İkinci ilerleme kontrolü';

  @override
  String get templateFollowupDay21Subtitle => 'Üçüncü ilerleme kontrolü';

  @override
  String get templateFollowupDay28Subtitle => 'Son muayene ve onay';

  @override
  String get templateFollowupDay28Title => 'Son Kontrol';

  @override
  String get templateFollowupDay7Subtitle => 'Klinikte ilerleme kontrolü';

  @override
  String get templateFollowupDay7Title => 'Kontrol Randevusu';

  @override
  String get templateFollowupScarCareSubtitle =>
      'Yara izini nazikçe nemlendirin ve gözlemleyin';

  @override
  String get templateFollowupScarCareTitle => 'Yara İzi Bakımı';

  @override
  String get templateFollowupWeeklyCheckSubtitle =>
      'İyileşme ilerlemesini değerlendirin ve belgeleyin';

  @override
  String get templateFollowupWeeklyCheckTitle => 'Haftalık Öz Kontrol';

  @override
  String get templateFollowupWoundPhotoSubtitle =>
      'İyileşme sürecini belgelemeye devam edin';

  @override
  String get templateFollowupWoundPhotoTitle => 'Yara Fotoğrafı Çek';

  @override
  String get templateMedsEveningSubtitle => 'Plana göre akşam dozu';

  @override
  String get templateMedsMiddaySubtitle => 'Plana göre öğle dozu';

  @override
  String get templateMedsMorningSubtitle => 'Plana göre sabah dozu';

  @override
  String get templateMedsMorningTitle => 'İlaç Al';

  @override
  String get templateOpdayAdmissionSubtitle =>
      'Lütfen hastaneye zamanında gelin';

  @override
  String get templateOpdayAdmissionTitle => 'Kabul';

  @override
  String get templateOpdayFastingSubtitle =>
      'Talimatlara göre yemek veya içecek almayın';

  @override
  String get templateOpdayFastingTitle => 'Açlık Kontrolü';

  @override
  String get templateOpdayInfoSubtitle => 'Açık soruları ekiple netleştirin';

  @override
  String get templateOpdayInfoTitle => 'Ameliyat Bilgilerini Onayla';

  @override
  String get templateOpdayMobilizationSubtitle =>
      'Destekle kısa süre oturun/ayağa kalkın';

  @override
  String get templateOpdayMobilizationTitle => 'İlk Hareket';

  @override
  String get templatePreopBagSubtitle =>
      'Belgeleri, kıyafetleri ve şarj cihazını paketleyin';

  @override
  String get templatePreopBagTitle => 'Hastane Çantasını Hazırla';

  @override
  String get templatePreopCompanionSubtitle =>
      'Yol ve buluşma noktasını koordine edin';

  @override
  String get templatePreopCompanionTitle => 'Refakatçiyi Bilgilendir';

  @override
  String get templatePreopDocumentsSubtitle =>
      'Sigorta kartını ve bulguları hazırlayın';

  @override
  String get templatePreopDocumentsTitle => 'Belgeleri Kontrol Et';

  @override
  String get templateWeek1AbdominalSupportSubtitle =>
      'Oturuşu ve takma şeklini kontrol edin';

  @override
  String get templateWeek1AbdominalSupportTitle =>
      'Karın Kemeri/Desteğini Kontrol Et';

  @override
  String get templateWeek1BackPostureSubtitle =>
      'Omurgayı döndürme veya bükme hareketi yapmayın';

  @override
  String get templateWeek1BackPostureTitle => 'Sırt Koruma Duruşu';

  @override
  String get templateWeek1BloodPressureSubtitle =>
      'Sabah ve akşam değerleri kaydedin';

  @override
  String get templateWeek1BloodPressureTitle => 'Tansiyon Ölç';

  @override
  String get templateWeek1BowelDiarySubtitle =>
      'Sindirimi izleyin – diyet oluşturma için önemli';

  @override
  String get templateWeek1BowelDiaryTitle => 'Bağırsak Hareketini Belgele';

  @override
  String get templateWeek1BreathingCardioSubtitle =>
      'Akciğer bakımı için derin nefesler – kalp ameliyatından sonra özellikle önemli';

  @override
  String get templateWeek1BreathingCardioTitle => 'Nefes Egzersizleri';

  @override
  String get templateWeek1BreathingSpineSubtitle =>
      'Derin nefesler – sırt düz, nazikçe nefes alın';

  @override
  String get templateWeek1BreathingSpineTitle => 'Nefes Egzersizleri';

  @override
  String get templateWeek1CardiacRehabSubtitle =>
      'Hafif yürüyüş, dolaşımı yavaşça geliştirin';

  @override
  String get templateWeek1CardiacRehabTitle =>
      'Kardiyak Rehabilitasyon Egzersizleri';

  @override
  String get templateWeek1CompressionSubtitle =>
      'Çorapların oturmasını ve durumunu kontrol edin';

  @override
  String get templateWeek1CompressionTitle =>
      'Kompresyon Çoraplarını Kontrol Et';

  @override
  String get templateWeek1DietBuildupSubtitle =>
      'Hafif yemek, yumuşak diyet → yavaşça artırın';

  @override
  String get templateWeek1DietBuildupTitle => 'Diyet Oluşturma';

  @override
  String get templateWeek1DressingSubtitle =>
      'Pansuman durumunu kontrol edin ve belgeleyin';

  @override
  String get templateWeek1DressingTitle => 'Pansuman Kontrolü';

  @override
  String get templateWeek1HydrationSubtitle => 'Günde en az 1,5 litre sıvı';

  @override
  String get templateWeek1HydrationTitle => 'Sıvı Alımını Kontrol Et';

  @override
  String get templateWeek1JointRomSubtitle =>
      'Bükme ve germeyi dikkatli test edin';

  @override
  String get templateWeek1JointRomTitle => 'Eklem Hareketliliğini Kontrol Et';

  @override
  String get templateWeek1LegExercisesSubtitle =>
      'Ayakları döndürün, bacakları gerin – tromboz önleme';

  @override
  String get templateWeek1LegExercisesTitle => 'Bacak Egzersizleri Yap';

  @override
  String get templateWeek1MobilizationSubtitle =>
      'Yavaşça hareket edin – küçük adımlar da sayılır';

  @override
  String get templateWeek1MobilizationTitle =>
      'Kısa Süre Ayağa Kalk ve Hareket Et';

  @override
  String get templateWeek1NoStrainingSubtitle =>
      'Zorlanmayın, kalkarken yana doğru yuvarlanın';

  @override
  String get templateWeek1NoStrainingTitle => 'Karın Kası Koruma';

  @override
  String get templateWeek1OrthosisSubtitle =>
      'Oturuş ve takma süresini kontrol edin';

  @override
  String get templateWeek1OrthosisTitle => 'Ortez/Korse Kontrolü';

  @override
  String get templateWeek1PainScoreSubtitle =>
      'Ağrı seviyesini uygulamaya girin';

  @override
  String get templateWeek1PainScoreTitle => 'Ağrı Seviyesini Kaydet';

  @override
  String get templateWeek1RedFlagsSubtitle =>
      'Ateş, kızarıklık, şişlik, şiddetli ağrı?';

  @override
  String get templateWeek1RedFlagsTitle => 'Uyarı İşaretlerini Kontrol Et';

  @override
  String get templateWeek1SpineStabilizationSubtitle =>
      'Talimatlara göre gövde stabilizasyonu – yavaşça artırın';

  @override
  String get templateWeek1SpineStabilizationTitle =>
      'Stabilizasyon Egzersizleri';

  @override
  String get templateWeek1SternumSubtitle =>
      '5 kg\'dan fazla kaldırmayın, kolları vücuda yakın tutun';

  @override
  String get templateWeek1SternumTitle => 'Göğüs Kemiği Koruma';

  @override
  String get templateWeek1VitalsSubtitle => 'Nabız/sıcaklığı kısa not edin';

  @override
  String get templateWeek1VitalsTitle => 'Yaşam Belirtilerini Kontrol Et';

  @override
  String get templateWeek1WoundPhotoSubtitle =>
      'İlerleme takibi için fotoğraf belgeleyin';

  @override
  String get templateWeek1WoundPhotoTitle => 'Yara Fotoğrafı Çek';

  @override
  String get templateWeek2CardiacWalkSubtitle =>
      'Yürüme mesafesini yavaşça artırın, nabzı izleyin';

  @override
  String get templateWeek2CardiacWalkTitle =>
      'Kardiyak Rehabilitasyon Yürüyüşü';

  @override
  String get templateWeek2DietNormalizeSubtitle =>
      'Sindirimi izleyin – yavaşça normal diyete geçin';

  @override
  String get templateWeek2DietNormalizeTitle => 'Normal Diyete Geç';

  @override
  String get templateWeek2GaitSubtitle =>
      'Yardımcı araçlarla/arasız güvenli yürümeyi alıştırın';

  @override
  String get templateWeek2GaitTitle => 'Yürüyüş Eğitimi';

  @override
  String get templateWeek2PainSubtitle =>
      'Ağrı gelişimini belgeleyin – düzeliyor mu?';

  @override
  String get templateWeek2PainTitle => 'Ağrı Günlüğü';

  @override
  String get templateWeek2PhysioSubtitle =>
      'Talimatlara göre egzersizleri yapın';

  @override
  String get templateWeek2PhysioTitle => 'Fizyoterapi Egzersizleri';

  @override
  String get templateWeek2WalkSubtitle =>
      'Her gün biraz daha fazla yürüyün – dolaşımı güçlendirin';

  @override
  String get templateWeek2WalkTitle => 'Yürüyüşe Çık';

  @override
  String get templateWeek2WoundObserveSubtitle =>
      'İyileşme sürecini izleyin ve belgeleyin';

  @override
  String get templateWeek2WoundObserveTitle => 'Yarayı Gözlemle';

  @override
  String get termineNaechste14Tage => 'TODO:tr: Termine nächste 14 Tage';

  @override
  String get testBenachrichtigungErstellen =>
      'TODO:tr: Testbenachrichtigung erstellen';

  @override
  String get ticketChatNachrichtSchreiben => 'TODO:tr: Nachricht schreiben…';

  @override
  String get ticketErstellen => 'TODO:tr: Ticket erstellen';

  @override
  String get timelineAddNoteContent => 'İçerik (isteğe bağlı)';

  @override
  String get timelineAddTaskDescription => 'Açıklama (isteğe bağlı)';

  @override
  String get timelineAddTaskTitle => 'Başlık';

  @override
  String get timelineBesserOrganisieren =>
      'TODO:tr: Timeline besser organisieren';

  @override
  String get timelineDue => 'Yapılacak';

  @override
  String get timelineFriday => 'Cuma';

  @override
  String get timelineMonday => 'Pazartesi';

  @override
  String get timelineMyPlan => 'Planım';

  @override
  String get timelineNoOpenTasks => 'Bugün açık görev yok';

  @override
  String get timelinePhaseDefault => 'Faz';

  @override
  String get timelinePhaseFollowup => 'Kontrol';

  @override
  String get timelinePhaseOpday => 'Ameliyat Günü';

  @override
  String get timelinePhasePersonal => 'Kayıtlarım';

  @override
  String get timelinePhasePreop => 'Hazırlık';

  @override
  String get timelinePhaseWeek1 => 'Hafta 1 · İyileşme ve Kontrol';

  @override
  String get timelinePhaseWeek2 => 'Hafta 2 · Aktivasyon';

  @override
  String get timelinePlanComplete => 'Planınız şu anda tamamen tamamlandı';

  @override
  String get timelineRouteAppointment => 'Randevu Ekle';

  @override
  String get timelineRouteAppointmentDesc =>
      'Ameliyatla ilgili randevularınızı oluşturun ve yönetin.';

  @override
  String get timelineRouteDocuments => 'Belge Yükle';

  @override
  String get timelineRouteMedication => 'İlaçlar';

  @override
  String get timelineRouteMoodLog => 'Ruh Hali Günlüğü';

  @override
  String get timelineRouteMoodLogDesc =>
      'Ruh halinizi takip edin ve duygusal durumunuzdaki kalıpları fark edin.';

  @override
  String get timelineRouteNoteAdd => 'Not Oluştur';

  @override
  String get timelineRouteNoteAddDesc =>
      'Zaman çizelgenize serbest bir giriş ekleyin.';

  @override
  String get timelineRouteNutrition => 'Beslenme Günlüğü';

  @override
  String get timelineRouteNutritionDesc =>
      'Öğünlerinizi belgeleyebilir ve beslenme önerileri alabilirsiniz.';

  @override
  String get timelineRoutePainLog => 'Ağrı Günlüğü';

  @override
  String get timelineRoutePainLogDesc =>
      'Ağrı seviyenizi 1-10 arası bir ölçekte belgeleyebilirsiniz.';

  @override
  String get timelineRouteQuestions => 'Sorular ve Notlar';

  @override
  String get timelineRouteQuestionsDesc =>
      'Cerrahınıza sorularınızı ve kişisel notlarınızı kaydedin.';

  @override
  String get timelineRouteRedFlag => 'Kırmızı Bayrak Paneli';

  @override
  String get timelineRouteRedFlagDesc =>
      'Aktif uyarıları ve acil durum eylemlerini kontrol edin.';

  @override
  String get timelineRouteRehab => 'Rehabilitasyon';

  @override
  String get timelineRouteRehabDesc =>
      'Egzersizler ve ilerleme için rehabilitasyon genel görünümünü açar.';

  @override
  String get timelineRouteSleepLog => 'Uyku Günlüğü';

  @override
  String get timelineRouteSleepLogDesc =>
      'Uyku sürenizi ve kalitenizi belgeleyebilirsiniz.';

  @override
  String get timelineRoutesNotizErstellen854 => 'TODO:tr: Notiz erstellen';

  @override
  String get timelineRouteSymptomCheck => 'Semptom Kontrolü';

  @override
  String get timelineRouteTaskAdd => 'Görev Ekle';

  @override
  String get timelineRouteTaskAddDesc =>
      'Ameliyat hazırlığınız için özel bir görev oluşturun.';

  @override
  String get timelineRouteTransport => 'Ulaşım';

  @override
  String get timelineRouteTransportDesc =>
      'Hastaneye gidiş-dönüş yolculuğunuzu planlayın.';

  @override
  String get timelineRouteVitals => 'Yaşam Belirtileri';

  @override
  String get timelineRouteWoundDoc => 'Yara Belgeleme';

  @override
  String get timelineSaturday => 'Cumartesi';

  @override
  String get timelineSheetDocUpload => 'Belge yükle';

  @override
  String get timelineSheetPainLevel => 'Ağrı seviyesi';

  @override
  String get timelineSheetWoundPhoto => 'Yara fotoğrafı';

  @override
  String get timelineSunday => 'Pazar';

  @override
  String get timelineThursday => 'Perşembe';

  @override
  String get timelineToday => 'Bugün';

  @override
  String get timelineTomorrow => 'Yarın';

  @override
  String get timelineTransportDriver => 'Sürücü';

  @override
  String get timelineTransportHint =>
      'Hastaneye gidiş-dönüş yolculuğunuzu planlayın.';

  @override
  String get timelineTransportNotes => 'Notlar';

  @override
  String get timelineTransportOutbound => 'Gidiş (Saat / Buluşma Noktası)';

  @override
  String get timelineTransportReturn => 'Dönüş (Saat / Buluşma Noktası)';

  @override
  String get timelineTuesday => 'Salı';

  @override
  String get timelineVerknuepfung => 'TODO:tr: Timeline-Verknüpfung';

  @override
  String get timelineViewFullPlan => 'Tüm planı görüntüle';

  @override
  String get timelineWednesday => 'Çarşamba';

  @override
  String get timelineZusammenfassung => 'TODO:tr: Timeline Zusammenfassung';

  @override
  String get timerStarten => 'TODO:tr: Timer starten';

  @override
  String get titelBeschreibung => 'TODO:tr: Titel / Beschreibung';

  @override
  String get transkriptBearbeiten => 'TODO:tr: Transkript bearbeiten…';

  @override
  String get uebungSuchen => 'TODO:tr: Übung suchen…';

  @override
  String get userSuchen => 'TODO:tr: User suchen';

  @override
  String get userUID => 'TODO:tr: User UID';

  @override
  String get verbindungFehlgeschlagen =>
      'TODO:tr: Verbindung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get verbindungTrennen => 'TODO:tr: Verbindung trennen';

  @override
  String get verfolgeDeineRecoveryMeilensteine =>
      'TODO:tr: Verfolge deine Recovery-Meilensteine';

  @override
  String get voiceMemosMemosDurchsuchen => 'TODO:tr: Memos durchsuchen…';

  @override
  String get vordefinierteVorlagenVerwalten =>
      'TODO:tr: Vordefinierte Vorlagen verwalten';

  @override
  String get vorDerOP => 'TODO:tr: Vor der OP';

  @override
  String get vorlage => 'TODO:tr: Vorlage';

  @override
  String get vorlagenDurchsuchen => 'TODO:tr: Vorlagen suchen...';

  @override
  String get wannZumArzt => 'TODO:tr: Wann zum Arzt?';

  @override
  String get warnCall112 => '112\'yi Ara';

  @override
  String get warnCheckLabel => 'Hızlı kontrol:';

  @override
  String get warnContactClinic => 'Bu işaretlerde kliniği arayın:';

  @override
  String get warnEmergencySubtitle => 'Hayatı tehdit eden semptomlar için!';

  @override
  String get warnEmergencyTitle => 'Acil Durum?';

  @override
  String get warnItemBleedingQ1 => 'Kanama aktif ve durdurulamıyor mu?';

  @override
  String get warnItemBleedingQ2 => 'Bandaj zaten tamamen ıslandı mı?';

  @override
  String get warnItemBleedingQ3 =>
      'Baş dönmesi veya halsizlik hissediyor musunuz?';

  @override
  String get warnItemBleedingSubtitle => 'Kan bandajı hızla ıslatıyor';

  @override
  String get warnItemBleedingTitle => 'Şiddetli Kanama';

  @override
  String get warnItemBreathQ1 => 'Nefes darlığı dinlenirken oluyor mu?';

  @override
  String get warnItemBreathQ2 => 'Nefes darlığı kötüleşiyor mu?';

  @override
  String get warnItemBreathQ3 => 'Nefes alırken ağrı var mı?';

  @override
  String get warnItemBreathSubtitle => 'Nefes kısalığı veya hava açlığı';

  @override
  String get warnItemBreathTitle => 'Nefes Darlığı';

  @override
  String get warnItemFeverQ1 => 'Sıcaklığınızı ölçtünüz mü?';

  @override
  String get warnItemFeverQ2 => 'Sıcaklık 38,5 °C üzerinde mi?';

  @override
  String get warnItemFeverQ3 => 'Titreme var mı?';

  @override
  String get warnItemFeverSubtitle => 'Sıcaklık 38,5 °C üzerinde';

  @override
  String get warnItemFeverTitle => 'Yüksek Ateş';

  @override
  String get warnItemPainQ1 => 'Ağrı alışılmıştan çok daha şiddetli mi?';

  @override
  String get warnItemPainQ2 =>
      'Olağan ağrı kesicileriniz artık yardımcı olmuyor mu?';

  @override
  String get warnItemPainQ3 => 'Ağrı bölgesi şişmiş veya sıcak mı?';

  @override
  String get warnItemPainSubtitle => 'Aniden artan, kontrol edilemeyen';

  @override
  String get warnItemPainTitle => 'Şiddetli Ağrı';

  @override
  String get warnItemRednessQ1 => 'Kızarıklık yayılıyor mu?';

  @override
  String get warnItemRednessQ2 => 'Bölge ılık veya sıcak mı?';

  @override
  String get warnItemRednessQ3 => 'İrinli akıntı var mı?';

  @override
  String get warnItemRednessSubtitle => 'Yara bölgesi iltihaplanmış görünüyor';

  @override
  String get warnItemRednessTitle => 'Artan Kızarıklık / Şişlik';

  @override
  String get warnItemSmellQ1 => 'Akıntının rengi olağandışı mı?';

  @override
  String get warnItemSmellQ2 =>
      'Yaradan belirgin şekilde hoş olmayan koku geliyor mu?';

  @override
  String get warnItemSmellQ3 => 'Akıntı miktarı arttı mı?';

  @override
  String get warnItemSmellSubtitle => 'Yaradan olağandışı akıntı';

  @override
  String get warnItemSmellTitle => 'Kötü Kokulu Akıntı';

  @override
  String get warnSaveCheck => 'Kontrolü kaydet';

  @override
  String get warnTitle => 'Uyarı İşaretleri';

  @override
  String get warnzeichenStatus => 'TODO:tr: Warnzeichen Status';

  @override
  String get wartungsmodusDeaktivieren => 'TODO:tr: Wartungsmodus deaktivieren';

  @override
  String get wasBeschaeftigtDich => 'TODO:tr: Was beschäftigt dich gerade?';

  @override
  String get wasBeschreibtDeineStimmung =>
      'TODO:tr: Was beschreibt deine Stimmung?';

  @override
  String get wasHastDuBeobachtet => 'TODO:tr: Was hast du beobachtet?';

  @override
  String get weekdayShortFri => 'Cum';

  @override
  String get weekdayShortMon => 'Pzt';

  @override
  String get weekdayShortSat => 'Cmt';

  @override
  String get weekdayShortSun => 'Paz';

  @override
  String get weekdayShortThu => 'Per';

  @override
  String get weekdayShortTue => 'Sal';

  @override
  String get weekdayShortWed => 'Çar';

  @override
  String get weiterDokumentieren => 'TODO:tr: Weiter dokumentieren';

  @override
  String get weiterenPatientenHinzufuegen =>
      'TODO:tr: Weiteren Patienten hinzufügen';

  @override
  String get werbungUndDatenschutz => 'TODO:tr: Werbung & Datenschutz';

  @override
  String get wieGehtEsDir => 'TODO:tr: Wie geht es dir?';

  @override
  String get woche1 => 'TODO:tr: Woche 1';

  @override
  String get wochentage => 'TODO:tr: Wochentage';

  @override
  String get woundDocumentationNeuesFotoAufnehmen =>
      'TODO:tr: Neues Foto aufnehmen';

  @override
  String get wunddetailFehlendeArgumente =>
      'TODO:tr: Wunddetail (fehlende Argumente)';

  @override
  String get wunddokuLetzte3 => 'TODO:tr: Wunddoku letzte 3';

  @override
  String get wundeSchmerzBewegung => 'TODO:tr: Wunde, Schmerz, Bewegung';

  @override
  String get wundschmerz => 'TODO:tr: Ø Wundschmerz';

  @override
  String get wundvergleichFehlendeArgumente =>
      'TODO:tr: Wundvergleich (fehlende Argumente)';

  @override
  String get xPUndLevelSystem => 'TODO:tr: XP & Level-System';

  @override
  String get zBA1B2C3D4 => 'TODO:tr: z.B. A1B2C3D4';

  @override
  String get zBA1B2C3D4E5F6 => 'TODO:tr: z.B. A1B2C3D4E5F6';

  @override
  String get zBArztAnrufen => 'TODO:tr: z.B. Arzt anrufen';

  @override
  String get zbBefund => 'TODO:tr: z.B. Befund';

  @override
  String get zbDieBlaue => 'TODO:tr: z. B. Die blaue, nicht die rote';

  @override
  String get zbNachDemEssen =>
      'TODO:tr: z. B. mit Wasser nach dem Essen einnehmen';

  @override
  String get zBRehaBadNauheim => 'TODO:tr: z.B. Reha Bad Nauheim';

  @override
  String get zBRehaKlinikMustermann => 'TODO:tr: z. B. Reha-Klinik Mustermann';

  @override
  String get zbUpdateWirdEingespielt =>
      'TODO:tr: z.B. Update wird eingespielt…';

  @override
  String get zeitfilterZuruecksetzen => 'TODO:tr: Zeitfilter zurücksetzen';

  @override
  String get zeitraumFiltern => 'TODO:tr: Zeitraum filtern';

  @override
  String get zuDenEinstellungen => 'TODO:tr: Zu den Einstellungen';

  @override
  String get zurueckZurTimeline => 'TODO:tr: Zurück zur Timeline';

  @override
  String anfrageAblehnenBestaetigung(String name) {
    return 'TODO:tr: Möchtest du die Anfrage von $name ablehnen?';
  }

  @override
  String apptCalendarDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count randevu',
      one: '$count randevu',
    );
    return '$_temp0';
  }

  @override
  String apptCreatedBy(String name) {
    return '$name tarafından oluşturuldu';
  }

  @override
  String apptDeleteContent(String title) {
    return '\"$title\" öğesini kalıcı olarak silmek istiyor musunuz?';
  }

  @override
  String apptReminderMinutes(int minutes) {
    return '$minutes dakika önce';
  }

  @override
  String apptRepeatUntilDate(String date) {
    return '($date tarihine kadar)';
  }

  @override
  String aufgabenAuswaehlenCount(int selected, int total) {
    return 'TODO:tr: Aufgaben auswählen ($selected/$total):';
  }

  @override
  String aufgabenCount(int count) {
    return 'TODO:tr: Aufgaben ($count)';
  }

  @override
  String aufgabenCountSelected(int count, String suffix) {
    return 'TODO:tr: $count Aufgabe$suffix ausgewählt';
  }

  @override
  String bellaActionStatusCancelled(String label) {
    return '$label — iptal edildi';
  }

  @override
  String bellaActionStatusCreated(String label) {
    return '$label — oluşturuldu';
  }

  @override
  String bellaActionStatusFailed(String label) {
    return '$label — başarısız';
  }

  @override
  String bellaBriefingHttpError(int statusCode) {
    return 'Brifing oluşturulurken hata (HTTP $statusCode).';
  }

  @override
  String bellaDailyUsage(int used, int limit) {
    return 'Bugün $used / $limit mesaj';
  }

  @override
  String bellaProactiveDocGap(int days) {
    return '$days gündür hiçbir şey kaydetmediniz';
  }

  @override
  String bellaProactiveMedReminder(String name) {
    return 'Bugün $name aldınız mı?';
  }

  @override
  String bellaProactiveMedReminderMultiple(int count) {
    return 'Bugün ilaçlarınızı aldınız mı? ($count beklemede)';
  }

  @override
  String bellaProactiveOpenTasks(int count) {
    return 'Bugün için hâlâ $count açık göreviniz var';
  }

  @override
  String bellaProactiveStreakAtRisk(int streak) {
    return '$streak günlük seriniz tehlikede!';
  }

  @override
  String benachrichtigungenCountNeu(int count) {
    return 'TODO:tr: Benachrichtigungen ($count neu)';
  }

  @override
  String caregiverEntfernt(String name) {
    return 'TODO:tr: $name wurde entfernt';
  }

  @override
  String cloneErstellt(String name) {
    return 'TODO:tr: \"$name\" erstellt';
  }

  @override
  String doctorEntfernt(String name) {
    return 'TODO:tr: $name wurde entfernt';
  }

  @override
  String doctorHinzugefuegt(String name) {
    return 'TODO:tr: $name wurde hinzugefügt';
  }

  @override
  String dokumentGeloescht(String title) {
    return 'TODO:tr: „$title“ gelöscht';
  }

  @override
  String erstelltVon(String name) {
    return 'TODO:tr: Created by: $name';
  }

  @override
  String fehlerMitError(String error) {
    return 'TODO:tr: Fehler: $error';
  }

  @override
  String gueltigFuerTage(int days) {
    return 'TODO:tr: Gültig für $days Tage';
  }

  @override
  String keysErstellt(int count) {
    return 'TODO:tr: $count Keys erstellt';
  }

  @override
  String medikamentEntfernt(String name) {
    return 'TODO:tr: $name entfernt';
  }

  @override
  String medikamentWiederhergestellt(String name) {
    return 'TODO:tr: $name wiederhergestellt';
  }

  @override
  String medikamentWirdEntfernt(String name) {
    return 'TODO:tr: $name wird entfernt.';
  }

  @override
  String mitarbeiterAction(String action) {
    return 'TODO:tr: Mitarbeiter $action';
  }

  @override
  String mitarbeiterEntfernt(String name) {
    return 'TODO:tr: $name wurde entfernt';
  }

  @override
  String nameWurdeEntsperrt(String name) {
    return 'TODO:tr: $name wurde entsperrt.';
  }

  @override
  String nameWurdeGeloescht(String name) {
    return 'TODO:tr: $name wurde gelöscht.';
  }

  @override
  String nameWurdeGesperrt(String name) {
    return 'TODO:tr: $name wurde gesperrt.';
  }

  @override
  String neuesPasswortFuer(String name) {
    return 'TODO:tr: Neues Passwort für $name';
  }

  @override
  String noSearchResults(String query) {
    return 'TODO:tr: Keine Ergebnisse für „$query\"';
  }

  @override
  String notizLoeschenBestaetigung(String title) {
    return 'TODO:tr: „$title“ wirklich löschen?';
  }

  @override
  String partnerAnzeigenCount(int count) {
    return 'TODO:tr: Partner-Anzeigen ($count)';
  }

  @override
  String pushAnEmail(String email) {
    return 'TODO:tr: Push to $email';
  }

  @override
  String pushAnEmailGesendet(String email) {
    return 'TODO:tr: Push sent to $email.';
  }

  @override
  String pushAnTargetGesendet(String target) {
    return 'TODO:tr: Push to $target sent!';
  }

  @override
  String rfActiveBadge(int count) {
    return '$count aktif';
  }

  @override
  String rfActiveCount(int count) {
    return 'Aktif ($count)';
  }

  @override
  String rfLevelBadge(String level) {
    return 'Düzey: $level';
  }

  @override
  String rfResolvedCount(int count) {
    return 'Geçmiş ($count)';
  }

  @override
  String rolleGeaendert(String role) {
    return 'TODO:tr: Rolle geändert zu „$role\".';
  }

  @override
  String statusMitLabel(String label) {
    return 'TODO:tr: Status: $label';
  }

  @override
  String tageVergeben(int days) {
    return 'TODO:tr: $days Tage gewährt';
  }

  @override
  String ticketsCountOffen(int count) {
    return 'TODO:tr: Tickets ($count open)';
  }

  @override
  String timelineDoneOfTotal(int done, int total) {
    return '$done/$total tamamlandı';
  }

  @override
  String timelineDueAttention(int count) {
    return '$count bugün dikkat gerektiriyor';
  }

  @override
  String timelineNextUp(String title) {
    return 'Sıradaki: $title';
  }

  @override
  String timelinePhaseProgress(int done, int total) {
    return '$done/$total tamamlandı';
  }

  @override
  String timelineProgressPercent(int percent) {
    return '$percent% tamamlandı – devam edin!';
  }

  @override
  String timelineStickyDoneOfTotal(int done, int total) {
    return '$done/$total tamamlandı';
  }

  @override
  String timelineStickyDue(int count) {
    return '$count gecikmiş';
  }

  @override
  String timelineStickyToday(int count) {
    return '$count bugün';
  }

  @override
  String timelineStreakDays(int count) {
    return '$count gün';
  }

  @override
  String timelineTasksPlanned(int count) {
    return '$count görev bugün için planlandı';
  }

  @override
  String unwiderruflichLoeschen(String title) {
    return 'TODO:tr: „$title“ wird dauerhaft gelöscht.';
  }

  @override
  String userAktionFehler(String action) {
    return 'TODO:tr: Nutzer konnte nicht ${action}t werden.';
  }

  @override
  String vorlageErstellt(String name) {
    return 'TODO:tr: Vorlage „$name\" erstellt';
  }

  @override
  String vorlageLoeschenBestaetigung(String name) {
    return 'TODO:tr: Möchtest du \"$name\" wirklich löschen?';
  }

  @override
  String vorlageUebernommen(String name) {
    return 'TODO:tr: „$name\" in eigene Vorlagen kopiert';
  }

  @override
  String warnLastCheck(String label, String date) {
    return 'Son kontrol: $label · $date';
  }

  @override
  String warnzeichenGespeichert(String level) {
    return 'TODO:tr: Warnzeichen-Check gespeichert ($level)';
  }

  @override
  String get accountUndRechtliches => 'TODO:tr: Account & Rechtliches';

  @override
  String get actionCall112 => 'TODO:tr: 112 anrufen';

  @override
  String get actionUnlock => 'TODO:tr: Entsperren';

  @override
  String get aktiveWarnungenUndNotfallaktionenPruefen =>
      'TODO:tr: Aktive Warnungen und Notfallaktionen prüfen.';

  @override
  String get alertNotruf112 => 'TODO:tr: Notruf 112';

  @override
  String get alleAbwaehlen => 'TODO:tr: Alle abwählen';

  @override
  String get alleAuswaehlen => 'TODO:tr: Alle auswählen';

  @override
  String get alleKategorienErledigt => 'TODO:tr: Alle Kategorien erledigt!';

  @override
  String get alleTermineImBlick => 'TODO:tr: Alle Termine im Blick';

  @override
  String get allesErledigt => 'TODO:tr: Alles erledigt!';

  @override
  String get analyticsNutrition => 'TODO:tr: Ernährung';

  @override
  String get analyticsOverview => 'TODO:tr: Übersicht';

  @override
  String get analyticsPain => 'TODO:tr: Schmerzen';

  @override
  String get analyticsVitals => 'TODO:tr: Vitaldaten';

  @override
  String get analyticsWounds => 'TODO:tr: Wunden';

  @override
  String get apptAllDay => 'Tüm gün';

  @override
  String get arztAnrufen => 'TODO:tr: Arzt anrufen';

  @override
  String get arztKontaktieren => 'TODO:tr: Arzt kontaktieren';

  @override
  String get aufgabeHinzufuegen => 'TODO:tr: Aufgabe hinzufügen';

  @override
  String get aufgabenUndTimeline => 'TODO:tr: Aufgaben & Timeline';

  @override
  String get aufmerksamkeitErforderlich =>
      'TODO:tr: Aufmerksamkeit erforderlich';

  @override
  String get ausGalerie => 'TODO:tr: Aus Galerie';

  @override
  String get ausZwischenNablageEinfuegen =>
      'TODO:tr: Aus Zwischenablage einfügen';

  @override
  String get authServiceGoogleSignInWasCancelledByTheUser =>
      'TODO:tr: Der Google-Anmeldevorgang wurde abgebrochen.';

  @override
  String get badgeMedicationHero => 'TODO:tr: Medikamenten-Held';

  @override
  String get badgeMedicationHeroDesc => 'TODO:tr: 7 Tage ohne vergessene Dosis';

  @override
  String get badgeMoodTrackerDesc => 'TODO:tr: Stimmung 20 Mal dokumentiert';

  @override
  String get badgePainTracker => 'TODO:tr: Schmerz-Tracker';

  @override
  String get badgePainTrackerDesc => 'TODO:tr: Schmerzen 20 Mal dokumentiert';

  @override
  String get bandscheibenOP44Jahre => 'TODO:tr: Bandscheiben-OP, 44 Jahre';

  @override
  String get befundeUndBerichte => 'TODO:tr: Befunde & Berichte';

  @override
  String get begleitetWerden => 'TODO:tr: Begleitet werden';

  @override
  String get bellaAIGespraechsexport => 'TODO:tr: Bella AI – Gesprächsexport';

  @override
  String get bevorIchLoslegenKannBraucheIchKurzDeineEinwilligung =>
      'TODO:tr: Bevor ich loslegen kann, brauche ich kurz deine Einwilligung';

  @override
  String get bevorstehendeArztUndKliniktermine =>
      'TODO:tr: Bevorstehende Arzt- und Kliniktermine';

  @override
  String get bildAuswaehlen => 'TODO:tr: Bild auswählen';

  @override
  String get bitteGibEinenKeyEin => 'TODO:tr: Bitte gib einen Key ein.';

  @override
  String get blutwerteAbgegeben => 'TODO:tr: Blutwerte abgegeben';

  @override
  String caregiverRemoved(String name) {
    return 'TODO:tr: $name wurde entfernt';
  }

  @override
  String get challengeGeschafft => 'TODO:tr: Challenge geschafft!';

  @override
  String get checklisteFuerDieKlinik => 'TODO:tr: Checkliste für die Klinik';

  @override
  String get cpAbdominalBelt => 'TODO:tr: Bauchgurt/Stütze prüfen';

  @override
  String get cpAbdominalBeltDesc => 'TODO:tr: Sitz und Trageweise prüfen';

  @override
  String get cpAbdominalProtection => 'TODO:tr: Bauchmuskelschutz';

  @override
  String get cpAbdominalProtectionDesc =>
      'TODO:tr: Nicht pressen, beim Aufstehen zur Seite rollen';

  @override
  String get cpAdmission => 'TODO:tr: Aufnahme';

  @override
  String get cpAdmissionDesc => 'TODO:tr: Bitte pünktlich in der Klinik melden';

  @override
  String get cpBandageCheck => 'TODO:tr: Verband kontrollieren';

  @override
  String get cpBandageCheckDesc =>
      'TODO:tr: Verbandszustand prüfen und dokumentieren';

  @override
  String get cpBreathingExercises => 'TODO:tr: Atemübungen';

  @override
  String get cpBreathingExercisesHeartDesc =>
      'TODO:tr: Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen';

  @override
  String get cpBreathingExercisesSpineDesc =>
      'TODO:tr: Tiefe Atemzüge – Rücken gerade, sanft atmen';

  @override
  String get cpCardiacRehabExercises => 'TODO:tr: Herzreha-Übungen';

  @override
  String get cpCardiacRehabExercisesDesc =>
      'TODO:tr: Leichtes Gehen, Kreislauf langsam aufbauen';

  @override
  String get cpCardiacRehabWalk => 'TODO:tr: Herzreha-Spaziergang';

  @override
  String get cpCardiacRehabWalkDesc =>
      'TODO:tr: Gehstrecke langsam steigern, Puls beobachten';

  @override
  String get cpCheckDocuments => 'TODO:tr: Dokumente prüfen';

  @override
  String get cpCheckDocumentsDesc =>
      'TODO:tr: Krankenkassenkarte und Unterlagen vorbereiten';

  @override
  String get cpCheckFasting => 'TODO:tr: Nüchternheit prüfen';

  @override
  String get cpCheckFastingDesc =>
      'TODO:tr: Keine Nahrung oder Flüssigkeit wie angewiesen';

  @override
  String get cpCheckFluidIntake => 'TODO:tr: Flüssigkeitszufuhr prüfen';

  @override
  String get cpCheckFluidIntakeDesc =>
      'TODO:tr: Mindestens 1,5 Liter Flüssigkeit täglich';

  @override
  String get cpCheckOrthosis => 'TODO:tr: Orthese/Korsett prüfen';

  @override
  String get cpCheckOrthosisDesc => 'TODO:tr: Sitz und Tragezeit prüfen';

  @override
  String get cpCheckVitals => 'TODO:tr: Vitalzeichen prüfen';

  @override
  String get cpCheckVitalsDesc => 'TODO:tr: Puls/Temperatur kurz notieren';

  @override
  String get cpCheckWarnings => 'TODO:tr: Warnzeichen prüfen';

  @override
  String get cpCheckWarningsDesc =>
      'TODO:tr: Fieber, Rötung, Schwellung, starke Schmerzen?';

  @override
  String get cpCompressionStockings => 'TODO:tr: Kompressionsstrümpfe prüfen';

  @override
  String get cpCompressionStockingsDesc =>
      'TODO:tr: Sitz und Zustand der Strümpfe prüfen';

  @override
  String get cpConfirmOpInfo => 'TODO:tr: OP-Informationen bestätigen';

  @override
  String get cpConfirmOpInfoDesc =>
      'TODO:tr: Offene Fragen mit dem Team klären';

  @override
  String get cpDietProgression => 'TODO:tr: Kostaufbau';

  @override
  String get cpDietProgressionDesc =>
      'TODO:tr: Leichte Kost, Schonkost → langsam steigern';

  @override
  String get cpDocumentBowel => 'TODO:tr: Stuhlgang dokumentieren';

  @override
  String get cpDocumentBowelDesc =>
      'TODO:tr: Verdauung beobachten – wichtig für den Kostaufbau';

  @override
  String get cpEveningDose => 'TODO:tr: Abenddosis wie vorgeschrieben';

  @override
  String get cpFinalCheck => 'TODO:tr: Abschlusskontrolle';

  @override
  String get cpFinalCheckDesc =>
      'TODO:tr: Abschlussuntersuchung und Entlassung';

  @override
  String get cpFirstMobilisation => 'TODO:tr: Erste Mobilisation';

  @override
  String get cpFirstMobilisationDesc =>
      'TODO:tr: Kurz aufsetzen/aufstehen mit Unterstützung';

  @override
  String get cpFollowUpAppointment => 'TODO:tr: Nachsorgetermin';

  @override
  String get cpFollowUpDesc1 => 'TODO:tr: Fortschrittskontrolle in der Klinik';

  @override
  String get cpFollowUpDesc2 => 'TODO:tr: Zweite Fortschrittskontrolle';

  @override
  String get cpFollowUpDesc3 => 'TODO:tr: Dritte Fortschrittskontrolle';

  @override
  String get cpGaitTraining => 'TODO:tr: Gangschulung';

  @override
  String get cpGaitTrainingDesc =>
      'TODO:tr: Sicheres Gehen mit/ohne Hilfsmittel üben';

  @override
  String get cpGoForWalk => 'TODO:tr: Spazieren gehen';

  @override
  String get cpGoForWalkDesc =>
      'TODO:tr: Jeden Tag etwas weiter laufen – Kreislauf stärken';

  @override
  String get cpIncreaseActivity => 'TODO:tr: Aktivität steigern';

  @override
  String get cpIncreaseActivityDesc =>
      'TODO:tr: Aktivität langsam steigern – auf Körpersignale achten';

  @override
  String get cpInformCompanion => 'TODO:tr: Begleitperson informieren';

  @override
  String get cpInformCompanionDesc => 'TODO:tr: Fahrt und Treffpunkt abstimmen';

  @override
  String get cpLegExercises => 'TODO:tr: Beinübungen durchführen';

  @override
  String get cpLegExercisesDesc =>
      'TODO:tr: Füße kreisen, Beine anspannen – Thromboseprophylaxe';

  @override
  String get cpMorningDose => 'TODO:tr: Morgendosis wie vorgeschrieben';

  @override
  String get cpNoonDose => 'TODO:tr: Mittagsdosis wie vorgeschrieben';

  @override
  String get cpNormalDietProgression => 'TODO:tr: Normale Ernährung aufbauen';

  @override
  String get cpNormalDietProgressionDesc =>
      'TODO:tr: Verdauung beobachten – schrittweise zur normalen Ernährung';

  @override
  String get cpObserveWound => 'TODO:tr: Wunde beobachten';

  @override
  String get cpObserveWoundDesc =>
      'TODO:tr: Heilungsverlauf beobachten und dokumentieren';

  @override
  String get cpPackHospitalBag => 'TODO:tr: Kliniktasche packen';

  @override
  String get cpPackHospitalBagDesc =>
      'TODO:tr: Dokumente, Kleidung und Ladekabel einpacken';

  @override
  String get cpPainDiary => 'TODO:tr: Schmerztagebuch';

  @override
  String get cpPainDiaryDesc =>
      'TODO:tr: Schmerzverlauf dokumentieren – bessert es sich?';

  @override
  String get cpPhysioExercises => 'TODO:tr: Physiotherapie-Übungen';

  @override
  String get cpPhysioExercisesDesc =>
      'TODO:tr: Übungen wie angewiesen durchführen';

  @override
  String get cpRecordPainLevel => 'TODO:tr: Schmerzniveau erfassen';

  @override
  String get cpRecordPainLevelDesc =>
      'TODO:tr: Schmerzniveau in der App eingeben';

  @override
  String get cpScarCare => 'TODO:tr: Narbenpflege';

  @override
  String get cpScarCareDesc => 'TODO:tr: Narbe sanft eincremen und beobachten';

  @override
  String get cpSpineProtection => 'TODO:tr: Rückenschutzhaltung';

  @override
  String get cpSpineProtectionDesc =>
      'TODO:tr: Kein Verdrehen oder Beugen der Wirbelsäule';

  @override
  String get cpStabilisationExercises => 'TODO:tr: Stabilisationsübungen';

  @override
  String get cpStabilisationExercisesDesc =>
      'TODO:tr: Rumpfstabilisation wie angewiesen – schrittweise steigern';

  @override
  String get cpSternumProtection => 'TODO:tr: Sternumschutz';

  @override
  String get cpSternumProtectionDesc =>
      'TODO:tr: Kein Heben über 5 kg, Arme nah am Körper halten';

  @override
  String get cpTakeMedication => 'TODO:tr: Medikamente einnehmen';

  @override
  String get cpTakeWoundPhoto => 'TODO:tr: Wundfoto aufnehmen';

  @override
  String get cpTakeWoundPhotoDesc =>
      'TODO:tr: Foto zur Fortschrittsverfolgung dokumentieren';

  @override
  String get cpTakeWoundPhotoProgress => 'TODO:tr: Wundfoto aufnehmen';

  @override
  String get cpTakeWoundPhotoProgressDesc =>
      'TODO:tr: Heilungsfortschritt weiter dokumentieren';

  @override
  String get cpWeeklySelfCheck => 'TODO:tr: Wöchentliche Selbstkontrolle';

  @override
  String get cpWeeklySelfCheckDesc =>
      'TODO:tr: Heilungsfortschritt auswerten und dokumentieren';

  @override
  String get dasRehaSystemMitTimerIstGoldWert =>
      'TODO:tr: Das Reha-System mit Timer ist Gold wert.';

  @override
  String get datenEingeben => 'TODO:tr: Daten eingeben';

  @override
  String debugEmail(String email) {
    return 'TODO:tr: E-Mail: $email';
  }

  @override
  String get debugLinkedPatients => 'TODO:tr: Verknüpfte Patienten';

  @override
  String get debugNotAvailable => 'TODO:tr: nicht verfügbar';

  @override
  String get debugNotLoggedIn => 'TODO:tr: nicht angemeldet';

  @override
  String get debugOnlyForAdmins => 'TODO:tr: Nur für Admins verfügbar.';

  @override
  String get debugOnlyInDebug => 'TODO:tr: Nur in Debug-Builds verfügbar.';

  @override
  String debugRole(String role) {
    return 'TODO:tr: Rolle: $role';
  }

  @override
  String debugUid(String uid) {
    return 'TODO:tr: UID: $uid';
  }

  @override
  String get deineHeutigeChallenge => 'TODO:tr: Deine heutige Challenge';

  @override
  String get deineWochenZusammenfassung =>
      'TODO:tr: Deine Wochen-Zusammenfassung';

  @override
  String get derNutzerVerliertSofortDenProZugang =>
      'TODO:tr: Der Nutzer verliert sofort den Pro-Zugang.';

  @override
  String get dieserKeyIstAbgelaufen => 'TODO:tr: Dieser Key ist abgelaufen.';

  @override
  String get dokuHubFuerKameraUndGalerie =>
      'TODO:tr: Doku-Hub für Kamera & Galerie';

  @override
  String get dokumenteHochladen => 'TODO:tr: Dokumente hochladen';

  @override
  String get duHastAlleAufgabenAbgeschlossenGoennDirEinePause =>
      'TODO:tr: Du hast alle Aufgaben abgeschlossen. Gönn dir eine Pause.';

  @override
  String get duMusstAngemeldetSein => 'TODO:tr: Du musst angemeldet sein.';

  @override
  String get einnahmeDokumentieren => 'TODO:tr: Einnahme dokumentieren';

  @override
  String get empty7DaysNoData => 'TODO:tr: 7 Tage: keine Daten';

  @override
  String get emptyNoMacros => 'TODO:tr: Keine Makros erfasst';

  @override
  String get emptyNoNotifications => 'TODO:tr: Keine Benachrichtigungen';

  @override
  String get emptyNoRedFlags => 'TODO:tr: Keine offenen Red Flags';

  @override
  String get emptyNoVitals => 'TODO:tr: Noch keine Vitaldaten erfasst';

  @override
  String get emptyNoVitalsShort => 'TODO:tr: Noch keine Vitaldaten';

  @override
  String get emptyTasksInPlan => 'TODO:tr: Noch keine Aufgaben im Plan.';

  @override
  String get emptyTodayNoEntries => 'TODO:tr: Heute: keine Einträge';

  @override
  String get erinnerungenAnMedikamenteneinnahme =>
      'TODO:tr: Erinnerungen an Medikamenteneinnahme';

  @override
  String get erstelle => 'TODO:tr: Erstelle…';

  @override
  String get erstelleDeinKontoInWenigenSekunden =>
      'TODO:tr: Erstelle dein Konto in wenigen Sekunden.';

  @override
  String get erstelleEineEigeneAufgabeFuerDeineOPVorbereitung =>
      'TODO:tr: Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.';

  @override
  String get erstelleUndVerwalteDeineOPBezogenenTermine =>
      'TODO:tr: Erstelle und verwalte deine OP-bezogenen Termine.';

  @override
  String get familyOverviewAufmerksamkeitErforderlich =>
      'TODO:tr: Aufmerksamkeit erforderlich';

  @override
  String get fehlerBeimEinloesenBitteVersucheEsErneut =>
      'TODO:tr: Fehler beim Einlösen. Bitte versuche es erneut.';

  @override
  String get fehlerBeimSpeichernErneut =>
      'TODO:tr: Fehler beim Speichern. Bitte erneut versuchen.';

  @override
  String fehlerGeneric(String error) {
    return 'TODO:tr: Fehler: $error';
  }

  @override
  String fehlerMitDetails(String error) {
    return 'TODO:tr: Fehler: $error';
  }

  @override
  String get fotoAufnehmen => 'TODO:tr: Foto aufnehmen';

  @override
  String get fragenUndNotizen => 'TODO:tr: Fragen & Notizen';

  @override
  String get fuegeDeineOPInformationenHinzu =>
      'TODO:tr: Füge deine OP-Informationen hinzu.';

  @override
  String get googleSignInWasCancelledByTheUser =>
      'TODO:tr: Der Google-Anmeldevorgang wurde abgebrochen.';

  @override
  String get habenSieAtembeschwerdenOderKurzatmigkeit =>
      'TODO:tr: Haben Sie Atembeschwerden oder Kurzatmigkeit?';

  @override
  String get halteEinenFreienEintragInDeinerTimelineFest =>
      'TODO:tr: Halte einen freien Eintrag in deiner Timeline fest.';

  @override
  String get hintDescribeInDetail =>
      'TODO:tr: Beschreibe dein Anliegen so genau wie möglich…';

  @override
  String get hintShortDescription =>
      'TODO:tr: Kurze Beschreibung deines Anliegens';

  @override
  String get ichWarNervoesVorDerOPDieRedFlagWarnung =>
      'TODO:tr: Ich war nervös vor der OP. Die Red-Flag Warnung';

  @override
  String itemDeletedMessage(String title) {
    return 'TODO:tr: „$title“ gelöscht';
  }

  @override
  String itemDeletedPermanently(String title) {
    return 'TODO:tr: „$title“ wird dauerhaft gelöscht.';
  }

  @override
  String get keyNichtGefunden => 'TODO:tr: Key nicht gefunden.';

  @override
  String get knieTEP58Jahre => 'TODO:tr: Knie-TEP, 58 Jahre';

  @override
  String get kritischerSymptomCheck => 'TODO:tr: Kritischer Symptom-Check';

  @override
  String get labelCategory => 'TODO:tr: Kategorie';

  @override
  String get labelContentOptional => 'TODO:tr: Inhalt (optional)';

  @override
  String get labelCustomMinutes => 'TODO:tr: Eigene Minuten';

  @override
  String get labelDescriptionOptional => 'TODO:tr: Beschreibung (optional)';

  @override
  String get labelInviteCode => 'TODO:tr: Einladungscode';

  @override
  String labelInviteCodeValue(String code) {
    return 'TODO:tr: Code: $code';
  }

  @override
  String get labelLinkType => 'TODO:tr: Link-Typ';

  @override
  String get labelLocation => 'TODO:tr: Ort';

  @override
  String get labelLocationDetails => 'TODO:tr: Ortsdetails';

  @override
  String get labelNote => 'TODO:tr: Notiz';

  @override
  String get labelObservation => 'TODO:tr: Beobachtung';

  @override
  String get labelReminder => 'TODO:tr: Erinnerung';

  @override
  String get labelSubject => 'TODO:tr: Betreff';

  @override
  String get labelTitle => 'TODO:tr: Titel';

  @override
  String get labelTitleRequired => 'TODO:tr: Titel *';

  @override
  String get labelType => 'TODO:tr: Typ';

  @override
  String get mahlzeitenUndEmpfehlungen => 'TODO:tr: Mahlzeiten & Empfehlungen';

  @override
  String get measurementSaved => 'TODO:tr: Messung gespeichert';

  @override
  String get meinePatienten => 'TODO:tr: Meine Patienten';

  @override
  String get memoAufnehmen => 'TODO:tr: Memo aufnehmen';

  @override
  String get n7Tage => 'TODO:tr: Ø 7 Tage';

  @override
  String get nachDerOP => 'TODO:tr: Nach der OP';

  @override
  String get nachMeinerKnieOPHatteIchHundertFragen =>
      'TODO:tr: Nach meiner Knie-OP hatte ich hundert Fragen.';

  @override
  String get nachrichtNsenden => 'TODO:tr: Nachricht\nsenden';

  @override
  String get notifChannelAppointments =>
      'TODO:tr: Erinnerungen für bevorstehende Termine';

  @override
  String get notifChannelMedication => 'TODO:tr: Medikamentenerinnerung';

  @override
  String get notifChannelMedicationDesc =>
      'TODO:tr: Tägliche Erinnerungen für Medikamente';

  @override
  String get notifChannelVitals => 'TODO:tr: Vitaldaten-Erinnerung';

  @override
  String get notifChannelVitalsDesc =>
      'TODO:tr: Tägliche Erinnerung für Vitaldatenmessungen';

  @override
  String notifDoctorAnswered(String name) {
    return 'TODO:tr: Dr. $name hat deine Frage beantwortet';
  }

  @override
  String get notifMeasureVitals => 'TODO:tr: Vitaldaten messen';

  @override
  String notifObservationFrom(String name) {
    return 'TODO:tr: Beobachtung von $name';
  }

  @override
  String get notifWoundAlarm => 'TODO:tr: Wund-Alarm';

  @override
  String get notizErstellen => 'TODO:tr: Notiz erstellen';

  @override
  String get nutritionProteinG1110 => 'TODO:tr: Protein (g)';

  @override
  String get oPAngelegt => 'TODO:tr: OP angelegt';

  @override
  String get oPTag => 'TODO:tr: OP‑Tag';

  @override
  String get oPTagWundeFrischVersorgtSterilerVerbandAngelegt =>
      'TODO:tr: OP‑Tag. Wunde frisch versorgt, steriler Verband angelegt.';

  @override
  String get oeffnetDieRehaUebersichtFuerUebungenUndFortschritt =>
      'TODO:tr: Öffnet die Reha-Übersicht für Übungen und Fortschritt.';

  @override
  String get operateurUndAnaesthesist => 'TODO:tr: Operateur & Anästhesist';

  @override
  String get pain7Tage => 'TODO:tr: Ø 7 Tage';

  @override
  String get painDiary7Tage => 'TODO:tr: Ø 7 Tage';

  @override
  String get patientNhinzufuegen => 'TODO:tr: Patient\nhinzufügen';

  @override
  String get planeHinUndRueckfahrtZurKlinik =>
      'TODO:tr: Plane Hin- und Rückfahrt zur Klinik.';

  @override
  String get proActiveSubtitle => 'TODO:tr: Alle Funktionen freigeschaltet';

  @override
  String get proActiveTitle => 'TODO:tr: Pro aktiv';

  @override
  String get proEntziehen => 'TODO:tr: Pro entziehen';

  @override
  String get proGeben => 'TODO:tr: Pro vergeben';

  @override
  String get proStatusEntziehen => 'TODO:tr: Pro-Status entziehen?';

  @override
  String get redFlagCockpit => 'TODO:tr: Red-Flag Cockpit';

  @override
  String redFlagCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flags',
      one: 'Flag',
    );
    return 'TODO:tr: $count $_temp0';
  }

  @override
  String get rolleKonnteNichtGeladenWerden =>
      'TODO:tr: Rolle konnte nicht geladen werden.';

  @override
  String get ruheBewahren => 'TODO:tr: Ruhe bewahren';

  @override
  String get schmerzErfassen => 'TODO:tr: Schmerz erfassen';

  @override
  String get setzenOderLegenSieSichHinAtmenSieRuhig =>
      'TODO:tr: Setzen oder legen Sie sich hin. Atmen Sie ruhig.';

  @override
  String get sleepEntryEditorNotizOptional => 'TODO:tr: Notiz (optional)';

  @override
  String get speichere => 'TODO:tr: Speichere…';

  @override
  String get speichert => 'TODO:tr: Speichert…';

  @override
  String get streakGerettet => 'TODO:tr: Streak gerettet!';

  @override
  String get symptomCheckServiceNotruf112 => 'TODO:tr: Notruf 112';

  @override
  String get symptomU2011Check => 'TODO:tr: Symptom‑Check';

  @override
  String systemVorlageFehler(String error) {
    return 'TODO:tr: Fehler: $error';
  }

  @override
  String get timelineRoutesAufgabeHinzufuegen => 'TODO:tr: Aufgabe hinzufügen';

  @override
  String get timelineRoutesNotizErstellen => 'TODO:tr: Notiz erstellen';

  @override
  String get timelineTransportTitle => 'Ulaşım Planlaması';

  @override
  String get trittMeinemOperationsbegleiterBeiNN =>
      'TODO:tr: Tritt meinem Operationsbegleiter bei!\n\n';

  @override
  String get uebungenTimerUndFortschritt =>
      'TODO:tr: Übungen, Timer & Fortschritt';

  @override
  String get updatesProStatusUndAppHinweise =>
      'TODO:tr: Updates, Pro-Status & App-Hinweise';

  @override
  String userBlocked(String name) {
    return 'TODO:tr: $name wurde gesperrt.';
  }

  @override
  String userDeleted(String name) {
    return 'TODO:tr: $name wurde gelöscht.';
  }

  @override
  String userGesperrtEntsperrt(String action) {
    return 'TODO:tr: Nutzer $action.';
  }

  @override
  String userUnblocked(String name) {
    return 'TODO:tr: $name wurde entsperrt.';
  }

  @override
  String get vitalsNotizOptional => 'TODO:tr: Notiz (optional)';

  @override
  String get vorWaehrendUndNachDerOP => 'TODO:tr: Vor, während & nach der OP';

  @override
  String get vorlageErzeugen => 'TODO:tr: Vorlage erstellen';

  @override
  String warningCheckSaved(String level) {
    return 'TODO:tr: Warnüberprüfung gespeichert ($level)';
  }

  @override
  String get warnungenBeiKritischenWundkontrollErgebnissen =>
      'TODO:tr: Warnungen bei kritischen Wundkontroll-Ergebnissen';

  @override
  String get warnungenUndNotfall => 'TODO:tr: Warnungen & Notfall';

  @override
  String get wieHastDuGeschlafen => 'TODO:tr: Wie hast du geschlafen?';

  @override
  String get wieStarkSindIhreSchmerzenImOPBereich =>
      'TODO:tr: Wie stark sind Ihre Schmerzen im OP-Bereich?';

  @override
  String get wirdZugewiesen => 'TODO:tr: Wird zugewiesen…';

  @override
  String get wunddokumentation => 'TODO:tr: Wunddokumentation';

  @override
  String get wundenDokumentieren => 'TODO:tr: Wunden dokumentieren';

  @override
  String get zusammenfassungFuerDenArzt =>
      'TODO:tr: Zusammenfassung für den Arzt';

  @override
  String get rtsTitle => 'Spora Dönüş Testi';

  @override
  String get rtsNewAssessment => 'Yeni Test Başlat';

  @override
  String get rtsLatestResult => 'Son Sonuç';

  @override
  String get rtsHistory => 'Test Geçmişi';

  @override
  String get rtsScore => 'Toplam Puan';

  @override
  String get rtsCleared => 'Onaylandı ✓';

  @override
  String get rtsAlmostReady => 'Neredeyse Hazır';

  @override
  String get rtsNotReady => 'Henüz Hazır Değil';

  @override
  String get rtsClearedMessage =>
      'Puanınız eşiği aştı. Spora dönebilirsiniz – lütfen önce doktorunuzla görüşün.';

  @override
  String get rtsAlmostReadyMessage =>
      'İyi ilerliyorsunuz. Antrenmanınızı sürdürün ve birkaç hafta sonra testi tekrarlayın.';

  @override
  String get rtsNotReadyMessage =>
      'Vücudunuz biraz daha zamanı hakediyor. Spora dönmeden önce rehabilitasyon ve güçlendirme egzersizlerine odaklanın.';

  @override
  String get rtsEmptyTitle => 'Spora Dönmeye Hazır mısınız?';

  @override
  String get rtsEmptySubtitle =>
      'Start your first fitness test. Instead of arbitrary time rules, measure strength, balance, and stability.';

  @override
  String get rtsAssessmentTitle => 'Fitness Testi';

  @override
  String get rtsResultTitle => 'Test Sonucu';

  @override
  String get rtsBreakdown => 'Bireysel Sonuçlar';

  @override
  String get rtsFinishAssessment => 'Skoru Hesapla';

  @override
  String get rtsDeleteTitle => 'Testi Sil';

  @override
  String get rtsDeleteConfirm => 'Bu test sonucu kalıcı olarak silinecektir.';

  @override
  String get rtsValidationHint => 'Lütfen tüm zorunlu alanları doldurun.';

  @override
  String get rtsNotesLabel => 'Not (isteğe bağlı)';

  @override
  String get rtsNotesHint => 'Günlük form, koşullar …';

  @override
  String rtsStepOf(String current, String total) {
    return 'Adım $current/$total';
  }

  @override
  String get rtsTestLsiTitle => 'Uzuv Simetri İndeksi (LSI)';

  @override
  String get rtsTestLsiDesc =>
      'Etkilenen tarafın performansını sağlıklı tarafla karşılaştırın.';

  @override
  String get rtsTestLsiHint => 'LSI ≥ %90 optimal sınır olarak kabul edilir.';

  @override
  String get rtsLsiSeconds => 'Saniye';

  @override
  String get rtsLsiReps => 'Tekrar';

  @override
  String rtsLsiAffected(String unit) {
    return 'Etkilenen taraf ($unit)';
  }

  @override
  String rtsLsiHealthy(String unit) {
    return 'Sağlıklı taraf ($unit)';
  }

  @override
  String rtsLsiDetailValue(
    String affected,
    String healthy,
    String unit,
    String percent,
  ) {
    return 'Etkilenen: $affected $unit / Sağlıklı: $healthy $unit → LSI: $percent';
  }

  @override
  String get rtsTestBalanceTitle => 'Tek Bacak Dengesi';

  @override
  String get rtsTestBalanceDesc =>
      'Etkilenen bacak üzerinde mümkün olduğunca uzun süre dengede durun.';

  @override
  String get rtsTestBalanceHint => '30 saniye tam puana karşılık gelir.';

  @override
  String get rtsBalanceSeconds => 'Süre (saniye)';

  @override
  String rtsBalanceDetailValue(String seconds) {
    return '$seconds saniye';
  }

  @override
  String get rtsTestStabilityTitle => 'Stabilite (Tek Bacak Çömelme)';

  @override
  String get rtsTestStabilityDesc =>
      'Etkilenen bacakta tek bacak çömelme hareketini ne kadar iyi yapabiliyorsunuz?';

  @override
  String get rtsStability1 =>
      '1 – Yapılamıyor, şiddetli ağrı veya kontrol kaybı.';

  @override
  String get rtsStability2 => '2 – Büyük kısıtlamalarla zor yapılabilir.';

  @override
  String get rtsStability3 => '3 – Kompanzasyonlarla yapılabilir.';

  @override
  String get rtsStability4 => '4 – Neredeyse normal.';

  @override
  String get rtsStability5 => '5 – Tam kontrol, ağrısız.';

  @override
  String rtsStabilityDetailValue(String rating) {
    return 'Kendi değerlendirmesi: $rating / 5';
  }

  @override
  String get rtsTestPainTitle => 'Aktivite Sırasında Ağrı';

  @override
  String get rtsTestPainDesc =>
      'Spora özgü aktiviteler sırasında ağrınız ne kadar şiddetli? 0–10 arasında değerlendirin.';

  @override
  String get rtsPainNoKein => '0 – Ağrı yok';

  @override
  String get rtsPainSevere => '10 – En şiddetli ağrı';

  @override
  String rtsPainDetailValue(String level) {
    return 'NRS: $level / 10';
  }

  @override
  String get rtsSportTypeTitle => 'Spor Türü';

  @override
  String get rtsSportTypeDesc => 'Hangi spora geri dönmek istiyorsunuz?';

  @override
  String get rtsSportRunning => 'Koşu';

  @override
  String get rtsSportSoccer => 'Futbol / Takım Sporları';

  @override
  String get rtsSportStrength => 'Güç Antrenmanı';

  @override
  String get rtsSportCycling => 'Bisiklet';

  @override
  String get rtsSportSwimming => 'Yüzme';

  @override
  String get rtsSportMartialArts => 'Dövüş Sanatları';

  @override
  String get rtsSportOther => 'Diğer';

  @override
  String get rtsTestHopTitle => 'Tek Bacak Sıçrama Testi';

  @override
  String get rtsTestHopDesc =>
      'Etkilenen bacakla mümkün olduğunca ileri sıçrayın ve mesafeyi ölçün. Sağlıklı tarafla tekrarlayın.';

  @override
  String get rtsTestHopHint =>
      '3 deneme yapın ve en iyi sıçramayı kaydedin. LSI ≥ %90 spora dönüş için optimal eşik değeridir.';

  @override
  String get rtsHopAffected => 'Etkilenen taraf (cm)';

  @override
  String get rtsHopHealthy => 'Sağlıklı taraf (cm)';

  @override
  String rtsHopDetailValue(String affected, String healthy, String percent) {
    return 'Etkilenen: $affected cm / Sağlıklı: $healthy cm → LSI: $percent';
  }

  @override
  String get rtsTestTugTitle => 'Kalk ve Yürü Testi (TUG)';

  @override
  String get rtsTestTugDesc =>
      'Bir sandalyeden kalkın, 3 metre yürüyün, geri dönün ve oturun. Toplam süreyi ölçün.';

  @override
  String get rtsTestTugHint =>
      'Kronometre düğmesini kullanın veya süreyi manuel girin. 10 saniyenin altı mükemmel kabul edilir.';

  @override
  String rtsTugDetailValue(String seconds) {
    return '$seconds saniye';
  }

  @override
  String get rtsTimerStart => 'Kronometre Başlat';

  @override
  String get rtsTimerStop => 'Durdur';

  @override
  String get rtsTimerReset => 'Sıfırla';

  @override
  String get rtsTimerRestart => 'Yeniden Başlat';

  @override
  String get rtsTimerOrManual => 'Veya manuel girin:';

  @override
  String get rtsTimerManualLabel => 'Saniye cinsinden süre';

  @override
  String get rtsScoreTrend => 'Puan Trendi';

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
