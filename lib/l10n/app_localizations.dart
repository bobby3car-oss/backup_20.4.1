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

  /// No description provided for @authSlideTrustSignals.
  ///
  /// In de, this message translates to:
  /// **'Kostenlos · Keine Kreditkarte · In 30 Sek. startklar'**
  String get authSlideTrustSignals;

  /// No description provided for @authSlideSocialProof.
  ///
  /// In de, this message translates to:
  /// **'4,9 ★ · 2.500+ Patienten vertrauen der App'**
  String get authSlideSocialProof;

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
  String appointmentForPatient(String name);

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
  /// **'Patientenverknüpfung'**
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

  /// No description provided for @scSeverityNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get scSeverityNone;

  /// No description provided for @scSeverityMild.
  ///
  /// In de, this message translates to:
  /// **'Leicht'**
  String get scSeverityMild;

  /// No description provided for @scSeverityModerate.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get scSeverityModerate;

  /// No description provided for @scSeveritySevere.
  ///
  /// In de, this message translates to:
  /// **'Stark'**
  String get scSeveritySevere;

  /// No description provided for @scLevelGreen.
  ///
  /// In de, this message translates to:
  /// **'Grün'**
  String get scLevelGreen;

  /// No description provided for @scLevelYellow.
  ///
  /// In de, this message translates to:
  /// **'Gelb'**
  String get scLevelYellow;

  /// No description provided for @scLevelRed.
  ///
  /// In de, this message translates to:
  /// **'Rot'**
  String get scLevelRed;

  /// No description provided for @scLevelTitleYellow.
  ///
  /// In de, this message translates to:
  /// **'Bitte beobachten'**
  String get scLevelTitleYellow;

  /// No description provided for @scRecommendGreen.
  ///
  /// In de, this message translates to:
  /// **'Ihre Symptome sind unauffällig. Dokumentieren Sie weiterhin regelmäßig und halten Sie sich an Ihren Genesungsplan.'**
  String get scRecommendGreen;

  /// No description provided for @scRecommendYellow.
  ///
  /// In de, this message translates to:
  /// **'Einzelne Symptome sind leicht auffällig. Beobachten Sie die Entwicklung in den nächsten 24 Stunden. Bei Verschlechterung kontaktieren Sie Ihren Arzt.'**
  String get scRecommendYellow;

  /// No description provided for @scRecommendRed.
  ///
  /// In de, this message translates to:
  /// **'Ihre Symptome deuten auf eine Komplikation hin. Kontaktieren Sie umgehend Ihren Arzt oder suchen Sie die nächste Notaufnahme auf.'**
  String get scRecommendRed;

  /// No description provided for @scSymPain.
  ///
  /// In de, this message translates to:
  /// **'Schmerzen'**
  String get scSymPain;

  /// No description provided for @scSymNausea.
  ///
  /// In de, this message translates to:
  /// **'Übelkeit'**
  String get scSymNausea;

  /// No description provided for @scSymBreathing.
  ///
  /// In de, this message translates to:
  /// **'Atmung'**
  String get scSymBreathing;

  /// No description provided for @scSymDizziness.
  ///
  /// In de, this message translates to:
  /// **'Schwindel'**
  String get scSymDizziness;

  /// No description provided for @scSymWound.
  ///
  /// In de, this message translates to:
  /// **'Wundstatus'**
  String get scSymWound;

  /// No description provided for @scSymPainSub.
  ///
  /// In de, this message translates to:
  /// **'Wie stark sind Ihre Schmerzen im OP-Bereich?'**
  String get scSymPainSub;

  /// No description provided for @scSymNauseaSub.
  ///
  /// In de, this message translates to:
  /// **'Verspüren Sie Übelkeit oder Brechreiz?'**
  String get scSymNauseaSub;

  /// No description provided for @scSymBreathingSub.
  ///
  /// In de, this message translates to:
  /// **'Haben Sie Atembeschwerden oder Kurzatmigkeit?'**
  String get scSymBreathingSub;

  /// No description provided for @scSymDizzinessSub.
  ///
  /// In de, this message translates to:
  /// **'Fühlen Sie sich benommen oder schwindelig?'**
  String get scSymDizzinessSub;

  /// No description provided for @scSymWoundSub.
  ///
  /// In de, this message translates to:
  /// **'Zeigt die Wunde Auffälligkeiten (Rötung, Sekret)?'**
  String get scSymWoundSub;

  /// No description provided for @scTitle.
  ///
  /// In de, this message translates to:
  /// **'Symptom‑Check'**
  String get scTitle;

  /// No description provided for @scSymptomsSection.
  ///
  /// In de, this message translates to:
  /// **'Symptome bewerten'**
  String get scSymptomsSection;

  /// No description provided for @scYourInputs.
  ///
  /// In de, this message translates to:
  /// **'Ihre Angaben'**
  String get scYourInputs;

  /// No description provided for @scIntroBody.
  ///
  /// In de, this message translates to:
  /// **'Bewerten Sie jedes Symptom. Am Ende erhalten Sie eine Einschätzung mit Empfehlung.'**
  String get scIntroBody;

  /// No description provided for @scSetDailyReminder.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Erinnerung einrichten'**
  String get scSetDailyReminder;

  /// No description provided for @scActionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Empfohlene Aktionen'**
  String get scActionsTitle;

  /// No description provided for @scSaveResult.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis speichern'**
  String get scSaveResult;

  /// No description provided for @scSaving.
  ///
  /// In de, this message translates to:
  /// **'Speichert…'**
  String get scSaving;

  /// No description provided for @scSaved.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert ✓'**
  String get scSaved;

  /// No description provided for @scResultBadge.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis: {label}'**
  String scResultBadge(String label);

  /// No description provided for @scReminderActive.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung: {time}'**
  String scReminderActive(String time);

  /// No description provided for @scReminderSet.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung gesetzt für {time}'**
  String scReminderSet(String time);

  /// No description provided for @nichtHinterlegt.
  ///
  /// In de, this message translates to:
  /// **'Nicht hinterlegt'**
  String get nichtHinterlegt;

  /// No description provided for @fieldName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefonnummer'**
  String get fieldPhone;

  /// No description provided for @fieldWeight.
  ///
  /// In de, this message translates to:
  /// **'Gewicht'**
  String get fieldWeight;

  /// No description provided for @fieldSmoker.
  ///
  /// In de, this message translates to:
  /// **'Raucher'**
  String get fieldSmoker;

  /// No description provided for @fieldOpType.
  ///
  /// In de, this message translates to:
  /// **'OP-Art'**
  String get fieldOpType;

  /// No description provided for @fieldOpDate.
  ///
  /// In de, this message translates to:
  /// **'OP-Datum'**
  String get fieldOpDate;

  /// No description provided for @fieldOpModus.
  ///
  /// In de, this message translates to:
  /// **'OP-Modus'**
  String get fieldOpModus;

  /// No description provided for @fieldHospitalPhone.
  ///
  /// In de, this message translates to:
  /// **'KH-Telefon'**
  String get fieldHospitalPhone;

  /// No description provided for @fieldDoctorPhone.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Telefon'**
  String get fieldDoctorPhone;

  /// No description provided for @eiBloodType.
  ///
  /// In de, this message translates to:
  /// **'Blutgruppe'**
  String get eiBloodType;

  /// No description provided for @eiAllergies.
  ///
  /// In de, this message translates to:
  /// **'Allergien'**
  String get eiAllergies;

  /// No description provided for @eiInsurance.
  ///
  /// In de, this message translates to:
  /// **'Versicherung'**
  String get eiInsurance;

  /// No description provided for @eiHospital.
  ///
  /// In de, this message translates to:
  /// **'Krankenhaus'**
  String get eiHospital;

  /// No description provided for @eiConditions.
  ///
  /// In de, this message translates to:
  /// **'Vorerkrankungen'**
  String get eiConditions;

  /// No description provided for @eiMedications.
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get eiMedications;

  /// No description provided for @eiOfflineBanner.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung – bitte stelle sicher, dass du die Notfallinfos bei einer Gelegenheit mit Internet lädst.'**
  String get eiOfflineBanner;

  /// No description provided for @eiNoDataHint.
  ///
  /// In de, this message translates to:
  /// **'Keine Notfalldaten hinterlegt.\nTrage deine Daten im Profil ein.'**
  String get eiNoDataHint;

  /// No description provided for @eiOpenProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil öffnen'**
  String get eiOpenProfile;

  /// No description provided for @eiShareHeader.
  ///
  /// In de, this message translates to:
  /// **'🆘 NOTFALL-INFORMATIONEN'**
  String get eiShareHeader;

  /// No description provided for @eiShareEmergency.
  ///
  /// In de, this message translates to:
  /// **'Notruf: 112'**
  String get eiShareEmergency;

  /// No description provided for @eiSummaryNameHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Max Mustermann'**
  String get eiSummaryNameHint;

  /// No description provided for @eiSummaryPhoneHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. +49 170 1234567'**
  String get eiSummaryPhoneHint;

  /// No description provided for @eiSummaryOpType.
  ///
  /// In de, this message translates to:
  /// **'OP-Typ'**
  String get eiSummaryOpType;

  /// No description provided for @eiSummaryOpDateUnknown.
  ///
  /// In de, this message translates to:
  /// **'Noch unbekannt'**
  String get eiSummaryOpDateUnknown;

  /// No description provided for @eiSummaryTreatment.
  ///
  /// In de, this message translates to:
  /// **'Behandlung'**
  String get eiSummaryTreatment;

  /// No description provided for @eiSummaryAmbulant.
  ///
  /// In de, this message translates to:
  /// **'Ambulant'**
  String get eiSummaryAmbulant;

  /// No description provided for @eiShareBloodType.
  ///
  /// In de, this message translates to:
  /// **'Blutgruppe: {value}'**
  String eiShareBloodType(String value);

  /// No description provided for @eiShareAllergies.
  ///
  /// In de, this message translates to:
  /// **'Allergien: {value}'**
  String eiShareAllergies(String value);

  /// No description provided for @eiShareContact.
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakt: {name}'**
  String eiShareContact(String name);

  /// No description provided for @eiSharePhone.
  ///
  /// In de, this message translates to:
  /// **'Tel: {value}'**
  String eiSharePhone(String value);

  /// No description provided for @eiShareHospital.
  ///
  /// In de, this message translates to:
  /// **'Krankenhaus: {name}'**
  String eiShareHospital(String name);

  /// No description provided for @eiShareHospitalPhone.
  ///
  /// In de, this message translates to:
  /// **'KH-Tel: {value}'**
  String eiShareHospitalPhone(String value);

  /// No description provided for @eiShareDoctor.
  ///
  /// In de, this message translates to:
  /// **'Arzt: {name}'**
  String eiShareDoctor(String name);

  /// No description provided for @eiShareDoctorPhone.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Tel: {value}'**
  String eiShareDoctorPhone(String value);

  /// No description provided for @eiShareInsurance.
  ///
  /// In de, this message translates to:
  /// **'Versicherung: {value}'**
  String eiShareInsurance(String value);

  /// No description provided for @notfallInfoTeilen.
  ///
  /// In de, this message translates to:
  /// **'Notfall-Info teilen'**
  String get notfallInfoTeilen;

  /// No description provided for @notruf112.
  ///
  /// In de, this message translates to:
  /// **'Notruf 112'**
  String get notruf112;

  /// No description provided for @fehlerSpeichernErneut.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern. Erneut versuchen.'**
  String get fehlerSpeichernErneut;

  /// No description provided for @fehlerBeimSpeichern.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern.'**
  String get fehlerBeimSpeichern;

  /// No description provided for @woWirstDuBehandelt.
  ///
  /// In de, this message translates to:
  /// **'Wo wirst du behandelt?'**
  String get woWirstDuBehandelt;

  /// No description provided for @fastGeschafft.
  ///
  /// In de, this message translates to:
  /// **'Fast geschafft!'**
  String get fastGeschafft;

  /// No description provided for @opClinic.
  ///
  /// In de, this message translates to:
  /// **'Klinik'**
  String get opClinic;

  /// No description provided for @deinGesundheitsprofil.
  ///
  /// In de, this message translates to:
  /// **'Dein Gesundheitsprofil'**
  String get deinGesundheitsprofil;

  /// No description provided for @aktuelleMedikamente.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Medikamente'**
  String get aktuelleMedikamente;

  /// No description provided for @oPTypEingeben.
  ///
  /// In de, this message translates to:
  /// **'OP-Typ eingeben'**
  String get oPTypEingeben;

  /// No description provided for @mitKrankenhausaufenthalt.
  ///
  /// In de, this message translates to:
  /// **'Mit Krankenhausaufenthalt'**
  String get mitKrankenhausaufenthalt;

  /// No description provided for @profilGespeichertKurz.
  ///
  /// In de, this message translates to:
  /// **'Profil gespeichert'**
  String get profilGespeichertKurz;

  /// No description provided for @koerperwerteUndGesundheit.
  ///
  /// In de, this message translates to:
  /// **'Körperwerte & Gesundheit'**
  String get koerperwerteUndGesundheit;

  /// No description provided for @notfallkontaktUndNotfallInfo.
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakt & Notfall-Info'**
  String get notfallkontaktUndNotfallInfo;

  /// No description provided for @bezeichnungEingeben.
  ///
  /// In de, this message translates to:
  /// **'Bezeichnung eingeben'**
  String get bezeichnungEingeben;

  /// No description provided for @pINAktivieren.
  ///
  /// In de, this message translates to:
  /// **'PIN aktivieren'**
  String get pINAktivieren;

  /// No description provided for @n4StelligerZugangsPIN.
  ///
  /// In de, this message translates to:
  /// **'4-stelliger Zugangs-PIN'**
  String get n4StelligerZugangsPIN;

  /// No description provided for @proEntdecken.
  ///
  /// In de, this message translates to:
  /// **'Pro entdecken'**
  String get proEntdecken;

  /// No description provided for @aktuellesPasswort.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Passwort'**
  String get aktuellesPasswort;

  /// No description provided for @passwortSpeichern.
  ///
  /// In de, this message translates to:
  /// **'Passwort speichern'**
  String get passwortSpeichern;

  /// No description provided for @labelHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'{label} hinzufügen'**
  String labelHinzufuegen(String label);

  /// No description provided for @vitalwerte.
  ///
  /// In de, this message translates to:
  /// **'Vitalwerte'**
  String get vitalwerte;

  /// No description provided for @neueMessung.
  ///
  /// In de, this message translates to:
  /// **'Neue Messung'**
  String get neueMessung;

  /// No description provided for @systolisch.
  ///
  /// In de, this message translates to:
  /// **'Systolisch'**
  String get systolisch;

  /// No description provided for @diastolisch.
  ///
  /// In de, this message translates to:
  /// **'Diastolisch'**
  String get diastolisch;

  /// No description provided for @puls.
  ///
  /// In de, this message translates to:
  /// **'Puls'**
  String get puls;

  /// No description provided for @normalSystolisch.
  ///
  /// In de, this message translates to:
  /// **'Normal: 90–140'**
  String get normalSystolisch;

  /// No description provided for @normalDiastolisch.
  ///
  /// In de, this message translates to:
  /// **'Normal: 60–90'**
  String get normalDiastolisch;

  /// No description provided for @normalPuls.
  ///
  /// In de, this message translates to:
  /// **'Normal: 60–100'**
  String get normalPuls;

  /// No description provided for @weitereWerteOptional.
  ///
  /// In de, this message translates to:
  /// **'Weitere Werte (optional)'**
  String get weitereWerteOptional;

  /// No description provided for @vitalsErinnerung.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get vitalsErinnerung;

  /// No description provided for @taeglicheMesserinnerung.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Messerinnerung'**
  String get taeglicheMesserinnerung;

  /// No description provided for @temperatur.
  ///
  /// In de, this message translates to:
  /// **'Temperatur'**
  String get temperatur;

  /// No description provided for @normalTemperatur.
  ///
  /// In de, this message translates to:
  /// **'Normal: 36.0–37.5 °C'**
  String get normalTemperatur;

  /// No description provided for @normalO2Saettigung.
  ///
  /// In de, this message translates to:
  /// **'Normal: 95–100 %'**
  String get normalO2Saettigung;

  /// No description provided for @notizOptional.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get notizOptional;

  /// No description provided for @mindZweiEintraege.
  ///
  /// In de, this message translates to:
  /// **'Mind. 2 Einträge für den Verlauf'**
  String get mindZweiEintraege;

  /// No description provided for @vitalsTipp.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Trage deine Vitalwerte täglich ein – so erkennst du Trends frühzeitig.'**
  String get vitalsTipp;

  /// No description provided for @chartLast5.
  ///
  /// In de, this message translates to:
  /// **'5 Einträge'**
  String get chartLast5;

  /// No description provided for @chartDays7.
  ///
  /// In de, this message translates to:
  /// **'7 Tage'**
  String get chartDays7;

  /// No description provided for @chartDays30.
  ///
  /// In de, this message translates to:
  /// **'30 Tage'**
  String get chartDays30;

  /// No description provided for @blutdruck.
  ///
  /// In de, this message translates to:
  /// **'Blutdruck'**
  String get blutdruck;

  /// No description provided for @trageVitalwerteEin.
  ///
  /// In de, this message translates to:
  /// **'Trage deine aktuellen Vitalwerte ein.'**
  String get trageVitalwerteEin;

  /// No description provided for @normalbereichValue.
  ///
  /// In de, this message translates to:
  /// **'Normalbereich: {min}–{max} {unit}'**
  String normalbereichValue(String min, String max, String unit);

  /// No description provided for @neueMessungenSync.
  ///
  /// In de, this message translates to:
  /// **'{count} neue Messungen synchronisiert'**
  String neueMessungenSync(int count);

  /// No description provided for @neueMessungEintragen.
  ///
  /// In de, this message translates to:
  /// **'Neue Messung eintragen'**
  String get neueMessungEintragen;

  /// No description provided for @messungGespeichert.
  ///
  /// In de, this message translates to:
  /// **'Messung gespeichert'**
  String get messungGespeichert;

  /// No description provided for @schmerzfrei.
  ///
  /// In de, this message translates to:
  /// **'Schmerzfrei'**
  String get schmerzfrei;

  /// No description provided for @sehrStark.
  ///
  /// In de, this message translates to:
  /// **'Sehr stark'**
  String get sehrStark;

  /// No description provided for @schmerztagebuch.
  ///
  /// In de, this message translates to:
  /// **'Schmerztagebuch'**
  String get schmerztagebuch;

  /// No description provided for @wieStarkSindDeineSchmerzen.
  ///
  /// In de, this message translates to:
  /// **'Wie stark sind deine Schmerzen?'**
  String get wieStarkSindDeineSchmerzen;

  /// No description provided for @woTutEsWeh.
  ///
  /// In de, this message translates to:
  /// **'Wo tut es weh?'**
  String get woTutEsWeh;

  /// No description provided for @optionalTippeAufEineRegion.
  ///
  /// In de, this message translates to:
  /// **'Optional – tippe auf eine Region'**
  String get optionalTippeAufEineRegion;

  /// No description provided for @artDerSchmerzen.
  ///
  /// In de, this message translates to:
  /// **'Art der Schmerzen'**
  String get artDerSchmerzen;

  /// No description provided for @optionalWieFuehltEsSichAn.
  ///
  /// In de, this message translates to:
  /// **'Optional – wie fühlt es sich an?'**
  String get optionalWieFuehltEsSichAn;

  /// No description provided for @avgSiebenTage.
  ///
  /// In de, this message translates to:
  /// **'Ø 7 Tage'**
  String get avgSiebenTage;

  /// No description provided for @gesamt.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get gesamt;

  /// No description provided for @trendLabel.
  ///
  /// In de, this message translates to:
  /// **'Trend'**
  String get trendLabel;

  /// No description provided for @minMax.
  ///
  /// In de, this message translates to:
  /// **'Min / Max'**
  String get minMax;

  /// No description provided for @eintraegeInsgesamt.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge insgesamt'**
  String eintraegeInsgesamt(int count);

  /// No description provided for @mehrMitPro.
  ///
  /// In de, this message translates to:
  /// **'Mehr mit Pro'**
  String get mehrMitPro;

  /// No description provided for @letzteEintraege.
  ///
  /// In de, this message translates to:
  /// **'Letzte {count} Einträge'**
  String letzteEintraege(int count);

  /// No description provided for @letzteEintraegeGratis.
  ///
  /// In de, this message translates to:
  /// **'Letzte {count} Einträge (5 gratis)'**
  String letzteEintraegeGratis(int count);

  /// No description provided for @letzteEintraegeHeader.
  ///
  /// In de, this message translates to:
  /// **'Letzte Einträge'**
  String get letzteEintraegeHeader;

  /// No description provided for @alleAnzeigen.
  ///
  /// In de, this message translates to:
  /// **'Alle →'**
  String get alleAnzeigen;

  /// No description provided for @gradesEben.
  ///
  /// In de, this message translates to:
  /// **'Gerade eben'**
  String get gradesEben;

  /// No description provided for @vorMinuten.
  ///
  /// In de, this message translates to:
  /// **'vor {min} Min.'**
  String vorMinuten(int min);

  /// No description provided for @vorStunden.
  ///
  /// In de, this message translates to:
  /// **'vor {h} Std.'**
  String vorStunden(int h);

  /// No description provided for @gestern.
  ///
  /// In de, this message translates to:
  /// **'Gestern'**
  String get gestern;

  /// No description provided for @vorTagen.
  ///
  /// In de, this message translates to:
  /// **'vor {days} Tagen'**
  String vorTagen(int days);

  /// No description provided for @ortOptional.
  ///
  /// In de, this message translates to:
  /// **'Ort (optional)'**
  String get ortOptional;

  /// No description provided for @ausloeserOptional.
  ///
  /// In de, this message translates to:
  /// **'Auslöser (optional)'**
  String get ausloeserOptional;

  /// No description provided for @painEntryEditorNotizOptional.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get painEntryEditorNotizOptional;

  /// No description provided for @eintragBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Eintrag bearbeiten'**
  String get eintragBearbeiten;

  /// No description provided for @schmerzlevel.
  ///
  /// In de, this message translates to:
  /// **'Schmerzlevel'**
  String get schmerzlevel;

  /// No description provided for @wann.
  ///
  /// In de, this message translates to:
  /// **'Wann?'**
  String get wann;

  /// No description provided for @datumLabel.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get datumLabel;

  /// No description provided for @uhrzeitLabel.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit'**
  String get uhrzeitLabel;

  /// No description provided for @dauerLabel.
  ///
  /// In de, this message translates to:
  /// **'Dauer'**
  String get dauerLabel;

  /// No description provided for @dauerhaft.
  ///
  /// In de, this message translates to:
  /// **'Dauerhaft'**
  String get dauerhaft;

  /// No description provided for @minMinuten.
  ///
  /// In de, this message translates to:
  /// **'{min} Min.'**
  String minMinuten(int min);

  /// No description provided for @stundenLabel.
  ///
  /// In de, this message translates to:
  /// **'{h} Std.'**
  String stundenLabel(int h);

  /// No description provided for @medikationLabel.
  ///
  /// In de, this message translates to:
  /// **'Medikation'**
  String get medikationLabel;

  /// No description provided for @eintragLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen'**
  String get eintragLoeschen;

  /// No description provided for @kalender.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get kalender;

  /// No description provided for @proLabel.
  ///
  /// In de, this message translates to:
  /// **'Pro'**
  String get proLabel;

  /// No description provided for @filterAktiv.
  ///
  /// In de, this message translates to:
  /// **'Filter aktiv'**
  String get filterAktiv;

  /// No description provided for @filtern.
  ///
  /// In de, this message translates to:
  /// **'Filtern'**
  String get filtern;

  /// No description provided for @koerperregion.
  ///
  /// In de, this message translates to:
  /// **'Körperregion'**
  String get koerperregion;

  /// No description provided for @schmerzart.
  ///
  /// In de, this message translates to:
  /// **'Schmerzart'**
  String get schmerzart;

  /// No description provided for @insights.
  ///
  /// In de, this message translates to:
  /// **'Einblicke'**
  String get insights;

  /// No description provided for @haeufigstesGebiet.
  ///
  /// In de, this message translates to:
  /// **'Häufigstes Gebiet: {region}'**
  String haeufigstesGebiet(String region);

  /// No description provided for @keineEintraegeFilter.
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge mit diesen Filtern'**
  String get keineEintraegeFilter;

  /// No description provided for @nochKeineEintraege.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Einträge'**
  String get nochKeineEintraege;

  /// No description provided for @tippeAufNeuenEintrag.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf \"+ Neuer Eintrag\" um zu starten'**
  String get tippeAufNeuenEintrag;

  /// No description provided for @avgWert.
  ///
  /// In de, this message translates to:
  /// **'Ø {val}'**
  String avgWert(String val);

  /// No description provided for @heute.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get heute;

  /// No description provided for @montag.
  ///
  /// In de, this message translates to:
  /// **'Montag'**
  String get montag;

  /// No description provided for @dienstag.
  ///
  /// In de, this message translates to:
  /// **'Dienstag'**
  String get dienstag;

  /// No description provided for @mittwoch.
  ///
  /// In de, this message translates to:
  /// **'Mittwoch'**
  String get mittwoch;

  /// No description provided for @donnerstag.
  ///
  /// In de, this message translates to:
  /// **'Donnerstag'**
  String get donnerstag;

  /// No description provided for @freitag.
  ///
  /// In de, this message translates to:
  /// **'Freitag'**
  String get freitag;

  /// No description provided for @samstag.
  ///
  /// In de, this message translates to:
  /// **'Samstag'**
  String get samstag;

  /// No description provided for @sonntag.
  ///
  /// In de, this message translates to:
  /// **'Sonntag'**
  String get sonntag;

  /// No description provided for @moKurz.
  ///
  /// In de, this message translates to:
  /// **'Mo'**
  String get moKurz;

  /// No description provided for @diKurz.
  ///
  /// In de, this message translates to:
  /// **'Di'**
  String get diKurz;

  /// No description provided for @miKurz.
  ///
  /// In de, this message translates to:
  /// **'Mi'**
  String get miKurz;

  /// No description provided for @doKurz.
  ///
  /// In de, this message translates to:
  /// **'Do'**
  String get doKurz;

  /// No description provided for @frKurz.
  ///
  /// In de, this message translates to:
  /// **'Fr'**
  String get frKurz;

  /// No description provided for @saKurz.
  ///
  /// In de, this message translates to:
  /// **'Sa'**
  String get saKurz;

  /// No description provided for @soKurz.
  ///
  /// In de, this message translates to:
  /// **'So'**
  String get soKurz;

  /// No description provided for @keinSchmerz.
  ///
  /// In de, this message translates to:
  /// **'Kein'**
  String get keinSchmerz;

  /// No description provided for @kalenderMitProFreischalten.
  ///
  /// In de, this message translates to:
  /// **'Kalender mit Pro freischalten'**
  String get kalenderMitProFreischalten;

  /// No description provided for @keineDetails.
  ///
  /// In de, this message translates to:
  /// **'Keine Details'**
  String get keineDetails;

  /// No description provided for @minLabel.
  ///
  /// In de, this message translates to:
  /// **'Min'**
  String get minLabel;

  /// No description provided for @maxLabel.
  ///
  /// In de, this message translates to:
  /// **'Max'**
  String get maxLabel;

  /// No description provided for @bellaAnalyse.
  ///
  /// In de, this message translates to:
  /// **'Bella Analyse'**
  String get bellaAnalyse;

  /// No description provided for @emptyNoEntries.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Einträge'**
  String get emptyNoEntries;

  /// No description provided for @emptyWoundDocHint.
  ///
  /// In de, this message translates to:
  /// **'Dokumentiere deinen Heilungsverlauf mit täglichen Fotos.'**
  String get emptyWoundDocHint;

  /// No description provided for @ersteDokumentationStarten.
  ///
  /// In de, this message translates to:
  /// **'Erste Dokumentation starten'**
  String get ersteDokumentationStarten;

  /// No description provided for @neuesFotoAufnehmen.
  ///
  /// In de, this message translates to:
  /// **'Neues Foto aufnehmen'**
  String get neuesFotoAufnehmen;

  /// No description provided for @woundHubKoerperstelle.
  ///
  /// In de, this message translates to:
  /// **'Körperstelle'**
  String get woundHubKoerperstelle;

  /// No description provided for @neuErfassen.
  ///
  /// In de, this message translates to:
  /// **'Neu erfassen'**
  String get neuErfassen;

  /// No description provided for @verlaufVergleichen.
  ///
  /// In de, this message translates to:
  /// **'Verlauf vergleichen'**
  String get verlaufVergleichen;

  /// No description provided for @koerperstelle.
  ///
  /// In de, this message translates to:
  /// **'Körperstelle'**
  String get koerperstelle;

  /// No description provided for @keinFotoAnalyse.
  ///
  /// In de, this message translates to:
  /// **'Kein Foto vorhanden.'**
  String get keinFotoAnalyse;

  /// No description provided for @n1FotoPflaster.
  ///
  /// In de, this message translates to:
  /// **'1. Foto: Pflaster'**
  String get n1FotoPflaster;

  /// No description provided for @zeigtDenZustandDesVerbands.
  ///
  /// In de, this message translates to:
  /// **'Zeigt den Zustand des Verbands'**
  String get zeigtDenZustandDesVerbands;

  /// No description provided for @n2FotoWunde.
  ///
  /// In de, this message translates to:
  /// **'2. Foto: Wunde'**
  String get n2FotoWunde;

  /// No description provided for @nachAbnehmenDesPflasters.
  ///
  /// In de, this message translates to:
  /// **'Nach Abnehmen des Pflasters'**
  String get nachAbnehmenDesPflasters;

  /// No description provided for @linksA.
  ///
  /// In de, this message translates to:
  /// **'Links (A)'**
  String get linksA;

  /// No description provided for @rechtsB.
  ///
  /// In de, this message translates to:
  /// **'Rechts (B)'**
  String get rechtsB;

  /// No description provided for @schmerzScore.
  ///
  /// In de, this message translates to:
  /// **'Schmerzstärke: {score}/10'**
  String schmerzScore(int score);

  /// No description provided for @fotoLadeFehler.
  ///
  /// In de, this message translates to:
  /// **'Foto konnte nicht geladen werden.'**
  String get fotoLadeFehler;

  /// No description provided for @fotoHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Foto hinzufügen'**
  String get fotoHinzufuegen;

  /// No description provided for @fotoQuelleWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Foto-Quelle wählen'**
  String get fotoQuelleWaehlen;

  /// No description provided for @kameraOeffnen.
  ///
  /// In de, this message translates to:
  /// **'Kamera'**
  String get kameraOeffnen;

  /// No description provided for @ausGalerieWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Aus Galerie'**
  String get ausGalerieWaehlen;

  /// No description provided for @fotoAendern.
  ///
  /// In de, this message translates to:
  /// **'Foto ändern'**
  String get fotoAendern;

  /// No description provided for @fotoEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Foto entfernen'**
  String get fotoEntfernen;

  /// No description provided for @kameraBerechtigungFehlt.
  ///
  /// In de, this message translates to:
  /// **'Kamera-Zugriff verweigert. Bitte erlaube den Kamera-Zugriff in den Einstellungen.'**
  String get kameraBerechtigungFehlt;

  /// No description provided for @fotoMediathekBerechtigungFehlt.
  ///
  /// In de, this message translates to:
  /// **'Zugriff auf Fotomediathek verweigert. Bitte erlaube den Zugriff in den Einstellungen.'**
  String get fotoMediathekBerechtigungFehlt;

  /// No description provided for @kameraFehlerVersucheGalerie.
  ///
  /// In de, this message translates to:
  /// **'Kamera nicht verfügbar. Bitte wähle ein Foto aus der Galerie.'**
  String get kameraFehlerVersucheGalerie;

  /// No description provided for @koerperstelleOptional.
  ///
  /// In de, this message translates to:
  /// **'Körperstelle (optional)'**
  String get koerperstelleOptional;

  /// No description provided for @woundCompareTitle.
  ///
  /// In de, this message translates to:
  /// **'Wundvergleich'**
  String get woundCompareTitle;

  /// No description provided for @woundCompareSlider.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get woundCompareSlider;

  /// No description provided for @woundCompareCompare.
  ///
  /// In de, this message translates to:
  /// **'Vergleich'**
  String get woundCompareCompare;

  /// No description provided for @emptyNoPhotos.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos vorhanden.'**
  String get emptyNoPhotos;

  /// No description provided for @emptyWoundCompareHint.
  ///
  /// In de, this message translates to:
  /// **'Füge Fotos zur Wunddokumentation hinzu, um den Verlauf zu vergleichen.'**
  String get emptyWoundCompareHint;

  /// No description provided for @wundDokumentationTitle.
  ///
  /// In de, this message translates to:
  /// **'Wunddokumentation'**
  String get wundDokumentationTitle;

  /// No description provided for @woundNoPhotoYet.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Foto'**
  String get woundNoPhotoYet;

  /// No description provided for @woundNoteHint.
  ///
  /// In de, this message translates to:
  /// **'Wie sieht die Wunde aus? Besonderheiten?'**
  String get woundNoteHint;

  /// No description provided for @notizLabel.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get notizLabel;

  /// No description provided for @woundHistoryTitle.
  ///
  /// In de, this message translates to:
  /// **'Wundverlauf'**
  String get woundHistoryTitle;

  /// No description provided for @woundDiaryTitle.
  ///
  /// In de, this message translates to:
  /// **'Wundtagebuch'**
  String get woundDiaryTitle;

  /// No description provided for @woundDiarySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Chronologische Übersicht Ihrer Wundheilung mit Fotos und Notizen.'**
  String get woundDiarySubtitle;

  /// No description provided for @woundPhotoGuideTitle.
  ///
  /// In de, this message translates to:
  /// **'Foto-Anleitung'**
  String get woundPhotoGuideTitle;

  /// No description provided for @woundPhotoGuideSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Für eine gute Dokumentation empfehlen wir täglich 2 Fotos:'**
  String get woundPhotoGuideSubtitle;

  /// No description provided for @woundPhotoTip.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Achten Sie auf gute Beleuchtung und fotografieren Sie aus dem gleichen Winkel.'**
  String get woundPhotoTip;

  /// No description provided for @woundNoNotiz.
  ///
  /// In de, this message translates to:
  /// **'Keine Notiz'**
  String get woundNoNotiz;

  /// No description provided for @woundDetailTitle.
  ///
  /// In de, this message translates to:
  /// **'Wunddetail'**
  String get woundDetailTitle;

  /// No description provided for @notSpecified.
  ///
  /// In de, this message translates to:
  /// **'Nicht angegeben'**
  String get notSpecified;

  /// No description provided for @woundDeleteConfirmMessage.
  ///
  /// In de, this message translates to:
  /// **'Dieser Wundeintrag wird dauerhaft entfernt.'**
  String get woundDeleteConfirmMessage;

  /// No description provided for @woundMinEntriesForCompare.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 2 Wundeinträge für Vergleich erforderlich.'**
  String get woundMinEntriesForCompare;

  /// No description provided for @woundDiscoveryTip.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Fotografiere deine Wunde regelmäßig – so erkennst du Veränderungen auf einen Blick.'**
  String get woundDiscoveryTip;

  /// No description provided for @woundEntryCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Eintrag} other{{count} Einträge}}'**
  String woundEntryCount(int count);

  /// No description provided for @woundNoPhotoCaptured.
  ///
  /// In de, this message translates to:
  /// **'Kein Foto vorhanden'**
  String get woundNoPhotoCaptured;

  /// No description provided for @woundTapForDetails.
  ///
  /// In de, this message translates to:
  /// **'Tippen für Details'**
  String get woundTapForDetails;

  /// No description provided for @woundComparePick2.
  ///
  /// In de, this message translates to:
  /// **'Wähle zwei Fotos zum Vergleichen'**
  String get woundComparePick2;

  /// No description provided for @woundModeSplit.
  ///
  /// In de, this message translates to:
  /// **'Split'**
  String get woundModeSplit;

  /// No description provided for @woundModeOverlay.
  ///
  /// In de, this message translates to:
  /// **'Overlay'**
  String get woundModeOverlay;

  /// No description provided for @woundComparePhotosSelected.
  ///
  /// In de, this message translates to:
  /// **'{count} / 2 Fotos gewählt'**
  String woundComparePhotosSelected(int count);

  /// No description provided for @woundCompareTapInstruction.
  ///
  /// In de, this message translates to:
  /// **'Tippe unten auf die Fotos, die du vergleichen möchtest.'**
  String get woundCompareTapInstruction;

  /// No description provided for @before.
  ///
  /// In de, this message translates to:
  /// **'Vorher'**
  String get before;

  /// No description provided for @after.
  ///
  /// In de, this message translates to:
  /// **'Nachher'**
  String get after;

  /// No description provided for @woundHygieneStep1.
  ///
  /// In de, this message translates to:
  /// **'Hände gründlich waschen'**
  String get woundHygieneStep1;

  /// No description provided for @woundHygieneStep2.
  ///
  /// In de, this message translates to:
  /// **'🩹 Trockener Pflasterwechsel'**
  String get woundHygieneStep2;

  /// No description provided for @woundHygieneStep3.
  ///
  /// In de, this message translates to:
  /// **'Wunddoku: Trocken? Nicht rot? Keine frische Blutung?'**
  String get woundHygieneStep3;

  /// No description provided for @woundHygieneStep4.
  ///
  /// In de, this message translates to:
  /// **'Keine Berührung der Wunde, keine Manipulation, keine Cremes'**
  String get woundHygieneStep4;

  /// No description provided for @woundHygieneStep5.
  ///
  /// In de, this message translates to:
  /// **'Pflaster ohne Berührung der Auflage erneuern'**
  String get woundHygieneStep5;

  /// No description provided for @woundHygieneStep6.
  ///
  /// In de, this message translates to:
  /// **'Erneut Hände waschen'**
  String get woundHygieneStep6;

  /// No description provided for @woundHygieneTitle.
  ///
  /// In de, this message translates to:
  /// **'🧴 Wundhygiene-Empfehlungen'**
  String get woundHygieneTitle;

  /// No description provided for @woundHygieneWarning.
  ///
  /// In de, this message translates to:
  /// **'Bei Rötung bitte Praxis kontaktieren'**
  String get woundHygieneWarning;

  /// No description provided for @woundHygieneAckLabel.
  ///
  /// In de, this message translates to:
  /// **'✅ Gelesen am {date}'**
  String woundHygieneAckLabel(String date);

  /// No description provided for @kalorienKcal.
  ///
  /// In de, this message translates to:
  /// **'Kalorien (kcal)'**
  String get kalorienKcal;

  /// No description provided for @nutritionProteinG.
  ///
  /// In de, this message translates to:
  /// **'Protein (g)'**
  String get nutritionProteinG;

  /// No description provided for @wasserMl.
  ///
  /// In de, this message translates to:
  /// **'Wasser (ml)'**
  String get wasserMl;

  /// No description provided for @nameDerVorlage.
  ///
  /// In de, this message translates to:
  /// **'Name der Vorlage'**
  String get nameDerVorlage;

  /// No description provided for @zBHaferbreiMitBeeren.
  ///
  /// In de, this message translates to:
  /// **'z. B. Haferbrei mit Beeren'**
  String get zBHaferbreiMitBeeren;

  /// No description provided for @zbVollkornbrot.
  ///
  /// In de, this message translates to:
  /// **'z. B. Vollkornbrot mit Käse'**
  String get zbVollkornbrot;

  /// No description provided for @proteinG.
  ///
  /// In de, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @nutritionKohlenhG.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate (g)'**
  String get nutritionKohlenhG;

  /// No description provided for @nutritionFettG.
  ///
  /// In de, this message translates to:
  /// **'Fett (g)'**
  String get nutritionFettG;

  /// No description provided for @templateWirdEntfernt.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ wird aus deinen Vorlagen entfernt.'**
  String templateWirdEntfernt(String name);

  /// No description provided for @naehrwerteOptional.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte (optional)'**
  String get naehrwerteOptional;

  /// No description provided for @kohlenhG.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate (g)'**
  String get kohlenhG;

  /// No description provided for @fettG.
  ///
  /// In de, this message translates to:
  /// **'Fett (g)'**
  String get fettG;

  /// No description provided for @getrunkenMl.
  ///
  /// In de, this message translates to:
  /// **'Getrunken (ml)'**
  String get getrunkenMl;

  /// No description provided for @vertraeglichkeit.
  ///
  /// In de, this message translates to:
  /// **'Verträglichkeit'**
  String get vertraeglichkeit;

  /// No description provided for @mahlzeitSpeichern.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit speichern'**
  String get mahlzeitSpeichern;

  /// No description provided for @wasserMlDescription.
  ///
  /// In de, this message translates to:
  /// **'Wasser {ml}ml'**
  String wasserMlDescription(int ml);

  /// No description provided for @wasserMlAdded.
  ///
  /// In de, this message translates to:
  /// **'+{ml}ml Wasser erfasst'**
  String wasserMlAdded(int ml);

  /// No description provided for @vorlageLabel.
  ///
  /// In de, this message translates to:
  /// **'Vorlage'**
  String get vorlageLabel;

  /// No description provided for @wasserTracking.
  ///
  /// In de, this message translates to:
  /// **'Wasser-Tracking'**
  String get wasserTracking;

  /// No description provided for @favoriten.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get favoriten;

  /// No description provided for @tippeZumSchnellenWiederholen.
  ///
  /// In de, this message translates to:
  /// **'Tippe zum schnellen Wiederholen'**
  String get tippeZumSchnellenWiederholen;

  /// No description provided for @mahlzeitLabel.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit'**
  String get mahlzeitLabel;

  /// No description provided for @wasHastDuGegessen.
  ///
  /// In de, this message translates to:
  /// **'Was hast du gegessen?'**
  String get wasHastDuGegessen;

  /// No description provided for @optionalWasserTeeEtc.
  ///
  /// In de, this message translates to:
  /// **'Optional – Wasser, Tee, etc.'**
  String get optionalWasserTeeEtc;

  /// No description provided for @optionalWieVertragen.
  ///
  /// In de, this message translates to:
  /// **'Optional – wie hast du das Essen vertragen?'**
  String get optionalWieVertragen;

  /// No description provided for @symptomeNachDemEssen.
  ///
  /// In de, this message translates to:
  /// **'Symptome nach dem Essen'**
  String get symptomeNachDemEssen;

  /// No description provided for @optionalTippeAuf.
  ///
  /// In de, this message translates to:
  /// **'Optional – tippe auf zutreffende Symptome'**
  String get optionalTippeAuf;

  /// No description provided for @naehrwerteTitle.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte'**
  String get naehrwerteTitle;

  /// No description provided for @optionalKalorienProtein.
  ///
  /// In de, this message translates to:
  /// **'Optional – Kalorien, Protein, Kohlenhydrate, Fett'**
  String get optionalKalorienProtein;

  /// No description provided for @vorlagenTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorlagen'**
  String get vorlagenTitle;

  /// No description provided for @empfehlungFuerOp.
  ///
  /// In de, this message translates to:
  /// **'Empfehlung für {opType}-OP'**
  String empfehlungFuerOp(String opType);

  /// No description provided for @empfehlungFuerOpTag.
  ///
  /// In de, this message translates to:
  /// **' · Tag {day}'**
  String empfehlungFuerOpTag(int day);

  /// No description provided for @empfehlungenTitle.
  ///
  /// In de, this message translates to:
  /// **'Empfehlungen'**
  String get empfehlungenTitle;

  /// No description provided for @heuteMahlzeitenCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Mahlzeit} other{{count} Mahlzeiten}}'**
  String heuteMahlzeitenCount(int count);

  /// No description provided for @kcalLabel.
  ///
  /// In de, this message translates to:
  /// **'kcal'**
  String get kcalLabel;

  /// No description provided for @proteinLabel.
  ///
  /// In de, this message translates to:
  /// **'Protein'**
  String get proteinLabel;

  /// No description provided for @wasserLabel.
  ///
  /// In de, this message translates to:
  /// **'Wasser'**
  String get wasserLabel;

  /// No description provided for @symptomCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Symptom} other{{count} Symptome}}'**
  String symptomCount(int count);

  /// No description provided for @keineFilterEintraege.
  ///
  /// In de, this message translates to:
  /// **'Keine {mealType}-Einträge'**
  String keineFilterEintraege(String mealType);

  /// No description provided for @ersteMahlzeitTipp.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf + um deine erste Mahlzeit zu erfassen.'**
  String get ersteMahlzeitTipp;

  /// No description provided for @beschreibungLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get beschreibungLabel;

  /// No description provided for @zbVollkornbrotQuark.
  ///
  /// In de, this message translates to:
  /// **'z. B. Vollkornbrot mit Quark und Tomaten'**
  String get zbVollkornbrotQuark;

  /// No description provided for @zbZahl.
  ///
  /// In de, this message translates to:
  /// **'z. B. 250'**
  String get zbZahl;

  /// No description provided for @symptomeLabel.
  ///
  /// In de, this message translates to:
  /// **'Symptome'**
  String get symptomeLabel;

  /// No description provided for @notizZuSymptomenOptional.
  ///
  /// In de, this message translates to:
  /// **'Notiz zu den Symptomen (optional)'**
  String get notizZuSymptomenOptional;

  /// No description provided for @eintrBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Eintrag bearbeiten'**
  String get eintrBearbeiten;

  /// No description provided for @neueMahlzeit.
  ///
  /// In de, this message translates to:
  /// **'Neue Mahlzeit'**
  String get neueMahlzeit;

  /// No description provided for @eintrLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen'**
  String get eintrLoeschen;

  /// No description provided for @mealTypeFruehstueck.
  ///
  /// In de, this message translates to:
  /// **'Frühstück'**
  String get mealTypeFruehstueck;

  /// No description provided for @mealTypeMittagessen.
  ///
  /// In de, this message translates to:
  /// **'Mittagessen'**
  String get mealTypeMittagessen;

  /// No description provided for @mealTypeAbendessen.
  ///
  /// In de, this message translates to:
  /// **'Abendessen'**
  String get mealTypeAbendessen;

  /// No description provided for @mealTypeSnack.
  ///
  /// In de, this message translates to:
  /// **'Snack'**
  String get mealTypeSnack;

  /// No description provided for @symptomUebelkeit.
  ///
  /// In de, this message translates to:
  /// **'Übelkeit'**
  String get symptomUebelkeit;

  /// No description provided for @symptomBlaehungen.
  ///
  /// In de, this message translates to:
  /// **'Blähungen'**
  String get symptomBlaehungen;

  /// No description provided for @symptomSchmerzen.
  ///
  /// In de, this message translates to:
  /// **'Schmerzen'**
  String get symptomSchmerzen;

  /// No description provided for @symptomSodbrennen.
  ///
  /// In de, this message translates to:
  /// **'Sodbrennen'**
  String get symptomSodbrennen;

  /// No description provided for @symptomDurchfall.
  ///
  /// In de, this message translates to:
  /// **'Durchfall'**
  String get symptomDurchfall;

  /// No description provided for @symptomVerstopfung.
  ///
  /// In de, this message translates to:
  /// **'Verstopfung'**
  String get symptomVerstopfung;

  /// No description provided for @symptomMuedigkeit.
  ///
  /// In de, this message translates to:
  /// **'Müdigkeit'**
  String get symptomMuedigkeit;

  /// No description provided for @symptomSonstige.
  ///
  /// In de, this message translates to:
  /// **'Sonstige'**
  String get symptomSonstige;

  /// No description provided for @nochmal.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get nochmal;

  /// No description provided for @ablaufNarkoseEingriffe.
  ///
  /// In de, this message translates to:
  /// **'Ablauf, Narkose, Eingriffe'**
  String get ablaufNarkoseEingriffe;

  /// No description provided for @abmelden.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get abmelden;

  /// No description provided for @adminAbmeldenBestaetigung.
  ///
  /// In de, this message translates to:
  /// **'Wirklich aus dem Admin-Bereich abmelden?'**
  String get adminAbmeldenBestaetigung;

  /// No description provided for @adminAktionenUndEreignisprotokoll.
  ///
  /// In de, this message translates to:
  /// **'Admin-Aktionen & Ereignisprotokoll'**
  String get adminAktionenUndEreignisprotokoll;

  /// No description provided for @adminBenachrichtigungenUndEreignisse.
  ///
  /// In de, this message translates to:
  /// **'Admin-Benachrichtigungen & Ereignisse'**
  String get adminBenachrichtigungenUndEreignisse;

  /// No description provided for @aktivDieseWoche.
  ///
  /// In de, this message translates to:
  /// **'Aktiv diese Woche'**
  String get aktivDieseWoche;

  /// No description provided for @aktiveProLizenzen.
  ///
  /// In de, this message translates to:
  /// **'Aktive Pro-Lizenzen'**
  String get aktiveProLizenzen;

  /// No description provided for @aktiveTage.
  ///
  /// In de, this message translates to:
  /// **'Aktive Tage'**
  String get aktiveTage;

  /// No description provided for @aktivHeute.
  ///
  /// In de, this message translates to:
  /// **'Aktiv heute'**
  String get aktivHeute;

  /// No description provided for @aktivitaetsHeatmap.
  ///
  /// In de, this message translates to:
  /// **'Aktivitäts-Heatmap'**
  String get aktivitaetsHeatmap;

  /// No description provided for @alertArztKontaktieren.
  ///
  /// In de, this message translates to:
  /// **'Arzt kontaktieren'**
  String get alertArztKontaktieren;

  /// No description provided for @alle.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get alle;

  /// No description provided for @alleAlsGelesenMarkieren.
  ///
  /// In de, this message translates to:
  /// **'Alle als gelesen markieren'**
  String get alleAlsGelesenMarkieren;

  /// No description provided for @alleFunktionenOhneEinschraenkung.
  ///
  /// In de, this message translates to:
  /// **'Alle Funktionen ohne Einschränkung'**
  String get alleFunktionenOhneEinschraenkung;

  /// No description provided for @alleMarkieren.
  ///
  /// In de, this message translates to:
  /// **'Alle →'**
  String get alleMarkieren;

  /// No description provided for @alsGelesen.
  ///
  /// In de, this message translates to:
  /// **'Als gelesen'**
  String get alsGelesen;

  /// No description provided for @alsPDFTeilen.
  ///
  /// In de, this message translates to:
  /// **'Als PDF teilen'**
  String get alsPDFTeilen;

  /// No description provided for @alsTextKopieren.
  ///
  /// In de, this message translates to:
  /// **'Als Text kopieren'**
  String get alsTextKopieren;

  /// No description provided for @angehoerigeEinladenUndGemeinsamBegleiten.
  ///
  /// In de, this message translates to:
  /// **'Angehörige einladen & gemeinsam begleiten'**
  String get angehoerigeEinladenUndGemeinsamBegleiten;

  /// No description provided for @angehoerigenEinladen.
  ///
  /// In de, this message translates to:
  /// **'Angehörigen einladen'**
  String get angehoerigenEinladen;

  /// No description provided for @anweisungNotiz.
  ///
  /// In de, this message translates to:
  /// **'Anweisung / Notiz'**
  String get anweisungNotiz;

  /// No description provided for @appointmentEditorRepeatUntil.
  ///
  /// In de, this message translates to:
  /// **'Wiederholen bis'**
  String get appointmentEditorRepeatUntil;

  /// No description provided for @apptAddFirstHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf +, um deinen ersten Termin hinzuzufügen.'**
  String get apptAddFirstHint;

  /// No description provided for @apptCancelAppt.
  ///
  /// In de, this message translates to:
  /// **'Termin absagen'**
  String get apptCancelAppt;

  /// No description provided for @apptConfirmationPending.
  ///
  /// In de, this message translates to:
  /// **'Bestätigung ausstehend'**
  String get apptConfirmationPending;

  /// No description provided for @apptConfirmDeclineHint.
  ///
  /// In de, this message translates to:
  /// **'Bitte bestätigen oder ablehnen.'**
  String get apptConfirmDeclineHint;

  /// No description provided for @apptCreatedByDoctor.
  ///
  /// In de, this message translates to:
  /// **'Vom Arzt erstellt'**
  String get apptCreatedByDoctor;

  /// No description provided for @apptDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Termin löschen'**
  String get apptDeleteTitle;

  /// No description provided for @apptEditTitle.
  ///
  /// In de, this message translates to:
  /// **'Termin bearbeiten'**
  String get apptEditTitle;

  /// No description provided for @apptHintCustomMinutes.
  ///
  /// In de, this message translates to:
  /// **'Minuten'**
  String get apptHintCustomMinutes;

  /// No description provided for @apptHintDoctor.
  ///
  /// In de, this message translates to:
  /// **'z.B. Dr. Müller'**
  String get apptHintDoctor;

  /// No description provided for @apptHintLocation.
  ///
  /// In de, this message translates to:
  /// **'z.B. Städtisches Klinikum'**
  String get apptHintLocation;

  /// No description provided for @apptHintLocationDetails.
  ///
  /// In de, this message translates to:
  /// **'Details (Station, Zimmer)'**
  String get apptHintLocationDetails;

  /// No description provided for @apptHintNote.
  ///
  /// In de, this message translates to:
  /// **'Optionale Notiz…'**
  String get apptHintNote;

  /// No description provided for @apptHintTitle.
  ///
  /// In de, this message translates to:
  /// **'z. B. Nachsorgetermin'**
  String get apptHintTitle;

  /// No description provided for @apptLabelCustomMinutes.
  ///
  /// In de, this message translates to:
  /// **'Minuten'**
  String get apptLabelCustomMinutes;

  /// No description provided for @apptLabelDate.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get apptLabelDate;

  /// No description provided for @apptLabelDoctor.
  ///
  /// In de, this message translates to:
  /// **'Arzt / Behandler'**
  String get apptLabelDoctor;

  /// No description provided for @apptLabelEndTime.
  ///
  /// In de, this message translates to:
  /// **'Endzeit'**
  String get apptLabelEndTime;

  /// No description provided for @apptLabelFurtherDetails.
  ///
  /// In de, this message translates to:
  /// **'Weitere Details'**
  String get apptLabelFurtherDetails;

  /// No description provided for @apptLabelFurtherReminders.
  ///
  /// In de, this message translates to:
  /// **'Weitere Erinnerungen'**
  String get apptLabelFurtherReminders;

  /// No description provided for @apptLabelLocation.
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get apptLabelLocation;

  /// No description provided for @apptLabelNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get apptLabelNote;

  /// No description provided for @apptLabelPriority.
  ///
  /// In de, this message translates to:
  /// **'Priorität'**
  String get apptLabelPriority;

  /// No description provided for @apptLabelReminder.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get apptLabelReminder;

  /// No description provided for @apptLabelRepeatUntil.
  ///
  /// In de, this message translates to:
  /// **'Bis'**
  String get apptLabelRepeatUntil;

  /// No description provided for @apptLabelStartTime.
  ///
  /// In de, this message translates to:
  /// **'Startzeit'**
  String get apptLabelStartTime;

  /// No description provided for @apptLabelTime.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit'**
  String get apptLabelTime;

  /// No description provided for @apptLabelTitleRequired.
  ///
  /// In de, this message translates to:
  /// **'Titel *'**
  String get apptLabelTitleRequired;

  /// No description provided for @apptLabelType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get apptLabelType;

  /// No description provided for @apptMarkAsDone.
  ///
  /// In de, this message translates to:
  /// **'Als erledigt markieren'**
  String get apptMarkAsDone;

  /// No description provided for @apptMarkAsPlanned.
  ///
  /// In de, this message translates to:
  /// **'Als geplant markieren'**
  String get apptMarkAsPlanned;

  /// No description provided for @apptNewTitle.
  ///
  /// In de, this message translates to:
  /// **'Neuer Termin'**
  String get apptNewTitle;

  /// No description provided for @apptNoAppointments.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Termine'**
  String get apptNoAppointments;

  /// No description provided for @apptNoResults.
  ///
  /// In de, this message translates to:
  /// **'Keine Ergebnisse'**
  String get apptNoResults;

  /// No description provided for @apptNoResultsHint.
  ///
  /// In de, this message translates to:
  /// **'Andere Suchbegriffe oder Filter verwenden.'**
  String get apptNoResultsHint;

  /// No description provided for @apptPriorityHigh.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get apptPriorityHigh;

  /// No description provided for @apptPriorityLow.
  ///
  /// In de, this message translates to:
  /// **'Niedrig'**
  String get apptPriorityLow;

  /// No description provided for @apptPriorityMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get apptPriorityMedium;

  /// No description provided for @apptPriorityUrgent.
  ///
  /// In de, this message translates to:
  /// **'Dringend'**
  String get apptPriorityUrgent;

  /// No description provided for @apptReminderAtTime.
  ///
  /// In de, this message translates to:
  /// **'Pünktlich'**
  String get apptReminderAtTime;

  /// No description provided for @apptReminderCustom.
  ///
  /// In de, this message translates to:
  /// **'Benutzerdefiniert'**
  String get apptReminderCustom;

  /// No description provided for @apptReminderDay1.
  ///
  /// In de, this message translates to:
  /// **'1 Tag vorher'**
  String get apptReminderDay1;

  /// No description provided for @apptReminderDays2.
  ///
  /// In de, this message translates to:
  /// **'2 Tage vorher'**
  String get apptReminderDays2;

  /// No description provided for @apptReminderHour1.
  ///
  /// In de, this message translates to:
  /// **'1 Stunde vorher'**
  String get apptReminderHour1;

  /// No description provided for @apptReminderHours2.
  ///
  /// In de, this message translates to:
  /// **'2 Stunden vorher'**
  String get apptReminderHours2;

  /// No description provided for @apptReminderMin15.
  ///
  /// In de, this message translates to:
  /// **'15 Min. vorher'**
  String get apptReminderMin15;

  /// No description provided for @apptReminderMin30.
  ///
  /// In de, this message translates to:
  /// **'30 Min. vorher'**
  String get apptReminderMin30;

  /// No description provided for @apptReminderNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get apptReminderNone;

  /// No description provided for @apptRepeatDaily.
  ///
  /// In de, this message translates to:
  /// **'Täglich'**
  String get apptRepeatDaily;

  /// No description provided for @apptRepeatMonthly.
  ///
  /// In de, this message translates to:
  /// **'Monatlich'**
  String get apptRepeatMonthly;

  /// No description provided for @apptRepeatNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get apptRepeatNone;

  /// No description provided for @apptRepeatWeekly.
  ///
  /// In de, this message translates to:
  /// **'Wöchentlich'**
  String get apptRepeatWeekly;

  /// No description provided for @apptSaving.
  ///
  /// In de, this message translates to:
  /// **'Wird gespeichert…'**
  String get apptSaving;

  /// No description provided for @apptStatusCanceled.
  ///
  /// In de, this message translates to:
  /// **'Abgesagt'**
  String get apptStatusCanceled;

  /// No description provided for @apptStatusCompleted.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get apptStatusCompleted;

  /// No description provided for @apptStatusConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Bestätigt'**
  String get apptStatusConfirmed;

  /// No description provided for @apptStatusDeclined.
  ///
  /// In de, this message translates to:
  /// **'Abgelehnt'**
  String get apptStatusDeclined;

  /// No description provided for @apptStatusDone.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get apptStatusDone;

  /// No description provided for @apptStatusPending.
  ///
  /// In de, this message translates to:
  /// **'Ausstehend'**
  String get apptStatusPending;

  /// No description provided for @apptStatusPlanned.
  ///
  /// In de, this message translates to:
  /// **'Geplant'**
  String get apptStatusPlanned;

  /// No description provided for @apptTitleRequired.
  ///
  /// In de, this message translates to:
  /// **'Titel ist erforderlich.'**
  String get apptTitleRequired;

  /// No description provided for @apptTodayNone.
  ///
  /// In de, this message translates to:
  /// **'Heute keine Termine'**
  String get apptTodayNone;

  /// No description provided for @apptTodayTitle.
  ///
  /// In de, this message translates to:
  /// **'Heutige Termine'**
  String get apptTodayTitle;

  /// No description provided for @apptTypeCall.
  ///
  /// In de, this message translates to:
  /// **'Telefonat'**
  String get apptTypeCall;

  /// No description provided for @apptTypeFollowUp.
  ///
  /// In de, this message translates to:
  /// **'Nachsorge'**
  String get apptTypeFollowUp;

  /// No description provided for @apptTypeImaging.
  ///
  /// In de, this message translates to:
  /// **'Bildgebung'**
  String get apptTypeImaging;

  /// No description provided for @apptTypeOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get apptTypeOther;

  /// No description provided for @apptTypePhysio.
  ///
  /// In de, this message translates to:
  /// **'Physiotherapie'**
  String get apptTypePhysio;

  /// No description provided for @apptTypeSurgery.
  ///
  /// In de, this message translates to:
  /// **'Operation'**
  String get apptTypeSurgery;

  /// No description provided for @apptViewCalendar.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get apptViewCalendar;

  /// No description provided for @apptViewList.
  ///
  /// In de, this message translates to:
  /// **'Liste'**
  String get apptViewList;

  /// No description provided for @apptYesterday.
  ///
  /// In de, this message translates to:
  /// **'Gestern'**
  String get apptYesterday;

  /// No description provided for @arztBehandler.
  ///
  /// In de, this message translates to:
  /// **'Arzt / Behandler'**
  String get arztBehandler;

  /// No description provided for @arztEntsperren.
  ///
  /// In de, this message translates to:
  /// **'Arzt entsperren?'**
  String get arztEntsperren;

  /// No description provided for @arztSofortKontaktieren.
  ///
  /// In de, this message translates to:
  /// **'Arzt sofort kontaktieren'**
  String get arztSofortKontaktieren;

  /// No description provided for @arztSperren.
  ///
  /// In de, this message translates to:
  /// **'Arzt sperren?'**
  String get arztSperren;

  /// No description provided for @arztUndPatienteneinladungen.
  ///
  /// In de, this message translates to:
  /// **'Arzt- & Patienteneinladungen'**
  String get arztUndPatienteneinladungen;

  /// No description provided for @aufbauUndRoutine.
  ///
  /// In de, this message translates to:
  /// **'Aufbau & Routine'**
  String get aufbauUndRoutine;

  /// No description provided for @aufnahmeStartFehler.
  ///
  /// In de, this message translates to:
  /// **'Aufnahme konnte nicht gestartet werden.'**
  String get aufnahmeStartFehler;

  /// No description provided for @aufProUpgraden.
  ///
  /// In de, this message translates to:
  /// **'Auf Pro upgraden'**
  String get aufProUpgraden;

  /// No description provided for @auswertungAnzeigen.
  ///
  /// In de, this message translates to:
  /// **'Auswertung anzeigen'**
  String get auswertungAnzeigen;

  /// No description provided for @bedarfsmedikationOderSpontaneEinnahmen.
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedikation oder spontane Einnahmen.'**
  String get bedarfsmedikationOderSpontaneEinnahmen;

  /// No description provided for @begruendungEingeben.
  ///
  /// In de, this message translates to:
  /// **'Begründung eingeben …'**
  String get begruendungEingeben;

  /// No description provided for @beiAkuterVerschlechterung.
  ///
  /// In de, this message translates to:
  /// **'Bei akuter Verschlechterung'**
  String get beiAkuterVerschlechterung;

  /// No description provided for @beiVerschlechterungAnrufen.
  ///
  /// In de, this message translates to:
  /// **'Bei Verschlechterung anrufen'**
  String get beiVerschlechterungAnrufen;

  /// No description provided for @bellaActionCancelled.
  ///
  /// In de, this message translates to:
  /// **'Abgebrochen'**
  String get bellaActionCancelled;

  /// No description provided for @bellaActionCreated.
  ///
  /// In de, this message translates to:
  /// **'Eintrag erstellt ✓'**
  String get bellaActionCreated;

  /// No description provided for @bellaActionFailed.
  ///
  /// In de, this message translates to:
  /// **'Erstellen fehlgeschlagen'**
  String get bellaActionFailed;

  /// No description provided for @bellaArztBriefing.
  ///
  /// In de, this message translates to:
  /// **'Bella Arzt-Briefing'**
  String get bellaArztBriefing;

  /// No description provided for @bellaAskDirectly.
  ///
  /// In de, this message translates to:
  /// **'Oder stelle direkt eine Frage:'**
  String get bellaAskDirectly;

  /// No description provided for @bellaBriefingGenerating.
  ///
  /// In de, this message translates to:
  /// **'Bella erstellt dein Arzt-Briefing…'**
  String get bellaBriefingGenerating;

  /// No description provided for @bellaBriefingIsProFeature.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Briefing ist eine Pro-Funktion'**
  String get bellaBriefingIsProFeature;

  /// No description provided for @bellaBriefingNotSignedIn.
  ///
  /// In de, this message translates to:
  /// **'Bitte anmelden.'**
  String get bellaBriefingNotSignedIn;

  /// No description provided for @bellaBriefingPersonalTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein persönliches Arzt-Briefing'**
  String get bellaBriefingPersonalTitle;

  /// No description provided for @bellaBriefingProDescription.
  ///
  /// In de, this message translates to:
  /// **'Mit Pro erstellt Bella eine persönliche Zusammenfassung für deinen nächsten Arzttermin.'**
  String get bellaBriefingProDescription;

  /// No description provided for @bellaChipAddTask.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe hinzufügen: Wunde prüfen'**
  String get bellaChipAddTask;

  /// No description provided for @bellaChipAppFunctions.
  ///
  /// In de, this message translates to:
  /// **'Welche App-Funktionen gibt es?'**
  String get bellaChipAppFunctions;

  /// No description provided for @bellaChipCallDoctor.
  ///
  /// In de, this message translates to:
  /// **'Wann sollte ich den Arzt anrufen?'**
  String get bellaChipCallDoctor;

  /// No description provided for @bellaChipCreateAppointment.
  ///
  /// In de, this message translates to:
  /// **'Einen Termin für morgen um 10 Uhr erstellen'**
  String get bellaChipCreateAppointment;

  /// No description provided for @bellaChipDoctorDashboard.
  ///
  /// In de, this message translates to:
  /// **'Wie funktioniert das Arzt-Dashboard?'**
  String get bellaChipDoctorDashboard;

  /// No description provided for @bellaChipDoctorReport.
  ///
  /// In de, this message translates to:
  /// **'Wie erstelle ich einen Arztbericht?'**
  String get bellaChipDoctorReport;

  /// No description provided for @bellaChipGeneralDashboard.
  ///
  /// In de, this message translates to:
  /// **'Wie funktioniert das Dashboard?'**
  String get bellaChipGeneralDashboard;

  /// No description provided for @bellaChipKneeTep.
  ///
  /// In de, this message translates to:
  /// **'Info zur Knie-TEP'**
  String get bellaChipKneeTep;

  /// No description provided for @bellaChipLinkPatient.
  ///
  /// In de, this message translates to:
  /// **'Wie verknüpfe ich einen Patienten?'**
  String get bellaChipLinkPatient;

  /// No description provided for @bellaChipLogBloodPressure.
  ///
  /// In de, this message translates to:
  /// **'Blutdruck 120/80 erfassen'**
  String get bellaChipLogBloodPressure;

  /// No description provided for @bellaChipLogMedication.
  ///
  /// In de, this message translates to:
  /// **'Ich habe gerade Ibuprofen genommen'**
  String get bellaChipLogMedication;

  /// No description provided for @bellaChipLogPain.
  ///
  /// In de, this message translates to:
  /// **'Schmerzen erfassen: Knie, Stufe 4'**
  String get bellaChipLogPain;

  /// No description provided for @bellaChipMedications.
  ///
  /// In de, this message translates to:
  /// **'Wie dokumentiere ich meine Medikamente?'**
  String get bellaChipMedications;

  /// No description provided for @bellaChipMyTasks.
  ///
  /// In de, this message translates to:
  /// **'Was sind meine Aufgaben?'**
  String get bellaChipMyTasks;

  /// No description provided for @bellaChipOpDay.
  ///
  /// In de, this message translates to:
  /// **'Was passiert am OP-Tag?'**
  String get bellaChipOpDay;

  /// No description provided for @bellaChipPrepareOp.
  ///
  /// In de, this message translates to:
  /// **'Wie bereite ich mich auf die OP vor?'**
  String get bellaChipPrepareOp;

  /// No description provided for @bellaChipSymptomCheck.
  ///
  /// In de, this message translates to:
  /// **'Symptom-Check starten'**
  String get bellaChipSymptomCheck;

  /// No description provided for @bellaChipTimeline.
  ///
  /// In de, this message translates to:
  /// **'Wie funktioniert die Timeline?'**
  String get bellaChipTimeline;

  /// No description provided for @bellaChipVerifyAccount.
  ///
  /// In de, this message translates to:
  /// **'Wie verifiziere ich mein Arzt-Konto?'**
  String get bellaChipVerifyAccount;

  /// No description provided for @bellaChipViewPatientData.
  ///
  /// In de, this message translates to:
  /// **'Wie sehe ich Patientendaten?'**
  String get bellaChipViewPatientData;

  /// No description provided for @bellaChipViewPatientDataStaff.
  ///
  /// In de, this message translates to:
  /// **'Wie sehe ich Patientendaten?'**
  String get bellaChipViewPatientDataStaff;

  /// No description provided for @bellaConsentAccepted.
  ///
  /// In de, this message translates to:
  /// **'Zustimmung erteilt'**
  String get bellaConsentAccepted;

  /// No description provided for @bellaConsentBody.
  ///
  /// In de, this message translates to:
  /// **'Der KI-Assistent (Bella AI) nutzt einen externen Dienst (NVIDIA Corporation, USA), um deine Fragen zu beantworten. Mit deiner Zustimmung werden deine Eingaben an diesen Dienst übertragen. Keine persönlichen Gesundheitsdaten werden dauerhaft gespeichert.'**
  String get bellaConsentBody;

  /// No description provided for @bellaConsentDeclined.
  ///
  /// In de, this message translates to:
  /// **'Zustimmung abgelehnt'**
  String get bellaConsentDeclined;

  /// No description provided for @bellaConsentTitle.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzhinweis'**
  String get bellaConsentTitle;

  /// No description provided for @bellaConsentYes.
  ///
  /// In de, this message translates to:
  /// **'Ja, ich stimme zu'**
  String get bellaConsentYes;

  /// No description provided for @bellaDailyAnalysis.
  ///
  /// In de, this message translates to:
  /// **'Bella Tagesanalyse'**
  String get bellaDailyAnalysis;

  /// No description provided for @bellaDefaultWoundPrompt.
  ///
  /// In de, this message translates to:
  /// **'Bitte analysiere dieses Wundfoto.'**
  String get bellaDefaultWoundPrompt;

  /// No description provided for @bellaDescriptionDoctor.
  ///
  /// In de, this message translates to:
  /// **'Ich helfe dir beim Arzt-Dashboard, der Patientenverwaltung und bei klinischen Fragen.'**
  String get bellaDescriptionDoctor;

  /// No description provided for @bellaDescriptionPatient.
  ///
  /// In de, this message translates to:
  /// **'Ich beantworte deine Fragen zu deiner OP, der Nachsorge und der App.'**
  String get bellaDescriptionPatient;

  /// No description provided for @bellaDescriptionStaff.
  ///
  /// In de, this message translates to:
  /// **'Ich helfe dir beim Mitarbeiter-Dashboard und der Patientenbetreuung.'**
  String get bellaDescriptionStaff;

  /// No description provided for @bellaDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Kein medizinischer Rat – bei Beschwerden bitte einen Arzt aufsuchen.'**
  String get bellaDisclaimer;

  /// No description provided for @bellaFeatureAftercare.
  ///
  /// In de, this message translates to:
  /// **'Nachsorge'**
  String get bellaFeatureAftercare;

  /// No description provided for @bellaFeatureAppHelp.
  ///
  /// In de, this message translates to:
  /// **'App-Hilfe'**
  String get bellaFeatureAppHelp;

  /// No description provided for @bellaFeatureDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get bellaFeatureDashboard;

  /// No description provided for @bellaFeatureMedicalKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Medizinisches Wissen'**
  String get bellaFeatureMedicalKnowledge;

  /// No description provided for @bellaFeaturePatients.
  ///
  /// In de, this message translates to:
  /// **'Patienten'**
  String get bellaFeaturePatients;

  /// No description provided for @bellaFeatureTasks.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben'**
  String get bellaFeatureTasks;

  /// No description provided for @bellaFeatureWarnings.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen'**
  String get bellaFeatureWarnings;

  /// No description provided for @bellaGreeting.
  ///
  /// In de, this message translates to:
  /// **'Hallo! Ich bin Bella AI 🐰'**
  String get bellaGreeting;

  /// No description provided for @bellaNoAnswerReceived.
  ///
  /// In de, this message translates to:
  /// **'Keine Antwort erhalten. Bitte erneut versuchen. 🐰'**
  String get bellaNoAnswerReceived;

  /// No description provided for @bellaProactivePainTrend.
  ///
  /// In de, this message translates to:
  /// **'Dein Schmerzniveau steigt – möchtest du darüber sprechen?'**
  String get bellaProactivePainTrend;

  /// No description provided for @bellaProUpgrade.
  ///
  /// In de, this message translates to:
  /// **'Jetzt auf Pro upgraden'**
  String get bellaProUpgrade;

  /// No description provided for @bellaSays.
  ///
  /// In de, this message translates to:
  /// **'Bella sagt:'**
  String get bellaSays;

  /// No description provided for @bellaSubtitleDoctor.
  ///
  /// In de, this message translates to:
  /// **'Dein klinischer Assistent 🐰'**
  String get bellaSubtitleDoctor;

  /// No description provided for @bellaSubtitlePatient.
  ///
  /// In de, this message translates to:
  /// **'Dein OP-Begleiter 🐰'**
  String get bellaSubtitlePatient;

  /// No description provided for @bellaSubtitleStaff.
  ///
  /// In de, this message translates to:
  /// **'Dein Praxis-Assistent 🐰'**
  String get bellaSubtitleStaff;

  /// No description provided for @bellaWoundAnalysisTitle.
  ///
  /// In de, this message translates to:
  /// **'Wundanalyse'**
  String get bellaWoundAnalysisTitle;

  /// No description provided for @bellaWoundDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Kein Ersatz für eine medizinische Diagnose. Im Zweifel das medizinische Team kontaktieren.'**
  String get bellaWoundDisclaimer;

  /// No description provided for @bellaWoundObservations.
  ///
  /// In de, this message translates to:
  /// **'Beobachtungen'**
  String get bellaWoundObservations;

  /// No description provided for @bellaWoundProgressComparison.
  ///
  /// In de, this message translates to:
  /// **'Wundverlauf-Vergleich'**
  String get bellaWoundProgressComparison;

  /// No description provided for @beobachtenSieDieSymptomeGenau.
  ///
  /// In de, this message translates to:
  /// **'Beobachten Sie die Symptome genau'**
  String get beobachtenSieDieSymptomeGenau;

  /// No description provided for @beobachtungHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung hinzufügen'**
  String get beobachtungHinzufuegen;

  /// No description provided for @beschreibeAnliegen.
  ///
  /// In de, this message translates to:
  /// **'Beschreibe dein Anliegen so genau wie möglich…'**
  String get beschreibeAnliegen;

  /// No description provided for @beschreibenSieIhreSymptome.
  ///
  /// In de, this message translates to:
  /// **'Beschreiben Sie Ihre Symptome'**
  String get beschreibenSieIhreSymptome;

  /// No description provided for @besterPreisProMonat.
  ///
  /// In de, this message translates to:
  /// **'Bester Preis pro Monat'**
  String get besterPreisProMonat;

  /// No description provided for @broadcastSenden.
  ///
  /// In de, this message translates to:
  /// **'Broadcast senden'**
  String get broadcastSenden;

  /// No description provided for @calendarAddedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Termin zum Kalender hinzugefügt'**
  String get calendarAddedSuccess;

  /// No description provided for @calendarAddToCalendarBody.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diesen Termin zu deinem Gerätekalender hinzufügen oder als .ics-Datei teilen?'**
  String get calendarAddToCalendarBody;

  /// No description provided for @calendarExportFailed.
  ///
  /// In de, this message translates to:
  /// **'Kalenderexport fehlgeschlagen'**
  String get calendarExportFailed;

  /// No description provided for @calendarMonth.
  ///
  /// In de, this message translates to:
  /// **'Monat'**
  String get calendarMonth;

  /// No description provided for @calendarNoEvents.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine an diesem Tag'**
  String get calendarNoEvents;

  /// No description provided for @calendarTitle.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get calendarTitle;

  /// No description provided for @calendarWeek.
  ///
  /// In de, this message translates to:
  /// **'Woche'**
  String get calendarWeek;

  /// No description provided for @chronologischDokumentierteEinnahmen.
  ///
  /// In de, this message translates to:
  /// **'Chronologisch dokumentierte Einnahmen.'**
  String get chronologischDokumentierteEinnahmen;

  /// No description provided for @codeZumManuellenEingeben.
  ///
  /// In de, this message translates to:
  /// **'Code zum manuellen Eingeben'**
  String get codeZumManuellenEingeben;

  /// No description provided for @csvExportieren.
  ///
  /// In de, this message translates to:
  /// **'CSV exportieren'**
  String get csvExportieren;

  /// No description provided for @dashboardPushSenden.
  ///
  /// In de, this message translates to:
  /// **'Push senden'**
  String get dashboardPushSenden;

  /// No description provided for @dauer.
  ///
  /// In de, this message translates to:
  /// **'Ø Dauer'**
  String get dauer;

  /// No description provided for @deepLink.
  ///
  /// In de, this message translates to:
  /// **'Deep Link'**
  String get deepLink;

  /// No description provided for @discoverSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Funktionen auf einen Blick'**
  String get discoverSubtitle;

  /// No description provided for @discoverTitle.
  ///
  /// In de, this message translates to:
  /// **'Entdecken'**
  String get discoverTitle;

  /// No description provided for @doctorProfileMeinProfil.
  ///
  /// In de, this message translates to:
  /// **'Mein Profil'**
  String get doctorProfileMeinProfil;

  /// No description provided for @doctorReportSchmerztagebuchLetzte7Tage.
  ///
  /// In de, this message translates to:
  /// **'Schmerztagebuch letzte 7 Tage'**
  String get doctorReportSchmerztagebuchLetzte7Tage;

  /// No description provided for @doctorReportWunddokuLetzte3.
  ///
  /// In de, this message translates to:
  /// **'Wunddoku letzte 3'**
  String get doctorReportWunddokuLetzte3;

  /// No description provided for @doctorStatsCardSchmerzlevel.
  ///
  /// In de, this message translates to:
  /// **'Ø Schmerzlevel'**
  String get doctorStatsCardSchmerzlevel;

  /// No description provided for @dokumenteLetzte3.
  ///
  /// In de, this message translates to:
  /// **'Dokumente letzte 3'**
  String get dokumenteLetzte3;

  /// No description provided for @dokumenteOeffnenTeilen.
  ///
  /// In de, this message translates to:
  /// **'Öffnen / Teilen'**
  String get dokumenteOeffnenTeilen;

  /// No description provided for @dokumentiereWundenUnterWunddoku.
  ///
  /// In de, this message translates to:
  /// **'Dokumentiere Wunden unter Wunddoku'**
  String get dokumentiereWundenUnterWunddoku;

  /// No description provided for @einladungscode.
  ///
  /// In de, this message translates to:
  /// **'Einladungscode'**
  String get einladungscode;

  /// No description provided for @einladungTeilen.
  ///
  /// In de, this message translates to:
  /// **'Einladung teilen'**
  String get einladungTeilen;

  /// No description provided for @erfasseMedikamenteImMedikamentenplan.
  ///
  /// In de, this message translates to:
  /// **'Erfasse Medikamente im Medikamentenplan'**
  String get erfasseMedikamenteImMedikamentenplan;

  /// No description provided for @erfasseSchmerzwerteImSchmerztagebuch.
  ///
  /// In de, this message translates to:
  /// **'Erfasse Schmerzwerte im Schmerztagebuch'**
  String get erfasseSchmerzwerteImSchmerztagebuch;

  /// No description provided for @erfasseVitalwerteUnterVitals.
  ///
  /// In de, this message translates to:
  /// **'Erfasse Vitalwerte unter Vitaldaten'**
  String get erfasseVitalwerteUnterVitals;

  /// No description provided for @erinnerungErstellen.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung erstellen'**
  String get erinnerungErstellen;

  /// No description provided for @erneutPruefen.
  ///
  /// In de, this message translates to:
  /// **'Erneut prüfen'**
  String get erneutPruefen;

  /// No description provided for @errorAlreadyExists.
  ///
  /// In de, this message translates to:
  /// **'Bereits vorhanden.'**
  String get errorAlreadyExists;

  /// No description provided for @errorCancelled.
  ///
  /// In de, this message translates to:
  /// **'Vorgang abgebrochen.'**
  String get errorCancelled;

  /// No description provided for @errorDeadlineExceeded.
  ///
  /// In de, this message translates to:
  /// **'Zeitüberschreitung. Bitte erneut versuchen.'**
  String get errorDeadlineExceeded;

  /// No description provided for @errorEmailInUse.
  ///
  /// In de, this message translates to:
  /// **'Diese E-Mail-Adresse wird bereits verwendet.'**
  String get errorEmailInUse;

  /// No description provided for @errorFailedPrecondition.
  ///
  /// In de, this message translates to:
  /// **'Aktion kann nicht durchgeführt werden.'**
  String get errorFailedPrecondition;

  /// No description provided for @errorInvalidArgument.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Eingabe.'**
  String get errorInvalidArgument;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail-Adresse.'**
  String get errorInvalidEmail;

  /// No description provided for @errorNoInternet.
  ///
  /// In de, this message translates to:
  /// **'Keine Internetverbindung. Bitte Netzwerk prüfen.'**
  String get errorNoInternet;

  /// No description provided for @errorNotFound.
  ///
  /// In de, this message translates to:
  /// **'Nicht gefunden. Bitte Eingabe prüfen.'**
  String get errorNotFound;

  /// No description provided for @errorNotFoundShort.
  ///
  /// In de, this message translates to:
  /// **'Nicht gefunden.'**
  String get errorNotFoundShort;

  /// No description provided for @errorOperationNotAllowed.
  ///
  /// In de, this message translates to:
  /// **'Diese Aktion ist nicht erlaubt.'**
  String get errorOperationNotAllowed;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In de, this message translates to:
  /// **'Keine Berechtigung für diese Aktion.'**
  String get errorPermissionDenied;

  /// No description provided for @errorPleaseSignIn.
  ///
  /// In de, this message translates to:
  /// **'Bitte anmelden.'**
  String get errorPleaseSignIn;

  /// No description provided for @errorRequiresRecentLogin.
  ///
  /// In de, this message translates to:
  /// **'Bitte erneut anmelden, um fortzufahren.'**
  String get errorRequiresRecentLogin;

  /// No description provided for @errorResourceExhausted.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Anfragen. Bitte einen Moment warten.'**
  String get errorResourceExhausted;

  /// No description provided for @errorServiceUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Der Dienst ist vorübergehend nicht verfügbar. Bitte später erneut versuchen.'**
  String get errorServiceUnavailable;

  /// No description provided for @errorServiceUnavailableShort.
  ///
  /// In de, this message translates to:
  /// **'Der Dienst ist vorübergehend nicht verfügbar.'**
  String get errorServiceUnavailableShort;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Versuche. Bitte später erneut versuchen.'**
  String get errorTooManyRequests;

  /// No description provided for @errorUserDisabled.
  ///
  /// In de, this message translates to:
  /// **'Dieses Konto wurde deaktiviert.'**
  String get errorUserDisabled;

  /// No description provided for @errorUserNotFound.
  ///
  /// In de, this message translates to:
  /// **'Kein Konto mit dieser E-Mail-Adresse gefunden.'**
  String get errorUserNotFound;

  /// No description provided for @errorWeakPassword.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort ist zu schwach.'**
  String get errorWeakPassword;

  /// No description provided for @errorWrongPassword.
  ///
  /// In de, this message translates to:
  /// **'Falsches Passwort.'**
  String get errorWrongPassword;

  /// No description provided for @ersteListeErstellen.
  ///
  /// In de, this message translates to:
  /// **'Erste Liste erstellen'**
  String get ersteListeErstellen;

  /// No description provided for @erstelltAm.
  ///
  /// In de, this message translates to:
  /// **'Erstellt am'**
  String get erstelltAm;

  /// No description provided for @ersteNotizErstellen.
  ///
  /// In de, this message translates to:
  /// **'Erste Notiz erstellen'**
  String get ersteNotizErstellen;

  /// No description provided for @erstesItemHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Erstes Item hinzufügen'**
  String get erstesItemHinzufuegen;

  /// No description provided for @ersteVorlageErstellen.
  ///
  /// In de, this message translates to:
  /// **'Erste Vorlage erstellen'**
  String get ersteVorlageErstellen;

  /// No description provided for @esIstEinFehlerAufgetretenBitteVersucheEsErneut.
  ///
  /// In de, this message translates to:
  /// **'Es ist ein Fehler aufgetreten. Bitte versuche es erneut.'**
  String get esIstEinFehlerAufgetretenBitteVersucheEsErneut;

  /// No description provided for @exportFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Export fehlgeschlagen.'**
  String get exportFehlgeschlagen;

  /// No description provided for @familyMemberHubZBA1B2C3D4E5F6.
  ///
  /// In de, this message translates to:
  /// **'z.B. A1B2C3D4E5F6'**
  String get familyMemberHubZBA1B2C3D4E5F6;

  /// No description provided for @familyPatientsMeinePatienten.
  ///
  /// In de, this message translates to:
  /// **'Meine Patienten'**
  String get familyPatientsMeinePatienten;

  /// No description provided for @familyPatientsZBA1B2C3D4E5F6.
  ///
  /// In de, this message translates to:
  /// **'z.B. A1B2C3D4E5F6'**
  String get familyPatientsZBA1B2C3D4E5F6;

  /// No description provided for @familyProfileZBA1B2C3D4E5F6.
  ///
  /// In de, this message translates to:
  /// **'z.B. A1B2C3D4E5F6'**
  String get familyProfileZBA1B2C3D4E5F6;

  /// No description provided for @fehlerBeimErstellen.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Erstellen.'**
  String get fehlerBeimErstellen;

  /// No description provided for @firebaseUIDDesArztes.
  ///
  /// In de, this message translates to:
  /// **'Firebase UID des Arztes'**
  String get firebaseUIDDesArztes;

  /// No description provided for @footerLoveMessage.
  ///
  /// In de, this message translates to:
  /// **'Mit Liebe für deine Genesung entwickelt'**
  String get footerLoveMessage;

  /// No description provided for @fotosDurchsuchen.
  ///
  /// In de, this message translates to:
  /// **'Fotos suchen (Datum, Notiz, Kategorie)…'**
  String get fotosDurchsuchen;

  /// No description provided for @frageAnBella.
  ///
  /// In de, this message translates to:
  /// **'Frage an Bella …'**
  String get frageAnBella;

  /// No description provided for @frageBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Frage bearbeiten'**
  String get frageBearbeiten;

  /// No description provided for @frageStellen.
  ///
  /// In de, this message translates to:
  /// **'Frage stellen …'**
  String get frageStellen;

  /// No description provided for @freischalten.
  ///
  /// In de, this message translates to:
  /// **'Freischalten'**
  String get freischalten;

  /// No description provided for @funktionenErklaert.
  ///
  /// In de, this message translates to:
  /// **'Funktionen erklärt'**
  String get funktionenErklaert;

  /// No description provided for @grundDerSperrung.
  ///
  /// In de, this message translates to:
  /// **'Grund der Sperrung…'**
  String get grundDerSperrung;

  /// No description provided for @grundEingeben.
  ///
  /// In de, this message translates to:
  /// **'Grund eingeben…'**
  String get grundEingeben;

  /// No description provided for @grundOptional.
  ///
  /// In de, this message translates to:
  /// **'Grund (optional)'**
  String get grundOptional;

  /// No description provided for @helpHilfeUndSupport.
  ///
  /// In de, this message translates to:
  /// **'Hilfe & Support'**
  String get helpHilfeUndSupport;

  /// No description provided for @heuteDokumentiert.
  ///
  /// In de, this message translates to:
  /// **'Heute dokumentiert'**
  String get heuteDokumentiert;

  /// No description provided for @hilfeUndSupport.
  ///
  /// In de, this message translates to:
  /// **'Hilfe & Support'**
  String get hilfeUndSupport;

  /// No description provided for @hinterlegeDeineOPDetailsImProfil.
  ///
  /// In de, this message translates to:
  /// **'Hinterlege deine OP-Details im Profil'**
  String get hinterlegeDeineOPDetailsImProfil;

  /// No description provided for @hinweistextOptional.
  ///
  /// In de, this message translates to:
  /// **'Hinweistext (optional)'**
  String get hinweistextOptional;

  /// No description provided for @homeSummaryCardFaellig.
  ///
  /// In de, this message translates to:
  /// **'fällig'**
  String get homeSummaryCardFaellig;

  /// No description provided for @ihreAntwortEingeben.
  ///
  /// In de, this message translates to:
  /// **'Antwort eingeben…'**
  String get ihreAntwortEingeben;

  /// No description provided for @inaktiv3Tage.
  ///
  /// In de, this message translates to:
  /// **'Inaktiv >3 Tage'**
  String get inaktiv3Tage;

  /// No description provided for @itemBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Item bearbeiten'**
  String get itemBearbeiten;

  /// No description provided for @jaehrlich.
  ///
  /// In de, this message translates to:
  /// **'Jährlich'**
  String get jaehrlich;

  /// No description provided for @jederzeitNkuendbar.
  ///
  /// In de, this message translates to:
  /// **'Jederzeit\\nkündbar'**
  String get jederzeitNkuendbar;

  /// No description provided for @keineAufgabenImPlan.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Aufgaben im Plan.'**
  String get keineAufgabenImPlan;

  /// No description provided for @keineEmailApp.
  ///
  /// In de, this message translates to:
  /// **'Keine E-Mail-App gefunden'**
  String get keineEmailApp;

  /// No description provided for @keineOffenenEinladungen.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Einladungen.'**
  String get keineOffenenEinladungen;

  /// No description provided for @keinUebernachtenNurDasNoetigste.
  ///
  /// In de, this message translates to:
  /// **'Kein Übernachten – nur das Nötigste'**
  String get keinUebernachtenNurDasNoetigste;

  /// No description provided for @keyIdOderUidSuchen.
  ///
  /// In de, this message translates to:
  /// **'Key-ID oder Einlöser-UID suchen…'**
  String get keyIdOderUidSuchen;

  /// No description provided for @kontaktierenSieIhrenArzt.
  ///
  /// In de, this message translates to:
  /// **'Kontaktieren Sie Ihren Arzt'**
  String get kontaktierenSieIhrenArzt;

  /// No description provided for @kVNummerOptional.
  ///
  /// In de, this message translates to:
  /// **'KV-Nummer (optional)'**
  String get kVNummerOptional;

  /// No description provided for @letzteDokumente.
  ///
  /// In de, this message translates to:
  /// **'Letzte Dokumente'**
  String get letzteDokumente;

  /// No description provided for @letzteEinnahmen.
  ///
  /// In de, this message translates to:
  /// **'Letzte Einnahmen'**
  String get letzteEinnahmen;

  /// No description provided for @letzteVitalwerte.
  ///
  /// In de, this message translates to:
  /// **'Letzte Vitalwerte'**
  String get letzteVitalwerte;

  /// No description provided for @linkKopieren.
  ///
  /// In de, this message translates to:
  /// **'Link kopieren'**
  String get linkKopieren;

  /// No description provided for @losGehts.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s!'**
  String get losGehts;

  /// No description provided for @medikament.
  ///
  /// In de, this message translates to:
  /// **'Medikament *'**
  String get medikament;

  /// No description provided for @meilensteineUndZiele.
  ///
  /// In de, this message translates to:
  /// **'Meilensteine & Ziele'**
  String get meilensteineUndZiele;

  /// No description provided for @meinProfil.
  ///
  /// In de, this message translates to:
  /// **'Mein Profil'**
  String get meinProfil;

  /// No description provided for @memosDurchsuchen.
  ///
  /// In de, this message translates to:
  /// **'Memos durchsuchen…'**
  String get memosDurchsuchen;

  /// No description provided for @mitArztVerbinden.
  ///
  /// In de, this message translates to:
  /// **'Mit Arzt verbinden'**
  String get mitArztVerbinden;

  /// No description provided for @mitMedikation.
  ///
  /// In de, this message translates to:
  /// **'Mit Medikation'**
  String get mitMedikation;

  /// No description provided for @mitUebernachtungVollstaendigeListe.
  ///
  /// In de, this message translates to:
  /// **'Mit Übernachtung – vollständige Liste'**
  String get mitUebernachtungVollstaendigeListe;

  /// No description provided for @monatlichKuendbar.
  ///
  /// In de, this message translates to:
  /// **'monatlich kündbar'**
  String get monatlichKuendbar;

  /// No description provided for @monthApril.
  ///
  /// In de, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthAugust.
  ///
  /// In de, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthDecember.
  ///
  /// In de, this message translates to:
  /// **'Dezember'**
  String get monthDecember;

  /// No description provided for @monthFebruary.
  ///
  /// In de, this message translates to:
  /// **'Februar'**
  String get monthFebruary;

  /// No description provided for @monthJanuary.
  ///
  /// In de, this message translates to:
  /// **'Januar'**
  String get monthJanuary;

  /// No description provided for @monthJuly.
  ///
  /// In de, this message translates to:
  /// **'Juli'**
  String get monthJuly;

  /// No description provided for @monthJune.
  ///
  /// In de, this message translates to:
  /// **'Juni'**
  String get monthJune;

  /// No description provided for @monthMarch.
  ///
  /// In de, this message translates to:
  /// **'März'**
  String get monthMarch;

  /// No description provided for @monthMay.
  ///
  /// In de, this message translates to:
  /// **'Mai'**
  String get monthMay;

  /// No description provided for @monthNovember.
  ///
  /// In de, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthOctober.
  ///
  /// In de, this message translates to:
  /// **'Oktober'**
  String get monthOctober;

  /// No description provided for @monthSeptember.
  ///
  /// In de, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @n7TageTreue.
  ///
  /// In de, this message translates to:
  /// **'7-Tage Treue'**
  String get n7TageTreue;

  /// No description provided for @nachrichtSchreiben.
  ///
  /// In de, this message translates to:
  /// **'Nachricht schreiben...'**
  String get nachrichtSchreiben;

  /// No description provided for @nachRolleFiltern.
  ///
  /// In de, this message translates to:
  /// **'Nach Rolle filtern'**
  String get nachRolleFiltern;

  /// No description provided for @naechsteTermine.
  ///
  /// In de, this message translates to:
  /// **'Nächste Termine'**
  String get naechsteTermine;

  /// No description provided for @neuerKey.
  ///
  /// In de, this message translates to:
  /// **'Neuer Key'**
  String get neuerKey;

  /// No description provided for @neuerName.
  ///
  /// In de, this message translates to:
  /// **'Neuer Name'**
  String get neuerName;

  /// No description provided for @neuesPacklistenItem.
  ///
  /// In de, this message translates to:
  /// **'Neues Packlisten-Item'**
  String get neuesPacklistenItem;

  /// No description provided for @neuesPasswort.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort'**
  String get neuesPasswort;

  /// No description provided for @nochKeineAngehoerigenVerbunden.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Angehörigen verbunden.'**
  String get nochKeineAngehoerigenVerbunden;

  /// No description provided for @nochKeineBeobachtungen.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Beobachtungen.'**
  String get nochKeineBeobachtungen;

  /// No description provided for @nochKeineDokumentation.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Dokumentation'**
  String get nochKeineDokumentation;

  /// No description provided for @notaufnahmeAufsuchen.
  ///
  /// In de, this message translates to:
  /// **'Notaufnahme aufsuchen'**
  String get notaufnahmeAufsuchen;

  /// No description provided for @notificationCenterNotizOptional.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get notificationCenterNotizOptional;

  /// No description provided for @notruf112Anrufen.
  ///
  /// In de, this message translates to:
  /// **'Notruf 112 anrufen'**
  String get notruf112Anrufen;

  /// No description provided for @nurInDebugBuilds.
  ///
  /// In de, this message translates to:
  /// **'Nur in Debug-Builds verfügbar.'**
  String get nurInDebugBuilds;

  /// No description provided for @nurVomArztVerwaltbar.
  ///
  /// In de, this message translates to:
  /// **'Nur vom Arzt verwaltbar'**
  String get nurVomArztVerwaltbar;

  /// No description provided for @nutzerGesamt.
  ///
  /// In de, this message translates to:
  /// **'Nutzer gesamt'**
  String get nutzerGesamt;

  /// No description provided for @oeffnenTeilen.
  ///
  /// In de, this message translates to:
  /// **'Öffnen / Teilen'**
  String get oeffnenTeilen;

  /// No description provided for @offeneFragen.
  ///
  /// In de, this message translates to:
  /// **'Offene Fragen'**
  String get offeneFragen;

  /// No description provided for @offeneRedFlags.
  ///
  /// In de, this message translates to:
  /// **'Offene Warnsignale'**
  String get offeneRedFlags;

  /// No description provided for @ohneMedikation.
  ///
  /// In de, this message translates to:
  /// **'Ohne Medikation'**
  String get ohneMedikation;

  /// No description provided for @opActions.
  ///
  /// In de, this message translates to:
  /// **'Aktionen'**
  String get opActions;

  /// No description provided for @oPDatum.
  ///
  /// In de, this message translates to:
  /// **'OP Datum'**
  String get oPDatum;

  /// No description provided for @opDetails.
  ///
  /// In de, this message translates to:
  /// **'OP-Details'**
  String get opDetails;

  /// No description provided for @opDocumentsLabel.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get opDocumentsLabel;

  /// No description provided for @opManageCaregivers.
  ///
  /// In de, this message translates to:
  /// **'Begleiter\nverwalten'**
  String get opManageCaregivers;

  /// No description provided for @opName.
  ///
  /// In de, this message translates to:
  /// **'OP-Name'**
  String get opName;

  /// No description provided for @opSymptomsLabel.
  ///
  /// In de, this message translates to:
  /// **'Symptome'**
  String get opSymptomsLabel;

  /// No description provided for @opTimeline.
  ///
  /// In de, this message translates to:
  /// **'Timeline'**
  String get opTimeline;

  /// No description provided for @opType.
  ///
  /// In de, this message translates to:
  /// **'OP-Typ'**
  String get opType;

  /// No description provided for @oPUndTimeline.
  ///
  /// In de, this message translates to:
  /// **'OP & Timeline'**
  String get oPUndTimeline;

  /// No description provided for @packingItemEditorSheetNotizOptional.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get packingItemEditorSheetNotizOptional;

  /// No description provided for @patientAuswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Patient auswählen'**
  String get patientAuswaehlen;

  /// No description provided for @patientBasisdaten.
  ///
  /// In de, this message translates to:
  /// **'Patient Basisdaten'**
  String get patientBasisdaten;

  /// No description provided for @patientenBegleiten.
  ///
  /// In de, this message translates to:
  /// **'Patienten begleiten'**
  String get patientenBegleiten;

  /// No description provided for @perEMail.
  ///
  /// In de, this message translates to:
  /// **'Per E-Mail'**
  String get perEMail;

  /// No description provided for @placeholderLoading.
  ///
  /// In de, this message translates to:
  /// **'Wird geladen…'**
  String get placeholderLoading;

  /// No description provided for @praxisnameOptional.
  ///
  /// In de, this message translates to:
  /// **'Praxisname (optional)'**
  String get praxisnameOptional;

  /// No description provided for @prioritaet.
  ///
  /// In de, this message translates to:
  /// **'Priorität'**
  String get prioritaet;

  /// No description provided for @profilGespeichert.
  ///
  /// In de, this message translates to:
  /// **'Profil gespeichert.'**
  String get profilGespeichert;

  /// No description provided for @proKeyErstellen.
  ///
  /// In de, this message translates to:
  /// **'Pro-Key erstellen'**
  String get proKeyErstellen;

  /// No description provided for @proSatz.
  ///
  /// In de, this message translates to:
  /// **'pro Satz'**
  String get proSatz;

  /// No description provided for @proStatus.
  ///
  /// In de, this message translates to:
  /// **'Pro Status'**
  String get proStatus;

  /// No description provided for @pushBenachrichtigungenVersenden.
  ///
  /// In de, this message translates to:
  /// **'Push-Benachrichtigungen versenden'**
  String get pushBenachrichtigungenVersenden;

  /// No description provided for @pushPushSenden.
  ///
  /// In de, this message translates to:
  /// **'Push senden?'**
  String get pushPushSenden;

  /// No description provided for @pushSenden.
  ///
  /// In de, this message translates to:
  /// **'Push'**
  String get pushSenden;

  /// No description provided for @recoveryFeed.
  ///
  /// In de, this message translates to:
  /// **'Genesungs-Feed'**
  String get recoveryFeed;

  /// No description provided for @redU2011FlagSystem.
  ///
  /// In de, this message translates to:
  /// **'Red\\u2011Flag System'**
  String get redU2011FlagSystem;

  /// No description provided for @reportSchmerz.
  ///
  /// In de, this message translates to:
  /// **'Schmerz-Ø'**
  String get reportSchmerz;

  /// No description provided for @reportTagePostOP.
  ///
  /// In de, this message translates to:
  /// **'Tage post-OP'**
  String get reportTagePostOP;

  /// No description provided for @rfActiveWarnings.
  ///
  /// In de, this message translates to:
  /// **'Aktive Warnungen'**
  String get rfActiveWarnings;

  /// No description provided for @rfCheckStart.
  ///
  /// In de, this message translates to:
  /// **'Check starten'**
  String get rfCheckStart;

  /// No description provided for @rfEmergencyFollowSteps.
  ///
  /// In de, this message translates to:
  /// **'Befolge diese Schritte der Reihe nach.'**
  String get rfEmergencyFollowSteps;

  /// No description provided for @rfEmergencyInstructions.
  ///
  /// In de, this message translates to:
  /// **'Notfallanweisungen'**
  String get rfEmergencyInstructions;

  /// No description provided for @rfEmergencyStep1Desc.
  ///
  /// In de, this message translates to:
  /// **'Setzen oder hinlegen. Ruhig atmen.'**
  String get rfEmergencyStep1Desc;

  /// No description provided for @rfEmergencyStep1Title.
  ///
  /// In de, this message translates to:
  /// **'Ruhe bewahren'**
  String get rfEmergencyStep1Title;

  /// No description provided for @rfEmergencyStep2Desc.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Beschwerden und deren Schweregrad notieren.'**
  String get rfEmergencyStep2Desc;

  /// No description provided for @rfEmergencyStep2Title.
  ///
  /// In de, this message translates to:
  /// **'Symptome prüfen'**
  String get rfEmergencyStep2Title;

  /// No description provided for @rfEmergencyStep3Desc.
  ///
  /// In de, this message translates to:
  /// **'Arzt oder Klinik anrufen und Symptome beschreiben.'**
  String get rfEmergencyStep3Desc;

  /// No description provided for @rfEmergencyStep3Title.
  ///
  /// In de, this message translates to:
  /// **'Arzt anrufen'**
  String get rfEmergencyStep3Title;

  /// No description provided for @rfEmergencyStep4Desc.
  ///
  /// In de, this message translates to:
  /// **'Bei Atemnot, Bewusstlosigkeit oder starker Blutung sofort 112 anrufen.'**
  String get rfEmergencyStep4Desc;

  /// No description provided for @rfEmergencySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Sofortmaßnahmen bei Atemnot, Bewusstlosigkeit oder starker Blutung.'**
  String get rfEmergencySubtitle;

  /// No description provided for @rfEscalate.
  ///
  /// In de, this message translates to:
  /// **'Eskalieren'**
  String get rfEscalate;

  /// No description provided for @rfNoActiveWarnings.
  ///
  /// In de, this message translates to:
  /// **'Keine aktiven Warnungen. Weiter so!'**
  String get rfNoActiveWarnings;

  /// No description provided for @rfNoFlags.
  ///
  /// In de, this message translates to:
  /// **'Keine Red Flags'**
  String get rfNoFlags;

  /// No description provided for @rfProAutoDetect.
  ///
  /// In de, this message translates to:
  /// **'Mit Pro erkennt das System automatisch kritische Werte aus Schmerzen, Vitaldaten und mehr.'**
  String get rfProAutoDetect;

  /// No description provided for @rfProFeatureSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Beschwerden manuell eingeben oder auf Pro upgraden.'**
  String get rfProFeatureSubtitle;

  /// No description provided for @rfProFeatureTitle.
  ///
  /// In de, this message translates to:
  /// **'Automatische Red-Flag-Erkennung ist eine Pro-Funktion.'**
  String get rfProFeatureTitle;

  /// No description provided for @rfSeverityDescGreen.
  ///
  /// In de, this message translates to:
  /// **'Deine Werte liegen im Normalbereich. Weiter so!'**
  String get rfSeverityDescGreen;

  /// No description provided for @rfSeverityDescOrange.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Werte auffällig. Bald einen Arzt aufsuchen.'**
  String get rfSeverityDescOrange;

  /// No description provided for @rfSeverityDescRed.
  ///
  /// In de, this message translates to:
  /// **'Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.'**
  String get rfSeverityDescRed;

  /// No description provided for @rfSeverityDescYellow.
  ///
  /// In de, this message translates to:
  /// **'Einige Werte leicht außerhalb des Normalbereichs. Bitte beobachten.'**
  String get rfSeverityDescYellow;

  /// No description provided for @rfSeverityOrange.
  ///
  /// In de, this message translates to:
  /// **'Orange'**
  String get rfSeverityOrange;

  /// No description provided for @rfSeverityRed.
  ///
  /// In de, this message translates to:
  /// **'Rot'**
  String get rfSeverityRed;

  /// No description provided for @rfSeverityTitleGreen.
  ///
  /// In de, this message translates to:
  /// **'Alles OK'**
  String get rfSeverityTitleGreen;

  /// No description provided for @rfSeverityTitleOrange.
  ///
  /// In de, this message translates to:
  /// **'Erhöhtes Risiko'**
  String get rfSeverityTitleOrange;

  /// No description provided for @rfSeverityTitleRed.
  ///
  /// In de, this message translates to:
  /// **'Jetzt handeln'**
  String get rfSeverityTitleRed;

  /// No description provided for @rfSeverityTitleYellow.
  ///
  /// In de, this message translates to:
  /// **'Leichte Auffälligkeit'**
  String get rfSeverityTitleYellow;

  /// No description provided for @rfSeverityYellow.
  ///
  /// In de, this message translates to:
  /// **'Gelb'**
  String get rfSeverityYellow;

  /// No description provided for @rfSourceManual.
  ///
  /// In de, this message translates to:
  /// **'Manuell'**
  String get rfSourceManual;

  /// No description provided for @rfSourceObservation.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung'**
  String get rfSourceObservation;

  /// No description provided for @rfSourcePain.
  ///
  /// In de, this message translates to:
  /// **'Schmerzen'**
  String get rfSourcePain;

  /// No description provided for @rfSourceSymptomCheck.
  ///
  /// In de, this message translates to:
  /// **'Symptom-Check'**
  String get rfSourceSymptomCheck;

  /// No description provided for @rfSourceTimeline.
  ///
  /// In de, this message translates to:
  /// **'Timeline-Aufgabe'**
  String get rfSourceTimeline;

  /// No description provided for @rfSourceVitals.
  ///
  /// In de, this message translates to:
  /// **'Vitaldaten'**
  String get rfSourceVitals;

  /// No description provided for @rfSourceWarningCheck.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen-Check'**
  String get rfSourceWarningCheck;

  /// No description provided for @rfSourceWound.
  ///
  /// In de, this message translates to:
  /// **'Wunddaten'**
  String get rfSourceWound;

  /// No description provided for @rfStatusAcknowledged.
  ///
  /// In de, this message translates to:
  /// **'Gesehen'**
  String get rfStatusAcknowledged;

  /// No description provided for @rfStatusEscalated.
  ///
  /// In de, this message translates to:
  /// **'Eskaliert'**
  String get rfStatusEscalated;

  /// No description provided for @rfStatusMonitoring.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung'**
  String get rfStatusMonitoring;

  /// No description provided for @rfStatusOpen.
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get rfStatusOpen;

  /// No description provided for @rfStatusResolved.
  ///
  /// In de, this message translates to:
  /// **'Gelöst'**
  String get rfStatusResolved;

  /// No description provided for @rfWarningCheckSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schnellcheck der wichtigsten Symptome – dauert nur 30 Sekunden.'**
  String get rfWarningCheckSubtitle;

  /// No description provided for @roleDebug.
  ///
  /// In de, this message translates to:
  /// **'Role Debug'**
  String get roleDebug;

  /// No description provided for @rolleAuswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Rolle auswählen'**
  String get rolleAuswaehlen;

  /// No description provided for @scannbarerCodeZumBeitreten.
  ///
  /// In de, this message translates to:
  /// **'Scannbarer Code zum Beitreten'**
  String get scannbarerCodeZumBeitreten;

  /// No description provided for @schalteLevelXPTrackingUndMehrFrei.
  ///
  /// In de, this message translates to:
  /// **'Schalte Level, XP-Tracking und mehr frei'**
  String get schalteLevelXPTrackingUndMehrFrei;

  /// No description provided for @schlaf.
  ///
  /// In de, this message translates to:
  /// **'Ø Schlaf'**
  String get schlaf;

  /// No description provided for @schlafOptional.
  ///
  /// In de, this message translates to:
  /// **'Schlaf (optional)'**
  String get schlafOptional;

  /// No description provided for @schmerz.
  ///
  /// In de, this message translates to:
  /// **'Ø Schmerz'**
  String get schmerz;

  /// No description provided for @schmerztagebuchLetzte7Tage.
  ///
  /// In de, this message translates to:
  /// **'Schmerztagebuch letzte 7 Tage'**
  String get schmerztagebuchLetzte7Tage;

  /// No description provided for @schmerztrend7Tage.
  ///
  /// In de, this message translates to:
  /// **'Schmerztrend (7 Tage)'**
  String get schmerztrend7Tage;

  /// No description provided for @searchHint.
  ///
  /// In de, this message translates to:
  /// **'Suchen…'**
  String get searchHint;

  /// No description provided for @sectionAccompany.
  ///
  /// In de, this message translates to:
  /// **'Begleitung'**
  String get sectionAccompany;

  /// No description provided for @sectionAdsAdmin.
  ///
  /// In de, this message translates to:
  /// **'Ads Admin'**
  String get sectionAdsAdmin;

  /// No description provided for @sectionAnalysis.
  ///
  /// In de, this message translates to:
  /// **'Analyse'**
  String get sectionAnalysis;

  /// No description provided for @sectionAnalytics.
  ///
  /// In de, this message translates to:
  /// **'Analytik'**
  String get sectionAnalytics;

  /// No description provided for @sectionConnectDoctor.
  ///
  /// In de, this message translates to:
  /// **'Arzt verbinden'**
  String get sectionConnectDoctor;

  /// No description provided for @sectionDebugTools.
  ///
  /// In de, this message translates to:
  /// **'Debug Tools'**
  String get sectionDebugTools;

  /// No description provided for @sectionDoctorQuestions.
  ///
  /// In de, this message translates to:
  /// **'Arztfragen'**
  String get sectionDoctorQuestions;

  /// No description provided for @sectionDoctorReport.
  ///
  /// In de, this message translates to:
  /// **'Arztbericht'**
  String get sectionDoctorReport;

  /// No description provided for @sectionDocumentation.
  ///
  /// In de, this message translates to:
  /// **'Dokumentation'**
  String get sectionDocumentation;

  /// No description provided for @sectionDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get sectionDocuments;

  /// No description provided for @sectionEmergencyInfo.
  ///
  /// In de, this message translates to:
  /// **'Notfallinformationen'**
  String get sectionEmergencyInfo;

  /// No description provided for @sectionFirebaseTest.
  ///
  /// In de, this message translates to:
  /// **'Firebase Test'**
  String get sectionFirebaseTest;

  /// No description provided for @sectionHealth.
  ///
  /// In de, this message translates to:
  /// **'Gesundheit'**
  String get sectionHealth;

  /// No description provided for @sectionHealthReport.
  ///
  /// In de, this message translates to:
  /// **'Gesundheitsbericht'**
  String get sectionHealthReport;

  /// No description provided for @sectionHelp.
  ///
  /// In de, this message translates to:
  /// **'Hilfe'**
  String get sectionHelp;

  /// No description provided for @sectionLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get sectionLanguage;

  /// No description provided for @sectionMedication.
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get sectionMedication;

  /// No description provided for @sectionMood.
  ///
  /// In de, this message translates to:
  /// **'Stimmung'**
  String get sectionMood;

  /// No description provided for @sectionNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get sectionNotifications;

  /// No description provided for @sectionNutrition.
  ///
  /// In de, this message translates to:
  /// **'Ernährung'**
  String get sectionNutrition;

  /// No description provided for @sectionOpInfo.
  ///
  /// In de, this message translates to:
  /// **'OP-Informationen'**
  String get sectionOpInfo;

  /// No description provided for @sectionOpPlanning.
  ///
  /// In de, this message translates to:
  /// **'OP & Planung'**
  String get sectionOpPlanning;

  /// No description provided for @sectionPackingList.
  ///
  /// In de, this message translates to:
  /// **'Packliste'**
  String get sectionPackingList;

  /// No description provided for @sectionPain.
  ///
  /// In de, this message translates to:
  /// **'Schmerzen'**
  String get sectionPain;

  /// No description provided for @sectionPeople.
  ///
  /// In de, this message translates to:
  /// **'Personen'**
  String get sectionPeople;

  /// No description provided for @sectionPhotos.
  ///
  /// In de, this message translates to:
  /// **'Fotos'**
  String get sectionPhotos;

  /// No description provided for @sectionProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get sectionProfile;

  /// No description provided for @sectionProgress.
  ///
  /// In de, this message translates to:
  /// **'Fortschritt'**
  String get sectionProgress;

  /// No description provided for @sectionRecentlyUsed.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt genutzt'**
  String get sectionRecentlyUsed;

  /// No description provided for @sectionRedFlags.
  ///
  /// In de, this message translates to:
  /// **'Warnsignale'**
  String get sectionRedFlags;

  /// No description provided for @sectionRehabilitation.
  ///
  /// In de, this message translates to:
  /// **'Rehabilitation'**
  String get sectionRehabilitation;

  /// No description provided for @sectionRoleDebug.
  ///
  /// In de, this message translates to:
  /// **'Role Debug'**
  String get sectionRoleDebug;

  /// No description provided for @sectionSleep.
  ///
  /// In de, this message translates to:
  /// **'Schlaf'**
  String get sectionSleep;

  /// No description provided for @sectionSupplements.
  ///
  /// In de, this message translates to:
  /// **'Supplemente'**
  String get sectionSupplements;

  /// No description provided for @sectionSymptomCheck.
  ///
  /// In de, this message translates to:
  /// **'Symptom-Check'**
  String get sectionSymptomCheck;

  /// No description provided for @sectionVitals.
  ///
  /// In de, this message translates to:
  /// **'Vitaldaten'**
  String get sectionVitals;

  /// No description provided for @sectionVoiceNotes.
  ///
  /// In de, this message translates to:
  /// **'Sprachnotizen'**
  String get sectionVoiceNotes;

  /// No description provided for @sichereNZahlung.
  ///
  /// In de, this message translates to:
  /// **'Sichere\\nZahlung'**
  String get sichereNZahlung;

  /// No description provided for @sofortDokumentieren.
  ///
  /// In de, this message translates to:
  /// **'Sofort dokumentieren'**
  String get sofortDokumentieren;

  /// No description provided for @sonstige.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get sonstige;

  /// No description provided for @spracheUndMemos.
  ///
  /// In de, this message translates to:
  /// **'Sprache & Memos'**
  String get spracheUndMemos;

  /// No description provided for @statistikenAktualisieren.
  ///
  /// In de, this message translates to:
  /// **'Statistiken aktualisieren'**
  String get statistikenAktualisieren;

  /// No description provided for @statsNichtAktualisiert.
  ///
  /// In de, this message translates to:
  /// **'Statistiken konnten nicht aktualisiert werden.'**
  String get statsNichtAktualisiert;

  /// No description provided for @statusFiltern.
  ///
  /// In de, this message translates to:
  /// **'Filter status'**
  String get statusFiltern;

  /// No description provided for @stimmung.
  ///
  /// In de, this message translates to:
  /// **'Ø Stimmung'**
  String get stimmung;

  /// No description provided for @sucheInAktionenDetailsUID.
  ///
  /// In de, this message translates to:
  /// **'Suche in Aktionen, Details, UID…'**
  String get sucheInAktionenDetailsUID;

  /// No description provided for @sucheNachBetreffEMail.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Betreff, E-Mail…'**
  String get sucheNachBetreffEMail;

  /// No description provided for @sucheNachTitelOderOrt.
  ///
  /// In de, this message translates to:
  /// **'Nach Titel oder Ort suchen…'**
  String get sucheNachTitelOderOrt;

  /// No description provided for @suchenNameEMailFachrichtung.
  ///
  /// In de, this message translates to:
  /// **'Suchen (Name, E-Mail, Fachrichtung)…'**
  String get suchenNameEMailFachrichtung;

  /// No description provided for @suchenNameEmailUid.
  ///
  /// In de, this message translates to:
  /// **'Suchen (Name, E-Mail oder UID)…'**
  String get suchenNameEmailUid;

  /// No description provided for @taeglicheChallenges.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Challenges'**
  String get taeglicheChallenges;

  /// No description provided for @tagEingeben.
  ///
  /// In de, this message translates to:
  /// **'Tag eingeben…'**
  String get tagEingeben;

  /// No description provided for @tagePostOP.
  ///
  /// In de, this message translates to:
  /// **'Tage post-OP'**
  String get tagePostOP;

  /// No description provided for @templateFollowupActivitySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Aktivität schrittweise steigern – auf den Körper hören'**
  String get templateFollowupActivitySubtitle;

  /// No description provided for @templateFollowupActivityTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktivität steigern'**
  String get templateFollowupActivityTitle;

  /// No description provided for @templateFollowupDay14Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Zweite Fortschrittskontrolle'**
  String get templateFollowupDay14Subtitle;

  /// No description provided for @templateFollowupDay21Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Dritte Fortschrittskontrolle'**
  String get templateFollowupDay21Subtitle;

  /// No description provided for @templateFollowupDay28Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Abschlussuntersuchung und Entlassung'**
  String get templateFollowupDay28Subtitle;

  /// No description provided for @templateFollowupDay28Title.
  ///
  /// In de, this message translates to:
  /// **'Abschlusskontrolle'**
  String get templateFollowupDay28Title;

  /// No description provided for @templateFollowupDay7Subtitle.
  ///
  /// In de, this message translates to:
  /// **'Fortschrittskontrolle in der Praxis'**
  String get templateFollowupDay7Subtitle;

  /// No description provided for @templateFollowupDay7Title.
  ///
  /// In de, this message translates to:
  /// **'Nachsorgetermin'**
  String get templateFollowupDay7Title;

  /// No description provided for @templateFollowupScarCareSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Narbe sanft eincremen und beobachten'**
  String get templateFollowupScarCareSubtitle;

  /// No description provided for @templateFollowupScarCareTitle.
  ///
  /// In de, this message translates to:
  /// **'Narbenpflege'**
  String get templateFollowupScarCareTitle;

  /// No description provided for @templateFollowupWeeklyCheckSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Heilungsfortschritt auswerten und dokumentieren'**
  String get templateFollowupWeeklyCheckSubtitle;

  /// No description provided for @templateFollowupWeeklyCheckTitle.
  ///
  /// In de, this message translates to:
  /// **'Wöchentliche Selbstkontrolle'**
  String get templateFollowupWeeklyCheckTitle;

  /// No description provided for @templateFollowupWoundPhotoSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Heilungsfortschritt weiter dokumentieren'**
  String get templateFollowupWoundPhotoSubtitle;

  /// No description provided for @templateFollowupWoundPhotoTitle.
  ///
  /// In de, this message translates to:
  /// **'Wundfoto aufnehmen'**
  String get templateFollowupWoundPhotoTitle;

  /// No description provided for @templateMedsEveningSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Abenddosis wie verordnet'**
  String get templateMedsEveningSubtitle;

  /// No description provided for @templateMedsMiddaySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Mittagsdosis wie verordnet'**
  String get templateMedsMiddaySubtitle;

  /// No description provided for @templateMedsMorningSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Morgendosis wie verordnet'**
  String get templateMedsMorningSubtitle;

  /// No description provided for @templateMedsMorningTitle.
  ///
  /// In de, this message translates to:
  /// **'Medikamente nehmen'**
  String get templateMedsMorningTitle;

  /// No description provided for @templateOpdayAdmissionSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bitte pünktlich in der Klinik erscheinen'**
  String get templateOpdayAdmissionSubtitle;

  /// No description provided for @templateOpdayAdmissionTitle.
  ///
  /// In de, this message translates to:
  /// **'Aufnahme'**
  String get templateOpdayAdmissionTitle;

  /// No description provided for @templateOpdayFastingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Keine Nahrung oder Flüssigkeit wie angewiesen'**
  String get templateOpdayFastingSubtitle;

  /// No description provided for @templateOpdayFastingTitle.
  ///
  /// In de, this message translates to:
  /// **'Nüchternheit prüfen'**
  String get templateOpdayFastingTitle;

  /// No description provided for @templateOpdayInfoSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Offene Fragen mit dem Team klären'**
  String get templateOpdayInfoSubtitle;

  /// No description provided for @templateOpdayInfoTitle.
  ///
  /// In de, this message translates to:
  /// **'OP-Infos bestätigen'**
  String get templateOpdayInfoTitle;

  /// No description provided for @templateOpdayMobilizationSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Kurz aufsetzen/aufstehen mit Unterstützung'**
  String get templateOpdayMobilizationSubtitle;

  /// No description provided for @templateOpdayMobilizationTitle.
  ///
  /// In de, this message translates to:
  /// **'Erste Mobilisierung'**
  String get templateOpdayMobilizationTitle;

  /// No description provided for @templatePreopBagSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Dokumente, Kleidung und Ladekabel einpacken'**
  String get templatePreopBagSubtitle;

  /// No description provided for @templatePreopBagTitle.
  ///
  /// In de, this message translates to:
  /// **'Koffer packen'**
  String get templatePreopBagTitle;

  /// No description provided for @templatePreopCompanionSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Fahrt und Treffpunkt abstimmen'**
  String get templatePreopCompanionSubtitle;

  /// No description provided for @templatePreopCompanionTitle.
  ///
  /// In de, this message translates to:
  /// **'Begleitperson informieren'**
  String get templatePreopCompanionTitle;

  /// No description provided for @templatePreopDocumentsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Krankenkassenkarte und Befunde vorbereiten'**
  String get templatePreopDocumentsSubtitle;

  /// No description provided for @templatePreopDocumentsTitle.
  ///
  /// In de, this message translates to:
  /// **'Dokumente prüfen'**
  String get templatePreopDocumentsTitle;

  /// No description provided for @templateWeek1AbdominalSupportSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Sitz und Trageweise prüfen'**
  String get templateWeek1AbdominalSupportSubtitle;

  /// No description provided for @templateWeek1AbdominalSupportTitle.
  ///
  /// In de, this message translates to:
  /// **'Bauchgurt prüfen'**
  String get templateWeek1AbdominalSupportTitle;

  /// No description provided for @templateWeek1BackPostureSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Kein Verdrehen oder Beugen der Wirbelsäule'**
  String get templateWeek1BackPostureSubtitle;

  /// No description provided for @templateWeek1BackPostureTitle.
  ///
  /// In de, this message translates to:
  /// **'Rückenschutzhaltung'**
  String get templateWeek1BackPostureTitle;

  /// No description provided for @templateWeek1BloodPressureSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Werte morgens und abends dokumentieren'**
  String get templateWeek1BloodPressureSubtitle;

  /// No description provided for @templateWeek1BloodPressureTitle.
  ///
  /// In de, this message translates to:
  /// **'Blutdruck messen'**
  String get templateWeek1BloodPressureTitle;

  /// No description provided for @templateWeek1BowelDiarySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verdauung beobachten – wichtig für den Kostaufbau'**
  String get templateWeek1BowelDiarySubtitle;

  /// No description provided for @templateWeek1BowelDiaryTitle.
  ///
  /// In de, this message translates to:
  /// **'Stuhlgang dokumentieren'**
  String get templateWeek1BowelDiaryTitle;

  /// No description provided for @templateWeek1BreathingCardioSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen'**
  String get templateWeek1BreathingCardioSubtitle;

  /// No description provided for @templateWeek1BreathingCardioTitle.
  ///
  /// In de, this message translates to:
  /// **'Atemübungen'**
  String get templateWeek1BreathingCardioTitle;

  /// No description provided for @templateWeek1BreathingSpineSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Tiefe Atemzüge – Rücken gerade, sanft atmen'**
  String get templateWeek1BreathingSpineSubtitle;

  /// No description provided for @templateWeek1BreathingSpineTitle.
  ///
  /// In de, this message translates to:
  /// **'Atemübungen'**
  String get templateWeek1BreathingSpineTitle;

  /// No description provided for @templateWeek1CardiacRehabSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Leichtes Gehen, Kreislauf langsam aufbauen'**
  String get templateWeek1CardiacRehabSubtitle;

  /// No description provided for @templateWeek1CardiacRehabTitle.
  ///
  /// In de, this message translates to:
  /// **'Herz-Reha-Übungen'**
  String get templateWeek1CardiacRehabTitle;

  /// No description provided for @templateWeek1CompressionSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Sitz und Zustand der Strümpfe prüfen'**
  String get templateWeek1CompressionSubtitle;

  /// No description provided for @templateWeek1CompressionTitle.
  ///
  /// In de, this message translates to:
  /// **'Kompressionsstrümpfe prüfen'**
  String get templateWeek1CompressionTitle;

  /// No description provided for @templateWeek1DietBuildupSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Leichte Kost, Schonkost → schrittweise steigern'**
  String get templateWeek1DietBuildupSubtitle;

  /// No description provided for @templateWeek1DietBuildupTitle.
  ///
  /// In de, this message translates to:
  /// **'Kostaufbau'**
  String get templateWeek1DietBuildupTitle;

  /// No description provided for @templateWeek1DressingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verbandszustand prüfen und dokumentieren'**
  String get templateWeek1DressingSubtitle;

  /// No description provided for @templateWeek1DressingTitle.
  ///
  /// In de, this message translates to:
  /// **'Verbandkontrolle'**
  String get templateWeek1DressingTitle;

  /// No description provided for @templateWeek1HydrationSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 1,5 Liter Flüssigkeit pro Tag'**
  String get templateWeek1HydrationSubtitle;

  /// No description provided for @templateWeek1HydrationTitle.
  ///
  /// In de, this message translates to:
  /// **'Flüssigkeitszufuhr prüfen'**
  String get templateWeek1HydrationTitle;

  /// No description provided for @templateWeek1JointRomSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Beugen und Strecken vorsichtig testen'**
  String get templateWeek1JointRomSubtitle;

  /// No description provided for @templateWeek1JointRomTitle.
  ///
  /// In de, this message translates to:
  /// **'Gelenkbeweglichkeit prüfen'**
  String get templateWeek1JointRomTitle;

  /// No description provided for @templateWeek1LegExercisesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Füße kreisen, Beine anspannen – Thromboseprophylaxe'**
  String get templateWeek1LegExercisesSubtitle;

  /// No description provided for @templateWeek1LegExercisesTitle.
  ///
  /// In de, this message translates to:
  /// **'Beinübungen machen'**
  String get templateWeek1LegExercisesTitle;

  /// No description provided for @templateWeek1MobilizationSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Langsam mobilisieren – auch kleine Schritte zählen'**
  String get templateWeek1MobilizationSubtitle;

  /// No description provided for @templateWeek1MobilizationTitle.
  ///
  /// In de, this message translates to:
  /// **'Aufstehen & kurz bewegen'**
  String get templateWeek1MobilizationTitle;

  /// No description provided for @templateWeek1NoStrainingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Pressen vermeiden, seitwärts abrollen beim Aufstehen'**
  String get templateWeek1NoStrainingSubtitle;

  /// No description provided for @templateWeek1NoStrainingTitle.
  ///
  /// In de, this message translates to:
  /// **'Bauchschutz'**
  String get templateWeek1NoStrainingTitle;

  /// No description provided for @templateWeek1OrthosisSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Sitz und Tragezeit prüfen'**
  String get templateWeek1OrthosisSubtitle;

  /// No description provided for @templateWeek1OrthosisTitle.
  ///
  /// In de, this message translates to:
  /// **'Orthese/Korsett prüfen'**
  String get templateWeek1OrthosisTitle;

  /// No description provided for @templateWeek1PainScoreSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schmerzniveau in der App eingeben'**
  String get templateWeek1PainScoreSubtitle;

  /// No description provided for @templateWeek1PainScoreTitle.
  ///
  /// In de, this message translates to:
  /// **'Schmerzniveau erfassen'**
  String get templateWeek1PainScoreTitle;

  /// No description provided for @templateWeek1RedFlagsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Fieber, Rötung, Schwellung, starke Schmerzen?'**
  String get templateWeek1RedFlagsSubtitle;

  /// No description provided for @templateWeek1RedFlagsTitle.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen prüfen'**
  String get templateWeek1RedFlagsTitle;

  /// No description provided for @templateWeek1SpineStabilizationSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Rumpfstabilisierung nach Anweisung – schrittweise steigern'**
  String get templateWeek1SpineStabilizationSubtitle;

  /// No description provided for @templateWeek1SpineStabilizationTitle.
  ///
  /// In de, this message translates to:
  /// **'Stabilisierungsübungen'**
  String get templateWeek1SpineStabilizationTitle;

  /// No description provided for @templateWeek1SternumSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Nicht über 5 kg heben, Arme körpernah halten'**
  String get templateWeek1SternumSubtitle;

  /// No description provided for @templateWeek1SternumTitle.
  ///
  /// In de, this message translates to:
  /// **'Sternumschutz'**
  String get templateWeek1SternumTitle;

  /// No description provided for @templateWeek1VitalsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Puls/Temperatur kurz notieren'**
  String get templateWeek1VitalsSubtitle;

  /// No description provided for @templateWeek1VitalsTitle.
  ///
  /// In de, this message translates to:
  /// **'Vitaldaten prüfen'**
  String get templateWeek1VitalsTitle;

  /// No description provided for @templateWeek1WoundPhotoSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Foto zur Fortschrittsverfolgung dokumentieren'**
  String get templateWeek1WoundPhotoSubtitle;

  /// No description provided for @templateWeek1WoundPhotoTitle.
  ///
  /// In de, this message translates to:
  /// **'Wundfoto aufnehmen'**
  String get templateWeek1WoundPhotoTitle;

  /// No description provided for @templateWeek2CardiacWalkSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Gehdistanz schrittweise steigern, Puls beobachten'**
  String get templateWeek2CardiacWalkSubtitle;

  /// No description provided for @templateWeek2CardiacWalkTitle.
  ///
  /// In de, this message translates to:
  /// **'Herz-Reha-Spaziergang'**
  String get templateWeek2CardiacWalkTitle;

  /// No description provided for @templateWeek2DietNormalizeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verdauung beobachten – langsam auf Normalkost umstellen'**
  String get templateWeek2DietNormalizeSubtitle;

  /// No description provided for @templateWeek2DietNormalizeTitle.
  ///
  /// In de, this message translates to:
  /// **'Normale Ernährung aufbauen'**
  String get templateWeek2DietNormalizeTitle;

  /// No description provided for @templateWeek2GaitSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Sicheres Gehen mit/ohne Hilfsmittel üben'**
  String get templateWeek2GaitSubtitle;

  /// No description provided for @templateWeek2GaitTitle.
  ///
  /// In de, this message translates to:
  /// **'Gangschulung'**
  String get templateWeek2GaitTitle;

  /// No description provided for @templateWeek2PainSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schmerzverlauf dokumentieren – wird es besser?'**
  String get templateWeek2PainSubtitle;

  /// No description provided for @templateWeek2PainTitle.
  ///
  /// In de, this message translates to:
  /// **'Schmerztagebuch'**
  String get templateWeek2PainTitle;

  /// No description provided for @templateWeek2PhysioSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Übungen nach Anweisung durchführen'**
  String get templateWeek2PhysioSubtitle;

  /// No description provided for @templateWeek2PhysioTitle.
  ///
  /// In de, this message translates to:
  /// **'Physiotherapie-Übungen'**
  String get templateWeek2PhysioTitle;

  /// No description provided for @templateWeek2WalkSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Täglich etwas weiter gehen – Kreislauf stärken'**
  String get templateWeek2WalkSubtitle;

  /// No description provided for @templateWeek2WalkTitle.
  ///
  /// In de, this message translates to:
  /// **'Spazieren gehen'**
  String get templateWeek2WalkTitle;

  /// No description provided for @templateWeek2WoundObserveSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Heilungsverlauf beobachten und dokumentieren'**
  String get templateWeek2WoundObserveSubtitle;

  /// No description provided for @templateWeek2WoundObserveTitle.
  ///
  /// In de, this message translates to:
  /// **'Wunde beobachten'**
  String get templateWeek2WoundObserveTitle;

  /// No description provided for @templateWeek1SymptomCheckSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wie geht es dir heute? Symptome prüfen und dokumentieren'**
  String get templateWeek1SymptomCheckSubtitle;

  /// No description provided for @templateWeek1SymptomCheckTitle.
  ///
  /// In de, this message translates to:
  /// **'Symptomcheck durchführen'**
  String get templateWeek1SymptomCheckTitle;

  /// No description provided for @termineNaechste14Tage.
  ///
  /// In de, this message translates to:
  /// **'Termine nächste 14 Tage'**
  String get termineNaechste14Tage;

  /// No description provided for @testBenachrichtigungErstellen.
  ///
  /// In de, this message translates to:
  /// **'Testbenachrichtigung erstellen'**
  String get testBenachrichtigungErstellen;

  /// No description provided for @ticketChatNachrichtSchreiben.
  ///
  /// In de, this message translates to:
  /// **'Nachricht schreiben…'**
  String get ticketChatNachrichtSchreiben;

  /// No description provided for @ticketErstellen.
  ///
  /// In de, this message translates to:
  /// **'Ticket erstellen'**
  String get ticketErstellen;

  /// No description provided for @timelineAddNoteContent.
  ///
  /// In de, this message translates to:
  /// **'Inhalt (optional)'**
  String get timelineAddNoteContent;

  /// No description provided for @timelineAddTaskDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung (optional)'**
  String get timelineAddTaskDescription;

  /// No description provided for @timelineAddTaskTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get timelineAddTaskTitle;

  /// No description provided for @timelineBesserOrganisieren.
  ///
  /// In de, this message translates to:
  /// **'Timeline besser organisieren'**
  String get timelineBesserOrganisieren;

  /// No description provided for @timelineDue.
  ///
  /// In de, this message translates to:
  /// **'Fällig'**
  String get timelineDue;

  /// No description provided for @timelineFriday.
  ///
  /// In de, this message translates to:
  /// **'Freitag'**
  String get timelineFriday;

  /// No description provided for @timelineMonday.
  ///
  /// In de, this message translates to:
  /// **'Montag'**
  String get timelineMonday;

  /// No description provided for @timelineMyPlan.
  ///
  /// In de, this message translates to:
  /// **'Mein Plan'**
  String get timelineMyPlan;

  /// No description provided for @timelineNoOpenTasks.
  ///
  /// In de, this message translates to:
  /// **'Heute keine offenen Aufgaben'**
  String get timelineNoOpenTasks;

  /// No description provided for @timelinePhaseDefault.
  ///
  /// In de, this message translates to:
  /// **'Phase'**
  String get timelinePhaseDefault;

  /// No description provided for @timelinePhaseFollowup.
  ///
  /// In de, this message translates to:
  /// **'Nachsorge'**
  String get timelinePhaseFollowup;

  /// No description provided for @timelinePhaseOpday.
  ///
  /// In de, this message translates to:
  /// **'OP-Tag'**
  String get timelinePhaseOpday;

  /// No description provided for @timelinePhasePersonal.
  ///
  /// In de, this message translates to:
  /// **'Meine Einträge'**
  String get timelinePhasePersonal;

  /// No description provided for @timelinePhasePreop.
  ///
  /// In de, this message translates to:
  /// **'Vorbereitung'**
  String get timelinePhasePreop;

  /// No description provided for @timelinePhaseWeek1.
  ///
  /// In de, this message translates to:
  /// **'Woche 1 · Heilung & Überwachung'**
  String get timelinePhaseWeek1;

  /// No description provided for @timelinePhaseWeek2.
  ///
  /// In de, this message translates to:
  /// **'Woche 2 · Aktivierung'**
  String get timelinePhaseWeek2;

  /// No description provided for @timelinePlanComplete.
  ///
  /// In de, this message translates to:
  /// **'Dein Plan ist aktuell vollständig erledigt'**
  String get timelinePlanComplete;

  /// No description provided for @timelineRouteAppointment.
  ///
  /// In de, this message translates to:
  /// **'Termin hinzufügen'**
  String get timelineRouteAppointment;

  /// No description provided for @timelineRouteAppointmentDesc.
  ///
  /// In de, this message translates to:
  /// **'Erstelle und verwalte deine OP-bezogenen Termine.'**
  String get timelineRouteAppointmentDesc;

  /// No description provided for @timelineRouteDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente hochladen'**
  String get timelineRouteDocuments;

  /// No description provided for @timelineRouteMedication.
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get timelineRouteMedication;

  /// No description provided for @timelineRouteMoodLog.
  ///
  /// In de, this message translates to:
  /// **'Stimmungstagebuch'**
  String get timelineRouteMoodLog;

  /// No description provided for @timelineRouteMoodLogDesc.
  ///
  /// In de, this message translates to:
  /// **'Erfasse deine Stimmung und erkenne Muster in deinem emotionalen Wohlbefinden.'**
  String get timelineRouteMoodLogDesc;

  /// No description provided for @timelineRouteNoteAdd.
  ///
  /// In de, this message translates to:
  /// **'Notiz erstellen'**
  String get timelineRouteNoteAdd;

  /// No description provided for @timelineRouteNoteAddDesc.
  ///
  /// In de, this message translates to:
  /// **'Halte einen freien Eintrag in deiner Timeline fest.'**
  String get timelineRouteNoteAddDesc;

  /// No description provided for @timelineRouteNutrition.
  ///
  /// In de, this message translates to:
  /// **'Ernährungstagebuch'**
  String get timelineRouteNutrition;

  /// No description provided for @timelineRouteNutritionDesc.
  ///
  /// In de, this message translates to:
  /// **'Dokumentiere deine Mahlzeiten und erhalte Ernährungsempfehlungen.'**
  String get timelineRouteNutritionDesc;

  /// No description provided for @timelineRoutePainLog.
  ///
  /// In de, this message translates to:
  /// **'Schmerztagebuch'**
  String get timelineRoutePainLog;

  /// No description provided for @timelineRoutePainLogDesc.
  ///
  /// In de, this message translates to:
  /// **'Dokumentiere dein Schmerzniveau auf einer Skala von 1–10.'**
  String get timelineRoutePainLogDesc;

  /// No description provided for @timelineRouteQuestions.
  ///
  /// In de, this message translates to:
  /// **'Fragen & Notizen'**
  String get timelineRouteQuestions;

  /// No description provided for @timelineRouteQuestionsDesc.
  ///
  /// In de, this message translates to:
  /// **'Behalte den Überblick über Fragen für deinen Operateur und persönliche Notizen.'**
  String get timelineRouteQuestionsDesc;

  /// No description provided for @timelineRouteRedFlag.
  ///
  /// In de, this message translates to:
  /// **'Red-Flag Cockpit'**
  String get timelineRouteRedFlag;

  /// No description provided for @timelineRouteRedFlagDesc.
  ///
  /// In de, this message translates to:
  /// **'Aktive Warnungen und Notfallaktionen prüfen.'**
  String get timelineRouteRedFlagDesc;

  /// No description provided for @timelineRouteRehab.
  ///
  /// In de, this message translates to:
  /// **'Reha'**
  String get timelineRouteRehab;

  /// No description provided for @timelineRouteRehabDesc.
  ///
  /// In de, this message translates to:
  /// **'Öffnet die Reha-Übersicht für Übungen und Fortschritt.'**
  String get timelineRouteRehabDesc;

  /// No description provided for @timelineRouteSleepLog.
  ///
  /// In de, this message translates to:
  /// **'Schlaftagebuch'**
  String get timelineRouteSleepLog;

  /// No description provided for @timelineRouteSleepLogDesc.
  ///
  /// In de, this message translates to:
  /// **'Dokumentiere deine Schlafdauer und -qualität.'**
  String get timelineRouteSleepLogDesc;

  /// No description provided for @timelineRoutesNotizErstellen854.
  ///
  /// In de, this message translates to:
  /// **'Notiz erstellen'**
  String get timelineRoutesNotizErstellen854;

  /// No description provided for @timelineRouteSymptomCheck.
  ///
  /// In de, this message translates to:
  /// **'Symptom-Check'**
  String get timelineRouteSymptomCheck;

  /// No description provided for @timelineRouteTaskAdd.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe hinzufügen'**
  String get timelineRouteTaskAdd;

  /// No description provided for @timelineRouteTaskAddDesc.
  ///
  /// In de, this message translates to:
  /// **'Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.'**
  String get timelineRouteTaskAddDesc;

  /// No description provided for @timelineRouteTransport.
  ///
  /// In de, this message translates to:
  /// **'Transport'**
  String get timelineRouteTransport;

  /// No description provided for @timelineRouteTransportDesc.
  ///
  /// In de, this message translates to:
  /// **'Plane deine Hin- und Rückfahrt zur Klinik.'**
  String get timelineRouteTransportDesc;

  /// No description provided for @timelineRouteVitals.
  ///
  /// In de, this message translates to:
  /// **'Vitaldaten'**
  String get timelineRouteVitals;

  /// No description provided for @timelineRouteWoundDoc.
  ///
  /// In de, this message translates to:
  /// **'Wunddokumentation'**
  String get timelineRouteWoundDoc;

  /// No description provided for @timelineSaturday.
  ///
  /// In de, this message translates to:
  /// **'Samstag'**
  String get timelineSaturday;

  /// No description provided for @timelineSheetDocUpload.
  ///
  /// In de, this message translates to:
  /// **'Dokument hochladen'**
  String get timelineSheetDocUpload;

  /// No description provided for @timelineSheetPainLevel.
  ///
  /// In de, this message translates to:
  /// **'Schmerzniveau'**
  String get timelineSheetPainLevel;

  /// No description provided for @timelineSheetWoundPhoto.
  ///
  /// In de, this message translates to:
  /// **'Wundfoto'**
  String get timelineSheetWoundPhoto;

  /// No description provided for @timelineSunday.
  ///
  /// In de, this message translates to:
  /// **'Sonntag'**
  String get timelineSunday;

  /// No description provided for @timelineThursday.
  ///
  /// In de, this message translates to:
  /// **'Donnerstag'**
  String get timelineThursday;

  /// No description provided for @timelineToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get timelineToday;

  /// No description provided for @timelineTomorrow.
  ///
  /// In de, this message translates to:
  /// **'Morgen'**
  String get timelineTomorrow;

  /// No description provided for @timelineTransportDriver.
  ///
  /// In de, this message translates to:
  /// **'Fahrer'**
  String get timelineTransportDriver;

  /// No description provided for @timelineTransportHint.
  ///
  /// In de, this message translates to:
  /// **'Plane deine Hin- und Rückfahrt zur Klinik.'**
  String get timelineTransportHint;

  /// No description provided for @timelineTransportNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get timelineTransportNotes;

  /// No description provided for @timelineTransportOutbound.
  ///
  /// In de, this message translates to:
  /// **'Hinfahrt (Uhrzeit / Treffpunkt)'**
  String get timelineTransportOutbound;

  /// No description provided for @timelineTransportReturn.
  ///
  /// In de, this message translates to:
  /// **'Rückfahrt (Uhrzeit / Treffpunkt)'**
  String get timelineTransportReturn;

  /// No description provided for @timelineTuesday.
  ///
  /// In de, this message translates to:
  /// **'Dienstag'**
  String get timelineTuesday;

  /// No description provided for @timelineVerknuepfung.
  ///
  /// In de, this message translates to:
  /// **'Timeline-Verknüpfung'**
  String get timelineVerknuepfung;

  /// No description provided for @timelineViewFullPlan.
  ///
  /// In de, this message translates to:
  /// **'Gesamtplan anzeigen'**
  String get timelineViewFullPlan;

  /// No description provided for @timelineWednesday.
  ///
  /// In de, this message translates to:
  /// **'Mittwoch'**
  String get timelineWednesday;

  /// No description provided for @timelineZusammenfassung.
  ///
  /// In de, this message translates to:
  /// **'Timeline Zusammenfassung'**
  String get timelineZusammenfassung;

  /// No description provided for @timerStarten.
  ///
  /// In de, this message translates to:
  /// **'Timer starten'**
  String get timerStarten;

  /// No description provided for @titelBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Titel / Beschreibung'**
  String get titelBeschreibung;

  /// No description provided for @transkriptBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Transkript bearbeiten…'**
  String get transkriptBearbeiten;

  /// No description provided for @uebungSuchen.
  ///
  /// In de, this message translates to:
  /// **'Übung suchen…'**
  String get uebungSuchen;

  /// No description provided for @userSuchen.
  ///
  /// In de, this message translates to:
  /// **'User suchen'**
  String get userSuchen;

  /// No description provided for @userUID.
  ///
  /// In de, this message translates to:
  /// **'User UID'**
  String get userUID;

  /// No description provided for @verbindungFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Verbindung fehlgeschlagen. Bitte erneut versuchen.'**
  String get verbindungFehlgeschlagen;

  /// No description provided for @verbindungTrennen.
  ///
  /// In de, this message translates to:
  /// **'Verbindung trennen'**
  String get verbindungTrennen;

  /// No description provided for @verfolgeDeineRecoveryMeilensteine.
  ///
  /// In de, this message translates to:
  /// **'Verfolge deine Recovery-Meilensteine'**
  String get verfolgeDeineRecoveryMeilensteine;

  /// No description provided for @voiceMemosMemosDurchsuchen.
  ///
  /// In de, this message translates to:
  /// **'Memos durchsuchen…'**
  String get voiceMemosMemosDurchsuchen;

  /// No description provided for @vordefinierteVorlagenVerwalten.
  ///
  /// In de, this message translates to:
  /// **'Vordefinierte Vorlagen verwalten'**
  String get vordefinierteVorlagenVerwalten;

  /// No description provided for @vorDerOP.
  ///
  /// In de, this message translates to:
  /// **'Vor der OP'**
  String get vorDerOP;

  /// No description provided for @vorlage.
  ///
  /// In de, this message translates to:
  /// **'Vorlage'**
  String get vorlage;

  /// No description provided for @vorlagenDurchsuchen.
  ///
  /// In de, this message translates to:
  /// **'Vorlagen suchen...'**
  String get vorlagenDurchsuchen;

  /// No description provided for @wannZumArzt.
  ///
  /// In de, this message translates to:
  /// **'Wann zum Arzt?'**
  String get wannZumArzt;

  /// No description provided for @warnCall112.
  ///
  /// In de, this message translates to:
  /// **'112 anrufen'**
  String get warnCall112;

  /// No description provided for @warnCheckLabel.
  ///
  /// In de, this message translates to:
  /// **'Schnellcheck:'**
  String get warnCheckLabel;

  /// No description provided for @warnContactClinic.
  ///
  /// In de, this message translates to:
  /// **'Kontaktiere die Klinik bei diesen Zeichen:'**
  String get warnContactClinic;

  /// No description provided for @warnEmergencySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bei lebensbedrohlichen Symptomen!'**
  String get warnEmergencySubtitle;

  /// No description provided for @warnEmergencyTitle.
  ///
  /// In de, this message translates to:
  /// **'Notfall?'**
  String get warnEmergencyTitle;

  /// No description provided for @warnItemBleedingQ1.
  ///
  /// In de, this message translates to:
  /// **'Ist die Blutung aktiv und lässt sich nicht stoppen?'**
  String get warnItemBleedingQ1;

  /// No description provided for @warnItemBleedingQ2.
  ///
  /// In de, this message translates to:
  /// **'Ist der Verband schon vollständig durchgeblutet?'**
  String get warnItemBleedingQ2;

  /// No description provided for @warnItemBleedingQ3.
  ///
  /// In de, this message translates to:
  /// **'Fühlst du dich schwindelig oder schwach?'**
  String get warnItemBleedingQ3;

  /// No description provided for @warnItemBleedingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Blut sickert schnell durch den Verband'**
  String get warnItemBleedingSubtitle;

  /// No description provided for @warnItemBleedingTitle.
  ///
  /// In de, this message translates to:
  /// **'Starke Blutung'**
  String get warnItemBleedingTitle;

  /// No description provided for @warnItemBreathQ1.
  ///
  /// In de, this message translates to:
  /// **'Tritt die Atemnot in Ruhe auf?'**
  String get warnItemBreathQ1;

  /// No description provided for @warnItemBreathQ2.
  ///
  /// In de, this message translates to:
  /// **'Wird die Atemnot schlimmer?'**
  String get warnItemBreathQ2;

  /// No description provided for @warnItemBreathQ3.
  ///
  /// In de, this message translates to:
  /// **'Hast du Schmerzen beim Atmen?'**
  String get warnItemBreathQ3;

  /// No description provided for @warnItemBreathSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Atemnot oder Lufthunger'**
  String get warnItemBreathSubtitle;

  /// No description provided for @warnItemBreathTitle.
  ///
  /// In de, this message translates to:
  /// **'Atemnot'**
  String get warnItemBreathTitle;

  /// No description provided for @warnItemFeverQ1.
  ///
  /// In de, this message translates to:
  /// **'Hast du Fieber gemessen?'**
  String get warnItemFeverQ1;

  /// No description provided for @warnItemFeverQ2.
  ///
  /// In de, this message translates to:
  /// **'Ist die Temperatur über 38,5 °C?'**
  String get warnItemFeverQ2;

  /// No description provided for @warnItemFeverQ3.
  ///
  /// In de, this message translates to:
  /// **'Hast du Schüttelfrost?'**
  String get warnItemFeverQ3;

  /// No description provided for @warnItemFeverSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Temperatur über 38,5 °C'**
  String get warnItemFeverSubtitle;

  /// No description provided for @warnItemFeverTitle.
  ///
  /// In de, this message translates to:
  /// **'Hohes Fieber'**
  String get warnItemFeverTitle;

  /// No description provided for @warnItemPainQ1.
  ///
  /// In de, this message translates to:
  /// **'Sind die Schmerzen deutlich stärker als sonst?'**
  String get warnItemPainQ1;

  /// No description provided for @warnItemPainQ2.
  ///
  /// In de, this message translates to:
  /// **'Helfen deine üblichen Schmerzmittel nicht mehr?'**
  String get warnItemPainQ2;

  /// No description provided for @warnItemPainQ3.
  ///
  /// In de, this message translates to:
  /// **'Ist die schmerzende Stelle geschwollen oder heiß?'**
  String get warnItemPainQ3;

  /// No description provided for @warnItemPainSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Plötzlich zunehmend, nicht kontrollierbar'**
  String get warnItemPainSubtitle;

  /// No description provided for @warnItemPainTitle.
  ///
  /// In de, this message translates to:
  /// **'Starke Schmerzen'**
  String get warnItemPainTitle;

  /// No description provided for @warnItemRednessQ1.
  ///
  /// In de, this message translates to:
  /// **'Breitet sich die Rötung aus?'**
  String get warnItemRednessQ1;

  /// No description provided for @warnItemRednessQ2.
  ///
  /// In de, this message translates to:
  /// **'Ist die Stelle warm oder heiß?'**
  String get warnItemRednessQ2;

  /// No description provided for @warnItemRednessQ3.
  ///
  /// In de, this message translates to:
  /// **'Gibt es Eiter oder Absonderungen?'**
  String get warnItemRednessQ3;

  /// No description provided for @warnItemRednessSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wundbereich erscheint entzündet'**
  String get warnItemRednessSubtitle;

  /// No description provided for @warnItemRednessTitle.
  ///
  /// In de, this message translates to:
  /// **'Zunehmende Rötung / Schwellung'**
  String get warnItemRednessTitle;

  /// No description provided for @warnItemSmellQ1.
  ///
  /// In de, this message translates to:
  /// **'Hat das Sekret eine ungewöhnliche Farbe?'**
  String get warnItemSmellQ1;

  /// No description provided for @warnItemSmellQ2.
  ///
  /// In de, this message translates to:
  /// **'Riecht die Wunde deutlich unangenehm?'**
  String get warnItemSmellQ2;

  /// No description provided for @warnItemSmellQ3.
  ///
  /// In de, this message translates to:
  /// **'Hat sich die Sekretmenge erhöht?'**
  String get warnItemSmellQ3;

  /// No description provided for @warnItemSmellSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ungewöhnliches Sekret aus der Wunde'**
  String get warnItemSmellSubtitle;

  /// No description provided for @warnItemSmellTitle.
  ///
  /// In de, this message translates to:
  /// **'Übelriechendes Sekret'**
  String get warnItemSmellTitle;

  /// No description provided for @warnSaveCheck.
  ///
  /// In de, this message translates to:
  /// **'Prüfung speichern'**
  String get warnSaveCheck;

  /// No description provided for @warnTitle.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen'**
  String get warnTitle;

  /// No description provided for @warnzeichenStatus.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen Status'**
  String get warnzeichenStatus;

  /// No description provided for @wartungsmodusDeaktivieren.
  ///
  /// In de, this message translates to:
  /// **'Wartungsmodus deaktivieren'**
  String get wartungsmodusDeaktivieren;

  /// No description provided for @wasBeschaeftigtDich.
  ///
  /// In de, this message translates to:
  /// **'Was beschäftigt dich gerade?'**
  String get wasBeschaeftigtDich;

  /// No description provided for @wasBeschreibtDeineStimmung.
  ///
  /// In de, this message translates to:
  /// **'Was beschreibt deine Stimmung?'**
  String get wasBeschreibtDeineStimmung;

  /// No description provided for @wasHastDuBeobachtet.
  ///
  /// In de, this message translates to:
  /// **'Was hast du beobachtet?'**
  String get wasHastDuBeobachtet;

  /// No description provided for @weekdayShortFri.
  ///
  /// In de, this message translates to:
  /// **'Fr'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortMon.
  ///
  /// In de, this message translates to:
  /// **'Mo'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortSat.
  ///
  /// In de, this message translates to:
  /// **'Sa'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In de, this message translates to:
  /// **'So'**
  String get weekdayShortSun;

  /// No description provided for @weekdayShortThu.
  ///
  /// In de, this message translates to:
  /// **'Do'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortTue.
  ///
  /// In de, this message translates to:
  /// **'Di'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In de, this message translates to:
  /// **'Mi'**
  String get weekdayShortWed;

  /// No description provided for @weiterDokumentieren.
  ///
  /// In de, this message translates to:
  /// **'Weiter dokumentieren'**
  String get weiterDokumentieren;

  /// No description provided for @weiterenPatientenHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Weiteren Patienten hinzufügen'**
  String get weiterenPatientenHinzufuegen;

  /// No description provided for @werbungUndDatenschutz.
  ///
  /// In de, this message translates to:
  /// **'Werbung & Datenschutz'**
  String get werbungUndDatenschutz;

  /// No description provided for @wieGehtEsDir.
  ///
  /// In de, this message translates to:
  /// **'Wie geht es dir?'**
  String get wieGehtEsDir;

  /// No description provided for @woche1.
  ///
  /// In de, this message translates to:
  /// **'Woche 1'**
  String get woche1;

  /// No description provided for @wochentage.
  ///
  /// In de, this message translates to:
  /// **'Wochentage'**
  String get wochentage;

  /// No description provided for @woundDocumentationNeuesFotoAufnehmen.
  ///
  /// In de, this message translates to:
  /// **'Neues Foto aufnehmen'**
  String get woundDocumentationNeuesFotoAufnehmen;

  /// No description provided for @wunddetailFehlendeArgumente.
  ///
  /// In de, this message translates to:
  /// **'Wunddetail (fehlende Argumente)'**
  String get wunddetailFehlendeArgumente;

  /// No description provided for @wunddokuLetzte3.
  ///
  /// In de, this message translates to:
  /// **'Wunddoku letzte 3'**
  String get wunddokuLetzte3;

  /// No description provided for @wundeSchmerzBewegung.
  ///
  /// In de, this message translates to:
  /// **'Wunde, Schmerz, Bewegung'**
  String get wundeSchmerzBewegung;

  /// No description provided for @wundschmerz.
  ///
  /// In de, this message translates to:
  /// **'Ø Wundschmerz'**
  String get wundschmerz;

  /// No description provided for @wundvergleichFehlendeArgumente.
  ///
  /// In de, this message translates to:
  /// **'Wundvergleich (fehlende Argumente)'**
  String get wundvergleichFehlendeArgumente;

  /// No description provided for @xPUndLevelSystem.
  ///
  /// In de, this message translates to:
  /// **'XP & Level-System'**
  String get xPUndLevelSystem;

  /// No description provided for @zBA1B2C3D4.
  ///
  /// In de, this message translates to:
  /// **'z.B. A1B2C3D4'**
  String get zBA1B2C3D4;

  /// No description provided for @zBA1B2C3D4E5F6.
  ///
  /// In de, this message translates to:
  /// **'z.B. A1B2C3D4E5F6'**
  String get zBA1B2C3D4E5F6;

  /// No description provided for @zBArztAnrufen.
  ///
  /// In de, this message translates to:
  /// **'z.B. Arzt anrufen'**
  String get zBArztAnrufen;

  /// No description provided for @zbBefund.
  ///
  /// In de, this message translates to:
  /// **'z.B. Befund'**
  String get zbBefund;

  /// No description provided for @zbDieBlaue.
  ///
  /// In de, this message translates to:
  /// **'z. B. Die blaue, nicht die rote'**
  String get zbDieBlaue;

  /// No description provided for @zbNachDemEssen.
  ///
  /// In de, this message translates to:
  /// **'z. B. mit Wasser nach dem Essen einnehmen'**
  String get zbNachDemEssen;

  /// No description provided for @zBRehaBadNauheim.
  ///
  /// In de, this message translates to:
  /// **'z.B. Reha Bad Nauheim'**
  String get zBRehaBadNauheim;

  /// No description provided for @zBRehaKlinikMustermann.
  ///
  /// In de, this message translates to:
  /// **'z. B. Reha-Klinik Mustermann'**
  String get zBRehaKlinikMustermann;

  /// No description provided for @zbUpdateWirdEingespielt.
  ///
  /// In de, this message translates to:
  /// **'z.B. Update wird eingespielt…'**
  String get zbUpdateWirdEingespielt;

  /// No description provided for @zeitfilterZuruecksetzen.
  ///
  /// In de, this message translates to:
  /// **'Zeitfilter zurücksetzen'**
  String get zeitfilterZuruecksetzen;

  /// No description provided for @zeitraumFiltern.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum filtern'**
  String get zeitraumFiltern;

  /// No description provided for @zuDenEinstellungen.
  ///
  /// In de, this message translates to:
  /// **'Zu den Einstellungen'**
  String get zuDenEinstellungen;

  /// No description provided for @zurueckZurTimeline.
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Timeline'**
  String get zurueckZurTimeline;

  /// No description provided for @anfrageAblehnenBestaetigung.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du die Anfrage von {name} ablehnen?'**
  String anfrageAblehnenBestaetigung(String name);

  /// No description provided for @apptCalendarDayCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{{count} Termin} other{{count} Termine}}'**
  String apptCalendarDayCount(int count);

  /// No description provided for @apptCreatedBy.
  ///
  /// In de, this message translates to:
  /// **'Erstellt von {name}'**
  String apptCreatedBy(String name);

  /// No description provided for @apptDeleteContent.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du \"{title}\" wirklich dauerhaft löschen?'**
  String apptDeleteContent(String title);

  /// No description provided for @apptReminderMinutes.
  ///
  /// In de, this message translates to:
  /// **'{minutes} Min. vorher'**
  String apptReminderMinutes(int minutes);

  /// No description provided for @apptRepeatUntilDate.
  ///
  /// In de, this message translates to:
  /// **'(bis {date})'**
  String apptRepeatUntilDate(String date);

  /// No description provided for @aufgabenAuswaehlenCount.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben auswählen ({selected}/{total}):'**
  String aufgabenAuswaehlenCount(int selected, int total);

  /// No description provided for @aufgabenCount.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben ({count})'**
  String aufgabenCount(int count);

  /// No description provided for @aufgabenCountSelected.
  ///
  /// In de, this message translates to:
  /// **'{count} Aufgabe{suffix} ausgewählt'**
  String aufgabenCountSelected(int count, String suffix);

  /// No description provided for @bellaActionStatusCancelled.
  ///
  /// In de, this message translates to:
  /// **'{label} — abgebrochen'**
  String bellaActionStatusCancelled(String label);

  /// No description provided for @bellaActionStatusCreated.
  ///
  /// In de, this message translates to:
  /// **'{label} — erstellt'**
  String bellaActionStatusCreated(String label);

  /// No description provided for @bellaActionStatusFailed.
  ///
  /// In de, this message translates to:
  /// **'{label} — fehlgeschlagen'**
  String bellaActionStatusFailed(String label);

  /// No description provided for @bellaBriefingHttpError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Erstellen des Briefings (HTTP {statusCode}).'**
  String bellaBriefingHttpError(int statusCode);

  /// No description provided for @bellaDailyUsage.
  ///
  /// In de, this message translates to:
  /// **'{used} / {limit} Nachrichten heute'**
  String bellaDailyUsage(int used, int limit);

  /// No description provided for @bellaProactiveDocGap.
  ///
  /// In de, this message translates to:
  /// **'Du hast {days} Tage lang nichts eingetragen'**
  String bellaProactiveDocGap(int days);

  /// No description provided for @bellaProactiveMedReminder.
  ///
  /// In de, this message translates to:
  /// **'Hast du heute dein {name} eingenommen?'**
  String bellaProactiveMedReminder(String name);

  /// No description provided for @bellaProactiveMedReminderMultiple.
  ///
  /// In de, this message translates to:
  /// **'Hast du heute deine Medikamente eingenommen? ({count} ausstehend)'**
  String bellaProactiveMedReminderMultiple(int count);

  /// No description provided for @bellaProactiveOpenTasks.
  ///
  /// In de, this message translates to:
  /// **'Du hast noch {count} offene Aufgaben für heute'**
  String bellaProactiveOpenTasks(int count);

  /// No description provided for @bellaProactiveStreakAtRisk.
  ///
  /// In de, this message translates to:
  /// **'Dein {streak}-Tage-Streak ist in Gefahr!'**
  String bellaProactiveStreakAtRisk(int streak);

  /// No description provided for @benachrichtigungenCountNeu.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen ({count} neu)'**
  String benachrichtigungenCountNeu(int count);

  /// No description provided for @caregiverEntfernt.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde entfernt'**
  String caregiverEntfernt(String name);

  /// No description provided for @cloneErstellt.
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" erstellt'**
  String cloneErstellt(String name);

  /// No description provided for @doctorEntfernt.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde entfernt'**
  String doctorEntfernt(String name);

  /// No description provided for @doctorHinzugefuegt.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde hinzugefügt'**
  String doctorHinzugefuegt(String name);

  /// No description provided for @dokumentGeloescht.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ gelöscht'**
  String dokumentGeloescht(String title);

  /// No description provided for @erstelltVon.
  ///
  /// In de, this message translates to:
  /// **'Created by: {name}'**
  String erstelltVon(String name);

  /// No description provided for @fehlerMitError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String fehlerMitError(String error);

  /// No description provided for @gueltigFuerTage.
  ///
  /// In de, this message translates to:
  /// **'Gültig für {days} Tage'**
  String gueltigFuerTage(int days);

  /// No description provided for @keysErstellt.
  ///
  /// In de, this message translates to:
  /// **'{count} Keys erstellt'**
  String keysErstellt(int count);

  /// No description provided for @medikamentEntfernt.
  ///
  /// In de, this message translates to:
  /// **'{name} entfernt'**
  String medikamentEntfernt(String name);

  /// No description provided for @medikamentWiederhergestellt.
  ///
  /// In de, this message translates to:
  /// **'{name} wiederhergestellt'**
  String medikamentWiederhergestellt(String name);

  /// No description provided for @medikamentWirdEntfernt.
  ///
  /// In de, this message translates to:
  /// **'{name} wird entfernt.'**
  String medikamentWirdEntfernt(String name);

  /// No description provided for @mitarbeiterAction.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter {action}'**
  String mitarbeiterAction(String action);

  /// No description provided for @mitarbeiterEntfernt.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde entfernt'**
  String mitarbeiterEntfernt(String name);

  /// No description provided for @nameWurdeEntsperrt.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde entsperrt.'**
  String nameWurdeEntsperrt(String name);

  /// No description provided for @nameWurdeGeloescht.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde gelöscht.'**
  String nameWurdeGeloescht(String name);

  /// No description provided for @nameWurdeGesperrt.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde gesperrt.'**
  String nameWurdeGesperrt(String name);

  /// No description provided for @neuesPasswortFuer.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort für {name}'**
  String neuesPasswortFuer(String name);

  /// No description provided for @noSearchResults.
  ///
  /// In de, this message translates to:
  /// **'Keine Ergebnisse für „{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @notizLoeschenBestaetigung.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ wirklich löschen?'**
  String notizLoeschenBestaetigung(String title);

  /// No description provided for @partnerAnzeigenCount.
  ///
  /// In de, this message translates to:
  /// **'Partner-Anzeigen ({count})'**
  String partnerAnzeigenCount(int count);

  /// No description provided for @pushAnEmail.
  ///
  /// In de, this message translates to:
  /// **'Push to {email}'**
  String pushAnEmail(String email);

  /// No description provided for @pushAnEmailGesendet.
  ///
  /// In de, this message translates to:
  /// **'Push sent to {email}.'**
  String pushAnEmailGesendet(String email);

  /// No description provided for @pushAnTargetGesendet.
  ///
  /// In de, this message translates to:
  /// **'Push to {target} sent!'**
  String pushAnTargetGesendet(String target);

  /// No description provided for @rfActiveBadge.
  ///
  /// In de, this message translates to:
  /// **'{count} aktiv'**
  String rfActiveBadge(int count);

  /// No description provided for @rfActiveCount.
  ///
  /// In de, this message translates to:
  /// **'Aktiv ({count})'**
  String rfActiveCount(int count);

  /// No description provided for @rfLevelBadge.
  ///
  /// In de, this message translates to:
  /// **'Level: {level}'**
  String rfLevelBadge(String level);

  /// No description provided for @rfResolvedCount.
  ///
  /// In de, this message translates to:
  /// **'Verlauf ({count})'**
  String rfResolvedCount(int count);

  /// No description provided for @rolleGeaendert.
  ///
  /// In de, this message translates to:
  /// **'Rolle geändert zu „{role}\".'**
  String rolleGeaendert(String role);

  /// No description provided for @statusMitLabel.
  ///
  /// In de, this message translates to:
  /// **'Status: {label}'**
  String statusMitLabel(String label);

  /// No description provided for @tageVergeben.
  ///
  /// In de, this message translates to:
  /// **'{days} Tage gewährt'**
  String tageVergeben(int days);

  /// No description provided for @ticketsCountOffen.
  ///
  /// In de, this message translates to:
  /// **'Tickets ({count} open)'**
  String ticketsCountOffen(int count);

  /// No description provided for @timelineDoneOfTotal.
  ///
  /// In de, this message translates to:
  /// **'{done}/{total} erledigt'**
  String timelineDoneOfTotal(int done, int total);

  /// No description provided for @timelineDueAttention.
  ///
  /// In de, this message translates to:
  /// **'{count} heute zu erledigen'**
  String timelineDueAttention(int count);

  /// No description provided for @timelineNextUp.
  ///
  /// In de, this message translates to:
  /// **'Weiter: {title}'**
  String timelineNextUp(String title);

  /// No description provided for @timelinePhaseProgress.
  ///
  /// In de, this message translates to:
  /// **'{done}/{total} erledigt'**
  String timelinePhaseProgress(int done, int total);

  /// No description provided for @timelineProgressPercent.
  ///
  /// In de, this message translates to:
  /// **'{percent}% erledigt – weiter so!'**
  String timelineProgressPercent(int percent);

  /// No description provided for @timelineStickyDoneOfTotal.
  ///
  /// In de, this message translates to:
  /// **'{done} von {total} erledigt'**
  String timelineStickyDoneOfTotal(int done, int total);

  /// No description provided for @timelineStickyDue.
  ///
  /// In de, this message translates to:
  /// **'{count} fällig'**
  String timelineStickyDue(int count);

  /// No description provided for @timelineStickyToday.
  ///
  /// In de, this message translates to:
  /// **'{count} heute'**
  String timelineStickyToday(int count);

  /// No description provided for @timelineStreakDays.
  ///
  /// In de, this message translates to:
  /// **'{count} Tage'**
  String timelineStreakDays(int count);

  /// No description provided for @timelineTasksPlanned.
  ///
  /// In de, this message translates to:
  /// **'{count} Aufgaben für heute geplant'**
  String timelineTasksPlanned(int count);

  /// No description provided for @unwiderruflichLoeschen.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ wird dauerhaft gelöscht.'**
  String unwiderruflichLoeschen(String title);

  /// No description provided for @userAktionFehler.
  ///
  /// In de, this message translates to:
  /// **'Nutzer konnte nicht {action}t werden.'**
  String userAktionFehler(String action);

  /// No description provided for @vorlageErstellt.
  ///
  /// In de, this message translates to:
  /// **'Vorlage „{name}\" erstellt'**
  String vorlageErstellt(String name);

  /// No description provided for @vorlageLoeschenBestaetigung.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du \"{name}\" wirklich löschen?'**
  String vorlageLoeschenBestaetigung(String name);

  /// No description provided for @vorlageUebernommen.
  ///
  /// In de, this message translates to:
  /// **'„{name}\" in eigene Vorlagen kopiert'**
  String vorlageUebernommen(String name);

  /// No description provided for @warnLastCheck.
  ///
  /// In de, this message translates to:
  /// **'Letzter Check: {label} · {date}'**
  String warnLastCheck(String label, String date);

  /// No description provided for @warnzeichenGespeichert.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen-Check gespeichert ({level})'**
  String warnzeichenGespeichert(String level);

  /// No description provided for @accountUndRechtliches.
  ///
  /// In de, this message translates to:
  /// **'Account & Rechtliches'**
  String get accountUndRechtliches;

  /// No description provided for @actionCall112.
  ///
  /// In de, this message translates to:
  /// **'112 anrufen'**
  String get actionCall112;

  /// No description provided for @actionUnlock.
  ///
  /// In de, this message translates to:
  /// **'Entsperren'**
  String get actionUnlock;

  /// No description provided for @aktiveWarnungenUndNotfallaktionenPruefen.
  ///
  /// In de, this message translates to:
  /// **'Aktive Warnungen und Notfallaktionen prüfen.'**
  String get aktiveWarnungenUndNotfallaktionenPruefen;

  /// No description provided for @alertNotruf112.
  ///
  /// In de, this message translates to:
  /// **'Notruf 112'**
  String get alertNotruf112;

  /// No description provided for @alleAbwaehlen.
  ///
  /// In de, this message translates to:
  /// **'Alle abwählen'**
  String get alleAbwaehlen;

  /// No description provided for @alleAuswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Alle auswählen'**
  String get alleAuswaehlen;

  /// No description provided for @alleKategorienErledigt.
  ///
  /// In de, this message translates to:
  /// **'Alle Kategorien erledigt!'**
  String get alleKategorienErledigt;

  /// No description provided for @alleTermineImBlick.
  ///
  /// In de, this message translates to:
  /// **'Alle Termine im Blick'**
  String get alleTermineImBlick;

  /// No description provided for @allesErledigt.
  ///
  /// In de, this message translates to:
  /// **'Alles erledigt!'**
  String get allesErledigt;

  /// No description provided for @analyticsNutrition.
  ///
  /// In de, this message translates to:
  /// **'Ernährung'**
  String get analyticsNutrition;

  /// No description provided for @analyticsOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get analyticsOverview;

  /// No description provided for @analyticsPain.
  ///
  /// In de, this message translates to:
  /// **'Schmerzen'**
  String get analyticsPain;

  /// No description provided for @analyticsVitals.
  ///
  /// In de, this message translates to:
  /// **'Vitaldaten'**
  String get analyticsVitals;

  /// No description provided for @analyticsWounds.
  ///
  /// In de, this message translates to:
  /// **'Wunden'**
  String get analyticsWounds;

  /// No description provided for @apptAllDay.
  ///
  /// In de, this message translates to:
  /// **'Ganztägig'**
  String get apptAllDay;

  /// No description provided for @arztAnrufen.
  ///
  /// In de, this message translates to:
  /// **'Arzt anrufen'**
  String get arztAnrufen;

  /// No description provided for @arztKontaktieren.
  ///
  /// In de, this message translates to:
  /// **'Arzt kontaktieren'**
  String get arztKontaktieren;

  /// No description provided for @aufgabeHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe hinzufügen'**
  String get aufgabeHinzufuegen;

  /// No description provided for @aufgabenUndTimeline.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben & Timeline'**
  String get aufgabenUndTimeline;

  /// No description provided for @aufmerksamkeitErforderlich.
  ///
  /// In de, this message translates to:
  /// **'Aufmerksamkeit erforderlich'**
  String get aufmerksamkeitErforderlich;

  /// No description provided for @ausGalerie.
  ///
  /// In de, this message translates to:
  /// **'Aus Galerie'**
  String get ausGalerie;

  /// No description provided for @ausZwischenNablageEinfuegen.
  ///
  /// In de, this message translates to:
  /// **'Aus Zwischenablage einfügen'**
  String get ausZwischenNablageEinfuegen;

  /// No description provided for @authServiceGoogleSignInWasCancelledByTheUser.
  ///
  /// In de, this message translates to:
  /// **'Der Google-Anmeldevorgang wurde abgebrochen.'**
  String get authServiceGoogleSignInWasCancelledByTheUser;

  /// No description provided for @badgeMedicationHero.
  ///
  /// In de, this message translates to:
  /// **'Medikamenten-Held'**
  String get badgeMedicationHero;

  /// No description provided for @badgeMedicationHeroDesc.
  ///
  /// In de, this message translates to:
  /// **'7 Tage ohne vergessene Dosis'**
  String get badgeMedicationHeroDesc;

  /// No description provided for @badgeMoodTrackerDesc.
  ///
  /// In de, this message translates to:
  /// **'Stimmung 20 Mal dokumentiert'**
  String get badgeMoodTrackerDesc;

  /// No description provided for @badgePainTracker.
  ///
  /// In de, this message translates to:
  /// **'Schmerz-Tracker'**
  String get badgePainTracker;

  /// No description provided for @badgePainTrackerDesc.
  ///
  /// In de, this message translates to:
  /// **'Schmerzen 20 Mal dokumentiert'**
  String get badgePainTrackerDesc;

  /// No description provided for @bandscheibenOP44Jahre.
  ///
  /// In de, this message translates to:
  /// **'Bandscheiben-OP, 44 Jahre'**
  String get bandscheibenOP44Jahre;

  /// No description provided for @befundeUndBerichte.
  ///
  /// In de, this message translates to:
  /// **'Befunde & Berichte'**
  String get befundeUndBerichte;

  /// No description provided for @begleitetWerden.
  ///
  /// In de, this message translates to:
  /// **'Begleitet werden'**
  String get begleitetWerden;

  /// No description provided for @bellaAIGespraechsexport.
  ///
  /// In de, this message translates to:
  /// **'Bella AI – Gesprächsexport'**
  String get bellaAIGespraechsexport;

  /// No description provided for @bevorIchLoslegenKannBraucheIchKurzDeineEinwilligung.
  ///
  /// In de, this message translates to:
  /// **'Bevor ich loslegen kann, brauche ich kurz deine Einwilligung'**
  String get bevorIchLoslegenKannBraucheIchKurzDeineEinwilligung;

  /// No description provided for @bevorstehendeArztUndKliniktermine.
  ///
  /// In de, this message translates to:
  /// **'Bevorstehende Arzt- und Kliniktermine'**
  String get bevorstehendeArztUndKliniktermine;

  /// No description provided for @bildAuswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Bild auswählen'**
  String get bildAuswaehlen;

  /// No description provided for @bitteGibEinenKeyEin.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Key ein.'**
  String get bitteGibEinenKeyEin;

  /// No description provided for @blutwerteAbgegeben.
  ///
  /// In de, this message translates to:
  /// **'Blutwerte abgegeben'**
  String get blutwerteAbgegeben;

  /// No description provided for @caregiverRemoved.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde entfernt'**
  String caregiverRemoved(String name);

  /// No description provided for @challengeGeschafft.
  ///
  /// In de, this message translates to:
  /// **'Challenge geschafft!'**
  String get challengeGeschafft;

  /// No description provided for @checklisteFuerDieKlinik.
  ///
  /// In de, this message translates to:
  /// **'Checkliste für die Klinik'**
  String get checklisteFuerDieKlinik;

  /// No description provided for @cpAbdominalBelt.
  ///
  /// In de, this message translates to:
  /// **'Bauchgurt/Stütze prüfen'**
  String get cpAbdominalBelt;

  /// No description provided for @cpAbdominalBeltDesc.
  ///
  /// In de, this message translates to:
  /// **'Sitz und Trageweise prüfen'**
  String get cpAbdominalBeltDesc;

  /// No description provided for @cpAbdominalProtection.
  ///
  /// In de, this message translates to:
  /// **'Bauchmuskelschutz'**
  String get cpAbdominalProtection;

  /// No description provided for @cpAbdominalProtectionDesc.
  ///
  /// In de, this message translates to:
  /// **'Nicht pressen, beim Aufstehen zur Seite rollen'**
  String get cpAbdominalProtectionDesc;

  /// No description provided for @cpAdmission.
  ///
  /// In de, this message translates to:
  /// **'Aufnahme'**
  String get cpAdmission;

  /// No description provided for @cpAdmissionDesc.
  ///
  /// In de, this message translates to:
  /// **'Bitte pünktlich in der Klinik melden'**
  String get cpAdmissionDesc;

  /// No description provided for @cpBandageCheck.
  ///
  /// In de, this message translates to:
  /// **'Verband kontrollieren'**
  String get cpBandageCheck;

  /// No description provided for @cpBandageCheckDesc.
  ///
  /// In de, this message translates to:
  /// **'Verbandszustand prüfen und dokumentieren'**
  String get cpBandageCheckDesc;

  /// No description provided for @cpBreathingExercises.
  ///
  /// In de, this message translates to:
  /// **'Atemübungen'**
  String get cpBreathingExercises;

  /// No description provided for @cpBreathingExercisesHeartDesc.
  ///
  /// In de, this message translates to:
  /// **'Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen'**
  String get cpBreathingExercisesHeartDesc;

  /// No description provided for @cpBreathingExercisesSpineDesc.
  ///
  /// In de, this message translates to:
  /// **'Tiefe Atemzüge – Rücken gerade, sanft atmen'**
  String get cpBreathingExercisesSpineDesc;

  /// No description provided for @cpCardiacRehabExercises.
  ///
  /// In de, this message translates to:
  /// **'Herzreha-Übungen'**
  String get cpCardiacRehabExercises;

  /// No description provided for @cpCardiacRehabExercisesDesc.
  ///
  /// In de, this message translates to:
  /// **'Leichtes Gehen, Kreislauf langsam aufbauen'**
  String get cpCardiacRehabExercisesDesc;

  /// No description provided for @cpCardiacRehabWalk.
  ///
  /// In de, this message translates to:
  /// **'Herzreha-Spaziergang'**
  String get cpCardiacRehabWalk;

  /// No description provided for @cpCardiacRehabWalkDesc.
  ///
  /// In de, this message translates to:
  /// **'Gehstrecke langsam steigern, Puls beobachten'**
  String get cpCardiacRehabWalkDesc;

  /// No description provided for @cpCheckDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente prüfen'**
  String get cpCheckDocuments;

  /// No description provided for @cpCheckDocumentsDesc.
  ///
  /// In de, this message translates to:
  /// **'Krankenkassenkarte und Unterlagen vorbereiten'**
  String get cpCheckDocumentsDesc;

  /// No description provided for @cpCheckFasting.
  ///
  /// In de, this message translates to:
  /// **'Nüchternheit prüfen'**
  String get cpCheckFasting;

  /// No description provided for @cpCheckFastingDesc.
  ///
  /// In de, this message translates to:
  /// **'Keine Nahrung oder Flüssigkeit wie angewiesen'**
  String get cpCheckFastingDesc;

  /// No description provided for @cpCheckFluidIntake.
  ///
  /// In de, this message translates to:
  /// **'Flüssigkeitszufuhr prüfen'**
  String get cpCheckFluidIntake;

  /// No description provided for @cpCheckFluidIntakeDesc.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 1,5 Liter Flüssigkeit täglich'**
  String get cpCheckFluidIntakeDesc;

  /// No description provided for @cpCheckOrthosis.
  ///
  /// In de, this message translates to:
  /// **'Orthese/Korsett prüfen'**
  String get cpCheckOrthosis;

  /// No description provided for @cpCheckOrthosisDesc.
  ///
  /// In de, this message translates to:
  /// **'Sitz und Tragezeit prüfen'**
  String get cpCheckOrthosisDesc;

  /// No description provided for @cpCheckVitals.
  ///
  /// In de, this message translates to:
  /// **'Vitalzeichen prüfen'**
  String get cpCheckVitals;

  /// No description provided for @cpCheckVitalsDesc.
  ///
  /// In de, this message translates to:
  /// **'Puls/Temperatur kurz notieren'**
  String get cpCheckVitalsDesc;

  /// No description provided for @cpCheckWarnings.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen prüfen'**
  String get cpCheckWarnings;

  /// No description provided for @cpCheckWarningsDesc.
  ///
  /// In de, this message translates to:
  /// **'Fieber, Rötung, Schwellung, starke Schmerzen?'**
  String get cpCheckWarningsDesc;

  /// No description provided for @cpCompressionStockings.
  ///
  /// In de, this message translates to:
  /// **'Kompressionsstrümpfe prüfen'**
  String get cpCompressionStockings;

  /// No description provided for @cpCompressionStockingsDesc.
  ///
  /// In de, this message translates to:
  /// **'Sitz und Zustand der Strümpfe prüfen'**
  String get cpCompressionStockingsDesc;

  /// No description provided for @cpConfirmOpInfo.
  ///
  /// In de, this message translates to:
  /// **'OP-Informationen bestätigen'**
  String get cpConfirmOpInfo;

  /// No description provided for @cpConfirmOpInfoDesc.
  ///
  /// In de, this message translates to:
  /// **'Offene Fragen mit dem Team klären'**
  String get cpConfirmOpInfoDesc;

  /// No description provided for @cpDietProgression.
  ///
  /// In de, this message translates to:
  /// **'Kostaufbau'**
  String get cpDietProgression;

  /// No description provided for @cpDietProgressionDesc.
  ///
  /// In de, this message translates to:
  /// **'Leichte Kost, Schonkost → langsam steigern'**
  String get cpDietProgressionDesc;

  /// No description provided for @cpDocumentBowel.
  ///
  /// In de, this message translates to:
  /// **'Stuhlgang dokumentieren'**
  String get cpDocumentBowel;

  /// No description provided for @cpDocumentBowelDesc.
  ///
  /// In de, this message translates to:
  /// **'Verdauung beobachten – wichtig für den Kostaufbau'**
  String get cpDocumentBowelDesc;

  /// No description provided for @cpEveningDose.
  ///
  /// In de, this message translates to:
  /// **'Abenddosis wie vorgeschrieben'**
  String get cpEveningDose;

  /// No description provided for @cpFinalCheck.
  ///
  /// In de, this message translates to:
  /// **'Abschlusskontrolle'**
  String get cpFinalCheck;

  /// No description provided for @cpFinalCheckDesc.
  ///
  /// In de, this message translates to:
  /// **'Abschlussuntersuchung und Entlassung'**
  String get cpFinalCheckDesc;

  /// No description provided for @cpFirstMobilisation.
  ///
  /// In de, this message translates to:
  /// **'Erste Mobilisation'**
  String get cpFirstMobilisation;

  /// No description provided for @cpFirstMobilisationDesc.
  ///
  /// In de, this message translates to:
  /// **'Kurz aufsetzen/aufstehen mit Unterstützung'**
  String get cpFirstMobilisationDesc;

  /// No description provided for @cpFollowUpAppointment.
  ///
  /// In de, this message translates to:
  /// **'Nachsorgetermin'**
  String get cpFollowUpAppointment;

  /// No description provided for @cpFollowUpDesc1.
  ///
  /// In de, this message translates to:
  /// **'Fortschrittskontrolle in der Klinik'**
  String get cpFollowUpDesc1;

  /// No description provided for @cpFollowUpDesc2.
  ///
  /// In de, this message translates to:
  /// **'Zweite Fortschrittskontrolle'**
  String get cpFollowUpDesc2;

  /// No description provided for @cpFollowUpDesc3.
  ///
  /// In de, this message translates to:
  /// **'Dritte Fortschrittskontrolle'**
  String get cpFollowUpDesc3;

  /// No description provided for @cpGaitTraining.
  ///
  /// In de, this message translates to:
  /// **'Gangschulung'**
  String get cpGaitTraining;

  /// No description provided for @cpGaitTrainingDesc.
  ///
  /// In de, this message translates to:
  /// **'Sicheres Gehen mit/ohne Hilfsmittel üben'**
  String get cpGaitTrainingDesc;

  /// No description provided for @cpGoForWalk.
  ///
  /// In de, this message translates to:
  /// **'Spazieren gehen'**
  String get cpGoForWalk;

  /// No description provided for @cpGoForWalkDesc.
  ///
  /// In de, this message translates to:
  /// **'Jeden Tag etwas weiter laufen – Kreislauf stärken'**
  String get cpGoForWalkDesc;

  /// No description provided for @cpIncreaseActivity.
  ///
  /// In de, this message translates to:
  /// **'Aktivität steigern'**
  String get cpIncreaseActivity;

  /// No description provided for @cpIncreaseActivityDesc.
  ///
  /// In de, this message translates to:
  /// **'Aktivität langsam steigern – auf Körpersignale achten'**
  String get cpIncreaseActivityDesc;

  /// No description provided for @cpInformCompanion.
  ///
  /// In de, this message translates to:
  /// **'Begleitperson informieren'**
  String get cpInformCompanion;

  /// No description provided for @cpInformCompanionDesc.
  ///
  /// In de, this message translates to:
  /// **'Fahrt und Treffpunkt abstimmen'**
  String get cpInformCompanionDesc;

  /// No description provided for @cpLegExercises.
  ///
  /// In de, this message translates to:
  /// **'Beinübungen durchführen'**
  String get cpLegExercises;

  /// No description provided for @cpLegExercisesDesc.
  ///
  /// In de, this message translates to:
  /// **'Füße kreisen, Beine anspannen – Thromboseprophylaxe'**
  String get cpLegExercisesDesc;

  /// No description provided for @cpMorningDose.
  ///
  /// In de, this message translates to:
  /// **'Morgendosis wie vorgeschrieben'**
  String get cpMorningDose;

  /// No description provided for @cpNoonDose.
  ///
  /// In de, this message translates to:
  /// **'Mittagsdosis wie vorgeschrieben'**
  String get cpNoonDose;

  /// No description provided for @cpNormalDietProgression.
  ///
  /// In de, this message translates to:
  /// **'Normale Ernährung aufbauen'**
  String get cpNormalDietProgression;

  /// No description provided for @cpNormalDietProgressionDesc.
  ///
  /// In de, this message translates to:
  /// **'Verdauung beobachten – schrittweise zur normalen Ernährung'**
  String get cpNormalDietProgressionDesc;

  /// No description provided for @cpObserveWound.
  ///
  /// In de, this message translates to:
  /// **'Wunde beobachten'**
  String get cpObserveWound;

  /// No description provided for @cpObserveWoundDesc.
  ///
  /// In de, this message translates to:
  /// **'Heilungsverlauf beobachten und dokumentieren'**
  String get cpObserveWoundDesc;

  /// No description provided for @cpPackHospitalBag.
  ///
  /// In de, this message translates to:
  /// **'Kliniktasche packen'**
  String get cpPackHospitalBag;

  /// No description provided for @cpPackHospitalBagDesc.
  ///
  /// In de, this message translates to:
  /// **'Dokumente, Kleidung und Ladekabel einpacken'**
  String get cpPackHospitalBagDesc;

  /// No description provided for @cpPainDiary.
  ///
  /// In de, this message translates to:
  /// **'Schmerztagebuch'**
  String get cpPainDiary;

  /// No description provided for @cpPainDiaryDesc.
  ///
  /// In de, this message translates to:
  /// **'Schmerzverlauf dokumentieren – bessert es sich?'**
  String get cpPainDiaryDesc;

  /// No description provided for @cpPhysioExercises.
  ///
  /// In de, this message translates to:
  /// **'Physiotherapie-Übungen'**
  String get cpPhysioExercises;

  /// No description provided for @cpPhysioExercisesDesc.
  ///
  /// In de, this message translates to:
  /// **'Übungen wie angewiesen durchführen'**
  String get cpPhysioExercisesDesc;

  /// No description provided for @cpRecordPainLevel.
  ///
  /// In de, this message translates to:
  /// **'Schmerzniveau erfassen'**
  String get cpRecordPainLevel;

  /// No description provided for @cpRecordPainLevelDesc.
  ///
  /// In de, this message translates to:
  /// **'Schmerzniveau in der App eingeben'**
  String get cpRecordPainLevelDesc;

  /// No description provided for @cpScarCare.
  ///
  /// In de, this message translates to:
  /// **'Narbenpflege'**
  String get cpScarCare;

  /// No description provided for @cpScarCareDesc.
  ///
  /// In de, this message translates to:
  /// **'Narbe sanft eincremen und beobachten'**
  String get cpScarCareDesc;

  /// No description provided for @cpSpineProtection.
  ///
  /// In de, this message translates to:
  /// **'Rückenschutzhaltung'**
  String get cpSpineProtection;

  /// No description provided for @cpSpineProtectionDesc.
  ///
  /// In de, this message translates to:
  /// **'Kein Verdrehen oder Beugen der Wirbelsäule'**
  String get cpSpineProtectionDesc;

  /// No description provided for @cpStabilisationExercises.
  ///
  /// In de, this message translates to:
  /// **'Stabilisationsübungen'**
  String get cpStabilisationExercises;

  /// No description provided for @cpStabilisationExercisesDesc.
  ///
  /// In de, this message translates to:
  /// **'Rumpfstabilisation wie angewiesen – schrittweise steigern'**
  String get cpStabilisationExercisesDesc;

  /// No description provided for @cpSternumProtection.
  ///
  /// In de, this message translates to:
  /// **'Sternumschutz'**
  String get cpSternumProtection;

  /// No description provided for @cpSternumProtectionDesc.
  ///
  /// In de, this message translates to:
  /// **'Kein Heben über 5 kg, Arme nah am Körper halten'**
  String get cpSternumProtectionDesc;

  /// No description provided for @cpTakeMedication.
  ///
  /// In de, this message translates to:
  /// **'Medikamente einnehmen'**
  String get cpTakeMedication;

  /// No description provided for @cpTakeWoundPhoto.
  ///
  /// In de, this message translates to:
  /// **'Wundfoto aufnehmen'**
  String get cpTakeWoundPhoto;

  /// No description provided for @cpTakeWoundPhotoDesc.
  ///
  /// In de, this message translates to:
  /// **'Foto zur Fortschrittsverfolgung dokumentieren'**
  String get cpTakeWoundPhotoDesc;

  /// No description provided for @cpTakeWoundPhotoProgress.
  ///
  /// In de, this message translates to:
  /// **'Wundfoto aufnehmen'**
  String get cpTakeWoundPhotoProgress;

  /// No description provided for @cpTakeWoundPhotoProgressDesc.
  ///
  /// In de, this message translates to:
  /// **'Heilungsfortschritt weiter dokumentieren'**
  String get cpTakeWoundPhotoProgressDesc;

  /// No description provided for @cpWeeklySelfCheck.
  ///
  /// In de, this message translates to:
  /// **'Wöchentliche Selbstkontrolle'**
  String get cpWeeklySelfCheck;

  /// No description provided for @cpWeeklySelfCheckDesc.
  ///
  /// In de, this message translates to:
  /// **'Heilungsfortschritt auswerten und dokumentieren'**
  String get cpWeeklySelfCheckDesc;

  /// No description provided for @dasRehaSystemMitTimerIstGoldWert.
  ///
  /// In de, this message translates to:
  /// **'Das Reha-System mit Timer ist Gold wert.'**
  String get dasRehaSystemMitTimerIstGoldWert;

  /// No description provided for @datenEingeben.
  ///
  /// In de, this message translates to:
  /// **'Daten eingeben'**
  String get datenEingeben;

  /// No description provided for @debugEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail: {email}'**
  String debugEmail(String email);

  /// No description provided for @debugLinkedPatients.
  ///
  /// In de, this message translates to:
  /// **'Verknüpfte Patienten'**
  String get debugLinkedPatients;

  /// No description provided for @debugNotAvailable.
  ///
  /// In de, this message translates to:
  /// **'nicht verfügbar'**
  String get debugNotAvailable;

  /// No description provided for @debugNotLoggedIn.
  ///
  /// In de, this message translates to:
  /// **'nicht angemeldet'**
  String get debugNotLoggedIn;

  /// No description provided for @debugOnlyForAdmins.
  ///
  /// In de, this message translates to:
  /// **'Nur für Admins verfügbar.'**
  String get debugOnlyForAdmins;

  /// No description provided for @debugOnlyInDebug.
  ///
  /// In de, this message translates to:
  /// **'Nur in Debug-Builds verfügbar.'**
  String get debugOnlyInDebug;

  /// No description provided for @debugRole.
  ///
  /// In de, this message translates to:
  /// **'Rolle: {role}'**
  String debugRole(String role);

  /// No description provided for @debugUid.
  ///
  /// In de, this message translates to:
  /// **'UID: {uid}'**
  String debugUid(String uid);

  /// No description provided for @deineHeutigeChallenge.
  ///
  /// In de, this message translates to:
  /// **'Deine heutige Challenge'**
  String get deineHeutigeChallenge;

  /// No description provided for @deineWochenZusammenfassung.
  ///
  /// In de, this message translates to:
  /// **'Deine Wochen-Zusammenfassung'**
  String get deineWochenZusammenfassung;

  /// No description provided for @derNutzerVerliertSofortDenProZugang.
  ///
  /// In de, this message translates to:
  /// **'Der Nutzer verliert sofort den Pro-Zugang.'**
  String get derNutzerVerliertSofortDenProZugang;

  /// No description provided for @dieserKeyIstAbgelaufen.
  ///
  /// In de, this message translates to:
  /// **'Dieser Key ist abgelaufen.'**
  String get dieserKeyIstAbgelaufen;

  /// No description provided for @dokuHubFuerKameraUndGalerie.
  ///
  /// In de, this message translates to:
  /// **'Doku-Hub für Kamera & Galerie'**
  String get dokuHubFuerKameraUndGalerie;

  /// No description provided for @dokumenteHochladen.
  ///
  /// In de, this message translates to:
  /// **'Dokumente hochladen'**
  String get dokumenteHochladen;

  /// No description provided for @duHastAlleAufgabenAbgeschlossenGoennDirEinePause.
  ///
  /// In de, this message translates to:
  /// **'Du hast alle Aufgaben abgeschlossen. Gönn dir eine Pause.'**
  String get duHastAlleAufgabenAbgeschlossenGoennDirEinePause;

  /// No description provided for @duMusstAngemeldetSein.
  ///
  /// In de, this message translates to:
  /// **'Du musst angemeldet sein.'**
  String get duMusstAngemeldetSein;

  /// No description provided for @einnahmeDokumentieren.
  ///
  /// In de, this message translates to:
  /// **'Einnahme dokumentieren'**
  String get einnahmeDokumentieren;

  /// No description provided for @empty7DaysNoData.
  ///
  /// In de, this message translates to:
  /// **'7 Tage: keine Daten'**
  String get empty7DaysNoData;

  /// No description provided for @emptyNoMacros.
  ///
  /// In de, this message translates to:
  /// **'Keine Makros erfasst'**
  String get emptyNoMacros;

  /// No description provided for @emptyNoNotifications.
  ///
  /// In de, this message translates to:
  /// **'Keine Benachrichtigungen'**
  String get emptyNoNotifications;

  /// No description provided for @emptyNoRedFlags.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Red Flags'**
  String get emptyNoRedFlags;

  /// No description provided for @emptyNoVitals.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Vitaldaten erfasst'**
  String get emptyNoVitals;

  /// No description provided for @emptyNoVitalsShort.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Vitaldaten'**
  String get emptyNoVitalsShort;

  /// No description provided for @emptyTasksInPlan.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Aufgaben im Plan.'**
  String get emptyTasksInPlan;

  /// No description provided for @emptyTodayNoEntries.
  ///
  /// In de, this message translates to:
  /// **'Heute: keine Einträge'**
  String get emptyTodayNoEntries;

  /// No description provided for @erinnerungenAnMedikamenteneinnahme.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen an Medikamenteneinnahme'**
  String get erinnerungenAnMedikamenteneinnahme;

  /// No description provided for @erstelle.
  ///
  /// In de, this message translates to:
  /// **'Erstelle…'**
  String get erstelle;

  /// No description provided for @erstelleDeinKontoInWenigenSekunden.
  ///
  /// In de, this message translates to:
  /// **'Erstelle dein Konto in wenigen Sekunden.'**
  String get erstelleDeinKontoInWenigenSekunden;

  /// No description provided for @erstelleEineEigeneAufgabeFuerDeineOPVorbereitung.
  ///
  /// In de, this message translates to:
  /// **'Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.'**
  String get erstelleEineEigeneAufgabeFuerDeineOPVorbereitung;

  /// No description provided for @erstelleUndVerwalteDeineOPBezogenenTermine.
  ///
  /// In de, this message translates to:
  /// **'Erstelle und verwalte deine OP-bezogenen Termine.'**
  String get erstelleUndVerwalteDeineOPBezogenenTermine;

  /// No description provided for @familyOverviewAufmerksamkeitErforderlich.
  ///
  /// In de, this message translates to:
  /// **'Aufmerksamkeit erforderlich'**
  String get familyOverviewAufmerksamkeitErforderlich;

  /// No description provided for @fehlerBeimEinloesenBitteVersucheEsErneut.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Einlösen. Bitte versuche es erneut.'**
  String get fehlerBeimEinloesenBitteVersucheEsErneut;

  /// No description provided for @fehlerBeimSpeichernErneut.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern. Bitte erneut versuchen.'**
  String get fehlerBeimSpeichernErneut;

  /// No description provided for @fehlerGeneric.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String fehlerGeneric(String error);

  /// No description provided for @fehlerMitDetails.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String fehlerMitDetails(String error);

  /// No description provided for @fotoAufnehmen.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get fotoAufnehmen;

  /// No description provided for @fragenUndNotizen.
  ///
  /// In de, this message translates to:
  /// **'Fragen & Notizen'**
  String get fragenUndNotizen;

  /// No description provided for @fuegeDeineOPInformationenHinzu.
  ///
  /// In de, this message translates to:
  /// **'Füge deine OP-Informationen hinzu.'**
  String get fuegeDeineOPInformationenHinzu;

  /// No description provided for @googleSignInWasCancelledByTheUser.
  ///
  /// In de, this message translates to:
  /// **'Der Google-Anmeldevorgang wurde abgebrochen.'**
  String get googleSignInWasCancelledByTheUser;

  /// No description provided for @habenSieAtembeschwerdenOderKurzatmigkeit.
  ///
  /// In de, this message translates to:
  /// **'Haben Sie Atembeschwerden oder Kurzatmigkeit?'**
  String get habenSieAtembeschwerdenOderKurzatmigkeit;

  /// No description provided for @halteEinenFreienEintragInDeinerTimelineFest.
  ///
  /// In de, this message translates to:
  /// **'Halte einen freien Eintrag in deiner Timeline fest.'**
  String get halteEinenFreienEintragInDeinerTimelineFest;

  /// No description provided for @hintDescribeInDetail.
  ///
  /// In de, this message translates to:
  /// **'Beschreibe dein Anliegen so genau wie möglich…'**
  String get hintDescribeInDetail;

  /// No description provided for @hintShortDescription.
  ///
  /// In de, this message translates to:
  /// **'Kurze Beschreibung deines Anliegens'**
  String get hintShortDescription;

  /// No description provided for @ichWarNervoesVorDerOPDieRedFlagWarnung.
  ///
  /// In de, this message translates to:
  /// **'Ich war nervös vor der OP. Die Red-Flag Warnung'**
  String get ichWarNervoesVorDerOPDieRedFlagWarnung;

  /// No description provided for @itemDeletedMessage.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ gelöscht'**
  String itemDeletedMessage(String title);

  /// No description provided for @itemDeletedPermanently.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ wird dauerhaft gelöscht.'**
  String itemDeletedPermanently(String title);

  /// No description provided for @keyNichtGefunden.
  ///
  /// In de, this message translates to:
  /// **'Key nicht gefunden.'**
  String get keyNichtGefunden;

  /// No description provided for @knieTEP58Jahre.
  ///
  /// In de, this message translates to:
  /// **'Knie-TEP, 58 Jahre'**
  String get knieTEP58Jahre;

  /// No description provided for @kritischerSymptomCheck.
  ///
  /// In de, this message translates to:
  /// **'Kritischer Symptom-Check'**
  String get kritischerSymptomCheck;

  /// No description provided for @labelCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get labelCategory;

  /// No description provided for @labelContentOptional.
  ///
  /// In de, this message translates to:
  /// **'Inhalt (optional)'**
  String get labelContentOptional;

  /// No description provided for @labelCustomMinutes.
  ///
  /// In de, this message translates to:
  /// **'Eigene Minuten'**
  String get labelCustomMinutes;

  /// No description provided for @labelDescriptionOptional.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung (optional)'**
  String get labelDescriptionOptional;

  /// No description provided for @labelInviteCode.
  ///
  /// In de, this message translates to:
  /// **'Einladungscode'**
  String get labelInviteCode;

  /// No description provided for @labelInviteCodeValue.
  ///
  /// In de, this message translates to:
  /// **'Code: {code}'**
  String labelInviteCodeValue(String code);

  /// No description provided for @labelLinkType.
  ///
  /// In de, this message translates to:
  /// **'Link-Typ'**
  String get labelLinkType;

  /// No description provided for @labelLocation.
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get labelLocation;

  /// No description provided for @labelLocationDetails.
  ///
  /// In de, this message translates to:
  /// **'Ortsdetails'**
  String get labelLocationDetails;

  /// No description provided for @labelNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get labelNote;

  /// No description provided for @labelObservation.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung'**
  String get labelObservation;

  /// No description provided for @labelReminder.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get labelReminder;

  /// No description provided for @labelSubject.
  ///
  /// In de, this message translates to:
  /// **'Betreff'**
  String get labelSubject;

  /// No description provided for @labelTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get labelTitle;

  /// No description provided for @labelTitleRequired.
  ///
  /// In de, this message translates to:
  /// **'Titel *'**
  String get labelTitleRequired;

  /// No description provided for @labelType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get labelType;

  /// No description provided for @mahlzeitenUndEmpfehlungen.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeiten & Empfehlungen'**
  String get mahlzeitenUndEmpfehlungen;

  /// No description provided for @measurementSaved.
  ///
  /// In de, this message translates to:
  /// **'Messung gespeichert'**
  String get measurementSaved;

  /// No description provided for @meinePatienten.
  ///
  /// In de, this message translates to:
  /// **'Meine Patienten'**
  String get meinePatienten;

  /// No description provided for @memoAufnehmen.
  ///
  /// In de, this message translates to:
  /// **'Memo aufnehmen'**
  String get memoAufnehmen;

  /// No description provided for @n7Tage.
  ///
  /// In de, this message translates to:
  /// **'Ø 7 Tage'**
  String get n7Tage;

  /// No description provided for @nachDerOP.
  ///
  /// In de, this message translates to:
  /// **'Nach der OP'**
  String get nachDerOP;

  /// No description provided for @nachMeinerKnieOPHatteIchHundertFragen.
  ///
  /// In de, this message translates to:
  /// **'Nach meiner Knie-OP hatte ich hundert Fragen.'**
  String get nachMeinerKnieOPHatteIchHundertFragen;

  /// No description provided for @nachrichtNsenden.
  ///
  /// In de, this message translates to:
  /// **'Nachricht\nsenden'**
  String get nachrichtNsenden;

  /// No description provided for @notifChannelAppointments.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen für bevorstehende Termine'**
  String get notifChannelAppointments;

  /// No description provided for @notifChannelMedication.
  ///
  /// In de, this message translates to:
  /// **'Medikamentenerinnerung'**
  String get notifChannelMedication;

  /// No description provided for @notifChannelMedicationDesc.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Erinnerungen für Medikamente'**
  String get notifChannelMedicationDesc;

  /// No description provided for @notifChannelVitals.
  ///
  /// In de, this message translates to:
  /// **'Vitaldaten-Erinnerung'**
  String get notifChannelVitals;

  /// No description provided for @notifChannelVitalsDesc.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Erinnerung für Vitaldatenmessungen'**
  String get notifChannelVitalsDesc;

  /// No description provided for @notifDoctorAnswered.
  ///
  /// In de, this message translates to:
  /// **'Dr. {name} hat deine Frage beantwortet'**
  String notifDoctorAnswered(String name);

  /// No description provided for @notifMeasureVitals.
  ///
  /// In de, this message translates to:
  /// **'Vitaldaten messen'**
  String get notifMeasureVitals;

  /// No description provided for @notifObservationFrom.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung von {name}'**
  String notifObservationFrom(String name);

  /// No description provided for @notifWoundAlarm.
  ///
  /// In de, this message translates to:
  /// **'Wund-Alarm'**
  String get notifWoundAlarm;

  /// No description provided for @notizErstellen.
  ///
  /// In de, this message translates to:
  /// **'Notiz erstellen'**
  String get notizErstellen;

  /// No description provided for @nutritionProteinG1110.
  ///
  /// In de, this message translates to:
  /// **'Protein (g)'**
  String get nutritionProteinG1110;

  /// No description provided for @oPAngelegt.
  ///
  /// In de, this message translates to:
  /// **'OP angelegt'**
  String get oPAngelegt;

  /// No description provided for @oPTag.
  ///
  /// In de, this message translates to:
  /// **'OP‑Tag'**
  String get oPTag;

  /// No description provided for @oPTagWundeFrischVersorgtSterilerVerbandAngelegt.
  ///
  /// In de, this message translates to:
  /// **'OP‑Tag. Wunde frisch versorgt, steriler Verband angelegt.'**
  String get oPTagWundeFrischVersorgtSterilerVerbandAngelegt;

  /// No description provided for @oeffnetDieRehaUebersichtFuerUebungenUndFortschritt.
  ///
  /// In de, this message translates to:
  /// **'Öffnet die Reha-Übersicht für Übungen und Fortschritt.'**
  String get oeffnetDieRehaUebersichtFuerUebungenUndFortschritt;

  /// No description provided for @operateurUndAnaesthesist.
  ///
  /// In de, this message translates to:
  /// **'Operateur & Anästhesist'**
  String get operateurUndAnaesthesist;

  /// No description provided for @pain7Tage.
  ///
  /// In de, this message translates to:
  /// **'Ø 7 Tage'**
  String get pain7Tage;

  /// No description provided for @painDiary7Tage.
  ///
  /// In de, this message translates to:
  /// **'Ø 7 Tage'**
  String get painDiary7Tage;

  /// No description provided for @patientNhinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Patient\nhinzufügen'**
  String get patientNhinzufuegen;

  /// No description provided for @planeHinUndRueckfahrtZurKlinik.
  ///
  /// In de, this message translates to:
  /// **'Plane Hin- und Rückfahrt zur Klinik.'**
  String get planeHinUndRueckfahrtZurKlinik;

  /// No description provided for @proActiveSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Funktionen freigeschaltet'**
  String get proActiveSubtitle;

  /// No description provided for @proActiveTitle.
  ///
  /// In de, this message translates to:
  /// **'Pro aktiv'**
  String get proActiveTitle;

  /// No description provided for @proEntziehen.
  ///
  /// In de, this message translates to:
  /// **'Pro entziehen'**
  String get proEntziehen;

  /// No description provided for @proGeben.
  ///
  /// In de, this message translates to:
  /// **'Pro vergeben'**
  String get proGeben;

  /// No description provided for @proStatusEntziehen.
  ///
  /// In de, this message translates to:
  /// **'Pro-Status entziehen?'**
  String get proStatusEntziehen;

  /// No description provided for @redFlagCockpit.
  ///
  /// In de, this message translates to:
  /// **'Red-Flag Cockpit'**
  String get redFlagCockpit;

  /// No description provided for @rolleKonnteNichtGeladenWerden.
  ///
  /// In de, this message translates to:
  /// **'Rolle konnte nicht geladen werden.'**
  String get rolleKonnteNichtGeladenWerden;

  /// No description provided for @ruheBewahren.
  ///
  /// In de, this message translates to:
  /// **'Ruhe bewahren'**
  String get ruheBewahren;

  /// No description provided for @schmerzErfassen.
  ///
  /// In de, this message translates to:
  /// **'Schmerz erfassen'**
  String get schmerzErfassen;

  /// No description provided for @setzenOderLegenSieSichHinAtmenSieRuhig.
  ///
  /// In de, this message translates to:
  /// **'Setzen oder legen Sie sich hin. Atmen Sie ruhig.'**
  String get setzenOderLegenSieSichHinAtmenSieRuhig;

  /// No description provided for @sleepEntryEditorNotizOptional.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get sleepEntryEditorNotizOptional;

  /// No description provided for @speichere.
  ///
  /// In de, this message translates to:
  /// **'Speichere…'**
  String get speichere;

  /// No description provided for @speichert.
  ///
  /// In de, this message translates to:
  /// **'Speichert…'**
  String get speichert;

  /// No description provided for @streakGerettet.
  ///
  /// In de, this message translates to:
  /// **'Streak gerettet!'**
  String get streakGerettet;

  /// No description provided for @symptomCheckServiceNotruf112.
  ///
  /// In de, this message translates to:
  /// **'Notruf 112'**
  String get symptomCheckServiceNotruf112;

  /// No description provided for @symptomU2011Check.
  ///
  /// In de, this message translates to:
  /// **'Symptom‑Check'**
  String get symptomU2011Check;

  /// No description provided for @systemVorlageFehler.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String systemVorlageFehler(String error);

  /// No description provided for @timelineRoutesAufgabeHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe hinzufügen'**
  String get timelineRoutesAufgabeHinzufuegen;

  /// No description provided for @timelineRoutesNotizErstellen.
  ///
  /// In de, this message translates to:
  /// **'Notiz erstellen'**
  String get timelineRoutesNotizErstellen;

  /// No description provided for @timelineTransportTitle.
  ///
  /// In de, this message translates to:
  /// **'Transportplanung'**
  String get timelineTransportTitle;

  /// No description provided for @trittMeinemOperationsbegleiterBeiNN.
  ///
  /// In de, this message translates to:
  /// **'Tritt meinem Operationsbegleiter bei!\n\n'**
  String get trittMeinemOperationsbegleiterBeiNN;

  /// No description provided for @uebungenTimerUndFortschritt.
  ///
  /// In de, this message translates to:
  /// **'Übungen, Timer & Fortschritt'**
  String get uebungenTimerUndFortschritt;

  /// No description provided for @updatesProStatusUndAppHinweise.
  ///
  /// In de, this message translates to:
  /// **'Updates, Pro-Status & App-Hinweise'**
  String get updatesProStatusUndAppHinweise;

  /// No description provided for @userBlocked.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde gesperrt.'**
  String userBlocked(String name);

  /// No description provided for @userDeleted.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde gelöscht.'**
  String userDeleted(String name);

  /// No description provided for @userGesperrtEntsperrt.
  ///
  /// In de, this message translates to:
  /// **'Nutzer {action}.'**
  String userGesperrtEntsperrt(String action);

  /// No description provided for @userUnblocked.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde entsperrt.'**
  String userUnblocked(String name);

  /// No description provided for @vitalsNotizOptional.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get vitalsNotizOptional;

  /// No description provided for @vorWaehrendUndNachDerOP.
  ///
  /// In de, this message translates to:
  /// **'Vor, während & nach der OP'**
  String get vorWaehrendUndNachDerOP;

  /// No description provided for @vorlageErzeugen.
  ///
  /// In de, this message translates to:
  /// **'Vorlage erstellen'**
  String get vorlageErzeugen;

  /// No description provided for @warningCheckSaved.
  ///
  /// In de, this message translates to:
  /// **'Warnüberprüfung gespeichert ({level})'**
  String warningCheckSaved(String level);

  /// No description provided for @warnungenBeiKritischenWundkontrollErgebnissen.
  ///
  /// In de, this message translates to:
  /// **'Warnungen bei kritischen Wundkontroll-Ergebnissen'**
  String get warnungenBeiKritischenWundkontrollErgebnissen;

  /// No description provided for @warnungenUndNotfall.
  ///
  /// In de, this message translates to:
  /// **'Warnungen & Notfall'**
  String get warnungenUndNotfall;

  /// No description provided for @wieHastDuGeschlafen.
  ///
  /// In de, this message translates to:
  /// **'Wie hast du geschlafen?'**
  String get wieHastDuGeschlafen;

  /// No description provided for @wieStarkSindIhreSchmerzenImOPBereich.
  ///
  /// In de, this message translates to:
  /// **'Wie stark sind Ihre Schmerzen im OP-Bereich?'**
  String get wieStarkSindIhreSchmerzenImOPBereich;

  /// No description provided for @wirdZugewiesen.
  ///
  /// In de, this message translates to:
  /// **'Wird zugewiesen…'**
  String get wirdZugewiesen;

  /// No description provided for @wunddokumentation.
  ///
  /// In de, this message translates to:
  /// **'Wunddokumentation'**
  String get wunddokumentation;

  /// No description provided for @wundenDokumentieren.
  ///
  /// In de, this message translates to:
  /// **'Wunden dokumentieren'**
  String get wundenDokumentieren;

  /// No description provided for @zusammenfassungFuerDenArzt.
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung für den Arzt'**
  String get zusammenfassungFuerDenArzt;

  /// No description provided for @rtsTitle.
  ///
  /// In de, this message translates to:
  /// **'Sportfreigabe-Test'**
  String get rtsTitle;

  /// No description provided for @rtsNewAssessment.
  ///
  /// In de, this message translates to:
  /// **'Neuen Test starten'**
  String get rtsNewAssessment;

  /// No description provided for @rtsLatestResult.
  ///
  /// In de, this message translates to:
  /// **'Letztes Ergebnis'**
  String get rtsLatestResult;

  /// No description provided for @rtsHistory.
  ///
  /// In de, this message translates to:
  /// **'Testverlauf'**
  String get rtsHistory;

  /// No description provided for @rtsScore.
  ///
  /// In de, this message translates to:
  /// **'Gesamtscore'**
  String get rtsScore;

  /// No description provided for @rtsCleared.
  ///
  /// In de, this message translates to:
  /// **'Freigegeben ✓'**
  String get rtsCleared;

  /// No description provided for @rtsAlmostReady.
  ///
  /// In de, this message translates to:
  /// **'Fast bereit'**
  String get rtsAlmostReady;

  /// No description provided for @rtsNotReady.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht bereit'**
  String get rtsNotReady;

  /// No description provided for @rtsClearedMessage.
  ///
  /// In de, this message translates to:
  /// **'Dein Score liegt über dem Schwellenwert. Du kannst mit sportlicher Belastung beginnen – spreche vorher noch einmal mit deinem Arzt.'**
  String get rtsClearedMessage;

  /// No description provided for @rtsAlmostReadyMessage.
  ///
  /// In de, this message translates to:
  /// **'Du bist auf einem guten Weg. Setze dein Training fort und wiederhole den Test in ein paar Wochen.'**
  String get rtsAlmostReadyMessage;

  /// No description provided for @rtsNotReadyMessage.
  ///
  /// In de, this message translates to:
  /// **'Dein Körper braucht noch etwas Zeit. Konzentriere dich auf Rehabilitation und Kräftigung, bevor du wieder Sport treibst.'**
  String get rtsNotReadyMessage;

  /// No description provided for @rtsEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Bist du bereit für Sport?'**
  String get rtsEmptyTitle;

  /// No description provided for @rtsEmptySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Starte deinen ersten Fitness-Test. Statt starrer Zeitvorgaben misst du Kraft, Balance und Stabilität – und siehst anhand eines Scores, ob du wieder Sport treiben kannst.'**
  String get rtsEmptySubtitle;

  /// No description provided for @rtsAssessmentTitle.
  ///
  /// In de, this message translates to:
  /// **'Fitness-Test'**
  String get rtsAssessmentTitle;

  /// No description provided for @rtsResultTitle.
  ///
  /// In de, this message translates to:
  /// **'Testergebnis'**
  String get rtsResultTitle;

  /// No description provided for @rtsBreakdown.
  ///
  /// In de, this message translates to:
  /// **'Einzelergebnisse'**
  String get rtsBreakdown;

  /// No description provided for @rtsFinishAssessment.
  ///
  /// In de, this message translates to:
  /// **'Auswerten'**
  String get rtsFinishAssessment;

  /// No description provided for @rtsDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Test löschen'**
  String get rtsDeleteTitle;

  /// No description provided for @rtsDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Dieses Testergebnis wird unwiderruflich gelöscht.'**
  String get rtsDeleteConfirm;

  /// No description provided for @rtsValidationHint.
  ///
  /// In de, this message translates to:
  /// **'Bitte fülle alle Pflichtfelder aus.'**
  String get rtsValidationHint;

  /// No description provided for @rtsNotesLabel.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get rtsNotesLabel;

  /// No description provided for @rtsNotesHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Tagesform, Bedingungen …'**
  String get rtsNotesHint;

  /// No description provided for @rtsStepOf.
  ///
  /// In de, this message translates to:
  /// **'Schritt {current}/{total}'**
  String rtsStepOf(String current, String total);

  /// No description provided for @rtsTestLsiTitle.
  ///
  /// In de, this message translates to:
  /// **'Kraftseitenvergleich (LSI)'**
  String get rtsTestLsiTitle;

  /// No description provided for @rtsTestLsiDesc.
  ///
  /// In de, this message translates to:
  /// **'Vergleiche die Leistung der betroffenen Seite mit der gesunden Seite – z.B. Haltezeit beim Einbeinstand oder Wiederholungen einer einbeinigen Übung.'**
  String get rtsTestLsiDesc;

  /// No description provided for @rtsTestLsiHint.
  ///
  /// In de, this message translates to:
  /// **'Führe dieselbe Übung auf beiden Seiten durch und trage die Werte ein. Ein LSI ≥ 90 % gilt als optimale Freigabeschwelle.'**
  String get rtsTestLsiHint;

  /// No description provided for @rtsLsiSeconds.
  ///
  /// In de, this message translates to:
  /// **'Sekunden'**
  String get rtsLsiSeconds;

  /// No description provided for @rtsLsiReps.
  ///
  /// In de, this message translates to:
  /// **'Wiederholungen'**
  String get rtsLsiReps;

  /// No description provided for @rtsLsiAffected.
  ///
  /// In de, this message translates to:
  /// **'Betroffene Seite ({unit})'**
  String rtsLsiAffected(String unit);

  /// No description provided for @rtsLsiHealthy.
  ///
  /// In de, this message translates to:
  /// **'Gesunde Seite ({unit})'**
  String rtsLsiHealthy(String unit);

  /// No description provided for @rtsLsiDetailValue.
  ///
  /// In de, this message translates to:
  /// **'Betroffen: {affected} {unit} / Gesund: {healthy} {unit} → LSI: {percent}'**
  String rtsLsiDetailValue(
    String affected,
    String healthy,
    String unit,
    String percent,
  );

  /// No description provided for @rtsTestBalanceTitle.
  ///
  /// In de, this message translates to:
  /// **'Einbeinstand-Balance'**
  String get rtsTestBalanceTitle;

  /// No description provided for @rtsTestBalanceDesc.
  ///
  /// In de, this message translates to:
  /// **'Stehe auf dem betroffenen Bein und halte die Balance so lang wie möglich. Miss die Zeit in Sekunden.'**
  String get rtsTestBalanceDesc;

  /// No description provided for @rtsTestBalanceHint.
  ///
  /// In de, this message translates to:
  /// **'Führe den Test auf einer stabilen, flachen Fläche durch. 30 Sekunden entsprechen einem vollen Score.'**
  String get rtsTestBalanceHint;

  /// No description provided for @rtsBalanceSeconds.
  ///
  /// In de, this message translates to:
  /// **'Haltezeit (Sekunden)'**
  String get rtsBalanceSeconds;

  /// No description provided for @rtsBalanceDetailValue.
  ///
  /// In de, this message translates to:
  /// **'{seconds} Sekunden'**
  String rtsBalanceDetailValue(String seconds);

  /// No description provided for @rtsTestStabilityTitle.
  ///
  /// In de, this message translates to:
  /// **'Stabilität (Einbeinige Kniebeuge)'**
  String get rtsTestStabilityTitle;

  /// No description provided for @rtsTestStabilityDesc.
  ///
  /// In de, this message translates to:
  /// **'Wie gut kannst du eine kontrollierte einbeinige Kniebeuge auf dem betroffenen Bein durchführen?'**
  String get rtsTestStabilityDesc;

  /// No description provided for @rtsStability1.
  ///
  /// In de, this message translates to:
  /// **'1 – Gar nicht möglich, starke Schmerzen oder fehlende Kontrolle.'**
  String get rtsStability1;

  /// No description provided for @rtsStability2.
  ///
  /// In de, this message translates to:
  /// **'2 – Ansatzweise möglich, aber mit deutlichen Einschränkungen.'**
  String get rtsStability2;

  /// No description provided for @rtsStability3.
  ///
  /// In de, this message translates to:
  /// **'3 – Möglich mit spürbaren Kompensationen oder leichten Schmerzen.'**
  String get rtsStability3;

  /// No description provided for @rtsStability4.
  ///
  /// In de, this message translates to:
  /// **'4 – Fast problemlos, minimale Unsicherheit.'**
  String get rtsStability4;

  /// No description provided for @rtsStability5.
  ///
  /// In de, this message translates to:
  /// **'5 – Vollständig kontrolliert und schmerzfrei.'**
  String get rtsStability5;

  /// No description provided for @rtsStabilityDetailValue.
  ///
  /// In de, this message translates to:
  /// **'Selbstbewertung: {rating} / 5'**
  String rtsStabilityDetailValue(String rating);

  /// No description provided for @rtsTestPainTitle.
  ///
  /// In de, this message translates to:
  /// **'Schmerzfreiheit bei Belastung'**
  String get rtsTestPainTitle;

  /// No description provided for @rtsTestPainDesc.
  ///
  /// In de, this message translates to:
  /// **'Wie stark sind deine Schmerzen bei sportspezifischer Belastung (z. B. Laufen, Springen, Richtungswechsel)? Bewerte auf einer Skala von 0–10.'**
  String get rtsTestPainDesc;

  /// No description provided for @rtsPainNoKein.
  ///
  /// In de, this message translates to:
  /// **'0 – Kein Schmerz'**
  String get rtsPainNoKein;

  /// No description provided for @rtsPainSevere.
  ///
  /// In de, this message translates to:
  /// **'10 – Stärkster Schmerz'**
  String get rtsPainSevere;

  /// No description provided for @rtsPainDetailValue.
  ///
  /// In de, this message translates to:
  /// **'NRS: {level} / 10'**
  String rtsPainDetailValue(String level);

  /// No description provided for @rtsSportTypeTitle.
  ///
  /// In de, this message translates to:
  /// **'Sportart'**
  String get rtsSportTypeTitle;

  /// No description provided for @rtsSportTypeDesc.
  ///
  /// In de, this message translates to:
  /// **'Welchen Sport möchtest du wieder ausüben?'**
  String get rtsSportTypeDesc;

  /// No description provided for @rtsSportRunning.
  ///
  /// In de, this message translates to:
  /// **'Laufen'**
  String get rtsSportRunning;

  /// No description provided for @rtsSportSoccer.
  ///
  /// In de, this message translates to:
  /// **'Fußball / Teamsport'**
  String get rtsSportSoccer;

  /// No description provided for @rtsSportStrength.
  ///
  /// In de, this message translates to:
  /// **'Kraftsport'**
  String get rtsSportStrength;

  /// No description provided for @rtsSportCycling.
  ///
  /// In de, this message translates to:
  /// **'Radfahren'**
  String get rtsSportCycling;

  /// No description provided for @rtsSportSwimming.
  ///
  /// In de, this message translates to:
  /// **'Schwimmen'**
  String get rtsSportSwimming;

  /// No description provided for @rtsSportMartialArts.
  ///
  /// In de, this message translates to:
  /// **'Kampfsport'**
  String get rtsSportMartialArts;

  /// No description provided for @rtsSportOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstige'**
  String get rtsSportOther;

  /// No description provided for @rtsTestHopTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprungkraft-Seitenvergleich (Hop-Test)'**
  String get rtsTestHopTitle;

  /// No description provided for @rtsTestHopDesc.
  ///
  /// In de, this message translates to:
  /// **'Springe auf dem betroffenen Bein so weit wie möglich vorwärts und messe die Weite. Wiederhole den Test auf der gesunden Seite.'**
  String get rtsTestHopDesc;

  /// No description provided for @rtsTestHopHint.
  ///
  /// In de, this message translates to:
  /// **'Führe 3 Versuche durch und nimm die beste Weite. Ein LSI ≥ 90 % gilt als optimale Freigabeschwelle.'**
  String get rtsTestHopHint;

  /// No description provided for @rtsHopAffected.
  ///
  /// In de, this message translates to:
  /// **'Betroffene Seite (cm)'**
  String get rtsHopAffected;

  /// No description provided for @rtsHopHealthy.
  ///
  /// In de, this message translates to:
  /// **'Gesunde Seite (cm)'**
  String get rtsHopHealthy;

  /// No description provided for @rtsHopDetailValue.
  ///
  /// In de, this message translates to:
  /// **'Betroffen: {affected} cm / Gesund: {healthy} cm → LSI: {percent}'**
  String rtsHopDetailValue(String affected, String healthy, String percent);

  /// No description provided for @rtsTestTugTitle.
  ///
  /// In de, this message translates to:
  /// **'Timed Up and Go (TUG)'**
  String get rtsTestTugTitle;

  /// No description provided for @rtsTestTugDesc.
  ///
  /// In de, this message translates to:
  /// **'Stehe von einem Stuhl auf, gehe 3 Meter geradeaus, kehre um und setze dich wieder. Miss die Gesamtzeit.'**
  String get rtsTestTugDesc;

  /// No description provided for @rtsTestTugHint.
  ///
  /// In de, this message translates to:
  /// **'Verwende den Stoppuhr-Button oder trage die Zeit manuell ein. Unter 10 Sekunden gilt als sehr gut.'**
  String get rtsTestTugHint;

  /// No description provided for @rtsTugDetailValue.
  ///
  /// In de, this message translates to:
  /// **'{seconds} Sekunden'**
  String rtsTugDetailValue(String seconds);

  /// No description provided for @rtsTimerStart.
  ///
  /// In de, this message translates to:
  /// **'Stoppuhr starten'**
  String get rtsTimerStart;

  /// No description provided for @rtsTimerStop.
  ///
  /// In de, this message translates to:
  /// **'Stopp'**
  String get rtsTimerStop;

  /// No description provided for @rtsTimerReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get rtsTimerReset;

  /// No description provided for @rtsTimerRestart.
  ///
  /// In de, this message translates to:
  /// **'Neu starten'**
  String get rtsTimerRestart;

  /// No description provided for @rtsTimerOrManual.
  ///
  /// In de, this message translates to:
  /// **'Oder manuell eingeben:'**
  String get rtsTimerOrManual;

  /// No description provided for @rtsTimerManualLabel.
  ///
  /// In de, this message translates to:
  /// **'Zeit in Sekunden'**
  String get rtsTimerManualLabel;

  /// No description provided for @rtsScoreTrend.
  ///
  /// In de, this message translates to:
  /// **'Score-Verlauf'**
  String get rtsScoreTrend;

  /// No description provided for @supplementAddNew.
  ///
  /// In de, this message translates to:
  /// **'Supplement hinzufügen'**
  String get supplementAddNew;

  /// No description provided for @supplementEdit.
  ///
  /// In de, this message translates to:
  /// **'Supplement bearbeiten'**
  String get supplementEdit;

  /// No description provided for @supplementName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get supplementName;

  /// No description provided for @supplementBrand.
  ///
  /// In de, this message translates to:
  /// **'Marke (optional)'**
  String get supplementBrand;

  /// No description provided for @supplementDose.
  ///
  /// In de, this message translates to:
  /// **'Dosis (z.B. 1000 IE)'**
  String get supplementDose;

  /// No description provided for @supplementCategoryLabel.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get supplementCategoryLabel;

  /// No description provided for @supplementCategoryVitamine.
  ///
  /// In de, this message translates to:
  /// **'Vitamine'**
  String get supplementCategoryVitamine;

  /// No description provided for @supplementCategoryMineralien.
  ///
  /// In de, this message translates to:
  /// **'Mineralien'**
  String get supplementCategoryMineralien;

  /// No description provided for @supplementCategoryAminosaeuren.
  ///
  /// In de, this message translates to:
  /// **'Aminosäuren'**
  String get supplementCategoryAminosaeuren;

  /// No description provided for @supplementCategoryKraeuter.
  ///
  /// In de, this message translates to:
  /// **'Kräuter & Pflanzen'**
  String get supplementCategoryKraeuter;

  /// No description provided for @supplementCategoryProbiotika.
  ///
  /// In de, this message translates to:
  /// **'Probiotika'**
  String get supplementCategoryProbiotika;

  /// No description provided for @supplementCategoryFettsaeuren.
  ///
  /// In de, this message translates to:
  /// **'Fettsäuren'**
  String get supplementCategoryFettsaeuren;

  /// No description provided for @supplementCategoryProteine.
  ///
  /// In de, this message translates to:
  /// **'Proteine'**
  String get supplementCategoryProteine;

  /// No description provided for @supplementCategorySonstiges.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get supplementCategorySonstiges;

  /// No description provided for @supplementTimeSlots.
  ///
  /// In de, this message translates to:
  /// **'Einnahmezeiten'**
  String get supplementTimeSlots;

  /// No description provided for @supplementSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get supplementSave;

  /// No description provided for @supplementTabToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get supplementTabToday;

  /// No description provided for @supplementTabMine.
  ///
  /// In de, this message translates to:
  /// **'Meine'**
  String get supplementTabMine;

  /// No description provided for @supplementTabRecommendations.
  ///
  /// In de, this message translates to:
  /// **'Empfehlungen'**
  String get supplementTabRecommendations;

  /// No description provided for @supplementTodayProgress.
  ///
  /// In de, this message translates to:
  /// **'Heutige Einnahme'**
  String get supplementTodayProgress;

  /// No description provided for @supplementTodayHistory.
  ///
  /// In de, this message translates to:
  /// **'Heutige Einnahmen'**
  String get supplementTodayHistory;

  /// No description provided for @supplementLogSuccess.
  ///
  /// In de, this message translates to:
  /// **'Einnahme gespeichert ✓'**
  String get supplementLogSuccess;

  /// No description provided for @supplementLogManual.
  ///
  /// In de, this message translates to:
  /// **'Manuell eintragen'**
  String get supplementLogManual;

  /// No description provided for @supplementStockLow.
  ///
  /// In de, this message translates to:
  /// **'Vorrat niedrig'**
  String get supplementStockLow;

  /// No description provided for @supplementStockEmpty.
  ///
  /// In de, this message translates to:
  /// **'Vorrat aufgebraucht'**
  String get supplementStockEmpty;

  /// No description provided for @supplementEmptyState.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Supplemente angelegt.\nTippe + um loszulegen.'**
  String get supplementEmptyState;

  /// No description provided for @supplementDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Supplement löschen?'**
  String get supplementDeleteTitle;

  /// No description provided for @supplementDeleteBody.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du dieses Supplement wirklich löschen?'**
  String get supplementDeleteBody;

  /// No description provided for @supplementDoseGuidance.
  ///
  /// In de, this message translates to:
  /// **'Dosierungsempfehlung'**
  String get supplementDoseGuidance;

  /// No description provided for @supplementNoRecommendations.
  ///
  /// In de, this message translates to:
  /// **'Keine Empfehlungen verfügbar'**
  String get supplementNoRecommendations;

  /// No description provided for @tabOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get tabOverview;

  /// No description provided for @tabDoctors.
  ///
  /// In de, this message translates to:
  /// **'Ärzte'**
  String get tabDoctors;

  /// No description provided for @tabTeam.
  ///
  /// In de, this message translates to:
  /// **'Team'**
  String get tabTeam;

  /// No description provided for @tabPatients.
  ///
  /// In de, this message translates to:
  /// **'Patienten'**
  String get tabPatients;

  /// No description provided for @tabProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @tabCalendar.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get tabCalendar;

  /// No description provided for @tabPlan.
  ///
  /// In de, this message translates to:
  /// **'Plan'**
  String get tabPlan;

  /// No description provided for @tabReport.
  ///
  /// In de, this message translates to:
  /// **'Report'**
  String get tabReport;

  /// No description provided for @tabWound.
  ///
  /// In de, this message translates to:
  /// **'Wunde'**
  String get tabWound;

  /// No description provided for @tabPain.
  ///
  /// In de, this message translates to:
  /// **'Schmerz'**
  String get tabPain;

  /// No description provided for @tabDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get tabDocuments;

  /// No description provided for @tabMedications.
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get tabMedications;

  /// No description provided for @tabQuestions.
  ///
  /// In de, this message translates to:
  /// **'Fragen'**
  String get tabQuestions;

  /// No description provided for @tabNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get tabNotes;

  /// No description provided for @tabObservations.
  ///
  /// In de, this message translates to:
  /// **'Beobachtungen'**
  String get tabObservations;

  /// No description provided for @greetingMorning.
  ///
  /// In de, this message translates to:
  /// **'Guten Morgen'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In de, this message translates to:
  /// **'Guten Tag'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In de, this message translates to:
  /// **'Guten Abend'**
  String get greetingEvening;

  /// No description provided for @today.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get today;

  /// No description provided for @profil.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profil;

  /// No description provided for @patienten.
  ///
  /// In de, this message translates to:
  /// **'Patienten'**
  String get patienten;

  /// No description provided for @weekdayMonday.
  ///
  /// In de, this message translates to:
  /// **'Montag'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In de, this message translates to:
  /// **'Dienstag'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In de, this message translates to:
  /// **'Mittwoch'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In de, this message translates to:
  /// **'Donnerstag'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In de, this message translates to:
  /// **'Freitag'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In de, this message translates to:
  /// **'Samstag'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In de, this message translates to:
  /// **'Sonntag'**
  String get weekdaySunday;

  /// No description provided for @weekdayShortMo.
  ///
  /// In de, this message translates to:
  /// **'Mo'**
  String get weekdayShortMo;

  /// No description provided for @weekdayShortTu.
  ///
  /// In de, this message translates to:
  /// **'Di'**
  String get weekdayShortTu;

  /// No description provided for @weekdayShortWe.
  ///
  /// In de, this message translates to:
  /// **'Mi'**
  String get weekdayShortWe;

  /// No description provided for @weekdayShortTh.
  ///
  /// In de, this message translates to:
  /// **'Do'**
  String get weekdayShortTh;

  /// No description provided for @weekdayShortFr.
  ///
  /// In de, this message translates to:
  /// **'Fr'**
  String get weekdayShortFr;

  /// No description provided for @weekdayShortSa.
  ///
  /// In de, this message translates to:
  /// **'Sa'**
  String get weekdayShortSa;

  /// No description provided for @weekdayShortSu.
  ///
  /// In de, this message translates to:
  /// **'So'**
  String get weekdayShortSu;

  /// No description provided for @phasePreOp.
  ///
  /// In de, this message translates to:
  /// **'Prä-OP'**
  String get phasePreOp;

  /// No description provided for @phaseOpDay.
  ///
  /// In de, this message translates to:
  /// **'OP-Tag'**
  String get phaseOpDay;

  /// No description provided for @phasePostOp.
  ///
  /// In de, this message translates to:
  /// **'Post-OP'**
  String get phasePostOp;

  /// No description provided for @phaseDischarged.
  ///
  /// In de, this message translates to:
  /// **'Entlassen'**
  String get phaseDischarged;

  /// No description provided for @phaseDistribution.
  ///
  /// In de, this message translates to:
  /// **'Phasenverteilung'**
  String get phaseDistribution;

  /// No description provided for @statusActive.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get statusActive;

  /// No description provided for @statusDeactivated.
  ///
  /// In de, this message translates to:
  /// **'Deaktiviert'**
  String get statusDeactivated;

  /// No description provided for @notProvided.
  ///
  /// In de, this message translates to:
  /// **'Nicht hinterlegt'**
  String get notProvided;

  /// No description provided for @fieldType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get fieldType;

  /// No description provided for @fieldTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get fieldTitle;

  /// No description provided for @fieldNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get fieldNotes;

  /// No description provided for @fieldWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get fieldWebsite;

  /// No description provided for @fieldDescriptionOptional.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung (optional)'**
  String get fieldDescriptionOptional;

  /// No description provided for @sorting.
  ///
  /// In de, this message translates to:
  /// **'Sortierung'**
  String get sorting;

  /// No description provided for @sortName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortOpDate.
  ///
  /// In de, this message translates to:
  /// **'OP-Datum'**
  String get sortOpDate;

  /// No description provided for @sortLastEntry.
  ///
  /// In de, this message translates to:
  /// **'Letzter Eintrag'**
  String get sortLastEntry;

  /// No description provided for @sortSeverity.
  ///
  /// In de, this message translates to:
  /// **'Schweregrad'**
  String get sortSeverity;

  /// No description provided for @totalPatients.
  ///
  /// In de, this message translates to:
  /// **'Gesamtpatienten'**
  String get totalPatients;

  /// No description provided for @activePatients.
  ///
  /// In de, this message translates to:
  /// **'Aktive Patienten'**
  String get activePatients;

  /// No description provided for @openRedFlags.
  ///
  /// In de, this message translates to:
  /// **'Offene Red Flags'**
  String get openRedFlags;

  /// No description provided for @compliance.
  ///
  /// In de, this message translates to:
  /// **'Compliance'**
  String get compliance;

  /// No description provided for @total.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get total;

  /// No description provided for @countActive.
  ///
  /// In de, this message translates to:
  /// **'{count} aktiv'**
  String countActive(int count);

  /// No description provided for @quickActions.
  ///
  /// In de, this message translates to:
  /// **'Schnellaktionen'**
  String get quickActions;

  /// No description provided for @templates.
  ///
  /// In de, this message translates to:
  /// **'Vorlagen'**
  String get templates;

  /// No description provided for @monthlyReport.
  ///
  /// In de, this message translates to:
  /// **'Monatsbericht'**
  String get monthlyReport;

  /// No description provided for @myPatients.
  ///
  /// In de, this message translates to:
  /// **'Meine Patienten'**
  String get myPatients;

  /// No description provided for @patientStatus.
  ///
  /// In de, this message translates to:
  /// **'Patienten-Status'**
  String get patientStatus;

  /// No description provided for @allPatientsGreen.
  ///
  /// In de, this message translates to:
  /// **'Alle Patienten im grünen Bereich'**
  String get allPatientsGreen;

  /// No description provided for @attentionRequired.
  ///
  /// In de, this message translates to:
  /// **'Aufmerksamkeit erforderlich'**
  String get attentionRequired;

  /// No description provided for @noAppointmentsToday.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine heute – freier Tag!'**
  String get noAppointmentsToday;

  /// No description provided for @appointmentsCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Termine'**
  String appointmentsCount(int count);

  /// No description provided for @showAllAppointments.
  ///
  /// In de, this message translates to:
  /// **'Alle {count} Termine anzeigen →'**
  String showAllAppointments(int count);

  /// No description provided for @practiceOf.
  ///
  /// In de, this message translates to:
  /// **'Praxis von {name}'**
  String practiceOf(String name);

  /// No description provided for @searchPatient.
  ///
  /// In de, this message translates to:
  /// **'Patient suchen …'**
  String get searchPatient;

  /// No description provided for @noPatientsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Patienten gefunden.'**
  String get noPatientsFound;

  /// No description provided for @noPatientsLinked.
  ///
  /// In de, this message translates to:
  /// **'Keine Patienten verknüpft.'**
  String get noPatientsLinked;

  /// No description provided for @noPatientsLinkedYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Patienten verknüpft'**
  String get noPatientsLinkedYet;

  /// No description provided for @noPatientsInCategory.
  ///
  /// In de, this message translates to:
  /// **'Keine Patienten in dieser Kategorie'**
  String get noPatientsInCategory;

  /// No description provided for @patientsCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Patienten ({count})'**
  String patientsCountLabel(int count);

  /// No description provided for @selectPatientForDetails.
  ///
  /// In de, this message translates to:
  /// **'Patient auswählen, um Details anzuzeigen'**
  String get selectPatientForDetails;

  /// No description provided for @opDatePrefix.
  ///
  /// In de, this message translates to:
  /// **'OP: {date}'**
  String opDatePrefix(String date);

  /// No description provided for @countSelected.
  ///
  /// In de, this message translates to:
  /// **'{count} ausgewählt'**
  String countSelected(int count);

  /// No description provided for @proBadge.
  ///
  /// In de, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @proActive.
  ///
  /// In de, this message translates to:
  /// **'Pro aktiv'**
  String get proActive;

  /// No description provided for @validUntil.
  ///
  /// In de, this message translates to:
  /// **'Gültig bis'**
  String get validUntil;

  /// No description provided for @source.
  ///
  /// In de, this message translates to:
  /// **'Quelle'**
  String get source;

  /// No description provided for @proKey.
  ///
  /// In de, this message translates to:
  /// **'Pro-Key'**
  String get proKey;

  /// No description provided for @appStoreName.
  ///
  /// In de, this message translates to:
  /// **'App Store'**
  String get appStoreName;

  /// No description provided for @googlePlayName.
  ///
  /// In de, this message translates to:
  /// **'Google Play'**
  String get googlePlayName;

  /// No description provided for @subscription.
  ///
  /// In de, this message translates to:
  /// **'Abo'**
  String get subscription;

  /// No description provided for @freeTier.
  ///
  /// In de, this message translates to:
  /// **'Free'**
  String get freeTier;

  /// No description provided for @upgradeNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt upgraden'**
  String get upgradeNow;

  /// No description provided for @redeemKey.
  ///
  /// In de, this message translates to:
  /// **'Key einlösen'**
  String get redeemKey;

  /// No description provided for @praxisPro.
  ///
  /// In de, this message translates to:
  /// **'Praxis Pro'**
  String get praxisPro;

  /// No description provided for @praxisProSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzte Patienten & mehr'**
  String get praxisProSubtitle;

  /// No description provided for @upgradeNowArrow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt upgraden →'**
  String get upgradeNowArrow;

  /// No description provided for @sectionContactData.
  ///
  /// In de, this message translates to:
  /// **'Kontaktdaten'**
  String get sectionContactData;

  /// No description provided for @sectionDoctors.
  ///
  /// In de, this message translates to:
  /// **'Ärzte'**
  String get sectionDoctors;

  /// No description provided for @sectionTeam.
  ///
  /// In de, this message translates to:
  /// **'Team'**
  String get sectionTeam;

  /// No description provided for @sectionPatients.
  ///
  /// In de, this message translates to:
  /// **'Patienten'**
  String get sectionPatients;

  /// No description provided for @orgProfileNotFound.
  ///
  /// In de, this message translates to:
  /// **'Organisationsprofil nicht gefunden.'**
  String get orgProfileNotFound;

  /// No description provided for @verified.
  ///
  /// In de, this message translates to:
  /// **'Verifiziert'**
  String get verified;

  /// No description provided for @verificationPending.
  ///
  /// In de, this message translates to:
  /// **'Prüfung ausstehend'**
  String get verificationPending;

  /// No description provided for @practiceInformation.
  ///
  /// In de, this message translates to:
  /// **'Praxisinformationen'**
  String get practiceInformation;

  /// No description provided for @openingHours.
  ///
  /// In de, this message translates to:
  /// **'Öffnungszeiten'**
  String get openingHours;

  /// No description provided for @specialties.
  ///
  /// In de, this message translates to:
  /// **'Spezialgebiete'**
  String get specialties;

  /// No description provided for @professionalDetails.
  ///
  /// In de, this message translates to:
  /// **'Berufliche Angaben'**
  String get professionalDetails;

  /// No description provided for @approbation.
  ///
  /// In de, this message translates to:
  /// **'Approbation'**
  String get approbation;

  /// No description provided for @kvNumber.
  ///
  /// In de, this message translates to:
  /// **'KV-Nummer'**
  String get kvNumber;

  /// No description provided for @practiceName.
  ///
  /// In de, this message translates to:
  /// **'Praxisname'**
  String get practiceName;

  /// No description provided for @yourProfile.
  ///
  /// In de, this message translates to:
  /// **'Dein Profil'**
  String get yourProfile;

  /// No description provided for @accountAndSupport.
  ///
  /// In de, this message translates to:
  /// **'Konto & Support'**
  String get accountAndSupport;

  /// No description provided for @profileImageUploadError.
  ///
  /// In de, this message translates to:
  /// **'Profilbild konnte nicht hochgeladen werden.'**
  String get profileImageUploadError;

  /// No description provided for @doctorsCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Ärzte ({count})'**
  String doctorsCountLabel(int count);

  /// No description provided for @selectDoctorForDetails.
  ///
  /// In de, this message translates to:
  /// **'Arzt auswählen, um Details anzuzeigen'**
  String get selectDoctorForDetails;

  /// No description provided for @errorLoadingDoctors.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Ärzte.'**
  String get errorLoadingDoctors;

  /// No description provided for @errorLoading.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden.'**
  String get errorLoading;

  /// No description provided for @errorLoadingPatients.
  ///
  /// In de, this message translates to:
  /// **'Patientenliste konnte nicht geladen werden.'**
  String get errorLoadingPatients;

  /// No description provided for @errorLoadingStaff.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Mitarbeiter.'**
  String get errorLoadingStaff;

  /// No description provided for @joinedOn.
  ///
  /// In de, this message translates to:
  /// **'Beigetreten am {date}'**
  String joinedOn(String date);

  /// No description provided for @inviteCode.
  ///
  /// In de, this message translates to:
  /// **'Einladungscode'**
  String get inviteCode;

  /// No description provided for @inviteCodeDescription.
  ///
  /// In de, this message translates to:
  /// **'Teilen Sie diesen Code mit verifizierten Ärzten, die Ihrer Organisation beitreten möchten.'**
  String get inviteCodeDescription;

  /// No description provided for @inviteCodeLoadError.
  ///
  /// In de, this message translates to:
  /// **'Code konnte nicht geladen werden.'**
  String get inviteCodeLoadError;

  /// No description provided for @joinRequestsCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Beitrittsanfragen ({count})'**
  String joinRequestsCountLabel(int count);

  /// No description provided for @timeAgoMinutes.
  ///
  /// In de, this message translates to:
  /// **'vor {count} Min.'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In de, this message translates to:
  /// **'vor {count} Std.'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoDays.
  ///
  /// In de, this message translates to:
  /// **'vor {count} Tagen'**
  String timeAgoDays(int count);

  /// No description provided for @noDoctorsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Ärzte'**
  String get noDoctorsYet;

  /// No description provided for @addDoctorsToOrg.
  ///
  /// In de, this message translates to:
  /// **'Fügen Sie Ärzte hinzu, um Ihre Organisation aufzubauen.'**
  String get addDoctorsToOrg;

  /// No description provided for @createNewDoctor.
  ///
  /// In de, this message translates to:
  /// **'Neuen Arzt anlegen'**
  String get createNewDoctor;

  /// No description provided for @createDoctor.
  ///
  /// In de, this message translates to:
  /// **'Arzt erstellen'**
  String get createDoctor;

  /// No description provided for @creating.
  ///
  /// In de, this message translates to:
  /// **'Wird erstellt…'**
  String get creating;

  /// No description provided for @validationRequired.
  ///
  /// In de, this message translates to:
  /// **'Pflichtfeld'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail'**
  String get validationInvalidEmail;

  /// No description provided for @validationMinChars8.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen.'**
  String get validationMinChars8;

  /// No description provided for @confirmAddDoctorToOrg.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} wirklich Ihrer Organisation hinzufügen?'**
  String confirmAddDoctorToOrg(String name);

  /// No description provided for @confirmRemoveDoctorFromOrg.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} wirklich aus der Organisation entfernen? Der Arzt wird unabhängig und behält seinen Account.'**
  String confirmRemoveDoctorFromOrg(String name);

  /// No description provided for @confirmActivateStaff.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} wieder aktivieren? Der Login wird wieder möglich.'**
  String confirmActivateStaff(String name);

  /// No description provided for @confirmDeactivateStaff.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} deaktivieren? Der Login wird gesperrt.'**
  String confirmDeactivateStaff(String name);

  /// No description provided for @staffActivated.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde aktiviert'**
  String staffActivated(String name);

  /// No description provided for @staffDeactivated.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde deaktiviert'**
  String staffDeactivated(String name);

  /// No description provided for @confirmRemoveStaff.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} wirklich entfernen? Der Zugang wird sofort widerrufen und der Account deaktiviert.'**
  String confirmRemoveStaff(String name);

  /// No description provided for @actionActivate.
  ///
  /// In de, this message translates to:
  /// **'aktivieren'**
  String get actionActivate;

  /// No description provided for @actionDeactivate.
  ///
  /// In de, this message translates to:
  /// **'deaktivieren'**
  String get actionDeactivate;

  /// No description provided for @staffCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeitende ({count})'**
  String staffCountLabel(int count);

  /// No description provided for @noStaffYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Mitarbeitenden'**
  String get noStaffYet;

  /// No description provided for @createStaffHint.
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Mitarbeiter-Accounts für Ihr Team.'**
  String get createStaffHint;

  /// No description provided for @createStaffTeamHint.
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Accounts für Ihr Praxisteam,\num gemeinsam Patienten zu betreuen.'**
  String get createStaffTeamHint;

  /// No description provided for @permissionRead.
  ///
  /// In de, this message translates to:
  /// **'Lesen'**
  String get permissionRead;

  /// No description provided for @permissionWrite.
  ///
  /// In de, this message translates to:
  /// **'Schreiben'**
  String get permissionWrite;

  /// No description provided for @caregiverNoLinkedPatient.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Patient verknüpft.\nBitte lasse dich über einen Einladungscode verbinden.'**
  String get caregiverNoLinkedPatient;

  /// No description provided for @observationLabel.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung'**
  String get observationLabel;

  /// No description provided for @confirmDisconnectPatient.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Verbindung zu {name} wirklich trennen?'**
  String confirmDisconnectPatient(String name);

  /// No description provided for @taskForPatient.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe für {name}'**
  String taskForPatient(String name);

  /// No description provided for @selectTemplateForPatient.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie eine Vorlage für {name}:'**
  String selectTemplateForPatient(String name);

  /// No description provided for @selectAll.
  ///
  /// In de, this message translates to:
  /// **'Alle auswählen'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In de, this message translates to:
  /// **'Alle abwählen'**
  String get deselectAll;

  /// No description provided for @selectStartDateHint.
  ///
  /// In de, this message translates to:
  /// **'Startdatum wählen (z.B. OP-Datum)'**
  String get selectStartDateHint;

  /// No description provided for @assigning.
  ///
  /// In de, this message translates to:
  /// **'Wird zugewiesen…'**
  String get assigning;

  /// No description provided for @recurrenceDaily.
  ///
  /// In de, this message translates to:
  /// **'Täglich, {count}x'**
  String recurrenceDaily(int count);

  /// No description provided for @recurrenceWeekdays.
  ///
  /// In de, this message translates to:
  /// **'Werktags, {count}x'**
  String recurrenceWeekdays(int count);

  /// No description provided for @recurrenceEveryNDays.
  ///
  /// In de, this message translates to:
  /// **'Alle {days} Tage, {count}x'**
  String recurrenceEveryNDays(int days, int count);

  /// No description provided for @patientsMarkedRead.
  ///
  /// In de, this message translates to:
  /// **'{count} Patienten als gelesen markiert'**
  String patientsMarkedRead(int count);

  /// No description provided for @groupMessageToPatients.
  ///
  /// In de, this message translates to:
  /// **'Gruppennachricht an {count} Patienten'**
  String groupMessageToPatients(int count);

  /// No description provided for @hintEnterMessage.
  ///
  /// In de, this message translates to:
  /// **'Nachricht eingeben …'**
  String get hintEnterMessage;

  /// No description provided for @messageSentToPatients.
  ///
  /// In de, this message translates to:
  /// **'Nachricht an {count} Patienten gesendet'**
  String messageSentToPatients(int count);

  /// No description provided for @pdfReportCreating.
  ///
  /// In de, this message translates to:
  /// **'PDF-Bericht für {count} Patienten wird erstellt …'**
  String pdfReportCreating(int count);

  /// No description provided for @groupMessage.
  ///
  /// In de, this message translates to:
  /// **'Gruppennachricht'**
  String get groupMessage;

  /// No description provided for @pdfReport.
  ///
  /// In de, this message translates to:
  /// **'PDF-Bericht'**
  String get pdfReport;

  /// No description provided for @calendarDay.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get calendarDay;

  /// No description provided for @specialtyGeneralSurgery.
  ///
  /// In de, this message translates to:
  /// **'Allgemeinchirurgie'**
  String get specialtyGeneralSurgery;

  /// No description provided for @specialtyOrthopedics.
  ///
  /// In de, this message translates to:
  /// **'Orthopädie & Unfallchirurgie'**
  String get specialtyOrthopedics;

  /// No description provided for @specialtyVisceralSurgery.
  ///
  /// In de, this message translates to:
  /// **'Viszeralchirurgie'**
  String get specialtyVisceralSurgery;

  /// No description provided for @specialtyCardiacSurgery.
  ///
  /// In de, this message translates to:
  /// **'Herzchirurgie'**
  String get specialtyCardiacSurgery;

  /// No description provided for @specialtyNeurosurgery.
  ///
  /// In de, this message translates to:
  /// **'Neurochirurgie'**
  String get specialtyNeurosurgery;

  /// No description provided for @specialtyVascularSurgery.
  ///
  /// In de, this message translates to:
  /// **'Gefäßchirurgie'**
  String get specialtyVascularSurgery;

  /// No description provided for @specialtyPlasticSurgery.
  ///
  /// In de, this message translates to:
  /// **'Plastische Chirurgie'**
  String get specialtyPlasticSurgery;

  /// No description provided for @specialtyUrology.
  ///
  /// In de, this message translates to:
  /// **'Urologie'**
  String get specialtyUrology;

  /// No description provided for @specialtyGynecology.
  ///
  /// In de, this message translates to:
  /// **'Gynäkologie'**
  String get specialtyGynecology;

  /// No description provided for @specialtyEnt.
  ///
  /// In de, this message translates to:
  /// **'HNO'**
  String get specialtyEnt;

  /// No description provided for @specialtyOphthalmology.
  ///
  /// In de, this message translates to:
  /// **'Augenheilkunde'**
  String get specialtyOphthalmology;

  /// No description provided for @specialtyInternalMedicine.
  ///
  /// In de, this message translates to:
  /// **'Innere Medizin'**
  String get specialtyInternalMedicine;

  /// No description provided for @specialtyAnesthesiology.
  ///
  /// In de, this message translates to:
  /// **'Anästhesiologie'**
  String get specialtyAnesthesiology;

  /// No description provided for @specialtyOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstige'**
  String get specialtyOther;

  /// No description provided for @passwordMin8Chars.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen.'**
  String get passwordMin8Chars;

  /// No description provided for @staffConfirmActivateBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} wieder aktivieren? Der Login wird wieder möglich.'**
  String staffConfirmActivateBody(String name);

  /// No description provided for @staffConfirmDeactivateBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} deaktivieren? Der Login wird gesperrt.'**
  String staffConfirmDeactivateBody(String name);

  /// No description provided for @staffWasActivated.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde aktiviert'**
  String staffWasActivated(String name);

  /// No description provided for @staffWasDeactivated.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde deaktiviert'**
  String staffWasDeactivated(String name);

  /// No description provided for @staffRemoveConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} wirklich entfernen? Der Zugang wird sofort widerrufen und der Account deaktiviert.'**
  String staffRemoveConfirmBody(String name);

  /// No description provided for @teamHeader.
  ///
  /// In de, this message translates to:
  /// **'Team'**
  String get teamHeader;

  /// No description provided for @staffLoadError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Mitarbeiter.'**
  String get staffLoadError;

  /// No description provided for @statusDisabled.
  ///
  /// In de, this message translates to:
  /// **'Deaktiviert'**
  String get statusDisabled;

  /// No description provided for @noStaffYetTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Mitarbeiter'**
  String get noStaffYetTitle;

  /// No description provided for @noStaffYetSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Mitarbeiter-Accounts für Ihr Team.'**
  String get noStaffYetSubtitle;

  /// No description provided for @nSelected.
  ///
  /// In de, this message translates to:
  /// **'{count} ausgewählt'**
  String nSelected(int count);

  /// No description provided for @patientListLoadError.
  ///
  /// In de, this message translates to:
  /// **'Patientenliste konnte nicht geladen werden.'**
  String get patientListLoadError;

  /// No description provided for @sortByName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByOpDate.
  ///
  /// In de, this message translates to:
  /// **'OP-Datum'**
  String get sortByOpDate;

  /// No description provided for @sortByLastEntry.
  ///
  /// In de, this message translates to:
  /// **'Letzter Eintrag'**
  String get sortByLastEntry;

  /// No description provided for @sortBySeverity.
  ///
  /// In de, this message translates to:
  /// **'Schweregrad'**
  String get sortBySeverity;

  /// No description provided for @title.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get title;

  /// No description provided for @enterMessage.
  ///
  /// In de, this message translates to:
  /// **'Nachricht eingeben …'**
  String get enterMessage;

  /// No description provided for @staffActivateConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} wieder aktivieren? Der Login wird wieder möglich.'**
  String staffActivateConfirmBody(String name);

  /// No description provided for @staffDeactivateConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {name} deaktivieren? Der Login wird gesperrt.'**
  String staffDeactivateConfirmBody(String name);

  /// No description provided for @staffPermissionsSummary.
  ///
  /// In de, this message translates to:
  /// **'{readCount} Lesen · {writeCount} Schreiben'**
  String staffPermissionsSummary(int readCount, int writeCount);

  /// No description provided for @pdTabReport.
  ///
  /// In de, this message translates to:
  /// **'Report'**
  String get pdTabReport;

  /// No description provided for @pdTabRedFlags.
  ///
  /// In de, this message translates to:
  /// **'Red Flags'**
  String get pdTabRedFlags;

  /// No description provided for @pdTabWound.
  ///
  /// In de, this message translates to:
  /// **'Wunde'**
  String get pdTabWound;

  /// No description provided for @pdTabPain.
  ///
  /// In de, this message translates to:
  /// **'Schmerz'**
  String get pdTabPain;

  /// No description provided for @pdTabDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get pdTabDocuments;

  /// No description provided for @pdTabMedication.
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get pdTabMedication;

  /// No description provided for @pdTabQuestions.
  ///
  /// In de, this message translates to:
  /// **'Fragen'**
  String get pdTabQuestions;

  /// No description provided for @pdTabNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get pdTabNotes;

  /// No description provided for @phaseEntlassen.
  ///
  /// In de, this message translates to:
  /// **'Entlassen'**
  String get phaseEntlassen;

  /// No description provided for @disconnectConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Verbindung zu {name} wirklich trennen?'**
  String disconnectConfirmBody(String name);

  /// No description provided for @terminFuerPatient.
  ///
  /// In de, this message translates to:
  /// **'Termin für {name}'**
  String terminFuerPatient(String name);

  /// No description provided for @aufgabeFuerPatient.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe für {name}'**
  String aufgabeFuerPatient(String name);

  /// No description provided for @startdatumWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Startdatum wählen (z. B. OP-Datum)'**
  String get startdatumWaehlen;

  /// No description provided for @vorlageFuerPatient.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie eine Vorlage für {name}:'**
  String vorlageFuerPatient(String name);

  /// No description provided for @templateAppliedCount.
  ///
  /// In de, this message translates to:
  /// **'{name}: {count} Aufgabe{suffix} zugewiesen'**
  String templateAppliedCount(String name, int count, String suffix);

  /// No description provided for @nAufgabenColon.
  ///
  /// In de, this message translates to:
  /// **'{count} Aufgabe{suffix}:'**
  String nAufgabenColon(int count, String suffix);

  /// No description provided for @nAufgaben.
  ///
  /// In de, this message translates to:
  /// **'{count} Aufgabe{suffix}'**
  String nAufgaben(int count, String suffix);

  /// No description provided for @vorlageErstellen.
  ///
  /// In de, this message translates to:
  /// **'Vorlage erstellen'**
  String get vorlageErstellen;

  /// No description provided for @doctorProfileNotSpecified.
  ///
  /// In de, this message translates to:
  /// **'Nicht hinterlegt'**
  String get doctorProfileNotSpecified;

  /// No description provided for @doctorProfilePracticeInfo.
  ///
  /// In de, this message translates to:
  /// **'Praxisinformationen'**
  String get doctorProfilePracticeInfo;

  /// No description provided for @doctorProfileWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get doctorProfileWebsite;

  /// No description provided for @doctorProfileOpeningHours.
  ///
  /// In de, this message translates to:
  /// **'Öffnungszeiten'**
  String get doctorProfileOpeningHours;

  /// No description provided for @doctorProfileSpecialties.
  ///
  /// In de, this message translates to:
  /// **'Spezialgebiete'**
  String get doctorProfileSpecialties;

  /// No description provided for @doctorProfileProfessionalInfo.
  ///
  /// In de, this message translates to:
  /// **'Berufliche Angaben'**
  String get doctorProfileProfessionalInfo;

  /// No description provided for @doctorProfileApprobation.
  ///
  /// In de, this message translates to:
  /// **'Approbation'**
  String get doctorProfileApprobation;

  /// No description provided for @doctorProfileKvNumber.
  ///
  /// In de, this message translates to:
  /// **'KV-Nummer'**
  String get doctorProfileKvNumber;

  /// No description provided for @doctorProfilePracticeName.
  ///
  /// In de, this message translates to:
  /// **'Praxisname'**
  String get doctorProfilePracticeName;

  /// No description provided for @doctorProfileStaffMember.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter/in'**
  String get doctorProfileStaffMember;

  /// No description provided for @doctorProfileAccountSupport.
  ///
  /// In de, this message translates to:
  /// **'Konto & Support'**
  String get doctorProfileAccountSupport;

  /// No description provided for @doctorProfileImageUploadError.
  ///
  /// In de, this message translates to:
  /// **'Profilbild konnte nicht hochgeladen werden.'**
  String get doctorProfileImageUploadError;

  /// No description provided for @doctorProfileYourProfile.
  ///
  /// In de, this message translates to:
  /// **'Dein Profil'**
  String get doctorProfileYourProfile;

  /// No description provided for @doctorProfileVerified.
  ///
  /// In de, this message translates to:
  /// **'Verifiziert'**
  String get doctorProfileVerified;

  /// No description provided for @doctorProfileVerificationPending.
  ///
  /// In de, this message translates to:
  /// **'Prüfung ausstehend'**
  String get doctorProfileVerificationPending;

  /// No description provided for @doctorProfileClosed.
  ///
  /// In de, this message translates to:
  /// **'Geschlossen'**
  String get doctorProfileClosed;

  /// No description provided for @doctorProfileNoSpecialties.
  ///
  /// In de, this message translates to:
  /// **'Keine Spezialgebiete hinterlegt'**
  String get doctorProfileNoSpecialties;

  /// No description provided for @doctorProfileNewSpecialtyHint.
  ///
  /// In de, this message translates to:
  /// **'Neues Spezialgebiet…'**
  String get doctorProfileNewSpecialtyHint;

  /// No description provided for @patientSuchen.
  ///
  /// In de, this message translates to:
  /// **'Patient suchen…'**
  String get patientSuchen;

  /// No description provided for @fehlerBeimLaden.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden.'**
  String get fehlerBeimLaden;

  /// No description provided for @keinePatienenGefunden.
  ///
  /// In de, this message translates to:
  /// **'Keine Patienten gefunden.'**
  String get keinePatienenGefunden;

  /// No description provided for @patientenAnzahl.
  ///
  /// In de, this message translates to:
  /// **'Patienten ({count})'**
  String patientenAnzahl(int count);

  /// No description provided for @patientAuswaehlenUmDetailsAnzuzeigen.
  ///
  /// In de, this message translates to:
  /// **'Patient auswählen, um Details anzuzeigen'**
  String get patientAuswaehlenUmDetailsAnzuzeigen;

  /// No description provided for @opDatumKurz.
  ///
  /// In de, this message translates to:
  /// **'OP: {day}.{month}.{year}'**
  String opDatumKurz(int day, int month, int year);

  /// No description provided for @appointmentCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Termine'**
  String appointmentCount(int count);

  /// No description provided for @noAppointmentsFreeDay.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine – freier Tag!'**
  String get noAppointmentsFreeDay;

  /// No description provided for @showAllAppointmentsCount.
  ///
  /// In de, this message translates to:
  /// **'Alle {count} Termine anzeigen'**
  String showAllAppointmentsCount(int count);

  /// No description provided for @totalLabel.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get totalLabel;

  /// No description provided for @broadcastSend.
  ///
  /// In de, this message translates to:
  /// **'Senden'**
  String get broadcastSend;

  /// No description provided for @broadcastSentCount.
  ///
  /// In de, this message translates to:
  /// **'Broadcast an {count} Patienten gesendet'**
  String broadcastSentCount(int count);

  /// No description provided for @broadcastToAllPatients.
  ///
  /// In de, this message translates to:
  /// **'Broadcast an alle Patienten'**
  String get broadcastToAllPatients;

  /// No description provided for @broadcastWillBeSentTo.
  ///
  /// In de, this message translates to:
  /// **'Wird an {count} Patienten gesendet'**
  String broadcastWillBeSentTo(int count);

  /// No description provided for @sending.
  ///
  /// In de, this message translates to:
  /// **'Sende…'**
  String get sending;

  /// No description provided for @appointmentDeleteMessage.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie den Termin \"{title}\" für {patient} wirklich löschen?'**
  String appointmentDeleteMessage(String title, String patient);

  /// No description provided for @eventDeleteMessage.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie den Termin \"{title}\" wirklich löschen?'**
  String eventDeleteMessage(String title);

  /// No description provided for @appointmentEdit.
  ///
  /// In de, this message translates to:
  /// **'Termin bearbeiten'**
  String get appointmentEdit;

  /// No description provided for @notes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get notes;

  /// No description provided for @type.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get type;

  /// No description provided for @saving.
  ///
  /// In de, this message translates to:
  /// **'Speichern…'**
  String get saving;

  /// No description provided for @practiceAppointmentCreate.
  ///
  /// In de, this message translates to:
  /// **'Praxis-Termin erstellen'**
  String get practiceAppointmentCreate;

  /// No description provided for @practiceAppointmentEdit.
  ///
  /// In de, this message translates to:
  /// **'Praxis-Termin bearbeiten'**
  String get practiceAppointmentEdit;

  /// No description provided for @nochKeinePatientenInDerOrganisation.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Patienten in der Organisation.'**
  String get nochKeinePatientenInDerOrganisation;

  /// No description provided for @redFlagCountLabel.
  ///
  /// In de, this message translates to:
  /// **'{count} {count, plural, =1{Flag} other{Flags}}'**
  String redFlagCountLabel(int count);

  /// No description provided for @bellaDescriptionOrganisation.
  ///
  /// In de, this message translates to:
  /// **'Ich helfe dir bei der Verwaltung deiner Organisation, Ärzten, Mitarbeitern und Statistiken.'**
  String get bellaDescriptionOrganisation;

  /// No description provided for @bellaSubtitleOrganisation.
  ///
  /// In de, this message translates to:
  /// **'Dein Organisations-Assistent 🐰'**
  String get bellaSubtitleOrganisation;

  /// No description provided for @bellaFeatureBilling.
  ///
  /// In de, this message translates to:
  /// **'Abrechnung'**
  String get bellaFeatureBilling;

  /// No description provided for @bellaFeatureDoctors.
  ///
  /// In de, this message translates to:
  /// **'Ärzte'**
  String get bellaFeatureDoctors;

  /// No description provided for @bellaFeatureOrgStats.
  ///
  /// In de, this message translates to:
  /// **'Statistiken'**
  String get bellaFeatureOrgStats;

  /// No description provided for @bellaFeatureTeam.
  ///
  /// In de, this message translates to:
  /// **'Team'**
  String get bellaFeatureTeam;

  /// No description provided for @bellaChipDoctorBroadcast.
  ///
  /// In de, this message translates to:
  /// **'Nachricht an alle Patienten senden'**
  String get bellaChipDoctorBroadcast;

  /// No description provided for @bellaChipDoctorCreateAppointment.
  ///
  /// In de, this message translates to:
  /// **'Termin für Patient erstellen'**
  String get bellaChipDoctorCreateAppointment;

  /// No description provided for @bellaChipDoctorInvitePatient.
  ///
  /// In de, this message translates to:
  /// **'Neuen Patienten einladen'**
  String get bellaChipDoctorInvitePatient;

  /// No description provided for @bellaChipManageDoctors.
  ///
  /// In de, this message translates to:
  /// **'Wie verwalte ich meine Ärzte?'**
  String get bellaChipManageDoctors;

  /// No description provided for @bellaChipOrgBillingInfo.
  ///
  /// In de, this message translates to:
  /// **'Wie ist unser Abonnement-Status?'**
  String get bellaChipOrgBillingInfo;

  /// No description provided for @bellaChipOrgDashboard.
  ///
  /// In de, this message translates to:
  /// **'Zeig mir unsere Organisations-Übersicht'**
  String get bellaChipOrgDashboard;

  /// No description provided for @bellaChipOrgInviteDoctor.
  ///
  /// In de, this message translates to:
  /// **'Einen neuen Arzt einladen'**
  String get bellaChipOrgInviteDoctor;

  /// No description provided for @bellaChipOrgStats.
  ///
  /// In de, this message translates to:
  /// **'Zeig mir unsere Statistiken'**
  String get bellaChipOrgStats;

  /// No description provided for @bellaChipStaffCreateAppointment.
  ///
  /// In de, this message translates to:
  /// **'Termin für Patient erstellen'**
  String get bellaChipStaffCreateAppointment;

  /// No description provided for @bellaChipDoctorCreateTask.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe für Patient erstellen'**
  String get bellaChipDoctorCreateTask;

  /// No description provided for @bellaChipDoctorCreateRedFlag.
  ///
  /// In de, this message translates to:
  /// **'Warnung für Patient erstellen'**
  String get bellaChipDoctorCreateRedFlag;

  /// No description provided for @bellaChipOrgBroadcast.
  ///
  /// In de, this message translates to:
  /// **'Nachricht an alle Patienten senden'**
  String get bellaChipOrgBroadcast;

  /// No description provided for @bellaChipStaffCreateTask.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe für Patient erstellen'**
  String get bellaChipStaffCreateTask;

  /// No description provided for @bellaChipStaffLogVital.
  ///
  /// In de, this message translates to:
  /// **'Vitalwerte für Patient eintragen'**
  String get bellaChipStaffLogVital;

  /// No description provided for @orgManagedByOrg.
  ///
  /// In de, this message translates to:
  /// **'Wird von Ihrer Organisation verwaltet'**
  String get orgManagedByOrg;

  /// No description provided for @orgManagedByOrgHint.
  ///
  /// In de, this message translates to:
  /// **'Diese Einstellungen werden zentral von Ihrer Organisation gepflegt.'**
  String get orgManagedByOrgHint;

  /// No description provided for @orgProfileEdit.
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get orgProfileEdit;

  /// No description provided for @orgProfileSaved.
  ///
  /// In de, this message translates to:
  /// **'Organisationsprofil gespeichert'**
  String get orgProfileSaved;

  /// No description provided for @orgProfileSaveError.
  ///
  /// In de, this message translates to:
  /// **'Profil konnte nicht gespeichert werden'**
  String get orgProfileSaveError;

  /// No description provided for @orgSettingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Verwaltung'**
  String get orgSettingsTitle;

  /// No description provided for @orgSettingsDoctorManagement.
  ///
  /// In de, this message translates to:
  /// **'Ärzteverwaltung'**
  String get orgSettingsDoctorManagement;

  /// No description provided for @orgSettingsDoctorManagementDesc.
  ///
  /// In de, this message translates to:
  /// **'Ärzte hinzufügen, entfernen und Zugriffsrechte verwalten'**
  String get orgSettingsDoctorManagementDesc;

  /// No description provided for @orgSettingsStaffManagement.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiterverwaltung'**
  String get orgSettingsStaffManagement;

  /// No description provided for @orgSettingsStaffManagementDesc.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter verwalten und Berechtigungen zuweisen'**
  String get orgSettingsStaffManagementDesc;

  /// No description provided for @orgSettingsPatientOverview.
  ///
  /// In de, this message translates to:
  /// **'Patientenübersicht'**
  String get orgSettingsPatientOverview;

  /// No description provided for @orgSettingsPatientOverviewDesc.
  ///
  /// In de, this message translates to:
  /// **'Alle Patienten der Organisation einsehen'**
  String get orgSettingsPatientOverviewDesc;

  /// No description provided for @orgSettingsInviteCodes.
  ///
  /// In de, this message translates to:
  /// **'Einladungscodes'**
  String get orgSettingsInviteCodes;

  /// No description provided for @orgSettingsInviteCodesDesc.
  ///
  /// In de, this message translates to:
  /// **'Einladungscodes für neue Ärzte verwalten'**
  String get orgSettingsInviteCodesDesc;

  /// No description provided for @orgSettingsJoinRequests.
  ///
  /// In de, this message translates to:
  /// **'Beitrittsanfragen'**
  String get orgSettingsJoinRequests;

  /// No description provided for @orgSettingsJoinRequestsDesc.
  ///
  /// In de, this message translates to:
  /// **'Offene Anfragen von Ärzten prüfen und genehmigen'**
  String get orgSettingsJoinRequestsDesc;

  /// No description provided for @orgSettingsNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get orgSettingsNotifications;

  /// No description provided for @orgSettingsNotificationsDesc.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungseinstellungen der Organisation'**
  String get orgSettingsNotificationsDesc;

  /// No description provided for @orgSettingsBilling.
  ///
  /// In de, this message translates to:
  /// **'Abrechnung & Abonnement'**
  String get orgSettingsBilling;

  /// No description provided for @orgSettingsBillingDesc.
  ///
  /// In de, this message translates to:
  /// **'Pro-Status, Rechnungen und Abonnement verwalten'**
  String get orgSettingsBillingDesc;

  /// No description provided for @orgSettingsDataExport.
  ///
  /// In de, this message translates to:
  /// **'Datenexport'**
  String get orgSettingsDataExport;

  /// No description provided for @orgSettingsDataExportDesc.
  ///
  /// In de, this message translates to:
  /// **'Organisationsdaten zusammenstellen und exportieren'**
  String get orgSettingsDataExportDesc;

  /// No description provided for @orgSettingsAppearance.
  ///
  /// In de, this message translates to:
  /// **'Erscheinungsbild'**
  String get orgSettingsAppearance;

  /// No description provided for @orgSettingsAppearanceDesc.
  ///
  /// In de, this message translates to:
  /// **'Logo und Darstellung der Organisation anpassen'**
  String get orgSettingsAppearanceDesc;

  /// No description provided for @orgSettingsOpeningHours.
  ///
  /// In de, this message translates to:
  /// **'Öffnungszeiten'**
  String get orgSettingsOpeningHours;

  /// No description provided for @orgSettingsOpeningHoursDesc.
  ///
  /// In de, this message translates to:
  /// **'Öffnungszeiten der Einrichtung festlegen'**
  String get orgSettingsOpeningHoursDesc;

  /// No description provided for @orgSettingsWebsite.
  ///
  /// In de, this message translates to:
  /// **'Webseite'**
  String get orgSettingsWebsite;

  /// No description provided for @orgSettingsContactInfo.
  ///
  /// In de, this message translates to:
  /// **'Kontaktdaten Ihrer Organisation'**
  String get orgSettingsContactInfo;

  /// No description provided for @orgSettingsGeneralInfo.
  ///
  /// In de, this message translates to:
  /// **'Allgemeine Informationen'**
  String get orgSettingsGeneralInfo;

  /// No description provided for @orgSettingsDangerZone.
  ///
  /// In de, this message translates to:
  /// **'Gefahrenzone'**
  String get orgSettingsDangerZone;

  /// No description provided for @orgSettingsDeleteOrg.
  ///
  /// In de, this message translates to:
  /// **'Organisation löschen'**
  String get orgSettingsDeleteOrg;

  /// No description provided for @orgSettingsDeleteOrgDesc.
  ///
  /// In de, this message translates to:
  /// **'Organisation und alle zugehörigen Daten unwiderruflich löschen'**
  String get orgSettingsDeleteOrgDesc;

  /// No description provided for @orgDoctorCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Ärzte'**
  String orgDoctorCount(int count);

  /// No description provided for @orgStaffCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Mitarbeiter'**
  String orgStaffCount(int count);

  /// No description provided for @orgPatientCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Patienten'**
  String orgPatientCount(int count);

  /// No description provided for @orgPendingRequests.
  ///
  /// In de, this message translates to:
  /// **'{count} offene Anfragen'**
  String orgPendingRequests(int count);

  /// No description provided for @orgQuickActions.
  ///
  /// In de, this message translates to:
  /// **'Schnellaktionen'**
  String get orgQuickActions;

  /// No description provided for @orgManagementSection.
  ///
  /// In de, this message translates to:
  /// **'Organisation verwalten'**
  String get orgManagementSection;

  /// No description provided for @orgSecuritySection.
  ///
  /// In de, this message translates to:
  /// **'Sicherheit & Daten'**
  String get orgSecuritySection;

  /// No description provided for @orgSaveChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get orgSaveChanges;
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
