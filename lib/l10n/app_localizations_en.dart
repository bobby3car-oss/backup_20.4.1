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
  String get tabStart => 'Today';

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
  String get agbTermsLink => 'Terms of Service';

  @override
  String get agbAndConnector => ' and ';

  @override
  String get agbPrivacyLink => 'Privacy Policy';

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
  String get settingsProSubtitle => 'Subscription & Restore';

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

  @override
  String get connectivityOfflineBanner =>
      'You are offline. Changes will be synced once you are back online.';

  @override
  String get connectivityRequiredTitle => 'No internet connection';

  @override
  String get connectivityRequiredMessage =>
      'This feature requires an internet connection. Please connect to the internet and try again.';

  @override
  String get staffTeam => 'Team';

  @override
  String get staffInvite => 'Invite';

  @override
  String get staffInviteTitle => 'Invite staff member';

  @override
  String get staffInviteSubtitle => 'Share this code with your staff member';

  @override
  String get staffInviteValid => 'Valid for 7 days';

  @override
  String get staffInviteCopy => 'Copy';

  @override
  String get staffInviteShare => 'Share';

  @override
  String get staffInviteCodeLabel => 'Invite code';

  @override
  String get staffAcceptTitle => 'Staff invitation';

  @override
  String get staffAcceptCodeHint => 'ENTER CODE';

  @override
  String get staffAcceptSubmit => 'Redeem code';

  @override
  String get staffAcceptSuccess => 'Welcome to the team!';

  @override
  String get staffAcceptSuccessBody =>
      'You are now registered as a staff member.\nRestart the app to see the dashboard.';

  @override
  String get staffAcceptDone => 'Done';

  @override
  String get staffRevokedTitle => 'Access revoked';

  @override
  String get staffRevokedBody =>
      'Your staff access has been deactivated. Please contact your doctor.';

  @override
  String get staffPermissionsTitle => 'Permissions';

  @override
  String get staffPermissionsSave => 'Save';

  @override
  String get staffRemoveTitle => 'Remove staff member';

  @override
  String get staffRemoveConfirm => 'Really remove?';

  @override
  String get staffRemoveAction => 'Remove';

  @override
  String get staffEmptyTitle => 'No team yet';

  @override
  String get staffEmptySubtitle =>
      'Invite your staff members to share your practice dashboard.';

  @override
  String get staffRole => 'Staff member';

  @override
  String get staffPractice => 'Practice';

  @override
  String get staffMyPermissions => 'My permissions';

  @override
  String get staffAccessNone => 'No access';

  @override
  String get staffAccessRead => 'Read';

  @override
  String get staffAccessReadWrite => 'Read & Write';

  @override
  String get staffPendingInvites => 'Pending invites';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Let\'s go';

  @override
  String get onboardingSlide1Title => 'Your digital\nsurgery companion';

  @override
  String get onboardingSlide1Subtitle =>
      'All information about your procedure –\nsafe and organized in one place.';

  @override
  String get onboardingSlide1Feature1 => 'Step-by-step guidance';

  @override
  String get onboardingSlide1Feature2 => 'Designed for patients';

  @override
  String get onboardingSlide1Feature3 => 'Everything in one place';

  @override
  String get onboardingSlide2Title => 'Your surgery\nat a glance';

  @override
  String get onboardingSlide2Subtitle =>
      'From preparation to aftercare –\neverything clearly planned.';

  @override
  String get onboardingSlide2Feature1 => 'Preparation checklist';

  @override
  String get onboardingSlide2Feature2 => 'Packing list for the clinic';

  @override
  String get onboardingSlide2Feature3 => 'All appointments at a glance';

  @override
  String get onboardingSlide3Title => 'Track your\nhealth';

  @override
  String get onboardingSlide3Subtitle =>
      'Keep an eye on your vitals\nand symptoms at all times.';

  @override
  String get onboardingSlide3Feature1 => 'Vitals & pulse';

  @override
  String get onboardingSlide3Feature2 => 'Pain diary';

  @override
  String get onboardingSlide3Feature3 => 'Symptom check';

  @override
  String get onboardingSlide4Title => 'Your wound\nhealing';

  @override
  String get onboardingSlide4Subtitle =>
      'Document your healing progress\nwith photos and comparisons.';

  @override
  String get onboardingSlide4Feature1 => 'Photo documentation';

  @override
  String get onboardingSlide4Feature2 => 'Comparison feature';

  @override
  String get onboardingSlide4Feature3 => 'Smart suggestions';

  @override
  String get onboardingSlide5Title => 'Connected with\nyour team';

  @override
  String get onboardingSlide5Subtitle =>
      'Involve family members and share\nimportant information with your doctor.';

  @override
  String get onboardingSlide5Feature1 => 'Invite family members';

  @override
  String get onboardingSlide5Feature2 => 'Share medical reports';

  @override
  String get onboardingSlide5Feature3 => 'Direct communication';

  @override
  String get authSlideTitle => 'Ready to get started?';

  @override
  String get authSlideSubtitle =>
      'Create your account or sign in\nto start your surgery companion.';

  @override
  String get authSlideRegister => 'Register now';

  @override
  String get authSlideLogin => 'Sign in';

  @override
  String get authSlideDoctorRegister => 'Register as doctor';

  @override
  String get authSlideGuestMode => 'Try app without account';

  @override
  String get loginWelcomeBack => 'Welcome\nback';

  @override
  String get loginSubtitle => 'Sign in with your account.';

  @override
  String get loginPasswordResetSent =>
      'If an account exists, a reset email has been sent.';

  @override
  String get loginEnterEmailFirst => 'Please enter your email first.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginQuickLogin => 'Quick login';

  @override
  String get loginQuickLoginHint => 'Available after first login';

  @override
  String get doctorRegTitle => 'Doctor registration';

  @override
  String get doctorRegRoleBadge => 'Access for physicians';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'After registration, our team will verify your details.';

  @override
  String get doctorRegPersonalData => 'Personal data';

  @override
  String get doctorRegNameHint => 'Dr. John Smith';

  @override
  String get doctorRegServiceEmail => 'Work email';

  @override
  String get doctorRegEmailHint => 'doctor@clinic.com';

  @override
  String get doctorRegEmailRequired => 'Enter email';

  @override
  String get doctorRegEmailInvalid => 'Enter a valid email';

  @override
  String get doctorRegPasswordMin8 => 'At least 8 characters';

  @override
  String get doctorRegProfessionalData => 'Professional details';

  @override
  String get doctorRegSpecialty => 'Specialty';

  @override
  String get doctorRegSelectSpecialty => 'Select specialty';

  @override
  String get doctorRegSpecialtyRequired => 'Please select a specialty';

  @override
  String get doctorRegApprobation => 'Medical license number';

  @override
  String get doctorRegApprobationHint => 'Your medical license number';

  @override
  String get doctorRegApprobationRequired => 'Enter license number';

  @override
  String get doctorRegPractice => 'Practice / Clinic';

  @override
  String get doctorRegPracticeHint => 'Name of practice or clinic';

  @override
  String get doctorRegPracticeRequired => 'Enter practice/clinic';

  @override
  String get doctorRegKvNumber => 'Insurance number (optional)';

  @override
  String get doctorRegKvHint => 'If available';

  @override
  String get doctorRegSubmitting => 'Sending…';

  @override
  String get doctorRegSubmit => 'Request access';

  @override
  String get doctorRegDisclaimer =>
      'Your information is treated confidentially and used exclusively for verification.';

  @override
  String get medicalDisclaimer =>
      'This app is not a medical device and does not replace professional medical treatment.';
}
