import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Operationsbegleiter'**
  String get appTitle;

  /// No description provided for @languageLabel.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get languageLabel;

  /// No description provided for @languageName.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageName;

  /// No description provided for @languageChangeTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache wählen'**
  String get languageChangeTitle;

  /// No description provided for @tabStart.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get tabStart;

  /// No description provided for @tabAppointments.
  ///
  /// In de, this message translates to:
  /// **'Termine'**
  String get tabAppointments;

  /// No description provided for @tabDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get tabDocuments;

  /// No description provided for @tabMore.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get tabMore;

  /// No description provided for @login.
  ///
  /// In de, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginAction.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get loginAction;

  /// No description provided for @loginLoading.
  ///
  /// In de, this message translates to:
  /// **'Anmelden…'**
  String get loginLoading;

  /// No description provided for @loginFailed.
  ///
  /// In de, this message translates to:
  /// **'Login fehlgeschlagen: {error}'**
  String loginFailed(String error);

  /// No description provided for @loginAppleFailed.
  ///
  /// In de, this message translates to:
  /// **'Apple-Login fehlgeschlagen: {error}'**
  String loginAppleFailed(String error);

  /// No description provided for @loginGoogleFailed.
  ///
  /// In de, this message translates to:
  /// **'Google-Login fehlgeschlagen: {error}'**
  String loginGoogleFailed(String error);

  /// No description provided for @loginWithApple.
  ///
  /// In de, this message translates to:
  /// **'Mit Apple anmelden'**
  String get loginWithApple;

  /// No description provided for @loginWithGoogle.
  ///
  /// In de, this message translates to:
  /// **'Mit Google anmelden'**
  String get loginWithGoogle;

  /// No description provided for @or.
  ///
  /// In de, this message translates to:
  /// **'oder'**
  String get or;

  /// No description provided for @noAccountYet.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Konto? Registrieren'**
  String get noAccountYet;

  /// No description provided for @signupTitle.
  ///
  /// In de, this message translates to:
  /// **'Registrierung'**
  String get signupTitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In de, this message translates to:
  /// **'Konto\nerstellen'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Fülle die Felder aus, um loszulegen.'**
  String get createAccountSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get createAccount;

  /// No description provided for @creatingAccount.
  ///
  /// In de, this message translates to:
  /// **'Erstelle Konto…'**
  String get creatingAccount;

  /// No description provided for @fieldName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldFullName.
  ///
  /// In de, this message translates to:
  /// **'Vollständiger Name'**
  String get fieldFullName;

  /// No description provided for @fieldEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get fieldPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get fieldConfirmPassword;

  /// No description provided for @fieldRepeatPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get fieldRepeatPassword;

  /// No description provided for @fieldBirthDate.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum'**
  String get fieldBirthDate;

  /// No description provided for @fieldBirthDateHint.
  ///
  /// In de, this message translates to:
  /// **'TT.MM.JJJJ'**
  String get fieldBirthDateHint;

  /// No description provided for @fieldBirthDatePicker.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum wählen'**
  String get fieldBirthDatePicker;

  /// No description provided for @validationNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Name eingeben'**
  String get validationNameRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Gültige E‑Mail eingeben'**
  String get validationEmailInvalid;

  /// No description provided for @validationBirthDateRequired.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum wählen'**
  String get validationBirthDateRequired;

  /// No description provided for @validationPasswordMin6.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 6 Zeichen'**
  String get validationPasswordMin6;

  /// No description provided for @validationRepeatPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get validationRepeatPassword;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationPasswordsMismatchLegacy.
  ///
  /// In de, this message translates to:
  /// **'Passwoerter stimmen nicht ueberein.'**
  String get validationPasswordsMismatchLegacy;

  /// No description provided for @errorEmailInUse.
  ///
  /// In de, this message translates to:
  /// **'Diese E‑Mail wird bereits verwendet.'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Ungültige E‑Mail-Adresse.'**
  String get errorInvalidEmail;

  /// No description provided for @errorWeakPassword.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort ist zu schwach.'**
  String get errorWeakPassword;

  /// No description provided for @errorRegistrationFailed.
  ///
  /// In de, this message translates to:
  /// **'Registrierung fehlgeschlagen: {error}'**
  String errorRegistrationFailed(String error);

  /// No description provided for @agbAcceptPrefix.
  ///
  /// In de, this message translates to:
  /// **'Ich akzeptiere die '**
  String get agbAcceptPrefix;

  /// No description provided for @agbAcceptLink.
  ///
  /// In de, this message translates to:
  /// **'AGB und Datenschutzerklärung'**
  String get agbAcceptLink;

  /// No description provided for @agbTermsLink.
  ///
  /// In de, this message translates to:
  /// **'AGB'**
  String get agbTermsLink;

  /// No description provided for @agbAndConnector.
  ///
  /// In de, this message translates to:
  /// **' und '**
  String get agbAndConnector;

  /// No description provided for @agbPrivacyLink.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get agbPrivacyLink;

  /// No description provided for @datePickerCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get datePickerCancel;

  /// No description provided for @datePickerConfirm.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get datePickerConfirm;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In de, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsNotAvailable.
  ///
  /// In de, this message translates to:
  /// **'Nicht verfügbar'**
  String get settingsNotAvailable;

  /// No description provided for @settingsLogout.
  ///
  /// In de, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settingsNotifications;

  /// No description provided for @settingsPush.
  ///
  /// In de, this message translates to:
  /// **'Push'**
  String get settingsPush;

  /// No description provided for @settingsEmailNotif.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get settingsEmailNotif;

  /// No description provided for @settingsPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Platzhalter – wird noch implementiert'**
  String get settingsPlaceholder;

  /// No description provided for @settingsData.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get settingsData;

  /// No description provided for @settingsExportData.
  ///
  /// In de, this message translates to:
  /// **'Daten exportieren'**
  String get settingsExportData;

  /// No description provided for @settingsExportPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Export wird noch implementiert'**
  String get settingsExportPlaceholder;

  /// No description provided for @settingsExportSnack.
  ///
  /// In de, this message translates to:
  /// **'Export kommt als nächstes'**
  String get settingsExportSnack;

  /// No description provided for @settingsResetData.
  ///
  /// In de, this message translates to:
  /// **'Daten zurücksetzen'**
  String get settingsResetData;

  /// No description provided for @settingsResetPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Reset wird noch implementiert'**
  String get settingsResetPlaceholder;

  /// No description provided for @settingsResetSnack.
  ///
  /// In de, this message translates to:
  /// **'Reset kommt als nächstes'**
  String get settingsResetSnack;

  /// No description provided for @settingsPro.
  ///
  /// In de, this message translates to:
  /// **'Pro'**
  String get settingsPro;

  /// No description provided for @settingsProStatus.
  ///
  /// In de, this message translates to:
  /// **'Pro Status'**
  String get settingsProStatus;

  /// No description provided for @settingsProSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Abo & Wiederherstellen'**
  String get settingsProSubtitle;

  /// No description provided for @settingsLegal.
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get settingsLegal;

  /// No description provided for @settingsImprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get settingsImprint;

  /// No description provided for @settingsPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In de, this message translates to:
  /// **'AGB'**
  String get settingsTerms;

  /// No description provided for @settingsTermsPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'AGB-Screen wird noch ergänzt'**
  String get settingsTermsPlaceholder;

  /// No description provided for @settingsTermsSnack.
  ///
  /// In de, this message translates to:
  /// **'AGB folgt im nächsten Schritt'**
  String get settingsTermsSnack;

  /// No description provided for @settingsVersion.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @commonBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonLoading.
  ///
  /// In de, this message translates to:
  /// **'Laden…'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String commonError(String error);

  /// No description provided for @commonInProgress.
  ///
  /// In de, this message translates to:
  /// **'In Arbeit'**
  String get commonInProgress;

  /// No description provided for @commonUnnamed.
  ///
  /// In de, this message translates to:
  /// **'Unbenannt'**
  String get commonUnnamed;

  /// No description provided for @commonPatients.
  ///
  /// In de, this message translates to:
  /// **'Patienten'**
  String get commonPatients;

  /// No description provided for @commonNoPatientsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Patienten. Tippe auf +'**
  String get commonNoPatientsYet;

  /// No description provided for @commonPatientOpened.
  ///
  /// In de, this message translates to:
  /// **'Patient geöffnet: {name}'**
  String commonPatientOpened(String name);

  /// No description provided for @connectivityOfflineBanner.
  ///
  /// In de, this message translates to:
  /// **'Du bist offline. Änderungen werden synchronisiert, sobald du wieder online bist.'**
  String get connectivityOfflineBanner;

  /// No description provided for @connectivityRequiredTitle.
  ///
  /// In de, this message translates to:
  /// **'Keine Internetverbindung'**
  String get connectivityRequiredTitle;

  /// No description provided for @connectivityRequiredMessage.
  ///
  /// In de, this message translates to:
  /// **'Diese Funktion benötigt eine Internetverbindung. Bitte stelle eine Verbindung her und versuche es erneut.'**
  String get connectivityRequiredMessage;

  /// No description provided for @staffTeam.
  ///
  /// In de, this message translates to:
  /// **'Team'**
  String get staffTeam;

  /// No description provided for @staffInvite.
  ///
  /// In de, this message translates to:
  /// **'Einladen'**
  String get staffInvite;

  /// No description provided for @staffInviteTitle.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter einladen'**
  String get staffInviteTitle;

  /// No description provided for @staffInviteSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Teilen Sie diesen Code mit Ihrem/Ihrer Mitarbeiter/in'**
  String get staffInviteSubtitle;

  /// No description provided for @staffInviteValid.
  ///
  /// In de, this message translates to:
  /// **'Gültig für 7 Tage'**
  String get staffInviteValid;

  /// No description provided for @staffInviteCopy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get staffInviteCopy;

  /// No description provided for @staffInviteShare.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get staffInviteShare;

  /// No description provided for @staffInviteCodeLabel.
  ///
  /// In de, this message translates to:
  /// **'Einladungscode'**
  String get staffInviteCodeLabel;

  /// No description provided for @staffAcceptTitle.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter-Einladung'**
  String get staffAcceptTitle;

  /// No description provided for @staffAcceptCodeHint.
  ///
  /// In de, this message translates to:
  /// **'CODE EINGEBEN'**
  String get staffAcceptCodeHint;

  /// No description provided for @staffAcceptSubmit.
  ///
  /// In de, this message translates to:
  /// **'Code einlösen'**
  String get staffAcceptSubmit;

  /// No description provided for @staffAcceptSuccess.
  ///
  /// In de, this message translates to:
  /// **'Willkommen im Team!'**
  String get staffAcceptSuccess;

  /// No description provided for @staffAcceptSuccessBody.
  ///
  /// In de, this message translates to:
  /// **'Sie sind jetzt als Mitarbeiter/in registriert.\nStarten Sie die App neu, um das Dashboard zu sehen.'**
  String get staffAcceptSuccessBody;

  /// No description provided for @staffAcceptDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get staffAcceptDone;

  /// No description provided for @staffRevokedTitle.
  ///
  /// In de, this message translates to:
  /// **'Zugang widerrufen'**
  String get staffRevokedTitle;

  /// No description provided for @staffRevokedBody.
  ///
  /// In de, this message translates to:
  /// **'Ihr Mitarbeiter-Zugang wurde deaktiviert. Bitte wenden Sie sich an Ihren Arzt.'**
  String get staffRevokedBody;

  /// No description provided for @staffPermissionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen'**
  String get staffPermissionsTitle;

  /// No description provided for @staffPermissionsSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get staffPermissionsSave;

  /// No description provided for @staffRemoveTitle.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter entfernen'**
  String get staffRemoveTitle;

  /// No description provided for @staffRemoveConfirm.
  ///
  /// In de, this message translates to:
  /// **'Wirklich entfernen?'**
  String get staffRemoveConfirm;

  /// No description provided for @staffRemoveAction.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get staffRemoveAction;

  /// No description provided for @staffEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Team'**
  String get staffEmptyTitle;

  /// No description provided for @staffEmptySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Laden Sie Ihre Mitarbeitenden ein, um Ihr Praxis-Dashboard zu teilen.'**
  String get staffEmptySubtitle;

  /// No description provided for @staffRole.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter/in'**
  String get staffRole;

  /// No description provided for @staffPractice.
  ///
  /// In de, this message translates to:
  /// **'Praxis'**
  String get staffPractice;

  /// No description provided for @staffMyPermissions.
  ///
  /// In de, this message translates to:
  /// **'Meine Berechtigungen'**
  String get staffMyPermissions;

  /// No description provided for @staffAccessNone.
  ///
  /// In de, this message translates to:
  /// **'Kein Zugriff'**
  String get staffAccessNone;

  /// No description provided for @staffAccessRead.
  ///
  /// In de, this message translates to:
  /// **'Lesen'**
  String get staffAccessRead;

  /// No description provided for @staffAccessReadWrite.
  ///
  /// In de, this message translates to:
  /// **'Lesen & Schreiben'**
  String get staffAccessReadWrite;

  /// No description provided for @staffPendingInvites.
  ///
  /// In de, this message translates to:
  /// **'Offene Einladungen'**
  String get staffPendingInvites;

  /// No description provided for @onboardingSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In de, this message translates to:
  /// **'Dein digitaler\nOP-Begleiter'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Informationen rund um deinen Eingriff –\nsicher und übersichtlich an einem Ort.'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide1Feature1.
  ///
  /// In de, this message translates to:
  /// **'Schritt-für-Schritt Begleitung'**
  String get onboardingSlide1Feature1;

  /// No description provided for @onboardingSlide1Feature2.
  ///
  /// In de, this message translates to:
  /// **'Für Patienten entwickelt'**
  String get onboardingSlide1Feature2;

  /// No description provided for @onboardingSlide1Feature3.
  ///
  /// In de, this message translates to:
  /// **'Alles an einem Ort'**
  String get onboardingSlide1Feature3;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In de, this message translates to:
  /// **'Deine OP\nim Überblick'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Von der Vorbereitung bis zur Nachsorge –\nalles übersichtlich geplant.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide2Feature1.
  ///
  /// In de, this message translates to:
  /// **'Vorbereitungs-Checkliste'**
  String get onboardingSlide2Feature1;

  /// No description provided for @onboardingSlide2Feature2.
  ///
  /// In de, this message translates to:
  /// **'Packliste für die Klinik'**
  String get onboardingSlide2Feature2;

  /// No description provided for @onboardingSlide2Feature3.
  ///
  /// In de, this message translates to:
  /// **'Alle Termine im Blick'**
  String get onboardingSlide2Feature3;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In de, this message translates to:
  /// **'Gesundheit\ntracken'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Behalte deine Vitalwerte und Symptome\njederzeit im Auge.'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @onboardingSlide3Feature1.
  ///
  /// In de, this message translates to:
  /// **'Vitalwerte & Puls'**
  String get onboardingSlide3Feature1;

  /// No description provided for @onboardingSlide3Feature2.
  ///
  /// In de, this message translates to:
  /// **'Schmerztagebuch'**
  String get onboardingSlide3Feature2;

  /// No description provided for @onboardingSlide3Feature3.
  ///
  /// In de, this message translates to:
  /// **'Symptom-Check'**
  String get onboardingSlide3Feature3;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In de, this message translates to:
  /// **'Deine\nWundheilung'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Dokumentiere deinen Heilungsverlauf\nmit Fotos und Vergleichen.'**
  String get onboardingSlide4Subtitle;

  /// No description provided for @onboardingSlide4Feature1.
  ///
  /// In de, this message translates to:
  /// **'Foto-Dokumentation'**
  String get onboardingSlide4Feature1;

  /// No description provided for @onboardingSlide4Feature2.
  ///
  /// In de, this message translates to:
  /// **'Vergleichs-Funktion'**
  String get onboardingSlide4Feature2;

  /// No description provided for @onboardingSlide4Feature3.
  ///
  /// In de, this message translates to:
  /// **'Intelligente Hinweise'**
  String get onboardingSlide4Feature3;

  /// No description provided for @onboardingSlide5Title.
  ///
  /// In de, this message translates to:
  /// **'Vernetzt mit\ndeinem Team'**
  String get onboardingSlide5Title;

  /// No description provided for @onboardingSlide5Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Binde Angehörige ein und teile\nwichtige Informationen mit deinem Arzt.'**
  String get onboardingSlide5Subtitle;

  /// No description provided for @onboardingSlide5Feature1.
  ///
  /// In de, this message translates to:
  /// **'Angehörige einladen'**
  String get onboardingSlide5Feature1;

  /// No description provided for @onboardingSlide5Feature2.
  ///
  /// In de, this message translates to:
  /// **'Arztberichte teilen'**
  String get onboardingSlide5Feature2;

  /// No description provided for @onboardingSlide5Feature3.
  ///
  /// In de, this message translates to:
  /// **'Direkte Kommunikation'**
  String get onboardingSlide5Feature3;

  /// No description provided for @authSlideTitle.
  ///
  /// In de, this message translates to:
  /// **'Bereit loszulegen?'**
  String get authSlideTitle;

  /// No description provided for @authSlideSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erstelle dein Konto oder melde dich an,\num deine OP-Begleitung zu starten.'**
  String get authSlideSubtitle;

  /// No description provided for @authSlideRegister.
  ///
  /// In de, this message translates to:
  /// **'Jetzt registrieren'**
  String get authSlideRegister;

  /// No description provided for @authSlideLogin.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get authSlideLogin;

  /// No description provided for @authSlideDoctorRegister.
  ///
  /// In de, this message translates to:
  /// **'Als Arzt registrieren'**
  String get authSlideDoctorRegister;

  /// No description provided for @authSlideGuestMode.
  ///
  /// In de, this message translates to:
  /// **'App ohne Konto testen'**
  String get authSlideGuestMode;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In de, this message translates to:
  /// **'Willkommen\nzurück'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melde dich mit deinem Konto an.'**
  String get loginSubtitle;

  /// No description provided for @loginPasswordResetSent.
  ///
  /// In de, this message translates to:
  /// **'Falls ein Konto existiert, wurde eine E‑Mail gesendet.'**
  String get loginPasswordResetSent;

  /// No description provided for @loginEnterEmailFirst.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib zuerst deine E‑Mail ein.'**
  String get loginEnterEmailFirst;

  /// No description provided for @loginForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get loginForgotPassword;

  /// No description provided for @loginQuickLogin.
  ///
  /// In de, this message translates to:
  /// **'Schnellanmeldung'**
  String get loginQuickLogin;

  /// No description provided for @loginQuickLoginHint.
  ///
  /// In de, this message translates to:
  /// **'Verfügbar nach erstmaliger Anmeldung'**
  String get loginQuickLoginHint;

  /// No description provided for @doctorRegTitle.
  ///
  /// In de, this message translates to:
  /// **'Arzt‑Registrierung'**
  String get doctorRegTitle;

  /// No description provided for @doctorRegRoleBadge.
  ///
  /// In de, this message translates to:
  /// **'Zugang für Ärzt*innen'**
  String get doctorRegRoleBadge;

  /// No description provided for @doctorRegRoleBadgeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Nach der Registrierung prüft unser Team Ihre Angaben.'**
  String get doctorRegRoleBadgeSubtitle;

  /// No description provided for @doctorRegPersonalData.
  ///
  /// In de, this message translates to:
  /// **'Persönliche Daten'**
  String get doctorRegPersonalData;

  /// No description provided for @doctorRegNameHint.
  ///
  /// In de, this message translates to:
  /// **'Dr. med. Max Mustermann'**
  String get doctorRegNameHint;

  /// No description provided for @doctorRegServiceEmail.
  ///
  /// In de, this message translates to:
  /// **'Dienst‑E‑Mail'**
  String get doctorRegServiceEmail;

  /// No description provided for @doctorRegEmailHint.
  ///
  /// In de, this message translates to:
  /// **'arzt@klinik.de'**
  String get doctorRegEmailHint;

  /// No description provided for @doctorRegEmailRequired.
  ///
  /// In de, this message translates to:
  /// **'E‑Mail eingeben'**
  String get doctorRegEmailRequired;

  /// No description provided for @doctorRegEmailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Gültige E‑Mail eingeben'**
  String get doctorRegEmailInvalid;

  /// No description provided for @doctorRegPasswordMin8.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get doctorRegPasswordMin8;

  /// No description provided for @doctorRegProfessionalData.
  ///
  /// In de, this message translates to:
  /// **'Berufliche Angaben'**
  String get doctorRegProfessionalData;

  /// No description provided for @doctorRegSpecialty.
  ///
  /// In de, this message translates to:
  /// **'Fachrichtung'**
  String get doctorRegSpecialty;

  /// No description provided for @doctorRegSelectSpecialty.
  ///
  /// In de, this message translates to:
  /// **'Fachrichtung wählen'**
  String get doctorRegSelectSpecialty;

  /// No description provided for @doctorRegSpecialtyRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Fachrichtung wählen'**
  String get doctorRegSpecialtyRequired;

  /// No description provided for @doctorRegApprobation.
  ///
  /// In de, this message translates to:
  /// **'Approbationsnummer'**
  String get doctorRegApprobation;

  /// No description provided for @doctorRegApprobationHint.
  ///
  /// In de, this message translates to:
  /// **'Ihre ärztliche Approbationsnummer'**
  String get doctorRegApprobationHint;

  /// No description provided for @doctorRegApprobationRequired.
  ///
  /// In de, this message translates to:
  /// **'Approbationsnummer eingeben'**
  String get doctorRegApprobationRequired;

  /// No description provided for @doctorRegPractice.
  ///
  /// In de, this message translates to:
  /// **'Praxis / Klinik'**
  String get doctorRegPractice;

  /// No description provided for @doctorRegPracticeHint.
  ///
  /// In de, this message translates to:
  /// **'Name der Praxis oder Klinik'**
  String get doctorRegPracticeHint;

  /// No description provided for @doctorRegPracticeRequired.
  ///
  /// In de, this message translates to:
  /// **'Praxis/Klinik eingeben'**
  String get doctorRegPracticeRequired;

  /// No description provided for @doctorRegKvNumber.
  ///
  /// In de, this message translates to:
  /// **'KV‑Nummer (optional)'**
  String get doctorRegKvNumber;

  /// No description provided for @doctorRegKvHint.
  ///
  /// In de, this message translates to:
  /// **'Falls vorhanden'**
  String get doctorRegKvHint;

  /// No description provided for @doctorRegSubmitting.
  ///
  /// In de, this message translates to:
  /// **'Wird gesendet …'**
  String get doctorRegSubmitting;

  /// No description provided for @doctorRegSubmit.
  ///
  /// In de, this message translates to:
  /// **'Zugang beantragen'**
  String get doctorRegSubmit;

  /// No description provided for @doctorRegDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Ihre Angaben werden vertraulich behandelt und ausschließlich zur Verifizierung verwendet.'**
  String get doctorRegDisclaimer;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Diese App ist kein Medizinprodukt und ersetzt keine ärztliche Behandlung.'**
  String get medicalDisclaimer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
