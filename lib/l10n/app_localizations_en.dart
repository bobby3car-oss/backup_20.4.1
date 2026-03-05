// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Surgery Companion';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageName => 'English';

  @override
  String get languageChangeTitle => 'Choose Language';

  @override
  String get tabStart => 'Home';

  @override
  String get tabAppointments => 'Appointments';

  @override
  String get tabDocuments => 'Documents';

  @override
  String get tabMore => 'More';

  @override
  String get login => 'Login';

  @override
  String get loginAction => 'Sign In';

  @override
  String get loginLoading => 'Signing In…';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String loginAppleFailed(String error) {
    return 'Apple Sign-In failed: $error';
  }

  @override
  String loginGoogleFailed(String error) {
    return 'Google Sign-In failed: $error';
  }

  @override
  String get loginWithApple => 'Sign in with Apple';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get or => 'or';

  @override
  String get noAccountYet => 'No account yet? Register';

  @override
  String get signupTitle => 'Registration';

  @override
  String get createAccountTitle => 'Create\nAccount';

  @override
  String get createAccountSubtitle => 'Fill in the fields to get started.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get creatingAccount => 'Creating Account…';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldFullName => 'Full Name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldConfirmPassword => 'Confirm Password';

  @override
  String get fieldRepeatPassword => 'Repeat Password';

  @override
  String get fieldBirthDate => 'Date of Birth';

  @override
  String get fieldBirthDateHint => 'DD.MM.YYYY';

  @override
  String get fieldBirthDatePicker => 'Choose date of birth';

  @override
  String get validationNameRequired => 'Please enter your name';

  @override
  String get validationEmailInvalid => 'Please enter a valid email';

  @override
  String get validationBirthDateRequired => 'Please choose your date of birth';

  @override
  String get validationPasswordMin6 => 'At least 6 characters';

  @override
  String get validationRepeatPassword => 'Please repeat password';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match';

  @override
  String get validationPasswordsMismatchLegacy => 'Passwords do not match.';

  @override
  String get errorEmailInUse => 'This email is already in use.';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get errorWeakPassword => 'The password is too weak.';

  @override
  String errorRegistrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get agbAcceptPrefix => 'I accept the ';

  @override
  String get agbAcceptLink => 'Terms and Privacy Policy';

  @override
  String get datePickerCancel => 'Cancel';

  @override
  String get datePickerConfirm => 'Confirm';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotAvailable => 'Not available';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPush => 'Push';

  @override
  String get settingsEmailNotif => 'Email';

  @override
  String get settingsPlaceholder => 'Placeholder – coming soon';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExportData => 'Export Data';

  @override
  String get settingsExportPlaceholder => 'Export coming soon';

  @override
  String get settingsExportSnack => 'Export is coming next';

  @override
  String get settingsResetData => 'Reset Data';

  @override
  String get settingsResetPlaceholder => 'Reset coming soon';

  @override
  String get settingsResetSnack => 'Reset is coming next';

  @override
  String get settingsPro => 'Pro';

  @override
  String get settingsProStatus => 'Pro Status';

  @override
  String get settingsProSubtitle => 'Subscription, Restore & Pro Key';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsImprint => 'Imprint';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsTerms => 'Terms';

  @override
  String get settingsTermsPlaceholder => 'Terms screen coming soon';

  @override
  String get settingsTermsSnack => 'Terms coming next';

  @override
  String get settingsVersion => 'Version';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonLoading => 'Loading…';

  @override
  String commonError(String error) {
    return 'Error: $error';
  }

  @override
  String get commonInProgress => 'In Progress';

  @override
  String get commonUnnamed => 'Unnamed';

  @override
  String get commonPatients => 'Patients';

  @override
  String get commonNoPatientsYet => 'No patients yet. Tap + to add one';

  @override
  String commonPatientOpened(String name) {
    return 'Patient opened: $name';
  }
}
