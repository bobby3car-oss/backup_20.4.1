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
  String get tabStart => 'Bugün';

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
  String get agbTermsLink => 'Kullanım Koşulları';

  @override
  String get agbAndConnector => ' ve ';

  @override
  String get agbPrivacyLink => 'Gizlilik Politikası';

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

  @override
  String get staffTeam => 'TODO:tr: Team';

  @override
  String get staffInvite => 'TODO:tr: Einladen';

  @override
  String get staffInviteTitle => 'TODO:tr: Mitarbeiter einladen';

  @override
  String get staffInviteSubtitle =>
      'TODO:tr: Teilen Sie diesen Code mit Ihrem/Ihrer Mitarbeiter/in';

  @override
  String get staffInviteValid => 'TODO:tr: Gültig für 7 Tage';

  @override
  String get staffInviteCopy => 'TODO:tr: Kopieren';

  @override
  String get staffInviteShare => 'TODO:tr: Teilen';

  @override
  String get staffInviteCodeLabel => 'TODO:tr: Einladungscode';

  @override
  String get staffAcceptTitle => 'TODO:tr: Mitarbeiter-Einladung';

  @override
  String get staffAcceptCodeHint => 'TODO:tr: CODE EINGEBEN';

  @override
  String get staffAcceptSubmit => 'TODO:tr: Code einlösen';

  @override
  String get staffAcceptSuccess => 'TODO:tr: Willkommen im Team!';

  @override
  String get staffAcceptSuccessBody =>
      'TODO:tr: Sie sind jetzt als Mitarbeiter/in registriert.\nStarten Sie die App neu, um das Dashboard zu sehen.';

  @override
  String get staffAcceptDone => 'TODO:tr: Fertig';

  @override
  String get staffRevokedTitle => 'TODO:tr: Zugang widerrufen';

  @override
  String get staffRevokedBody =>
      'TODO:tr: Ihr Mitarbeiter-Zugang wurde deaktiviert. Bitte wenden Sie sich an Ihren Arzt.';

  @override
  String get staffPermissionsTitle => 'TODO:tr: Berechtigungen';

  @override
  String get staffPermissionsSave => 'TODO:tr: Speichern';

  @override
  String get staffRemoveTitle => 'TODO:tr: Mitarbeiter entfernen';

  @override
  String get staffRemoveConfirm => 'TODO:tr: Wirklich entfernen?';

  @override
  String get staffRemoveAction => 'TODO:tr: Entfernen';

  @override
  String get staffEmptyTitle => 'TODO:tr: Noch kein Team';

  @override
  String get staffEmptySubtitle =>
      'TODO:tr: Laden Sie Ihre Mitarbeitenden ein, um Ihr Praxis-Dashboard zu teilen.';

  @override
  String get staffRole => 'TODO:tr: Mitarbeiter/in';

  @override
  String get staffPractice => 'TODO:tr: Praxis';

  @override
  String get staffMyPermissions => 'TODO:tr: Meine Berechtigungen';

  @override
  String get staffAccessNone => 'TODO:tr: Kein Zugriff';

  @override
  String get staffAccessRead => 'TODO:tr: Lesen';

  @override
  String get staffAccessReadWrite => 'TODO:tr: Lesen & Schreiben';

  @override
  String get staffPendingInvites => 'TODO:tr: Offene Einladungen';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingGetStarted => 'Haydi başlayalım';

  @override
  String get onboardingSlide1Title => 'Dijital ameliyat\nrehberiniz';

  @override
  String get onboardingSlide1Subtitle =>
      'Ameliyatınıza dair tüm bilgiler –\ngüvenli ve düzenli bir arada.';

  @override
  String get onboardingSlide1Feature1 => 'Adım adım rehberlik';

  @override
  String get onboardingSlide1Feature2 => 'Hastalar için tasarlandı';

  @override
  String get onboardingSlide1Feature3 => 'Her şey tek yerde';

  @override
  String get onboardingSlide2Title => 'Ameliyatınız\nbir bakışta';

  @override
  String get onboardingSlide2Subtitle =>
      'Hazırlıktan bakıma kadar –\nher şey düzenli planlandı.';

  @override
  String get onboardingSlide2Feature1 => 'Hazırlık kontrol listesi';

  @override
  String get onboardingSlide2Feature2 => 'Klinik için bavul listesi';

  @override
  String get onboardingSlide2Feature3 => 'Tüm randevular bir bakışta';

  @override
  String get onboardingSlide3Title => 'Sağlığınızı\ntakip edin';

  @override
  String get onboardingSlide3Subtitle =>
      'Vital değerlerinizi ve semptomlarınızı\nher zaman takip edin.';

  @override
  String get onboardingSlide3Feature1 => 'Vital değerler ve nabız';

  @override
  String get onboardingSlide3Feature2 => 'Ağrı günlüğü';

  @override
  String get onboardingSlide3Feature3 => 'Semptom kontrolü';

  @override
  String get onboardingSlide4Title => 'Yara\niyileşmeniz';

  @override
  String get onboardingSlide4Subtitle =>
      'İyileşme sürecinizi\nfotoğraflar ve karşılaştırmalarla belgeleyin.';

  @override
  String get onboardingSlide4Feature1 => 'Fotoğraf belgeleme';

  @override
  String get onboardingSlide4Feature2 => 'Karşılaştırma özelliği';

  @override
  String get onboardingSlide4Feature3 => 'Akıllı öneriler';

  @override
  String get onboardingSlide5Title => 'Ekibinizle\nbağlantıda';

  @override
  String get onboardingSlide5Subtitle =>
      'Yakınlarınızı dahil edin ve\nönemli bilgileri doktorunuzla paylaşın.';

  @override
  String get onboardingSlide5Feature1 => 'Yakınları davet et';

  @override
  String get onboardingSlide5Feature2 => 'Doktor raporlarını paylaş';

  @override
  String get onboardingSlide5Feature3 => 'Doğrudan iletişim';

  @override
  String get authSlideTitle => 'Başlamaya hazır mısınız?';

  @override
  String get authSlideSubtitle =>
      'Hesabınızı oluşturun veya giriş yapın\nameliyat rehberinizi başlatmak için.';

  @override
  String get authSlideRegister => 'Şimdi kayıt ol';

  @override
  String get authSlideLogin => 'Giriş yap';

  @override
  String get authSlideDoctorRegister => 'Doktor olarak kayıt ol';

  @override
  String get authSlideGuestMode => 'Hesapsız deneyin';

  @override
  String get loginWelcomeBack => 'Tekrar\nhoş geldiniz';

  @override
  String get loginSubtitle => 'Hesabınızla giriş yapın.';

  @override
  String get loginPasswordResetSent =>
      'Hesap varsa sıfırlama e-postası gönderildi.';

  @override
  String get loginEnterEmailFirst => 'Lütfen önce e-postanızı girin.';

  @override
  String get loginForgotPassword => 'Şifreyi unuttunuz mu?';

  @override
  String get loginQuickLogin => 'Hızlı giriş';

  @override
  String get loginQuickLoginHint => 'İlk girişten sonra kullanılabilir';

  @override
  String get doctorRegTitle => 'Doktor kaydı';

  @override
  String get doctorRegRoleBadge => 'Doktorlar için erişim';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'Kayıt sonrası ekibimiz bilgilerinizi doğrulayacaktır.';

  @override
  String get doctorRegPersonalData => 'Kişisel veriler';

  @override
  String get doctorRegNameHint => 'Dr. Ahmet Yılmaz';

  @override
  String get doctorRegServiceEmail => 'İş e-postası';

  @override
  String get doctorRegEmailHint => 'doktor@klinik.com';

  @override
  String get doctorRegEmailRequired => 'E-posta girin';

  @override
  String get doctorRegEmailInvalid => 'Geçerli bir e-posta girin';

  @override
  String get doctorRegPasswordMin8 => 'En az 8 karakter';

  @override
  String get doctorRegProfessionalData => 'Mesleki bilgiler';

  @override
  String get doctorRegSpecialty => 'Uzmanlık';

  @override
  String get doctorRegSelectSpecialty => 'Uzmanlık seçin';

  @override
  String get doctorRegSpecialtyRequired => 'Lütfen bir uzmanlık seçin';

  @override
  String get doctorRegApprobation => 'Tıbbi lisans numarası';

  @override
  String get doctorRegApprobationHint => 'Tıbbi lisans numaranız';

  @override
  String get doctorRegApprobationRequired => 'Lisans numarası girin';

  @override
  String get doctorRegPractice => 'Muayenehane / Klinik';

  @override
  String get doctorRegPracticeHint => 'Muayenehane veya klinik adı';

  @override
  String get doctorRegPracticeRequired => 'Muayenehane/klinik girin';

  @override
  String get doctorRegKvNumber => 'Sigorta numarası (opsiyonel)';

  @override
  String get doctorRegKvHint => 'Varsa';

  @override
  String get doctorRegSubmitting => 'Gönderiliyor…';

  @override
  String get doctorRegSubmit => 'Erişim talep et';

  @override
  String get doctorRegDisclaimer =>
      'Bilgileriniz gizli tutulacak ve yalnızca doğrulama için kullanılacaktır.';

  @override
  String get medicalDisclaimer =>
      'Bu uygulama tıbbi bir cihaz değildir ve tıbbi tedavinin yerini almaz.';
}
