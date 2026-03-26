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

  /// No description provided for @tabStart.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get tabStart;

  /// No description provided for @tabAppointments.
  ///
  /// In de, this message translates to:
  /// **'Termine'**
  String get tabAppointments;

  /// No description provided for @tabMore.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get tabMore;

  /// No description provided for @commonBack.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get commonBack;

  /// No description provided for @or.
  ///
  /// In de, this message translates to:
  /// **'oder'**
  String get or;

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

  /// No description provided for @syncIndicatorSynced.
  ///
  /// In de, this message translates to:
  /// **'Alles synchronisiert'**
  String get syncIndicatorSynced;

  /// No description provided for @syncIndicatorSyncing.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge warten auf Sync'**
  String syncIndicatorSyncing(int count);

  /// No description provided for @syncIndicatorOffline.
  ///
  /// In de, this message translates to:
  /// **'Offline'**
  String get syncIndicatorOffline;

  /// No description provided for @syncIndicatorOfflineWithCount.
  ///
  /// In de, this message translates to:
  /// **'Offline – {count} Einträge warten auf Sync'**
  String syncIndicatorOfflineWithCount(int count);

  /// No description provided for @syncIndicatorTitle.
  ///
  /// In de, this message translates to:
  /// **'Synchronisation'**
  String get syncIndicatorTitle;

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
  /// **'Willkommen beim Operationsbegleiter'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Dein persönlicher Begleiter vor und nach der OP'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide1Feature1.
  ///
  /// In de, this message translates to:
  /// **'Alle wichtigen Infos auf einen Blick'**
  String get onboardingSlide1Feature1;

  /// No description provided for @onboardingSlide1Feature2.
  ///
  /// In de, this message translates to:
  /// **'Persönliche Checklisten für deine OP'**
  String get onboardingSlide1Feature2;

  /// No description provided for @onboardingSlide1Feature3.
  ///
  /// In de, this message translates to:
  /// **'Schritt für Schritt durch den Prozess'**
  String get onboardingSlide1Feature3;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In de, this message translates to:
  /// **'Vorbereitung'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Optimal vorbereitet in die OP'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide2Feature1.
  ///
  /// In de, this message translates to:
  /// **'Individuelle Vorbereitungspläne'**
  String get onboardingSlide2Feature1;

  /// No description provided for @onboardingSlide2Feature2.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen an wichtige Termine'**
  String get onboardingSlide2Feature2;

  /// No description provided for @onboardingSlide2Feature3.
  ///
  /// In de, this message translates to:
  /// **'Dokumente digital verwalten'**
  String get onboardingSlide2Feature3;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In de, this message translates to:
  /// **'Nachsorge'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Begleitung nach der Operation'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @onboardingSlide3Feature1.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Gesundheitschecks'**
  String get onboardingSlide3Feature1;

  /// No description provided for @onboardingSlide3Feature2.
  ///
  /// In de, this message translates to:
  /// **'Medikamenten-Erinnerungen'**
  String get onboardingSlide3Feature2;

  /// No description provided for @onboardingSlide3Feature3.
  ///
  /// In de, this message translates to:
  /// **'Fortschritts-Tracking'**
  String get onboardingSlide3Feature3;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In de, this message translates to:
  /// **'Sicherheit'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Daten sind bei uns sicher'**
  String get onboardingSlide4Subtitle;

  /// No description provided for @onboardingSlide4Feature1.
  ///
  /// In de, this message translates to:
  /// **'Ende-zu-Ende-Verschlüsselung'**
  String get onboardingSlide4Feature1;

  /// No description provided for @onboardingSlide4Feature2.
  ///
  /// In de, this message translates to:
  /// **'DSGVO-konform'**
  String get onboardingSlide4Feature2;

  /// No description provided for @onboardingSlide4Feature3.
  ///
  /// In de, this message translates to:
  /// **'Daten nur auf deinem Gerät'**
  String get onboardingSlide4Feature3;

  /// No description provided for @onboardingSlide5Title.
  ///
  /// In de, this message translates to:
  /// **'Bereit?'**
  String get onboardingSlide5Title;

  /// No description provided for @onboardingSlide5Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Erstelle jetzt dein Profil'**
  String get onboardingSlide5Subtitle;

  /// No description provided for @onboardingSlide5Feature1.
  ///
  /// In de, this message translates to:
  /// **'Kostenlos registrieren'**
  String get onboardingSlide5Feature1;

  /// No description provided for @onboardingSlide5Feature2.
  ///
  /// In de, this message translates to:
  /// **'In wenigen Minuten startklar'**
  String get onboardingSlide5Feature2;

  /// No description provided for @onboardingSlide5Feature3.
  ///
  /// In de, this message translates to:
  /// **'Jederzeit löschbar'**
  String get onboardingSlide5Feature3;

  /// No description provided for @authSlideTitle.
  ///
  /// In de, this message translates to:
  /// **'Operationsbegleiter'**
  String get authSlideTitle;

  /// No description provided for @authSlideSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Dein persönlicher Begleiter für die OP'**
  String get authSlideSubtitle;

  /// No description provided for @authSlideRegister.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get authSlideRegister;

  /// No description provided for @authSlideLogin.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get authSlideLogin;

  /// No description provided for @authSlideDoctorRegister.
  ///
  /// In de, this message translates to:
  /// **'Als Arzt / Organisation registrieren'**
  String get authSlideDoctorRegister;

  /// No description provided for @authSlideGuestMode.
  ///
  /// In de, this message translates to:
  /// **'Gastmodus'**
  String get authSlideGuestMode;

  /// No description provided for @registerContinueAsGuest.
  ///
  /// In de, this message translates to:
  /// **'Ohne Registrierung fortfahren'**
  String get registerContinueAsGuest;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melde dich an, um fortzufahren'**
  String get loginSubtitle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get loginForgotPassword;

  /// No description provided for @loginEnterEmailFirst.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib zuerst deine E-Mail-Adresse ein.'**
  String get loginEnterEmailFirst;

  /// No description provided for @loginPasswordResetSent.
  ///
  /// In de, this message translates to:
  /// **'E-Mail zum Zurücksetzen des Passworts wurde gesendet.'**
  String get loginPasswordResetSent;

  /// No description provided for @loginWithGoogle.
  ///
  /// In de, this message translates to:
  /// **'Mit Google anmelden'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In de, this message translates to:
  /// **'Mit Apple anmelden'**
  String get loginWithApple;

  /// No description provided for @noAccountYet.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Konto?'**
  String get noAccountYet;

  /// No description provided for @createAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get createAccount;

  /// No description provided for @createAccountTitle.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Registriere dich, um loszulegen'**
  String get createAccountSubtitle;

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

  /// No description provided for @fieldRepeatPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get fieldRepeatPassword;

  /// No description provided for @fieldFullName.
  ///
  /// In de, this message translates to:
  /// **'Vollständiger Name'**
  String get fieldFullName;

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
  /// **'Geburtsdatum auswählen'**
  String get fieldBirthDatePicker;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine gültige E-Mail-Adresse ein.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordMin6.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort muss mindestens 6 Zeichen lang sein.'**
  String get validationPasswordMin6;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In de, this message translates to:
  /// **'Die Passwörter stimmen nicht überein.'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deinen Namen ein.'**
  String get validationNameRequired;

  /// No description provided for @validationBirthDateRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib dein Geburtsdatum ein.'**
  String get validationBirthDateRequired;

  /// No description provided for @validationRepeatPassword.
  ///
  /// In de, this message translates to:
  /// **'Bitte wiederhole das Passwort.'**
  String get validationRepeatPassword;

  /// No description provided for @datePickerCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get datePickerCancel;

  /// No description provided for @datePickerConfirm.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get datePickerConfirm;

  /// No description provided for @agbAcceptPrefix.
  ///
  /// In de, this message translates to:
  /// **'Ich akzeptiere die '**
  String get agbAcceptPrefix;

  /// No description provided for @agbTermsLink.
  ///
  /// In de, this message translates to:
  /// **'AGB'**
  String get agbTermsLink;

  /// No description provided for @agbAndConnector.
  ///
  /// In de, this message translates to:
  /// **' und die '**
  String get agbAndConnector;

  /// No description provided for @agbPrivacyLink.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get agbPrivacyLink;

  /// No description provided for @languageLabel.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get languageLabel;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Diese App ersetzt keine ärztliche Beratung. Bei gesundheitlichen Beschwerden wende dich an deinen Arzt.'**
  String get medicalDisclaimer;

  /// No description provided for @doctorRegTitle.
  ///
  /// In de, this message translates to:
  /// **'Als Arzt registrieren'**
  String get doctorRegTitle;

  /// No description provided for @doctorRegRoleBadge.
  ///
  /// In de, this message translates to:
  /// **'Arzt'**
  String get doctorRegRoleBadge;

  /// No description provided for @doctorRegRoleBadgeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verifizierter medizinischer Fachexperte'**
  String get doctorRegRoleBadgeSubtitle;

  /// No description provided for @doctorRegPersonalData.
  ///
  /// In de, this message translates to:
  /// **'Persönliche Daten'**
  String get doctorRegPersonalData;

  /// No description provided for @doctorRegProfessionalData.
  ///
  /// In de, this message translates to:
  /// **'Berufliche Daten'**
  String get doctorRegProfessionalData;

  /// No description provided for @doctorRegNameHint.
  ///
  /// In de, this message translates to:
  /// **'Dr. Max Mustermann'**
  String get doctorRegNameHint;

  /// No description provided for @doctorRegEmailHint.
  ///
  /// In de, this message translates to:
  /// **'arzt@praxis.de'**
  String get doctorRegEmailHint;

  /// No description provided for @doctorRegEmailRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deine E-Mail-Adresse ein.'**
  String get doctorRegEmailRequired;

  /// No description provided for @doctorRegEmailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine gültige E-Mail-Adresse ein.'**
  String get doctorRegEmailInvalid;

  /// No description provided for @doctorRegPasswordMin8.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort muss mindestens 8 Zeichen lang sein.'**
  String get doctorRegPasswordMin8;

  /// No description provided for @doctorRegSpecialty.
  ///
  /// In de, this message translates to:
  /// **'Fachrichtung'**
  String get doctorRegSpecialty;

  /// No description provided for @doctorRegSelectSpecialty.
  ///
  /// In de, this message translates to:
  /// **'Fachrichtung auswählen'**
  String get doctorRegSelectSpecialty;

  /// No description provided for @doctorRegApprobation.
  ///
  /// In de, this message translates to:
  /// **'Approbationsnummer'**
  String get doctorRegApprobation;

  /// No description provided for @doctorRegApprobationHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. 12345678'**
  String get doctorRegApprobationHint;

  /// No description provided for @doctorRegApprobationRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deine Approbationsnummer ein.'**
  String get doctorRegApprobationRequired;

  /// No description provided for @doctorRegKvNumber.
  ///
  /// In de, this message translates to:
  /// **'KV-Nummer'**
  String get doctorRegKvNumber;

  /// No description provided for @doctorRegKvHint.
  ///
  /// In de, this message translates to:
  /// **'Optional'**
  String get doctorRegKvHint;

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
  /// **'Bitte gib deine Praxis an.'**
  String get doctorRegPracticeRequired;

  /// No description provided for @doctorRegServiceEmail.
  ///
  /// In de, this message translates to:
  /// **'Dienstliche E-Mail-Adresse'**
  String get doctorRegServiceEmail;

  /// No description provided for @doctorRegDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Ihre Angaben werden geprüft und Ihr Account nach erfolgreicher Verifizierung freigeschaltet.'**
  String get doctorRegDisclaimer;

  /// No description provided for @doctorRegSubmit.
  ///
  /// In de, this message translates to:
  /// **'Registrierung absenden'**
  String get doctorRegSubmit;

  /// No description provided for @doctorRegSubmitting.
  ///
  /// In de, this message translates to:
  /// **'Wird gesendet…'**
  String get doctorRegSubmitting;

  /// No description provided for @orgRegTitle.
  ///
  /// In de, this message translates to:
  /// **'Als Organisation registrieren'**
  String get orgRegTitle;

  /// No description provided for @orgRegRoleBadge.
  ///
  /// In de, this message translates to:
  /// **'Organisation'**
  String get orgRegRoleBadge;

  /// No description provided for @orgRegRoleBadgeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Krankenhäuser, Kliniken & Rehabilitationseinrichtungen'**
  String get orgRegRoleBadgeSubtitle;

  /// No description provided for @orgRegGeneralData.
  ///
  /// In de, this message translates to:
  /// **'Allgemeine Daten'**
  String get orgRegGeneralData;

  /// No description provided for @orgRegOrgData.
  ///
  /// In de, this message translates to:
  /// **'Organisationsdaten'**
  String get orgRegOrgData;

  /// No description provided for @orgRegOrgName.
  ///
  /// In de, this message translates to:
  /// **'Organisationsname'**
  String get orgRegOrgName;

  /// No description provided for @orgRegOrgNameHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Universitätsklinikum'**
  String get orgRegOrgNameHint;

  /// No description provided for @orgRegNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib den Organisationsnamen ein.'**
  String get orgRegNameRequired;

  /// No description provided for @orgRegOrgType.
  ///
  /// In de, this message translates to:
  /// **'Organisationstyp'**
  String get orgRegOrgType;

  /// No description provided for @orgRegSelectOrgType.
  ///
  /// In de, this message translates to:
  /// **'Organisationstyp auswählen'**
  String get orgRegSelectOrgType;

  /// No description provided for @orgRegAddress.
  ///
  /// In de, this message translates to:
  /// **'Adresse'**
  String get orgRegAddress;

  /// No description provided for @orgRegAddressHint.
  ///
  /// In de, this message translates to:
  /// **'Straße, PLZ, Ort'**
  String get orgRegAddressHint;

  /// No description provided for @orgRegAddressRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib die Adresse ein.'**
  String get orgRegAddressRequired;

  /// No description provided for @orgRegContactPerson.
  ///
  /// In de, this message translates to:
  /// **'Ansprechpartner'**
  String get orgRegContactPerson;

  /// No description provided for @orgRegContactPersonHint.
  ///
  /// In de, this message translates to:
  /// **'Vor- und Nachname'**
  String get orgRegContactPersonHint;

  /// No description provided for @orgRegContactPersonRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Ansprechpartner an.'**
  String get orgRegContactPersonRequired;

  /// No description provided for @orgRegEmail.
  ///
  /// In de, this message translates to:
  /// **'Organisations-E-Mail'**
  String get orgRegEmail;

  /// No description provided for @orgRegEmailHint.
  ///
  /// In de, this message translates to:
  /// **'info@organisation.de'**
  String get orgRegEmailHint;

  /// No description provided for @orgRegPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get orgRegPhone;

  /// No description provided for @orgRegPhoneHint.
  ///
  /// In de, this message translates to:
  /// **'+49 123 456789'**
  String get orgRegPhoneHint;

  /// No description provided for @orgRegDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Ihre Angaben werden geprüft und Ihr Account nach erfolgreicher Verifizierung freigeschaltet.'**
  String get orgRegDisclaimer;

  /// No description provided for @orgRegSubmit.
  ///
  /// In de, this message translates to:
  /// **'Registrierung absenden'**
  String get orgRegSubmit;

  /// No description provided for @orgRegSubmitting.
  ///
  /// In de, this message translates to:
  /// **'Wird gesendet…'**
  String get orgRegSubmitting;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsNotAvailable.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen nicht verfügbar'**
  String get settingsNotAvailable;

  /// No description provided for @settingsAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get settingsLogout;

  /// No description provided for @settingsNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settingsNotifications;

  /// No description provided for @settingsPush.
  ///
  /// In de, this message translates to:
  /// **'Push-Benachrichtigungen'**
  String get settingsPush;

  /// No description provided for @settingsEmailNotif.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Benachrichtigungen'**
  String get settingsEmailNotif;

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

  /// No description provided for @settingsResetData.
  ///
  /// In de, this message translates to:
  /// **'Daten zurücksetzen'**
  String get settingsResetData;

  /// No description provided for @settingsPro.
  ///
  /// In de, this message translates to:
  /// **'Pro-Version'**
  String get settingsPro;

  /// No description provided for @settingsProStatus.
  ///
  /// In de, this message translates to:
  /// **'Pro-Status'**
  String get settingsProStatus;

  /// No description provided for @settingsProSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Funktionen freischalten'**
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

  /// No description provided for @settingsVersion.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @tutorialSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get tutorialNext;

  /// No description provided for @tutorialFinish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get tutorialFinish;

  /// No description provided for @tutorialNeverShow.
  ///
  /// In de, this message translates to:
  /// **'Nicht mehr anzeigen'**
  String get tutorialNeverShow;

  /// No description provided for @tutorialStep1Title.
  ///
  /// In de, this message translates to:
  /// **'Willkommen! 👋'**
  String get tutorialStep1Title;

  /// No description provided for @tutorialStep1Desc.
  ///
  /// In de, this message translates to:
  /// **'Hallo, ich bin Bella! Hier siehst du alles Wichtige zu deiner OP auf einen Blick.'**
  String get tutorialStep1Desc;

  /// No description provided for @tutorialStep2Title.
  ///
  /// In de, this message translates to:
  /// **'Deine Termine'**
  String get tutorialStep2Title;

  /// No description provided for @tutorialStep2Desc.
  ///
  /// In de, this message translates to:
  /// **'Hier behältst du Arzttermine und Vorbereitungen im Blick – ich erinnere dich rechtzeitig.'**
  String get tutorialStep2Desc;

  /// No description provided for @tutorialStep3Title.
  ///
  /// In de, this message translates to:
  /// **'Ich bin immer da'**
  String get tutorialStep3Title;

  /// No description provided for @tutorialStep3Desc.
  ///
  /// In de, this message translates to:
  /// **'Das bin ich! 🐰 Tippe mich jederzeit an – ich beantworte alle Fragen rund um deine Genesung.'**
  String get tutorialStep3Desc;

  /// No description provided for @tutorialStep4Title.
  ///
  /// In de, this message translates to:
  /// **'Mehr entdecken'**
  String get tutorialStep4Title;

  /// No description provided for @tutorialStep4Desc.
  ///
  /// In de, this message translates to:
  /// **'Unter \'Mehr\' findest du Einstellungen, Hilfe und weitere hilfreiche Funktionen.'**
  String get tutorialStep4Desc;

  /// No description provided for @profileCompleteness.
  ///
  /// In de, this message translates to:
  /// **'Profilvollständigkeit'**
  String get profileCompleteness;

  /// No description provided for @profileStillTodo.
  ///
  /// In de, this message translates to:
  /// **'Noch zu erledigen'**
  String get profileStillTodo;

  /// No description provided for @profileMoreItems.
  ///
  /// In de, this message translates to:
  /// **'weitere'**
  String get profileMoreItems;

  /// No description provided for @profileComplete.
  ///
  /// In de, this message translates to:
  /// **'Profil vervollständigen'**
  String get profileComplete;

  /// No description provided for @profileCheckName.
  ///
  /// In de, this message translates to:
  /// **'Name angeben'**
  String get profileCheckName;

  /// No description provided for @profileCheckOpDate.
  ///
  /// In de, this message translates to:
  /// **'OP-Datum eintragen'**
  String get profileCheckOpDate;

  /// No description provided for @profileCheckOpType.
  ///
  /// In de, this message translates to:
  /// **'OP-Art auswählen'**
  String get profileCheckOpType;

  /// No description provided for @profileCheckDoctor.
  ///
  /// In de, this message translates to:
  /// **'Behandelnden Arzt angeben'**
  String get profileCheckDoctor;

  /// No description provided for @profileCheckHospital.
  ///
  /// In de, this message translates to:
  /// **'Krankenhaus angeben'**
  String get profileCheckHospital;

  /// No description provided for @profileCheckHeight.
  ///
  /// In de, this message translates to:
  /// **'Größe angeben'**
  String get profileCheckHeight;

  /// No description provided for @profileCheckWeight.
  ///
  /// In de, this message translates to:
  /// **'Gewicht angeben'**
  String get profileCheckWeight;

  /// No description provided for @profileCheckEmergencyContact.
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakt hinterlegen'**
  String get profileCheckEmergencyContact;

  /// No description provided for @doctorRegSpecialtyRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle eine Fachrichtung aus.'**
  String get doctorRegSpecialtyRequired;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get done;

  /// No description provided for @confirm.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retry;

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get remove;

  /// No description provided for @share.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get copy;

  /// No description provided for @send.
  ///
  /// In de, this message translates to:
  /// **'Senden'**
  String get send;

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// No description provided for @reset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get reset;

  /// No description provided for @activate.
  ///
  /// In de, this message translates to:
  /// **'Aktivieren'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In de, this message translates to:
  /// **'Deaktivieren'**
  String get deactivate;

  /// No description provided for @unlock.
  ///
  /// In de, this message translates to:
  /// **'Entsperren'**
  String get unlock;

  /// No description provided for @create.
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get create;

  /// No description provided for @update.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get update;

  /// No description provided for @yes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// No description provided for @all.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get all;

  /// No description provided for @none.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get none;

  /// No description provided for @details.
  ///
  /// In de, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @info.
  ///
  /// In de, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @warning.
  ///
  /// In de, this message translates to:
  /// **'Warnung'**
  String get warning;

  /// No description provided for @urgent.
  ///
  /// In de, this message translates to:
  /// **'Dringend'**
  String get urgent;

  /// No description provided for @critical.
  ///
  /// In de, this message translates to:
  /// **'Kritisch'**
  String get critical;

  /// No description provided for @high.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get high;

  /// No description provided for @low.
  ///
  /// In de, this message translates to:
  /// **'Niedrig'**
  String get low;

  /// No description provided for @normal.
  ///
  /// In de, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @minimal.
  ///
  /// In de, this message translates to:
  /// **'Minimal'**
  String get minimal;

  /// No description provided for @daily.
  ///
  /// In de, this message translates to:
  /// **'Täglich'**
  String get daily;

  /// No description provided for @weekdays.
  ///
  /// In de, this message translates to:
  /// **'Werktags'**
  String get weekdays;

  /// No description provided for @everyNDays.
  ///
  /// In de, this message translates to:
  /// **'Alle N Tage'**
  String get everyNDays;

  /// No description provided for @customDay.
  ///
  /// In de, this message translates to:
  /// **'Eigener Tag'**
  String get customDay;

  /// No description provided for @repeatUntil.
  ///
  /// In de, this message translates to:
  /// **'Wiederholen bis'**
  String get repeatUntil;

  /// No description provided for @repetition.
  ///
  /// In de, this message translates to:
  /// **'Wiederholung'**
  String get repetition;

  /// No description provided for @recurring.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrend'**
  String get recurring;

  /// No description provided for @allDay.
  ///
  /// In de, this message translates to:
  /// **'Ganztägig'**
  String get allDay;

  /// No description provided for @notAvailable.
  ///
  /// In de, this message translates to:
  /// **'Nicht verfügbar'**
  String get notAvailable;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In de, this message translates to:
  /// **'Abmelden?'**
  String get logoutConfirm;

  /// No description provided for @logoutAdminConfirm.
  ///
  /// In de, this message translates to:
  /// **'Wirklich aus dem Admin-Bereich abmelden?'**
  String get logoutAdminConfirm;

  /// No description provided for @login.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get login;

  /// No description provided for @register.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get register;

  /// No description provided for @accountRequired.
  ///
  /// In de, this message translates to:
  /// **'Konto erforderlich'**
  String get accountRequired;

  /// No description provided for @passwordConfirm.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get passwordConfirm;

  /// No description provided for @passwordChanged.
  ///
  /// In de, this message translates to:
  /// **'Passwort geändert'**
  String get passwordChanged;

  /// No description provided for @passwordReset.
  ///
  /// In de, this message translates to:
  /// **'Passwort zurücksetzen'**
  String get passwordReset;

  /// No description provided for @passwordResetDone.
  ///
  /// In de, this message translates to:
  /// **'Passwort wurde zurückgesetzt'**
  String get passwordResetDone;

  /// No description provided for @passwordsMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get passwordsMismatch;

  /// No description provided for @passwordMin6.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 6 Zeichen'**
  String get passwordMin6;

  /// No description provided for @newPasswordFor.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort für {name}'**
  String newPasswordFor(String name);

  /// No description provided for @deleteAccountTitle.
  ///
  /// In de, this message translates to:
  /// **'Account endgültig löschen?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Account löschen'**
  String get deleteAccount;

  /// No description provided for @deleteDataOnly.
  ///
  /// In de, this message translates to:
  /// **'Nur Daten löschen'**
  String get deleteDataOnly;

  /// No description provided for @deleteFinal.
  ///
  /// In de, this message translates to:
  /// **'Endgültig löschen'**
  String get deleteFinal;

  /// No description provided for @deleteUserAndData.
  ///
  /// In de, this message translates to:
  /// **'User und alle Daten gelöscht.'**
  String get deleteUserAndData;

  /// No description provided for @resetDataTitle.
  ///
  /// In de, this message translates to:
  /// **'Daten zurücksetzen'**
  String get resetDataTitle;

  /// No description provided for @allDataIrreversible.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten unwiderruflich entfernen'**
  String get allDataIrreversible;

  /// No description provided for @guestDataFound.
  ///
  /// In de, this message translates to:
  /// **'Lokale Daten gefunden'**
  String get guestDataFound;

  /// No description provided for @guestDataDiscard.
  ///
  /// In de, this message translates to:
  /// **'Nein, verwerfen'**
  String get guestDataDiscard;

  /// No description provided for @guestDataTransfer.
  ///
  /// In de, this message translates to:
  /// **'Ja, übertragen'**
  String get guestDataTransfer;

  /// No description provided for @settingSaveError.
  ///
  /// In de, this message translates to:
  /// **'Einstellung konnte nicht gespeichert werden.'**
  String get settingSaveError;

  /// No description provided for @settingSaved.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen gespeichert.'**
  String get settingSaved;

  /// No description provided for @tutorialRepeat.
  ///
  /// In de, this message translates to:
  /// **'Tutorial wiederholen'**
  String get tutorialRepeat;

  /// No description provided for @tutorialRepeatSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Einführung nochmals anzeigen'**
  String get tutorialRepeatSubtitle;

  /// No description provided for @notifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get notifications;

  /// No description provided for @notificationsActive.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen aktiv'**
  String get notificationsActive;

  /// No description provided for @notificationsManage.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen verwalten'**
  String get notificationsManage;

  /// No description provided for @notificationsCountNew.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen ({count} neu)'**
  String notificationsCountNew(int count);

  /// No description provided for @pushNotifications.
  ///
  /// In de, this message translates to:
  /// **'Push-Benachrichtigungen'**
  String get pushNotifications;

  /// No description provided for @privacyPolicy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In de, this message translates to:
  /// **'Nutzungsbedingungen'**
  String get termsOfUse;

  /// No description provided for @adDisplays.
  ///
  /// In de, this message translates to:
  /// **'Werbeanzeigen'**
  String get adDisplays;

  /// No description provided for @usageStats.
  ///
  /// In de, this message translates to:
  /// **'Nutzungsstatistiken'**
  String get usageStats;

  /// No description provided for @crashReports.
  ///
  /// In de, this message translates to:
  /// **'Absturzberichte'**
  String get crashReports;

  /// No description provided for @bellaAiAssistant.
  ///
  /// In de, this message translates to:
  /// **'Bella KI-Assistent'**
  String get bellaAiAssistant;

  /// No description provided for @exportAsPdf.
  ///
  /// In de, this message translates to:
  /// **'Als PDF exportieren'**
  String get exportAsPdf;

  /// No description provided for @exportAsPdfSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Übersichtlicher Bericht'**
  String get exportAsPdfSubtitle;

  /// No description provided for @exportAsJson.
  ///
  /// In de, this message translates to:
  /// **'Als JSON exportieren'**
  String get exportAsJson;

  /// No description provided for @exportAsJsonSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Rohdaten zum Archivieren'**
  String get exportAsJsonSubtitle;

  /// No description provided for @exportCreating.
  ///
  /// In de, this message translates to:
  /// **'Export wird erstellt …'**
  String get exportCreating;

  /// No description provided for @exportPreparing.
  ///
  /// In de, this message translates to:
  /// **'Export wird vorbereitet…'**
  String get exportPreparing;

  /// No description provided for @csvExporting.
  ///
  /// In de, this message translates to:
  /// **'CSV wird exportiert…'**
  String get csvExporting;

  /// No description provided for @appointment.
  ///
  /// In de, this message translates to:
  /// **'Termin'**
  String get appointment;

  /// No description provided for @appointmentCreate.
  ///
  /// In de, this message translates to:
  /// **'Termin erstellen'**
  String get appointmentCreate;

  /// No description provided for @appointmentAdd.
  ///
  /// In de, this message translates to:
  /// **'Termin hinzufügen'**
  String get appointmentAdd;

  /// No description provided for @appointmentConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Termin bestätigt'**
  String get appointmentConfirmed;

  /// No description provided for @appointmentDeclined.
  ///
  /// In de, this message translates to:
  /// **'Termin abgelehnt'**
  String get appointmentDeclined;

  /// No description provided for @appointmentDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Termin löschen?'**
  String get appointmentDeleteConfirm;

  /// No description provided for @appointmentSaveError.
  ///
  /// In de, this message translates to:
  /// **'Termin konnte nicht gespeichert werden.'**
  String get appointmentSaveError;

  /// No description provided for @appointmentCreateError.
  ///
  /// In de, this message translates to:
  /// **'Termin konnte nicht erstellt werden.'**
  String get appointmentCreateError;

  /// No description provided for @appointmentDeleteError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen des Termins'**
  String get appointmentDeleteError;

  /// No description provided for @appointmentForPatient.
  ///
  /// In de, this message translates to:
  /// **'Termin für einen Patienten erstellen'**
  String get appointmentForPatient;

  /// No description provided for @practiceAppointment.
  ///
  /// In de, this message translates to:
  /// **'Praxis-Termin'**
  String get practiceAppointment;

  /// No description provided for @practiceAppointmentOwn.
  ///
  /// In de, this message translates to:
  /// **'Eigenen praxisinternen Termin erstellen'**
  String get practiceAppointmentOwn;

  /// No description provided for @practiceAppointmentSaveError.
  ///
  /// In de, this message translates to:
  /// **'Praxis-Termin konnte nicht gespeichert werden.'**
  String get practiceAppointmentSaveError;

  /// No description provided for @practiceAppointmentDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Praxis-Termin löschen?'**
  String get practiceAppointmentDeleteConfirm;

  /// No description provided for @calendarAddTitle.
  ///
  /// In de, this message translates to:
  /// **'Zum Kalender hinzufügen?'**
  String get calendarAddTitle;

  /// No description provided for @calendarNoThanks.
  ///
  /// In de, this message translates to:
  /// **'Nein, danke'**
  String get calendarNoThanks;

  /// No description provided for @calendarShareIcs.
  ///
  /// In de, this message translates to:
  /// **'Als .ics teilen'**
  String get calendarShareIcs;

  /// No description provided for @calendarAdd.
  ///
  /// In de, this message translates to:
  /// **'Zum Kalender'**
  String get calendarAdd;

  /// No description provided for @medication.
  ///
  /// In de, this message translates to:
  /// **'Medikament'**
  String get medication;

  /// No description provided for @medicationAdd.
  ///
  /// In de, this message translates to:
  /// **'Medikament hinzufügen'**
  String get medicationAdd;

  /// No description provided for @medicationPlan.
  ///
  /// In de, this message translates to:
  /// **'Medikationsplan'**
  String get medicationPlan;

  /// No description provided for @medicationHubOpen.
  ///
  /// In de, this message translates to:
  /// **'Medikamenten-Hub öffnen'**
  String get medicationHubOpen;

  /// No description provided for @medicationIntakeTimes.
  ///
  /// In de, this message translates to:
  /// **'Einnahmezeiten'**
  String get medicationIntakeTimes;

  /// No description provided for @medicationIntakeSaveError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern der Einnahme'**
  String get medicationIntakeSaveError;

  /// No description provided for @medicationStock.
  ///
  /// In de, this message translates to:
  /// **'Vorrat (optional)'**
  String get medicationStock;

  /// No description provided for @medicationLocalAlarms.
  ///
  /// In de, this message translates to:
  /// **'Lokale Alarme für aktivierte Zeiten'**
  String get medicationLocalAlarms;

  /// No description provided for @medicationAlarmDeleteError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen des Weckers'**
  String get medicationAlarmDeleteError;

  /// No description provided for @patient.
  ///
  /// In de, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @patientInvite.
  ///
  /// In de, this message translates to:
  /// **'Patient einladen'**
  String get patientInvite;

  /// No description provided for @patientAdd.
  ///
  /// In de, this message translates to:
  /// **'Patient hinzufügen'**
  String get patientAdd;

  /// No description provided for @patientConnect.
  ///
  /// In de, this message translates to:
  /// **'Patient verbinden'**
  String get patientConnect;

  /// No description provided for @patientLinked.
  ///
  /// In de, this message translates to:
  /// **'Patient erfolgreich verknüpft!'**
  String get patientLinked;

  /// No description provided for @patientLinking.
  ///
  /// In de, this message translates to:
  /// **'Patient Linking'**
  String get patientLinking;

  /// No description provided for @patientPlan.
  ///
  /// In de, this message translates to:
  /// **'Patienten-Plan'**
  String get patientPlan;

  /// No description provided for @patientAppointment.
  ///
  /// In de, this message translates to:
  /// **'Patienten-Termin'**
  String get patientAppointment;

  /// No description provided for @patientData.
  ///
  /// In de, this message translates to:
  /// **'Patientendaten'**
  String get patientData;

  /// No description provided for @patientNoInvites.
  ///
  /// In de, this message translates to:
  /// **'Keine Patienten-Einladungen.'**
  String get patientNoInvites;

  /// No description provided for @doctor.
  ///
  /// In de, this message translates to:
  /// **'Arzt'**
  String get doctor;

  /// No description provided for @doctorAdd.
  ///
  /// In de, this message translates to:
  /// **'Arzt hinzufügen'**
  String get doctorAdd;

  /// No description provided for @doctorRemove.
  ///
  /// In de, this message translates to:
  /// **'Arzt entfernen'**
  String get doctorRemove;

  /// No description provided for @doctorConfirm.
  ///
  /// In de, this message translates to:
  /// **'Arzt bestätigen'**
  String get doctorConfirm;

  /// No description provided for @doctorDisconnect.
  ///
  /// In de, this message translates to:
  /// **'Arzt trennen'**
  String get doctorDisconnect;

  /// No description provided for @doctorDeleted.
  ///
  /// In de, this message translates to:
  /// **'Arzt gelöscht.'**
  String get doctorDeleted;

  /// No description provided for @doctorCreated.
  ///
  /// In de, this message translates to:
  /// **'Arzt wurde erstellt'**
  String get doctorCreated;

  /// No description provided for @doctorDetails.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Details'**
  String get doctorDetails;

  /// No description provided for @doctorCreateInvite.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Einladung erstellen'**
  String get doctorCreateInvite;

  /// No description provided for @doctorVerification.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Verifizierung'**
  String get doctorVerification;

  /// No description provided for @doctorNoInvites.
  ///
  /// In de, this message translates to:
  /// **'Keine Arzt-Einladungen.'**
  String get doctorNoInvites;

  /// No description provided for @doctorManage.
  ///
  /// In de, this message translates to:
  /// **'Ärzte verwalten'**
  String get doctorManage;

  /// No description provided for @doctorEnterUid.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine Arzt-UID eingeben.'**
  String get doctorEnterUid;

  /// No description provided for @doctorReportNotAvailable.
  ///
  /// In de, this message translates to:
  /// **'Arztbericht nicht verfügbar.'**
  String get doctorReportNotAvailable;

  /// No description provided for @treatingDoctor.
  ///
  /// In de, this message translates to:
  /// **'Behandelnder Arzt'**
  String get treatingDoctor;

  /// No description provided for @templateNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Vorlage'**
  String get templateNew;

  /// No description provided for @templateNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Vorlagen gefunden'**
  String get templateNone;

  /// No description provided for @templateDelete.
  ///
  /// In de, this message translates to:
  /// **'Vorlage löschen?'**
  String get templateDelete;

  /// No description provided for @templateDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie \"{name}\" wirklich löschen?'**
  String templateDeleteConfirm(String name);

  /// No description provided for @templateSaved.
  ///
  /// In de, this message translates to:
  /// **'Vorlage gespeichert'**
  String get templateSaved;

  /// No description provided for @templateSave.
  ///
  /// In de, this message translates to:
  /// **'Vorlage speichern'**
  String get templateSave;

  /// No description provided for @templateApply.
  ///
  /// In de, this message translates to:
  /// **'Vorlage anwenden'**
  String get templateApply;

  /// No description provided for @templateFromTasks.
  ///
  /// In de, this message translates to:
  /// **'Vorlage aus Aufgaben'**
  String get templateFromTasks;

  /// No description provided for @templateFromTasksCreate.
  ///
  /// In de, this message translates to:
  /// **'Vorlage aus Aufgaben erstellen'**
  String get templateFromTasksCreate;

  /// No description provided for @templateCreated.
  ///
  /// In de, this message translates to:
  /// **'Vorlage \"{name}\" erstellt'**
  String templateCreated(String name);

  /// No description provided for @templateDuplicated.
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" erstellt'**
  String templateDuplicated(String name);

  /// No description provided for @templateDuplicateError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Duplizieren'**
  String get templateDuplicateError;

  /// No description provided for @templateAdopted.
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" in eigene Vorlagen übernommen'**
  String templateAdopted(String name);

  /// No description provided for @templateAdoptError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Übernehmen'**
  String get templateAdoptError;

  /// No description provided for @templateDeleteError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen der Vorlage'**
  String get templateDeleteError;

  /// No description provided for @templateOwnTemplates.
  ///
  /// In de, this message translates to:
  /// **'Eigene Vorlagen'**
  String get templateOwnTemplates;

  /// No description provided for @templateDuplicate.
  ///
  /// In de, this message translates to:
  /// **'Duplizieren'**
  String get templateDuplicate;

  /// No description provided for @templateAdopt.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get templateAdopt;

  /// No description provided for @systemTemplates.
  ///
  /// In de, this message translates to:
  /// **'Systemvorlagen'**
  String get systemTemplates;

  /// No description provided for @systemTemplateDelete.
  ///
  /// In de, this message translates to:
  /// **'Systemvorlage löschen?'**
  String get systemTemplateDelete;

  /// No description provided for @systemTemplateNone.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Systemvorlagen'**
  String get systemTemplateNone;

  /// No description provided for @systemTemplateFirst.
  ///
  /// In de, this message translates to:
  /// **'Erste Systemvorlage'**
  String get systemTemplateFirst;

  /// No description provided for @task.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe'**
  String get task;

  /// No description provided for @taskDefine.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe definieren'**
  String get taskDefine;

  /// No description provided for @taskCreate.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe erstellen'**
  String get taskCreate;

  /// No description provided for @taskCreateError.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe konnte nicht erstellt werden.'**
  String get taskCreateError;

  /// No description provided for @taskAssign.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe zuweisen'**
  String get taskAssign;

  /// No description provided for @taskRequired.
  ///
  /// In de, this message translates to:
  /// **'Pflichtitem'**
  String get taskRequired;

  /// No description provided for @tasksCount.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben ({count})'**
  String tasksCount(int count);

  /// No description provided for @tasksSelectCount.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben auswählen ({selected}/{total}):'**
  String tasksSelectCount(int selected, int total);

  /// No description provided for @tasksSelectToApply.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben auswählen, die angewendet werden sollen:'**
  String get tasksSelectToApply;

  /// No description provided for @tasksNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Aufgaben'**
  String get tasksNone;

  /// No description provided for @tasksNoneYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Aufgaben'**
  String get tasksNoneYet;

  /// No description provided for @tasksNoneAdded.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Aufgaben hinzugefügt'**
  String get tasksNoneAdded;

  /// No description provided for @tasksNoneInPlan.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Aufgaben im Plan.'**
  String get tasksNoneInPlan;

  /// No description provided for @tasksNoneAssigned.
  ///
  /// In de, this message translates to:
  /// **'Keine zugewiesenen Aufgaben gefunden.'**
  String get tasksNoneAssigned;

  /// No description provided for @taskSaveError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern der Aufgabe'**
  String get taskSaveError;

  /// No description provided for @taskRepeatCount.
  ///
  /// In de, this message translates to:
  /// **'Anzahl Wiederholungen'**
  String get taskRepeatCount;

  /// No description provided for @taskDayOffset.
  ///
  /// In de, this message translates to:
  /// **'Tag-Offset'**
  String get taskDayOffset;

  /// No description provided for @taskDueAfterHours.
  ///
  /// In de, this message translates to:
  /// **'Fällig nach (Std.)'**
  String get taskDueAfterHours;

  /// No description provided for @taskTimeOfDay.
  ///
  /// In de, this message translates to:
  /// **'Tageszeit (optional)'**
  String get taskTimeOfDay;

  /// No description provided for @taskMustNotForget.
  ///
  /// In de, this message translates to:
  /// **'Darf auf keinen Fall vergessen werden'**
  String get taskMustNotForget;

  /// No description provided for @phase.
  ///
  /// In de, this message translates to:
  /// **'Phase'**
  String get phase;

  /// No description provided for @phases.
  ///
  /// In de, this message translates to:
  /// **'Phasen'**
  String get phases;

  /// No description provided for @phaseNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Phase'**
  String get phaseNone;

  /// No description provided for @phasesNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Phasen – alle Aufgaben sind allgemein.'**
  String get phasesNone;

  /// No description provided for @phaseRename.
  ///
  /// In de, this message translates to:
  /// **'Phase umbenennen'**
  String get phaseRename;

  /// No description provided for @inviteCreate.
  ///
  /// In de, this message translates to:
  /// **'Einladung erstellen'**
  String get inviteCreate;

  /// No description provided for @inviteCreated.
  ///
  /// In de, this message translates to:
  /// **'Einladung erstellt'**
  String get inviteCreated;

  /// No description provided for @inviteCreateError.
  ///
  /// In de, this message translates to:
  /// **'Einladung konnte nicht erstellt werden.'**
  String get inviteCreateError;

  /// No description provided for @inviteAcceptError.
  ///
  /// In de, this message translates to:
  /// **'Einladung konnte nicht akzeptiert werden.'**
  String get inviteAcceptError;

  /// No description provided for @inviteRevoke.
  ///
  /// In de, this message translates to:
  /// **'Einladung widerrufen?'**
  String get inviteRevoke;

  /// No description provided for @inviteRevoked.
  ///
  /// In de, this message translates to:
  /// **'Einladung widerrufen.'**
  String get inviteRevoked;

  /// No description provided for @inviteAccepted.
  ///
  /// In de, this message translates to:
  /// **'Invite akzeptiert.'**
  String get inviteAccepted;

  /// No description provided for @invitations.
  ///
  /// In de, this message translates to:
  /// **'Einladungen'**
  String get invitations;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In de, this message translates to:
  /// **'Einladungscode kopiert'**
  String get inviteCodeCopied;

  /// No description provided for @linkCopied.
  ///
  /// In de, this message translates to:
  /// **'Link kopiert'**
  String get linkCopied;

  /// No description provided for @codeCopied.
  ///
  /// In de, this message translates to:
  /// **'Code kopiert'**
  String get codeCopied;

  /// No description provided for @codeCopiedExcl.
  ///
  /// In de, this message translates to:
  /// **'Code kopiert!'**
  String get codeCopiedExcl;

  /// No description provided for @codeEnter.
  ///
  /// In de, this message translates to:
  /// **'Code eingeben'**
  String get codeEnter;

  /// No description provided for @codeCopy.
  ///
  /// In de, this message translates to:
  /// **'Code kopieren'**
  String get codeCopy;

  /// No description provided for @inviteFamilyMember.
  ///
  /// In de, this message translates to:
  /// **'Angehörige einladen'**
  String get inviteFamilyMember;

  /// No description provided for @observation.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung erfassen'**
  String get observation;

  /// No description provided for @observationNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Beobachtung'**
  String get observationNew;

  /// No description provided for @observationsNone.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Beobachtungen eingetragen.'**
  String get observationsNone;

  /// No description provided for @myObservations.
  ///
  /// In de, this message translates to:
  /// **'Meine Beobachtungen'**
  String get myObservations;

  /// No description provided for @woundDoc.
  ///
  /// In de, this message translates to:
  /// **'Wunddoku'**
  String get woundDoc;

  /// No description provided for @woundNoEntries.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Wundeinträge vorhanden.'**
  String get woundNoEntries;

  /// No description provided for @woundPhotoForAnalysis.
  ///
  /// In de, this message translates to:
  /// **'Wundfoto für Analyse'**
  String get woundPhotoForAnalysis;

  /// No description provided for @woundChoosePhoto.
  ///
  /// In de, this message translates to:
  /// **'Wähle ein Foto für die KI-Wundanalyse mit Bella'**
  String get woundChoosePhoto;

  /// No description provided for @woundNoPhotos.
  ///
  /// In de, this message translates to:
  /// **'Keine Wundfotos für die Analyse vorhanden.'**
  String get woundNoPhotos;

  /// No description provided for @woundNoPhoto.
  ///
  /// In de, this message translates to:
  /// **'Kein Foto für die Analyse vorhanden.'**
  String get woundNoPhoto;

  /// No description provided for @woundTakePhoto.
  ///
  /// In de, this message translates to:
  /// **'📷  Neues Foto aufnehmen'**
  String get woundTakePhoto;

  /// No description provided for @woundFromGallery.
  ///
  /// In de, this message translates to:
  /// **'🖼️  Aus Galerie wählen'**
  String get woundFromGallery;

  /// No description provided for @woundMinPhotos.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 2 Fotos für den Vergleich nötig.'**
  String get woundMinPhotos;

  /// No description provided for @woundCompare.
  ///
  /// In de, this message translates to:
  /// **'Vergleichen'**
  String get woundCompare;

  /// No description provided for @woundSliderMix.
  ///
  /// In de, this message translates to:
  /// **'A/B mit Slider mischen'**
  String get woundSliderMix;

  /// No description provided for @painLevel.
  ///
  /// In de, this message translates to:
  /// **'Schmerzstärke'**
  String get painLevel;

  /// No description provided for @painComparison.
  ///
  /// In de, this message translates to:
  /// **'Schmerzstärke Vergleich'**
  String get painComparison;

  /// No description provided for @painCourse7d.
  ///
  /// In de, this message translates to:
  /// **'Schmerzverlauf (7 Tage)'**
  String get painCourse7d;

  /// No description provided for @painSaved.
  ///
  /// In de, this message translates to:
  /// **'Schmerzwert gespeichert'**
  String get painSaved;

  /// No description provided for @painScoreOf10.
  ///
  /// In de, this message translates to:
  /// **'Schmerz: {score}/10'**
  String painScoreOf10(int score);

  /// No description provided for @painLevelOf10.
  ///
  /// In de, this message translates to:
  /// **'Schmerzlevel: {level}/10'**
  String painLevelOf10(int level);

  /// No description provided for @unbearable.
  ///
  /// In de, this message translates to:
  /// **'Unerträglich'**
  String get unbearable;

  /// No description provided for @moodSaved.
  ///
  /// In de, this message translates to:
  /// **'Stimmung gespeichert'**
  String get moodSaved;

  /// No description provided for @moodDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diesen Stimmungseintrag wirklich löschen?'**
  String get moodDeleteConfirm;

  /// No description provided for @nutritionDescribeMeal.
  ///
  /// In de, this message translates to:
  /// **'Bitte beschreibe deine Mahlzeit'**
  String get nutritionDescribeMeal;

  /// No description provided for @nutritionSaved.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit gespeichert'**
  String get nutritionSaved;

  /// No description provided for @nutritionRecipes.
  ///
  /// In de, this message translates to:
  /// **'Rezepte'**
  String get nutritionRecipes;

  /// No description provided for @nutritionDailyGoals.
  ///
  /// In de, this message translates to:
  /// **'Tagesziele'**
  String get nutritionDailyGoals;

  /// No description provided for @vitalsMeasurementSaved.
  ///
  /// In de, this message translates to:
  /// **'Messung gespeichert'**
  String get vitalsMeasurementSaved;

  /// No description provided for @vitalsNewMeasurementsSync.
  ///
  /// In de, this message translates to:
  /// **'{count} neue Messungen aus Health synchronisiert'**
  String vitalsNewMeasurementsSync(int count);

  /// No description provided for @bodyData.
  ///
  /// In de, this message translates to:
  /// **'Körperdaten'**
  String get bodyData;

  /// No description provided for @packingListReset.
  ///
  /// In de, this message translates to:
  /// **'Packliste zurücksetzen?'**
  String get packingListReset;

  /// No description provided for @packingListNoItems.
  ///
  /// In de, this message translates to:
  /// **'Keine Packlisten-Einträge vorhanden.'**
  String get packingListNoItems;

  /// No description provided for @packingListDelete.
  ///
  /// In de, this message translates to:
  /// **'Liste löschen?'**
  String get packingListDelete;

  /// No description provided for @packingListRename.
  ///
  /// In de, this message translates to:
  /// **'Liste umbenennen'**
  String get packingListRename;

  /// No description provided for @packingListNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Liste'**
  String get packingListNew;

  /// No description provided for @packingListName.
  ///
  /// In de, this message translates to:
  /// **'Listenname'**
  String get packingListName;

  /// No description provided for @packingListAddItem.
  ///
  /// In de, this message translates to:
  /// **'Item hinzufügen'**
  String get packingListAddItem;

  /// No description provided for @documentUpload.
  ///
  /// In de, this message translates to:
  /// **'Dokument hochladen'**
  String get documentUpload;

  /// No description provided for @documentDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Dokument löschen?'**
  String get documentDeleteConfirm;

  /// No description provided for @documentSavedLocally.
  ///
  /// In de, this message translates to:
  /// **'Dokument lokal gespeichert.'**
  String get documentSavedLocally;

  /// No description provided for @documentsOpen.
  ///
  /// In de, this message translates to:
  /// **'Dokumente öffnen'**
  String get documentsOpen;

  /// No description provided for @documentsAll.
  ///
  /// In de, this message translates to:
  /// **'Alle Dokumente'**
  String get documentsAll;

  /// No description provided for @noteDelete.
  ///
  /// In de, this message translates to:
  /// **'Notiz löschen'**
  String get noteDelete;

  /// No description provided for @noteSave.
  ///
  /// In de, this message translates to:
  /// **'Notiz speichern'**
  String get noteSave;

  /// No description provided for @noteDeleteError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen der Notiz'**
  String get noteDeleteError;

  /// No description provided for @noteSaveError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern der Notiz'**
  String get noteSaveError;

  /// No description provided for @voiceMemoSaved.
  ///
  /// In de, this message translates to:
  /// **'Memo gespeichert'**
  String get voiceMemoSaved;

  /// No description provided for @voiceMemoDelete.
  ///
  /// In de, this message translates to:
  /// **'Memo löschen?'**
  String get voiceMemoDelete;

  /// No description provided for @voiceStartRecording.
  ///
  /// In de, this message translates to:
  /// **'Aufnahme starten'**
  String get voiceStartRecording;

  /// No description provided for @voiceNoMemos.
  ///
  /// In de, this message translates to:
  /// **'Keine Memos gefunden.'**
  String get voiceNoMemos;

  /// No description provided for @voiceTranscriptSaved.
  ///
  /// In de, this message translates to:
  /// **'Transkript gespeichert'**
  String get voiceTranscriptSaved;

  /// No description provided for @voiceNoTranscript.
  ///
  /// In de, this message translates to:
  /// **'Kein Transkript vorhanden – bitte zuerst transkribieren.'**
  String get voiceNoTranscript;

  /// No description provided for @voiceAudioNotFoundLocal.
  ///
  /// In de, this message translates to:
  /// **'Audiodatei lokal nicht gefunden.'**
  String get voiceAudioNotFoundLocal;

  /// No description provided for @voiceAudioNotFound.
  ///
  /// In de, this message translates to:
  /// **'Audiodatei nicht gefunden.'**
  String get voiceAudioNotFound;

  /// No description provided for @voiceMicPermissionMissing.
  ///
  /// In de, this message translates to:
  /// **'Mikrofon-Berechtigung fehlt.'**
  String get voiceMicPermissionMissing;

  /// No description provided for @profileEdit.
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get profileEdit;

  /// No description provided for @profileSaved.
  ///
  /// In de, this message translates to:
  /// **'Profil gespeichert'**
  String get profileSaved;

  /// No description provided for @profileSaveError.
  ///
  /// In de, this message translates to:
  /// **'Profil konnte nicht gespeichert werden.'**
  String get profileSaveError;

  /// No description provided for @yourDetails.
  ///
  /// In de, this message translates to:
  /// **'Deine Angaben'**
  String get yourDetails;

  /// No description provided for @smokerStatus.
  ///
  /// In de, this message translates to:
  /// **'Raucherstatus'**
  String get smokerStatus;

  /// No description provided for @hospitalClinic.
  ///
  /// In de, this message translates to:
  /// **'Krankenhaus / Klinik'**
  String get hospitalClinic;

  /// No description provided for @treatmentType.
  ///
  /// In de, this message translates to:
  /// **'Behandlungsart *'**
  String get treatmentType;

  /// No description provided for @opDate.
  ///
  /// In de, this message translates to:
  /// **'OP-Datum *'**
  String get opDate;

  /// No description provided for @currentOperation.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Operation'**
  String get currentOperation;

  /// No description provided for @operationArchived.
  ///
  /// In de, this message translates to:
  /// **'Operation archiviert'**
  String get operationArchived;

  /// No description provided for @markOpComplete.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle OP als abgeschlossen markieren'**
  String get markOpComplete;

  /// No description provided for @stayType.
  ///
  /// In de, this message translates to:
  /// **'Art des Aufenthalts'**
  String get stayType;

  /// No description provided for @startDateOpDate.
  ///
  /// In de, this message translates to:
  /// **'Startdatum (z.B. OP-Datum)'**
  String get startDateOpDate;

  /// No description provided for @emergencyContact.
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakt'**
  String get emergencyContact;

  /// No description provided for @transportPlanSaved.
  ///
  /// In de, this message translates to:
  /// **'Transportplanung gespeichert'**
  String get transportPlanSaved;

  /// No description provided for @healthOverview.
  ///
  /// In de, this message translates to:
  /// **'Dein Gesundheitsüberblick'**
  String get healthOverview;

  /// No description provided for @proUnlock.
  ///
  /// In de, this message translates to:
  /// **'Pro freischalten'**
  String get proUnlock;

  /// No description provided for @proRedeemKey.
  ///
  /// In de, this message translates to:
  /// **'Pro Key einlösen'**
  String get proRedeemKey;

  /// No description provided for @proKeys.
  ///
  /// In de, this message translates to:
  /// **'Pro-Keys'**
  String get proKeys;

  /// No description provided for @proKeysCreate.
  ///
  /// In de, this message translates to:
  /// **'Pro-Keys erstellen'**
  String get proKeysCreate;

  /// No description provided for @proGrantAccess.
  ///
  /// In de, this message translates to:
  /// **'Pro-Zugang vergeben'**
  String get proGrantAccess;

  /// No description provided for @proHowManyDays.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Tage Pro-Zugang?'**
  String get proHowManyDays;

  /// No description provided for @proStatusChangeError.
  ///
  /// In de, this message translates to:
  /// **'Pro-Status konnte nicht geändert werden.'**
  String get proStatusChangeError;

  /// No description provided for @proManageSubscription.
  ///
  /// In de, this message translates to:
  /// **'Abo verwalten'**
  String get proManageSubscription;

  /// No description provided for @proRestorePurchase.
  ///
  /// In de, this message translates to:
  /// **'Kauf wiederherstellen'**
  String get proRestorePurchase;

  /// No description provided for @staffMember.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter {action}'**
  String staffMember(String action);

  /// No description provided for @staffUpdated.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter aktualisiert'**
  String get staffUpdated;

  /// No description provided for @staffRemove.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter entfernen'**
  String get staffRemove;

  /// No description provided for @staffCreate.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter erstellen'**
  String get staffCreate;

  /// No description provided for @staffCreated.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter wurde erstellt'**
  String get staffCreated;

  /// No description provided for @orgJoin.
  ///
  /// In de, this message translates to:
  /// **'Organisation beitreten'**
  String get orgJoin;

  /// No description provided for @orgJoinWithCode.
  ///
  /// In de, this message translates to:
  /// **'Mit Einladungscode beitreten'**
  String get orgJoinWithCode;

  /// No description provided for @orgConfirm.
  ///
  /// In de, this message translates to:
  /// **'Organisation bestätigen'**
  String get orgConfirm;

  /// No description provided for @orgVerification.
  ///
  /// In de, this message translates to:
  /// **'Organisations‑Verifizierung'**
  String get orgVerification;

  /// No description provided for @ticketNew.
  ///
  /// In de, this message translates to:
  /// **'Neues Ticket'**
  String get ticketNew;

  /// No description provided for @ticketCreated.
  ///
  /// In de, this message translates to:
  /// **'Ticket erstellt!'**
  String get ticketCreated;

  /// No description provided for @ticketClosed.
  ///
  /// In de, this message translates to:
  /// **'Ticket geschlossen.'**
  String get ticketClosed;

  /// No description provided for @ticketCloseConfirm.
  ///
  /// In de, this message translates to:
  /// **'Ticket schließen?'**
  String get ticketCloseConfirm;

  /// No description provided for @ticketCloseExplanation.
  ///
  /// In de, this message translates to:
  /// **'Das Ticket wird als geschlossen markiert.'**
  String get ticketCloseExplanation;

  /// No description provided for @tickets.
  ///
  /// In de, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @ticketsCountOpen.
  ///
  /// In de, this message translates to:
  /// **'Tickets ({count} offen)'**
  String ticketsCountOpen(int count);

  /// No description provided for @myTickets.
  ///
  /// In de, this message translates to:
  /// **'Meine Tickets'**
  String get myTickets;

  /// No description provided for @messageSendError.
  ///
  /// In de, this message translates to:
  /// **'Nachricht konnte nicht gesendet werden.'**
  String get messageSendError;

  /// No description provided for @message.
  ///
  /// In de, this message translates to:
  /// **'Nachricht'**
  String get message;

  /// No description provided for @noMessagesYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Nachrichten.'**
  String get noMessagesYet;

  /// No description provided for @questionAdd.
  ///
  /// In de, this message translates to:
  /// **'Frage hinzufügen'**
  String get questionAdd;

  /// No description provided for @questionNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Frage'**
  String get questionNew;

  /// No description provided for @questionCreate.
  ///
  /// In de, this message translates to:
  /// **'Frage anlegen'**
  String get questionCreate;

  /// No description provided for @questionDelete.
  ///
  /// In de, this message translates to:
  /// **'Frage löschen?'**
  String get questionDelete;

  /// No description provided for @loginToSaveQuestions.
  ///
  /// In de, this message translates to:
  /// **'Bitte melde dich an, um Fragen zu speichern.'**
  String get loginToSaveQuestions;

  /// No description provided for @bellaSummarize.
  ///
  /// In de, this message translates to:
  /// **'Mit Bella zusammenfassen'**
  String get bellaSummarize;

  /// No description provided for @bellaAnalyze.
  ///
  /// In de, this message translates to:
  /// **'Mit Bella analysieren'**
  String get bellaAnalyze;

  /// No description provided for @bellaGenerate.
  ///
  /// In de, this message translates to:
  /// **'Jetzt generieren'**
  String get bellaGenerate;

  /// No description provided for @bellaRegenerate.
  ///
  /// In de, this message translates to:
  /// **'Neu generieren'**
  String get bellaRegenerate;

  /// No description provided for @bellaBriefingCopied.
  ///
  /// In de, this message translates to:
  /// **'Briefing in die Zwischenablage kopiert'**
  String get bellaBriefingCopied;

  /// No description provided for @redFlagSaved.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen-Check gespeichert ({level})'**
  String redFlagSaved(String level);

  /// No description provided for @severityCourse.
  ///
  /// In de, this message translates to:
  /// **'Schweregrad-Verlauf'**
  String get severityCourse;

  /// No description provided for @lastFlags.
  ///
  /// In de, this message translates to:
  /// **'Letzte Flags'**
  String get lastFlags;

  /// No description provided for @lastEntries.
  ///
  /// In de, this message translates to:
  /// **'Letzte Einträge:'**
  String get lastEntries;

  /// No description provided for @photoSaved.
  ///
  /// In de, this message translates to:
  /// **'Foto gespeichert und synchronisiert.'**
  String get photoSaved;

  /// No description provided for @photo.
  ///
  /// In de, this message translates to:
  /// **'Foto'**
  String get photo;

  /// No description provided for @cameraOpening.
  ///
  /// In de, this message translates to:
  /// **'Kamera wird geöffnet…'**
  String get cameraOpening;

  /// No description provided for @entryDeleted.
  ///
  /// In de, this message translates to:
  /// **'Eintrag gelöscht'**
  String get entryDeleted;

  /// No description provided for @entryDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen?'**
  String get entryDeleteConfirm;

  /// No description provided for @entryDeleteIrreversible.
  ///
  /// In de, this message translates to:
  /// **'Dieser Eintrag wird unwiderruflich gelöscht.'**
  String get entryDeleteIrreversible;

  /// No description provided for @entryDetailed.
  ///
  /// In de, this message translates to:
  /// **'Detaillierter Eintrag'**
  String get entryDetailed;

  /// No description provided for @entryNew.
  ///
  /// In de, this message translates to:
  /// **'Neuer Eintrag'**
  String get entryNew;

  /// No description provided for @minTwoEntriesForComparison.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 2 Einträge für Vergleich nötig.'**
  String get minTwoEntriesForComparison;

  /// No description provided for @saveError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern'**
  String get saveError;

  /// No description provided for @saveFailed.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen'**
  String get saveFailed;

  /// No description provided for @saveFailedDot.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen.'**
  String get saveFailedDot;

  /// No description provided for @deleteError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen'**
  String get deleteError;

  /// No description provided for @disconnectError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Trennen'**
  String get disconnectError;

  /// No description provided for @restoreError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Wiederherstellen'**
  String get restoreError;

  /// No description provided for @pinError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Anheften'**
  String get pinError;

  /// No description provided for @unlockFailed.
  ///
  /// In de, this message translates to:
  /// **'Entsperren fehlgeschlagen.'**
  String get unlockFailed;

  /// No description provided for @lockFailed.
  ///
  /// In de, this message translates to:
  /// **'Sperren fehlgeschlagen.'**
  String get lockFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In de, this message translates to:
  /// **'Löschung fehlgeschlagen.'**
  String get deleteFailed;

  /// No description provided for @actionFailed.
  ///
  /// In de, this message translates to:
  /// **'Aktion fehlgeschlagen.'**
  String get actionFailed;

  /// No description provided for @dataLoadError.
  ///
  /// In de, this message translates to:
  /// **'Daten konnten nicht geladen werden.'**
  String get dataLoadError;

  /// No description provided for @pageOpenError.
  ///
  /// In de, this message translates to:
  /// **'Diese Seite konnte nicht geöffnet werden.'**
  String get pageOpenError;

  /// No description provided for @noLocalFile.
  ///
  /// In de, this message translates to:
  /// **'Keine lokale Datei vorhanden.'**
  String get noLocalFile;

  /// No description provided for @fileNotFound.
  ///
  /// In de, this message translates to:
  /// **'Datei nicht gefunden.'**
  String get fileNotFound;

  /// No description provided for @fileReadError.
  ///
  /// In de, this message translates to:
  /// **'Datei konnte nicht gelesen werden.'**
  String get fileReadError;

  /// No description provided for @uploadPending.
  ///
  /// In de, this message translates to:
  /// **'Upload ausstehend. Wird erneut versucht.'**
  String get uploadPending;

  /// No description provided for @uploadFailedLocal.
  ///
  /// In de, this message translates to:
  /// **'Upload fehlgeschlagen – lokal gespeichert.'**
  String get uploadFailedLocal;

  /// No description provided for @noEmailApp.
  ///
  /// In de, this message translates to:
  /// **'Keine E-Mail-App gefunden'**
  String get noEmailApp;

  /// No description provided for @titleRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Titel eingeben'**
  String get titleRequired;

  /// No description provided for @titleAndMessageRequired.
  ///
  /// In de, this message translates to:
  /// **'Titel und Nachricht dürfen nicht leer sein.'**
  String get titleAndMessageRequired;

  /// No description provided for @titleAndUrlRequired.
  ///
  /// In de, this message translates to:
  /// **'Titel und URL sind erforderlich.'**
  String get titleAndUrlRequired;

  /// No description provided for @urlInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine vollständige http(s)-URL eingeben.'**
  String get urlInvalid;

  /// No description provided for @imageRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte ein Bild für die Partner-Anzeige auswählen.'**
  String get imageRequired;

  /// No description provided for @resultSaved.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis gespeichert'**
  String get resultSaved;

  /// No description provided for @copiedToClipboard.
  ///
  /// In de, this message translates to:
  /// **'In Zwischenablage kopiert!'**
  String get copiedToClipboard;

  /// No description provided for @reportCopied.
  ///
  /// In de, this message translates to:
  /// **'Bericht in Zwischenablage kopiert'**
  String get reportCopied;

  /// No description provided for @allCopied.
  ///
  /// In de, this message translates to:
  /// **'Alle Keys in Zwischenablage kopiert!'**
  String get allCopied;

  /// No description provided for @allCopy.
  ///
  /// In de, this message translates to:
  /// **'Alle kopieren'**
  String get allCopy;

  /// No description provided for @selectSpecialty.
  ///
  /// In de, this message translates to:
  /// **'Bitte Fachrichtung auswählen'**
  String get selectSpecialty;

  /// No description provided for @selectMinOneSection.
  ///
  /// In de, this message translates to:
  /// **'Wähle mindestens eine Sektion aus.'**
  String get selectMinOneSection;

  /// No description provided for @errorGeneric.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorGeneric(String error);

  /// No description provided for @testNotificationCreated.
  ///
  /// In de, this message translates to:
  /// **'Test-Benachrichtigung erstellt.'**
  String get testNotificationCreated;

  /// No description provided for @companion.
  ///
  /// In de, this message translates to:
  /// **'Begleiter'**
  String get companion;

  /// No description provided for @timeline.
  ///
  /// In de, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @toTimeline.
  ///
  /// In de, this message translates to:
  /// **'Zur Timeline'**
  String get toTimeline;

  /// No description provided for @openDiary.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch öffnen'**
  String get openDiary;

  /// No description provided for @openFullDiary.
  ///
  /// In de, this message translates to:
  /// **'Vollständiges Tagebuch öffnen'**
  String get openFullDiary;

  /// No description provided for @checklists.
  ///
  /// In de, this message translates to:
  /// **'Checkliste'**
  String get checklists;

  /// No description provided for @categories.
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get categories;

  /// No description provided for @statistics.
  ///
  /// In de, this message translates to:
  /// **'Statistiken'**
  String get statistics;

  /// No description provided for @statisticsLoadError.
  ///
  /// In de, this message translates to:
  /// **'Statistiken konnten nicht aktualisiert werden.'**
  String get statisticsLoadError;

  /// No description provided for @statisticsLoading.
  ///
  /// In de, this message translates to:
  /// **'Statistiken werden geladen...'**
  String get statisticsLoading;

  /// No description provided for @tags.
  ///
  /// In de, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @permissions.
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen'**
  String get permissions;

  /// No description provided for @permissionsUpdated.
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen aktualisiert'**
  String get permissionsUpdated;

  /// No description provided for @myPermissions.
  ///
  /// In de, this message translates to:
  /// **'Meine Berechtigungen'**
  String get myPermissions;

  /// No description provided for @readAllowed.
  ///
  /// In de, this message translates to:
  /// **'Lesen erlauben'**
  String get readAllowed;

  /// No description provided for @writeAllowed.
  ///
  /// In de, this message translates to:
  /// **'Schreiben erlauben'**
  String get writeAllowed;

  /// No description provided for @readOnly.
  ///
  /// In de, this message translates to:
  /// **'Nur Lesen'**
  String get readOnly;

  /// No description provided for @read.
  ///
  /// In de, this message translates to:
  /// **'Lesen'**
  String get read;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get general;

  /// No description provided for @practice.
  ///
  /// In de, this message translates to:
  /// **'Praxis'**
  String get practice;

  /// No description provided for @history.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get history;

  /// No description provided for @preview.
  ///
  /// In de, this message translates to:
  /// **'Vorschau'**
  String get preview;

  /// No description provided for @status.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @role.
  ///
  /// In de, this message translates to:
  /// **'Rolle'**
  String get role;

  /// No description provided for @roleChange.
  ///
  /// In de, this message translates to:
  /// **'Rolle ändern'**
  String get roleChange;

  /// No description provided for @roleChangeError.
  ///
  /// In de, this message translates to:
  /// **'Rolle konnte nicht geändert werden.'**
  String get roleChangeError;

  /// No description provided for @roleDistribution.
  ///
  /// In de, this message translates to:
  /// **'Rollenverteilung'**
  String get roleDistribution;

  /// No description provided for @markAsRead.
  ///
  /// In de, this message translates to:
  /// **'Als gelesen markieren'**
  String get markAsRead;

  /// No description provided for @unread.
  ///
  /// In de, this message translates to:
  /// **'Ungelesen'**
  String get unread;

  /// No description provided for @pending.
  ///
  /// In de, this message translates to:
  /// **'Ausstehend'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In de, this message translates to:
  /// **'Akzeptiert'**
  String get accepted;

  /// No description provided for @declined.
  ///
  /// In de, this message translates to:
  /// **'Abgelehnt'**
  String get declined;

  /// No description provided for @resolved.
  ///
  /// In de, this message translates to:
  /// **'Gelöst'**
  String get resolved;

  /// No description provided for @inProgress.
  ///
  /// In de, this message translates to:
  /// **'In Bearbeitung'**
  String get inProgress;

  /// No description provided for @locked.
  ///
  /// In de, this message translates to:
  /// **'Gesperrt'**
  String get locked;

  /// No description provided for @full.
  ///
  /// In de, this message translates to:
  /// **'Voll'**
  String get full;

  /// No description provided for @off.
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get off;

  /// No description provided for @system.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @user.
  ///
  /// In de, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @overlayMode.
  ///
  /// In de, this message translates to:
  /// **'Overlay-Modus'**
  String get overlayMode;

  /// No description provided for @comingSoon.
  ///
  /// In de, this message translates to:
  /// **'Kommt gleich'**
  String get comingSoon;

  /// No description provided for @noAccess.
  ///
  /// In de, this message translates to:
  /// **'Kein Zugriff'**
  String get noAccess;

  /// No description provided for @sureQuestion.
  ///
  /// In de, this message translates to:
  /// **'Sicher?'**
  String get sureQuestion;

  /// No description provided for @disconnect.
  ///
  /// In de, this message translates to:
  /// **'Trennen'**
  String get disconnect;

  /// No description provided for @disconnectConfirm.
  ///
  /// In de, this message translates to:
  /// **'Verbindung trennen?'**
  String get disconnectConfirm;

  /// No description provided for @disconnected.
  ///
  /// In de, this message translates to:
  /// **'Verbindung aufgelöst'**
  String get disconnected;

  /// No description provided for @connect.
  ///
  /// In de, this message translates to:
  /// **'Verbinden'**
  String get connect;

  /// No description provided for @connectionRemove.
  ///
  /// In de, this message translates to:
  /// **'Verknüpfung entfernen'**
  String get connectionRemove;

  /// No description provided for @archive.
  ///
  /// In de, this message translates to:
  /// **'Archivieren'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get restore;

  /// No description provided for @rename.
  ///
  /// In de, this message translates to:
  /// **'Umbenennen'**
  String get rename;

  /// No description provided for @editTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel bearbeiten'**
  String get editTitle;

  /// No description provided for @filterReset.
  ///
  /// In de, this message translates to:
  /// **'Filter zurücksetzen'**
  String get filterReset;

  /// No description provided for @sendEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail senden'**
  String get sendEmail;

  /// No description provided for @day.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get day;

  /// No description provided for @moreTools.
  ///
  /// In de, this message translates to:
  /// **'Weitere Tools'**
  String get moreTools;

  /// No description provided for @checkAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmals prüfen'**
  String get checkAgain;

  /// No description provided for @adDelete.
  ///
  /// In de, this message translates to:
  /// **'Anzeige löschen?'**
  String get adDelete;

  /// No description provided for @adDeleteMessage.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ wird unwiderruflich gelöscht.'**
  String adDeleteMessage(String title);

  /// No description provided for @adGlobalSettings.
  ///
  /// In de, this message translates to:
  /// **'Globale Einstellungen'**
  String get adGlobalSettings;

  /// No description provided for @adEnabled.
  ///
  /// In de, this message translates to:
  /// **'Werbung aktiviert'**
  String get adEnabled;

  /// No description provided for @adGoogleAds.
  ///
  /// In de, this message translates to:
  /// **'Google Ads'**
  String get adGoogleAds;

  /// No description provided for @adAdmobBanner.
  ///
  /// In de, this message translates to:
  /// **'AdMob Banner-Werbung anzeigen'**
  String get adAdmobBanner;

  /// No description provided for @adPartnerAds.
  ///
  /// In de, this message translates to:
  /// **'Partner-Anzeigen'**
  String get adPartnerAds;

  /// No description provided for @adPartnerAdsCount.
  ///
  /// In de, this message translates to:
  /// **'Partner-Anzeigen ({count})'**
  String adPartnerAdsCount(int count);

  /// No description provided for @adFrequency.
  ///
  /// In de, this message translates to:
  /// **'Häufigkeit'**
  String get adFrequency;

  /// No description provided for @adPartnerCreate.
  ///
  /// In de, this message translates to:
  /// **'Partner-Anzeige erstellen'**
  String get adPartnerCreate;

  /// No description provided for @adminActivities7d.
  ///
  /// In de, this message translates to:
  /// **'Admin-Aktivitäten (7 Tage)'**
  String get adminActivities7d;

  /// No description provided for @adminActionDistribution7d.
  ///
  /// In de, this message translates to:
  /// **'Aktionsverteilung (7 Tage)'**
  String get adminActionDistribution7d;

  /// No description provided for @adminNewRegistrations30d.
  ///
  /// In de, this message translates to:
  /// **'Neuregistrierungen (30 Tage)'**
  String get adminNewRegistrations30d;

  /// No description provided for @adminRegistrations.
  ///
  /// In de, this message translates to:
  /// **'Registrierungen'**
  String get adminRegistrations;

  /// No description provided for @adminStatusOverview.
  ///
  /// In de, this message translates to:
  /// **'Status-Übersicht'**
  String get adminStatusOverview;

  /// No description provided for @adminAllRoles.
  ///
  /// In de, this message translates to:
  /// **'Alle Rollen'**
  String get adminAllRoles;

  /// No description provided for @adminUserManage.
  ///
  /// In de, this message translates to:
  /// **'Nutzer verwalten'**
  String get adminUserManage;

  /// No description provided for @adminUserLock.
  ///
  /// In de, this message translates to:
  /// **'Nutzer sperren'**
  String get adminUserLock;

  /// No description provided for @adminAuditLog.
  ///
  /// In de, this message translates to:
  /// **'Audit-Log'**
  String get adminAuditLog;

  /// No description provided for @adminLogsAppear.
  ///
  /// In de, this message translates to:
  /// **'Logs erscheinen hier.'**
  String get adminLogsAppear;

  /// No description provided for @adminMaintenanceMode.
  ///
  /// In de, this message translates to:
  /// **'Wartungsmodus aktivieren'**
  String get adminMaintenanceMode;

  /// No description provided for @adminMaintenanceError.
  ///
  /// In de, this message translates to:
  /// **'Wartungsmodus konnte nicht geändert werden.'**
  String get adminMaintenanceError;

  /// No description provided for @adminFirebaseSmokeTest.
  ///
  /// In de, this message translates to:
  /// **'Firebase Smoke Test'**
  String get adminFirebaseSmokeTest;

  /// No description provided for @declineRequest.
  ///
  /// In de, this message translates to:
  /// **'Anfrage ablehnen'**
  String get declineRequest;

  /// No description provided for @requestDeclined.
  ///
  /// In de, this message translates to:
  /// **'Anfrage wurde abgelehnt'**
  String get requestDeclined;

  /// No description provided for @requestNotFound.
  ///
  /// In de, this message translates to:
  /// **'Antrag nicht gefunden.'**
  String get requestNotFound;

  /// No description provided for @requestReactivate.
  ///
  /// In de, this message translates to:
  /// **'Antrag reaktivieren?'**
  String get requestReactivate;

  /// No description provided for @requestReactivated.
  ///
  /// In de, this message translates to:
  /// **'Antrag von {name} reaktiviert.'**
  String requestReactivated(String name);

  /// No description provided for @reactivate.
  ///
  /// In de, this message translates to:
  /// **'Reaktivieren'**
  String get reactivate;

  /// No description provided for @reactivationFailed.
  ///
  /// In de, this message translates to:
  /// **'Reaktivierung fehlgeschlagen.'**
  String get reactivationFailed;

  /// No description provided for @verificationFailed.
  ///
  /// In de, this message translates to:
  /// **'Verifizierung fehlgeschlagen.'**
  String get verificationFailed;

  /// No description provided for @declineReason.
  ///
  /// In de, this message translates to:
  /// **'Grund der Ablehnung'**
  String get declineReason;

  /// No description provided for @declineReasonAlt.
  ///
  /// In de, this message translates to:
  /// **'Grund für Ablehnung'**
  String get declineReasonAlt;

  /// No description provided for @internalCommentOptional.
  ///
  /// In de, this message translates to:
  /// **'Optionaler interner Kommentar:'**
  String get internalCommentOptional;

  /// No description provided for @decline.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In de, this message translates to:
  /// **'Annehmen'**
  String get accept;

  /// No description provided for @revoke.
  ///
  /// In de, this message translates to:
  /// **'Widerrufen'**
  String get revoke;

  /// No description provided for @pushTo.
  ///
  /// In de, this message translates to:
  /// **'Push an {target}'**
  String pushTo(String target);

  /// No description provided for @pushSent.
  ///
  /// In de, this message translates to:
  /// **'Push an {target} gesendet.'**
  String pushSent(String target);

  /// No description provided for @pushSendError.
  ///
  /// In de, this message translates to:
  /// **'Push konnte nicht gesendet werden.'**
  String get pushSendError;

  /// No description provided for @kneeArthroscopy.
  ///
  /// In de, this message translates to:
  /// **'Knie‑Arthroskopie'**
  String get kneeArthroscopy;

  /// No description provided for @uniClinicMunich.
  ///
  /// In de, this message translates to:
  /// **'Uniklinikum München'**
  String get uniClinicMunich;

  /// No description provided for @wakeTimeMustBeAfterBed.
  ///
  /// In de, this message translates to:
  /// **'Aufwachzeit muss nach der Bettzeit liegen.'**
  String get wakeTimeMustBeAfterBed;

  /// No description provided for @qrCodeScan.
  ///
  /// In de, this message translates to:
  /// **'QR-Code scannen'**
  String get qrCodeScan;

  /// No description provided for @releaseAll.
  ///
  /// In de, this message translates to:
  /// **'Alles freigeben'**
  String get releaseAll;

  /// No description provided for @keyActivate.
  ///
  /// In de, this message translates to:
  /// **'Key aktivieren'**
  String get keyActivate;

  /// No description provided for @keyDeactivate.
  ///
  /// In de, this message translates to:
  /// **'Key deaktivieren?'**
  String get keyDeactivate;

  /// No description provided for @keyDeactivated.
  ///
  /// In de, this message translates to:
  /// **'Key deaktiviert.'**
  String get keyDeactivated;

  /// No description provided for @keyCreated.
  ///
  /// In de, this message translates to:
  /// **'Key erstellt'**
  String get keyCreated;

  /// No description provided for @keyDeactivateError.
  ///
  /// In de, this message translates to:
  /// **'Key konnte nicht deaktiviert werden.'**
  String get keyDeactivateError;

  /// No description provided for @keyCreateError.
  ///
  /// In de, this message translates to:
  /// **'Key konnte nicht erstellt werden.'**
  String get keyCreateError;

  /// No description provided for @keysLoadError.
  ///
  /// In de, this message translates to:
  /// **'Keys konnten nicht geladen werden.'**
  String get keysLoadError;

  /// No description provided for @validForDays.
  ///
  /// In de, this message translates to:
  /// **'Gültig für {days} Tage'**
  String validForDays(int days);

  /// No description provided for @validityDuration.
  ///
  /// In de, this message translates to:
  /// **'Gültigkeitsdauer:'**
  String get validityDuration;

  /// No description provided for @targetGroup.
  ///
  /// In de, this message translates to:
  /// **'Zielgruppe'**
  String get targetGroup;

  /// No description provided for @endTimeSet.
  ///
  /// In de, this message translates to:
  /// **'Endzeit setzen'**
  String get endTimeSet;

  /// No description provided for @keineEintraege.
  ///
  /// In de, this message translates to:
  /// **'  Keine Einträge'**
  String get keineEintraege;

  /// No description provided for @n10Maerz2026.
  ///
  /// In de, this message translates to:
  /// **'10. März 2026'**
  String get n10Maerz2026;

  /// No description provided for @n15Maerz2026.
  ///
  /// In de, this message translates to:
  /// **'15. März 2026'**
  String get n15Maerz2026;

  /// No description provided for @n3NeueAufgabenJedenTagNurFuerPro.
  ///
  /// In de, this message translates to:
  /// **'3 neue Aufgaben jeden Tag – nur für Pro'**
  String get n3NeueAufgabenJedenTagNurFuerPro;

  /// No description provided for @n5Eintraege.
  ///
  /// In de, this message translates to:
  /// **'5 Einträge'**
  String get n5Eintraege;

  /// No description provided for @alleGesundheitsdatenWurdenGeloescht.
  ///
  /// In de, this message translates to:
  /// **'Alle Gesundheitsdaten wurden gelöscht.'**
  String get alleGesundheitsdatenWurdenGeloescht;

  /// No description provided for @alleDeineAktivitaetenAufEinenBlick.
  ///
  /// In de, this message translates to:
  /// **'Alle deine Aktivitäten auf einen Blick'**
  String get alleDeineAktivitaetenAufEinenBlick;

  /// No description provided for @allesImGruenenBereich.
  ///
  /// In de, this message translates to:
  /// **'Alles im grünen Bereich'**
  String get allesImGruenenBereich;

  /// No description provided for @angehoerige.
  ///
  /// In de, this message translates to:
  /// **'Angehörige'**
  String get angehoerige;

  /// No description provided for @angehoeriger.
  ///
  /// In de, this message translates to:
  /// **'Angehöriger'**
  String get angehoeriger;

  /// No description provided for @anweisungenOeffnen.
  ///
  /// In de, this message translates to:
  /// **'Anweisungen öffnen'**
  String get anweisungenOeffnen;

  /// No description provided for @anzeigeGeloescht.
  ///
  /// In de, this message translates to:
  /// **'Anzeige gelöscht.'**
  String get anzeigeGeloescht;

  /// No description provided for @anaesthesiologie.
  ///
  /// In de, this message translates to:
  /// **'Anästhesiologie'**
  String get anaesthesiologie;

  /// No description provided for @arztLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Arzt löschen?'**
  String get arztLoeschen;

  /// No description provided for @arztBriefingIstAufWebNichtVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Briefing ist auf Web nicht verfügbar.'**
  String get arztBriefingIstAufWebNichtVerfuegbar;

  /// No description provided for @atmungMobilitaet.
  ///
  /// In de, this message translates to:
  /// **'Atmung & Mobilität'**
  String get atmungMobilitaet;

  /// No description provided for @auffaelligeAbsonderungAusDerWunde.
  ///
  /// In de, this message translates to:
  /// **'Auffällige Absonderung aus der Wunde'**
  String get auffaelligeAbsonderungAusDerWunde;

  /// No description provided for @aufklaerung.
  ///
  /// In de, this message translates to:
  /// **'Aufklärung'**
  String get aufklaerung;

  /// No description provided for @aufklaerungsgespraech.
  ///
  /// In de, this message translates to:
  /// **'Aufklärungsgespräch'**
  String get aufklaerungsgespraech;

  /// No description provided for @auswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get auswaehlen;

  /// No description provided for @automatischeUeberwachung.
  ///
  /// In de, this message translates to:
  /// **'Automatische Überwachung'**
  String get automatischeUeberwachung;

  /// No description provided for @bedarfsmedikationOderZusaetzlicheEinnahme.
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedikation oder zusätzliche Einnahme'**
  String get bedarfsmedikationOderZusaetzlicheEinnahme;

  /// No description provided for @begruendung.
  ///
  /// In de, this message translates to:
  /// **'Begründung'**
  String get begruendung;

  /// No description provided for @bellaGedaechtnis.
  ///
  /// In de, this message translates to:
  /// **'Bella Gedächtnis'**
  String get bellaGedaechtnis;

  /// No description provided for @berechtigungenAendern.
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen ändern'**
  String get berechtigungenAendern;

  /// No description provided for @berichtFuer714Oder30TageErstellen.
  ///
  /// In de, this message translates to:
  /// **'Bericht für 7, 14 oder 30 Tage erstellen.'**
  String get berichtFuer714Oder30TageErstellen;

  /// No description provided for @bestehtSchuettelfrost.
  ///
  /// In de, this message translates to:
  /// **'Besteht Schüttelfrost?'**
  String get bestehtSchuettelfrost;

  /// No description provided for @bestaetigt.
  ///
  /// In de, this message translates to:
  /// **'Bestätigt'**
  String get bestaetigt;

  /// No description provided for @bitteAuswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Bitte auswählen'**
  String get bitteAuswaehlen;

  /// No description provided for @bitteGebenSieEineGueltigeEMailEin.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie eine gültige E-Mail ein.'**
  String get bitteGebenSieEineGueltigeEMailEin;

  /// No description provided for @breitetSichDieRoetungAus.
  ///
  /// In de, this message translates to:
  /// **'Breitet sich die Rötung aus?'**
  String get breitetSichDieRoetungAus;

  /// No description provided for @datumAuswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Datum auswählen'**
  String get datumAuswaehlen;

  /// No description provided for @deinWochenRueckblick.
  ///
  /// In de, this message translates to:
  /// **'Dein Wochen-Rückblick'**
  String get deinWochenRueckblick;

  /// No description provided for @deinPersoenlicherOpAssistent.
  ///
  /// In de, this message translates to:
  /// **'Dein persönlicher OP-Assistent'**
  String get deinPersoenlicherOpAssistent;

  /// No description provided for @deineAngehoerigenBleibenInformiertUndKoennenDichBesser.
  ///
  /// In de, this message translates to:
  /// **'Deine Angehörigen bleiben informiert und können dich besser unterstützen.'**
  String get deineAngehoerigenBleibenInformiertUndKoennenDichBesser;

  /// No description provided for @deineSprachUndTextnotizenSindDirektMitDeinerOpDoku.
  ///
  /// In de, this message translates to:
  /// **'Deine Sprach- und Textnotizen sind direkt mit deiner OP-Dokumentation verknüpft.'**
  String get deineSprachUndTextnotizenSindDirektMitDeinerOpDoku;

  /// No description provided for @derAppStoreIstNichtVerfuegbarBittePruefeDeineNetzwer.
  ///
  /// In de, this message translates to:
  /// **'Der App Store ist nicht verfügbar. Bitte prüfe deine Netzwerkverbindung.'**
  String get derAppStoreIstNichtVerfuegbarBittePruefeDeineNetzwer;

  /// No description provided for @derStoreIstGeradeNichtVerfuegbarBitteVersucheEsErne.
  ///
  /// In de, this message translates to:
  /// **'Der Store ist gerade nicht verfügbar. Bitte versuche es erneut.'**
  String get derStoreIstGeradeNichtVerfuegbarBitteVersucheEsErne;

  /// No description provided for @dieAppWirdWiederFuerAlleNutzerZugaenglich.
  ///
  /// In de, this message translates to:
  /// **'Die App wird wieder für alle Nutzer zugänglich.'**
  String get dieAppWirdWiederFuerAlleNutzerZugaenglich;

  /// No description provided for @dieseInformationenHelfenUnsDeinenPersoenlichenCarePla.
  ///
  /// In de, this message translates to:
  /// **'Diese Informationen helfen uns, deinen persönlichen Care Plan zu erstellen.'**
  String get dieseInformationenHelfenUnsDeinenPersoenlichenCarePla;

  /// No description provided for @dosisFuerDiesenZeitpunktOptional.
  ///
  /// In de, this message translates to:
  /// **'Dosis für diesen Zeitpunkt (optional)'**
  String get dosisFuerDiesenZeitpunktOptional;

  /// No description provided for @duEntscheidestWelcheDatenDeineAngehoerigenSehenSchme.
  ///
  /// In de, this message translates to:
  /// **'Du entscheidest, welche Daten deine Angehörigen sehen: Schmerz, Vitals, Termine und mehr.'**
  String get duEntscheidestWelcheDatenDeineAngehoerigenSehenSchme;

  /// No description provided for @duGehstMitKlarheitInsKontrollgespraechDasGibtSicherh.
  ///
  /// In de, this message translates to:
  /// **'Du gehst mit Klarheit ins Kontrollgespräch. Das gibt Sicherheit – dir und deinem Arzt.'**
  String get duGehstMitKlarheitInsKontrollgespraechDasGibtSicherh;

  /// No description provided for @einPreisFuerDieGesamteOpUndNachsorgephase.
  ///
  /// In de, this message translates to:
  /// **'Ein Preis für die gesamte OP- und Nachsorgephase.'**
  String get einPreisFuerDieGesamteOpUndNachsorgephase;

  /// No description provided for @eingeloest.
  ///
  /// In de, this message translates to:
  /// **'Eingelöst'**
  String get eingeloest;

  /// No description provided for @eingeloestVon.
  ///
  /// In de, this message translates to:
  /// **'Eingelöst von'**
  String get eingeloestVon;

  /// No description provided for @einigeDatenKonntenNichtGeloeschtWerden.
  ///
  /// In de, this message translates to:
  /// **'Einige Daten konnten nicht gelöscht werden.'**
  String get einigeDatenKonntenNichtGeloeschtWerden;

  /// No description provided for @eintraege.
  ///
  /// In de, this message translates to:
  /// **'Einträge'**
  String get eintraege;

  /// No description provided for @einzelneWerteLeichtAusserhalbDesNormalbereichsBitteBe.
  ///
  /// In de, this message translates to:
  /// **'Einzelne Werte leicht außerhalb des Normalbereichs. Bitte beobachten.'**
  String get einzelneWerteLeichtAusserhalbDesNormalbereichsBitteBe;

  /// No description provided for @entdeckeNeueFunktionenInDeinerAppJetztOeffnen.
  ///
  /// In de, this message translates to:
  /// **'Entdecke neue Funktionen in deiner App. Jetzt öffnen!'**
  String get entdeckeNeueFunktionenInDeinerAppJetztOeffnen;

  /// No description provided for @erhalteAlleInfosSchrittFuerSchritt.
  ///
  /// In de, this message translates to:
  /// **'Erhalte alle Infos Schritt für Schritt.'**
  String get erhalteAlleInfosSchrittFuerSchritt;

  /// No description provided for @erhoehtesRisiko.
  ///
  /// In de, this message translates to:
  /// **'Erhöhtes Risiko'**
  String get erhoehtesRisiko;

  /// No description provided for @erinnerungszeitWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungszeit wählen'**
  String get erinnerungszeitWaehlen;

  /// No description provided for @ernaehrung.
  ///
  /// In de, this message translates to:
  /// **'Ernährung'**
  String get ernaehrung;

  /// No description provided for @ernaehrungHeute.
  ///
  /// In de, this message translates to:
  /// **'Ernährung heute'**
  String get ernaehrungHeute;

  /// No description provided for @ernaehrungstagebuch.
  ///
  /// In de, this message translates to:
  /// **'Ernährungstagebuch'**
  String get ernaehrungstagebuch;

  /// No description provided for @erstelleEinArztBriefingFuerMeinenNaechstenTermin.
  ///
  /// In de, this message translates to:
  /// **'Erstelle ein Arzt-Briefing für meinen nächsten Termin.'**
  String get erstelleEinArztBriefingFuerMeinenNaechstenTermin;

  /// No description provided for @erzaehlUnsVonDeinerOp.
  ///
  /// In de, this message translates to:
  /// **'Erzähl uns von deiner OP'**
  String get erzaehlUnsVonDeinerOp;

  /// No description provided for @fehlerBeimLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen.'**
  String get fehlerBeimLoeschen;

  /// No description provided for @flexibelJederzeitKuendbar.
  ///
  /// In de, this message translates to:
  /// **'Flexibel – jederzeit kündbar'**
  String get flexibelJederzeitKuendbar;

  /// No description provided for @fragenFuerDenArzt.
  ///
  /// In de, this message translates to:
  /// **'Fragen für den Arzt'**
  String get fragenFuerDenArzt;

  /// No description provided for @fragenFuerDenArztNotieren.
  ///
  /// In de, this message translates to:
  /// **'Fragen für den Arzt notieren →'**
  String get fragenFuerDenArztNotieren;

  /// No description provided for @faellig.
  ///
  /// In de, this message translates to:
  /// **'Fällig'**
  String get faellig;

  /// No description provided for @faelligeUndErledigteAufgaben.
  ///
  /// In de, this message translates to:
  /// **'Fällige und erledigte Aufgaben'**
  String get faelligeUndErledigteAufgaben;

  /// No description provided for @fuegeDeineOpInformationenHinzu.
  ///
  /// In de, this message translates to:
  /// **'Füge deine OP‑Informationen hinzu.'**
  String get fuegeDeineOpInformationenHinzu;

  /// No description provided for @fuehlenSieSichBenommenOderSchwindelig.
  ///
  /// In de, this message translates to:
  /// **'Fühlen Sie sich benommen oder schwindelig?'**
  String get fuehlenSieSichBenommenOderSchwindelig;

  /// No description provided for @fuehlenSieSichSchwindeligOderSchwach.
  ///
  /// In de, this message translates to:
  /// **'Fühlen Sie sich schwindelig oder schwach?'**
  String get fuehlenSieSichSchwindeligOderSchwach;

  /// No description provided for @fuerPushBenachrichtigungenBenoetigstDuEinKonto.
  ///
  /// In de, this message translates to:
  /// **'Für Push-Benachrichtigungen benötigst du ein Konto.'**
  String get fuerPushBenachrichtigungenBenoetigstDuEinKonto;

  /// No description provided for @gefaesschirurgie.
  ///
  /// In de, this message translates to:
  /// **'Gefäßchirurgie'**
  String get gefaesschirurgie;

  /// No description provided for @gespraecheFuerArztOderAngehoerigeTeilen.
  ///
  /// In de, this message translates to:
  /// **'Gespräche für Arzt oder Angehörige teilen'**
  String get gespraecheFuerArztOderAngehoerigeTeilen;

  /// No description provided for @gleichtaegigeEntlassung.
  ///
  /// In de, this message translates to:
  /// **'Gleichtägige Entlassung'**
  String get gleichtaegigeEntlassung;

  /// No description provided for @groesse.
  ///
  /// In de, this message translates to:
  /// **'Größe'**
  String get groesse;

  /// No description provided for @gruen.
  ///
  /// In de, this message translates to:
  /// **'Grün'**
  String get gruen;

  /// No description provided for @gynaekologie.
  ///
  /// In de, this message translates to:
  /// **'Gynäkologie'**
  String get gynaekologie;

  /// No description provided for @gueltigkeitInTagen.
  ///
  /// In de, this message translates to:
  /// **'Gültigkeit (in Tagen)'**
  String get gueltigkeitInTagen;

  /// No description provided for @halteGedankenFragenUndNotizenAlsAudioFestJederzei.
  ///
  /// In de, this message translates to:
  /// **'Halte Gedanken, Fragen und Notizen als Audio fest – jederzeit abhörbar.'**
  String get halteGedankenFragenUndNotizenAlsAudioFestJederzei;

  /// No description provided for @haltenSieIhreTaeglicheRoutineBei.
  ///
  /// In de, this message translates to:
  /// **'Halten Sie Ihre tägliche Routine bei'**
  String get haltenSieIhreTaeglicheRoutineBei;

  /// No description provided for @hatDasSekretEineUngewoehnlicheFarbe.
  ///
  /// In de, this message translates to:
  /// **'Hat das Sekret eine ungewöhnliche Farbe?'**
  String get hatDasSekretEineUngewoehnlicheFarbe;

  /// No description provided for @hatSichDieMengeDesSekretsErhoeht.
  ///
  /// In de, this message translates to:
  /// **'Hat sich die Menge des Sekrets erhöht?'**
  String get hatSichDieMengeDesSekretsErhoeht;

  /// No description provided for @helfenIhreUeblichenSchmerzmittelNichtMehr.
  ///
  /// In de, this message translates to:
  /// **'Helfen Ihre üblichen Schmerzmittel nicht mehr?'**
  String get helfenIhreUeblichenSchmerzmittelNichtMehr;

  /// No description provided for @heuteFaellig.
  ///
  /// In de, this message translates to:
  /// **'Heute fällig'**
  String get heuteFaellig;

  /// No description provided for @hinterlegeOptionalEinenNotfallkontaktUndUeberpruefeDeine.
  ///
  /// In de, this message translates to:
  /// **'Hinterlege optional einen Notfallkontakt und überprüfe deine Angaben.'**
  String get hinterlegeOptionalEinenNotfallkontaktUndUeberpruefeDeine;

  /// No description provided for @hoereZu.
  ///
  /// In de, this message translates to:
  /// **'Höre zu …'**
  String get hoereZu;

  /// No description provided for @huefte.
  ///
  /// In de, this message translates to:
  /// **'Hüfte'**
  String get huefte;

  /// No description provided for @in24HErneutPruefen.
  ///
  /// In de, this message translates to:
  /// **'In 24 h erneut prüfen'**
  String get in24HErneutPruefen;

  /// No description provided for @istDerSchmerzbereichGeschwollenOderHeiss.
  ///
  /// In de, this message translates to:
  /// **'Ist der Schmerzbereich geschwollen oder heiß?'**
  String get istDerSchmerzbereichGeschwollenOderHeiss;

  /// No description provided for @istDerVerbandBereitsKomplettDurchnaesst.
  ///
  /// In de, this message translates to:
  /// **'Ist der Verband bereits komplett durchnässt?'**
  String get istDerVerbandBereitsKomplettDurchnaesst;

  /// No description provided for @istDieStelleWarmOderHeiss.
  ///
  /// In de, this message translates to:
  /// **'Ist die Stelle warm oder heiß?'**
  String get istDieStelleWarmOderHeiss;

  /// No description provided for @jedeDokumentierteEinheitIstEinBeweisDuTustEtwasFuer.
  ///
  /// In de, this message translates to:
  /// **'Jede dokumentierte Einheit ist ein Beweis: Du tust etwas für deine Genesung.'**
  String get jedeDokumentierteEinheitIstEinBeweisDuTustEtwasFuer;

  /// No description provided for @jedenMorgenDeinPersoenlicherUeberblick.
  ///
  /// In de, this message translates to:
  /// **'Jeden Morgen dein persönlicher Überblick'**
  String get jedenMorgenDeinPersoenlicherUeberblick;

  /// No description provided for @kannIchMeinenAccountLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Kann ich meinen Account löschen?'**
  String get kannIchMeinenAccountLoeschen;

  /// No description provided for @keineBeruehrungDerWundeKeineManipulationKeineCremes.
  ///
  /// In de, this message translates to:
  /// **'Keine Berührung der Wunde, keine Manipulation, keine Cremes/Salben'**
  String get keineBeruehrungDerWundeKeineManipulationKeineCremes;

  /// No description provided for @keineEintraege2.
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge.'**
  String get keineEintraege2;

  /// No description provided for @keineLueckenMehrImGespraech.
  ///
  /// In de, this message translates to:
  /// **'Keine Lücken mehr im Gespräch'**
  String get keineLueckenMehrImGespraech;

  /// No description provided for @keineSchmerzeintraegeVorhanden.
  ///
  /// In de, this message translates to:
  /// **'Keine Schmerzeinträge vorhanden.'**
  String get keineSchmerzeintraegeVorhanden;

  /// No description provided for @keineUnsicherheitBeiDauerUndWiederholungenDerTimerF.
  ///
  /// In de, this message translates to:
  /// **'Keine Unsicherheit bei Dauer und Wiederholungen. Der Timer führt dich durch jede Einheit.'**
  String get keineUnsicherheitBeiDauerUndWiederholungenDerTimerF;

  /// No description provided for @keineWundeintraegeVorhanden.
  ///
  /// In de, this message translates to:
  /// **'Keine Wundeinträge vorhanden.'**
  String get keineWundeintraegeVorhanden;

  /// No description provided for @keineFrueherenKaeufeGefunden.
  ///
  /// In de, this message translates to:
  /// **'Keine früheren Käufe gefunden.'**
  String get keineFrueherenKaeufeGefunden;

  /// No description provided for @kritischeWerteErkanntSofortigeAerztlicheHilfeEmpfohlen.
  ///
  /// In de, this message translates to:
  /// **'Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.'**
  String get kritischeWerteErkanntSofortigeAerztlicheHilfeEmpfohlen;

  /// No description provided for @kraeftigung.
  ///
  /// In de, this message translates to:
  /// **'Kräftigung'**
  String get kraeftigung;

  /// No description provided for @koerperregionHaeufigkeit.
  ///
  /// In de, this message translates to:
  /// **'Körperregion-Häufigkeit'**
  String get koerperregionHaeufigkeit;

  /// No description provided for @leichteAuffaelligkeit.
  ///
  /// In de, this message translates to:
  /// **'Leichte Auffälligkeit'**
  String get leichteAuffaelligkeit;

  /// No description provided for @letzteAktivitaeten.
  ///
  /// In de, this message translates to:
  /// **'Letzte Aktivitäten'**
  String get letzteAktivitaeten;

  /// No description provided for @liegtDieTemperaturUeber385C.
  ///
  /// In de, this message translates to:
  /// **'Liegt die Temperatur über 38,5 °C?'**
  String get liegtDieTemperaturUeber385C;

  /// No description provided for @linkZumDirektenOeffnenDerApp.
  ///
  /// In de, this message translates to:
  /// **'Link zum direkten Öffnen der App'**
  String get linkZumDirektenOeffnenDerApp;

  /// No description provided for @lizenzschluesselErstellenVerwalten.
  ///
  /// In de, this message translates to:
  /// **'Lizenzschlüssel erstellen & verwalten'**
  String get lizenzschluesselErstellenVerwalten;

  /// No description provided for @loeschen.
  ///
  /// In de, this message translates to:
  /// **'LÖSCHEN'**
  String get loeschen;

  /// No description provided for @loeschung.
  ///
  /// In de, this message translates to:
  /// **'Löschung'**
  String get loeschung;

  /// No description provided for @mehrereWerteAuffaelligKontaktierenSieIhrenArztZeitnah.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Werte auffällig. Kontaktieren Sie Ihren Arzt zeitnah.'**
  String get mehrereWerteAuffaelligKontaktierenSieIhrenArztZeitnah;

  /// No description provided for @meineAerzte.
  ///
  /// In de, this message translates to:
  /// **'Meine Ärzte'**
  String get meineAerzte;

  /// No description provided for @mind2EintraegeFuerChart.
  ///
  /// In de, this message translates to:
  /// **'Mind. 2 Einträge für Chart'**
  String get mind2EintraegeFuerChart;

  /// No description provided for @mindestens2EintraegeFuerTrendanalyseBenoetigt.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 2 Einträge für Trendanalyse benötigt.'**
  String get mindestens2EintraegeFuerTrendanalyseBenoetigt;

  /// No description provided for @maessig.
  ///
  /// In de, this message translates to:
  /// **'Mäßig'**
  String get maessig;

  /// No description provided for @neueBeobachtungenVonAerztenBegleitern.
  ///
  /// In de, this message translates to:
  /// **'Neue Beobachtungen von Ärzten & Begleitern'**
  String get neueBeobachtungenVonAerztenBegleitern;

  /// No description provided for @nichtVerfuegbareBereiche.
  ///
  /// In de, this message translates to:
  /// **'Nicht verfügbare Bereiche'**
  String get nichtVerfuegbareBereiche;

  /// No description provided for @nochKeineErnaehrungseintraege.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Ernährungseinträge'**
  String get nochKeineErnaehrungseintraege;

  /// No description provided for @nochKeineSchlafeintraege.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Schlafeinträge'**
  String get nochKeineSchlafeintraege;

  /// No description provided for @nochKeineSchmerzeintraege.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Schmerzeinträge'**
  String get nochKeineSchmerzeintraege;

  /// No description provided for @nochKeineStimmungseintraege.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Stimmungseinträge'**
  String get nochKeineStimmungseintraege;

  /// No description provided for @nochKeineWundeintraege.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Wundeinträge'**
  String get nochKeineWundeintraege;

  /// No description provided for @nochKeineAerzteInDerOrganisation.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Ärzte in der Organisation.'**
  String get nochKeineAerzteInDerOrganisation;

  /// No description provided for @nochNichtGenugGemeinsameTageFuerEineKorrelation.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht genug gemeinsame Tage für eine Korrelation.'**
  String get nochNichtGenugGemeinsameTageFuerEineKorrelation;

  /// No description provided for @notierenSieIhreAktuellenBeschwerdenUndDerenStaerke.
  ///
  /// In de, this message translates to:
  /// **'Notieren Sie Ihre aktuellen Beschwerden und deren Stärke.'**
  String get notierenSieIhreAktuellenBeschwerdenUndDerenStaerke;

  /// No description provided for @nurDieRelevantenDatenEinschliessen.
  ///
  /// In de, this message translates to:
  /// **'Nur die relevanten Daten einschließen.'**
  String get nurDieRelevantenDatenEinschliessen;

  /// No description provided for @naechsteGeplanteEinnahme.
  ///
  /// In de, this message translates to:
  /// **'Nächste geplante Einnahme.'**
  String get naechsteGeplanteEinnahme;

  /// No description provided for @naechsterSchritt.
  ///
  /// In de, this message translates to:
  /// **'Nächster Schritt'**
  String get naechsterSchritt;

  /// No description provided for @naechte.
  ///
  /// In de, this message translates to:
  /// **'Nächte'**
  String get naechte;

  /// No description provided for @opAufklaerungen.
  ///
  /// In de, this message translates to:
  /// **'OP-Aufklärungen'**
  String get opAufklaerungen;

  /// No description provided for @offlineEingeschraenkterModus.
  ///
  /// In de, this message translates to:
  /// **'Offline • Eingeschränkter Modus'**
  String get offlineEingeschraenkterModus;

  /// No description provided for @orgaRegistrierungenPruefen.
  ///
  /// In de, this message translates to:
  /// **'Orga-Registrierungen prüfen'**
  String get orgaRegistrierungenPruefen;

  /// No description provided for @oSaettigung.
  ///
  /// In de, this message translates to:
  /// **'O₂-Sättigung'**
  String get oSaettigung;

  /// No description provided for @pinBestaetigen.
  ///
  /// In de, this message translates to:
  /// **'PIN bestätigen'**
  String get pinBestaetigen;

  /// No description provided for @pinsStimmenNichtUeberein.
  ///
  /// In de, this message translates to:
  /// **'PINs stimmen nicht überein'**
  String get pinsStimmenNichtUeberein;

  /// No description provided for @passwortAendern.
  ///
  /// In de, this message translates to:
  /// **'Passwort ändern'**
  String get passwortAendern;

  /// No description provided for @passwoerterStimmenNichtUeberein.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein.'**
  String get passwoerterStimmenNichtUeberein;

  /// No description provided for @patientenverknuepfung.
  ///
  /// In de, this message translates to:
  /// **'Patientenverknüpfung'**
  String get patientenverknuepfung;

  /// No description provided for @plaeneAnsehen.
  ///
  /// In de, this message translates to:
  /// **'Pläne ansehen'**
  String get plaeneAnsehen;

  /// No description provided for @ploetzlichZunehmendNichtKontrollierbar.
  ///
  /// In de, this message translates to:
  /// **'Plötzlich zunehmend, nicht kontrollierbar'**
  String get ploetzlichZunehmendNichtKontrollierbar;

  /// No description provided for @prioritaetAendern.
  ///
  /// In de, this message translates to:
  /// **'Priorität ändern'**
  String get prioritaetAendern;

  /// No description provided for @praeOp.
  ///
  /// In de, this message translates to:
  /// **'Prä-OP'**
  String get praeOp;

  /// No description provided for @qualitaet.
  ///
  /// In de, this message translates to:
  /// **'Qualität'**
  String get qualitaet;

  /// No description provided for @roetung.
  ///
  /// In de, this message translates to:
  /// **'Rötung'**
  String get roetung;

  /// No description provided for @ruecken.
  ///
  /// In de, this message translates to:
  /// **'Rücken'**
  String get ruecken;

  /// No description provided for @rueckgaengig.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get rueckgaengig;

  /// No description provided for @sammleErfahrungspunkteFuerJedeAktionUndSteigeImLevel.
  ///
  /// In de, this message translates to:
  /// **'Sammle Erfahrungspunkte für jede Aktion und steige im Level auf.'**
  String get sammleErfahrungspunkteFuerJedeAktionUndSteigeImLevel;

  /// No description provided for @schilddruesenOp36Jahre.
  ///
  /// In de, this message translates to:
  /// **'Schilddrüsen-OP, 36 Jahre'**
  String get schilddruesenOp36Jahre;

  /// No description provided for @schlafqualitaet.
  ///
  /// In de, this message translates to:
  /// **'Schlafqualität'**
  String get schlafqualitaet;

  /// No description provided for @schmerzMedikamenteWundeUndVitalsGebuendeltDeinArzt.
  ///
  /// In de, this message translates to:
  /// **'Schmerz, Medikamente, Wunde und Vitals gebündelt. Dein Arzt sieht sofort, was wichtig ist.'**
  String get schmerzMedikamenteWundeUndVitalsGebuendeltDeinArzt;

  /// No description provided for @sektionenWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Sektionen wählen'**
  String get sektionenWaehlen;

  /// No description provided for @sindDieSchmerzenDeutlichStaerkerAlsGewohnt.
  ///
  /// In de, this message translates to:
  /// **'Sind die Schmerzen deutlich stärker als gewohnt?'**
  String get sindDieSchmerzenDeutlichStaerkerAlsGewohnt;

  /// No description provided for @stationaer.
  ///
  /// In de, this message translates to:
  /// **'Stationär'**
  String get stationaer;

  /// No description provided for @statusAendern.
  ///
  /// In de, this message translates to:
  /// **'Status ändern'**
  String get statusAendern;

  /// No description provided for @strukturierteEinschaetzungDeinerWundheilung.
  ///
  /// In de, this message translates to:
  /// **'Strukturierte Einschätzung deiner Wundheilung'**
  String get strukturierteEinschaetzungDeinerWundheilung;

  /// No description provided for @stoerungen.
  ///
  /// In de, this message translates to:
  /// **'Störungen'**
  String get stoerungen;

  /// No description provided for @symptomePruefen.
  ///
  /// In de, this message translates to:
  /// **'Symptome prüfen'**
  String get symptomePruefen;

  /// No description provided for @saetze.
  ///
  /// In de, this message translates to:
  /// **'Sätze'**
  String get saetze;

  /// No description provided for @temperaturUeber385C.
  ///
  /// In de, this message translates to:
  /// **'Temperatur über 38,5 °C'**
  String get temperaturUeber385C;

  /// No description provided for @triggerHaeufigkeit.
  ///
  /// In de, this message translates to:
  /// **'Trigger-Häufigkeit'**
  String get triggerHaeufigkeit;

  /// No description provided for @tutorialWirdBeimNaechstenStartAngezeigt.
  ///
  /// In de, this message translates to:
  /// **'Tutorial wird beim nächsten Start angezeigt.'**
  String get tutorialWirdBeimNaechstenStartAngezeigt;

  /// No description provided for @umAngehoerigeEinzuladenBenoetigstDuEinKonto.
  ///
  /// In de, this message translates to:
  /// **'Um Angehörige einzuladen, benötigst du ein Konto.'**
  String get umAngehoerigeEinzuladenBenoetigstDuEinKonto;

  /// No description provided for @umPatientenZuBegleitenBenoetigstDuEinKonto.
  ///
  /// In de, this message translates to:
  /// **'Um Patienten zu begleiten, benötigst du ein Konto.'**
  String get umPatientenZuBegleitenBenoetigstDuEinKonto;

  /// No description provided for @umProFreizuschaltenBenoetigstDuEinKonto.
  ///
  /// In de, this message translates to:
  /// **'Um Pro freizuschalten, benötigst du ein Konto.'**
  String get umProFreizuschaltenBenoetigstDuEinKonto;

  /// No description provided for @umDeinProfilZuVerwaltenBenoetigstDuEinKonto.
  ///
  /// In de, this message translates to:
  /// **'Um dein Profil zu verwalten, benötigst du ein Konto.'**
  String get umDeinProfilZuVerwaltenBenoetigstDuEinKonto;

  /// No description provided for @umEinenArztZuVerbindenBenoetigstDuEinKonto.
  ///
  /// In de, this message translates to:
  /// **'Um einen Arzt zu verbinden, benötigst du ein Konto.'**
  String get umEinenArztZuVerbindenBenoetigstDuEinKonto;

  /// No description provided for @umAerzteZuVerwaltenBenoetigstDuEinKonto.
  ///
  /// In de, this message translates to:
  /// **'Um Ärzte zu verwalten, benötigst du ein Konto.'**
  String get umAerzteZuVerwaltenBenoetigstDuEinKonto;

  /// No description provided for @ungueltigeServerAntwort.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Server-Antwort'**
  String get ungueltigeServerAntwort;

  /// No description provided for @universitaetsklinikumMuenchen.
  ///
  /// In de, this message translates to:
  /// **'Universitätsklinikum München'**
  String get universitaetsklinikumMuenchen;

  /// No description provided for @unveraendert.
  ///
  /// In de, this message translates to:
  /// **'Unverändert'**
  String get unveraendert;

  /// No description provided for @userLoeschenDsgvo.
  ///
  /// In de, this message translates to:
  /// **'User löschen (DSGVO)?'**
  String get userLoeschenDsgvo;

  /// No description provided for @verbindungsfehlerBittePruefeDeineInternetverbindung.
  ///
  /// In de, this message translates to:
  /// **'Verbindungsfehler. Bitte prüfe deine Internetverbindung.'**
  String get verbindungsfehlerBittePruefeDeineInternetverbindung;

  /// No description provided for @verfolgeDeineWundheilungMitFotosUndEintraegenImZeitli.
  ///
  /// In de, this message translates to:
  /// **'Verfolge deine Wundheilung mit Fotos und Einträgen im zeitlichen Verlauf.'**
  String get verfolgeDeineWundheilungMitFotosUndEintraegenImZeitli;

  /// No description provided for @verspuerenSieUebelkeitOderBrechreiz.
  ///
  /// In de, this message translates to:
  /// **'Verspüren Sie Übelkeit oder Brechreiz?'**
  String get verspuerenSieUebelkeitOderBrechreiz;

  /// No description provided for @visualisiereDeineTaeglicheAktivitaet.
  ///
  /// In de, this message translates to:
  /// **'Visualisiere deine tägliche Aktivität'**
  String get visualisiereDeineTaeglicheAktivitaet;

  /// No description provided for @vollstaendigerExport.
  ///
  /// In de, this message translates to:
  /// **'Vollständiger Export'**
  String get vollstaendigerExport;

  /// No description provided for @vorbereitetStattUeberfordert.
  ///
  /// In de, this message translates to:
  /// **'Vorbereitet statt überfordert'**
  String get vorbereitetStattUeberfordert;

  /// No description provided for @wieFuehlenSieSich.
  ///
  /// In de, this message translates to:
  /// **'Wie fühlen Sie sich?'**
  String get wieFuehlenSieSich;

  /// No description provided for @wieKannIchMeinProAboKuendigen.
  ///
  /// In de, this message translates to:
  /// **'Wie kann ich mein Pro-Abo kündigen?'**
  String get wieKannIchMeinProAboKuendigen;

  /// No description provided for @wiederOeffnen.
  ///
  /// In de, this message translates to:
  /// **'Wieder öffnen'**
  String get wiederOeffnen;

  /// No description provided for @willkommenZurueck.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück!'**
  String get willkommenZurueck;

  /// No description provided for @wundbereichWirktEntzuendet.
  ///
  /// In de, this message translates to:
  /// **'Wundbereich wirkt entzündet'**
  String get wundbereichWirktEntzuendet;

  /// No description provided for @waehleDeinenPlan.
  ///
  /// In de, this message translates to:
  /// **'Wähle deinen Plan'**
  String get waehleDeinenPlan;

  /// No description provided for @waehleEinenModusZumVergleichen.
  ///
  /// In de, this message translates to:
  /// **'Wähle einen Modus zum Vergleichen'**
  String get waehleEinenModusZumVergleichen;

  /// No description provided for @zeigtDieWundeAuffaelligkeitenRoetungSekret.
  ///
  /// In de, this message translates to:
  /// **'Zeigt die Wunde Auffälligkeiten (Rötung, Sekret)?'**
  String get zeigtDieWundeAuffaelligkeitenRoetungSekret;

  /// No description provided for @zeitraumWaehlbar.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum wählbar'**
  String get zeitraumWaehlbar;

  /// No description provided for @zuletztGeaendertVor30Tagen.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt geändert vor 30 Tagen'**
  String get zuletztGeaendertVor30Tagen;

  /// No description provided for @zunehmendeRoetungSchwellung.
  ///
  /// In de, this message translates to:
  /// **'Zunehmende Rötung / Schwellung'**
  String get zunehmendeRoetungSchwellung;

  /// No description provided for @zusaetzlicheDetails.
  ///
  /// In de, this message translates to:
  /// **'Zusätzliche Details…'**
  String get zusaetzlicheDetails;

  /// No description provided for @stationaer2.
  ///
  /// In de, this message translates to:
  /// **'stationär'**
  String get stationaer2;

  /// No description provided for @zBZahnbuerste.
  ///
  /// In de, this message translates to:
  /// **'z.B. Zahnbürste'**
  String get zBZahnbuerste;

  /// No description provided for @aeltesteZuerst.
  ///
  /// In de, this message translates to:
  /// **'Älteste zuerst'**
  String get aeltesteZuerst;

  /// No description provided for @aendern.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get aendern;

  /// No description provided for @aenderungenSpeichern.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get aenderungenSpeichern;

  /// No description provided for @aerzte.
  ///
  /// In de, this message translates to:
  /// **'Ärzte'**
  String get aerzte;

  /// No description provided for @aerztlichenRatEinholen.
  ///
  /// In de, this message translates to:
  /// **'Ärztlichen Rat einholen'**
  String get aerztlichenRatEinholen;

  /// No description provided for @oeffnen.
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get oeffnen;

  /// No description provided for @qualitaet2.
  ///
  /// In de, this message translates to:
  /// **'Ø Qualität'**
  String get qualitaet2;

  /// No description provided for @uebelRiechendesSekret.
  ///
  /// In de, this message translates to:
  /// **'Übel riechendes Sekret'**
  String get uebelRiechendesSekret;

  /// No description provided for @uebelkeit.
  ///
  /// In de, this message translates to:
  /// **'Übelkeit'**
  String get uebelkeit;

  /// No description provided for @ueberfaellig.
  ///
  /// In de, this message translates to:
  /// **'Überfällig'**
  String get ueberfaellig;

  /// No description provided for @uebersicht.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get uebersicht;

  /// No description provided for @uebersichtlichesLayoutZumAusdrucken.
  ///
  /// In de, this message translates to:
  /// **'Übersichtliches Layout zum Ausdrucken.'**
  String get uebersichtlichesLayoutZumAusdrucken;

  /// No description provided for @uebersprungen.
  ///
  /// In de, this message translates to:
  /// **'Übersprungen'**
  String get uebersprungen;

  /// No description provided for @symptomHaeufigkeit.
  ///
  /// In de, this message translates to:
  /// **'⚠️ Symptom-Häufigkeit'**
  String get symptomHaeufigkeit;
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
