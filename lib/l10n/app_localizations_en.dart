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
  String get appointmentForPatient => 'Create appointment for a patient';

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
}
