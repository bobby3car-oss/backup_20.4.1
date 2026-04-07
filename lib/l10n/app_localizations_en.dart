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
  String get authSlideTrustSignals =>
      'Free · No credit card · Ready in 30 seconds';

  @override
  String get authSlideSocialProof => '4.9 ★ · 2,500+ patients trust this app';

  @override
  String get registerContinueAsGuest => 'Continue without registration';

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
  String get tutorialStep1Title => 'Welcome! 👋';

  @override
  String get tutorialStep1Desc =>
      'Hi, I\'m Bella! Here you\'ll find everything important about your surgery at a glance.';

  @override
  String get tutorialStep2Title => 'Your Appointments';

  @override
  String get tutorialStep2Desc =>
      'Keep track of your doctor appointments and preparations – I\'ll remind you in time.';

  @override
  String get tutorialStep3Title => 'I\'m Always Here';

  @override
  String get tutorialStep3Desc =>
      'That\'s me! 🐰 Tap me anytime – I\'ll answer all your recovery questions.';

  @override
  String get tutorialStep4Title => 'Discover More';

  @override
  String get tutorialStep4Desc =>
      'Under \'More\' you\'ll find settings, help and additional useful features.';

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

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get send => 'Send';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get reset => 'Reset';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get unlock => 'Unlock';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get details => 'Details';

  @override
  String get info => 'Info';

  @override
  String get warning => 'Warning';

  @override
  String get urgent => 'Urgent';

  @override
  String get critical => 'Critical';

  @override
  String get high => 'High';

  @override
  String get low => 'Low';

  @override
  String get normal => 'Normal';

  @override
  String get minimal => 'Minimal';

  @override
  String get daily => 'Daily';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get everyNDays => 'Every N days';

  @override
  String get customDay => 'Custom day';

  @override
  String get repeatUntil => 'Repeat until';

  @override
  String get repetition => 'Repetition';

  @override
  String get recurring => 'Recurring';

  @override
  String get allDay => 'All day';

  @override
  String get notAvailable => 'Not available';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutConfirm => 'Sign out?';

  @override
  String get logoutAdminConfirm => 'Really sign out of the admin area?';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Register';

  @override
  String get accountRequired => 'Account required';

  @override
  String get passwordConfirm => 'Confirm password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get passwordReset => 'Reset password';

  @override
  String get passwordResetDone => 'Password has been reset';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get passwordMin6 => 'At least 6 characters';

  @override
  String newPasswordFor(String name) {
    return 'New password for $name';
  }

  @override
  String get deleteAccountTitle => 'Permanently delete account?';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteDataOnly => 'Delete data only';

  @override
  String get deleteFinal => 'Delete permanently';

  @override
  String get deleteUserAndData => 'User and all data deleted.';

  @override
  String get resetDataTitle => 'Reset data';

  @override
  String get allDataIrreversible => 'Remove all data irreversibly';

  @override
  String get guestDataFound => 'Local data found';

  @override
  String get guestDataDiscard => 'No, discard';

  @override
  String get guestDataTransfer => 'Yes, transfer';

  @override
  String get settingSaveError => 'Setting could not be saved.';

  @override
  String get settingSaved => 'Settings saved.';

  @override
  String get tutorialRepeat => 'Repeat tutorial';

  @override
  String get tutorialRepeatSubtitle => 'Show introduction again';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsActive => 'Notifications active';

  @override
  String get notificationsManage => 'Manage notifications';

  @override
  String notificationsCountNew(int count) {
    return 'Notifications ($count new)';
  }

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get adDisplays => 'Advertisements';

  @override
  String get usageStats => 'Usage statistics';

  @override
  String get crashReports => 'Crash reports';

  @override
  String get bellaAiAssistant => 'Bella AI Assistant';

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get exportAsPdfSubtitle => 'Clear overview report';

  @override
  String get exportAsJson => 'Export as JSON';

  @override
  String get exportAsJsonSubtitle => 'All raw data for archiving';

  @override
  String get exportCreating => 'Creating export…';

  @override
  String get exportPreparing => 'Preparing export…';

  @override
  String get csvExporting => 'Exporting CSV…';

  @override
  String get appointment => 'Appointment';

  @override
  String get appointmentCreate => 'Create appointment';

  @override
  String get appointmentAdd => 'Add appointment';

  @override
  String get appointmentConfirmed => 'Appointment confirmed';

  @override
  String get appointmentDeclined => 'Appointment declined';

  @override
  String get appointmentDeleteConfirm => 'Delete appointment?';

  @override
  String get appointmentSaveError => 'Appointment could not be saved.';

  @override
  String get appointmentCreateError => 'Appointment could not be created.';

  @override
  String get appointmentDeleteError => 'Error deleting appointment';

  @override
  String appointmentForPatient(String name) {
    return 'Create appointment for a patient';
  }

  @override
  String get practiceAppointment => 'Practice appointment';

  @override
  String get practiceAppointmentOwn =>
      'Create own internal practice appointment';

  @override
  String get practiceAppointmentSaveError =>
      'Practice appointment could not be saved.';

  @override
  String get practiceAppointmentDeleteConfirm => 'Delete practice appointment?';

  @override
  String get calendarAddTitle => 'Add to calendar?';

  @override
  String get calendarNoThanks => 'No, thanks';

  @override
  String get calendarShareIcs => 'Share as .ics';

  @override
  String get calendarAdd => 'Add to calendar';

  @override
  String get medication => 'Medication';

  @override
  String get medicationAdd => 'Add medication';

  @override
  String get medicationPlan => 'Medication plan';

  @override
  String get medicationHubOpen => 'Open medication hub';

  @override
  String get medicationIntakeTimes => 'Intake times';

  @override
  String get medicationIntakeSaveError => 'Error saving intake';

  @override
  String get medicationStock => 'Stock (optional)';

  @override
  String get medicationLocalAlarms => 'Local alarms for activated times';

  @override
  String get medicationAlarmDeleteError => 'Error deleting alarm';

  @override
  String get patient => 'Patient';

  @override
  String get patientInvite => 'Invite patient';

  @override
  String get patientAdd => 'Add patient';

  @override
  String get patientConnect => 'Connect patient';

  @override
  String get patientLinked => 'Patient successfully linked!';

  @override
  String get patientLinking => 'Patient Linking';

  @override
  String get patientPlan => 'Patient plan';

  @override
  String get patientAppointment => 'Patient appointment';

  @override
  String get patientData => 'Patient data';

  @override
  String get patientNoInvites => 'No patient invitations.';

  @override
  String get doctor => 'Doctor';

  @override
  String get doctorAdd => 'Add doctor';

  @override
  String get doctorRemove => 'Remove doctor';

  @override
  String get doctorConfirm => 'Confirm doctor';

  @override
  String get doctorDisconnect => 'Disconnect doctor';

  @override
  String get doctorDeleted => 'Doctor deleted.';

  @override
  String get doctorCreated => 'Doctor was created';

  @override
  String get doctorDetails => 'Doctor details';

  @override
  String get doctorCreateInvite => 'Create doctor invitation';

  @override
  String get doctorVerification => 'Doctor verification';

  @override
  String get doctorNoInvites => 'No doctor invitations.';

  @override
  String get doctorManage => 'Manage doctors';

  @override
  String get doctorEnterUid => 'Please enter a doctor UID.';

  @override
  String get doctorReportNotAvailable => 'Doctor report not available.';

  @override
  String get treatingDoctor => 'Treating doctor';

  @override
  String get templateNew => 'New template';

  @override
  String get templateNone => 'No templates found';

  @override
  String get templateDelete => 'Delete template?';

  @override
  String templateDeleteConfirm(String name) {
    return 'Do you really want to delete \"$name\"?';
  }

  @override
  String get templateSaved => 'Template saved';

  @override
  String get templateSave => 'Save template';

  @override
  String get templateApply => 'Apply template';

  @override
  String get templateFromTasks => 'Template from tasks';

  @override
  String get templateFromTasksCreate => 'Create template from tasks';

  @override
  String templateCreated(String name) {
    return 'Template \"$name\" created';
  }

  @override
  String templateDuplicated(String name) {
    return '\"$name\" created';
  }

  @override
  String get templateDuplicateError => 'Error duplicating';

  @override
  String templateAdopted(String name) {
    return '\"$name\" adopted to own templates';
  }

  @override
  String get templateAdoptError => 'Error adopting';

  @override
  String get templateDeleteError => 'Error deleting template';

  @override
  String get templateOwnTemplates => 'Own templates';

  @override
  String get templateDuplicate => 'Duplicate';

  @override
  String get templateAdopt => 'Adopt';

  @override
  String get systemTemplates => 'System templates';

  @override
  String get systemTemplateDelete => 'Delete system template?';

  @override
  String get systemTemplateNone => 'No system templates yet';

  @override
  String get systemTemplateFirst => 'First system template';

  @override
  String get task => 'Task';

  @override
  String get taskDefine => 'Define task';

  @override
  String get taskCreate => 'Create task';

  @override
  String get taskCreateError => 'Task could not be created.';

  @override
  String get taskAssign => 'Assign task';

  @override
  String get taskRequired => 'Required item';

  @override
  String tasksCount(int count) {
    return 'Tasks ($count)';
  }

  @override
  String tasksSelectCount(int selected, int total) {
    return 'Select tasks ($selected/$total):';
  }

  @override
  String get tasksSelectToApply => 'Select tasks to apply:';

  @override
  String get tasksNone => 'No tasks';

  @override
  String get tasksNoneYet => 'No tasks yet';

  @override
  String get tasksNoneAdded => 'No tasks added yet';

  @override
  String get tasksNoneInPlan => 'No tasks in plan yet.';

  @override
  String get tasksNoneAssigned => 'No assigned tasks found.';

  @override
  String get taskSaveError => 'Error saving task';

  @override
  String get taskRepeatCount => 'Number of repetitions';

  @override
  String get taskDayOffset => 'Day offset';

  @override
  String get taskDueAfterHours => 'Due after (hours)';

  @override
  String get taskTimeOfDay => 'Time of day (optional)';

  @override
  String get taskMustNotForget => 'Must not be forgotten';

  @override
  String get phase => 'Phase';

  @override
  String get phases => 'Phases';

  @override
  String get phaseNone => 'No phase';

  @override
  String get phasesNone => 'No phases – all tasks are general.';

  @override
  String get phaseRename => 'Rename phase';

  @override
  String get inviteCreate => 'Create invitation';

  @override
  String get inviteCreated => 'Invitation created';

  @override
  String get inviteCreateError => 'Invitation could not be created.';

  @override
  String get inviteAcceptError => 'Invitation could not be accepted.';

  @override
  String get inviteRevoke => 'Revoke invitation?';

  @override
  String get inviteRevoked => 'Invitation revoked.';

  @override
  String get inviteAccepted => 'Invite accepted.';

  @override
  String get invitations => 'Invitations';

  @override
  String get inviteCodeCopied => 'Invitation code copied';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get codeCopiedExcl => 'Code copied!';

  @override
  String get codeEnter => 'Enter code';

  @override
  String get codeCopy => 'Copy code';

  @override
  String get inviteFamilyMember => 'Invite family member';

  @override
  String get observation => 'Record observation';

  @override
  String get observationNew => 'New observation';

  @override
  String get observationsNone => 'No observations recorded yet.';

  @override
  String get myObservations => 'My observations';

  @override
  String get woundDoc => 'Wound documentation';

  @override
  String get woundNoEntries => 'No wound entries yet.';

  @override
  String get woundPhotoForAnalysis => 'Wound photo for analysis';

  @override
  String get woundChoosePhoto =>
      'Choose a photo for AI wound analysis with Bella';

  @override
  String get woundNoPhotos => 'No wound photos available for analysis.';

  @override
  String get woundNoPhoto => 'No photo available for analysis.';

  @override
  String get woundTakePhoto => '📷  Take new photo';

  @override
  String get woundFromGallery => '🖼️  Choose from gallery';

  @override
  String get woundMinPhotos => 'At least 2 photos needed for comparison.';

  @override
  String get woundCompare => 'Compare';

  @override
  String get woundSliderMix => 'A/B slider mix';

  @override
  String get painLevel => 'Pain level';

  @override
  String get painComparison => 'Pain level comparison';

  @override
  String get painCourse7d => 'Pain course (7 days)';

  @override
  String get painSaved => 'Pain value saved';

  @override
  String painScoreOf10(int score) {
    return 'Pain: $score/10';
  }

  @override
  String painLevelOf10(int level) {
    return 'Pain level: $level/10';
  }

  @override
  String get unbearable => 'Unbearable';

  @override
  String get moodSaved => 'Mood saved';

  @override
  String get moodDeleteConfirm =>
      'Do you really want to delete this mood entry?';

  @override
  String get nutritionDescribeMeal => 'Please describe your meal';

  @override
  String get nutritionSaved => 'Meal saved';

  @override
  String get nutritionRecipes => 'Recipes';

  @override
  String get nutritionDailyGoals => 'Daily goals';

  @override
  String get vitalsMeasurementSaved => 'Measurement saved';

  @override
  String vitalsNewMeasurementsSync(int count) {
    return '$count new measurements synced from Health';
  }

  @override
  String get bodyData => 'Body data';

  @override
  String get packingListReset => 'Reset packing list?';

  @override
  String get packingListNoItems => 'No packing list items available.';

  @override
  String get packingListDelete => 'Delete list?';

  @override
  String get packingListRename => 'Rename list';

  @override
  String get packingListNew => 'New list';

  @override
  String get packingListName => 'List name';

  @override
  String get packingListAddItem => 'Add item';

  @override
  String get documentUpload => 'Upload document';

  @override
  String get documentDeleteConfirm => 'Delete document?';

  @override
  String get documentSavedLocally => 'Document saved locally.';

  @override
  String get documentsOpen => 'Open documents';

  @override
  String get documentsAll => 'All documents';

  @override
  String get noteDelete => 'Delete note';

  @override
  String get noteSave => 'Save note';

  @override
  String get noteDeleteError => 'Error deleting note';

  @override
  String get noteSaveError => 'Error saving note';

  @override
  String get voiceMemoSaved => 'Memo saved';

  @override
  String get voiceMemoDelete => 'Delete memo?';

  @override
  String get voiceStartRecording => 'Start recording';

  @override
  String get voiceNoMemos => 'No memos found.';

  @override
  String get voiceTranscriptSaved => 'Transcript saved';

  @override
  String get voiceNoTranscript =>
      'No transcript available – please transcribe first.';

  @override
  String get voiceAudioNotFoundLocal => 'Audio file not found locally.';

  @override
  String get voiceAudioNotFound => 'Audio file not found.';

  @override
  String get voiceMicPermissionMissing => 'Microphone permission missing.';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileSaveError => 'Profile could not be saved.';

  @override
  String get yourDetails => 'Your details';

  @override
  String get smokerStatus => 'Smoker status';

  @override
  String get hospitalClinic => 'Hospital / Clinic';

  @override
  String get treatmentType => 'Treatment type *';

  @override
  String get opDate => 'Surgery date *';

  @override
  String get currentOperation => 'Current operation';

  @override
  String get operationArchived => 'Operation archived';

  @override
  String get markOpComplete => 'Mark current surgery as completed';

  @override
  String get stayType => 'Type of stay';

  @override
  String get startDateOpDate => 'Start date (e.g. surgery date)';

  @override
  String get emergencyContact => 'Emergency contact';

  @override
  String get transportPlanSaved => 'Transport planning saved';

  @override
  String get healthOverview => 'Your health overview';

  @override
  String get proUnlock => 'Unlock Pro';

  @override
  String get proRedeemKey => 'Redeem Pro key';

  @override
  String get proKeys => 'Pro Keys';

  @override
  String get proKeysCreate => 'Create Pro keys';

  @override
  String get proGrantAccess => 'Grant Pro access';

  @override
  String get proHowManyDays => 'How many days of Pro access?';

  @override
  String get proStatusChangeError => 'Pro status could not be changed.';

  @override
  String get proManageSubscription => 'Manage subscription';

  @override
  String get proRestorePurchase => 'Restore purchase';

  @override
  String staffMember(String action) {
    return 'Staff member $action';
  }

  @override
  String get staffUpdated => 'Staff member updated';

  @override
  String get staffRemove => 'Remove staff member';

  @override
  String get staffCreate => 'Create staff member';

  @override
  String get staffCreated => 'Staff member was created';

  @override
  String get orgJoin => 'Join organisation';

  @override
  String get orgJoinWithCode => 'Join with invitation code';

  @override
  String get orgConfirm => 'Confirm organisation';

  @override
  String get orgVerification => 'Organisation verification';

  @override
  String get ticketNew => 'New ticket';

  @override
  String get ticketCreated => 'Ticket created!';

  @override
  String get ticketClosed => 'Ticket closed.';

  @override
  String get ticketCloseConfirm => 'Close ticket?';

  @override
  String get ticketCloseExplanation => 'The ticket will be marked as closed.';

  @override
  String get tickets => 'Tickets';

  @override
  String ticketsCountOpen(int count) {
    return 'Tickets ($count open)';
  }

  @override
  String get myTickets => 'My tickets';

  @override
  String get messageSendError => 'Message could not be sent.';

  @override
  String get message => 'Message';

  @override
  String get noMessagesYet => 'No messages yet.';

  @override
  String get questionAdd => 'Add question';

  @override
  String get questionNew => 'New question';

  @override
  String get questionCreate => 'Create question';

  @override
  String get questionDelete => 'Delete question?';

  @override
  String get loginToSaveQuestions => 'Please sign in to save questions.';

  @override
  String get bellaSummarize => 'Summarize with Bella';

  @override
  String get bellaAnalyze => 'Analyze with Bella';

  @override
  String get bellaGenerate => 'Generate now';

  @override
  String get bellaRegenerate => 'Regenerate';

  @override
  String get bellaBriefingCopied => 'Briefing copied to clipboard';

  @override
  String redFlagSaved(String level) {
    return 'Warning sign check saved ($level)';
  }

  @override
  String get severityCourse => 'Severity course';

  @override
  String get lastFlags => 'Last flags';

  @override
  String get lastEntries => 'Last entries:';

  @override
  String get photoSaved => 'Photo saved and synced.';

  @override
  String get photo => 'Photo';

  @override
  String get cameraOpening => 'Opening camera…';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get entryDeleteConfirm => 'Delete entry?';

  @override
  String get entryDeleteIrreversible =>
      'This entry will be permanently deleted.';

  @override
  String get entryDetailed => 'Detailed entry';

  @override
  String get entryNew => 'New entry';

  @override
  String get minTwoEntriesForComparison =>
      'At least 2 entries needed for comparison.';

  @override
  String get saveError => 'Error saving';

  @override
  String get saveFailed => 'Save failed';

  @override
  String get saveFailedDot => 'Save failed.';

  @override
  String get deleteError => 'Error deleting';

  @override
  String get disconnectError => 'Error disconnecting';

  @override
  String get restoreError => 'Error restoring';

  @override
  String get pinError => 'Error pinning';

  @override
  String get unlockFailed => 'Unlock failed.';

  @override
  String get lockFailed => 'Lock failed.';

  @override
  String get deleteFailed => 'Deletion failed.';

  @override
  String get actionFailed => 'Action failed.';

  @override
  String get dataLoadError => 'Data could not be loaded.';

  @override
  String get pageOpenError => 'This page could not be opened.';

  @override
  String get noLocalFile => 'No local file available.';

  @override
  String get fileNotFound => 'File not found.';

  @override
  String get fileReadError => 'File could not be read.';

  @override
  String get uploadPending => 'Upload pending. Retrying.';

  @override
  String get uploadFailedLocal => 'Upload failed – saved locally.';

  @override
  String get noEmailApp => 'No email app found';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get titleAndMessageRequired => 'Title and message must not be empty.';

  @override
  String get titleAndUrlRequired => 'Title and URL are required.';

  @override
  String get urlInvalid => 'Please enter a complete http(s) URL.';

  @override
  String get imageRequired => 'Please select an image for the partner ad.';

  @override
  String get resultSaved => 'Result saved';

  @override
  String get copiedToClipboard => 'Copied to clipboard!';

  @override
  String get reportCopied => 'Report copied to clipboard';

  @override
  String get allCopied => 'All keys copied to clipboard!';

  @override
  String get allCopy => 'Copy all';

  @override
  String get selectSpecialty => 'Please select a specialty';

  @override
  String get selectMinOneSection => 'Select at least one section.';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get testNotificationCreated => 'Test notification created.';

  @override
  String get companion => 'Companion';

  @override
  String get timeline => 'Timeline';

  @override
  String get toTimeline => 'To Timeline';

  @override
  String get openDiary => 'Open diary';

  @override
  String get openFullDiary => 'Open full diary';

  @override
  String get checklists => 'Checklist';

  @override
  String get categories => 'Categories';

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsLoadError => 'Statistics could not be updated.';

  @override
  String get statisticsLoading => 'Loading statistics...';

  @override
  String get tags => 'Tags';

  @override
  String get permissions => 'Permissions';

  @override
  String get permissionsUpdated => 'Permissions updated';

  @override
  String get myPermissions => 'My permissions';

  @override
  String get readAllowed => 'Allow reading';

  @override
  String get writeAllowed => 'Allow writing';

  @override
  String get readOnly => 'Read only';

  @override
  String get read => 'Read';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get practice => 'Practice';

  @override
  String get history => 'History';

  @override
  String get preview => 'Preview';

  @override
  String get status => 'Status';

  @override
  String get role => 'Role';

  @override
  String get roleChange => 'Change role';

  @override
  String get roleChangeError => 'Role could not be changed.';

  @override
  String get roleDistribution => 'Role distribution';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get unread => 'Unread';

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get declined => 'Declined';

  @override
  String get resolved => 'Resolved';

  @override
  String get inProgress => 'In progress';

  @override
  String get locked => 'Locked';

  @override
  String get full => 'Full';

  @override
  String get off => 'Off';

  @override
  String get system => 'System';

  @override
  String get user => 'User';

  @override
  String get overlayMode => 'Overlay mode';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get noAccess => 'No access';

  @override
  String get sureQuestion => 'Are you sure?';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectConfirm => 'Disconnect?';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connect => 'Connect';

  @override
  String get connectionRemove => 'Remove connection';

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get rename => 'Rename';

  @override
  String get editTitle => 'Edit title';

  @override
  String get filterReset => 'Reset filter';

  @override
  String get sendEmail => 'Send email';

  @override
  String get day => 'Day';

  @override
  String get moreTools => 'More tools';

  @override
  String get checkAgain => 'Check again';

  @override
  String get adDelete => 'Delete ad?';

  @override
  String adDeleteMessage(String title) {
    return '\"$title\" will be permanently deleted.';
  }

  @override
  String get adGlobalSettings => 'Global settings';

  @override
  String get adEnabled => 'Ads enabled';

  @override
  String get adGoogleAds => 'Google Ads';

  @override
  String get adAdmobBanner => 'Show AdMob banner ads';

  @override
  String get adPartnerAds => 'Partner ads';

  @override
  String adPartnerAdsCount(int count) {
    return 'Partner ads ($count)';
  }

  @override
  String get adFrequency => 'Frequency';

  @override
  String get adPartnerCreate => 'Create partner ad';

  @override
  String get adminActivities7d => 'Admin activities (7 days)';

  @override
  String get adminActionDistribution7d => 'Action distribution (7 days)';

  @override
  String get adminNewRegistrations30d => 'New registrations (30 days)';

  @override
  String get adminRegistrations => 'Registrations';

  @override
  String get adminStatusOverview => 'Status overview';

  @override
  String get adminAllRoles => 'All roles';

  @override
  String get adminUserManage => 'Manage users';

  @override
  String get adminUserLock => 'Lock user';

  @override
  String get adminAuditLog => 'Audit log';

  @override
  String get adminLogsAppear => 'Logs appear here.';

  @override
  String get adminMaintenanceMode => 'Activate maintenance mode';

  @override
  String get adminMaintenanceError => 'Maintenance mode could not be changed.';

  @override
  String get adminFirebaseSmokeTest => 'Firebase Smoke Test';

  @override
  String get declineRequest => 'Decline request';

  @override
  String get requestDeclined => 'Request was declined';

  @override
  String get requestNotFound => 'Request not found.';

  @override
  String get requestReactivate => 'Reactivate request?';

  @override
  String requestReactivated(String name) {
    return 'Request from $name reactivated.';
  }

  @override
  String get reactivate => 'Reactivate';

  @override
  String get reactivationFailed => 'Reactivation failed.';

  @override
  String get verificationFailed => 'Verification failed.';

  @override
  String get declineReason => 'Reason for decline';

  @override
  String get declineReasonAlt => 'Reason for decline';

  @override
  String get internalCommentOptional => 'Optional internal comment:';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get revoke => 'Revoke';

  @override
  String pushTo(String target) {
    return 'Push to $target';
  }

  @override
  String pushSent(String target) {
    return 'Push to $target sent.';
  }

  @override
  String get pushSendError => 'Push could not be sent.';

  @override
  String get kneeArthroscopy => 'Knee arthroscopy';

  @override
  String get uniClinicMunich => 'University Hospital Munich';

  @override
  String get wakeTimeMustBeAfterBed => 'Wake time must be after bedtime.';

  @override
  String get qrCodeScan => 'Scan QR code';

  @override
  String get releaseAll => 'Release all';

  @override
  String get keyActivate => 'Activate key';

  @override
  String get keyDeactivate => 'Deactivate key?';

  @override
  String get keyDeactivated => 'Key deactivated.';

  @override
  String get keyCreated => 'Key created';

  @override
  String get keyDeactivateError => 'Key could not be deactivated.';

  @override
  String get keyCreateError => 'Key could not be created.';

  @override
  String get keysLoadError => 'Keys could not be loaded.';

  @override
  String validForDays(int days) {
    return 'Valid for $days days';
  }

  @override
  String get validityDuration => 'Validity duration:';

  @override
  String get targetGroup => 'Target group';

  @override
  String get endTimeSet => 'Set end time';

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
  String get scSeverityNone => 'None';

  @override
  String get scSeverityMild => 'Mild';

  @override
  String get scSeverityModerate => 'Moderate';

  @override
  String get scSeveritySevere => 'Severe';

  @override
  String get scLevelGreen => 'Green';

  @override
  String get scLevelYellow => 'Yellow';

  @override
  String get scLevelRed => 'Red';

  @override
  String get scLevelTitleYellow => 'Please observe';

  @override
  String get scRecommendGreen =>
      'Your symptoms are unremarkable. Continue to document regularly and follow your recovery plan.';

  @override
  String get scRecommendYellow =>
      'Some symptoms are slightly abnormal. Monitor the development over the next 24 hours. Contact your doctor if symptoms worsen.';

  @override
  String get scRecommendRed =>
      'Your symptoms indicate a possible complication. Contact your doctor immediately or go to the nearest emergency room.';

  @override
  String get scSymPain => 'Pain';

  @override
  String get scSymNausea => 'Nausea';

  @override
  String get scSymBreathing => 'Breathing';

  @override
  String get scSymDizziness => 'Dizziness';

  @override
  String get scSymWound => 'Wound Status';

  @override
  String get scSymPainSub => 'How severe is your pain in the surgical area?';

  @override
  String get scSymNauseaSub => 'Do you have nausea or the urge to vomit?';

  @override
  String get scSymBreathingSub =>
      'Do you have breathing difficulties or shortness of breath?';

  @override
  String get scSymDizzinessSub => 'Do you feel dizzy or lightheaded?';

  @override
  String get scSymWoundSub =>
      'Does the wound show abnormalities (redness, discharge)?';

  @override
  String get scTitle => 'Symptom Check';

  @override
  String get scSymptomsSection => 'Evaluate Symptoms';

  @override
  String get scYourInputs => 'Your Inputs';

  @override
  String get scIntroBody =>
      'Rate each symptom. At the end you will receive an assessment with a recommendation.';

  @override
  String get scSetDailyReminder => 'Set Daily Reminder';

  @override
  String get scActionsTitle => 'Recommended Actions';

  @override
  String get scSaveResult => 'Save Result';

  @override
  String get scSaving => 'Saving…';

  @override
  String get scSaved => 'Saved ✓';

  @override
  String scResultBadge(String label) {
    return 'Result: $label';
  }

  @override
  String scReminderActive(String time) {
    return 'Reminder: $time';
  }

  @override
  String scReminderSet(String time) {
    return 'Reminder set for $time';
  }

  @override
  String get nichtHinterlegt => 'Not provided';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldPhone => 'Phone number';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get fieldSmoker => 'Smoker';

  @override
  String get fieldOpType => 'Surgery type';

  @override
  String get fieldOpDate => 'Surgery date';

  @override
  String get fieldOpModus => 'Surgery mode';

  @override
  String get fieldHospitalPhone => 'Hospital phone';

  @override
  String get fieldDoctorPhone => 'Doctor\'s phone';

  @override
  String get eiBloodType => 'Blood type';

  @override
  String get eiAllergies => 'Allergies';

  @override
  String get eiInsurance => 'Insurance';

  @override
  String get eiHospital => 'Hospital';

  @override
  String get eiConditions => 'Pre-existing conditions';

  @override
  String get eiMedications => 'Medications';

  @override
  String get eiOfflineBanner =>
      'No connection – please make sure to load the emergency info when you have internet access.';

  @override
  String get eiNoDataHint =>
      'No emergency data stored.\nEnter your data in your profile.';

  @override
  String get eiOpenProfile => 'Open profile';

  @override
  String get eiShareHeader => '🆘 EMERGENCY INFORMATION';

  @override
  String get eiShareEmergency => 'Emergency: 112';

  @override
  String get eiSummaryNameHint => 'e.g. John Smith';

  @override
  String get eiSummaryPhoneHint => 'e.g. +1 555 1234567';

  @override
  String get eiSummaryOpType => 'Surgery Type';

  @override
  String get eiSummaryOpDateUnknown => 'Not yet known';

  @override
  String get eiSummaryTreatment => 'Treatment';

  @override
  String get eiSummaryAmbulant => 'Outpatient';

  @override
  String eiShareBloodType(String value) {
    return 'Blood type: $value';
  }

  @override
  String eiShareAllergies(String value) {
    return 'Allergies: $value';
  }

  @override
  String eiShareContact(String name) {
    return 'Emergency contact: $name';
  }

  @override
  String eiSharePhone(String value) {
    return 'Tel: $value';
  }

  @override
  String eiShareHospital(String name) {
    return 'Hospital: $name';
  }

  @override
  String eiShareHospitalPhone(String value) {
    return 'Hospital tel: $value';
  }

  @override
  String eiShareDoctor(String name) {
    return 'Doctor: $name';
  }

  @override
  String eiShareDoctorPhone(String value) {
    return 'Doctor tel: $value';
  }

  @override
  String eiShareInsurance(String value) {
    return 'Insurance: $value';
  }

  @override
  String get notfallInfoTeilen => 'Notfall-Info teilen';

  @override
  String get notruf112 => 'Notruf 112';

  @override
  String get fehlerSpeichernErneut => 'Error saving. Please try again.';

  @override
  String get fehlerBeimSpeichern => 'Error saving.';

  @override
  String get woWirstDuBehandelt => 'Wo wirst du behandelt?';

  @override
  String get fastGeschafft => 'Fast geschafft!';

  @override
  String get opClinic => 'Clinic';

  @override
  String get deinGesundheitsprofil => 'Dein Gesundheitsprofil';

  @override
  String get aktuelleMedikamente => 'Aktuelle Medikamente';

  @override
  String get oPTypEingeben => 'OP-Typ eingeben';

  @override
  String get mitKrankenhausaufenthalt => 'Mit Krankenhausaufenthalt';

  @override
  String get profilGespeichertKurz => 'Profile saved';

  @override
  String get koerperwerteUndGesundheit => 'Körperwerte & Gesundheit';

  @override
  String get notfallkontaktUndNotfallInfo => 'Notfallkontakt & Notfall-Info';

  @override
  String get bezeichnungEingeben => 'Enter label';

  @override
  String get pINAktivieren => 'PIN aktivieren';

  @override
  String get n4StelligerZugangsPIN => '4-stelliger Zugangs-PIN';

  @override
  String get proEntdecken => 'Pro entdecken';

  @override
  String get aktuellesPasswort => 'Aktuelles Passwort';

  @override
  String get passwortSpeichern => 'Passwort speichern';

  @override
  String labelHinzufuegen(String label) {
    return 'Add $label';
  }

  @override
  String get vitalwerte => 'Vitals';

  @override
  String get neueMessung => 'New Measurement';

  @override
  String get systolisch => 'Systolic';

  @override
  String get diastolisch => 'Diastolic';

  @override
  String get puls => 'Pulse';

  @override
  String get normalSystolisch => 'Normal: 90–140';

  @override
  String get normalDiastolisch => 'Normal: 60–90';

  @override
  String get normalPuls => 'Normal: 60–100';

  @override
  String get weitereWerteOptional => 'More Values (optional)';

  @override
  String get vitalsErinnerung => 'Reminder';

  @override
  String get taeglicheMesserinnerung => 'Daily Measurement Reminder';

  @override
  String get temperatur => 'Temperature';

  @override
  String get normalTemperatur => 'Normal: 36.0–37.5 °C';

  @override
  String get normalO2Saettigung => 'Normal: 95–100 %';

  @override
  String get notizOptional => 'Notiz (optional)';

  @override
  String get mindZweiEintraege => 'Min. 2 entries for the chart';

  @override
  String get vitalsTipp =>
      'Tip: Log your vitals daily – this helps you spot trends early.';

  @override
  String get chartLast5 => '5 entries';

  @override
  String get chartDays7 => '7 days';

  @override
  String get chartDays30 => '30 days';

  @override
  String get blutdruck => 'Blood Pressure';

  @override
  String get trageVitalwerteEin => 'Enter your current vitals.';

  @override
  String normalbereichValue(String min, String max, String unit) {
    return 'Normal range: $min–$max $unit';
  }

  @override
  String neueMessungenSync(int count) {
    return '$count new measurements synced from Health';
  }

  @override
  String get neueMessungEintragen => 'Neue Messung eintragen';

  @override
  String get messungGespeichert => 'Measurement saved';

  @override
  String get schmerzfrei => 'Pain-free';

  @override
  String get sehrStark => 'Very severe';

  @override
  String get schmerztagebuch => 'Pain Diary';

  @override
  String get wieStarkSindDeineSchmerzen => 'How severe is your pain?';

  @override
  String get woTutEsWeh => 'Wo tut es weh?';

  @override
  String get optionalTippeAufEineRegion => 'Optional – tap on a region';

  @override
  String get artDerSchmerzen => 'Art der Schmerzen';

  @override
  String get optionalWieFuehltEsSichAn => 'Optional – how does it feel?';

  @override
  String get avgSiebenTage => 'Ø 7 Days';

  @override
  String get gesamt => 'Ø Gesamt';

  @override
  String get trendLabel => 'Trend';

  @override
  String get minMax => 'Min / Max';

  @override
  String eintraegeInsgesamt(int count) {
    return '$count entries total';
  }

  @override
  String get mehrMitPro => 'More with Pro';

  @override
  String letzteEintraege(int count) {
    return 'Last $count entries';
  }

  @override
  String letzteEintraegeGratis(int count) {
    return 'Last $count entries (5 free)';
  }

  @override
  String get letzteEintraegeHeader => 'Recent entries';

  @override
  String get alleAnzeigen => 'All →';

  @override
  String get gradesEben => 'Just now';

  @override
  String vorMinuten(int min) {
    return '$min min. ago';
  }

  @override
  String vorStunden(int h) {
    return '$h hr. ago';
  }

  @override
  String get gestern => 'Yesterday';

  @override
  String vorTagen(int days) {
    return '$days days ago';
  }

  @override
  String get ortOptional => 'Ort (optional)';

  @override
  String get ausloeserOptional => 'Auslöser (optional)';

  @override
  String get painEntryEditorNotizOptional => 'Notiz (optional)';

  @override
  String get eintragBearbeiten => 'Edit entry';

  @override
  String get schmerzlevel => 'Pain level: null/10';

  @override
  String get wann => 'When?';

  @override
  String get datumLabel => 'Date';

  @override
  String get uhrzeitLabel => 'Time';

  @override
  String get dauerLabel => 'Duration';

  @override
  String get dauerhaft => 'Persistent';

  @override
  String minMinuten(int min) {
    return '$min min.';
  }

  @override
  String stundenLabel(int h) {
    return '$h hr.';
  }

  @override
  String get medikationLabel => 'Medication';

  @override
  String get eintragLoeschen => 'Delete entry';

  @override
  String get kalender => 'Calendar';

  @override
  String get proLabel => 'Pro';

  @override
  String get filterAktiv => 'Filter active';

  @override
  String get filtern => 'Filter';

  @override
  String get koerperregion => 'Body region';

  @override
  String get schmerzart => 'Pain type';

  @override
  String get insights => 'Insights';

  @override
  String haeufigstesGebiet(String region) {
    return 'Most frequent area: $region';
  }

  @override
  String get keineEintraegeFilter => 'No entries with these filters';

  @override
  String get nochKeineEintraege => 'No entries yet';

  @override
  String get tippeAufNeuenEintrag => 'Tap \"+ New entry\" to get started';

  @override
  String avgWert(String val) {
    return 'Ø $val';
  }

  @override
  String get heute => 'Today';

  @override
  String get montag => 'Monday';

  @override
  String get dienstag => 'Tuesday';

  @override
  String get mittwoch => 'Wednesday';

  @override
  String get donnerstag => 'Thursday';

  @override
  String get freitag => 'Friday';

  @override
  String get samstag => 'Saturday';

  @override
  String get sonntag => 'Sunday';

  @override
  String get moKurz => 'Mo';

  @override
  String get diKurz => 'Tu';

  @override
  String get miKurz => 'We';

  @override
  String get doKurz => 'Th';

  @override
  String get frKurz => 'Fr';

  @override
  String get saKurz => 'Sa';

  @override
  String get soKurz => 'Su';

  @override
  String get keinSchmerz => 'None';

  @override
  String get kalenderMitProFreischalten => 'Unlock calendar with Pro';

  @override
  String get keineDetails => 'No details';

  @override
  String get minLabel => 'Min';

  @override
  String get maxLabel => 'Max';

  @override
  String get bellaAnalyse => 'Bella Analyse 🐰';

  @override
  String get emptyNoEntries => 'No entries yet';

  @override
  String get emptyWoundDocHint =>
      'Document your wound healing with photos,\npain levels, and notes.';

  @override
  String get ersteDokumentationStarten => 'Erste Dokumentation starten';

  @override
  String get neuesFotoAufnehmen => 'Neues Foto aufnehmen';

  @override
  String get woundHubKoerperstelle => 'Körperstelle';

  @override
  String get neuErfassen => 'Neu erfassen';

  @override
  String get verlaufVergleichen => 'Verlauf vergleichen';

  @override
  String get koerperstelle => 'Körperstelle';

  @override
  String get keinFotoAnalyse => 'No photo available for analysis.';

  @override
  String get n1FotoPflaster => '1. Foto: Pflaster';

  @override
  String get zeigtDenZustandDesVerbands => 'Zeigt den Zustand des Verbands';

  @override
  String get n2FotoWunde => '2. Foto: Wunde';

  @override
  String get nachAbnehmenDesPflasters => 'Nach Abnehmen des Pflasters';

  @override
  String get linksA => 'Links (A)';

  @override
  String get rechtsB => 'Rechts (B)';

  @override
  String schmerzScore(int score) {
    return 'Pain: $score/10';
  }

  @override
  String get fotoLadeFehler => 'Could not load photo.';

  @override
  String get fotoHinzufuegen => 'Foto hinzufügen';

  @override
  String get fotoQuelleWaehlen => 'Choose photo source';

  @override
  String get kameraOeffnen => 'Camera';

  @override
  String get ausGalerieWaehlen => 'From Gallery';

  @override
  String get fotoAendern => 'Change photo';

  @override
  String get fotoEntfernen => 'Remove photo';

  @override
  String get kameraBerechtigungFehlt =>
      'Camera access denied. Please allow camera access in Settings.';

  @override
  String get fotoMediathekBerechtigungFehlt =>
      'Photo library access denied. Please allow access in Settings.';

  @override
  String get kameraFehlerVersucheGalerie =>
      'Camera not available. Please select a photo from the gallery.';

  @override
  String get koerperstelleOptional => 'Body location (optional)';

  @override
  String get woundCompareTitle => 'Photo comparison';

  @override
  String get woundCompareSlider => 'Slider';

  @override
  String get woundCompareCompare => 'Compare';

  @override
  String get emptyNoPhotos => 'No photos available';

  @override
  String get emptyWoundCompareHint =>
      'Document at least two entries\nwith a photo to compare progress.';

  @override
  String get wundDokumentationTitle => 'Wound documentation';

  @override
  String get woundNoPhotoYet => 'No photo yet';

  @override
  String get woundNoteHint => 'How does the wound look? Anything notable?';

  @override
  String get notizLabel => 'Note';

  @override
  String get woundHistoryTitle => 'Wound history';

  @override
  String get woundDiaryTitle => 'Wound diary';

  @override
  String get woundDiarySubtitle =>
      'Chronological overview of your wound healing with photos and notes.';

  @override
  String get woundPhotoGuideTitle => 'Photo guide';

  @override
  String get woundPhotoGuideSubtitle =>
      'For good documentation we recommend 2 photos daily:';

  @override
  String get woundPhotoTip =>
      'Tip: Make sure to have good lighting and photograph from the same angle.';

  @override
  String get woundNoNotiz => 'No note';

  @override
  String get woundDetailTitle => 'Wound detail';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get woundDeleteConfirmMessage =>
      'This wound entry will be permanently removed.';

  @override
  String get woundMinEntriesForCompare =>
      'At least 2 wound entries required for comparison.';

  @override
  String get woundDiscoveryTip =>
      'Tip: Photograph your wound regularly – that way you can spot changes at a glance.';

  @override
  String woundEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get woundNoPhotoCaptured => 'No photo available';

  @override
  String get woundTapForDetails => 'Tap for details';

  @override
  String get woundComparePick2 => 'Select two photos to compare';

  @override
  String get woundModeSplit => 'Split';

  @override
  String get woundModeOverlay => 'Overlay';

  @override
  String woundComparePhotosSelected(int count) {
    return '$count / 2 photos selected';
  }

  @override
  String get woundCompareTapInstruction =>
      'Tap the photos below that you want to compare.';

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String get woundHygieneStep1 => 'Wash hands thoroughly';

  @override
  String get woundHygieneStep2 => '🩹 Dry bandage change';

  @override
  String get woundHygieneStep3 =>
      'Wound check: Dry? Not red? No fresh bleeding?';

  @override
  String get woundHygieneStep4 =>
      'No touching the wound, no manipulation, no creams';

  @override
  String get woundHygieneStep5 => 'Replace bandage without touching the pad';

  @override
  String get woundHygieneStep6 => 'Wash hands again';

  @override
  String get woundHygieneTitle => '🧴 Wound hygiene recommendations';

  @override
  String get woundHygieneWarning =>
      'If redness occurs, please contact your practice';

  @override
  String woundHygieneAckLabel(String date) {
    return '✅ Read on $date';
  }

  @override
  String get kalorienKcal => 'Kalorien (kcal)';

  @override
  String get nutritionProteinG => 'Protein (g)';

  @override
  String get wasserMl => 'Wasser (ml)';

  @override
  String get nameDerVorlage => 'Template name';

  @override
  String get zBHaferbreiMitBeeren => 'z. B. Haferbrei mit Beeren';

  @override
  String get zbVollkornbrot =>
      'e.g. whole grain bread with cream cheese and tomatoes';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get nutritionKohlenhG => 'Kohlenh. (g)';

  @override
  String get nutritionFettG => 'Fett (g)';

  @override
  String templateWirdEntfernt(String name) {
    return '\"$name\" will be removed.';
  }

  @override
  String get naehrwerteOptional => 'Nährwerte (optional)';

  @override
  String get kohlenhG => 'Kohlenh. (g)';

  @override
  String get fettG => 'Fett (g)';

  @override
  String get getrunkenMl => 'Getrunken (ml)';

  @override
  String get vertraeglichkeit => 'Verträglichkeit';

  @override
  String get mahlzeitSpeichern => 'Save meal';

  @override
  String wasserMlDescription(int ml) {
    return 'Water ${ml}ml';
  }

  @override
  String wasserMlAdded(int ml) {
    return '+${ml}ml water added';
  }

  @override
  String get vorlageLabel => 'Template';

  @override
  String get wasserTracking => 'Water Tracking';

  @override
  String get favoriten => 'Favourites';

  @override
  String get tippeZumSchnellenWiederholen => 'Tap to repeat quickly';

  @override
  String get mahlzeitLabel => 'Meal';

  @override
  String get wasHastDuGegessen => 'What did you eat?';

  @override
  String get optionalWasserTeeEtc => 'Optional – water, tea, etc.';

  @override
  String get optionalWieVertragen =>
      'Optional – how did you tolerate the meal?';

  @override
  String get symptomeNachDemEssen => 'Symptoms after eating';

  @override
  String get optionalTippeAuf => 'Optional – tap on applicable symptoms';

  @override
  String get naehrwerteTitle => 'Nutrition';

  @override
  String get optionalKalorienProtein =>
      'Optional – calories, protein, carbohydrates, fat';

  @override
  String get vorlagenTitle => 'Templates';

  @override
  String empfehlungFuerOp(String opType) {
    return 'Recommendation for $opType surgery';
  }

  @override
  String empfehlungFuerOpTag(int day) {
    return ' · Day $day';
  }

  @override
  String get empfehlungenTitle => 'Recommendations';

  @override
  String heuteMahlzeitenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String get kcalLabel => 'kcal';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get wasserLabel => 'Water';

  @override
  String symptomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count symptoms',
      one: '1 symptom',
    );
    return '$_temp0';
  }

  @override
  String keineFilterEintraege(String mealType) {
    return 'No $mealType entries';
  }

  @override
  String get ersteMahlzeitTipp => 'Tap + to add your first meal.';

  @override
  String get beschreibungLabel => 'Description';

  @override
  String get zbVollkornbrotQuark =>
      'e.g. whole grain bread with cottage cheese';

  @override
  String get zbZahl => 'e.g. 250';

  @override
  String get symptomeLabel => 'Symptoms';

  @override
  String get notizZuSymptomenOptional => 'Note about symptoms (optional)';

  @override
  String get eintrBearbeiten => 'Edit entry';

  @override
  String get neueMahlzeit => 'New meal';

  @override
  String get eintrLoeschen => 'Delete entry';

  @override
  String get mealTypeFruehstueck => 'Breakfast';

  @override
  String get mealTypeMittagessen => 'Lunch';

  @override
  String get mealTypeAbendessen => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get symptomUebelkeit => 'Nausea';

  @override
  String get symptomBlaehungen => 'Bloating';

  @override
  String get symptomSchmerzen => 'Pain';

  @override
  String get symptomSodbrennen => 'Heartburn';

  @override
  String get symptomDurchfall => 'Diarrhoea';

  @override
  String get symptomVerstopfung => 'Constipation';

  @override
  String get symptomMuedigkeit => 'Fatigue';

  @override
  String get symptomSonstige => 'Other';

  @override
  String get nochmal => 'Again';

  @override
  String get ablaufNarkoseEingriffe => 'Ablauf, Narkose, Eingriffe';

  @override
  String get abmelden => 'Sign out';

  @override
  String get adminAbmeldenBestaetigung => 'Really sign out of the admin area?';

  @override
  String get adminAktionenUndEreignisprotokoll =>
      'Admin-Aktionen & Ereignisprotokoll';

  @override
  String get adminBenachrichtigungenUndEreignisse =>
      'Admin-Benachrichtigungen & Ereignisse';

  @override
  String get aktivDieseWoche => 'Aktiv diese Woche';

  @override
  String get aktiveProLizenzen => 'Aktive Pro-Lizenzen';

  @override
  String get aktiveTage => 'Aktive Tage';

  @override
  String get aktivHeute => 'Aktiv heute';

  @override
  String get aktivitaetsHeatmap => 'Aktivitäts-Heatmap';

  @override
  String get alertArztKontaktieren => 'Arzt kontaktieren';

  @override
  String get alle => 'All';

  @override
  String get alleAlsGelesenMarkieren => 'Mark all as read';

  @override
  String get alleFunktionenOhneEinschraenkung =>
      'Alle Funktionen ohne Einschränkung';

  @override
  String get alleMarkieren => 'All →';

  @override
  String get alsGelesen => 'Als gelesen';

  @override
  String get alsPDFTeilen => 'Als PDF teilen';

  @override
  String get alsTextKopieren => 'Als Text kopieren';

  @override
  String get angehoerigeEinladenUndGemeinsamBegleiten =>
      'Angehörige einladen & gemeinsam begleiten';

  @override
  String get angehoerigenEinladen => 'Angehörigen einladen';

  @override
  String get anweisungNotiz => 'Anweisung / Notiz';

  @override
  String get appointmentEditorRepeatUntil => 'Repeat until';

  @override
  String get apptAddFirstHint => 'Tap + to add your first appointment.';

  @override
  String get apptCancelAppt => 'Cancel appointment';

  @override
  String get apptConfirmationPending => 'Confirmation pending';

  @override
  String get apptConfirmDeclineHint => 'Please confirm or decline.';

  @override
  String get apptCreatedByDoctor => 'Created by doctor';

  @override
  String get apptDeleteTitle => 'Delete appointment';

  @override
  String get apptEditTitle => 'Edit appointment';

  @override
  String get apptHintCustomMinutes => 'Minutes';

  @override
  String get apptHintDoctor => 'e.g. Dr. Smith';

  @override
  String get apptHintLocation => 'e.g. City Hospital';

  @override
  String get apptHintLocationDetails => 'Details (ward, room)';

  @override
  String get apptHintNote => 'Optional note…';

  @override
  String get apptHintTitle => 'e.g. check-up appointment';

  @override
  String get apptLabelCustomMinutes => 'Minutes';

  @override
  String get apptLabelDate => 'Date';

  @override
  String get apptLabelDoctor => 'Doctor / Practitioner';

  @override
  String get apptLabelEndTime => 'End time';

  @override
  String get apptLabelFurtherDetails => 'More details';

  @override
  String get apptLabelFurtherReminders => 'More reminders';

  @override
  String get apptLabelLocation => 'Location';

  @override
  String get apptLabelNote => 'Note';

  @override
  String get apptLabelPriority => 'Priority';

  @override
  String get apptLabelReminder => 'Reminder';

  @override
  String get apptLabelRepeatUntil => 'Until';

  @override
  String get apptLabelStartTime => 'Start time';

  @override
  String get apptLabelTime => 'Time';

  @override
  String get apptLabelTitleRequired => 'Title *';

  @override
  String get apptLabelType => 'Type';

  @override
  String get apptMarkAsDone => 'Mark as done';

  @override
  String get apptMarkAsPlanned => 'Mark as planned';

  @override
  String get apptNewTitle => 'New appointment';

  @override
  String get apptNoAppointments => 'No appointments yet';

  @override
  String get apptNoResults => 'No results';

  @override
  String get apptNoResultsHint => 'Try different search terms or filters.';

  @override
  String get apptPriorityHigh => 'High';

  @override
  String get apptPriorityLow => 'Low';

  @override
  String get apptPriorityMedium => 'Medium';

  @override
  String get apptPriorityUrgent => 'Urgent';

  @override
  String get apptReminderAtTime => 'At the time';

  @override
  String get apptReminderCustom => 'Custom';

  @override
  String get apptReminderDay1 => '1 day before';

  @override
  String get apptReminderDays2 => '2 days before';

  @override
  String get apptReminderHour1 => '1 hour before';

  @override
  String get apptReminderHours2 => '2 hours before';

  @override
  String get apptReminderMin15 => '15 min. before';

  @override
  String get apptReminderMin30 => '30 min. before';

  @override
  String get apptReminderNone => 'None';

  @override
  String get apptRepeatDaily => 'Daily';

  @override
  String get apptRepeatMonthly => 'Monthly';

  @override
  String get apptRepeatNone => 'None';

  @override
  String get apptRepeatWeekly => 'Weekly';

  @override
  String get apptSaving => 'Saving…';

  @override
  String get apptStatusCanceled => 'Canceled';

  @override
  String get apptStatusCompleted => 'Completed';

  @override
  String get apptStatusConfirmed => 'Confirmed';

  @override
  String get apptStatusDeclined => 'Declined';

  @override
  String get apptStatusDone => 'Done';

  @override
  String get apptStatusPending => 'Pending';

  @override
  String get apptStatusPlanned => 'Planned';

  @override
  String get apptTitleRequired => 'Title is required.';

  @override
  String get apptTodayNone => 'No appointments today';

  @override
  String get apptTodayTitle => 'Today\'s appointments';

  @override
  String get apptTypeCall => 'Call';

  @override
  String get apptTypeFollowUp => 'Follow-up';

  @override
  String get apptTypeImaging => 'Imaging';

  @override
  String get apptTypeOther => 'Other';

  @override
  String get apptTypePhysio => 'Physio';

  @override
  String get apptTypeSurgery => 'Surgery';

  @override
  String get apptViewCalendar => 'Calendar';

  @override
  String get apptViewList => 'List';

  @override
  String get apptYesterday => 'Yesterday';

  @override
  String get arztBehandler => 'Arzt / Behandler';

  @override
  String get arztEntsperren => 'Arzt entsperren?';

  @override
  String get arztSofortKontaktieren => 'Arzt sofort kontaktieren';

  @override
  String get arztSperren => 'Arzt sperren?';

  @override
  String get arztUndPatienteneinladungen => 'Arzt- & Patienteneinladungen';

  @override
  String get aufbauUndRoutine => 'Aufbau & Routine';

  @override
  String get aufnahmeStartFehler => 'Could not start recording.';

  @override
  String get aufProUpgraden => 'Auf Pro upgraden';

  @override
  String get auswertungAnzeigen => 'Auswertung anzeigen';

  @override
  String get bedarfsmedikationOderSpontaneEinnahmen =>
      'Bedarfsmedikation oder spontane Einnahmen.';

  @override
  String get begruendungEingeben => 'Enter reason …';

  @override
  String get beiAkuterVerschlechterung => 'Bei akuter Verschlechterung';

  @override
  String get beiVerschlechterungAnrufen => 'Bei Verschlechterung anrufen';

  @override
  String get bellaActionCancelled => 'Cancelled';

  @override
  String get bellaActionCreated => 'Entry created ✓';

  @override
  String get bellaActionFailed => 'Failed to create';

  @override
  String get bellaArztBriefing => 'Bella Arzt-Briefing';

  @override
  String get bellaAskDirectly => 'Or ask a question directly:';

  @override
  String get bellaBriefingGenerating =>
      'Bella is creating your doctor briefing …';

  @override
  String get bellaBriefingIsProFeature => 'Doctor Briefing is a Pro feature';

  @override
  String get bellaBriefingNotSignedIn => 'Please sign in.';

  @override
  String get bellaBriefingPersonalTitle => 'Your personal doctor briefing';

  @override
  String get bellaBriefingProDescription =>
      'With Pro, Bella creates a personal summary for your next doctor\'s appointment.';

  @override
  String get bellaChipAddTask => 'Add a task: check wound';

  @override
  String get bellaChipAppFunctions => 'What app features are there?';

  @override
  String get bellaChipCallDoctor => 'When should I call the doctor?';

  @override
  String get bellaChipCreateAppointment =>
      'Create an appointment tomorrow at 10 AM';

  @override
  String get bellaChipDoctorDashboard => 'How does the doctor dashboard work?';

  @override
  String get bellaChipDoctorReport => 'How do I create a doctor report?';

  @override
  String get bellaChipGeneralDashboard => 'How does the dashboard work?';

  @override
  String get bellaChipKneeTep => 'Info on knee replacement';

  @override
  String get bellaChipLinkPatient => 'How do I link a patient?';

  @override
  String get bellaChipLogBloodPressure => 'Log blood pressure 120/80';

  @override
  String get bellaChipLogMedication => 'I just took ibuprofen';

  @override
  String get bellaChipLogPain => 'Log pain: knee, level 4';

  @override
  String get bellaChipMedications => 'How do I log my medications?';

  @override
  String get bellaChipMyTasks => 'What are my tasks?';

  @override
  String get bellaChipOpDay => 'What happens on surgery day?';

  @override
  String get bellaChipPrepareOp => 'How do I prepare for surgery?';

  @override
  String get bellaChipSymptomCheck => 'Start symptom check';

  @override
  String get bellaChipTimeline => 'How does the timeline work?';

  @override
  String get bellaChipVerifyAccount => 'How do I verify my doctor account?';

  @override
  String get bellaChipViewPatientData => 'How do I view patient data?';

  @override
  String get bellaChipViewPatientDataStaff => 'How do I view patient data?';

  @override
  String get bellaConsentAccepted => 'Consent given';

  @override
  String get bellaConsentBody =>
      'The AI assistant (Bella AI) uses an external service (NVIDIA Corporation, USA) to answer your questions.\n\nYour chat messages are transmitted to this service. No other personal data is shared.\n\nYou can withdraw your consent at any time in Settings.\n\nLegal basis: Art. 6(1)(a) and Art. 9(2)(a) GDPR.';

  @override
  String get bellaConsentDeclined => 'Consent declined';

  @override
  String get bellaConsentTitle => 'Privacy Notice';

  @override
  String get bellaConsentYes => 'Yes, I agree';

  @override
  String get bellaDailyAnalysis => 'Bella Daily Analysis';

  @override
  String get bellaDefaultWoundPrompt => 'Please analyse this wound photo.';

  @override
  String get bellaDescriptionDoctor =>
      'I help you with the doctor dashboard, patient management, and clinical questions.';

  @override
  String get bellaDescriptionPatient =>
      'I answer your questions about your surgery, aftercare, and the app.';

  @override
  String get bellaDescriptionStaff =>
      'I help you with the staff dashboard and patient care.';

  @override
  String get bellaDisclaimer =>
      'Not medical advice – consult a doctor for any complaints.';

  @override
  String get bellaFeatureAftercare => 'Aftercare';

  @override
  String get bellaFeatureAppHelp => 'App Help';

  @override
  String get bellaFeatureDashboard => 'Dashboard';

  @override
  String get bellaFeatureMedicalKnowledge => 'Surgery';

  @override
  String get bellaFeaturePatients => 'Patients';

  @override
  String get bellaFeatureTasks => 'Tasks';

  @override
  String get bellaFeatureWarnings => 'Warning Signs';

  @override
  String get bellaGreeting => 'Hello! I\'m Bella AI 🐰';

  @override
  String get bellaNoAnswerReceived =>
      'No answer received. Please try again. 🐰';

  @override
  String get bellaProactivePainTrend =>
      'Your pain level is rising – would you like to talk about it?';

  @override
  String get bellaProUpgrade => 'Upgrade to Pro now';

  @override
  String get bellaSays => 'Bella says:';

  @override
  String get bellaSubtitleDoctor => 'Your clinical assistant 🐰';

  @override
  String get bellaSubtitlePatient => 'Your surgery guide 🐰';

  @override
  String get bellaSubtitleStaff => 'Your practice assistant 🐰';

  @override
  String get bellaWoundAnalysisTitle => 'Wound Analysis';

  @override
  String get bellaWoundDisclaimer =>
      'Not a substitute for medical diagnosis. If in doubt, contact your medical team.';

  @override
  String get bellaWoundObservations => 'Observations';

  @override
  String get bellaWoundProgressComparison => 'Progress Comparison';

  @override
  String get beobachtenSieDieSymptomeGenau =>
      'Beobachten Sie die Symptome genau';

  @override
  String get beobachtungHinzufuegen => 'Beobachtung hinzufügen';

  @override
  String get beschreibeAnliegen =>
      'Describe your issue as precisely as possible…';

  @override
  String get beschreibenSieIhreSymptome => 'Beschreiben Sie Ihre Symptome';

  @override
  String get besterPreisProMonat => 'Bester Preis pro Monat';

  @override
  String get broadcastSenden => 'Broadcast senden';

  @override
  String get calendarAddedSuccess => 'Appointment added to calendar';

  @override
  String get calendarAddToCalendarBody =>
      'Would you like to add this appointment to your device calendar or share it as an .ics file?';

  @override
  String get calendarExportFailed => 'Calendar export failed';

  @override
  String get calendarMonth => 'Month';

  @override
  String get calendarNoEvents => 'No appointments on this day';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarWeek => 'Week';

  @override
  String get chronologischDokumentierteEinnahmen =>
      'Chronologisch dokumentierte Einnahmen.';

  @override
  String get codeZumManuellenEingeben => 'Code zum manuellen Eingeben';

  @override
  String get csvExportieren => 'Export CSV';

  @override
  String get dashboardPushSenden => 'Push senden';

  @override
  String get dauer => 'Ø Dauer';

  @override
  String get deepLink => 'Deep Link';

  @override
  String get discoverSubtitle => 'All features at a glance';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get doctorProfileMeinProfil => 'Mein Profil';

  @override
  String get doctorReportSchmerztagebuchLetzte7Tage =>
      'Schmerztagebuch letzte 7 Tage';

  @override
  String get doctorReportWunddokuLetzte3 => 'Wunddoku letzte 3';

  @override
  String get doctorStatsCardSchmerzlevel => 'Ø Schmerzlevel';

  @override
  String get dokumenteLetzte3 => 'Dokumente letzte 3';

  @override
  String get dokumenteOeffnenTeilen => 'Öffnen / Teilen';

  @override
  String get dokumentiereWundenUnterWunddoku =>
      'Dokumentiere Wunden unter Wunddoku';

  @override
  String get einladungscode => 'Invitation code';

  @override
  String get einladungTeilen => 'Einladung teilen';

  @override
  String get erfasseMedikamenteImMedikamentenplan =>
      'Erfasse Medikamente im Medikamentenplan';

  @override
  String get erfasseSchmerzwerteImSchmerztagebuch =>
      'Erfasse Schmerzwerte im Schmerztagebuch';

  @override
  String get erfasseVitalwerteUnterVitals => 'Erfasse Vitalwerte unter Vitals';

  @override
  String get erinnerungErstellen => 'Erinnerung erstellen';

  @override
  String get erneutPruefen => 'Erneut prüfen';

  @override
  String get errorAlreadyExists => 'Already exists.';

  @override
  String get errorCancelled => 'Operation cancelled.';

  @override
  String get errorDeadlineExceeded => 'Timeout. Please try again.';

  @override
  String get errorEmailInUse => 'This email address is already in use.';

  @override
  String get errorFailedPrecondition => 'Action cannot be performed.';

  @override
  String get errorInvalidArgument => 'Invalid input.';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get errorNoInternet =>
      'No internet connection. Please check your network.';

  @override
  String get errorNotFound => 'Not found. Please check your input.';

  @override
  String get errorNotFoundShort => 'Not found.';

  @override
  String get errorOperationNotAllowed => 'This operation is not allowed.';

  @override
  String get errorPermissionDenied => 'No permission for this action.';

  @override
  String get errorPleaseSignIn => 'Please sign in.';

  @override
  String get errorRequiresRecentLogin => 'Please sign in again to continue.';

  @override
  String get errorResourceExhausted =>
      'Too many requests. Please wait a moment.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Please try again later.';

  @override
  String get errorServiceUnavailableShort =>
      'The service is temporarily unavailable.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorUserDisabled => 'This account has been disabled.';

  @override
  String get errorUserNotFound => 'No account found with this email address.';

  @override
  String get errorWeakPassword => 'The password is too weak.';

  @override
  String get errorWrongPassword => 'Wrong password.';

  @override
  String get ersteListeErstellen => 'Erste Liste erstellen';

  @override
  String get erstelltAm => 'Erstellt am';

  @override
  String get ersteNotizErstellen => 'Erste Notiz erstellen';

  @override
  String get erstesItemHinzufuegen => 'Erstes Item hinzufügen';

  @override
  String get ersteVorlageErstellen => 'Erste Vorlage erstellen';

  @override
  String get esIstEinFehlerAufgetretenBitteVersucheEsErneut =>
      'Es ist ein Fehler aufgetreten. Bitte versuche es erneut.';

  @override
  String get exportFehlgeschlagen => 'Export failed.';

  @override
  String get familyMemberHubZBA1B2C3D4E5F6 => 'z.B. A1B2C3D4E5F6';

  @override
  String get familyPatientsMeinePatienten => 'Meine Patienten';

  @override
  String get familyPatientsZBA1B2C3D4E5F6 => 'z.B. A1B2C3D4E5F6';

  @override
  String get familyProfileZBA1B2C3D4E5F6 => 'z.B. A1B2C3D4E5F6';

  @override
  String get fehlerBeimErstellen => 'Error creating.';

  @override
  String get firebaseUIDDesArztes => 'Firebase UID des Arztes';

  @override
  String get footerLoveMessage => 'Built with love for your recovery';

  @override
  String get fotosDurchsuchen => 'Search photos (date, note, category)…';

  @override
  String get frageAnBella => 'Frage an Bella …';

  @override
  String get frageBearbeiten => 'Frage bearbeiten';

  @override
  String get frageStellen => 'Frage stellen …';

  @override
  String get freischalten => 'Unlock';

  @override
  String get funktionenErklaert => 'Funktionen erklärt';

  @override
  String get grundDerSperrung => 'Reason for blocking …';

  @override
  String get grundEingeben => 'Enter reason…';

  @override
  String get grundOptional => 'Reason (optional)';

  @override
  String get helpHilfeUndSupport => 'Hilfe & Support';

  @override
  String get heuteDokumentiert => 'Heute dokumentiert';

  @override
  String get hilfeUndSupport => 'Hilfe & Support';

  @override
  String get hinterlegeDeineOPDetailsImProfil =>
      'Hinterlege deine OP-Details im Profil';

  @override
  String get hinweistextOptional => 'Notice text (optional)';

  @override
  String get homeSummaryCardFaellig => 'fällig';

  @override
  String get ihreAntwortEingeben => 'Enter your answer…';

  @override
  String get inaktiv3Tage => 'Inaktiv >3 Tage';

  @override
  String get itemBearbeiten => 'Item bearbeiten';

  @override
  String get jaehrlich => 'Jährlich';

  @override
  String get jederzeitNkuendbar => 'Jederzeit\\nkündbar';

  @override
  String get keineAufgabenImPlan => 'No tasks in the plan yet.';

  @override
  String get keineEmailApp => 'No email app found';

  @override
  String get keineOffenenEinladungen => 'Keine offenen Einladungen.';

  @override
  String get keinUebernachtenNurDasNoetigste =>
      'Kein Übernachten – nur das Nötigste';

  @override
  String get keyIdOderUidSuchen => 'Search key ID or redeemer UID…';

  @override
  String get kontaktierenSieIhrenArzt => 'Kontaktieren Sie Ihren Arzt';

  @override
  String get kVNummerOptional => 'KV-Nummer (optional)';

  @override
  String get letzteDokumente => 'Letzte Dokumente';

  @override
  String get letzteEinnahmen => 'Letzte Einnahmen';

  @override
  String get letzteVitalwerte => 'Letzte Vitalwerte';

  @override
  String get linkKopieren => 'Link kopieren';

  @override
  String get losGehts => 'Let’s go';

  @override
  String get medikament => 'Medikament *';

  @override
  String get meilensteineUndZiele => 'Meilensteine & Ziele';

  @override
  String get meinProfil => 'Mein Profil';

  @override
  String get memosDurchsuchen => 'Memos durchsuchen…';

  @override
  String get mitArztVerbinden => 'Mit Arzt verbinden';

  @override
  String get mitMedikation => 'Mit Medikation';

  @override
  String get mitUebernachtungVollstaendigeListe =>
      'Mit Übernachtung – vollständige Liste';

  @override
  String get monatlichKuendbar => 'cancel monthly';

  @override
  String get monthApril => 'April';

  @override
  String get monthAugust => 'August';

  @override
  String get monthDecember => 'December';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthJuly => 'July';

  @override
  String get monthJune => 'June';

  @override
  String get monthMarch => 'March';

  @override
  String get monthMay => 'May';

  @override
  String get monthNovember => 'November';

  @override
  String get monthOctober => 'October';

  @override
  String get monthSeptember => 'September';

  @override
  String get n7TageTreue => '7-Tage Treue';

  @override
  String get nachrichtSchreiben => 'Nachricht schreiben...';

  @override
  String get nachRolleFiltern => 'Filter by role';

  @override
  String get naechsteTermine => 'Nächste Termine';

  @override
  String get neuerKey => 'New key';

  @override
  String get neuerName => 'New name';

  @override
  String get neuesPacklistenItem => 'Neues Packlisten-Item';

  @override
  String get neuesPasswort => 'New password';

  @override
  String get nochKeineAngehoerigenVerbunden =>
      'Noch keine Angehörigen verbunden.';

  @override
  String get nochKeineBeobachtungen => 'Noch keine Beobachtungen.';

  @override
  String get nochKeineDokumentation => 'Noch keine Dokumentation';

  @override
  String get notaufnahmeAufsuchen => 'Notaufnahme aufsuchen';

  @override
  String get notificationCenterNotizOptional => 'Notiz (optional)';

  @override
  String get notruf112Anrufen => 'Notruf 112 anrufen';

  @override
  String get nurInDebugBuilds => 'Only available in debug builds.';

  @override
  String get nurVomArztVerwaltbar => 'Nur vom Arzt verwaltbar';

  @override
  String get nutzerGesamt => 'Nutzer gesamt';

  @override
  String get oeffnenTeilen => 'Öffnen / Teilen';

  @override
  String get offeneFragen => 'Offene Fragen';

  @override
  String get offeneRedFlags => 'Offene Red Flags';

  @override
  String get ohneMedikation => 'Ohne Medikation';

  @override
  String get opActions => 'Actions';

  @override
  String get oPDatum => 'OP Datum';

  @override
  String get opDetails => 'Surgery Details';

  @override
  String get opDocumentsLabel => 'Documents';

  @override
  String get opManageCaregivers => 'Manage\nCaregivers';

  @override
  String get opName => 'Surgery Name';

  @override
  String get opSymptomsLabel => 'Symptoms';

  @override
  String get opTimeline => 'Timeline';

  @override
  String get opType => 'Surgery Type';

  @override
  String get oPUndTimeline => 'OP & Timeline';

  @override
  String get packingItemEditorSheetNotizOptional => 'Notiz (optional)';

  @override
  String get patientAuswaehlen => 'Select patient';

  @override
  String get patientBasisdaten => 'Patient Basisdaten';

  @override
  String get patientenBegleiten => 'Patienten begleiten';

  @override
  String get perEMail => 'Per E-Mail';

  @override
  String get placeholderLoading => 'Loading…';

  @override
  String get praxisnameOptional => 'Praxisname (optional)';

  @override
  String get prioritaet => 'Priority';

  @override
  String get profilGespeichert => 'Profile saved.';

  @override
  String get proKeyErstellen => 'Pro-Key erstellen';

  @override
  String get proSatz => 'pro Satz';

  @override
  String get proStatus => 'Pro Status';

  @override
  String get pushBenachrichtigungenVersenden =>
      'Push-Benachrichtigungen versenden';

  @override
  String get pushPushSenden => 'Push senden?';

  @override
  String get pushSenden => 'Push';

  @override
  String get recoveryFeed => 'Recovery Feed';

  @override
  String get redU2011FlagSystem => 'Red\\u2011Flag System';

  @override
  String get reportSchmerz => 'Schmerz-Ø';

  @override
  String get reportTagePostOP => 'Tage post-OP';

  @override
  String get rfActiveWarnings => 'Active Warnings';

  @override
  String get rfCheckStart => 'Start Check';

  @override
  String get rfEmergencyFollowSteps => 'Follow these steps in order.';

  @override
  String get rfEmergencyInstructions => 'Emergency Instructions';

  @override
  String get rfEmergencyStep1Desc => 'Sit or lie down. Breathe calmly.';

  @override
  String get rfEmergencyStep1Title => 'Stay calm';

  @override
  String get rfEmergencyStep2Desc =>
      'Note your current complaints and their severity.';

  @override
  String get rfEmergencyStep2Title => 'Check symptoms';

  @override
  String get rfEmergencyStep3Desc =>
      'Call your doctor or clinic and describe the symptoms.';

  @override
  String get rfEmergencyStep3Title => 'Call doctor';

  @override
  String get rfEmergencyStep4Desc =>
      'For shortness of breath, unconsciousness or severe bleeding, immediately call 112.';

  @override
  String get rfEmergencySubtitle =>
      'Immediate measures for shortness of breath, unconsciousness or severe bleeding.';

  @override
  String get rfEscalate => 'Escalate';

  @override
  String get rfNoActiveWarnings => 'No active warnings. Keep it up!';

  @override
  String get rfNoFlags => 'No Red Flags';

  @override
  String get rfProAutoDetect =>
      'With Pro, the system automatically detects critical values from pain, vitals & more.';

  @override
  String get rfProFeatureSubtitle =>
      'Enter complaints manually or upgrade to Pro.';

  @override
  String get rfProFeatureTitle =>
      'Automatic red flag detection is a Pro feature.';

  @override
  String get rfSeverityDescGreen =>
      'Your values are within normal range. Keep it up!';

  @override
  String get rfSeverityDescOrange =>
      'Several values abnormal. Contact your doctor soon.';

  @override
  String get rfSeverityDescRed =>
      'Critical values detected. Immediate medical attention recommended.';

  @override
  String get rfSeverityDescYellow =>
      'Some values slightly outside normal range. Please monitor.';

  @override
  String get rfSeverityOrange => 'Orange';

  @override
  String get rfSeverityRed => 'Red';

  @override
  String get rfSeverityTitleGreen => 'All OK';

  @override
  String get rfSeverityTitleOrange => 'Elevated Risk';

  @override
  String get rfSeverityTitleRed => 'Act Now';

  @override
  String get rfSeverityTitleYellow => 'Slight Abnormality';

  @override
  String get rfSeverityYellow => 'Yellow';

  @override
  String get rfSourceManual => 'Manual';

  @override
  String get rfSourceObservation => 'Observation';

  @override
  String get rfSourcePain => 'Pain';

  @override
  String get rfSourceSymptomCheck => 'Symptom Check';

  @override
  String get rfSourceTimeline => 'Timeline Task';

  @override
  String get rfSourceVitals => 'Vital Signs';

  @override
  String get rfSourceWarningCheck => 'Warning Check';

  @override
  String get rfSourceWound => 'Wound Data';

  @override
  String get rfStatusAcknowledged => 'Seen';

  @override
  String get rfStatusEscalated => 'Escalated';

  @override
  String get rfStatusMonitoring => 'Monitoring';

  @override
  String get rfStatusOpen => 'Open';

  @override
  String get rfStatusResolved => 'Resolved';

  @override
  String get rfWarningCheckSubtitle =>
      'Quick check of the most important symptoms – takes only 30 seconds.';

  @override
  String get roleDebug => 'Role Debug';

  @override
  String get rolleAuswaehlen => 'Select role';

  @override
  String get scannbarerCodeZumBeitreten => 'Scannbarer Code zum Beitreten';

  @override
  String get schalteLevelXPTrackingUndMehrFrei =>
      'Schalte Level, XP-Tracking und mehr frei';

  @override
  String get schlaf => 'Ø Schlaf';

  @override
  String get schlafOptional => 'Schlaf (optional)';

  @override
  String get schmerz => 'Ø Schmerz';

  @override
  String get schmerztagebuchLetzte7Tage => 'Schmerztagebuch letzte 7 Tage';

  @override
  String get schmerztrend7Tage => 'Schmerztrend (7 Tage)';

  @override
  String get searchHint => 'Search…';

  @override
  String get sectionAccompany => 'Accompany';

  @override
  String get sectionAdsAdmin => 'Ads Admin';

  @override
  String get sectionAnalysis => 'Analysis';

  @override
  String get sectionAnalytics => 'Analytics';

  @override
  String get sectionConnectDoctor => 'Connect Doctor';

  @override
  String get sectionDebugTools => 'Debug Tools';

  @override
  String get sectionDoctorQuestions => 'Doctor Questions';

  @override
  String get sectionDoctorReport => 'Doctor Report';

  @override
  String get sectionDocumentation => 'Documentation';

  @override
  String get sectionDocuments => 'Documents';

  @override
  String get sectionEmergencyInfo => 'Emergency Info';

  @override
  String get sectionFirebaseTest => 'Firebase Test';

  @override
  String get sectionHealth => 'Health';

  @override
  String get sectionHealthReport => 'Health Report';

  @override
  String get sectionHelp => 'Help';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get sectionMedication => 'Medication';

  @override
  String get sectionMood => 'Mood';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionNutrition => 'Nutrition';

  @override
  String get sectionOpInfo => 'Surgery Info';

  @override
  String get sectionOpPlanning => 'Surgery & Planning';

  @override
  String get sectionPackingList => 'Packing List';

  @override
  String get sectionPain => 'Pain';

  @override
  String get sectionPeople => 'People';

  @override
  String get sectionPhotos => 'Photos';

  @override
  String get sectionProfile => 'Profile';

  @override
  String get sectionProgress => 'Progress';

  @override
  String get sectionRecentlyUsed => 'Recently Used';

  @override
  String get sectionRedFlags => 'Red Flags';

  @override
  String get sectionRehabilitation => 'Rehabilitation';

  @override
  String get sectionRoleDebug => 'Role Debug';

  @override
  String get sectionSleep => 'Sleep';

  @override
  String get sectionSupplements => 'Supplements';

  @override
  String get sectionSymptomCheck => 'Symptom Check';

  @override
  String get sectionVitals => 'Vital Signs';

  @override
  String get sectionVoiceNotes => 'Voice Notes';

  @override
  String get sichereNZahlung => 'Sichere\\nZahlung';

  @override
  String get sofortDokumentieren => 'Sofort dokumentieren';

  @override
  String get sonstige => 'Other';

  @override
  String get spracheUndMemos => 'Sprache & Memos';

  @override
  String get statistikenAktualisieren => 'Refresh statistics';

  @override
  String get statsNichtAktualisiert => 'Stats could not be updated.';

  @override
  String get statusFiltern => 'Filter status';

  @override
  String get stimmung => 'Ø Stimmung';

  @override
  String get sucheInAktionenDetailsUID => 'Suche in Aktionen, Details, UID…';

  @override
  String get sucheNachBetreffEMail => 'Suche nach Betreff, E-Mail…';

  @override
  String get sucheNachTitelOderOrt => 'Search by title or location…';

  @override
  String get suchenNameEMailFachrichtung =>
      'Suchen (Name, E-Mail, Fachrichtung)…';

  @override
  String get suchenNameEmailUid => 'Search (name, email or UID)…';

  @override
  String get taeglicheChallenges => 'Tägliche Challenges';

  @override
  String get tagEingeben => 'Enter day...';

  @override
  String get tagePostOP => 'Tage post-OP';

  @override
  String get templateFollowupActivitySubtitle =>
      'Gradually increase activity – listen to your body';

  @override
  String get templateFollowupActivityTitle => 'Increase Activity';

  @override
  String get templateFollowupDay14Subtitle => 'Second progress check';

  @override
  String get templateFollowupDay21Subtitle => 'Third progress check';

  @override
  String get templateFollowupDay28Subtitle => 'Final examination and clearance';

  @override
  String get templateFollowupDay28Title => 'Final Check-up';

  @override
  String get templateFollowupDay7Subtitle => 'Progress check at the practice';

  @override
  String get templateFollowupDay7Title => 'Follow-up Appointment';

  @override
  String get templateFollowupScarCareSubtitle =>
      'Gently moisturize and observe the scar';

  @override
  String get templateFollowupScarCareTitle => 'Scar Care';

  @override
  String get templateFollowupWeeklyCheckSubtitle =>
      'Evaluate and document healing progress';

  @override
  String get templateFollowupWeeklyCheckTitle => 'Weekly Self-Check';

  @override
  String get templateFollowupWoundPhotoSubtitle =>
      'Continue documenting healing progress';

  @override
  String get templateFollowupWoundPhotoTitle => 'Take Wound Photo';

  @override
  String get templateMedsEveningSubtitle => 'Evening dose as prescribed';

  @override
  String get templateMedsMiddaySubtitle => 'Midday dose as prescribed';

  @override
  String get templateMedsMorningSubtitle => 'Morning dose as prescribed';

  @override
  String get templateMedsMorningTitle => 'Take Medication';

  @override
  String get templateOpdayAdmissionSubtitle =>
      'Please arrive at the clinic on time';

  @override
  String get templateOpdayAdmissionTitle => 'Admission';

  @override
  String get templateOpdayFastingSubtitle =>
      'Do not eat or drink as instructed';

  @override
  String get templateOpdayFastingTitle => 'Check Fasting';

  @override
  String get templateOpdayInfoSubtitle =>
      'Clarify open questions with the team';

  @override
  String get templateOpdayInfoTitle => 'Confirm Surgery Info';

  @override
  String get templateOpdayMobilizationSubtitle =>
      'Sit up/stand briefly with support';

  @override
  String get templateOpdayMobilizationTitle => 'First Mobilization';

  @override
  String get templatePreopBagSubtitle => 'Pack documents, clothes, and charger';

  @override
  String get templatePreopBagTitle => 'Pack Hospital Bag';

  @override
  String get templatePreopCompanionSubtitle =>
      'Coordinate travel and meeting point';

  @override
  String get templatePreopCompanionTitle => 'Inform Companion';

  @override
  String get templatePreopDocumentsSubtitle =>
      'Prepare insurance card and findings';

  @override
  String get templatePreopDocumentsTitle => 'Check Documents';

  @override
  String get templateWeek1AbdominalSupportSubtitle =>
      'Check fit and wearing method';

  @override
  String get templateWeek1AbdominalSupportTitle => 'Check Abdominal Support';

  @override
  String get templateWeek1BackPostureSubtitle =>
      'No twisting or bending of the spine';

  @override
  String get templateWeek1BackPostureTitle => 'Back Protection Posture';

  @override
  String get templateWeek1BloodPressureSubtitle =>
      'Document values morning and evening';

  @override
  String get templateWeek1BloodPressureTitle => 'Measure Blood Pressure';

  @override
  String get templateWeek1BowelDiarySubtitle =>
      'Monitor digestion – important for diet build-up';

  @override
  String get templateWeek1BowelDiaryTitle => 'Document Bowel Movement';

  @override
  String get templateWeek1BreathingCardioSubtitle =>
      'Deep breaths for lung care – especially important after heart surgery';

  @override
  String get templateWeek1BreathingCardioTitle => 'Breathing Exercises';

  @override
  String get templateWeek1BreathingSpineSubtitle =>
      'Deep breaths – back straight, breathe gently';

  @override
  String get templateWeek1BreathingSpineTitle => 'Breathing Exercises';

  @override
  String get templateWeek1CardiacRehabSubtitle =>
      'Light walking, slowly build circulation';

  @override
  String get templateWeek1CardiacRehabTitle => 'Cardiac Rehab Exercises';

  @override
  String get templateWeek1CompressionSubtitle =>
      'Check fit and condition of stockings';

  @override
  String get templateWeek1CompressionTitle => 'Check Compression Stockings';

  @override
  String get templateWeek1DietBuildupSubtitle =>
      'Light food, soft diet → gradually increase';

  @override
  String get templateWeek1DietBuildupTitle => 'Diet Build-up';

  @override
  String get templateWeek1DressingSubtitle =>
      'Check and document dressing condition';

  @override
  String get templateWeek1DressingTitle => 'Dressing Check';

  @override
  String get templateWeek1HydrationSubtitle =>
      'At least 1.5 liters of fluid per day';

  @override
  String get templateWeek1HydrationTitle => 'Check Fluid Intake';

  @override
  String get templateWeek1JointRomSubtitle =>
      'Carefully test bending and stretching';

  @override
  String get templateWeek1JointRomTitle => 'Check Joint Mobility';

  @override
  String get templateWeek1LegExercisesSubtitle =>
      'Circle feet, tense legs – thrombosis prevention';

  @override
  String get templateWeek1LegExercisesTitle => 'Do Leg Exercises';

  @override
  String get templateWeek1MobilizationSubtitle =>
      'Mobilize slowly – even small steps count';

  @override
  String get templateWeek1MobilizationTitle => 'Get Up & Move Briefly';

  @override
  String get templateWeek1NoStrainingSubtitle =>
      'Avoid straining, roll sideways when getting up';

  @override
  String get templateWeek1NoStrainingTitle => 'Abdominal Protection';

  @override
  String get templateWeek1OrthosisSubtitle => 'Check fit and wearing time';

  @override
  String get templateWeek1OrthosisTitle => 'Check Orthosis/Corset';

  @override
  String get templateWeek1PainScoreSubtitle => 'Enter pain level in the app';

  @override
  String get templateWeek1PainScoreTitle => 'Record Pain Level';

  @override
  String get templateWeek1RedFlagsSubtitle =>
      'Fever, redness, swelling, severe pain?';

  @override
  String get templateWeek1RedFlagsTitle => 'Check Warning Signs';

  @override
  String get templateWeek1SpineStabilizationSubtitle =>
      'Core stabilization as instructed – gradually increase';

  @override
  String get templateWeek1SpineStabilizationTitle => 'Stabilization Exercises';

  @override
  String get templateWeek1SternumSubtitle =>
      'No lifting over 5 kg, keep arms close to body';

  @override
  String get templateWeek1SternumTitle => 'Sternum Protection';

  @override
  String get templateWeek1VitalsSubtitle => 'Note pulse/temperature briefly';

  @override
  String get templateWeek1VitalsTitle => 'Check Vitals';

  @override
  String get templateWeek1WoundPhotoSubtitle =>
      'Document photo for progress tracking';

  @override
  String get templateWeek1WoundPhotoTitle => 'Take Wound Photo';

  @override
  String get templateWeek2CardiacWalkSubtitle =>
      'Gradually increase walking distance, monitor pulse';

  @override
  String get templateWeek2CardiacWalkTitle => 'Cardiac Rehab Walk';

  @override
  String get templateWeek2DietNormalizeSubtitle =>
      'Monitor digestion – slowly transition to normal diet';

  @override
  String get templateWeek2DietNormalizeTitle => 'Build Normal Diet';

  @override
  String get templateWeek2GaitSubtitle =>
      'Practice safe walking with/without aids';

  @override
  String get templateWeek2GaitTitle => 'Gait Training';

  @override
  String get templateWeek2PainSubtitle =>
      'Document pain progress – is it getting better?';

  @override
  String get templateWeek2PainTitle => 'Pain Diary';

  @override
  String get templateWeek2PhysioSubtitle => 'Perform exercises as instructed';

  @override
  String get templateWeek2PhysioTitle => 'Physiotherapy Exercises';

  @override
  String get templateWeek2WalkSubtitle =>
      'Walk a bit further each day – strengthen circulation';

  @override
  String get templateWeek2WalkTitle => 'Take a Walk';

  @override
  String get templateWeek2WoundObserveSubtitle =>
      'Monitor and document healing progress';

  @override
  String get templateWeek2WoundObserveTitle => 'Observe Wound';

  @override
  String get templateWeek1SymptomCheckSubtitle =>
      'How are you feeling today? Check and document your symptoms';

  @override
  String get templateWeek1SymptomCheckTitle => 'Symptom Check';

  @override
  String get termineNaechste14Tage => 'Termine nächste 14 Tage';

  @override
  String get testBenachrichtigungErstellen => 'Create test notification';

  @override
  String get ticketChatNachrichtSchreiben => 'Nachricht schreiben…';

  @override
  String get ticketErstellen => 'Create ticket';

  @override
  String get timelineAddNoteContent => 'Content (optional)';

  @override
  String get timelineAddTaskDescription => 'Description (optional)';

  @override
  String get timelineAddTaskTitle => 'Title';

  @override
  String get timelineBesserOrganisieren => 'Timeline besser organisieren';

  @override
  String get timelineDue => 'Due';

  @override
  String get timelineFriday => 'Friday';

  @override
  String get timelineMonday => 'Monday';

  @override
  String get timelineMyPlan => 'My Plan';

  @override
  String get timelineNoOpenTasks => 'No open tasks today';

  @override
  String get timelinePhaseDefault => 'Phase';

  @override
  String get timelinePhaseFollowup => 'Follow-up';

  @override
  String get timelinePhaseOpday => 'Surgery Day';

  @override
  String get timelinePhasePersonal => 'My Entries';

  @override
  String get timelinePhasePreop => 'Preparation';

  @override
  String get timelinePhaseWeek1 => 'Week 1 · Healing & Monitoring';

  @override
  String get timelinePhaseWeek2 => 'Week 2 · Activation';

  @override
  String get timelinePlanComplete => 'Your plan is currently all done';

  @override
  String get timelineRouteAppointment => 'Add Appointment';

  @override
  String get timelineRouteAppointmentDesc =>
      'Create and manage your surgery-related appointments.';

  @override
  String get timelineRouteDocuments => 'Upload Documents';

  @override
  String get timelineRouteMedication => 'Medication';

  @override
  String get timelineRouteMoodLog => 'Mood Diary';

  @override
  String get timelineRouteMoodLogDesc =>
      'Track your mood and recognize patterns in your emotional well-being.';

  @override
  String get timelineRouteNoteAdd => 'Create Note';

  @override
  String get timelineRouteNoteAddDesc => 'Add a free entry to your timeline.';

  @override
  String get timelineRouteNutrition => 'Nutrition Diary';

  @override
  String get timelineRouteNutritionDesc =>
      'Document your meals and get nutrition recommendations.';

  @override
  String get timelineRoutePainLog => 'Pain Diary';

  @override
  String get timelineRoutePainLogDesc =>
      'Document your pain level on a scale of 1–10.';

  @override
  String get timelineRouteQuestions => 'Questions & Notes';

  @override
  String get timelineRouteQuestionsDesc =>
      'Keep track of questions for your surgeon and personal notes.';

  @override
  String get timelineRouteRedFlag => 'Red-Flag Cockpit';

  @override
  String get timelineRouteRedFlagDesc =>
      'Check active warnings and emergency actions.';

  @override
  String get timelineRouteRehab => 'Rehab';

  @override
  String get timelineRouteRehabDesc =>
      'Opens the rehab overview for exercises and progress.';

  @override
  String get timelineRouteSleepLog => 'Sleep Diary';

  @override
  String get timelineRouteSleepLogDesc =>
      'Document your sleep duration and quality.';

  @override
  String get timelineRoutesNotizErstellen854 => 'Notiz erstellen';

  @override
  String get timelineRouteSymptomCheck => 'Symptom Check';

  @override
  String get timelineRouteTaskAdd => 'Add Task';

  @override
  String get timelineRouteTaskAddDesc =>
      'Create a custom task for your surgery preparation.';

  @override
  String get timelineRouteTransport => 'Transport';

  @override
  String get timelineRouteTransportDesc =>
      'Plan your trip to and from the clinic.';

  @override
  String get timelineRouteVitals => 'Vitals';

  @override
  String get timelineRouteWoundDoc => 'Wound Documentation';

  @override
  String get timelineSaturday => 'Saturday';

  @override
  String get timelineSheetDocUpload => 'Upload document';

  @override
  String get timelineSheetPainLevel => 'Pain level';

  @override
  String get timelineSheetWoundPhoto => 'Wound photo';

  @override
  String get timelineSunday => 'Sunday';

  @override
  String get timelineThursday => 'Thursday';

  @override
  String get timelineToday => 'Today';

  @override
  String get timelineTomorrow => 'Tomorrow';

  @override
  String get timelineTransportDriver => 'Driver';

  @override
  String get timelineTransportHint => 'Plan your trip to and from the clinic.';

  @override
  String get timelineTransportNotes => 'Notes';

  @override
  String get timelineTransportOutbound => 'Outbound (Time / Meeting Point)';

  @override
  String get timelineTransportReturn => 'Return (Time / Meeting Point)';

  @override
  String get timelineTuesday => 'Tuesday';

  @override
  String get timelineVerknuepfung => 'Timeline-Verknüpfung';

  @override
  String get timelineViewFullPlan => 'View full plan';

  @override
  String get timelineWednesday => 'Wednesday';

  @override
  String get timelineZusammenfassung => 'Timeline Zusammenfassung';

  @override
  String get timerStarten => 'Timer starten';

  @override
  String get titelBeschreibung => 'Titel / Beschreibung';

  @override
  String get transkriptBearbeiten => 'Edit transcript…';

  @override
  String get uebungSuchen => 'Search exercise…';

  @override
  String get userSuchen => 'User suchen';

  @override
  String get userUID => 'User UID';

  @override
  String get verbindungFehlgeschlagen => 'Connection failed. Please try again.';

  @override
  String get verbindungTrennen => 'Disconnect';

  @override
  String get verfolgeDeineRecoveryMeilensteine =>
      'Verfolge deine Recovery-Meilensteine';

  @override
  String get voiceMemosMemosDurchsuchen => 'Memos durchsuchen…';

  @override
  String get vordefinierteVorlagenVerwalten =>
      'Vordefinierte Vorlagen verwalten';

  @override
  String get vorDerOP => 'Vor der OP';

  @override
  String get vorlage => 'Template';

  @override
  String get vorlagenDurchsuchen => 'Search templates...';

  @override
  String get wannZumArzt => 'Wann zum Arzt?';

  @override
  String get warnCall112 => 'Call 112';

  @override
  String get warnCheckLabel => 'Quick check:';

  @override
  String get warnContactClinic => 'Contact the clinic for these signs:';

  @override
  String get warnEmergencySubtitle => 'For life-threatening symptoms!';

  @override
  String get warnEmergencyTitle => 'Emergency?';

  @override
  String get warnItemBleedingQ1 =>
      'Is the bleeding active and cannot be stopped?';

  @override
  String get warnItemBleedingQ2 =>
      'Is the bandage already completely soaked through?';

  @override
  String get warnItemBleedingQ3 => 'Do you feel dizzy or weak?';

  @override
  String get warnItemBleedingSubtitle => 'Blood soaks through bandage quickly';

  @override
  String get warnItemBleedingTitle => 'Severe Bleeding';

  @override
  String get warnItemBreathQ1 => 'Does the shortness of breath occur at rest?';

  @override
  String get warnItemBreathQ2 => 'Is the shortness of breath getting worse?';

  @override
  String get warnItemBreathQ3 => 'Do you have pain when breathing?';

  @override
  String get warnItemBreathSubtitle => 'Shortness of breath or air hunger';

  @override
  String get warnItemBreathTitle => 'Shortness of Breath';

  @override
  String get warnItemFeverQ1 => 'Have you taken your temperature?';

  @override
  String get warnItemFeverQ2 => 'Is the temperature above 38.5 °C?';

  @override
  String get warnItemFeverQ3 => 'Do you have chills?';

  @override
  String get warnItemFeverSubtitle => 'Temperature above 38.5 °C';

  @override
  String get warnItemFeverTitle => 'High Fever';

  @override
  String get warnItemPainQ1 => 'Is the pain significantly stronger than usual?';

  @override
  String get warnItemPainQ2 => 'Do your usual pain medications no longer help?';

  @override
  String get warnItemPainQ3 => 'Is the painful area swollen or hot?';

  @override
  String get warnItemPainSubtitle => 'Suddenly increasing, uncontrollable';

  @override
  String get warnItemPainTitle => 'Severe Pain';

  @override
  String get warnItemRednessQ1 => 'Is the redness spreading?';

  @override
  String get warnItemRednessQ2 => 'Is the area warm or hot?';

  @override
  String get warnItemRednessQ3 => 'Is there pus or discharge?';

  @override
  String get warnItemRednessSubtitle => 'Wound area appears inflamed';

  @override
  String get warnItemRednessTitle => 'Increasing Redness / Swelling';

  @override
  String get warnItemSmellQ1 => 'Does the discharge have an unusual color?';

  @override
  String get warnItemSmellQ2 => 'Does the wound smell distinctly unpleasant?';

  @override
  String get warnItemSmellQ3 => 'Has the amount of discharge increased?';

  @override
  String get warnItemSmellSubtitle => 'Unusual discharge from the wound';

  @override
  String get warnItemSmellTitle => 'Foul-smelling Discharge';

  @override
  String get warnSaveCheck => 'Save check';

  @override
  String get warnTitle => 'Warning Signs';

  @override
  String get warnzeichenStatus => 'Warnzeichen Status';

  @override
  String get wartungsmodusDeaktivieren => 'Wartungsmodus deaktivieren';

  @override
  String get wasBeschaeftigtDich => 'What\'s on your mind right now?';

  @override
  String get wasBeschreibtDeineStimmung => 'Was beschreibt deine Stimmung?';

  @override
  String get wasHastDuBeobachtet => 'Was hast du beobachtet?';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weiterDokumentieren => 'Weiter dokumentieren';

  @override
  String get weiterenPatientenHinzufuegen => 'Add another patient';

  @override
  String get werbungUndDatenschutz => 'Werbung & Datenschutz';

  @override
  String get wieGehtEsDir => 'Wie geht es dir?';

  @override
  String get woche1 => 'Woche 1';

  @override
  String get wochentage => 'Weekdays';

  @override
  String get woundDocumentationNeuesFotoAufnehmen => 'Neues Foto aufnehmen';

  @override
  String get wunddetailFehlendeArgumente => 'Wunddetail (fehlende Argumente)';

  @override
  String get wunddokuLetzte3 => 'Wunddoku letzte 3';

  @override
  String get wundeSchmerzBewegung => 'Wunde, Schmerz, Bewegung';

  @override
  String get wundschmerz => 'Ø Wundschmerz';

  @override
  String get wundvergleichFehlendeArgumente =>
      'Wundvergleich (fehlende Argumente)';

  @override
  String get xPUndLevelSystem => 'XP & Level-System';

  @override
  String get zBA1B2C3D4 => 'z.B. A1B2C3D4';

  @override
  String get zBA1B2C3D4E5F6 => 'z.B. A1B2C3D4E5F6';

  @override
  String get zBArztAnrufen => 'z.B. Arzt anrufen';

  @override
  String get zbBefund => 'e.g. Finding';

  @override
  String get zbDieBlaue => 'e.g. The blue one, not the red one';

  @override
  String get zbNachDemEssen => 'e.g. take with water after meals';

  @override
  String get zBRehaBadNauheim => 'z.B. Reha Bad Nauheim';

  @override
  String get zBRehaKlinikMustermann => 'z. B. Reha-Klinik Mustermann';

  @override
  String get zbUpdateWirdEingespielt => 'e.g. Update is being applied…';

  @override
  String get zeitfilterZuruecksetzen => 'Reset time filter';

  @override
  String get zeitraumFiltern => 'Zeitraum filtern';

  @override
  String get zuDenEinstellungen => 'Zu den Einstellungen';

  @override
  String get zurueckZurTimeline => 'Zurück zur Timeline';

  @override
  String anfrageAblehnenBestaetigung(String name) {
    return 'Do you want to reject the request from $name?';
  }

  @override
  String apptCalendarDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appointments',
      one: '$count appointment',
    );
    return '$_temp0';
  }

  @override
  String apptCreatedBy(String name) {
    return 'Created by $name';
  }

  @override
  String apptDeleteContent(String title) {
    return 'Do you really want to permanently delete “$title“?';
  }

  @override
  String apptReminderMinutes(int minutes) {
    return '$minutes min. before';
  }

  @override
  String apptRepeatUntilDate(String date) {
    return '(until $date)';
  }

  @override
  String aufgabenAuswaehlenCount(int selected, int total) {
    return 'Select tasks ($selected/$total):';
  }

  @override
  String aufgabenCount(int count) {
    return 'Tasks ($count)';
  }

  @override
  String aufgabenCountSelected(int count, String suffix) {
    return '$count task$suffix selected';
  }

  @override
  String bellaActionStatusCancelled(String label) {
    return '$label — cancelled';
  }

  @override
  String bellaActionStatusCreated(String label) {
    return '$label — created';
  }

  @override
  String bellaActionStatusFailed(String label) {
    return '$label — failed';
  }

  @override
  String bellaBriefingHttpError(int statusCode) {
    return 'Error creating briefing (HTTP $statusCode).';
  }

  @override
  String bellaDailyUsage(int used, int limit) {
    return '$used / $limit messages today';
  }

  @override
  String bellaProactiveDocGap(int days) {
    return 'You haven\'t logged anything in $days days';
  }

  @override
  String bellaProactiveMedReminder(String name) {
    return 'Have you taken your $name today?';
  }

  @override
  String bellaProactiveMedReminderMultiple(int count) {
    return 'Have you taken your medication today? ($count pending)';
  }

  @override
  String bellaProactiveOpenTasks(int count) {
    return 'You still have $count open tasks for today';
  }

  @override
  String bellaProactiveStreakAtRisk(int streak) {
    return 'Your $streak-day streak is at risk!';
  }

  @override
  String benachrichtigungenCountNeu(int count) {
    return 'Notifications ($count new)';
  }

  @override
  String caregiverEntfernt(String name) {
    return '$name was removed';
  }

  @override
  String cloneErstellt(String name) {
    return '\"$name\" created';
  }

  @override
  String doctorEntfernt(String name) {
    return '$name was removed';
  }

  @override
  String doctorHinzugefuegt(String name) {
    return '$name was added';
  }

  @override
  String dokumentGeloescht(String title) {
    return '\"$title\" deleted';
  }

  @override
  String erstelltVon(String name) {
    return 'Created by: $name';
  }

  @override
  String fehlerMitError(String error) {
    return 'Error: $error';
  }

  @override
  String gueltigFuerTage(int days) {
    return 'Valid for $days days';
  }

  @override
  String keysErstellt(int count) {
    return '$count keys created';
  }

  @override
  String medikamentEntfernt(String name) {
    return '$name removed';
  }

  @override
  String medikamentWiederhergestellt(String name) {
    return '$name restored';
  }

  @override
  String medikamentWirdEntfernt(String name) {
    return '$name will be removed.';
  }

  @override
  String mitarbeiterAction(String action) {
    return 'Staff member $action';
  }

  @override
  String mitarbeiterEntfernt(String name) {
    return '$name was removed';
  }

  @override
  String nameWurdeEntsperrt(String name) {
    return '$name was unblocked.';
  }

  @override
  String nameWurdeGeloescht(String name) {
    return '$name was deleted.';
  }

  @override
  String nameWurdeGesperrt(String name) {
    return '$name was blocked.';
  }

  @override
  String neuesPasswortFuer(String name) {
    return 'New password for $name';
  }

  @override
  String noSearchResults(String query) {
    return 'No results for “$query”';
  }

  @override
  String notizLoeschenBestaetigung(String title) {
    return 'Really delete \"$title\"?';
  }

  @override
  String partnerAnzeigenCount(int count) {
    return 'Partner ads ($count)';
  }

  @override
  String pushAnEmail(String email) {
    return 'Push to $email';
  }

  @override
  String pushAnEmailGesendet(String email) {
    return 'Push sent to $email.';
  }

  @override
  String pushAnTargetGesendet(String target) {
    return 'Push to $target sent!';
  }

  @override
  String rfActiveBadge(int count) {
    return '$count active';
  }

  @override
  String rfActiveCount(int count) {
    return 'Active ($count)';
  }

  @override
  String rfLevelBadge(String level) {
    return 'Level: $level';
  }

  @override
  String rfResolvedCount(int count) {
    return 'History ($count)';
  }

  @override
  String rolleGeaendert(String role) {
    return 'Role changed to \"$role\".';
  }

  @override
  String statusMitLabel(String label) {
    return 'Status: $label';
  }

  @override
  String tageVergeben(int days) {
    return '$days days granted';
  }

  @override
  String ticketsCountOffen(int count) {
    return 'Tickets ($count open)';
  }

  @override
  String timelineDoneOfTotal(int done, int total) {
    return '$done/$total done';
  }

  @override
  String timelineDueAttention(int count) {
    return '$count need attention today';
  }

  @override
  String timelineNextUp(String title) {
    return 'Next up: $title';
  }

  @override
  String timelinePhaseProgress(int done, int total) {
    return '$done/$total done';
  }

  @override
  String timelineProgressPercent(int percent) {
    return '$percent% done – keep going!';
  }

  @override
  String timelineStickyDoneOfTotal(int done, int total) {
    return '$done of $total done';
  }

  @override
  String timelineStickyDue(int count) {
    return '$count due';
  }

  @override
  String timelineStickyToday(int count) {
    return '$count today';
  }

  @override
  String timelineStreakDays(int count) {
    return '$count days';
  }

  @override
  String timelineTasksPlanned(int count) {
    return '$count tasks planned for today';
  }

  @override
  String unwiderruflichLoeschen(String title) {
    return '\"$title\" will be permanently deleted.';
  }

  @override
  String userAktionFehler(String action) {
    return 'User could not be ${action}ed.';
  }

  @override
  String vorlageErstellt(String name) {
    return 'Template \"$name\" created';
  }

  @override
  String vorlageLoeschenBestaetigung(String name) {
    return 'Do you really want to delete \"$name\"?';
  }

  @override
  String vorlageUebernommen(String name) {
    return '\"$name\" copied to own templates';
  }

  @override
  String warnLastCheck(String label, String date) {
    return 'Last check: $label · $date';
  }

  @override
  String warnzeichenGespeichert(String level) {
    return 'Warning sign check saved ($level)';
  }

  @override
  String get accountUndRechtliches => 'Account & Rechtliches';

  @override
  String get actionCall112 => 'Call 112';

  @override
  String get actionUnlock => 'Unlock';

  @override
  String get aktiveWarnungenUndNotfallaktionenPruefen =>
      'Aktive Warnungen und Notfallaktionen prüfen.';

  @override
  String get alertNotruf112 => 'Notruf 112';

  @override
  String get alleAbwaehlen => 'Deselect all';

  @override
  String get alleAuswaehlen => 'Select all';

  @override
  String get alleKategorienErledigt => 'Alle Kategorien erledigt!';

  @override
  String get alleTermineImBlick => 'Alle Termine im Blick';

  @override
  String get allesErledigt => 'Alles erledigt!';

  @override
  String get analyticsNutrition => 'Nutrition';

  @override
  String get analyticsOverview => 'Overview';

  @override
  String get analyticsPain => 'Pain';

  @override
  String get analyticsVitals => 'Vitals';

  @override
  String get analyticsWounds => 'Wounds';

  @override
  String get apptAllDay => 'All day';

  @override
  String get arztAnrufen => 'Arzt anrufen';

  @override
  String get arztKontaktieren => 'Arzt kontaktieren';

  @override
  String get aufgabeHinzufuegen => 'Aufgabe hinzufügen';

  @override
  String get aufgabenUndTimeline => 'Aufgaben & Timeline';

  @override
  String get aufmerksamkeitErforderlich => 'Aufmerksamkeit erforderlich';

  @override
  String get ausGalerie => 'Aus Galerie';

  @override
  String get ausZwischenNablageEinfuegen => 'Aus Zwischen-\\nablage einfügen';

  @override
  String get authServiceGoogleSignInWasCancelledByTheUser =>
      'Google sign-in was cancelled by the user.';

  @override
  String get badgeMedicationHero => 'Medication Hero';

  @override
  String get badgeMedicationHeroDesc => '7 days without a missed dose';

  @override
  String get badgeMoodTrackerDesc => 'Documented mood 20 times';

  @override
  String get badgePainTracker => 'Pain Tracker';

  @override
  String get badgePainTrackerDesc => 'Documented pain 20 times';

  @override
  String get bandscheibenOP44Jahre => 'Bandscheiben-OP, 44 Jahre';

  @override
  String get befundeUndBerichte => 'Befunde & Berichte';

  @override
  String get begleitetWerden => 'Begleitet werden';

  @override
  String get bellaAIGespraechsexport => 'Bella AI – Gesprächsexport';

  @override
  String get bevorIchLoslegenKannBraucheIchKurzDeineEinwilligung =>
      'Bevor ich loslegen kann, brauche ich kurz deine Einwilligung ';

  @override
  String get bevorstehendeArztUndKliniktermine =>
      'Bevorstehende Arzt- und Kliniktermine';

  @override
  String get bildAuswaehlen => 'Choose image';

  @override
  String get bitteGibEinenKeyEin => 'Bitte gib einen Key ein.';

  @override
  String get blutwerteAbgegeben => 'Blutwerte abgegeben';

  @override
  String caregiverRemoved(String name) {
    return '$name has been removed';
  }

  @override
  String get challengeGeschafft => 'Challenge geschafft!';

  @override
  String get checklisteFuerDieKlinik => 'Checkliste für die Klinik';

  @override
  String get cpAbdominalBelt => 'Check abdominal belt/support';

  @override
  String get cpAbdominalBeltDesc => 'Check fit and wearing method';

  @override
  String get cpAbdominalProtection => 'Abdominal muscle protection';

  @override
  String get cpAbdominalProtectionDesc =>
      'No straining, roll to the side when getting up';

  @override
  String get cpAdmission => 'Admission';

  @override
  String get cpAdmissionDesc => 'Please report to the clinic on time';

  @override
  String get cpBandageCheck => 'Bandage check';

  @override
  String get cpBandageCheckDesc => 'Check and document bandage condition';

  @override
  String get cpBreathingExercises => 'Breathing exercises';

  @override
  String get cpBreathingExercisesHeartDesc =>
      'Deep breaths for lung care – especially important after heart surgery';

  @override
  String get cpBreathingExercisesSpineDesc =>
      'Deep breaths – back straight, breathe gently';

  @override
  String get cpCardiacRehabExercises => 'Cardiac rehab exercises';

  @override
  String get cpCardiacRehabExercisesDesc =>
      'Light walking, gradually build circulation';

  @override
  String get cpCardiacRehabWalk => 'Cardiac rehab walk';

  @override
  String get cpCardiacRehabWalkDesc =>
      'Gradually increase walking distance, monitor pulse';

  @override
  String get cpCheckDocuments => 'Check documents';

  @override
  String get cpCheckDocumentsDesc =>
      'Prepare insurance card and medical records';

  @override
  String get cpCheckFasting => 'Check fasting status';

  @override
  String get cpCheckFastingDesc => 'No food or drink as instructed';

  @override
  String get cpCheckFluidIntake => 'Check fluid intake';

  @override
  String get cpCheckFluidIntakeDesc => 'At least 1.5 liters of fluids per day';

  @override
  String get cpCheckOrthosis => 'Check orthosis/corset';

  @override
  String get cpCheckOrthosisDesc => 'Check fit and wearing time';

  @override
  String get cpCheckVitals => 'Check vital signs';

  @override
  String get cpCheckVitalsDesc => 'Briefly note pulse/temperature';

  @override
  String get cpCheckWarnings => 'Check warning signs';

  @override
  String get cpCheckWarningsDesc => 'Fever, redness, swelling, severe pain?';

  @override
  String get cpCompressionStockings => 'Check compression stockings';

  @override
  String get cpCompressionStockingsDesc =>
      'Check fit and condition of stockings';

  @override
  String get cpConfirmOpInfo => 'Confirm surgery info';

  @override
  String get cpConfirmOpInfoDesc => 'Clarify open questions with the team';

  @override
  String get cpDietProgression => 'Diet progression';

  @override
  String get cpDietProgressionDesc =>
      'Light food, bland diet → gradually increase';

  @override
  String get cpDocumentBowel => 'Document bowel movements';

  @override
  String get cpDocumentBowelDesc =>
      'Monitor digestion – important for diet progression';

  @override
  String get cpEveningDose => 'Evening dose as scheduled';

  @override
  String get cpFinalCheck => 'Final check-up';

  @override
  String get cpFinalCheckDesc => 'Final examination and clearance';

  @override
  String get cpFirstMobilisation => 'First mobilisation';

  @override
  String get cpFirstMobilisationDesc => 'Briefly sit up/stand with support';

  @override
  String get cpFollowUpAppointment => 'Follow-up appointment';

  @override
  String get cpFollowUpDesc1 => 'Progress check at the clinic';

  @override
  String get cpFollowUpDesc2 => 'Second progress check';

  @override
  String get cpFollowUpDesc3 => 'Third progress check';

  @override
  String get cpGaitTraining => 'Gait training';

  @override
  String get cpGaitTrainingDesc => 'Practice safe walking with/without aids';

  @override
  String get cpGoForWalk => 'Go for a walk';

  @override
  String get cpGoForWalkDesc =>
      'Walk a little further every day – strengthen circulation';

  @override
  String get cpIncreaseActivity => 'Increase activity';

  @override
  String get cpIncreaseActivityDesc =>
      'Slowly increase activity – pay attention to body signals';

  @override
  String get cpInformCompanion => 'Inform companion';

  @override
  String get cpInformCompanionDesc => 'Coordinate travel and meeting point';

  @override
  String get cpLegExercises => 'Perform leg exercises';

  @override
  String get cpLegExercisesDesc =>
      'Circle feet, tense legs – thrombosis prevention';

  @override
  String get cpMorningDose => 'Morning dose as scheduled';

  @override
  String get cpNoonDose => 'Noon dose as scheduled';

  @override
  String get cpNormalDietProgression => 'Build up normal diet';

  @override
  String get cpNormalDietProgressionDesc =>
      'Monitor digestion – gradually return to normal diet';

  @override
  String get cpObserveWound => 'Observe wound';

  @override
  String get cpObserveWoundDesc => 'Monitor and document healing progress';

  @override
  String get cpPackHospitalBag => 'Pack hospital bag';

  @override
  String get cpPackHospitalBagDesc => 'Pack documents, clothing, and charger';

  @override
  String get cpPainDiary => 'Pain diary';

  @override
  String get cpPainDiaryDesc => 'Document pain progression – is it improving?';

  @override
  String get cpPhysioExercises => 'Physiotherapy exercises';

  @override
  String get cpPhysioExercisesDesc => 'Perform exercises as instructed';

  @override
  String get cpRecordPainLevel => 'Record pain level';

  @override
  String get cpRecordPainLevelDesc => 'Enter pain level in the app';

  @override
  String get cpScarCare => 'Scar care';

  @override
  String get cpScarCareDesc => 'Gently apply cream to scar and monitor';

  @override
  String get cpSpineProtection => 'Back protection posture';

  @override
  String get cpSpineProtectionDesc => 'No twisting or bending of the spine';

  @override
  String get cpStabilisationExercises => 'Stabilisation exercises';

  @override
  String get cpStabilisationExercisesDesc =>
      'Core stabilisation as instructed – gradually increase';

  @override
  String get cpSternumProtection => 'Sternum protection';

  @override
  String get cpSternumProtectionDesc =>
      'No lifting over 5 kg, keep arms close to body';

  @override
  String get cpTakeMedication => 'Take medication';

  @override
  String get cpTakeWoundPhoto => 'Take wound photo';

  @override
  String get cpTakeWoundPhotoDesc => 'Document photo for progress tracking';

  @override
  String get cpTakeWoundPhotoProgress => 'Take wound photo';

  @override
  String get cpTakeWoundPhotoProgressDesc =>
      'Continue documenting healing progress';

  @override
  String get cpWeeklySelfCheck => 'Weekly self-check';

  @override
  String get cpWeeklySelfCheckDesc => 'Evaluate and document healing progress';

  @override
  String get dasRehaSystemMitTimerIstGoldWert =>
      'Das Reha-System mit Timer ist Gold wert. ';

  @override
  String get datenEingeben => 'Daten eingeben';

  @override
  String debugEmail(String email) {
    return 'email: $email';
  }

  @override
  String get debugLinkedPatients => 'Linked Patients';

  @override
  String get debugNotAvailable => 'not available';

  @override
  String get debugNotLoggedIn => 'not logged in';

  @override
  String get debugOnlyForAdmins => 'Only available for admins.';

  @override
  String get debugOnlyInDebug => 'Only available in debug builds.';

  @override
  String debugRole(String role) {
    return 'role: $role';
  }

  @override
  String debugUid(String uid) {
    return 'uid: $uid';
  }

  @override
  String get deineHeutigeChallenge => 'Deine heutige Challenge';

  @override
  String get deineWochenZusammenfassung => 'Deine Wochen-Zusammenfassung';

  @override
  String get derNutzerVerliertSofortDenProZugang =>
      'Der Nutzer verliert sofort den Pro-Zugang.';

  @override
  String get dieserKeyIstAbgelaufen => 'Dieser Key ist abgelaufen.';

  @override
  String get dokuHubFuerKameraUndGalerie => 'Doku-Hub für Kamera & Galerie';

  @override
  String get dokumenteHochladen => 'Dokumente hochladen';

  @override
  String get duHastAlleAufgabenAbgeschlossenGoennDirEinePause =>
      'Du hast alle Aufgaben abgeschlossen. Gönn dir eine Pause.';

  @override
  String get duMusstAngemeldetSein => 'Du musst angemeldet sein.';

  @override
  String get einnahmeDokumentieren => 'Document intake';

  @override
  String get empty7DaysNoData => '7 days: no data';

  @override
  String get emptyNoMacros => 'No macros recorded';

  @override
  String get emptyNoNotifications => 'No notifications';

  @override
  String get emptyNoRedFlags => 'No open red flags';

  @override
  String get emptyNoVitals => 'No vital signs recorded yet';

  @override
  String get emptyNoVitalsShort => 'No vital signs yet';

  @override
  String get emptyTasksInPlan => 'No tasks in the plan yet.';

  @override
  String get emptyTodayNoEntries => 'Today: no entries';

  @override
  String get erinnerungenAnMedikamenteneinnahme =>
      'Erinnerungen an Medikamenteneinnahme';

  @override
  String get erstelle => 'Creating...';

  @override
  String get erstelleDeinKontoInWenigenSekunden =>
      'Erstelle dein Konto in wenigen Sekunden.';

  @override
  String get erstelleEineEigeneAufgabeFuerDeineOPVorbereitung =>
      'Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.';

  @override
  String get erstelleUndVerwalteDeineOPBezogenenTermine =>
      'Erstelle und verwalte deine OP-bezogenen Termine.';

  @override
  String get familyOverviewAufmerksamkeitErforderlich =>
      'Aufmerksamkeit erforderlich';

  @override
  String get fehlerBeimEinloesenBitteVersucheEsErneut =>
      'Fehler beim Einlösen. Bitte versuche es erneut.';

  @override
  String get fehlerBeimSpeichernErneut => 'Error saving. Please try again.';

  @override
  String fehlerGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String fehlerMitDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get fotoAufnehmen => 'Foto aufnehmen';

  @override
  String get fragenUndNotizen => 'Fragen & Notizen';

  @override
  String get fuegeDeineOPInformationenHinzu =>
      'Füge deine OP-Informationen hinzu.';

  @override
  String get googleSignInWasCancelledByTheUser =>
      'Google sign-in was cancelled by the user.';

  @override
  String get habenSieAtembeschwerdenOderKurzatmigkeit =>
      'Haben Sie Atembeschwerden oder Kurzatmigkeit?';

  @override
  String get halteEinenFreienEintragInDeinerTimelineFest =>
      'Halte einen freien Eintrag in deiner Timeline fest.';

  @override
  String get hintDescribeInDetail =>
      'Describe your concern in as much detail as possible…';

  @override
  String get hintShortDescription => 'Brief description of your concern';

  @override
  String get ichWarNervoesVorDerOPDieRedFlagWarnung =>
      'Ich war nervös vor der OP. Die Red-Flag Warnung ';

  @override
  String itemDeletedMessage(String title) {
    return '\"$title\" deleted';
  }

  @override
  String itemDeletedPermanently(String title) {
    return '\"$title\" will be permanently deleted.';
  }

  @override
  String get keyNichtGefunden => 'Key nicht gefunden.';

  @override
  String get knieTEP58Jahre => 'Knie-TEP, 58 Jahre';

  @override
  String get kritischerSymptomCheck => 'Kritischer Symptom-Check';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelContentOptional => 'Content (optional)';

  @override
  String get labelCustomMinutes => 'Custom Minutes';

  @override
  String get labelDescriptionOptional => 'Description (optional)';

  @override
  String get labelInviteCode => 'Invite Code';

  @override
  String labelInviteCodeValue(String code) {
    return 'Code: $code';
  }

  @override
  String get labelLinkType => 'Link Type';

  @override
  String get labelLocation => 'Location';

  @override
  String get labelLocationDetails => 'Location Details';

  @override
  String get labelNote => 'Note';

  @override
  String get labelObservation => 'Observation';

  @override
  String get labelReminder => 'Reminder';

  @override
  String get labelSubject => 'Subject';

  @override
  String get labelTitle => 'Title';

  @override
  String get labelTitleRequired => 'Title *';

  @override
  String get labelType => 'Type';

  @override
  String get mahlzeitenUndEmpfehlungen => 'Mahlzeiten & Empfehlungen';

  @override
  String get measurementSaved => 'Measurement saved';

  @override
  String get meinePatienten => 'Meine Patienten';

  @override
  String get memoAufnehmen => 'Memo aufnehmen';

  @override
  String get n7Tage => 'Ø 7 Tage';

  @override
  String get nachDerOP => 'Nach der OP';

  @override
  String get nachMeinerKnieOPHatteIchHundertFragen =>
      'Nach meiner Knie-OP hatte ich hundert Fragen. ';

  @override
  String get nachrichtNsenden => 'Nachricht\\nsenden';

  @override
  String get notifChannelAppointments => 'Reminders for upcoming appointments';

  @override
  String get notifChannelMedication => 'Medication Reminder';

  @override
  String get notifChannelMedicationDesc => 'Daily reminders for medications';

  @override
  String get notifChannelVitals => 'Vital Signs Reminder';

  @override
  String get notifChannelVitalsDesc =>
      'Daily reminder for vital sign measurements';

  @override
  String notifDoctorAnswered(String name) {
    return 'Dr. $name answered your question';
  }

  @override
  String get notifMeasureVitals => 'Measure vital signs';

  @override
  String notifObservationFrom(String name) {
    return 'Observation from $name';
  }

  @override
  String get notifWoundAlarm => 'Wound Alert';

  @override
  String get notizErstellen => 'Notiz erstellen';

  @override
  String get nutritionProteinG1110 => 'Protein (g)';

  @override
  String get oPAngelegt => 'OP angelegt';

  @override
  String get oPTag => 'OP‑Tag';

  @override
  String get oPTagWundeFrischVersorgtSterilerVerbandAngelegt =>
      'OP‑Tag. Wunde frisch versorgt, steriler Verband angelegt.';

  @override
  String get oeffnetDieRehaUebersichtFuerUebungenUndFortschritt =>
      'Öffnet die Reha-Übersicht für Übungen und Fortschritt.';

  @override
  String get operateurUndAnaesthesist => 'Operateur & Anästhesist';

  @override
  String get pain7Tage => 'Ø 7 Tage';

  @override
  String get painDiary7Tage => 'Ø 7 Tage';

  @override
  String get patientNhinzufuegen => 'Patient\\nhinzufügen';

  @override
  String get planeHinUndRueckfahrtZurKlinik =>
      'Plane Hin- und Rückfahrt zur Klinik.';

  @override
  String get proActiveSubtitle => 'All features unlocked';

  @override
  String get proActiveTitle => 'Pro active';

  @override
  String get proEntziehen => 'Remove Pro';

  @override
  String get proGeben => 'Give Pro';

  @override
  String get proStatusEntziehen => 'Pro-Status entziehen?';

  @override
  String get redFlagCockpit => 'Red-Flag Cockpit';

  @override
  String get rolleKonnteNichtGeladenWerden =>
      'Rolle konnte nicht geladen werden.';

  @override
  String get ruheBewahren => 'Ruhe bewahren';

  @override
  String get schmerzErfassen => 'Schmerz erfassen';

  @override
  String get setzenOderLegenSieSichHinAtmenSieRuhig =>
      'Setzen oder legen Sie sich hin. Atmen Sie ruhig.';

  @override
  String get sleepEntryEditorNotizOptional => 'Notiz (optional)';

  @override
  String get speichere => 'Saving...';

  @override
  String get speichert => 'Saving...';

  @override
  String get streakGerettet => 'Streak gerettet!';

  @override
  String get symptomCheckServiceNotruf112 => 'Notruf 112';

  @override
  String get symptomU2011Check => 'Symptom\\u2011Check';

  @override
  String systemVorlageFehler(String error) {
    return 'Error: $error';
  }

  @override
  String get timelineRoutesAufgabeHinzufuegen => 'Aufgabe hinzufügen';

  @override
  String get timelineRoutesNotizErstellen => 'Notiz erstellen';

  @override
  String get timelineTransportTitle => 'Transport Planning';

  @override
  String get trittMeinemOperationsbegleiterBeiNN =>
      'Tritt meinem Operationsbegleiter bei!\\n\\n';

  @override
  String get uebungenTimerUndFortschritt => 'Übungen, Timer & Fortschritt';

  @override
  String get updatesProStatusUndAppHinweise =>
      'Updates, Pro-Status & App-Hinweise';

  @override
  String userBlocked(String name) {
    return '$name has been blocked.';
  }

  @override
  String userDeleted(String name) {
    return '$name has been deleted.';
  }

  @override
  String userGesperrtEntsperrt(String action) {
    return 'User $action.';
  }

  @override
  String userUnblocked(String name) {
    return '$name has been unblocked.';
  }

  @override
  String get vitalsNotizOptional => 'Notiz (optional)';

  @override
  String get vorWaehrendUndNachDerOP => 'Vor, während & nach der OP';

  @override
  String get vorlageErzeugen => 'Create template';

  @override
  String warningCheckSaved(String level) {
    return 'Warning check saved ($level)';
  }

  @override
  String get warnungenBeiKritischenWundkontrollErgebnissen =>
      'Warnungen bei kritischen Wundkontroll-Ergebnissen';

  @override
  String get warnungenUndNotfall => 'Warnungen & Notfall';

  @override
  String get wieHastDuGeschlafen => 'Wie hast du geschlafen?';

  @override
  String get wieStarkSindIhreSchmerzenImOPBereich =>
      'Wie stark sind Ihre Schmerzen im OP-Bereich?';

  @override
  String get wirdZugewiesen => 'Assigning...';

  @override
  String get wunddokumentation => 'Wound documentation';

  @override
  String get wundenDokumentieren => 'Wunden dokumentieren';

  @override
  String get zusammenfassungFuerDenArzt => 'Zusammenfassung für den Arzt';

  @override
  String get rtsTitle => 'Return-to-Sport Test';

  @override
  String get rtsNewAssessment => 'Start New Test';

  @override
  String get rtsLatestResult => 'Latest Result';

  @override
  String get rtsHistory => 'Test History';

  @override
  String get rtsScore => 'Overall Score';

  @override
  String get rtsCleared => 'Cleared ✓';

  @override
  String get rtsAlmostReady => 'Almost Ready';

  @override
  String get rtsNotReady => 'Not Yet Ready';

  @override
  String get rtsClearedMessage =>
      'Your score is above the threshold. You may return to sport – please confirm with your physician first.';

  @override
  String get rtsAlmostReadyMessage =>
      'You\'re making good progress. Keep training and retest in a few weeks.';

  @override
  String get rtsNotReadyMessage =>
      'Your body needs more time. Focus on rehabilitation and strength training before returning to sport.';

  @override
  String get rtsEmptyTitle => 'Ready to Return to Sport?';

  @override
  String get rtsEmptySubtitle =>
      'Start your first fitness test. Instead of arbitrary time rules, measure strength, balance, and stability – and get an objective score for your return to sport.';

  @override
  String get rtsAssessmentTitle => 'Fitness Test';

  @override
  String get rtsResultTitle => 'Test Result';

  @override
  String get rtsBreakdown => 'Individual Results';

  @override
  String get rtsFinishAssessment => 'Calculate Score';

  @override
  String get rtsDeleteTitle => 'Delete Test';

  @override
  String get rtsDeleteConfirm =>
      'This test result will be permanently deleted.';

  @override
  String get rtsValidationHint => 'Please fill in all required fields.';

  @override
  String get rtsNotesLabel => 'Notes (optional)';

  @override
  String get rtsNotesHint => 'e.g. daily form, conditions …';

  @override
  String rtsStepOf(String current, String total) {
    return 'Step $current/$total';
  }

  @override
  String get rtsTestLsiTitle => 'Limb Symmetry Index (LSI)';

  @override
  String get rtsTestLsiDesc =>
      'Compare the performance of the affected side to the healthy side – e.g., single-leg hold time or reps of a unilateral exercise.';

  @override
  String get rtsTestLsiHint =>
      'Perform the same exercise on both sides and enter the values. An LSI ≥ 90 % is the recommended clearance threshold.';

  @override
  String get rtsLsiSeconds => 'Seconds';

  @override
  String get rtsLsiReps => 'Repetitions';

  @override
  String rtsLsiAffected(String unit) {
    return 'Affected side ($unit)';
  }

  @override
  String rtsLsiHealthy(String unit) {
    return 'Healthy side ($unit)';
  }

  @override
  String rtsLsiDetailValue(
    String affected,
    String healthy,
    String unit,
    String percent,
  ) {
    return 'Affected: $affected $unit / Healthy: $healthy $unit → LSI: $percent';
  }

  @override
  String get rtsTestBalanceTitle => 'Single-Leg Balance';

  @override
  String get rtsTestBalanceDesc =>
      'Stand on the affected leg and maintain balance as long as possible. Measure the time in seconds.';

  @override
  String get rtsTestBalanceHint =>
      'Perform the test on a stable flat surface. 30 seconds equals a full score.';

  @override
  String get rtsBalanceSeconds => 'Hold time (seconds)';

  @override
  String rtsBalanceDetailValue(String seconds) {
    return '$seconds seconds';
  }

  @override
  String get rtsTestStabilityTitle => 'Stability (Single-Leg Squat)';

  @override
  String get rtsTestStabilityDesc =>
      'How well can you perform a controlled single-leg squat on the affected leg?';

  @override
  String get rtsStability1 =>
      '1 – Not possible, severe pain or loss of control.';

  @override
  String get rtsStability2 =>
      '2 – Barely possible with significant limitations.';

  @override
  String get rtsStability3 =>
      '3 – Possible with noticeable compensations or mild pain.';

  @override
  String get rtsStability4 => '4 – Almost normal, minimal uncertainty.';

  @override
  String get rtsStability5 => '5 – Fully controlled and pain-free.';

  @override
  String rtsStabilityDetailValue(String rating) {
    return 'Self-rating: $rating / 5';
  }

  @override
  String get rtsTestPainTitle => 'Pain During Activity';

  @override
  String get rtsTestPainDesc =>
      'How strong is your pain during sport-specific activities (e.g. running, jumping, cutting)? Rate on a scale of 0–10.';

  @override
  String get rtsPainNoKein => '0 – No pain';

  @override
  String get rtsPainSevere => '10 – Worst pain';

  @override
  String rtsPainDetailValue(String level) {
    return 'NRS: $level / 10';
  }

  @override
  String get rtsSportTypeTitle => 'Sport Type';

  @override
  String get rtsSportTypeDesc => 'Which sport do you want to return to?';

  @override
  String get rtsSportRunning => 'Running';

  @override
  String get rtsSportSoccer => 'Soccer / Team Sports';

  @override
  String get rtsSportStrength => 'Strength Training';

  @override
  String get rtsSportCycling => 'Cycling';

  @override
  String get rtsSportSwimming => 'Swimming';

  @override
  String get rtsSportMartialArts => 'Martial Arts';

  @override
  String get rtsSportOther => 'Other';

  @override
  String get rtsTestHopTitle => 'Single-Leg Hop Test';

  @override
  String get rtsTestHopDesc =>
      'Hop as far as possible on your affected leg and measure the distance. Repeat on the healthy side.';

  @override
  String get rtsTestHopHint =>
      'Perform 3 attempts and record the best jump. An LSI ≥ 90% is the optimal return-to-sport threshold.';

  @override
  String get rtsHopAffected => 'Affected side (cm)';

  @override
  String get rtsHopHealthy => 'Healthy side (cm)';

  @override
  String rtsHopDetailValue(String affected, String healthy, String percent) {
    return 'Affected: $affected cm / Healthy: $healthy cm → LSI: $percent';
  }

  @override
  String get rtsTestTugTitle => 'Timed Up and Go (TUG)';

  @override
  String get rtsTestTugDesc =>
      'Stand up from a chair, walk 3 meters, turn around and sit back down. Measure the total time.';

  @override
  String get rtsTestTugHint =>
      'Use the stopwatch button or enter the time manually. Below 10 seconds is considered excellent.';

  @override
  String rtsTugDetailValue(String seconds) {
    return '$seconds seconds';
  }

  @override
  String get rtsTimerStart => 'Start Stopwatch';

  @override
  String get rtsTimerStop => 'Stop';

  @override
  String get rtsTimerReset => 'Reset';

  @override
  String get rtsTimerRestart => 'Restart';

  @override
  String get rtsTimerOrManual => 'Or enter manually:';

  @override
  String get rtsTimerManualLabel => 'Time in seconds';

  @override
  String get rtsScoreTrend => 'Score Trend';

  @override
  String get supplementAddNew => 'Add Supplement';

  @override
  String get supplementEdit => 'Edit Supplement';

  @override
  String get supplementName => 'Name';

  @override
  String get supplementBrand => 'Brand (optional)';

  @override
  String get supplementDose => 'Dose (e.g. 1000 IU)';

  @override
  String get supplementCategoryLabel => 'Category';

  @override
  String get supplementCategoryVitamine => 'Vitamins';

  @override
  String get supplementCategoryMineralien => 'Minerals';

  @override
  String get supplementCategoryAminosaeuren => 'Amino Acids';

  @override
  String get supplementCategoryKraeuter => 'Herbs & Plants';

  @override
  String get supplementCategoryProbiotika => 'Probiotics';

  @override
  String get supplementCategoryFettsaeuren => 'Fatty Acids';

  @override
  String get supplementCategoryProteine => 'Proteins';

  @override
  String get supplementCategorySonstiges => 'Other';

  @override
  String get supplementTimeSlots => 'Intake Times';

  @override
  String get supplementSave => 'Save';

  @override
  String get supplementTabToday => 'Today';

  @override
  String get supplementTabMine => 'My Supplements';

  @override
  String get supplementTabRecommendations => 'Recommendations';

  @override
  String get supplementTodayProgress => 'Today\'s intake';

  @override
  String get supplementTodayHistory => 'Today\'s intakes';

  @override
  String get supplementLogSuccess => 'Intake saved ✓';

  @override
  String get supplementLogManual => 'Log manually';

  @override
  String get supplementStockLow => 'Stock low';

  @override
  String get supplementStockEmpty => 'Out of stock';

  @override
  String get supplementEmptyState =>
      'No supplements yet.\nTap + to get started.';

  @override
  String get supplementDeleteTitle => 'Delete supplement?';

  @override
  String get supplementDeleteBody =>
      'Do you really want to delete this supplement?';

  @override
  String get supplementDoseGuidance => 'Dose recommendation';

  @override
  String get supplementNoRecommendations => 'No recommendations available';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabDoctors => 'Doctors';

  @override
  String get tabTeam => 'Team';

  @override
  String get tabPatients => 'Patients';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabReport => 'Report';

  @override
  String get tabWound => 'Wound';

  @override
  String get tabPain => 'Pain';

  @override
  String get tabDocuments => 'Documents';

  @override
  String get tabMedications => 'Medications';

  @override
  String get tabQuestions => 'Questions';

  @override
  String get tabNotes => 'Notes';

  @override
  String get tabObservations => 'Observations';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingDay => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get today => 'Today';

  @override
  String get profil => 'Profile';

  @override
  String get patienten => 'Patients';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayShortMo => 'Mon';

  @override
  String get weekdayShortTu => 'Tue';

  @override
  String get weekdayShortWe => 'Wed';

  @override
  String get weekdayShortTh => 'Thu';

  @override
  String get weekdayShortFr => 'Fri';

  @override
  String get weekdayShortSa => 'Sat';

  @override
  String get weekdayShortSu => 'Sun';

  @override
  String get phasePreOp => 'Pre-OP';

  @override
  String get phaseOpDay => 'OP Day';

  @override
  String get phasePostOp => 'Post-OP';

  @override
  String get phaseDischarged => 'Discharged';

  @override
  String get phaseDistribution => 'Phase distribution';

  @override
  String get statusActive => 'Active';

  @override
  String get statusDeactivated => 'Deactivated';

  @override
  String get notProvided => 'Not provided';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldDescriptionOptional => 'Description (optional)';

  @override
  String get sorting => 'Sorting';

  @override
  String get sortName => 'Name';

  @override
  String get sortOpDate => 'OP date';

  @override
  String get sortLastEntry => 'Last entry';

  @override
  String get sortSeverity => 'Severity';

  @override
  String get totalPatients => 'Total patients';

  @override
  String get activePatients => 'Active patients';

  @override
  String get openRedFlags => 'Open red flags';

  @override
  String get compliance => 'Compliance';

  @override
  String get total => 'Total';

  @override
  String countActive(int count) {
    return '$count active';
  }

  @override
  String get quickActions => 'Quick actions';

  @override
  String get templates => 'Templates';

  @override
  String get monthlyReport => 'Monthly report';

  @override
  String get myPatients => 'My patients';

  @override
  String get patientStatus => 'Patient status';

  @override
  String get allPatientsGreen => 'All patients in the green zone';

  @override
  String get attentionRequired => 'Attention required';

  @override
  String get noAppointmentsToday => 'No appointments today – enjoy your day!';

  @override
  String appointmentsCount(int count) {
    return '$count appointments';
  }

  @override
  String showAllAppointments(int count) {
    return 'Show all $count appointments →';
  }

  @override
  String practiceOf(String name) {
    return 'Practice of $name';
  }

  @override
  String get searchPatient => 'Search patient …';

  @override
  String get noPatientsFound => 'No patients found.';

  @override
  String get noPatientsLinked => 'No patients linked.';

  @override
  String get noPatientsLinkedYet => 'No patients linked yet';

  @override
  String get noPatientsInCategory => 'No patients in this category';

  @override
  String patientsCountLabel(int count) {
    return 'Patients ($count)';
  }

  @override
  String get selectPatientForDetails => 'Select a patient to view details';

  @override
  String opDatePrefix(String date) {
    return 'OP: $date';
  }

  @override
  String countSelected(int count) {
    return '$count selected';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get proActive => 'Pro active';

  @override
  String get validUntil => 'Valid until';

  @override
  String get source => 'Source';

  @override
  String get proKey => 'Pro Key';

  @override
  String get appStoreName => 'App Store';

  @override
  String get googlePlayName => 'Google Play';

  @override
  String get subscription => 'Subscription';

  @override
  String get freeTier => 'Free';

  @override
  String get upgradeNow => 'Upgrade now';

  @override
  String get redeemKey => 'Redeem key';

  @override
  String get praxisPro => 'Practice Pro';

  @override
  String get praxisProSubtitle => 'Unlimited patients & more';

  @override
  String get upgradeNowArrow => 'Upgrade now →';

  @override
  String get sectionContactData => 'Contact details';

  @override
  String get sectionDoctors => 'Doctors';

  @override
  String get sectionTeam => 'Team';

  @override
  String get sectionPatients => 'Patients';

  @override
  String get orgProfileNotFound => 'Organisation profile not found.';

  @override
  String get verified => 'Verified';

  @override
  String get verificationPending => 'Verification pending';

  @override
  String get practiceInformation => 'Practice information';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get specialties => 'Specialties';

  @override
  String get professionalDetails => 'Professional details';

  @override
  String get approbation => 'Approbation';

  @override
  String get kvNumber => 'KV number';

  @override
  String get practiceName => 'Practice name';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get accountAndSupport => 'Account & Support';

  @override
  String get profileImageUploadError => 'Profile image could not be uploaded.';

  @override
  String doctorsCountLabel(int count) {
    return 'Doctors ($count)';
  }

  @override
  String get selectDoctorForDetails => 'Select a doctor to view details';

  @override
  String get errorLoadingDoctors => 'Error loading doctors.';

  @override
  String get errorLoading => 'Error loading.';

  @override
  String get errorLoadingPatients => 'Patient list could not be loaded.';

  @override
  String get errorLoadingStaff => 'Error loading staff.';

  @override
  String joinedOn(String date) {
    return 'Joined on $date';
  }

  @override
  String get inviteCode => 'Invite code';

  @override
  String get inviteCodeDescription =>
      'Share this code with verified doctors who want to join your organisation.';

  @override
  String get inviteCodeLoadError => 'Code could not be loaded.';

  @override
  String joinRequestsCountLabel(int count) {
    return 'Join requests ($count)';
  }

  @override
  String timeAgoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String timeAgoHours(int count) {
    return '$count hrs ago';
  }

  @override
  String timeAgoDays(int count) {
    return '$count days ago';
  }

  @override
  String get noDoctorsYet => 'No doctors yet';

  @override
  String get addDoctorsToOrg => 'Add doctors to build your organisation.';

  @override
  String get createNewDoctor => 'Create new doctor';

  @override
  String get createDoctor => 'Create doctor';

  @override
  String get creating => 'Creating…';

  @override
  String get validationRequired => 'Required field';

  @override
  String get validationInvalidEmail => 'Invalid email';

  @override
  String get validationMinChars8 => 'At least 8 characters.';

  @override
  String confirmAddDoctorToOrg(String name) {
    return 'Do you really want to add $name to your organisation?';
  }

  @override
  String confirmRemoveDoctorFromOrg(String name) {
    return 'Do you really want to remove $name from the organisation? The doctor will become independent and keep their account.';
  }

  @override
  String confirmActivateStaff(String name) {
    return 'Do you want to reactivate $name? Login will be possible again.';
  }

  @override
  String confirmDeactivateStaff(String name) {
    return 'Do you want to deactivate $name? Login will be blocked.';
  }

  @override
  String staffActivated(String name) {
    return '$name has been activated';
  }

  @override
  String staffDeactivated(String name) {
    return '$name has been deactivated';
  }

  @override
  String confirmRemoveStaff(String name) {
    return 'Do you really want to remove $name? Access will be revoked immediately and the account deactivated.';
  }

  @override
  String get actionActivate => 'activate';

  @override
  String get actionDeactivate => 'deactivate';

  @override
  String staffCountLabel(int count) {
    return 'Staff ($count)';
  }

  @override
  String get noStaffYet => 'No staff yet';

  @override
  String get createStaffHint => 'Create staff accounts for your team.';

  @override
  String get createStaffTeamHint =>
      'Create accounts for your practice team\nto manage patients together.';

  @override
  String get permissionRead => 'Read';

  @override
  String get permissionWrite => 'Write';

  @override
  String get caregiverNoLinkedPatient =>
      'No patient linked yet.\nPlease connect via an invitation code.';

  @override
  String get observationLabel => 'Observation';

  @override
  String confirmDisconnectPatient(String name) {
    return 'Do you really want to disconnect from $name?';
  }

  @override
  String taskForPatient(String name) {
    return 'Task for $name';
  }

  @override
  String selectTemplateForPatient(String name) {
    return 'Select a template for $name:';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get selectStartDateHint => 'Select start date (e.g. OP date)';

  @override
  String get assigning => 'Assigning…';

  @override
  String recurrenceDaily(int count) {
    return 'Daily, ${count}x';
  }

  @override
  String recurrenceWeekdays(int count) {
    return 'Weekdays, ${count}x';
  }

  @override
  String recurrenceEveryNDays(int days, int count) {
    return 'Every $days days, ${count}x';
  }

  @override
  String patientsMarkedRead(int count) {
    return '$count patients marked as read';
  }

  @override
  String groupMessageToPatients(int count) {
    return 'Group message to $count patients';
  }

  @override
  String get hintEnterMessage => 'Enter message …';

  @override
  String messageSentToPatients(int count) {
    return 'Message sent to $count patients';
  }

  @override
  String pdfReportCreating(int count) {
    return 'Creating PDF report for $count patients …';
  }

  @override
  String get groupMessage => 'Group message';

  @override
  String get pdfReport => 'PDF report';

  @override
  String get calendarDay => 'Day';

  @override
  String get specialtyGeneralSurgery => 'General surgery';

  @override
  String get specialtyOrthopedics => 'Orthopaedics & trauma surgery';

  @override
  String get specialtyVisceralSurgery => 'Visceral surgery';

  @override
  String get specialtyCardiacSurgery => 'Cardiac surgery';

  @override
  String get specialtyNeurosurgery => 'Neurosurgery';

  @override
  String get specialtyVascularSurgery => 'Vascular surgery';

  @override
  String get specialtyPlasticSurgery => 'Plastic surgery';

  @override
  String get specialtyUrology => 'Urology';

  @override
  String get specialtyGynecology => 'Gynaecology';

  @override
  String get specialtyEnt => 'ENT';

  @override
  String get specialtyOphthalmology => 'Ophthalmology';

  @override
  String get specialtyInternalMedicine => 'Internal medicine';

  @override
  String get specialtyAnesthesiology => 'Anaesthesiology';

  @override
  String get specialtyOther => 'Other';

  @override
  String get passwordMin8Chars => 'At least 8 characters.';

  @override
  String staffConfirmActivateBody(String name) {
    return 'Do you want to reactivate $name? Login will be possible again.';
  }

  @override
  String staffConfirmDeactivateBody(String name) {
    return 'Do you want to deactivate $name? Login will be blocked.';
  }

  @override
  String staffWasActivated(String name) {
    return '$name was activated';
  }

  @override
  String staffWasDeactivated(String name) {
    return '$name was deactivated';
  }

  @override
  String staffRemoveConfirmBody(String name) {
    return 'Do you really want to remove $name? Access will be revoked immediately and the account deactivated.';
  }

  @override
  String get teamHeader => 'Team';

  @override
  String get staffLoadError => 'Error loading staff members.';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get noStaffYetTitle => 'No staff yet';

  @override
  String get noStaffYetSubtitle => 'Create staff accounts for your team.';

  @override
  String nSelected(int count) {
    return '$count selected';
  }

  @override
  String get patientListLoadError => 'Could not load patient list.';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByOpDate => 'Surgery date';

  @override
  String get sortByLastEntry => 'Last entry';

  @override
  String get sortBySeverity => 'Severity';

  @override
  String get title => 'Title';

  @override
  String get enterMessage => 'Enter message …';

  @override
  String staffActivateConfirmBody(String name) {
    return 'Do you want to reactivate $name? Login will be possible again.';
  }

  @override
  String staffDeactivateConfirmBody(String name) {
    return 'Do you want to deactivate $name? Login will be blocked.';
  }

  @override
  String staffPermissionsSummary(int readCount, int writeCount) {
    return '$readCount Read · $writeCount Write';
  }

  @override
  String get pdTabReport => 'Report';

  @override
  String get pdTabRedFlags => 'Red Flags';

  @override
  String get pdTabWound => 'Wound';

  @override
  String get pdTabPain => 'Pain';

  @override
  String get pdTabDocuments => 'Documents';

  @override
  String get pdTabMedication => 'Medication';

  @override
  String get pdTabQuestions => 'Questions';

  @override
  String get pdTabNotes => 'Notes';

  @override
  String get phaseEntlassen => 'Discharged';

  @override
  String disconnectConfirmBody(String name) {
    return 'Do you really want to disconnect from $name?';
  }

  @override
  String terminFuerPatient(String name) {
    return 'Appointment for $name';
  }

  @override
  String aufgabeFuerPatient(String name) {
    return 'Task for $name';
  }

  @override
  String get startdatumWaehlen => 'Select start date (e.g. surgery date)';

  @override
  String vorlageFuerPatient(String name) {
    return 'Select a template for $name:';
  }

  @override
  String templateAppliedCount(String name, int count, String suffix) {
    return '$name: $count task$suffix assigned';
  }

  @override
  String nAufgabenColon(int count, String suffix) {
    return '$count task$suffix:';
  }

  @override
  String nAufgaben(int count, String suffix) {
    return '$count task$suffix';
  }

  @override
  String get vorlageErstellen => 'Create template';

  @override
  String get doctorProfileNotSpecified => 'Not specified';

  @override
  String get doctorProfilePracticeInfo => 'Practice information';

  @override
  String get doctorProfileWebsite => 'Website';

  @override
  String get doctorProfileOpeningHours => 'Opening hours';

  @override
  String get doctorProfileSpecialties => 'Specialties';

  @override
  String get doctorProfileProfessionalInfo => 'Professional credentials';

  @override
  String get doctorProfileApprobation => 'Medical license';

  @override
  String get doctorProfileKvNumber => 'KV number';

  @override
  String get doctorProfilePracticeName => 'Practice name';

  @override
  String get doctorProfileStaffMember => 'Staff member';

  @override
  String get doctorProfileAccountSupport => 'Account & Support';

  @override
  String get doctorProfileImageUploadError =>
      'Profile picture could not be uploaded.';

  @override
  String get doctorProfileYourProfile => 'Your profile';

  @override
  String get doctorProfileVerified => 'Verified';

  @override
  String get doctorProfileVerificationPending => 'Verification pending';

  @override
  String get doctorProfileClosed => 'Closed';

  @override
  String get doctorProfileNoSpecialties => 'No specialties specified';

  @override
  String get doctorProfileNewSpecialtyHint => 'New specialty…';

  @override
  String get patientSuchen => 'Search patient…';

  @override
  String get fehlerBeimLaden => 'Error loading.';

  @override
  String get keinePatienenGefunden => 'No patients found.';

  @override
  String patientenAnzahl(int count) {
    return 'Patients ($count)';
  }

  @override
  String get patientAuswaehlenUmDetailsAnzuzeigen =>
      'Select a patient to view details';

  @override
  String opDatumKurz(int day, int month, int year) {
    return 'Surgery: $day.$month.$year';
  }

  @override
  String appointmentCount(int count) {
    return '$count appointments';
  }

  @override
  String get noAppointmentsFreeDay => 'No appointments – free day!';

  @override
  String showAllAppointmentsCount(int count) {
    return 'Show all $count appointments';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get broadcastSend => 'Send';

  @override
  String broadcastSentCount(int count) {
    return 'Broadcast sent to $count patients';
  }

  @override
  String get broadcastToAllPatients => 'Broadcast to all patients';

  @override
  String broadcastWillBeSentTo(int count) {
    return 'Will be sent to $count patients';
  }

  @override
  String get sending => 'Sending…';

  @override
  String appointmentDeleteMessage(String title, String patient) {
    return 'Do you really want to delete the appointment \"$title\" for $patient?';
  }

  @override
  String eventDeleteMessage(String title) {
    return 'Do you really want to delete the appointment \"$title\"?';
  }

  @override
  String get appointmentEdit => 'Edit appointment';

  @override
  String get notes => 'Notes';

  @override
  String get type => 'Type';

  @override
  String get saving => 'Saving…';

  @override
  String get practiceAppointmentCreate => 'Create practice appointment';

  @override
  String get practiceAppointmentEdit => 'Edit practice appointment';

  @override
  String get nochKeinePatientenInDerOrganisation =>
      'No patients in the organisation yet.';

  @override
  String redFlagCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Flags',
      one: 'Flag',
    );
    return '$count $_temp0';
  }

  @override
  String get bellaDescriptionOrganisation =>
      'I help you manage your organisation, doctors, staff, and statistics.';

  @override
  String get bellaSubtitleOrganisation => 'Your organisation assistant 🐰';

  @override
  String get bellaFeatureBilling => 'Billing';

  @override
  String get bellaFeatureDoctors => 'Doctors';

  @override
  String get bellaFeatureOrgStats => 'Statistics';

  @override
  String get bellaFeatureTeam => 'Team';

  @override
  String get bellaChipDoctorBroadcast => 'Send a message to all patients';

  @override
  String get bellaChipDoctorCreateAppointment =>
      'Create an appointment for a patient';

  @override
  String get bellaChipDoctorInvitePatient => 'Invite a new patient';

  @override
  String get bellaChipManageDoctors => 'How do I manage my doctors?';

  @override
  String get bellaChipOrgBillingInfo => 'What is our subscription status?';

  @override
  String get bellaChipOrgDashboard => 'Show our organisation overview';

  @override
  String get bellaChipOrgInviteDoctor => 'Invite a new doctor';

  @override
  String get bellaChipOrgStats => 'Show our statistics';

  @override
  String get bellaChipStaffCreateAppointment =>
      'Create an appointment for a patient';

  @override
  String get bellaChipDoctorCreateTask => 'Create a task for a patient';

  @override
  String get bellaChipDoctorCreateRedFlag => 'Create a warning for a patient';

  @override
  String get bellaChipOrgBroadcast => 'Send a message to all patients';

  @override
  String get bellaChipStaffCreateTask => 'Create a task for a patient';

  @override
  String get bellaChipStaffLogVital => 'Log vitals for a patient';

  @override
  String get orgManagedByOrg => 'Wird von Ihrer Organisation verwaltet';

  @override
  String get orgManagedByOrgHint =>
      'Diese Einstellungen werden zentral von Ihrer Organisation gepflegt.';

  @override
  String get orgProfileEdit => 'Profil bearbeiten';

  @override
  String get orgProfileSaved => 'Organisationsprofil gespeichert';

  @override
  String get orgProfileSaveError => 'Profil konnte nicht gespeichert werden';

  @override
  String get orgSettingsTitle => 'Verwaltung';

  @override
  String get orgSettingsDoctorManagement => 'Ärzteverwaltung';

  @override
  String get orgSettingsDoctorManagementDesc =>
      'Ärzte hinzufügen, entfernen und Zugriffsrechte verwalten';

  @override
  String get orgSettingsStaffManagement => 'Mitarbeiterverwaltung';

  @override
  String get orgSettingsStaffManagementDesc =>
      'Mitarbeiter verwalten und Berechtigungen zuweisen';

  @override
  String get orgSettingsPatientOverview => 'Patientenübersicht';

  @override
  String get orgSettingsPatientOverviewDesc =>
      'Alle Patienten der Organisation einsehen';

  @override
  String get orgSettingsInviteCodes => 'Einladungscodes';

  @override
  String get orgSettingsInviteCodesDesc =>
      'Einladungscodes für neue Ärzte verwalten';

  @override
  String get orgSettingsJoinRequests => 'Beitrittsanfragen';

  @override
  String get orgSettingsJoinRequestsDesc =>
      'Offene Anfragen von Ärzten prüfen und genehmigen';

  @override
  String get orgSettingsNotifications => 'Benachrichtigungen';

  @override
  String get orgSettingsNotificationsDesc =>
      'Benachrichtigungseinstellungen der Organisation';

  @override
  String get orgSettingsBilling => 'Abrechnung & Abonnement';

  @override
  String get orgSettingsBillingDesc =>
      'Pro-Status, Rechnungen und Abonnement verwalten';

  @override
  String get orgSettingsDataExport => 'Datenexport';

  @override
  String get orgSettingsDataExportDesc =>
      'Organisationsdaten zusammenstellen und exportieren';

  @override
  String get orgSettingsAppearance => 'Erscheinungsbild';

  @override
  String get orgSettingsAppearanceDesc =>
      'Logo und Darstellung der Organisation anpassen';

  @override
  String get orgSettingsOpeningHours => 'Öffnungszeiten';

  @override
  String get orgSettingsOpeningHoursDesc =>
      'Öffnungszeiten der Einrichtung festlegen';

  @override
  String get orgSettingsWebsite => 'Webseite';

  @override
  String get orgSettingsContactInfo => 'Kontaktdaten Ihrer Organisation';

  @override
  String get orgSettingsGeneralInfo => 'Allgemeine Informationen';

  @override
  String get orgSettingsDangerZone => 'Gefahrenzone';

  @override
  String get orgSettingsDeleteOrg => 'Organisation löschen';

  @override
  String get orgSettingsDeleteOrgDesc =>
      'Organisation und alle zugehörigen Daten unwiderruflich löschen';

  @override
  String orgDoctorCount(int count) {
    return '$count Ärzte';
  }

  @override
  String orgStaffCount(int count) {
    return '$count Mitarbeiter';
  }

  @override
  String orgPatientCount(int count) {
    return '$count Patienten';
  }

  @override
  String orgPendingRequests(int count) {
    return '$count offene Anfragen';
  }

  @override
  String get orgQuickActions => 'Schnellaktionen';

  @override
  String get orgManagementSection => 'Organisation verwalten';

  @override
  String get orgSecuritySection => 'Sicherheit & Daten';

  @override
  String get orgSaveChanges => 'Änderungen speichern';
}
