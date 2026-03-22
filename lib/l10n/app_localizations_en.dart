// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabStart => 'Home';

  @override
  String get tabAppointments => 'Appointments';

  @override
  String get tabMore => 'More';

  @override
  String get commonBack => 'OK';

  @override
  String get or => 'or';

  @override
  String get connectivityOfflineBanner =>
      'You are offline. Changes will be synced once you are back online.';

  @override
  String get connectivityRequiredTitle => 'No Internet Connection';

  @override
  String get connectivityRequiredMessage =>
      'This feature requires an internet connection. Please connect and try again.';

  @override
  String get syncIndicatorSynced => 'All synced';

  @override
  String syncIndicatorSyncing(int count) {
    return '$count entries waiting to sync';
  }

  @override
  String get syncIndicatorOffline => 'Offline';

  @override
  String syncIndicatorOfflineWithCount(int count) {
    return 'Offline – $count entries waiting to sync';
  }

  @override
  String get syncIndicatorTitle => 'Synchronisation';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSlide1Title => 'Welcome to Operationsbegleiter';

  @override
  String get onboardingSlide1Subtitle =>
      'Your personal companion before and after surgery';

  @override
  String get onboardingSlide1Feature1 =>
      'All important information at a glance';

  @override
  String get onboardingSlide1Feature2 => 'Personal checklists for your surgery';

  @override
  String get onboardingSlide1Feature3 => 'Step-by-step through the process';

  @override
  String get onboardingSlide2Title => 'Preparation';

  @override
  String get onboardingSlide2Subtitle => 'Optimally prepared for surgery';

  @override
  String get onboardingSlide2Feature1 => 'Individual preparation plans';

  @override
  String get onboardingSlide2Feature2 => 'Reminders for important appointments';

  @override
  String get onboardingSlide2Feature3 => 'Manage documents digitally';

  @override
  String get onboardingSlide3Title => 'Aftercare';

  @override
  String get onboardingSlide3Subtitle => 'Support after your operation';

  @override
  String get onboardingSlide3Feature1 => 'Daily health checks';

  @override
  String get onboardingSlide3Feature2 => 'Medication reminders';

  @override
  String get onboardingSlide3Feature3 => 'Progress tracking';

  @override
  String get onboardingSlide4Title => 'Security';

  @override
  String get onboardingSlide4Subtitle => 'Your data is safe with us';

  @override
  String get onboardingSlide4Feature1 => 'End-to-end encryption';

  @override
  String get onboardingSlide4Feature2 => 'GDPR compliant';

  @override
  String get onboardingSlide4Feature3 => 'Data only on your device';

  @override
  String get onboardingSlide5Title => 'Ready?';

  @override
  String get onboardingSlide5Subtitle => 'Create your profile now';

  @override
  String get onboardingSlide5Feature1 => 'Register for free';

  @override
  String get onboardingSlide5Feature2 => 'Ready in a few minutes';

  @override
  String get onboardingSlide5Feature3 => 'Deletable at any time';

  @override
  String get authSlideTitle => 'Operationsbegleiter';

  @override
  String get authSlideSubtitle => 'Your personal companion for surgery';

  @override
  String get authSlideRegister => 'Register';

  @override
  String get authSlideLogin => 'Sign In';

  @override
  String get authSlideDoctorRegister => 'Register as Doctor / Organisation';

  @override
  String get authSlideGuestMode => 'Guest Mode';

  @override
  String get loginWelcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginEnterEmailFirst => 'Please enter your email address first.';

  @override
  String get loginPasswordResetSent => 'Password reset email has been sent.';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginWithApple => 'Sign in with Apple';

  @override
  String get noAccountYet => 'Don\'t have an account yet?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get createAccountSubtitle => 'Register to get started';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldRepeatPassword => 'Repeat Password';

  @override
  String get fieldFullName => 'Full Name';

  @override
  String get fieldBirthDate => 'Date of Birth';

  @override
  String get fieldBirthDateHint => 'DD.MM.YYYY';

  @override
  String get fieldBirthDatePicker => 'Select date of birth';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address.';

  @override
  String get validationPasswordMin6 =>
      'Password must be at least 6 characters long.';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match.';

  @override
  String get validationNameRequired => 'Please enter your name.';

  @override
  String get validationBirthDateRequired => 'Please enter your date of birth.';

  @override
  String get validationRepeatPassword => 'Please repeat the password.';

  @override
  String get datePickerCancel => 'Cancel';

  @override
  String get datePickerConfirm => 'Confirm';

  @override
  String get agbAcceptPrefix => 'I accept the ';

  @override
  String get agbTermsLink => 'Terms of Service';

  @override
  String get agbAndConnector => ' and the ';

  @override
  String get agbPrivacyLink => 'Privacy Policy';

  @override
  String get languageLabel => 'Language';

  @override
  String get medicalDisclaimer =>
      'This app does not replace medical advice. For health concerns, please consult your doctor.';

  @override
  String get doctorRegTitle => 'Register as Doctor';

  @override
  String get doctorRegRoleBadge => 'Doctor';

  @override
  String get doctorRegRoleBadgeSubtitle => 'Verified medical professional';

  @override
  String get doctorRegPersonalData => 'Personal Data';

  @override
  String get doctorRegProfessionalData => 'Professional Data';

  @override
  String get doctorRegNameHint => 'Dr. John Doe';

  @override
  String get doctorRegEmailHint => 'doctor@practice.com';

  @override
  String get doctorRegEmailRequired => 'Please enter your email address.';

  @override
  String get doctorRegEmailInvalid => 'Please enter a valid email address.';

  @override
  String get doctorRegPasswordMin8 =>
      'Password must be at least 8 characters long.';

  @override
  String get doctorRegSpecialty => 'Specialty';

  @override
  String get doctorRegSelectSpecialty => 'Select specialty';

  @override
  String get doctorRegApprobation => 'Medical License Number';

  @override
  String get doctorRegApprobationHint => 'e.g. 12345678';

  @override
  String get doctorRegApprobationRequired =>
      'Please enter your medical license number.';

  @override
  String get doctorRegKvNumber => 'KV Number';

  @override
  String get doctorRegKvHint => 'Optional';

  @override
  String get doctorRegPractice => 'Practice / Clinic';

  @override
  String get doctorRegPracticeHint => 'Name of practice or clinic';

  @override
  String get doctorRegPracticeRequired => 'Please enter your practice.';

  @override
  String get doctorRegServiceEmail => 'Professional email address';

  @override
  String get doctorRegDisclaimer =>
      'Your details will be reviewed and your account activated after successful verification.';

  @override
  String get doctorRegSubmit => 'Submit Registration';

  @override
  String get doctorRegSubmitting => 'Submitting…';

  @override
  String get orgRegTitle => 'Register as Organisation';

  @override
  String get orgRegRoleBadge => 'Organisation';

  @override
  String get orgRegRoleBadgeSubtitle =>
      'Hospitals, clinics & rehabilitation facilities';

  @override
  String get orgRegGeneralData => 'General Data';

  @override
  String get orgRegOrgData => 'Organisation Data';

  @override
  String get orgRegOrgName => 'Organisation Name';

  @override
  String get orgRegOrgNameHint => 'e.g. University Hospital';

  @override
  String get orgRegNameRequired => 'Please enter the organisation name.';

  @override
  String get orgRegOrgType => 'Organisation Type';

  @override
  String get orgRegSelectOrgType => 'Select organisation type';

  @override
  String get orgRegAddress => 'Address';

  @override
  String get orgRegAddressHint => 'Street, Postcode, City';

  @override
  String get orgRegAddressRequired => 'Please enter the address.';

  @override
  String get orgRegContactPerson => 'Contact Person';

  @override
  String get orgRegContactPersonHint => 'First and last name';

  @override
  String get orgRegContactPersonRequired => 'Please enter a contact person.';

  @override
  String get orgRegEmail => 'Organisation Email';

  @override
  String get orgRegEmailHint => 'info@organisation.com';

  @override
  String get orgRegPhone => 'Phone';

  @override
  String get orgRegPhoneHint => '+49 123 456789';

  @override
  String get orgRegDisclaimer =>
      'Your details will be reviewed and your account activated after successful verification.';

  @override
  String get orgRegSubmit => 'Submit Registration';

  @override
  String get orgRegSubmitting => 'Submitting…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNotAvailable => 'Settings not available';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPush => 'Push Notifications';

  @override
  String get settingsEmailNotif => 'Email Notifications';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExportData => 'Export Data';

  @override
  String get settingsResetData => 'Reset Data';

  @override
  String get settingsPro => 'Pro Version';

  @override
  String get settingsProStatus => 'Pro Status';

  @override
  String get settingsProSubtitle => 'Unlock all features';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsImprint => 'Imprint';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsVersion => 'Version';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialFinish => 'Done';

  @override
  String get tutorialNeverShow => 'Don\'t show again';

  @override
  String get tutorialStep1Title => 'Welcome';

  @override
  String get tutorialStep1Desc =>
      'Here you\'ll find everything important about your surgery at a glance.';

  @override
  String get tutorialStep2Title => 'Appointments';

  @override
  String get tutorialStep2Desc =>
      'Manage your doctor\'s appointments and surgery preparations.';

  @override
  String get tutorialStep3Title => 'Checklists';

  @override
  String get tutorialStep3Desc =>
      'Work through your personal tasks step by step.';

  @override
  String get tutorialStep4Title => 'Discover More';

  @override
  String get tutorialStep4Desc =>
      'Under \'More\' you\'ll find settings, help and additional features.';

  @override
  String get profileCompleteness => 'Profile Completeness';

  @override
  String get profileStillTodo => 'Still to do';

  @override
  String get profileMoreItems => 'more';

  @override
  String get profileComplete => 'Complete Profile';

  @override
  String get profileCheckName => 'Enter name';

  @override
  String get profileCheckOpDate => 'Enter surgery date';

  @override
  String get profileCheckOpType => 'Select surgery type';

  @override
  String get profileCheckDoctor => 'Enter treating doctor';

  @override
  String get profileCheckHospital => 'Enter hospital';

  @override
  String get profileCheckHeight => 'Enter height';

  @override
  String get profileCheckWeight => 'Enter weight';

  @override
  String get profileCheckEmergencyContact => 'Add emergency contact';

  @override
  String get doctorRegSpecialtyRequired => 'Please select a specialty.';
}
