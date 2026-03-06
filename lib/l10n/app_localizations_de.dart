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
  String get tabStart => 'Start';

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
  String get settingsPlaceholder => 'Platzhalter – wird noch implementiert';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsExportData => 'Daten exportieren';

  @override
  String get settingsExportPlaceholder => 'Export wird noch implementiert';

  @override
  String get settingsExportSnack => 'Export kommt als nächstes';

  @override
  String get settingsResetData => 'Daten zurücksetzen';

  @override
  String get settingsResetPlaceholder => 'Reset wird noch implementiert';

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
  String get settingsTermsPlaceholder => 'AGB-Screen wird noch ergänzt';

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
  String get commonInProgress => 'In Arbeit';

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
}
