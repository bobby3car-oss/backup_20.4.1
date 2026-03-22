// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tabStart => 'Start';

  @override
  String get tabAppointments => 'Termine';

  @override
  String get tabMore => 'Mehr';

  @override
  String get commonBack => 'OK';

  @override
  String get or => 'oder';

  @override
  String get connectivityOfflineBanner =>
      'Du bist offline. Änderungen werden synchronisiert, sobald du wieder online bist.';

  @override
  String get connectivityRequiredTitle => 'Keine Internetverbindung';

  @override
  String get connectivityRequiredMessage =>
      'Diese Funktion benötigt eine Internetverbindung. Bitte stelle eine Verbindung her und versuche es erneut.';

  @override
  String get syncIndicatorSynced => 'Alles synchronisiert';

  @override
  String syncIndicatorSyncing(int count) {
    return '$count Einträge warten auf Sync';
  }

  @override
  String get syncIndicatorOffline => 'Offline';

  @override
  String syncIndicatorOfflineWithCount(int count) {
    return 'Offline – $count Einträge warten auf Sync';
  }

  @override
  String get syncIndicatorTitle => 'Synchronisation';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingSlide1Title => 'Willkommen beim Operationsbegleiter';

  @override
  String get onboardingSlide1Subtitle =>
      'Dein persönlicher Begleiter vor und nach der OP';

  @override
  String get onboardingSlide1Feature1 => 'Alle wichtigen Infos auf einen Blick';

  @override
  String get onboardingSlide1Feature2 => 'Persönliche Checklisten für deine OP';

  @override
  String get onboardingSlide1Feature3 =>
      'Schritt für Schritt durch den Prozess';

  @override
  String get onboardingSlide2Title => 'Vorbereitung';

  @override
  String get onboardingSlide2Subtitle => 'Optimal vorbereitet in die OP';

  @override
  String get onboardingSlide2Feature1 => 'Individuelle Vorbereitungspläne';

  @override
  String get onboardingSlide2Feature2 => 'Erinnerungen an wichtige Termine';

  @override
  String get onboardingSlide2Feature3 => 'Dokumente digital verwalten';

  @override
  String get onboardingSlide3Title => 'Nachsorge';

  @override
  String get onboardingSlide3Subtitle => 'Begleitung nach der Operation';

  @override
  String get onboardingSlide3Feature1 => 'Tägliche Gesundheitschecks';

  @override
  String get onboardingSlide3Feature2 => 'Medikamenten-Erinnerungen';

  @override
  String get onboardingSlide3Feature3 => 'Fortschritts-Tracking';

  @override
  String get onboardingSlide4Title => 'Sicherheit';

  @override
  String get onboardingSlide4Subtitle => 'Deine Daten sind bei uns sicher';

  @override
  String get onboardingSlide4Feature1 => 'Ende-zu-Ende-Verschlüsselung';

  @override
  String get onboardingSlide4Feature2 => 'DSGVO-konform';

  @override
  String get onboardingSlide4Feature3 => 'Daten nur auf deinem Gerät';

  @override
  String get onboardingSlide5Title => 'Bereit?';

  @override
  String get onboardingSlide5Subtitle => 'Erstelle jetzt dein Profil';

  @override
  String get onboardingSlide5Feature1 => 'Kostenlos registrieren';

  @override
  String get onboardingSlide5Feature2 => 'In wenigen Minuten startklar';

  @override
  String get onboardingSlide5Feature3 => 'Jederzeit löschbar';

  @override
  String get authSlideTitle => 'Operationsbegleiter';

  @override
  String get authSlideSubtitle => 'Dein persönlicher Begleiter für die OP';

  @override
  String get authSlideRegister => 'Registrieren';

  @override
  String get authSlideLogin => 'Anmelden';

  @override
  String get authSlideDoctorRegister => 'Als Arzt / Organisation registrieren';

  @override
  String get authSlideGuestMode => 'Gastmodus';

  @override
  String get loginWelcomeBack => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Melde dich an, um fortzufahren';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginEnterEmailFirst =>
      'Bitte gib zuerst deine E-Mail-Adresse ein.';

  @override
  String get loginPasswordResetSent =>
      'E-Mail zum Zurücksetzen des Passworts wurde gesendet.';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get loginWithApple => 'Mit Apple anmelden';

  @override
  String get noAccountYet => 'Noch kein Konto?';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createAccountTitle => 'Konto erstellen';

  @override
  String get createAccountSubtitle => 'Registriere dich, um loszulegen';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPassword => 'Passwort';

  @override
  String get fieldRepeatPassword => 'Passwort wiederholen';

  @override
  String get fieldFullName => 'Vollständiger Name';

  @override
  String get fieldBirthDate => 'Geburtsdatum';

  @override
  String get fieldBirthDateHint => 'TT.MM.JJJJ';

  @override
  String get fieldBirthDatePicker => 'Geburtsdatum auswählen';

  @override
  String get validationEmailInvalid =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get validationPasswordMin6 =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get validationPasswordsMismatch =>
      'Die Passwörter stimmen nicht überein.';

  @override
  String get validationNameRequired => 'Bitte gib deinen Namen ein.';

  @override
  String get validationBirthDateRequired => 'Bitte gib dein Geburtsdatum ein.';

  @override
  String get validationRepeatPassword => 'Bitte wiederhole das Passwort.';

  @override
  String get datePickerCancel => 'Abbrechen';

  @override
  String get datePickerConfirm => 'Bestätigen';

  @override
  String get agbAcceptPrefix => 'Ich akzeptiere die ';

  @override
  String get agbTermsLink => 'AGB';

  @override
  String get agbAndConnector => ' und die ';

  @override
  String get agbPrivacyLink => 'Datenschutzerklärung';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get medicalDisclaimer =>
      'Diese App ersetzt keine ärztliche Beratung. Bei gesundheitlichen Beschwerden wende dich an deinen Arzt.';

  @override
  String get doctorRegTitle => 'Als Arzt registrieren';

  @override
  String get doctorRegRoleBadge => 'Arzt';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'Verifizierter medizinischer Fachexperte';

  @override
  String get doctorRegPersonalData => 'Persönliche Daten';

  @override
  String get doctorRegProfessionalData => 'Berufliche Daten';

  @override
  String get doctorRegNameHint => 'Dr. Max Mustermann';

  @override
  String get doctorRegEmailHint => 'arzt@praxis.de';

  @override
  String get doctorRegEmailRequired => 'Bitte gib deine E-Mail-Adresse ein.';

  @override
  String get doctorRegEmailInvalid =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get doctorRegPasswordMin8 =>
      'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get doctorRegSpecialty => 'Fachrichtung';

  @override
  String get doctorRegSelectSpecialty => 'Fachrichtung auswählen';

  @override
  String get doctorRegApprobation => 'Approbationsnummer';

  @override
  String get doctorRegApprobationHint => 'z.B. 12345678';

  @override
  String get doctorRegApprobationRequired =>
      'Bitte gib deine Approbationsnummer ein.';

  @override
  String get doctorRegKvNumber => 'KV-Nummer';

  @override
  String get doctorRegKvHint => 'Optional';

  @override
  String get doctorRegPractice => 'Praxis / Klinik';

  @override
  String get doctorRegPracticeHint => 'Name der Praxis oder Klinik';

  @override
  String get doctorRegPracticeRequired => 'Bitte gib deine Praxis an.';

  @override
  String get doctorRegServiceEmail => 'Dienstliche E-Mail-Adresse';

  @override
  String get doctorRegDisclaimer =>
      'Ihre Angaben werden geprüft und Ihr Account nach erfolgreicher Verifizierung freigeschaltet.';

  @override
  String get doctorRegSubmit => 'Registrierung absenden';

  @override
  String get doctorRegSubmitting => 'Wird gesendet…';

  @override
  String get orgRegTitle => 'Als Organisation registrieren';

  @override
  String get orgRegRoleBadge => 'Organisation';

  @override
  String get orgRegRoleBadgeSubtitle =>
      'Krankenhäuser, Kliniken & Rehabilitationseinrichtungen';

  @override
  String get orgRegGeneralData => 'Allgemeine Daten';

  @override
  String get orgRegOrgData => 'Organisationsdaten';

  @override
  String get orgRegOrgName => 'Organisationsname';

  @override
  String get orgRegOrgNameHint => 'z.B. Universitätsklinikum';

  @override
  String get orgRegNameRequired => 'Bitte gib den Organisationsnamen ein.';

  @override
  String get orgRegOrgType => 'Organisationstyp';

  @override
  String get orgRegSelectOrgType => 'Organisationstyp auswählen';

  @override
  String get orgRegAddress => 'Adresse';

  @override
  String get orgRegAddressHint => 'Straße, PLZ, Ort';

  @override
  String get orgRegAddressRequired => 'Bitte gib die Adresse ein.';

  @override
  String get orgRegContactPerson => 'Ansprechpartner';

  @override
  String get orgRegContactPersonHint => 'Vor- und Nachname';

  @override
  String get orgRegContactPersonRequired =>
      'Bitte gib einen Ansprechpartner an.';

  @override
  String get orgRegEmail => 'Organisations-E-Mail';

  @override
  String get orgRegEmailHint => 'info@organisation.de';

  @override
  String get orgRegPhone => 'Telefon';

  @override
  String get orgRegPhoneHint => '+49 123 456789';

  @override
  String get orgRegDisclaimer =>
      'Ihre Angaben werden geprüft und Ihr Account nach erfolgreicher Verifizierung freigeschaltet.';

  @override
  String get orgRegSubmit => 'Registrierung absenden';

  @override
  String get orgRegSubmitting => 'Wird gesendet…';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsNotAvailable => 'Einstellungen nicht verfügbar';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsPush => 'Push-Benachrichtigungen';

  @override
  String get settingsEmailNotif => 'E-Mail-Benachrichtigungen';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsExportData => 'Daten exportieren';

  @override
  String get settingsResetData => 'Daten zurücksetzen';

  @override
  String get settingsPro => 'Pro-Version';

  @override
  String get settingsProStatus => 'Pro-Status';

  @override
  String get settingsProSubtitle => 'Alle Funktionen freischalten';

  @override
  String get settingsLegal => 'Rechtliches';

  @override
  String get settingsImprint => 'Impressum';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsTerms => 'AGB';

  @override
  String get settingsVersion => 'Version';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get tutorialNext => 'Weiter';

  @override
  String get tutorialFinish => 'Fertig';

  @override
  String get tutorialNeverShow => 'Nicht mehr anzeigen';

  @override
  String get tutorialStep1Title => 'Willkommen';

  @override
  String get tutorialStep1Desc =>
      'Hier findest du alles Wichtige zu deiner OP auf einen Blick.';

  @override
  String get tutorialStep2Title => 'Termine';

  @override
  String get tutorialStep2Desc =>
      'Verwalte deine Arzttermine und OP-Vorbereitungen.';

  @override
  String get tutorialStep3Title => 'Checklisten';

  @override
  String get tutorialStep3Desc =>
      'Arbeite Schritt für Schritt deine persönlichen Aufgaben ab.';

  @override
  String get tutorialStep4Title => 'Mehr entdecken';

  @override
  String get tutorialStep4Desc =>
      'Unter \'Mehr\' findest du Einstellungen, Hilfe und weitere Funktionen.';

  @override
  String get profileCompleteness => 'Profilvollständigkeit';

  @override
  String get profileStillTodo => 'Noch zu erledigen';

  @override
  String get profileMoreItems => 'weitere';

  @override
  String get profileComplete => 'Profil vervollständigen';

  @override
  String get profileCheckName => 'Name angeben';

  @override
  String get profileCheckOpDate => 'OP-Datum eintragen';

  @override
  String get profileCheckOpType => 'OP-Art auswählen';

  @override
  String get profileCheckDoctor => 'Behandelnden Arzt angeben';

  @override
  String get profileCheckHospital => 'Krankenhaus angeben';

  @override
  String get profileCheckHeight => 'Größe angeben';

  @override
  String get profileCheckWeight => 'Gewicht angeben';

  @override
  String get profileCheckEmergencyContact => 'Notfallkontakt hinterlegen';

  @override
  String get doctorRegSpecialtyRequired => 'Bitte wähle eine Fachrichtung aus.';
}
