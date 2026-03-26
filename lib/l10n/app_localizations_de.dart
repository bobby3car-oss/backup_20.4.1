// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tabStart => 'Start';

  @override
  String get tabAppointments => 'Termine';

  @override
  String get tabMore => 'Mehr';

  @override
  String get commonBack => 'OK';

  @override
  String get or => 'oder';

  @override
  String get connectivityOfflineBanner =>
      'Du bist offline. Änderungen werden synchronisiert, sobald du wieder online bist.';

  @override
  String get connectivityRequiredTitle => 'Keine Internetverbindung';

  @override
  String get connectivityRequiredMessage =>
      'Diese Funktion benötigt eine Internetverbindung. Bitte stelle eine Verbindung her und versuche es erneut.';

  @override
  String get syncIndicatorSynced => 'Alles synchronisiert';

  @override
  String syncIndicatorSyncing(int count) {
    return '$count Einträge warten auf Sync';
  }

  @override
  String get syncIndicatorOffline => 'Offline';

  @override
  String syncIndicatorOfflineWithCount(int count) {
    return 'Offline – $count Einträge warten auf Sync';
  }

  @override
  String get syncIndicatorTitle => 'Synchronisation';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingSlide1Title => 'Willkommen beim Operationsbegleiter';

  @override
  String get onboardingSlide1Subtitle =>
      'Dein persönlicher Begleiter vor und nach der OP';

  @override
  String get onboardingSlide1Feature1 => 'Alle wichtigen Infos auf einen Blick';

  @override
  String get onboardingSlide1Feature2 => 'Persönliche Checklisten für deine OP';

  @override
  String get onboardingSlide1Feature3 =>
      'Schritt für Schritt durch den Prozess';

  @override
  String get onboardingSlide2Title => 'Vorbereitung';

  @override
  String get onboardingSlide2Subtitle => 'Optimal vorbereitet in die OP';

  @override
  String get onboardingSlide2Feature1 => 'Individuelle Vorbereitungspläne';

  @override
  String get onboardingSlide2Feature2 => 'Erinnerungen an wichtige Termine';

  @override
  String get onboardingSlide2Feature3 => 'Dokumente digital verwalten';

  @override
  String get onboardingSlide3Title => 'Nachsorge';

  @override
  String get onboardingSlide3Subtitle => 'Begleitung nach der Operation';

  @override
  String get onboardingSlide3Feature1 => 'Tägliche Gesundheitschecks';

  @override
  String get onboardingSlide3Feature2 => 'Medikamenten-Erinnerungen';

  @override
  String get onboardingSlide3Feature3 => 'Fortschritts-Tracking';

  @override
  String get onboardingSlide4Title => 'Sicherheit';

  @override
  String get onboardingSlide4Subtitle => 'Deine Daten sind bei uns sicher';

  @override
  String get onboardingSlide4Feature1 => 'Ende-zu-Ende-Verschlüsselung';

  @override
  String get onboardingSlide4Feature2 => 'DSGVO-konform';

  @override
  String get onboardingSlide4Feature3 => 'Daten nur auf deinem Gerät';

  @override
  String get onboardingSlide5Title => 'Bereit?';

  @override
  String get onboardingSlide5Subtitle => 'Erstelle jetzt dein Profil';

  @override
  String get onboardingSlide5Feature1 => 'Kostenlos registrieren';

  @override
  String get onboardingSlide5Feature2 => 'In wenigen Minuten startklar';

  @override
  String get onboardingSlide5Feature3 => 'Jederzeit löschbar';

  @override
  String get authSlideTitle => 'Operationsbegleiter';

  @override
  String get authSlideSubtitle => 'Dein persönlicher Begleiter für die OP';

  @override
  String get authSlideRegister => 'Registrieren';

  @override
  String get authSlideLogin => 'Anmelden';

  @override
  String get authSlideDoctorRegister => 'Als Arzt / Organisation registrieren';

  @override
  String get authSlideGuestMode => 'Gastmodus';

  @override
  String get registerContinueAsGuest => 'Ohne Registrierung fortfahren';

  @override
  String get loginWelcomeBack => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Melde dich an, um fortzufahren';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginEnterEmailFirst =>
      'Bitte gib zuerst deine E-Mail-Adresse ein.';

  @override
  String get loginPasswordResetSent =>
      'E-Mail zum Zurücksetzen des Passworts wurde gesendet.';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get loginWithApple => 'Mit Apple anmelden';

  @override
  String get noAccountYet => 'Noch kein Konto?';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createAccountTitle => 'Konto erstellen';

  @override
  String get createAccountSubtitle => 'Registriere dich, um loszulegen';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPassword => 'Passwort';

  @override
  String get fieldRepeatPassword => 'Passwort wiederholen';

  @override
  String get fieldFullName => 'Vollständiger Name';

  @override
  String get fieldBirthDate => 'Geburtsdatum';

  @override
  String get fieldBirthDateHint => 'TT.MM.JJJJ';

  @override
  String get fieldBirthDatePicker => 'Geburtsdatum auswählen';

  @override
  String get validationEmailInvalid =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get validationPasswordMin6 =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get validationPasswordsMismatch =>
      'Die Passwörter stimmen nicht überein.';

  @override
  String get validationNameRequired => 'Bitte gib deinen Namen ein.';

  @override
  String get validationBirthDateRequired => 'Bitte gib dein Geburtsdatum ein.';

  @override
  String get validationRepeatPassword => 'Bitte wiederhole das Passwort.';

  @override
  String get datePickerCancel => 'Abbrechen';

  @override
  String get datePickerConfirm => 'Bestätigen';

  @override
  String get agbAcceptPrefix => 'Ich akzeptiere die ';

  @override
  String get agbTermsLink => 'AGB';

  @override
  String get agbAndConnector => ' und die ';

  @override
  String get agbPrivacyLink => 'Datenschutzerklärung';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get medicalDisclaimer =>
      'Diese App ersetzt keine ärztliche Beratung. Bei gesundheitlichen Beschwerden wende dich an deinen Arzt.';

  @override
  String get doctorRegTitle => 'Als Arzt registrieren';

  @override
  String get doctorRegRoleBadge => 'Arzt';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'Verifizierter medizinischer Fachexperte';

  @override
  String get doctorRegPersonalData => 'Persönliche Daten';

  @override
  String get doctorRegProfessionalData => 'Berufliche Daten';

  @override
  String get doctorRegNameHint => 'Dr. Max Mustermann';

  @override
  String get doctorRegEmailHint => 'arzt@praxis.de';

  @override
  String get doctorRegEmailRequired => 'Bitte gib deine E-Mail-Adresse ein.';

  @override
  String get doctorRegEmailInvalid =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get doctorRegPasswordMin8 =>
      'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get doctorRegSpecialty => 'Fachrichtung';

  @override
  String get doctorRegSelectSpecialty => 'Fachrichtung auswählen';

  @override
  String get doctorRegApprobation => 'Approbationsnummer';

  @override
  String get doctorRegApprobationHint => 'z.B. 12345678';

  @override
  String get doctorRegApprobationRequired =>
      'Bitte gib deine Approbationsnummer ein.';

  @override
  String get doctorRegKvNumber => 'KV-Nummer';

  @override
  String get doctorRegKvHint => 'Optional';

  @override
  String get doctorRegPractice => 'Praxis / Klinik';

  @override
  String get doctorRegPracticeHint => 'Name der Praxis oder Klinik';

  @override
  String get doctorRegPracticeRequired => 'Bitte gib deine Praxis an.';

  @override
  String get doctorRegServiceEmail => 'Dienstliche E-Mail-Adresse';

  @override
  String get doctorRegDisclaimer =>
      'Ihre Angaben werden geprüft und Ihr Account nach erfolgreicher Verifizierung freigeschaltet.';

  @override
  String get doctorRegSubmit => 'Registrierung absenden';

  @override
  String get doctorRegSubmitting => 'Wird gesendet…';

  @override
  String get orgRegTitle => 'Als Organisation registrieren';

  @override
  String get orgRegRoleBadge => 'Organisation';

  @override
  String get orgRegRoleBadgeSubtitle =>
      'Krankenhäuser, Kliniken & Rehabilitationseinrichtungen';

  @override
  String get orgRegGeneralData => 'Allgemeine Daten';

  @override
  String get orgRegOrgData => 'Organisationsdaten';

  @override
  String get orgRegOrgName => 'Organisationsname';

  @override
  String get orgRegOrgNameHint => 'z.B. Universitätsklinikum';

  @override
  String get orgRegNameRequired => 'Bitte gib den Organisationsnamen ein.';

  @override
  String get orgRegOrgType => 'Organisationstyp';

  @override
  String get orgRegSelectOrgType => 'Organisationstyp auswählen';

  @override
  String get orgRegAddress => 'Adresse';

  @override
  String get orgRegAddressHint => 'Straße, PLZ, Ort';

  @override
  String get orgRegAddressRequired => 'Bitte gib die Adresse ein.';

  @override
  String get orgRegContactPerson => 'Ansprechpartner';

  @override
  String get orgRegContactPersonHint => 'Vor- und Nachname';

  @override
  String get orgRegContactPersonRequired =>
      'Bitte gib einen Ansprechpartner an.';

  @override
  String get orgRegEmail => 'Organisations-E-Mail';

  @override
  String get orgRegEmailHint => 'info@organisation.de';

  @override
  String get orgRegPhone => 'Telefon';

  @override
  String get orgRegPhoneHint => '+49 123 456789';

  @override
  String get orgRegDisclaimer =>
      'Ihre Angaben werden geprüft und Ihr Account nach erfolgreicher Verifizierung freigeschaltet.';

  @override
  String get orgRegSubmit => 'Registrierung absenden';

  @override
  String get orgRegSubmitting => 'Wird gesendet…';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsNotAvailable => 'Einstellungen nicht verfügbar';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsPush => 'Push-Benachrichtigungen';

  @override
  String get settingsEmailNotif => 'E-Mail-Benachrichtigungen';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsExportData => 'Daten exportieren';

  @override
  String get settingsResetData => 'Daten zurücksetzen';

  @override
  String get settingsPro => 'Pro-Version';

  @override
  String get settingsProStatus => 'Pro-Status';

  @override
  String get settingsProSubtitle => 'Alle Funktionen freischalten';

  @override
  String get settingsLegal => 'Rechtliches';

  @override
  String get settingsImprint => 'Impressum';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsTerms => 'AGB';

  @override
  String get settingsVersion => 'Version';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get tutorialNext => 'Weiter';

  @override
  String get tutorialFinish => 'Fertig';

  @override
  String get tutorialNeverShow => 'Nicht mehr anzeigen';

  @override
  String get tutorialStep1Title => 'Willkommen! 👋';

  @override
  String get tutorialStep1Desc =>
      'Hallo, ich bin Bella! Hier siehst du alles Wichtige zu deiner OP auf einen Blick.';

  @override
  String get tutorialStep2Title => 'Deine Termine';

  @override
  String get tutorialStep2Desc =>
      'Hier behältst du Arzttermine und Vorbereitungen im Blick – ich erinnere dich rechtzeitig.';

  @override
  String get tutorialStep3Title => 'Ich bin immer da';

  @override
  String get tutorialStep3Desc =>
      'Das bin ich! 🐰 Tippe mich jederzeit an – ich beantworte alle Fragen rund um deine Genesung.';

  @override
  String get tutorialStep4Title => 'Mehr entdecken';

  @override
  String get tutorialStep4Desc =>
      'Unter \'Mehr\' findest du Einstellungen, Hilfe und weitere hilfreiche Funktionen.';

  @override
  String get profileCompleteness => 'Profilvollständigkeit';

  @override
  String get profileStillTodo => 'Noch zu erledigen';

  @override
  String get profileMoreItems => 'weitere';

  @override
  String get profileComplete => 'Profil vervollständigen';

  @override
  String get profileCheckName => 'Name angeben';

  @override
  String get profileCheckOpDate => 'OP-Datum eintragen';

  @override
  String get profileCheckOpType => 'OP-Art auswählen';

  @override
  String get profileCheckDoctor => 'Behandelnden Arzt angeben';

  @override
  String get profileCheckHospital => 'Krankenhaus angeben';

  @override
  String get profileCheckHeight => 'Größe angeben';

  @override
  String get profileCheckWeight => 'Gewicht angeben';

  @override
  String get profileCheckEmergencyContact => 'Notfallkontakt hinterlegen';

  @override
  String get doctorRegSpecialtyRequired => 'Bitte wähle eine Fachrichtung aus.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get done => 'Fertig';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get close => 'Schließen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get share => 'Teilen';

  @override
  String get copy => 'Kopieren';

  @override
  String get send => 'Senden';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get activate => 'Aktivieren';

  @override
  String get deactivate => 'Deaktivieren';

  @override
  String get unlock => 'Entsperren';

  @override
  String get create => 'Erstellen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get all => 'Alle';

  @override
  String get none => 'Keine';

  @override
  String get details => 'Details';

  @override
  String get info => 'Info';

  @override
  String get warning => 'Warnung';

  @override
  String get urgent => 'Dringend';

  @override
  String get critical => 'Kritisch';

  @override
  String get high => 'Hoch';

  @override
  String get low => 'Niedrig';

  @override
  String get normal => 'Normal';

  @override
  String get minimal => 'Minimal';

  @override
  String get daily => 'Täglich';

  @override
  String get weekdays => 'Werktags';

  @override
  String get everyNDays => 'Alle N Tage';

  @override
  String get customDay => 'Eigener Tag';

  @override
  String get repeatUntil => 'Wiederholen bis';

  @override
  String get repetition => 'Wiederholung';

  @override
  String get recurring => 'Wiederkehrend';

  @override
  String get allDay => 'Ganztägig';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirm => 'Abmelden?';

  @override
  String get logoutAdminConfirm => 'Wirklich aus dem Admin-Bereich abmelden?';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get accountRequired => 'Konto erforderlich';

  @override
  String get passwordConfirm => 'Passwort bestätigen';

  @override
  String get passwordChanged => 'Passwort geändert';

  @override
  String get passwordReset => 'Passwort zurücksetzen';

  @override
  String get passwordResetDone => 'Passwort wurde zurückgesetzt';

  @override
  String get passwordsMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordMin6 => 'Mindestens 6 Zeichen';

  @override
  String newPasswordFor(String name) {
    return 'Neues Passwort für $name';
  }

  @override
  String get deleteAccountTitle => 'Account endgültig löschen?';

  @override
  String get deleteAccount => 'Account löschen';

  @override
  String get deleteDataOnly => 'Nur Daten löschen';

  @override
  String get deleteFinal => 'Endgültig löschen';

  @override
  String get deleteUserAndData => 'User und alle Daten gelöscht.';

  @override
  String get resetDataTitle => 'Daten zurücksetzen';

  @override
  String get allDataIrreversible => 'Alle Daten unwiderruflich entfernen';

  @override
  String get guestDataFound => 'Lokale Daten gefunden';

  @override
  String get guestDataDiscard => 'Nein, verwerfen';

  @override
  String get guestDataTransfer => 'Ja, übertragen';

  @override
  String get settingSaveError => 'Einstellung konnte nicht gespeichert werden.';

  @override
  String get settingSaved => 'Einstellungen gespeichert.';

  @override
  String get tutorialRepeat => 'Tutorial wiederholen';

  @override
  String get tutorialRepeatSubtitle => 'Einführung nochmals anzeigen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notificationsActive => 'Benachrichtigungen aktiv';

  @override
  String get notificationsManage => 'Benachrichtigungen verwalten';

  @override
  String notificationsCountNew(int count) {
    return 'Benachrichtigungen ($count neu)';
  }

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get adDisplays => 'Werbeanzeigen';

  @override
  String get usageStats => 'Nutzungsstatistiken';

  @override
  String get crashReports => 'Absturzberichte';

  @override
  String get bellaAiAssistant => 'Bella KI-Assistent';

  @override
  String get exportAsPdf => 'Als PDF exportieren';

  @override
  String get exportAsPdfSubtitle => 'Übersichtlicher Bericht';

  @override
  String get exportAsJson => 'Als JSON exportieren';

  @override
  String get exportAsJsonSubtitle => 'Alle Rohdaten zum Archivieren';

  @override
  String get exportCreating => 'Export wird erstellt …';

  @override
  String get exportPreparing => 'Export wird vorbereitet…';

  @override
  String get csvExporting => 'CSV wird exportiert…';

  @override
  String get appointment => 'Termin';

  @override
  String get appointmentCreate => 'Termin erstellen';

  @override
  String get appointmentAdd => 'Termin hinzufügen';

  @override
  String get appointmentConfirmed => 'Termin bestätigt';

  @override
  String get appointmentDeclined => 'Termin abgelehnt';

  @override
  String get appointmentDeleteConfirm => 'Termin löschen?';

  @override
  String get appointmentSaveError => 'Termin konnte nicht gespeichert werden.';

  @override
  String get appointmentCreateError => 'Termin konnte nicht erstellt werden.';

  @override
  String get appointmentDeleteError => 'Fehler beim Löschen des Termins';

  @override
  String get appointmentForPatient => 'Termin für einen Patienten erstellen';

  @override
  String get practiceAppointment => 'Praxis-Termin';

  @override
  String get practiceAppointmentOwn =>
      'Eigenen praxisinternen Termin erstellen';

  @override
  String get practiceAppointmentSaveError =>
      'Praxis-Termin konnte nicht gespeichert werden.';

  @override
  String get practiceAppointmentDeleteConfirm => 'Praxis-Termin löschen?';

  @override
  String get calendarAddTitle => 'Zum Kalender hinzufügen?';

  @override
  String get calendarNoThanks => 'Nein, danke';

  @override
  String get calendarShareIcs => 'Als .ics teilen';

  @override
  String get calendarAdd => 'Zum Kalender';

  @override
  String get medication => 'Medikament';

  @override
  String get medicationAdd => 'Medikament hinzufügen';

  @override
  String get medicationPlan => 'Medikationsplan';

  @override
  String get medicationHubOpen => 'Medikamenten-Hub öffnen';

  @override
  String get medicationIntakeTimes => 'Einnahmezeiten';

  @override
  String get medicationIntakeSaveError => 'Fehler beim Speichern der Einnahme';

  @override
  String get medicationStock => 'Vorrat (optional)';

  @override
  String get medicationLocalAlarms => 'Lokale Alarme für aktivierte Zeiten';

  @override
  String get medicationAlarmDeleteError => 'Fehler beim Löschen des Weckers';

  @override
  String get patient => 'Patient';

  @override
  String get patientInvite => 'Patient einladen';

  @override
  String get patientAdd => 'Patient hinzufügen';

  @override
  String get patientConnect => 'Patient verbinden';

  @override
  String get patientLinked => 'Patient erfolgreich verknüpft!';

  @override
  String get patientLinking => 'Patient Linking';

  @override
  String get patientPlan => 'Patienten-Plan';

  @override
  String get patientAppointment => 'Patienten-Termin';

  @override
  String get patientData => 'Patientendaten';

  @override
  String get patientNoInvites => 'Keine Patienten-Einladungen.';

  @override
  String get doctor => 'Arzt';

  @override
  String get doctorAdd => 'Arzt hinzufügen';

  @override
  String get doctorRemove => 'Arzt entfernen';

  @override
  String get doctorConfirm => 'Arzt bestätigen';

  @override
  String get doctorDisconnect => 'Arzt trennen';

  @override
  String get doctorDeleted => 'Arzt gelöscht.';

  @override
  String get doctorCreated => 'Arzt wurde erstellt';

  @override
  String get doctorDetails => 'Arzt-Details';

  @override
  String get doctorCreateInvite => 'Arzt-Einladung erstellen';

  @override
  String get doctorVerification => 'Arzt-Verifizierung';

  @override
  String get doctorNoInvites => 'Keine Arzt-Einladungen.';

  @override
  String get doctorManage => 'Ärzte verwalten';

  @override
  String get doctorEnterUid => 'Bitte eine Arzt-UID eingeben.';

  @override
  String get doctorReportNotAvailable => 'Arztbericht nicht verfügbar.';

  @override
  String get treatingDoctor => 'Behandelnder Arzt';

  @override
  String get templateNew => 'Neue Vorlage';

  @override
  String get templateNone => 'Keine Vorlagen gefunden';

  @override
  String get templateDelete => 'Vorlage löschen?';

  @override
  String templateDeleteConfirm(String name) {
    return 'Möchten Sie \"$name\" wirklich löschen?';
  }

  @override
  String get templateSaved => 'Vorlage gespeichert';

  @override
  String get templateSave => 'Vorlage speichern';

  @override
  String get templateApply => 'Vorlage anwenden';

  @override
  String get templateFromTasks => 'Vorlage aus Aufgaben';

  @override
  String get templateFromTasksCreate => 'Vorlage aus Aufgaben erstellen';

  @override
  String templateCreated(String name) {
    return 'Vorlage \"$name\" erstellt';
  }

  @override
  String templateDuplicated(String name) {
    return '\"$name\" erstellt';
  }

  @override
  String get templateDuplicateError => 'Fehler beim Duplizieren';

  @override
  String templateAdopted(String name) {
    return '\"$name\" in eigene Vorlagen übernommen';
  }

  @override
  String get templateAdoptError => 'Fehler beim Übernehmen';

  @override
  String get templateDeleteError => 'Fehler beim Löschen der Vorlage';

  @override
  String get templateOwnTemplates => 'Eigene Vorlagen';

  @override
  String get templateDuplicate => 'Duplizieren';

  @override
  String get templateAdopt => 'Übernehmen';

  @override
  String get systemTemplates => 'Systemvorlagen';

  @override
  String get systemTemplateDelete => 'Systemvorlage löschen?';

  @override
  String get systemTemplateNone => 'Noch keine Systemvorlagen';

  @override
  String get systemTemplateFirst => 'Erste Systemvorlage';

  @override
  String get task => 'Aufgabe';

  @override
  String get taskDefine => 'Aufgabe definieren';

  @override
  String get taskCreate => 'Aufgabe erstellen';

  @override
  String get taskCreateError => 'Aufgabe konnte nicht erstellt werden.';

  @override
  String get taskAssign => 'Aufgabe zuweisen';

  @override
  String get taskRequired => 'Pflichtitem';

  @override
  String tasksCount(int count) {
    return 'Aufgaben ($count)';
  }

  @override
  String tasksSelectCount(int selected, int total) {
    return 'Aufgaben auswählen ($selected/$total):';
  }

  @override
  String get tasksSelectToApply =>
      'Aufgaben auswählen, die angewendet werden sollen:';

  @override
  String get tasksNone => 'Keine Aufgaben';

  @override
  String get tasksNoneYet => 'Noch keine Aufgaben';

  @override
  String get tasksNoneAdded => 'Noch keine Aufgaben hinzugefügt';

  @override
  String get tasksNoneInPlan => 'Noch keine Aufgaben im Plan.';

  @override
  String get tasksNoneAssigned => 'Keine zugewiesenen Aufgaben gefunden.';

  @override
  String get taskSaveError => 'Fehler beim Speichern der Aufgabe';

  @override
  String get taskRepeatCount => 'Anzahl Wiederholungen';

  @override
  String get taskDayOffset => 'Tag-Offset';

  @override
  String get taskDueAfterHours => 'Fällig nach (Std.)';

  @override
  String get taskTimeOfDay => 'Tageszeit (optional)';

  @override
  String get taskMustNotForget => 'Darf auf keinen Fall vergessen werden';

  @override
  String get phase => 'Phase';

  @override
  String get phases => 'Phasen';

  @override
  String get phaseNone => 'Keine Phase';

  @override
  String get phasesNone => 'Keine Phasen – alle Aufgaben sind allgemein.';

  @override
  String get phaseRename => 'Phase umbenennen';

  @override
  String get inviteCreate => 'Einladung erstellen';

  @override
  String get inviteCreated => 'Einladung erstellt';

  @override
  String get inviteCreateError => 'Einladung konnte nicht erstellt werden.';

  @override
  String get inviteAcceptError => 'Einladung konnte nicht akzeptiert werden.';

  @override
  String get inviteRevoke => 'Einladung widerrufen?';

  @override
  String get inviteRevoked => 'Einladung widerrufen.';

  @override
  String get inviteAccepted => 'Invite akzeptiert.';

  @override
  String get invitations => 'Einladungen';

  @override
  String get inviteCodeCopied => 'Einladungscode kopiert';

  @override
  String get linkCopied => 'Link kopiert';

  @override
  String get codeCopied => 'Code kopiert';

  @override
  String get codeCopiedExcl => 'Code kopiert!';

  @override
  String get codeEnter => 'Code eingeben';

  @override
  String get codeCopy => 'Code kopieren';

  @override
  String get inviteFamilyMember => 'Angehörige einladen';

  @override
  String get observation => 'Beobachtung erfassen';

  @override
  String get observationNew => 'Neue Beobachtung';

  @override
  String get observationsNone => 'Noch keine Beobachtungen eingetragen.';

  @override
  String get myObservations => 'Meine Beobachtungen';

  @override
  String get woundDoc => 'Wunddoku';

  @override
  String get woundNoEntries => 'Noch keine Wundeinträge vorhanden.';

  @override
  String get woundPhotoForAnalysis => 'Wundfoto für Analyse';

  @override
  String get woundChoosePhoto =>
      'Wähle ein Foto für die KI-Wundanalyse mit Bella';

  @override
  String get woundNoPhotos => 'Keine Wundfotos für die Analyse vorhanden.';

  @override
  String get woundNoPhoto => 'Kein Foto für die Analyse vorhanden.';

  @override
  String get woundTakePhoto => '📷  Neues Foto aufnehmen';

  @override
  String get woundFromGallery => '🖼️  Aus Galerie wählen';

  @override
  String get woundMinPhotos => 'Mindestens 2 Fotos für den Vergleich nötig.';

  @override
  String get woundCompare => 'Vergleichen';

  @override
  String get woundSliderMix => 'A/B mit Slider mischen';

  @override
  String get painLevel => 'Schmerzstärke';

  @override
  String get painComparison => 'Schmerzstärke Vergleich';

  @override
  String get painCourse7d => 'Schmerzverlauf (7 Tage)';

  @override
  String get painSaved => 'Schmerzwert gespeichert';

  @override
  String painScoreOf10(int score) {
    return 'Schmerz: $score/10';
  }

  @override
  String painLevelOf10(int level) {
    return 'Schmerzlevel: $level/10';
  }

  @override
  String get unbearable => 'Unerträglich';

  @override
  String get moodSaved => 'Stimmung gespeichert';

  @override
  String get moodDeleteConfirm =>
      'Möchtest du diesen Stimmungseintrag wirklich löschen?';

  @override
  String get nutritionDescribeMeal => 'Bitte beschreibe deine Mahlzeit';

  @override
  String get nutritionSaved => 'Mahlzeit gespeichert';

  @override
  String get nutritionRecipes => 'Rezepte';

  @override
  String get nutritionDailyGoals => 'Tagesziele';

  @override
  String get vitalsMeasurementSaved => 'Messung gespeichert';

  @override
  String vitalsNewMeasurementsSync(int count) {
    return '$count neue Messungen aus Health synchronisiert';
  }

  @override
  String get bodyData => 'Körperdaten';

  @override
  String get packingListReset => 'Packliste zurücksetzen?';

  @override
  String get packingListNoItems => 'Keine Packlisten-Einträge vorhanden.';

  @override
  String get packingListDelete => 'Liste löschen?';

  @override
  String get packingListRename => 'Liste umbenennen';

  @override
  String get packingListNew => 'Neue Liste';

  @override
  String get packingListName => 'Listenname';

  @override
  String get packingListAddItem => 'Item hinzufügen';

  @override
  String get documentUpload => 'Dokument hochladen';

  @override
  String get documentDeleteConfirm => 'Dokument löschen?';

  @override
  String get documentSavedLocally => 'Dokument lokal gespeichert.';

  @override
  String get documentsOpen => 'Dokumente öffnen';

  @override
  String get documentsAll => 'Alle Dokumente';

  @override
  String get noteDelete => 'Notiz löschen';

  @override
  String get noteSave => 'Notiz speichern';

  @override
  String get noteDeleteError => 'Fehler beim Löschen der Notiz';

  @override
  String get noteSaveError => 'Fehler beim Speichern der Notiz';

  @override
  String get voiceMemoSaved => 'Memo gespeichert';

  @override
  String get voiceMemoDelete => 'Memo löschen?';

  @override
  String get voiceStartRecording => 'Aufnahme starten';

  @override
  String get voiceNoMemos => 'Keine Memos gefunden.';

  @override
  String get voiceTranscriptSaved => 'Transkript gespeichert';

  @override
  String get voiceNoTranscript =>
      'Kein Transkript vorhanden – bitte zuerst transkribieren.';

  @override
  String get voiceAudioNotFoundLocal => 'Audiodatei lokal nicht gefunden.';

  @override
  String get voiceAudioNotFound => 'Audiodatei nicht gefunden.';

  @override
  String get voiceMicPermissionMissing => 'Mikrofon-Berechtigung fehlt.';

  @override
  String get profileEdit => 'Profil bearbeiten';

  @override
  String get profileSaved => 'Profil gespeichert';

  @override
  String get profileSaveError => 'Profil konnte nicht gespeichert werden.';

  @override
  String get yourDetails => 'Deine Angaben';

  @override
  String get smokerStatus => 'Raucherstatus';

  @override
  String get hospitalClinic => 'Krankenhaus / Klinik';

  @override
  String get treatmentType => 'Behandlungsart *';

  @override
  String get opDate => 'OP-Datum *';

  @override
  String get currentOperation => 'Aktuelle Operation';

  @override
  String get operationArchived => 'Operation archiviert';

  @override
  String get markOpComplete => 'Aktuelle OP als abgeschlossen markieren';

  @override
  String get stayType => 'Art des Aufenthalts';

  @override
  String get startDateOpDate => 'Startdatum (z.B. OP-Datum)';

  @override
  String get emergencyContact => 'Notfallkontakt';

  @override
  String get transportPlanSaved => 'Transportplanung gespeichert';

  @override
  String get healthOverview => 'Dein Gesundheitsüberblick';

  @override
  String get proUnlock => 'Pro freischalten';

  @override
  String get proRedeemKey => 'Pro Key einlösen';

  @override
  String get proKeys => 'Pro-Keys';

  @override
  String get proKeysCreate => 'Pro-Keys erstellen';

  @override
  String get proGrantAccess => 'Pro-Zugang vergeben';

  @override
  String get proHowManyDays => 'Wie viele Tage Pro-Zugang?';

  @override
  String get proStatusChangeError => 'Pro-Status konnte nicht geändert werden.';

  @override
  String get proManageSubscription => 'Abo verwalten';

  @override
  String get proRestorePurchase => 'Kauf wiederherstellen';

  @override
  String staffMember(String action) {
    return 'Mitarbeiter $action';
  }

  @override
  String get staffUpdated => 'Mitarbeiter aktualisiert';

  @override
  String get staffRemove => 'Mitarbeiter entfernen';

  @override
  String get staffCreate => 'Mitarbeiter erstellen';

  @override
  String get staffCreated => 'Mitarbeiter wurde erstellt';

  @override
  String get orgJoin => 'Organisation beitreten';

  @override
  String get orgJoinWithCode => 'Mit Einladungscode beitreten';

  @override
  String get orgConfirm => 'Organisation bestätigen';

  @override
  String get orgVerification => 'Organisations‑Verifizierung';

  @override
  String get ticketNew => 'Neues Ticket';

  @override
  String get ticketCreated => 'Ticket erstellt!';

  @override
  String get ticketClosed => 'Ticket geschlossen.';

  @override
  String get ticketCloseConfirm => 'Ticket schließen?';

  @override
  String get ticketCloseExplanation =>
      'Das Ticket wird als geschlossen markiert.';

  @override
  String get tickets => 'Tickets';

  @override
  String ticketsCountOpen(int count) {
    return 'Tickets ($count offen)';
  }

  @override
  String get myTickets => 'Meine Tickets';

  @override
  String get messageSendError => 'Nachricht konnte nicht gesendet werden.';

  @override
  String get message => 'Nachricht';

  @override
  String get noMessagesYet => 'Noch keine Nachrichten.';

  @override
  String get questionAdd => 'Frage hinzufügen';

  @override
  String get questionNew => 'Neue Frage';

  @override
  String get questionCreate => 'Frage anlegen';

  @override
  String get questionDelete => 'Frage löschen?';

  @override
  String get loginToSaveQuestions =>
      'Bitte melde dich an, um Fragen zu speichern.';

  @override
  String get bellaSummarize => 'Mit Bella zusammenfassen';

  @override
  String get bellaAnalyze => 'Mit Bella analysieren';

  @override
  String get bellaGenerate => 'Jetzt generieren';

  @override
  String get bellaRegenerate => 'Neu generieren';

  @override
  String get bellaBriefingCopied => 'Briefing in die Zwischenablage kopiert';

  @override
  String redFlagSaved(String level) {
    return 'Warnzeichen-Check gespeichert ($level)';
  }

  @override
  String get severityCourse => 'Schweregrad-Verlauf';

  @override
  String get lastFlags => 'Letzte Flags';

  @override
  String get lastEntries => 'Letzte Einträge:';

  @override
  String get photoSaved => 'Foto gespeichert und synchronisiert.';

  @override
  String get photo => 'Foto';

  @override
  String get cameraOpening => 'Kamera wird geöffnet…';

  @override
  String get entryDeleted => 'Eintrag gelöscht';

  @override
  String get entryDeleteConfirm => 'Eintrag löschen?';

  @override
  String get entryDeleteIrreversible =>
      'Dieser Eintrag wird unwiderruflich gelöscht.';

  @override
  String get entryDetailed => 'Detaillierter Eintrag';

  @override
  String get entryNew => 'Neuer Eintrag';

  @override
  String get minTwoEntriesForComparison =>
      'Mindestens 2 Einträge für Vergleich nötig.';

  @override
  String get saveError => 'Fehler beim Speichern';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String get saveFailedDot => 'Speichern fehlgeschlagen.';

  @override
  String get deleteError => 'Fehler beim Löschen';

  @override
  String get disconnectError => 'Fehler beim Trennen';

  @override
  String get restoreError => 'Fehler beim Wiederherstellen';

  @override
  String get pinError => 'Fehler beim Anheften';

  @override
  String get unlockFailed => 'Entsperren fehlgeschlagen.';

  @override
  String get lockFailed => 'Sperren fehlgeschlagen.';

  @override
  String get deleteFailed => 'Löschung fehlgeschlagen.';

  @override
  String get actionFailed => 'Aktion fehlgeschlagen.';

  @override
  String get dataLoadError => 'Daten konnten nicht geladen werden.';

  @override
  String get pageOpenError => 'Diese Seite konnte nicht geöffnet werden.';

  @override
  String get noLocalFile => 'Keine lokale Datei vorhanden.';

  @override
  String get fileNotFound => 'Datei nicht gefunden.';

  @override
  String get fileReadError => 'Datei konnte nicht gelesen werden.';

  @override
  String get uploadPending => 'Upload ausstehend. Wird erneut versucht.';

  @override
  String get uploadFailedLocal => 'Upload fehlgeschlagen – lokal gespeichert.';

  @override
  String get noEmailApp => 'Keine E-Mail-App gefunden';

  @override
  String get titleRequired => 'Bitte einen Titel eingeben';

  @override
  String get titleAndMessageRequired =>
      'Titel und Nachricht dürfen nicht leer sein.';

  @override
  String get titleAndUrlRequired => 'Titel und URL sind erforderlich.';

  @override
  String get urlInvalid => 'Bitte eine vollständige http(s)-URL eingeben.';

  @override
  String get imageRequired =>
      'Bitte ein Bild für die Partner-Anzeige auswählen.';

  @override
  String get resultSaved => 'Ergebnis gespeichert';

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert!';

  @override
  String get reportCopied => 'Bericht in Zwischenablage kopiert';

  @override
  String get allCopied => 'Alle Keys in Zwischenablage kopiert!';

  @override
  String get allCopy => 'Alle kopieren';

  @override
  String get selectSpecialty => 'Bitte Fachrichtung auswählen';

  @override
  String get selectMinOneSection => 'Wähle mindestens eine Sektion aus.';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get testNotificationCreated => 'Test-Benachrichtigung erstellt.';

  @override
  String get companion => 'Begleiter';

  @override
  String get timeline => 'Timeline';

  @override
  String get toTimeline => 'Zur Timeline';

  @override
  String get openDiary => 'Tagebuch öffnen';

  @override
  String get openFullDiary => 'Vollständiges Tagebuch öffnen';

  @override
  String get checklists => 'Checkliste';

  @override
  String get categories => 'Kategorien';

  @override
  String get statistics => 'Statistiken';

  @override
  String get statisticsLoadError =>
      'Statistiken konnten nicht aktualisiert werden.';

  @override
  String get statisticsLoading => 'Statistiken werden geladen...';

  @override
  String get tags => 'Tags';

  @override
  String get permissions => 'Berechtigungen';

  @override
  String get permissionsUpdated => 'Berechtigungen aktualisiert';

  @override
  String get myPermissions => 'Meine Berechtigungen';

  @override
  String get readAllowed => 'Lesen erlauben';

  @override
  String get writeAllowed => 'Schreiben erlauben';

  @override
  String get readOnly => 'Nur Lesen';

  @override
  String get read => 'Lesen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get general => 'Allgemein';

  @override
  String get practice => 'Praxis';

  @override
  String get history => 'Verlauf';

  @override
  String get preview => 'Vorschau';

  @override
  String get status => 'Status';

  @override
  String get role => 'Rolle';

  @override
  String get roleChange => 'Rolle ändern';

  @override
  String get roleChangeError => 'Rolle konnte nicht geändert werden.';

  @override
  String get roleDistribution => 'Rollenverteilung';

  @override
  String get markAsRead => 'Als gelesen markieren';

  @override
  String get unread => 'Ungelesen';

  @override
  String get pending => 'Ausstehend';

  @override
  String get accepted => 'Akzeptiert';

  @override
  String get declined => 'Abgelehnt';

  @override
  String get resolved => 'Gelöst';

  @override
  String get inProgress => 'In Bearbeitung';

  @override
  String get locked => 'Gesperrt';

  @override
  String get full => 'Voll';

  @override
  String get off => 'Aus';

  @override
  String get system => 'System';

  @override
  String get user => 'User';

  @override
  String get overlayMode => 'Overlay-Modus';

  @override
  String get comingSoon => 'Kommt gleich';

  @override
  String get noAccess => 'Kein Zugriff';

  @override
  String get sureQuestion => 'Sicher?';

  @override
  String get disconnect => 'Trennen';

  @override
  String get disconnectConfirm => 'Verbindung trennen?';

  @override
  String get disconnected => 'Verbindung aufgelöst';

  @override
  String get connect => 'Verbinden';

  @override
  String get connectionRemove => 'Verknüpfung entfernen';

  @override
  String get archive => 'Archivieren';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get editTitle => 'Titel bearbeiten';

  @override
  String get filterReset => 'Filter zurücksetzen';

  @override
  String get sendEmail => 'E-Mail senden';

  @override
  String get day => 'Tag';

  @override
  String get moreTools => 'Weitere Tools';

  @override
  String get checkAgain => 'Nochmals prüfen';

  @override
  String get adDelete => 'Anzeige löschen?';

  @override
  String adDeleteMessage(String title) {
    return '„$title“ wird unwiderruflich gelöscht.';
  }

  @override
  String get adGlobalSettings => 'Globale Einstellungen';

  @override
  String get adEnabled => 'Werbung aktiviert';

  @override
  String get adGoogleAds => 'Google Ads';

  @override
  String get adAdmobBanner => 'AdMob Banner-Werbung anzeigen';

  @override
  String get adPartnerAds => 'Partner-Anzeigen';

  @override
  String adPartnerAdsCount(int count) {
    return 'Partner-Anzeigen ($count)';
  }

  @override
  String get adFrequency => 'Häufigkeit';

  @override
  String get adPartnerCreate => 'Partner-Anzeige erstellen';

  @override
  String get adminActivities7d => 'Admin-Aktivitäten (7 Tage)';

  @override
  String get adminActionDistribution7d => 'Aktionsverteilung (7 Tage)';

  @override
  String get adminNewRegistrations30d => 'Neuregistrierungen (30 Tage)';

  @override
  String get adminRegistrations => 'Registrierungen';

  @override
  String get adminStatusOverview => 'Status-Übersicht';

  @override
  String get adminAllRoles => 'Alle Rollen';

  @override
  String get adminUserManage => 'Nutzer verwalten';

  @override
  String get adminUserLock => 'Nutzer sperren';

  @override
  String get adminAuditLog => 'Audit-Log';

  @override
  String get adminLogsAppear => 'Logs erscheinen hier.';

  @override
  String get adminMaintenanceMode => 'Wartungsmodus aktivieren';

  @override
  String get adminMaintenanceError =>
      'Wartungsmodus konnte nicht geändert werden.';

  @override
  String get adminFirebaseSmokeTest => 'Firebase Smoke Test';

  @override
  String get declineRequest => 'Anfrage ablehnen';

  @override
  String get requestDeclined => 'Anfrage wurde abgelehnt';

  @override
  String get requestNotFound => 'Antrag nicht gefunden.';

  @override
  String get requestReactivate => 'Antrag reaktivieren?';

  @override
  String requestReactivated(String name) {
    return 'Antrag von $name reaktiviert.';
  }

  @override
  String get reactivate => 'Reaktivieren';

  @override
  String get reactivationFailed => 'Reaktivierung fehlgeschlagen.';

  @override
  String get verificationFailed => 'Verifizierung fehlgeschlagen.';

  @override
  String get declineReason => 'Grund der Ablehnung';

  @override
  String get declineReasonAlt => 'Grund für Ablehnung';

  @override
  String get internalCommentOptional => 'Optionaler interner Kommentar:';

  @override
  String get decline => 'Ablehnen';

  @override
  String get accept => 'Annehmen';

  @override
  String get revoke => 'Widerrufen';

  @override
  String pushTo(String target) {
    return 'Push an $target';
  }

  @override
  String pushSent(String target) {
    return 'Push an $target gesendet.';
  }

  @override
  String get pushSendError => 'Push konnte nicht gesendet werden.';

  @override
  String get kneeArthroscopy => 'Knie‑Arthroskopie';

  @override
  String get uniClinicMunich => 'Uniklinikum München';

  @override
  String get wakeTimeMustBeAfterBed =>
      'Aufwachzeit muss nach der Bettzeit liegen.';

  @override
  String get qrCodeScan => 'QR-Code scannen';

  @override
  String get releaseAll => 'Alles freigeben';

  @override
  String get keyActivate => 'Key aktivieren';

  @override
  String get keyDeactivate => 'Key deaktivieren?';

  @override
  String get keyDeactivated => 'Key deaktiviert.';

  @override
  String get keyCreated => 'Key erstellt';

  @override
  String get keyDeactivateError => 'Key konnte nicht deaktiviert werden.';

  @override
  String get keyCreateError => 'Key konnte nicht erstellt werden.';

  @override
  String get keysLoadError => 'Keys konnten nicht geladen werden.';

  @override
  String validForDays(int days) {
    return 'Gültig für $days Tage';
  }

  @override
  String get validityDuration => 'Gültigkeitsdauer:';

  @override
  String get targetGroup => 'Zielgruppe';

  @override
  String get endTimeSet => 'Endzeit setzen';

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
}
