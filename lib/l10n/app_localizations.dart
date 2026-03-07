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
  /// **'Start'**
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
