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
  /// **'Willkommen'**
  String get tutorialStep1Title;

  /// No description provided for @tutorialStep1Desc.
  ///
  /// In de, this message translates to:
  /// **'Hier findest du alles Wichtige zu deiner OP auf einen Blick.'**
  String get tutorialStep1Desc;

  /// No description provided for @tutorialStep2Title.
  ///
  /// In de, this message translates to:
  /// **'Termine'**
  String get tutorialStep2Title;

  /// No description provided for @tutorialStep2Desc.
  ///
  /// In de, this message translates to:
  /// **'Verwalte deine Arzttermine und OP-Vorbereitungen.'**
  String get tutorialStep2Desc;

  /// No description provided for @tutorialStep3Title.
  ///
  /// In de, this message translates to:
  /// **'Checklisten'**
  String get tutorialStep3Title;

  /// No description provided for @tutorialStep3Desc.
  ///
  /// In de, this message translates to:
  /// **'Arbeite Schritt für Schritt deine persönlichen Aufgaben ab.'**
  String get tutorialStep3Desc;

  /// No description provided for @tutorialStep4Title.
  ///
  /// In de, this message translates to:
  /// **'Mehr entdecken'**
  String get tutorialStep4Title;

  /// No description provided for @tutorialStep4Desc.
  ///
  /// In de, this message translates to:
  /// **'Unter \'Mehr\' findest du Einstellungen, Hilfe und weitere Funktionen.'**
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
