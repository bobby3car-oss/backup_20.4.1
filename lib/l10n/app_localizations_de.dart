// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Operationsbegleiter';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get languageName => 'Deutsch';

  @override
  String get languageChangeTitle => 'Sprache wählen';

  @override
  String get tabStart => 'Heute';

  @override
  String get tabAppointments => 'Termine';

  @override
  String get tabDocuments => 'Dokumente';

  @override
  String get tabMore => 'Mehr';

  @override
  String get login => 'Login';

  @override
  String get loginAction => 'Anmelden';

  @override
  String get loginLoading => 'Anmelden…';

  @override
  String loginFailed(String error) {
    return 'Login fehlgeschlagen: $error';
  }

  @override
  String loginAppleFailed(String error) {
    return 'Apple-Login fehlgeschlagen: $error';
  }

  @override
  String loginGoogleFailed(String error) {
    return 'Google-Login fehlgeschlagen: $error';
  }

  @override
  String get loginWithApple => 'Mit Apple anmelden';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get or => 'oder';

  @override
  String get noAccountYet => 'Noch kein Konto? Registrieren';

  @override
  String get signupTitle => 'Registrierung';

  @override
  String get createAccountTitle => 'Konto\nerstellen';

  @override
  String get createAccountSubtitle => 'Fülle die Felder aus, um loszulegen.';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get creatingAccount => 'Erstelle Konto…';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldFullName => 'Vollständiger Name';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPassword => 'Passwort';

  @override
  String get fieldConfirmPassword => 'Passwort bestätigen';

  @override
  String get fieldRepeatPassword => 'Passwort wiederholen';

  @override
  String get fieldBirthDate => 'Geburtsdatum';

  @override
  String get fieldBirthDateHint => 'TT.MM.JJJJ';

  @override
  String get fieldBirthDatePicker => 'Geburtsdatum wählen';

  @override
  String get validationNameRequired => 'Name eingeben';

  @override
  String get validationEmailInvalid => 'Gültige E‑Mail eingeben';

  @override
  String get validationBirthDateRequired => 'Geburtsdatum wählen';

  @override
  String get validationPasswordMin6 => 'Mindestens 6 Zeichen';

  @override
  String get validationRepeatPassword => 'Passwort wiederholen';

  @override
  String get validationPasswordsMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get validationPasswordsMismatchLegacy =>
      'Passwoerter stimmen nicht ueberein.';

  @override
  String get errorEmailInUse => 'Diese E‑Mail wird bereits verwendet.';

  @override
  String get errorInvalidEmail => 'Ungültige E‑Mail-Adresse.';

  @override
  String get errorWeakPassword => 'Das Passwort ist zu schwach.';

  @override
  String errorRegistrationFailed(String error) {
    return 'Registrierung fehlgeschlagen: $error';
  }

  @override
  String get agbAcceptPrefix => 'Ich akzeptiere die ';

  @override
  String get agbAcceptLink => 'AGB und Datenschutzerklärung';

  @override
  String get agbTermsLink => 'AGB';

  @override
  String get agbAndConnector => ' und ';

  @override
  String get agbPrivacyLink => 'Datenschutzerklärung';

  @override
  String get datePickerCancel => 'Abbrechen';

  @override
  String get datePickerConfirm => 'Übernehmen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotAvailable => 'Nicht verfügbar';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsPush => 'Push';

  @override
  String get settingsEmailNotif => 'E-Mail';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsExportData => 'Daten exportieren';

  @override
  String get settingsExportSnack => 'Export kommt als nächstes';

  @override
  String get settingsResetData => 'Daten zurücksetzen';

  @override
  String get settingsResetSnack => 'Reset kommt als nächstes';

  @override
  String get settingsPro => 'Pro';

  @override
  String get settingsProStatus => 'Pro Status';

  @override
  String get settingsProSubtitle => 'Abo & Wiederherstellen';

  @override
  String get settingsLegal => 'Rechtliches';

  @override
  String get settingsImprint => 'Impressum';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsTerms => 'AGB';

  @override
  String get settingsTermsSnack => 'AGB folgt im nächsten Schritt';

  @override
  String get settingsVersion => 'Version';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonLoading => 'Laden…';

  @override
  String commonError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get commonInProgress => 'Wird geladen…';

  @override
  String get commonUnnamed => 'Unbenannt';

  @override
  String get commonPatients => 'Patienten';

  @override
  String get commonNoPatientsYet => 'Noch keine Patienten. Tippe auf +';

  @override
  String commonPatientOpened(String name) {
    return 'Patient geöffnet: $name';
  }

  @override
  String get connectivityOfflineBanner =>
      'Du bist offline. Änderungen werden synchronisiert, sobald du wieder online bist.';

  @override
  String get connectivityRequiredTitle => 'Keine Internetverbindung';

  @override
  String get connectivityRequiredMessage =>
      'Diese Funktion benötigt eine Internetverbindung. Bitte stelle eine Verbindung her und versuche es erneut.';

  @override
  String get staffTeam => 'Team';

  @override
  String get staffInvite => 'Einladen';

  @override
  String get staffInviteTitle => 'Mitarbeiter einladen';

  @override
  String get staffInviteSubtitle =>
      'Teilen Sie diesen Code mit Ihrem/Ihrer Mitarbeiter/in';

  @override
  String get staffInviteValid => 'Gültig für 7 Tage';

  @override
  String get staffInviteCopy => 'Kopieren';

  @override
  String get staffInviteShare => 'Teilen';

  @override
  String get staffInviteCodeLabel => 'Einladungscode';

  @override
  String get staffAcceptTitle => 'Mitarbeiter-Einladung';

  @override
  String get staffAcceptCodeHint => 'CODE EINGEBEN';

  @override
  String get staffAcceptSubmit => 'Code einlösen';

  @override
  String get staffAcceptSuccess => 'Willkommen im Team!';

  @override
  String get staffAcceptSuccessBody =>
      'Sie sind jetzt als Mitarbeiter/in registriert.\nStarten Sie die App neu, um das Dashboard zu sehen.';

  @override
  String get staffAcceptDone => 'Fertig';

  @override
  String get staffRevokedTitle => 'Zugang widerrufen';

  @override
  String get staffRevokedBody =>
      'Ihr Mitarbeiter-Zugang wurde deaktiviert. Bitte wenden Sie sich an Ihren Arzt.';

  @override
  String get staffPermissionsTitle => 'Berechtigungen';

  @override
  String get staffPermissionsSave => 'Speichern';

  @override
  String get staffRemoveTitle => 'Mitarbeiter entfernen';

  @override
  String get staffRemoveConfirm => 'Wirklich entfernen?';

  @override
  String get staffRemoveAction => 'Entfernen';

  @override
  String get staffEmptyTitle => 'Noch kein Team';

  @override
  String get staffEmptySubtitle =>
      'Laden Sie Ihre Mitarbeitenden ein, um Ihr Praxis-Dashboard zu teilen.';

  @override
  String get staffRole => 'Mitarbeiter/in';

  @override
  String get staffPractice => 'Praxis';

  @override
  String get staffMyPermissions => 'Meine Berechtigungen';

  @override
  String get staffAccessNone => 'Kein Zugriff';

  @override
  String get staffAccessRead => 'Lesen';

  @override
  String get staffAccessReadWrite => 'Lesen & Schreiben';

  @override
  String get staffPendingInvites => 'Offene Einladungen';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingSlide1Title => 'Dein digitaler\nOP-Begleiter';

  @override
  String get onboardingSlide1Subtitle =>
      'Alle Informationen rund um deinen Eingriff –\nsicher und übersichtlich an einem Ort.';

  @override
  String get onboardingSlide1Feature1 => 'Schritt-für-Schritt Begleitung';

  @override
  String get onboardingSlide1Feature2 => 'Für Patienten entwickelt';

  @override
  String get onboardingSlide1Feature3 => 'Alles an einem Ort';

  @override
  String get onboardingSlide2Title => 'Deine OP\nim Überblick';

  @override
  String get onboardingSlide2Subtitle =>
      'Von der Vorbereitung bis zur Nachsorge –\nalles übersichtlich geplant.';

  @override
  String get onboardingSlide2Feature1 => 'Vorbereitungs-Checkliste';

  @override
  String get onboardingSlide2Feature2 => 'Packliste für die Klinik';

  @override
  String get onboardingSlide2Feature3 => 'Alle Termine im Blick';

  @override
  String get onboardingSlide3Title => 'Gesundheit\ntracken';

  @override
  String get onboardingSlide3Subtitle =>
      'Behalte deine Vitalwerte und Symptome\njederzeit im Auge.';

  @override
  String get onboardingSlide3Feature1 => 'Vitalwerte & Puls';

  @override
  String get onboardingSlide3Feature2 => 'Schmerztagebuch';

  @override
  String get onboardingSlide3Feature3 => 'Symptom-Check';

  @override
  String get onboardingSlide4Title => 'Deine\nWundheilung';

  @override
  String get onboardingSlide4Subtitle =>
      'Dokumentiere deinen Heilungsverlauf\nmit Fotos und Vergleichen.';

  @override
  String get onboardingSlide4Feature1 => 'Foto-Dokumentation';

  @override
  String get onboardingSlide4Feature2 => 'Vergleichs-Funktion';

  @override
  String get onboardingSlide4Feature3 => 'Intelligente Hinweise';

  @override
  String get onboardingSlide5Title => 'Vernetzt mit\ndeinem Team';

  @override
  String get onboardingSlide5Subtitle =>
      'Binde Angehörige ein und teile\nwichtige Informationen mit deinem Arzt.';

  @override
  String get onboardingSlide5Feature1 => 'Angehörige einladen';

  @override
  String get onboardingSlide5Feature2 => 'Arztberichte teilen';

  @override
  String get onboardingSlide5Feature3 => 'Direkte Kommunikation';

  @override
  String get authSlideTitle => 'Bereit loszulegen?';

  @override
  String get authSlideSubtitle =>
      'Erstelle dein Konto oder melde dich an,\num deine OP-Begleitung zu starten.';

  @override
  String get authSlideRegister => 'Jetzt registrieren';

  @override
  String get authSlideLogin => 'Anmelden';

  @override
  String get authSlideDoctorRegister => 'Als Arzt registrieren';

  @override
  String get authSlideGuestMode => 'App ohne Konto testen';

  @override
  String get loginWelcomeBack => 'Willkommen\nzurück';

  @override
  String get loginSubtitle => 'Melde dich mit deinem Konto an.';

  @override
  String get loginPasswordResetSent =>
      'Falls ein Konto existiert, wurde eine E‑Mail gesendet.';

  @override
  String get loginEnterEmailFirst => 'Bitte gib zuerst deine E‑Mail ein.';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginQuickLogin => 'Schnellanmeldung';

  @override
  String get loginQuickLoginHint => 'Verfügbar nach erstmaliger Anmeldung';

  @override
  String get doctorRegTitle => 'Arzt‑Registrierung';

  @override
  String get doctorRegRoleBadge => 'Zugang für Ärzt*innen';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'Nach der Registrierung prüft unser Team Ihre Angaben.';

  @override
  String get doctorRegPersonalData => 'Persönliche Daten';

  @override
  String get doctorRegNameHint => 'Dr. med. Max Mustermann';

  @override
  String get doctorRegServiceEmail => 'Dienst‑E‑Mail';

  @override
  String get doctorRegEmailHint => 'arzt@klinik.de';

  @override
  String get doctorRegEmailRequired => 'E‑Mail eingeben';

  @override
  String get doctorRegEmailInvalid => 'Gültige E‑Mail eingeben';

  @override
  String get doctorRegPasswordMin8 => 'Mindestens 8 Zeichen';

  @override
  String get doctorRegProfessionalData => 'Berufliche Angaben';

  @override
  String get doctorRegSpecialty => 'Fachrichtung';

  @override
  String get doctorRegSelectSpecialty => 'Fachrichtung wählen';

  @override
  String get doctorRegSpecialtyRequired => 'Bitte Fachrichtung wählen';

  @override
  String get doctorRegApprobation => 'Approbationsnummer';

  @override
  String get doctorRegApprobationHint => 'Ihre ärztliche Approbationsnummer';

  @override
  String get doctorRegApprobationRequired => 'Approbationsnummer eingeben';

  @override
  String get doctorRegPractice => 'Praxis / Klinik';

  @override
  String get doctorRegPracticeHint => 'Name der Praxis oder Klinik';

  @override
  String get doctorRegPracticeRequired => 'Praxis/Klinik eingeben';

  @override
  String get doctorRegKvNumber => 'KV‑Nummer (optional)';

  @override
  String get doctorRegKvHint => 'Falls vorhanden';

  @override
  String get doctorRegSubmitting => 'Wird gesendet …';

  @override
  String get doctorRegSubmit => 'Zugang beantragen';

  @override
  String get doctorRegDisclaimer =>
      'Ihre Angaben werden vertraulich behandelt und ausschließlich zur Verifizierung verwendet.';

  @override
  String get medicalDisclaimer =>
      'Diese App ist kein Medizinprodukt und ersetzt keine ärztliche Behandlung.';
}
