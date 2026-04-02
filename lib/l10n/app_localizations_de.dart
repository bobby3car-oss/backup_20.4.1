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
  String appointmentForPatient(String name) {
    return 'Termin für einen Patienten erstellen';
  }

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
  String get patientLinking => 'Patientenverknüpfung';

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

  @override
  String get scSeverityNone => 'Keine';

  @override
  String get scSeverityMild => 'Leicht';

  @override
  String get scSeverityModerate => 'Mittel';

  @override
  String get scSeveritySevere => 'Stark';

  @override
  String get scLevelGreen => 'Grün';

  @override
  String get scLevelYellow => 'Gelb';

  @override
  String get scLevelRed => 'Rot';

  @override
  String get scLevelTitleYellow => 'Bitte beobachten';

  @override
  String get scRecommendGreen =>
      'Ihre Symptome sind unauffällig. Dokumentieren Sie weiterhin regelmäßig und halten Sie sich an Ihren Genesungsplan.';

  @override
  String get scRecommendYellow =>
      'Einzelne Symptome sind leicht auffällig. Beobachten Sie die Entwicklung in den nächsten 24 Stunden. Bei Verschlechterung kontaktieren Sie Ihren Arzt.';

  @override
  String get scRecommendRed =>
      'Ihre Symptome deuten auf eine Komplikation hin. Kontaktieren Sie umgehend Ihren Arzt oder suchen Sie die nächste Notaufnahme auf.';

  @override
  String get scSymPain => 'Schmerzen';

  @override
  String get scSymNausea => 'Übelkeit';

  @override
  String get scSymBreathing => 'Atmung';

  @override
  String get scSymDizziness => 'Schwindel';

  @override
  String get scSymWound => 'Wundstatus';

  @override
  String get scSymPainSub => 'Wie stark sind Ihre Schmerzen im OP-Bereich?';

  @override
  String get scSymNauseaSub => 'Verspüren Sie Übelkeit oder Brechreiz?';

  @override
  String get scSymBreathingSub =>
      'Haben Sie Atembeschwerden oder Kurzatmigkeit?';

  @override
  String get scSymDizzinessSub => 'Fühlen Sie sich benommen oder schwindelig?';

  @override
  String get scSymWoundSub =>
      'Zeigt die Wunde Auffälligkeiten (Rötung, Sekret)?';

  @override
  String get scTitle => 'Symptom‑Check';

  @override
  String get scSymptomsSection => 'Symptome bewerten';

  @override
  String get scYourInputs => 'Ihre Angaben';

  @override
  String get scIntroBody =>
      'Bewerten Sie jedes Symptom. Am Ende erhalten Sie eine Einschätzung mit Empfehlung.';

  @override
  String get scSetDailyReminder => 'Tägliche Erinnerung einrichten';

  @override
  String get scActionsTitle => 'Empfohlene Aktionen';

  @override
  String get scSaveResult => 'Ergebnis speichern';

  @override
  String get scSaving => 'Speichert…';

  @override
  String get scSaved => 'Gespeichert ✓';

  @override
  String scResultBadge(String label) {
    return 'Ergebnis: $label';
  }

  @override
  String scReminderActive(String time) {
    return 'Erinnerung: $time';
  }

  @override
  String scReminderSet(String time) {
    return 'Erinnerung gesetzt für $time';
  }

  @override
  String get nichtHinterlegt => 'Nicht hinterlegt';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldPhone => 'Telefonnummer';

  @override
  String get fieldWeight => 'Gewicht';

  @override
  String get fieldSmoker => 'Raucher';

  @override
  String get fieldOpType => 'OP-Art';

  @override
  String get fieldOpDate => 'OP-Datum';

  @override
  String get fieldOpModus => 'OP-Modus';

  @override
  String get fieldHospitalPhone => 'KH-Telefon';

  @override
  String get fieldDoctorPhone => 'Arzt-Telefon';

  @override
  String get eiBloodType => 'Blutgruppe';

  @override
  String get eiAllergies => 'Allergien';

  @override
  String get eiInsurance => 'Versicherung';

  @override
  String get eiHospital => 'Krankenhaus';

  @override
  String get eiConditions => 'Vorerkrankungen';

  @override
  String get eiMedications => 'Medikamente';

  @override
  String get eiOfflineBanner =>
      'Keine Verbindung – bitte stelle sicher, dass du die Notfallinfos bei einer Gelegenheit mit Internet lädst.';

  @override
  String get eiNoDataHint =>
      'Keine Notfalldaten hinterlegt.\nTrage deine Daten im Profil ein.';

  @override
  String get eiOpenProfile => 'Profil öffnen';

  @override
  String get eiShareHeader => '🆘 NOTFALL-INFORMATIONEN';

  @override
  String get eiShareEmergency => 'Notruf: 112';

  @override
  String get eiSummaryNameHint => 'z.B. Max Mustermann';

  @override
  String get eiSummaryPhoneHint => 'z.B. +49 170 1234567';

  @override
  String get eiSummaryOpType => 'OP-Typ';

  @override
  String get eiSummaryOpDateUnknown => 'Noch unbekannt';

  @override
  String get eiSummaryTreatment => 'Behandlung';

  @override
  String get eiSummaryAmbulant => 'Ambulant';

  @override
  String eiShareBloodType(String value) {
    return 'Blutgruppe: $value';
  }

  @override
  String eiShareAllergies(String value) {
    return 'Allergien: $value';
  }

  @override
  String eiShareContact(String name) {
    return 'Notfallkontakt: $name';
  }

  @override
  String eiSharePhone(String value) {
    return 'Tel: $value';
  }

  @override
  String eiShareHospital(String name) {
    return 'Krankenhaus: $name';
  }

  @override
  String eiShareHospitalPhone(String value) {
    return 'KH-Tel: $value';
  }

  @override
  String eiShareDoctor(String name) {
    return 'Arzt: $name';
  }

  @override
  String eiShareDoctorPhone(String value) {
    return 'Arzt-Tel: $value';
  }

  @override
  String eiShareInsurance(String value) {
    return 'Versicherung: $value';
  }

  @override
  String get notfallInfoTeilen => 'Notfall-Info teilen';

  @override
  String get notruf112 => 'Notruf 112';

  @override
  String get fehlerSpeichernErneut =>
      'Fehler beim Speichern. Erneut versuchen.';

  @override
  String get fehlerBeimSpeichern => 'Fehler beim Speichern.';

  @override
  String get woWirstDuBehandelt => 'Wo wirst du behandelt?';

  @override
  String get fastGeschafft => 'Fast geschafft!';

  @override
  String get opClinic => 'Klinik';

  @override
  String get deinGesundheitsprofil => 'Dein Gesundheitsprofil';

  @override
  String get aktuelleMedikamente => 'Aktuelle Medikamente';

  @override
  String get oPTypEingeben => 'OP-Typ eingeben';

  @override
  String get mitKrankenhausaufenthalt => 'Mit Krankenhausaufenthalt';

  @override
  String get profilGespeichertKurz => 'Profil gespeichert';

  @override
  String get koerperwerteUndGesundheit => 'Körperwerte & Gesundheit';

  @override
  String get notfallkontaktUndNotfallInfo => 'Notfallkontakt & Notfall-Info';

  @override
  String get bezeichnungEingeben => 'Bezeichnung eingeben';

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
    return '$label hinzufügen';
  }

  @override
  String get vitalwerte => 'Vitalwerte';

  @override
  String get neueMessung => 'Neue Messung';

  @override
  String get systolisch => 'Systolisch';

  @override
  String get diastolisch => 'Diastolisch';

  @override
  String get puls => 'Puls';

  @override
  String get normalSystolisch => 'Normal: 90–140';

  @override
  String get normalDiastolisch => 'Normal: 60–90';

  @override
  String get normalPuls => 'Normal: 60–100';

  @override
  String get weitereWerteOptional => 'Weitere Werte (optional)';

  @override
  String get vitalsErinnerung => 'Erinnerung';

  @override
  String get taeglicheMesserinnerung => 'Tägliche Messerinnerung';

  @override
  String get temperatur => 'Temperatur';

  @override
  String get normalTemperatur => 'Normal: 36.0–37.5 °C';

  @override
  String get normalO2Saettigung => 'Normal: 95–100 %';

  @override
  String get notizOptional => 'Notiz (optional)';

  @override
  String get mindZweiEintraege => 'Mind. 2 Einträge für den Verlauf';

  @override
  String get vitalsTipp =>
      'Tipp: Trage deine Vitalwerte täglich ein – so erkennst du Trends frühzeitig.';

  @override
  String get chartLast5 => '5 Einträge';

  @override
  String get chartDays7 => '7 Tage';

  @override
  String get chartDays30 => '30 Tage';

  @override
  String get blutdruck => 'Blutdruck';

  @override
  String get trageVitalwerteEin => 'Trage deine aktuellen Vitalwerte ein.';

  @override
  String normalbereichValue(String min, String max, String unit) {
    return 'Normalbereich: $min–$max $unit';
  }

  @override
  String neueMessungenSync(int count) {
    return '$count neue Messungen synchronisiert';
  }

  @override
  String get neueMessungEintragen => 'Neue Messung eintragen';

  @override
  String get messungGespeichert => 'Messung gespeichert';

  @override
  String get schmerzfrei => 'Schmerzfrei';

  @override
  String get sehrStark => 'Sehr stark';

  @override
  String get schmerztagebuch => 'Schmerztagebuch';

  @override
  String get wieStarkSindDeineSchmerzen => 'Wie stark sind deine Schmerzen?';

  @override
  String get woTutEsWeh => 'Wo tut es weh?';

  @override
  String get optionalTippeAufEineRegion => 'Optional – tippe auf eine Region';

  @override
  String get artDerSchmerzen => 'Art der Schmerzen';

  @override
  String get optionalWieFuehltEsSichAn => 'Optional – wie fühlt es sich an?';

  @override
  String get avgSiebenTage => 'Ø 7 Tage';

  @override
  String get gesamt => 'Gesamt';

  @override
  String get trendLabel => 'Trend';

  @override
  String get minMax => 'Min / Max';

  @override
  String eintraegeInsgesamt(int count) {
    return '$count Einträge insgesamt';
  }

  @override
  String get mehrMitPro => 'Mehr mit Pro';

  @override
  String letzteEintraege(int count) {
    return 'Letzte $count Einträge';
  }

  @override
  String letzteEintraegeGratis(int count) {
    return 'Letzte $count Einträge (5 gratis)';
  }

  @override
  String get letzteEintraegeHeader => 'Letzte Einträge';

  @override
  String get alleAnzeigen => 'Alle →';

  @override
  String get gradesEben => 'Gerade eben';

  @override
  String vorMinuten(int min) {
    return 'vor $min Min.';
  }

  @override
  String vorStunden(int h) {
    return 'vor $h Std.';
  }

  @override
  String get gestern => 'Gestern';

  @override
  String vorTagen(int days) {
    return 'vor $days Tagen';
  }

  @override
  String get ortOptional => 'Ort (optional)';

  @override
  String get ausloeserOptional => 'Auslöser (optional)';

  @override
  String get painEntryEditorNotizOptional => 'Notiz (optional)';

  @override
  String get eintragBearbeiten => 'Eintrag bearbeiten';

  @override
  String get schmerzlevel => 'Schmerzlevel';

  @override
  String get wann => 'Wann?';

  @override
  String get datumLabel => 'Datum';

  @override
  String get uhrzeitLabel => 'Uhrzeit';

  @override
  String get dauerLabel => 'Dauer';

  @override
  String get dauerhaft => 'Dauerhaft';

  @override
  String minMinuten(int min) {
    return '$min Min.';
  }

  @override
  String stundenLabel(int h) {
    return '$h Std.';
  }

  @override
  String get medikationLabel => 'Medikation';

  @override
  String get eintragLoeschen => 'Eintrag löschen';

  @override
  String get kalender => 'Kalender';

  @override
  String get proLabel => 'Pro';

  @override
  String get filterAktiv => 'Filter aktiv';

  @override
  String get filtern => 'Filtern';

  @override
  String get koerperregion => 'Körperregion';

  @override
  String get schmerzart => 'Schmerzart';

  @override
  String get insights => 'Einblicke';

  @override
  String haeufigstesGebiet(String region) {
    return 'Häufigstes Gebiet: $region';
  }

  @override
  String get keineEintraegeFilter => 'Keine Einträge mit diesen Filtern';

  @override
  String get nochKeineEintraege => 'Noch keine Einträge';

  @override
  String get tippeAufNeuenEintrag =>
      'Tippe auf \"+ Neuer Eintrag\" um zu starten';

  @override
  String avgWert(String val) {
    return 'Ø $val';
  }

  @override
  String get heute => 'Heute';

  @override
  String get montag => 'Montag';

  @override
  String get dienstag => 'Dienstag';

  @override
  String get mittwoch => 'Mittwoch';

  @override
  String get donnerstag => 'Donnerstag';

  @override
  String get freitag => 'Freitag';

  @override
  String get samstag => 'Samstag';

  @override
  String get sonntag => 'Sonntag';

  @override
  String get moKurz => 'Mo';

  @override
  String get diKurz => 'Di';

  @override
  String get miKurz => 'Mi';

  @override
  String get doKurz => 'Do';

  @override
  String get frKurz => 'Fr';

  @override
  String get saKurz => 'Sa';

  @override
  String get soKurz => 'So';

  @override
  String get keinSchmerz => 'Kein';

  @override
  String get kalenderMitProFreischalten => 'Kalender mit Pro freischalten';

  @override
  String get keineDetails => 'Keine Details';

  @override
  String get minLabel => 'Min';

  @override
  String get maxLabel => 'Max';

  @override
  String get bellaAnalyse => 'Bella Analyse';

  @override
  String get emptyNoEntries => 'Noch keine Einträge';

  @override
  String get emptyWoundDocHint =>
      'Dokumentiere deinen Heilungsverlauf mit täglichen Fotos.';

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
  String get keinFotoAnalyse => 'Kein Foto vorhanden.';

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
    return 'Schmerzstärke: $score/10';
  }

  @override
  String get fotoLadeFehler => 'Foto konnte nicht geladen werden.';

  @override
  String get fotoHinzufuegen => 'Foto hinzufügen';

  @override
  String get fotoQuelleWaehlen => 'Foto-Quelle wählen';

  @override
  String get kameraOeffnen => 'Kamera';

  @override
  String get ausGalerieWaehlen => 'Aus Galerie';

  @override
  String get fotoAendern => 'Foto ändern';

  @override
  String get fotoEntfernen => 'Foto entfernen';

  @override
  String get kameraBerechtigungFehlt =>
      'Kamera-Zugriff verweigert. Bitte erlaube den Kamera-Zugriff in den Einstellungen.';

  @override
  String get fotoMediathekBerechtigungFehlt =>
      'Zugriff auf Fotomediathek verweigert. Bitte erlaube den Zugriff in den Einstellungen.';

  @override
  String get kameraFehlerVersucheGalerie =>
      'Kamera nicht verfügbar. Bitte wähle ein Foto aus der Galerie.';

  @override
  String get koerperstelleOptional => 'Körperstelle (optional)';

  @override
  String get woundCompareTitle => 'Wundvergleich';

  @override
  String get woundCompareSlider => 'Verlauf';

  @override
  String get woundCompareCompare => 'Vergleich';

  @override
  String get emptyNoPhotos => 'Noch keine Fotos vorhanden.';

  @override
  String get emptyWoundCompareHint =>
      'Füge Fotos zur Wunddokumentation hinzu, um den Verlauf zu vergleichen.';

  @override
  String get wundDokumentationTitle => 'Wunddokumentation';

  @override
  String get woundNoPhotoYet => 'Noch kein Foto';

  @override
  String get woundNoteHint => 'Wie sieht die Wunde aus? Besonderheiten?';

  @override
  String get notizLabel => 'Notiz';

  @override
  String get woundHistoryTitle => 'Wundverlauf';

  @override
  String get woundDiaryTitle => 'Wundtagebuch';

  @override
  String get woundDiarySubtitle =>
      'Chronologische Übersicht Ihrer Wundheilung mit Fotos und Notizen.';

  @override
  String get woundPhotoGuideTitle => 'Foto-Anleitung';

  @override
  String get woundPhotoGuideSubtitle =>
      'Für eine gute Dokumentation empfehlen wir täglich 2 Fotos:';

  @override
  String get woundPhotoTip =>
      'Tipp: Achten Sie auf gute Beleuchtung und fotografieren Sie aus dem gleichen Winkel.';

  @override
  String get woundNoNotiz => 'Keine Notiz';

  @override
  String get woundDetailTitle => 'Wunddetail';

  @override
  String get notSpecified => 'Nicht angegeben';

  @override
  String get woundDeleteConfirmMessage =>
      'Dieser Wundeintrag wird dauerhaft entfernt.';

  @override
  String get woundMinEntriesForCompare =>
      'Mindestens 2 Wundeinträge für Vergleich erforderlich.';

  @override
  String get woundDiscoveryTip =>
      'Tipp: Fotografiere deine Wunde regelmäßig – so erkennst du Veränderungen auf einen Blick.';

  @override
  String woundEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get woundNoPhotoCaptured => 'Kein Foto vorhanden';

  @override
  String get woundTapForDetails => 'Tippen für Details';

  @override
  String get woundComparePick2 => 'Wähle zwei Fotos zum Vergleichen';

  @override
  String get woundModeSplit => 'Split';

  @override
  String get woundModeOverlay => 'Overlay';

  @override
  String woundComparePhotosSelected(int count) {
    return '$count / 2 Fotos gewählt';
  }

  @override
  String get woundCompareTapInstruction =>
      'Tippe unten auf die Fotos, die du vergleichen möchtest.';

  @override
  String get before => 'Vorher';

  @override
  String get after => 'Nachher';

  @override
  String get woundHygieneStep1 => 'Hände gründlich waschen';

  @override
  String get woundHygieneStep2 => '🩹 Trockener Pflasterwechsel';

  @override
  String get woundHygieneStep3 =>
      'Wunddoku: Trocken? Nicht rot? Keine frische Blutung?';

  @override
  String get woundHygieneStep4 =>
      'Keine Berührung der Wunde, keine Manipulation, keine Cremes';

  @override
  String get woundHygieneStep5 =>
      'Pflaster ohne Berührung der Auflage erneuern';

  @override
  String get woundHygieneStep6 => 'Erneut Hände waschen';

  @override
  String get woundHygieneTitle => '🧴 Wundhygiene-Empfehlungen';

  @override
  String get woundHygieneWarning => 'Bei Rötung bitte Praxis kontaktieren';

  @override
  String woundHygieneAckLabel(String date) {
    return '✅ Gelesen am $date';
  }

  @override
  String get kalorienKcal => 'Kalorien (kcal)';

  @override
  String get nutritionProteinG => 'Protein (g)';

  @override
  String get wasserMl => 'Wasser (ml)';

  @override
  String get nameDerVorlage => 'Name der Vorlage';

  @override
  String get zBHaferbreiMitBeeren => 'z. B. Haferbrei mit Beeren';

  @override
  String get zbVollkornbrot => 'z. B. Vollkornbrot mit Käse';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get nutritionKohlenhG => 'Kohlenhydrate (g)';

  @override
  String get nutritionFettG => 'Fett (g)';

  @override
  String templateWirdEntfernt(String name) {
    return '„$name“ wird aus deinen Vorlagen entfernt.';
  }

  @override
  String get naehrwerteOptional => 'Nährwerte (optional)';

  @override
  String get kohlenhG => 'Kohlenhydrate (g)';

  @override
  String get fettG => 'Fett (g)';

  @override
  String get getrunkenMl => 'Getrunken (ml)';

  @override
  String get vertraeglichkeit => 'Verträglichkeit';

  @override
  String get mahlzeitSpeichern => 'Mahlzeit speichern';

  @override
  String wasserMlDescription(int ml) {
    return 'Wasser ${ml}ml';
  }

  @override
  String wasserMlAdded(int ml) {
    return '+${ml}ml Wasser erfasst';
  }

  @override
  String get vorlageLabel => 'Vorlage';

  @override
  String get wasserTracking => 'Wasser-Tracking';

  @override
  String get favoriten => 'Favoriten';

  @override
  String get tippeZumSchnellenWiederholen => 'Tippe zum schnellen Wiederholen';

  @override
  String get mahlzeitLabel => 'Mahlzeit';

  @override
  String get wasHastDuGegessen => 'Was hast du gegessen?';

  @override
  String get optionalWasserTeeEtc => 'Optional – Wasser, Tee, etc.';

  @override
  String get optionalWieVertragen =>
      'Optional – wie hast du das Essen vertragen?';

  @override
  String get symptomeNachDemEssen => 'Symptome nach dem Essen';

  @override
  String get optionalTippeAuf => 'Optional – tippe auf zutreffende Symptome';

  @override
  String get naehrwerteTitle => 'Nährwerte';

  @override
  String get optionalKalorienProtein =>
      'Optional – Kalorien, Protein, Kohlenhydrate, Fett';

  @override
  String get vorlagenTitle => 'Vorlagen';

  @override
  String empfehlungFuerOp(String opType) {
    return 'Empfehlung für $opType-OP';
  }

  @override
  String empfehlungFuerOpTag(int day) {
    return ' · Tag $day';
  }

  @override
  String get empfehlungenTitle => 'Empfehlungen';

  @override
  String heuteMahlzeitenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mahlzeiten',
      one: '1 Mahlzeit',
    );
    return '$_temp0';
  }

  @override
  String get kcalLabel => 'kcal';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get wasserLabel => 'Wasser';

  @override
  String symptomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Symptome',
      one: '1 Symptom',
    );
    return '$_temp0';
  }

  @override
  String keineFilterEintraege(String mealType) {
    return 'Keine $mealType-Einträge';
  }

  @override
  String get ersteMahlzeitTipp =>
      'Tippe auf + um deine erste Mahlzeit zu erfassen.';

  @override
  String get beschreibungLabel => 'Beschreibung';

  @override
  String get zbVollkornbrotQuark => 'z. B. Vollkornbrot mit Quark und Tomaten';

  @override
  String get zbZahl => 'z. B. 250';

  @override
  String get symptomeLabel => 'Symptome';

  @override
  String get notizZuSymptomenOptional => 'Notiz zu den Symptomen (optional)';

  @override
  String get eintrBearbeiten => 'Eintrag bearbeiten';

  @override
  String get neueMahlzeit => 'Neue Mahlzeit';

  @override
  String get eintrLoeschen => 'Eintrag löschen';

  @override
  String get mealTypeFruehstueck => 'Frühstück';

  @override
  String get mealTypeMittagessen => 'Mittagessen';

  @override
  String get mealTypeAbendessen => 'Abendessen';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get symptomUebelkeit => 'Übelkeit';

  @override
  String get symptomBlaehungen => 'Blähungen';

  @override
  String get symptomSchmerzen => 'Schmerzen';

  @override
  String get symptomSodbrennen => 'Sodbrennen';

  @override
  String get symptomDurchfall => 'Durchfall';

  @override
  String get symptomVerstopfung => 'Verstopfung';

  @override
  String get symptomMuedigkeit => 'Müdigkeit';

  @override
  String get symptomSonstige => 'Sonstige';

  @override
  String get nochmal => 'Nochmal';

  @override
  String get ablaufNarkoseEingriffe => 'Ablauf, Narkose, Eingriffe';

  @override
  String get abmelden => 'Abmelden';

  @override
  String get adminAbmeldenBestaetigung =>
      'Wirklich aus dem Admin-Bereich abmelden?';

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
  String get alle => 'Alle';

  @override
  String get alleAlsGelesenMarkieren => 'Alle als gelesen markieren';

  @override
  String get alleFunktionenOhneEinschraenkung =>
      'Alle Funktionen ohne Einschränkung';

  @override
  String get alleMarkieren => 'Alle →';

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
  String get appointmentEditorRepeatUntil => 'Wiederholen bis';

  @override
  String get apptAddFirstHint =>
      'Tippe auf +, um deinen ersten Termin hinzuzufügen.';

  @override
  String get apptCancelAppt => 'Termin absagen';

  @override
  String get apptConfirmationPending => 'Bestätigung ausstehend';

  @override
  String get apptConfirmDeclineHint => 'Bitte bestätigen oder ablehnen.';

  @override
  String get apptCreatedByDoctor => 'Vom Arzt erstellt';

  @override
  String get apptDeleteTitle => 'Termin löschen';

  @override
  String get apptEditTitle => 'Termin bearbeiten';

  @override
  String get apptHintCustomMinutes => 'Minuten';

  @override
  String get apptHintDoctor => 'z.B. Dr. Müller';

  @override
  String get apptHintLocation => 'z.B. Städtisches Klinikum';

  @override
  String get apptHintLocationDetails => 'Details (Station, Zimmer)';

  @override
  String get apptHintNote => 'Optionale Notiz…';

  @override
  String get apptHintTitle => 'z. B. Nachsorgetermin';

  @override
  String get apptLabelCustomMinutes => 'Minuten';

  @override
  String get apptLabelDate => 'Datum';

  @override
  String get apptLabelDoctor => 'Arzt / Behandler';

  @override
  String get apptLabelEndTime => 'Endzeit';

  @override
  String get apptLabelFurtherDetails => 'Weitere Details';

  @override
  String get apptLabelFurtherReminders => 'Weitere Erinnerungen';

  @override
  String get apptLabelLocation => 'Ort';

  @override
  String get apptLabelNote => 'Notiz';

  @override
  String get apptLabelPriority => 'Priorität';

  @override
  String get apptLabelReminder => 'Erinnerung';

  @override
  String get apptLabelRepeatUntil => 'Bis';

  @override
  String get apptLabelStartTime => 'Startzeit';

  @override
  String get apptLabelTime => 'Uhrzeit';

  @override
  String get apptLabelTitleRequired => 'Titel *';

  @override
  String get apptLabelType => 'Typ';

  @override
  String get apptMarkAsDone => 'Als erledigt markieren';

  @override
  String get apptMarkAsPlanned => 'Als geplant markieren';

  @override
  String get apptNewTitle => 'Neuer Termin';

  @override
  String get apptNoAppointments => 'Noch keine Termine';

  @override
  String get apptNoResults => 'Keine Ergebnisse';

  @override
  String get apptNoResultsHint => 'Andere Suchbegriffe oder Filter verwenden.';

  @override
  String get apptPriorityHigh => 'Hoch';

  @override
  String get apptPriorityLow => 'Niedrig';

  @override
  String get apptPriorityMedium => 'Mittel';

  @override
  String get apptPriorityUrgent => 'Dringend';

  @override
  String get apptReminderAtTime => 'Pünktlich';

  @override
  String get apptReminderCustom => 'Benutzerdefiniert';

  @override
  String get apptReminderDay1 => '1 Tag vorher';

  @override
  String get apptReminderDays2 => '2 Tage vorher';

  @override
  String get apptReminderHour1 => '1 Stunde vorher';

  @override
  String get apptReminderHours2 => '2 Stunden vorher';

  @override
  String get apptReminderMin15 => '15 Min. vorher';

  @override
  String get apptReminderMin30 => '30 Min. vorher';

  @override
  String get apptReminderNone => 'Keine';

  @override
  String get apptRepeatDaily => 'Täglich';

  @override
  String get apptRepeatMonthly => 'Monatlich';

  @override
  String get apptRepeatNone => 'Keine';

  @override
  String get apptRepeatWeekly => 'Wöchentlich';

  @override
  String get apptSaving => 'Wird gespeichert…';

  @override
  String get apptStatusCanceled => 'Abgesagt';

  @override
  String get apptStatusCompleted => 'Abgeschlossen';

  @override
  String get apptStatusConfirmed => 'Bestätigt';

  @override
  String get apptStatusDeclined => 'Abgelehnt';

  @override
  String get apptStatusDone => 'Erledigt';

  @override
  String get apptStatusPending => 'Ausstehend';

  @override
  String get apptStatusPlanned => 'Geplant';

  @override
  String get apptTitleRequired => 'Titel ist erforderlich.';

  @override
  String get apptTodayNone => 'Heute keine Termine';

  @override
  String get apptTodayTitle => 'Heutige Termine';

  @override
  String get apptTypeCall => 'Telefonat';

  @override
  String get apptTypeFollowUp => 'Nachsorge';

  @override
  String get apptTypeImaging => 'Bildgebung';

  @override
  String get apptTypeOther => 'Sonstiges';

  @override
  String get apptTypePhysio => 'Physiotherapie';

  @override
  String get apptTypeSurgery => 'Operation';

  @override
  String get apptViewCalendar => 'Kalender';

  @override
  String get apptViewList => 'Liste';

  @override
  String get apptYesterday => 'Gestern';

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
  String get aufnahmeStartFehler => 'Aufnahme konnte nicht gestartet werden.';

  @override
  String get aufProUpgraden => 'Auf Pro upgraden';

  @override
  String get auswertungAnzeigen => 'Auswertung anzeigen';

  @override
  String get bedarfsmedikationOderSpontaneEinnahmen =>
      'Bedarfsmedikation oder spontane Einnahmen.';

  @override
  String get begruendungEingeben => 'Begründung eingeben …';

  @override
  String get beiAkuterVerschlechterung => 'Bei akuter Verschlechterung';

  @override
  String get beiVerschlechterungAnrufen => 'Bei Verschlechterung anrufen';

  @override
  String get bellaActionCancelled => 'Abgebrochen';

  @override
  String get bellaActionCreated => 'Eintrag erstellt ✓';

  @override
  String get bellaActionFailed => 'Erstellen fehlgeschlagen';

  @override
  String get bellaArztBriefing => 'Bella Arzt-Briefing';

  @override
  String get bellaAskDirectly => 'Oder stelle direkt eine Frage:';

  @override
  String get bellaBriefingGenerating => 'Bella erstellt dein Arzt-Briefing…';

  @override
  String get bellaBriefingIsProFeature => 'Arzt-Briefing ist eine Pro-Funktion';

  @override
  String get bellaBriefingNotSignedIn => 'Bitte anmelden.';

  @override
  String get bellaBriefingPersonalTitle => 'Dein persönliches Arzt-Briefing';

  @override
  String get bellaBriefingProDescription =>
      'Mit Pro erstellt Bella eine persönliche Zusammenfassung für deinen nächsten Arzttermin.';

  @override
  String get bellaChipAddTask => 'Aufgabe hinzufügen: Wunde prüfen';

  @override
  String get bellaChipAppFunctions => 'Welche App-Funktionen gibt es?';

  @override
  String get bellaChipCallDoctor => 'Wann sollte ich den Arzt anrufen?';

  @override
  String get bellaChipCreateAppointment =>
      'Einen Termin für morgen um 10 Uhr erstellen';

  @override
  String get bellaChipDoctorDashboard => 'Wie funktioniert das Arzt-Dashboard?';

  @override
  String get bellaChipDoctorReport => 'Wie erstelle ich einen Arztbericht?';

  @override
  String get bellaChipGeneralDashboard => 'Wie funktioniert das Dashboard?';

  @override
  String get bellaChipKneeTep => 'Info zur Knie-TEP';

  @override
  String get bellaChipLinkPatient => 'Wie verknüpfe ich einen Patienten?';

  @override
  String get bellaChipLogBloodPressure => 'Blutdruck 120/80 erfassen';

  @override
  String get bellaChipLogMedication => 'Ich habe gerade Ibuprofen genommen';

  @override
  String get bellaChipLogPain => 'Schmerzen erfassen: Knie, Stufe 4';

  @override
  String get bellaChipMedications => 'Wie dokumentiere ich meine Medikamente?';

  @override
  String get bellaChipMyTasks => 'Was sind meine Aufgaben?';

  @override
  String get bellaChipOpDay => 'Was passiert am OP-Tag?';

  @override
  String get bellaChipPrepareOp => 'Wie bereite ich mich auf die OP vor?';

  @override
  String get bellaChipSymptomCheck => 'Symptom-Check starten';

  @override
  String get bellaChipTimeline => 'Wie funktioniert die Timeline?';

  @override
  String get bellaChipVerifyAccount => 'Wie verifiziere ich mein Arzt-Konto?';

  @override
  String get bellaChipViewPatientData => 'Wie sehe ich Patientendaten?';

  @override
  String get bellaChipViewPatientDataStaff => 'Wie sehe ich Patientendaten?';

  @override
  String get bellaConsentAccepted => 'Zustimmung erteilt';

  @override
  String get bellaConsentBody =>
      'Der KI-Assistent (Bella AI) nutzt einen externen Dienst (NVIDIA Corporation, USA), um deine Fragen zu beantworten. Mit deiner Zustimmung werden deine Eingaben an diesen Dienst übertragen. Keine persönlichen Gesundheitsdaten werden dauerhaft gespeichert.';

  @override
  String get bellaConsentDeclined => 'Zustimmung abgelehnt';

  @override
  String get bellaConsentTitle => 'Datenschutzhinweis';

  @override
  String get bellaConsentYes => 'Ja, ich stimme zu';

  @override
  String get bellaDailyAnalysis => 'Bella Tagesanalyse';

  @override
  String get bellaDefaultWoundPrompt => 'Bitte analysiere dieses Wundfoto.';

  @override
  String get bellaDescriptionDoctor =>
      'Ich helfe dir beim Arzt-Dashboard, der Patientenverwaltung und bei klinischen Fragen.';

  @override
  String get bellaDescriptionPatient =>
      'Ich beantworte deine Fragen zu deiner OP, der Nachsorge und der App.';

  @override
  String get bellaDescriptionStaff =>
      'Ich helfe dir beim Mitarbeiter-Dashboard und der Patientenbetreuung.';

  @override
  String get bellaDisclaimer =>
      'Kein medizinischer Rat – bei Beschwerden bitte einen Arzt aufsuchen.';

  @override
  String get bellaFeatureAftercare => 'Nachsorge';

  @override
  String get bellaFeatureAppHelp => 'App-Hilfe';

  @override
  String get bellaFeatureDashboard => 'Dashboard';

  @override
  String get bellaFeatureMedicalKnowledge => 'Medizinisches Wissen';

  @override
  String get bellaFeaturePatients => 'Patienten';

  @override
  String get bellaFeatureTasks => 'Aufgaben';

  @override
  String get bellaFeatureWarnings => 'Warnzeichen';

  @override
  String get bellaGreeting => 'Hallo! Ich bin Bella AI 🐰';

  @override
  String get bellaNoAnswerReceived =>
      'Keine Antwort erhalten. Bitte erneut versuchen. 🐰';

  @override
  String get bellaProactivePainTrend =>
      'Dein Schmerzniveau steigt – möchtest du darüber sprechen?';

  @override
  String get bellaProUpgrade => 'Jetzt auf Pro upgraden';

  @override
  String get bellaSays => 'Bella sagt:';

  @override
  String get bellaSubtitleDoctor => 'Dein klinischer Assistent 🐰';

  @override
  String get bellaSubtitlePatient => 'Dein OP-Begleiter 🐰';

  @override
  String get bellaSubtitleStaff => 'Dein Praxis-Assistent 🐰';

  @override
  String get bellaWoundAnalysisTitle => 'Wundanalyse';

  @override
  String get bellaWoundDisclaimer =>
      'Kein Ersatz für eine medizinische Diagnose. Im Zweifel das medizinische Team kontaktieren.';

  @override
  String get bellaWoundObservations => 'Beobachtungen';

  @override
  String get bellaWoundProgressComparison => 'Wundverlauf-Vergleich';

  @override
  String get beobachtenSieDieSymptomeGenau =>
      'Beobachten Sie die Symptome genau';

  @override
  String get beobachtungHinzufuegen => 'Beobachtung hinzufügen';

  @override
  String get beschreibeAnliegen =>
      'Beschreibe dein Anliegen so genau wie möglich…';

  @override
  String get beschreibenSieIhreSymptome => 'Beschreiben Sie Ihre Symptome';

  @override
  String get besterPreisProMonat => 'Bester Preis pro Monat';

  @override
  String get broadcastSenden => 'Broadcast senden';

  @override
  String get calendarAddedSuccess => 'Termin zum Kalender hinzugefügt';

  @override
  String get calendarAddToCalendarBody =>
      'Möchtest du diesen Termin zu deinem Gerätekalender hinzufügen oder als .ics-Datei teilen?';

  @override
  String get calendarExportFailed => 'Kalenderexport fehlgeschlagen';

  @override
  String get calendarMonth => 'Monat';

  @override
  String get calendarNoEvents => 'Keine Termine an diesem Tag';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarWeek => 'Woche';

  @override
  String get chronologischDokumentierteEinnahmen =>
      'Chronologisch dokumentierte Einnahmen.';

  @override
  String get codeZumManuellenEingeben => 'Code zum manuellen Eingeben';

  @override
  String get csvExportieren => 'CSV exportieren';

  @override
  String get dashboardPushSenden => 'Push senden';

  @override
  String get dauer => 'Ø Dauer';

  @override
  String get deepLink => 'Deep Link';

  @override
  String get discoverSubtitle => 'Alle Funktionen auf einen Blick';

  @override
  String get discoverTitle => 'Entdecken';

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
  String get einladungscode => 'Einladungscode';

  @override
  String get einladungTeilen => 'Einladung teilen';

  @override
  String get erfasseMedikamenteImMedikamentenplan =>
      'Erfasse Medikamente im Medikamentenplan';

  @override
  String get erfasseSchmerzwerteImSchmerztagebuch =>
      'Erfasse Schmerzwerte im Schmerztagebuch';

  @override
  String get erfasseVitalwerteUnterVitals =>
      'Erfasse Vitalwerte unter Vitaldaten';

  @override
  String get erinnerungErstellen => 'Erinnerung erstellen';

  @override
  String get erneutPruefen => 'Erneut prüfen';

  @override
  String get errorAlreadyExists => 'Bereits vorhanden.';

  @override
  String get errorCancelled => 'Vorgang abgebrochen.';

  @override
  String get errorDeadlineExceeded =>
      'Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String get errorEmailInUse => 'Diese E-Mail-Adresse wird bereits verwendet.';

  @override
  String get errorFailedPrecondition =>
      'Aktion kann nicht durchgeführt werden.';

  @override
  String get errorInvalidArgument => 'Ungültige Eingabe.';

  @override
  String get errorInvalidEmail => 'Ungültige E-Mail-Adresse.';

  @override
  String get errorNoInternet =>
      'Keine Internetverbindung. Bitte Netzwerk prüfen.';

  @override
  String get errorNotFound => 'Nicht gefunden. Bitte Eingabe prüfen.';

  @override
  String get errorNotFoundShort => 'Nicht gefunden.';

  @override
  String get errorOperationNotAllowed => 'Diese Aktion ist nicht erlaubt.';

  @override
  String get errorPermissionDenied => 'Keine Berechtigung für diese Aktion.';

  @override
  String get errorPleaseSignIn => 'Bitte anmelden.';

  @override
  String get errorRequiresRecentLogin =>
      'Bitte erneut anmelden, um fortzufahren.';

  @override
  String get errorResourceExhausted =>
      'Zu viele Anfragen. Bitte einen Moment warten.';

  @override
  String get errorServiceUnavailable =>
      'Der Dienst ist vorübergehend nicht verfügbar. Bitte später erneut versuchen.';

  @override
  String get errorServiceUnavailableShort =>
      'Der Dienst ist vorübergehend nicht verfügbar.';

  @override
  String get errorTooManyRequests =>
      'Zu viele Versuche. Bitte später erneut versuchen.';

  @override
  String get errorUserDisabled => 'Dieses Konto wurde deaktiviert.';

  @override
  String get errorUserNotFound =>
      'Kein Konto mit dieser E-Mail-Adresse gefunden.';

  @override
  String get errorWeakPassword => 'Das Passwort ist zu schwach.';

  @override
  String get errorWrongPassword => 'Falsches Passwort.';

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
  String get exportFehlgeschlagen => 'Export fehlgeschlagen.';

  @override
  String get familyMemberHubZBA1B2C3D4E5F6 => 'z.B. A1B2C3D4E5F6';

  @override
  String get familyPatientsMeinePatienten => 'Meine Patienten';

  @override
  String get familyPatientsZBA1B2C3D4E5F6 => 'z.B. A1B2C3D4E5F6';

  @override
  String get familyProfileZBA1B2C3D4E5F6 => 'z.B. A1B2C3D4E5F6';

  @override
  String get fehlerBeimErstellen => 'Fehler beim Erstellen.';

  @override
  String get firebaseUIDDesArztes => 'Firebase UID des Arztes';

  @override
  String get footerLoveMessage => 'Mit Liebe für deine Genesung entwickelt';

  @override
  String get fotosDurchsuchen => 'Fotos suchen (Datum, Notiz, Kategorie)…';

  @override
  String get frageAnBella => 'Frage an Bella …';

  @override
  String get frageBearbeiten => 'Frage bearbeiten';

  @override
  String get frageStellen => 'Frage stellen …';

  @override
  String get freischalten => 'Freischalten';

  @override
  String get funktionenErklaert => 'Funktionen erklärt';

  @override
  String get grundDerSperrung => 'Grund der Sperrung…';

  @override
  String get grundEingeben => 'Grund eingeben…';

  @override
  String get grundOptional => 'Grund (optional)';

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
  String get hinweistextOptional => 'Hinweistext (optional)';

  @override
  String get homeSummaryCardFaellig => 'fällig';

  @override
  String get ihreAntwortEingeben => 'Antwort eingeben…';

  @override
  String get inaktiv3Tage => 'Inaktiv >3 Tage';

  @override
  String get itemBearbeiten => 'Item bearbeiten';

  @override
  String get jaehrlich => 'Jährlich';

  @override
  String get jederzeitNkuendbar => 'Jederzeit\\nkündbar';

  @override
  String get keineAufgabenImPlan => 'Noch keine Aufgaben im Plan.';

  @override
  String get keineEmailApp => 'Keine E-Mail-App gefunden';

  @override
  String get keineOffenenEinladungen => 'Keine offenen Einladungen.';

  @override
  String get keinUebernachtenNurDasNoetigste =>
      'Kein Übernachten – nur das Nötigste';

  @override
  String get keyIdOderUidSuchen => 'Key-ID oder Einlöser-UID suchen…';

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
  String get losGehts => 'Los geht\'s!';

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
  String get monatlichKuendbar => 'monatlich kündbar';

  @override
  String get monthApril => 'April';

  @override
  String get monthAugust => 'August';

  @override
  String get monthDecember => 'Dezember';

  @override
  String get monthFebruary => 'Februar';

  @override
  String get monthJanuary => 'Januar';

  @override
  String get monthJuly => 'Juli';

  @override
  String get monthJune => 'Juni';

  @override
  String get monthMarch => 'März';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthNovember => 'November';

  @override
  String get monthOctober => 'Oktober';

  @override
  String get monthSeptember => 'September';

  @override
  String get n7TageTreue => '7-Tage Treue';

  @override
  String get nachrichtSchreiben => 'Nachricht schreiben...';

  @override
  String get nachRolleFiltern => 'Nach Rolle filtern';

  @override
  String get naechsteTermine => 'Nächste Termine';

  @override
  String get neuerKey => 'Neuer Key';

  @override
  String get neuerName => 'Neuer Name';

  @override
  String get neuesPacklistenItem => 'Neues Packlisten-Item';

  @override
  String get neuesPasswort => 'Neues Passwort';

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
  String get nurInDebugBuilds => 'Nur in Debug-Builds verfügbar.';

  @override
  String get nurVomArztVerwaltbar => 'Nur vom Arzt verwaltbar';

  @override
  String get nutzerGesamt => 'Nutzer gesamt';

  @override
  String get oeffnenTeilen => 'Öffnen / Teilen';

  @override
  String get offeneFragen => 'Offene Fragen';

  @override
  String get offeneRedFlags => 'Offene Warnsignale';

  @override
  String get ohneMedikation => 'Ohne Medikation';

  @override
  String get opActions => 'Aktionen';

  @override
  String get oPDatum => 'OP Datum';

  @override
  String get opDetails => 'OP-Details';

  @override
  String get opDocumentsLabel => 'Dokumente';

  @override
  String get opManageCaregivers => 'Begleiter\nverwalten';

  @override
  String get opName => 'OP-Name';

  @override
  String get opSymptomsLabel => 'Symptome';

  @override
  String get opTimeline => 'Timeline';

  @override
  String get opType => 'OP-Typ';

  @override
  String get oPUndTimeline => 'OP & Timeline';

  @override
  String get packingItemEditorSheetNotizOptional => 'Notiz (optional)';

  @override
  String get patientAuswaehlen => 'Patient auswählen';

  @override
  String get patientBasisdaten => 'Patient Basisdaten';

  @override
  String get patientenBegleiten => 'Patienten begleiten';

  @override
  String get perEMail => 'Per E-Mail';

  @override
  String get placeholderLoading => 'Wird geladen…';

  @override
  String get praxisnameOptional => 'Praxisname (optional)';

  @override
  String get prioritaet => 'Priorität';

  @override
  String get profilGespeichert => 'Profil gespeichert.';

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
  String get recoveryFeed => 'Genesungs-Feed';

  @override
  String get redU2011FlagSystem => 'Red\\u2011Flag System';

  @override
  String get reportSchmerz => 'Schmerz-Ø';

  @override
  String get reportTagePostOP => 'Tage post-OP';

  @override
  String get rfActiveWarnings => 'Aktive Warnungen';

  @override
  String get rfCheckStart => 'Check starten';

  @override
  String get rfEmergencyFollowSteps => 'Befolge diese Schritte der Reihe nach.';

  @override
  String get rfEmergencyInstructions => 'Notfallanweisungen';

  @override
  String get rfEmergencyStep1Desc => 'Setzen oder hinlegen. Ruhig atmen.';

  @override
  String get rfEmergencyStep1Title => 'Ruhe bewahren';

  @override
  String get rfEmergencyStep2Desc =>
      'Aktuelle Beschwerden und deren Schweregrad notieren.';

  @override
  String get rfEmergencyStep2Title => 'Symptome prüfen';

  @override
  String get rfEmergencyStep3Desc =>
      'Arzt oder Klinik anrufen und Symptome beschreiben.';

  @override
  String get rfEmergencyStep3Title => 'Arzt anrufen';

  @override
  String get rfEmergencyStep4Desc =>
      'Bei Atemnot, Bewusstlosigkeit oder starker Blutung sofort 112 anrufen.';

  @override
  String get rfEmergencySubtitle =>
      'Sofortmaßnahmen bei Atemnot, Bewusstlosigkeit oder starker Blutung.';

  @override
  String get rfEscalate => 'Eskalieren';

  @override
  String get rfNoActiveWarnings => 'Keine aktiven Warnungen. Weiter so!';

  @override
  String get rfNoFlags => 'Keine Red Flags';

  @override
  String get rfProAutoDetect =>
      'Mit Pro erkennt das System automatisch kritische Werte aus Schmerzen, Vitaldaten und mehr.';

  @override
  String get rfProFeatureSubtitle =>
      'Beschwerden manuell eingeben oder auf Pro upgraden.';

  @override
  String get rfProFeatureTitle =>
      'Automatische Red-Flag-Erkennung ist eine Pro-Funktion.';

  @override
  String get rfSeverityDescGreen =>
      'Deine Werte liegen im Normalbereich. Weiter so!';

  @override
  String get rfSeverityDescOrange =>
      'Mehrere Werte auffällig. Bald einen Arzt aufsuchen.';

  @override
  String get rfSeverityDescRed =>
      'Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.';

  @override
  String get rfSeverityDescYellow =>
      'Einige Werte leicht außerhalb des Normalbereichs. Bitte beobachten.';

  @override
  String get rfSeverityOrange => 'Orange';

  @override
  String get rfSeverityRed => 'Rot';

  @override
  String get rfSeverityTitleGreen => 'Alles OK';

  @override
  String get rfSeverityTitleOrange => 'Erhöhtes Risiko';

  @override
  String get rfSeverityTitleRed => 'Jetzt handeln';

  @override
  String get rfSeverityTitleYellow => 'Leichte Auffälligkeit';

  @override
  String get rfSeverityYellow => 'Gelb';

  @override
  String get rfSourceManual => 'Manuell';

  @override
  String get rfSourceObservation => 'Beobachtung';

  @override
  String get rfSourcePain => 'Schmerzen';

  @override
  String get rfSourceSymptomCheck => 'Symptom-Check';

  @override
  String get rfSourceTimeline => 'Timeline-Aufgabe';

  @override
  String get rfSourceVitals => 'Vitaldaten';

  @override
  String get rfSourceWarningCheck => 'Warnzeichen-Check';

  @override
  String get rfSourceWound => 'Wunddaten';

  @override
  String get rfStatusAcknowledged => 'Gesehen';

  @override
  String get rfStatusEscalated => 'Eskaliert';

  @override
  String get rfStatusMonitoring => 'Beobachtung';

  @override
  String get rfStatusOpen => 'Offen';

  @override
  String get rfStatusResolved => 'Gelöst';

  @override
  String get rfWarningCheckSubtitle =>
      'Schnellcheck der wichtigsten Symptome – dauert nur 30 Sekunden.';

  @override
  String get roleDebug => 'Role Debug';

  @override
  String get rolleAuswaehlen => 'Rolle auswählen';

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
  String get searchHint => 'Suchen…';

  @override
  String get sectionAccompany => 'Begleitung';

  @override
  String get sectionAdsAdmin => 'Ads Admin';

  @override
  String get sectionAnalysis => 'Analyse';

  @override
  String get sectionAnalytics => 'Analytik';

  @override
  String get sectionConnectDoctor => 'Arzt verbinden';

  @override
  String get sectionDebugTools => 'Debug Tools';

  @override
  String get sectionDoctorQuestions => 'Arztfragen';

  @override
  String get sectionDoctorReport => 'Arztbericht';

  @override
  String get sectionDocumentation => 'Dokumentation';

  @override
  String get sectionDocuments => 'Dokumente';

  @override
  String get sectionEmergencyInfo => 'Notfallinformationen';

  @override
  String get sectionFirebaseTest => 'Firebase Test';

  @override
  String get sectionHealth => 'Gesundheit';

  @override
  String get sectionHealthReport => 'Gesundheitsbericht';

  @override
  String get sectionHelp => 'Hilfe';

  @override
  String get sectionLanguage => 'Sprache';

  @override
  String get sectionMedication => 'Medikamente';

  @override
  String get sectionMood => 'Stimmung';

  @override
  String get sectionNotifications => 'Benachrichtigungen';

  @override
  String get sectionNutrition => 'Ernährung';

  @override
  String get sectionOpInfo => 'OP-Informationen';

  @override
  String get sectionOpPlanning => 'OP & Planung';

  @override
  String get sectionPackingList => 'Packliste';

  @override
  String get sectionPain => 'Schmerzen';

  @override
  String get sectionPeople => 'Personen';

  @override
  String get sectionPhotos => 'Fotos';

  @override
  String get sectionProfile => 'Profil';

  @override
  String get sectionProgress => 'Fortschritt';

  @override
  String get sectionRecentlyUsed => 'Zuletzt genutzt';

  @override
  String get sectionRedFlags => 'Warnsignale';

  @override
  String get sectionRehabilitation => 'Rehabilitation';

  @override
  String get sectionRoleDebug => 'Role Debug';

  @override
  String get sectionSleep => 'Schlaf';

  @override
  String get sectionSupplements => 'Supplemente';

  @override
  String get sectionSymptomCheck => 'Symptom-Check';

  @override
  String get sectionVitals => 'Vitaldaten';

  @override
  String get sectionVoiceNotes => 'Sprachnotizen';

  @override
  String get sichereNZahlung => 'Sichere\\nZahlung';

  @override
  String get sofortDokumentieren => 'Sofort dokumentieren';

  @override
  String get sonstige => 'Sonstiges';

  @override
  String get spracheUndMemos => 'Sprache & Memos';

  @override
  String get statistikenAktualisieren => 'Statistiken aktualisieren';

  @override
  String get statsNichtAktualisiert =>
      'Statistiken konnten nicht aktualisiert werden.';

  @override
  String get statusFiltern => 'Filter status';

  @override
  String get stimmung => 'Ø Stimmung';

  @override
  String get sucheInAktionenDetailsUID => 'Suche in Aktionen, Details, UID…';

  @override
  String get sucheNachBetreffEMail => 'Suche nach Betreff, E-Mail…';

  @override
  String get sucheNachTitelOderOrt => 'Nach Titel oder Ort suchen…';

  @override
  String get suchenNameEMailFachrichtung =>
      'Suchen (Name, E-Mail, Fachrichtung)…';

  @override
  String get suchenNameEmailUid => 'Suchen (Name, E-Mail oder UID)…';

  @override
  String get taeglicheChallenges => 'Tägliche Challenges';

  @override
  String get tagEingeben => 'Tag eingeben…';

  @override
  String get tagePostOP => 'Tage post-OP';

  @override
  String get templateFollowupActivitySubtitle =>
      'Aktivität schrittweise steigern – auf den Körper hören';

  @override
  String get templateFollowupActivityTitle => 'Aktivität steigern';

  @override
  String get templateFollowupDay14Subtitle => 'Zweite Fortschrittskontrolle';

  @override
  String get templateFollowupDay21Subtitle => 'Dritte Fortschrittskontrolle';

  @override
  String get templateFollowupDay28Subtitle =>
      'Abschlussuntersuchung und Entlassung';

  @override
  String get templateFollowupDay28Title => 'Abschlusskontrolle';

  @override
  String get templateFollowupDay7Subtitle =>
      'Fortschrittskontrolle in der Praxis';

  @override
  String get templateFollowupDay7Title => 'Nachsorgetermin';

  @override
  String get templateFollowupScarCareSubtitle =>
      'Narbe sanft eincremen und beobachten';

  @override
  String get templateFollowupScarCareTitle => 'Narbenpflege';

  @override
  String get templateFollowupWeeklyCheckSubtitle =>
      'Heilungsfortschritt auswerten und dokumentieren';

  @override
  String get templateFollowupWeeklyCheckTitle => 'Wöchentliche Selbstkontrolle';

  @override
  String get templateFollowupWoundPhotoSubtitle =>
      'Heilungsfortschritt weiter dokumentieren';

  @override
  String get templateFollowupWoundPhotoTitle => 'Wundfoto aufnehmen';

  @override
  String get templateMedsEveningSubtitle => 'Abenddosis wie verordnet';

  @override
  String get templateMedsMiddaySubtitle => 'Mittagsdosis wie verordnet';

  @override
  String get templateMedsMorningSubtitle => 'Morgendosis wie verordnet';

  @override
  String get templateMedsMorningTitle => 'Medikamente nehmen';

  @override
  String get templateOpdayAdmissionSubtitle =>
      'Bitte pünktlich in der Klinik erscheinen';

  @override
  String get templateOpdayAdmissionTitle => 'Aufnahme';

  @override
  String get templateOpdayFastingSubtitle =>
      'Keine Nahrung oder Flüssigkeit wie angewiesen';

  @override
  String get templateOpdayFastingTitle => 'Nüchternheit prüfen';

  @override
  String get templateOpdayInfoSubtitle => 'Offene Fragen mit dem Team klären';

  @override
  String get templateOpdayInfoTitle => 'OP-Infos bestätigen';

  @override
  String get templateOpdayMobilizationSubtitle =>
      'Kurz aufsetzen/aufstehen mit Unterstützung';

  @override
  String get templateOpdayMobilizationTitle => 'Erste Mobilisierung';

  @override
  String get templatePreopBagSubtitle =>
      'Dokumente, Kleidung und Ladekabel einpacken';

  @override
  String get templatePreopBagTitle => 'Koffer packen';

  @override
  String get templatePreopCompanionSubtitle => 'Fahrt und Treffpunkt abstimmen';

  @override
  String get templatePreopCompanionTitle => 'Begleitperson informieren';

  @override
  String get templatePreopDocumentsSubtitle =>
      'Krankenkassenkarte und Befunde vorbereiten';

  @override
  String get templatePreopDocumentsTitle => 'Dokumente prüfen';

  @override
  String get templateWeek1AbdominalSupportSubtitle =>
      'Sitz und Trageweise prüfen';

  @override
  String get templateWeek1AbdominalSupportTitle => 'Bauchgurt prüfen';

  @override
  String get templateWeek1BackPostureSubtitle =>
      'Kein Verdrehen oder Beugen der Wirbelsäule';

  @override
  String get templateWeek1BackPostureTitle => 'Rückenschutzhaltung';

  @override
  String get templateWeek1BloodPressureSubtitle =>
      'Werte morgens und abends dokumentieren';

  @override
  String get templateWeek1BloodPressureTitle => 'Blutdruck messen';

  @override
  String get templateWeek1BowelDiarySubtitle =>
      'Verdauung beobachten – wichtig für den Kostaufbau';

  @override
  String get templateWeek1BowelDiaryTitle => 'Stuhlgang dokumentieren';

  @override
  String get templateWeek1BreathingCardioSubtitle =>
      'Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen';

  @override
  String get templateWeek1BreathingCardioTitle => 'Atemübungen';

  @override
  String get templateWeek1BreathingSpineSubtitle =>
      'Tiefe Atemzüge – Rücken gerade, sanft atmen';

  @override
  String get templateWeek1BreathingSpineTitle => 'Atemübungen';

  @override
  String get templateWeek1CardiacRehabSubtitle =>
      'Leichtes Gehen, Kreislauf langsam aufbauen';

  @override
  String get templateWeek1CardiacRehabTitle => 'Herz-Reha-Übungen';

  @override
  String get templateWeek1CompressionSubtitle =>
      'Sitz und Zustand der Strümpfe prüfen';

  @override
  String get templateWeek1CompressionTitle => 'Kompressionsstrümpfe prüfen';

  @override
  String get templateWeek1DietBuildupSubtitle =>
      'Leichte Kost, Schonkost → schrittweise steigern';

  @override
  String get templateWeek1DietBuildupTitle => 'Kostaufbau';

  @override
  String get templateWeek1DressingSubtitle =>
      'Verbandszustand prüfen und dokumentieren';

  @override
  String get templateWeek1DressingTitle => 'Verbandkontrolle';

  @override
  String get templateWeek1HydrationSubtitle =>
      'Mindestens 1,5 Liter Flüssigkeit pro Tag';

  @override
  String get templateWeek1HydrationTitle => 'Flüssigkeitszufuhr prüfen';

  @override
  String get templateWeek1JointRomSubtitle =>
      'Beugen und Strecken vorsichtig testen';

  @override
  String get templateWeek1JointRomTitle => 'Gelenkbeweglichkeit prüfen';

  @override
  String get templateWeek1LegExercisesSubtitle =>
      'Füße kreisen, Beine anspannen – Thromboseprophylaxe';

  @override
  String get templateWeek1LegExercisesTitle => 'Beinübungen machen';

  @override
  String get templateWeek1MobilizationSubtitle =>
      'Langsam mobilisieren – auch kleine Schritte zählen';

  @override
  String get templateWeek1MobilizationTitle => 'Aufstehen & kurz bewegen';

  @override
  String get templateWeek1NoStrainingSubtitle =>
      'Pressen vermeiden, seitwärts abrollen beim Aufstehen';

  @override
  String get templateWeek1NoStrainingTitle => 'Bauchschutz';

  @override
  String get templateWeek1OrthosisSubtitle => 'Sitz und Tragezeit prüfen';

  @override
  String get templateWeek1OrthosisTitle => 'Orthese/Korsett prüfen';

  @override
  String get templateWeek1PainScoreSubtitle =>
      'Schmerzniveau in der App eingeben';

  @override
  String get templateWeek1PainScoreTitle => 'Schmerzniveau erfassen';

  @override
  String get templateWeek1RedFlagsSubtitle =>
      'Fieber, Rötung, Schwellung, starke Schmerzen?';

  @override
  String get templateWeek1RedFlagsTitle => 'Warnzeichen prüfen';

  @override
  String get templateWeek1SpineStabilizationSubtitle =>
      'Rumpfstabilisierung nach Anweisung – schrittweise steigern';

  @override
  String get templateWeek1SpineStabilizationTitle => 'Stabilisierungsübungen';

  @override
  String get templateWeek1SternumSubtitle =>
      'Nicht über 5 kg heben, Arme körpernah halten';

  @override
  String get templateWeek1SternumTitle => 'Sternumschutz';

  @override
  String get templateWeek1VitalsSubtitle => 'Puls/Temperatur kurz notieren';

  @override
  String get templateWeek1VitalsTitle => 'Vitaldaten prüfen';

  @override
  String get templateWeek1WoundPhotoSubtitle =>
      'Foto zur Fortschrittsverfolgung dokumentieren';

  @override
  String get templateWeek1WoundPhotoTitle => 'Wundfoto aufnehmen';

  @override
  String get templateWeek2CardiacWalkSubtitle =>
      'Gehdistanz schrittweise steigern, Puls beobachten';

  @override
  String get templateWeek2CardiacWalkTitle => 'Herz-Reha-Spaziergang';

  @override
  String get templateWeek2DietNormalizeSubtitle =>
      'Verdauung beobachten – langsam auf Normalkost umstellen';

  @override
  String get templateWeek2DietNormalizeTitle => 'Normale Ernährung aufbauen';

  @override
  String get templateWeek2GaitSubtitle =>
      'Sicheres Gehen mit/ohne Hilfsmittel üben';

  @override
  String get templateWeek2GaitTitle => 'Gangschulung';

  @override
  String get templateWeek2PainSubtitle =>
      'Schmerzverlauf dokumentieren – wird es besser?';

  @override
  String get templateWeek2PainTitle => 'Schmerztagebuch';

  @override
  String get templateWeek2PhysioSubtitle =>
      'Übungen nach Anweisung durchführen';

  @override
  String get templateWeek2PhysioTitle => 'Physiotherapie-Übungen';

  @override
  String get templateWeek2WalkSubtitle =>
      'Täglich etwas weiter gehen – Kreislauf stärken';

  @override
  String get templateWeek2WalkTitle => 'Spazieren gehen';

  @override
  String get templateWeek2WoundObserveSubtitle =>
      'Heilungsverlauf beobachten und dokumentieren';

  @override
  String get templateWeek2WoundObserveTitle => 'Wunde beobachten';

  @override
  String get templateWeek1SymptomCheckSubtitle =>
      'Wie geht es dir heute? Symptome prüfen und dokumentieren';

  @override
  String get templateWeek1SymptomCheckTitle => 'Symptomcheck durchführen';

  @override
  String get termineNaechste14Tage => 'Termine nächste 14 Tage';

  @override
  String get testBenachrichtigungErstellen => 'Testbenachrichtigung erstellen';

  @override
  String get ticketChatNachrichtSchreiben => 'Nachricht schreiben…';

  @override
  String get ticketErstellen => 'Ticket erstellen';

  @override
  String get timelineAddNoteContent => 'Inhalt (optional)';

  @override
  String get timelineAddTaskDescription => 'Beschreibung (optional)';

  @override
  String get timelineAddTaskTitle => 'Titel';

  @override
  String get timelineBesserOrganisieren => 'Timeline besser organisieren';

  @override
  String get timelineDue => 'Fällig';

  @override
  String get timelineFriday => 'Freitag';

  @override
  String get timelineMonday => 'Montag';

  @override
  String get timelineMyPlan => 'Mein Plan';

  @override
  String get timelineNoOpenTasks => 'Heute keine offenen Aufgaben';

  @override
  String get timelinePhaseDefault => 'Phase';

  @override
  String get timelinePhaseFollowup => 'Nachsorge';

  @override
  String get timelinePhaseOpday => 'OP-Tag';

  @override
  String get timelinePhasePersonal => 'Meine Einträge';

  @override
  String get timelinePhasePreop => 'Vorbereitung';

  @override
  String get timelinePhaseWeek1 => 'Woche 1 · Heilung & Überwachung';

  @override
  String get timelinePhaseWeek2 => 'Woche 2 · Aktivierung';

  @override
  String get timelinePlanComplete =>
      'Dein Plan ist aktuell vollständig erledigt';

  @override
  String get timelineRouteAppointment => 'Termin hinzufügen';

  @override
  String get timelineRouteAppointmentDesc =>
      'Erstelle und verwalte deine OP-bezogenen Termine.';

  @override
  String get timelineRouteDocuments => 'Dokumente hochladen';

  @override
  String get timelineRouteMedication => 'Medikamente';

  @override
  String get timelineRouteMoodLog => 'Stimmungstagebuch';

  @override
  String get timelineRouteMoodLogDesc =>
      'Erfasse deine Stimmung und erkenne Muster in deinem emotionalen Wohlbefinden.';

  @override
  String get timelineRouteNoteAdd => 'Notiz erstellen';

  @override
  String get timelineRouteNoteAddDesc =>
      'Halte einen freien Eintrag in deiner Timeline fest.';

  @override
  String get timelineRouteNutrition => 'Ernährungstagebuch';

  @override
  String get timelineRouteNutritionDesc =>
      'Dokumentiere deine Mahlzeiten und erhalte Ernährungsempfehlungen.';

  @override
  String get timelineRoutePainLog => 'Schmerztagebuch';

  @override
  String get timelineRoutePainLogDesc =>
      'Dokumentiere dein Schmerzniveau auf einer Skala von 1–10.';

  @override
  String get timelineRouteQuestions => 'Fragen & Notizen';

  @override
  String get timelineRouteQuestionsDesc =>
      'Behalte den Überblick über Fragen für deinen Operateur und persönliche Notizen.';

  @override
  String get timelineRouteRedFlag => 'Red-Flag Cockpit';

  @override
  String get timelineRouteRedFlagDesc =>
      'Aktive Warnungen und Notfallaktionen prüfen.';

  @override
  String get timelineRouteRehab => 'Reha';

  @override
  String get timelineRouteRehabDesc =>
      'Öffnet die Reha-Übersicht für Übungen und Fortschritt.';

  @override
  String get timelineRouteSleepLog => 'Schlaftagebuch';

  @override
  String get timelineRouteSleepLogDesc =>
      'Dokumentiere deine Schlafdauer und -qualität.';

  @override
  String get timelineRoutesNotizErstellen854 => 'Notiz erstellen';

  @override
  String get timelineRouteSymptomCheck => 'Symptom-Check';

  @override
  String get timelineRouteTaskAdd => 'Aufgabe hinzufügen';

  @override
  String get timelineRouteTaskAddDesc =>
      'Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.';

  @override
  String get timelineRouteTransport => 'Transport';

  @override
  String get timelineRouteTransportDesc =>
      'Plane deine Hin- und Rückfahrt zur Klinik.';

  @override
  String get timelineRouteVitals => 'Vitaldaten';

  @override
  String get timelineRouteWoundDoc => 'Wunddokumentation';

  @override
  String get timelineSaturday => 'Samstag';

  @override
  String get timelineSheetDocUpload => 'Dokument hochladen';

  @override
  String get timelineSheetPainLevel => 'Schmerzniveau';

  @override
  String get timelineSheetWoundPhoto => 'Wundfoto';

  @override
  String get timelineSunday => 'Sonntag';

  @override
  String get timelineThursday => 'Donnerstag';

  @override
  String get timelineToday => 'Heute';

  @override
  String get timelineTomorrow => 'Morgen';

  @override
  String get timelineTransportDriver => 'Fahrer';

  @override
  String get timelineTransportHint =>
      'Plane deine Hin- und Rückfahrt zur Klinik.';

  @override
  String get timelineTransportNotes => 'Notizen';

  @override
  String get timelineTransportOutbound => 'Hinfahrt (Uhrzeit / Treffpunkt)';

  @override
  String get timelineTransportReturn => 'Rückfahrt (Uhrzeit / Treffpunkt)';

  @override
  String get timelineTuesday => 'Dienstag';

  @override
  String get timelineVerknuepfung => 'Timeline-Verknüpfung';

  @override
  String get timelineViewFullPlan => 'Gesamtplan anzeigen';

  @override
  String get timelineWednesday => 'Mittwoch';

  @override
  String get timelineZusammenfassung => 'Timeline Zusammenfassung';

  @override
  String get timerStarten => 'Timer starten';

  @override
  String get titelBeschreibung => 'Titel / Beschreibung';

  @override
  String get transkriptBearbeiten => 'Transkript bearbeiten…';

  @override
  String get uebungSuchen => 'Übung suchen…';

  @override
  String get userSuchen => 'User suchen';

  @override
  String get userUID => 'User UID';

  @override
  String get verbindungFehlgeschlagen =>
      'Verbindung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get verbindungTrennen => 'Verbindung trennen';

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
  String get vorlage => 'Vorlage';

  @override
  String get vorlagenDurchsuchen => 'Vorlagen suchen...';

  @override
  String get wannZumArzt => 'Wann zum Arzt?';

  @override
  String get warnCall112 => '112 anrufen';

  @override
  String get warnCheckLabel => 'Schnellcheck:';

  @override
  String get warnContactClinic => 'Kontaktiere die Klinik bei diesen Zeichen:';

  @override
  String get warnEmergencySubtitle => 'Bei lebensbedrohlichen Symptomen!';

  @override
  String get warnEmergencyTitle => 'Notfall?';

  @override
  String get warnItemBleedingQ1 =>
      'Ist die Blutung aktiv und lässt sich nicht stoppen?';

  @override
  String get warnItemBleedingQ2 =>
      'Ist der Verband schon vollständig durchgeblutet?';

  @override
  String get warnItemBleedingQ3 => 'Fühlst du dich schwindelig oder schwach?';

  @override
  String get warnItemBleedingSubtitle =>
      'Blut sickert schnell durch den Verband';

  @override
  String get warnItemBleedingTitle => 'Starke Blutung';

  @override
  String get warnItemBreathQ1 => 'Tritt die Atemnot in Ruhe auf?';

  @override
  String get warnItemBreathQ2 => 'Wird die Atemnot schlimmer?';

  @override
  String get warnItemBreathQ3 => 'Hast du Schmerzen beim Atmen?';

  @override
  String get warnItemBreathSubtitle => 'Atemnot oder Lufthunger';

  @override
  String get warnItemBreathTitle => 'Atemnot';

  @override
  String get warnItemFeverQ1 => 'Hast du Fieber gemessen?';

  @override
  String get warnItemFeverQ2 => 'Ist die Temperatur über 38,5 °C?';

  @override
  String get warnItemFeverQ3 => 'Hast du Schüttelfrost?';

  @override
  String get warnItemFeverSubtitle => 'Temperatur über 38,5 °C';

  @override
  String get warnItemFeverTitle => 'Hohes Fieber';

  @override
  String get warnItemPainQ1 => 'Sind die Schmerzen deutlich stärker als sonst?';

  @override
  String get warnItemPainQ2 =>
      'Helfen deine üblichen Schmerzmittel nicht mehr?';

  @override
  String get warnItemPainQ3 =>
      'Ist die schmerzende Stelle geschwollen oder heiß?';

  @override
  String get warnItemPainSubtitle =>
      'Plötzlich zunehmend, nicht kontrollierbar';

  @override
  String get warnItemPainTitle => 'Starke Schmerzen';

  @override
  String get warnItemRednessQ1 => 'Breitet sich die Rötung aus?';

  @override
  String get warnItemRednessQ2 => 'Ist die Stelle warm oder heiß?';

  @override
  String get warnItemRednessQ3 => 'Gibt es Eiter oder Absonderungen?';

  @override
  String get warnItemRednessSubtitle => 'Wundbereich erscheint entzündet';

  @override
  String get warnItemRednessTitle => 'Zunehmende Rötung / Schwellung';

  @override
  String get warnItemSmellQ1 => 'Hat das Sekret eine ungewöhnliche Farbe?';

  @override
  String get warnItemSmellQ2 => 'Riecht die Wunde deutlich unangenehm?';

  @override
  String get warnItemSmellQ3 => 'Hat sich die Sekretmenge erhöht?';

  @override
  String get warnItemSmellSubtitle => 'Ungewöhnliches Sekret aus der Wunde';

  @override
  String get warnItemSmellTitle => 'Übelriechendes Sekret';

  @override
  String get warnSaveCheck => 'Prüfung speichern';

  @override
  String get warnTitle => 'Warnzeichen';

  @override
  String get warnzeichenStatus => 'Warnzeichen Status';

  @override
  String get wartungsmodusDeaktivieren => 'Wartungsmodus deaktivieren';

  @override
  String get wasBeschaeftigtDich => 'Was beschäftigt dich gerade?';

  @override
  String get wasBeschreibtDeineStimmung => 'Was beschreibt deine Stimmung?';

  @override
  String get wasHastDuBeobachtet => 'Was hast du beobachtet?';

  @override
  String get weekdayShortFri => 'Fr';

  @override
  String get weekdayShortMon => 'Mo';

  @override
  String get weekdayShortSat => 'Sa';

  @override
  String get weekdayShortSun => 'So';

  @override
  String get weekdayShortThu => 'Do';

  @override
  String get weekdayShortTue => 'Di';

  @override
  String get weekdayShortWed => 'Mi';

  @override
  String get weiterDokumentieren => 'Weiter dokumentieren';

  @override
  String get weiterenPatientenHinzufuegen => 'Weiteren Patienten hinzufügen';

  @override
  String get werbungUndDatenschutz => 'Werbung & Datenschutz';

  @override
  String get wieGehtEsDir => 'Wie geht es dir?';

  @override
  String get woche1 => 'Woche 1';

  @override
  String get wochentage => 'Wochentage';

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
  String get zbBefund => 'z.B. Befund';

  @override
  String get zbDieBlaue => 'z. B. Die blaue, nicht die rote';

  @override
  String get zbNachDemEssen => 'z. B. mit Wasser nach dem Essen einnehmen';

  @override
  String get zBRehaBadNauheim => 'z.B. Reha Bad Nauheim';

  @override
  String get zBRehaKlinikMustermann => 'z. B. Reha-Klinik Mustermann';

  @override
  String get zbUpdateWirdEingespielt => 'z.B. Update wird eingespielt…';

  @override
  String get zeitfilterZuruecksetzen => 'Zeitfilter zurücksetzen';

  @override
  String get zeitraumFiltern => 'Zeitraum filtern';

  @override
  String get zuDenEinstellungen => 'Zu den Einstellungen';

  @override
  String get zurueckZurTimeline => 'Zurück zur Timeline';

  @override
  String anfrageAblehnenBestaetigung(String name) {
    return 'Möchtest du die Anfrage von $name ablehnen?';
  }

  @override
  String apptCalendarDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Termine',
      one: '$count Termin',
    );
    return '$_temp0';
  }

  @override
  String apptCreatedBy(String name) {
    return 'Erstellt von $name';
  }

  @override
  String apptDeleteContent(String title) {
    return 'Möchtest du \"$title\" wirklich dauerhaft löschen?';
  }

  @override
  String apptReminderMinutes(int minutes) {
    return '$minutes Min. vorher';
  }

  @override
  String apptRepeatUntilDate(String date) {
    return '(bis $date)';
  }

  @override
  String aufgabenAuswaehlenCount(int selected, int total) {
    return 'Aufgaben auswählen ($selected/$total):';
  }

  @override
  String aufgabenCount(int count) {
    return 'Aufgaben ($count)';
  }

  @override
  String aufgabenCountSelected(int count, String suffix) {
    return '$count Aufgabe$suffix ausgewählt';
  }

  @override
  String bellaActionStatusCancelled(String label) {
    return '$label — abgebrochen';
  }

  @override
  String bellaActionStatusCreated(String label) {
    return '$label — erstellt';
  }

  @override
  String bellaActionStatusFailed(String label) {
    return '$label — fehlgeschlagen';
  }

  @override
  String bellaBriefingHttpError(int statusCode) {
    return 'Fehler beim Erstellen des Briefings (HTTP $statusCode).';
  }

  @override
  String bellaDailyUsage(int used, int limit) {
    return '$used / $limit Nachrichten heute';
  }

  @override
  String bellaProactiveDocGap(int days) {
    return 'Du hast $days Tage lang nichts eingetragen';
  }

  @override
  String bellaProactiveMedReminder(String name) {
    return 'Hast du heute dein $name eingenommen?';
  }

  @override
  String bellaProactiveMedReminderMultiple(int count) {
    return 'Hast du heute deine Medikamente eingenommen? ($count ausstehend)';
  }

  @override
  String bellaProactiveOpenTasks(int count) {
    return 'Du hast noch $count offene Aufgaben für heute';
  }

  @override
  String bellaProactiveStreakAtRisk(int streak) {
    return 'Dein $streak-Tage-Streak ist in Gefahr!';
  }

  @override
  String benachrichtigungenCountNeu(int count) {
    return 'Benachrichtigungen ($count neu)';
  }

  @override
  String caregiverEntfernt(String name) {
    return '$name wurde entfernt';
  }

  @override
  String cloneErstellt(String name) {
    return '\"$name\" erstellt';
  }

  @override
  String doctorEntfernt(String name) {
    return '$name wurde entfernt';
  }

  @override
  String doctorHinzugefuegt(String name) {
    return '$name wurde hinzugefügt';
  }

  @override
  String dokumentGeloescht(String title) {
    return '„$title“ gelöscht';
  }

  @override
  String erstelltVon(String name) {
    return 'Created by: $name';
  }

  @override
  String fehlerMitError(String error) {
    return 'Fehler: $error';
  }

  @override
  String gueltigFuerTage(int days) {
    return 'Gültig für $days Tage';
  }

  @override
  String keysErstellt(int count) {
    return '$count Keys erstellt';
  }

  @override
  String medikamentEntfernt(String name) {
    return '$name entfernt';
  }

  @override
  String medikamentWiederhergestellt(String name) {
    return '$name wiederhergestellt';
  }

  @override
  String medikamentWirdEntfernt(String name) {
    return '$name wird entfernt.';
  }

  @override
  String mitarbeiterAction(String action) {
    return 'Mitarbeiter $action';
  }

  @override
  String mitarbeiterEntfernt(String name) {
    return '$name wurde entfernt';
  }

  @override
  String nameWurdeEntsperrt(String name) {
    return '$name wurde entsperrt.';
  }

  @override
  String nameWurdeGeloescht(String name) {
    return '$name wurde gelöscht.';
  }

  @override
  String nameWurdeGesperrt(String name) {
    return '$name wurde gesperrt.';
  }

  @override
  String neuesPasswortFuer(String name) {
    return 'Neues Passwort für $name';
  }

  @override
  String noSearchResults(String query) {
    return 'Keine Ergebnisse für „$query\"';
  }

  @override
  String notizLoeschenBestaetigung(String title) {
    return '„$title“ wirklich löschen?';
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
    return '$count aktiv';
  }

  @override
  String rfActiveCount(int count) {
    return 'Aktiv ($count)';
  }

  @override
  String rfLevelBadge(String level) {
    return 'Level: $level';
  }

  @override
  String rfResolvedCount(int count) {
    return 'Verlauf ($count)';
  }

  @override
  String rolleGeaendert(String role) {
    return 'Rolle geändert zu „$role\".';
  }

  @override
  String statusMitLabel(String label) {
    return 'Status: $label';
  }

  @override
  String tageVergeben(int days) {
    return '$days Tage gewährt';
  }

  @override
  String ticketsCountOffen(int count) {
    return 'Tickets ($count open)';
  }

  @override
  String timelineDoneOfTotal(int done, int total) {
    return '$done/$total erledigt';
  }

  @override
  String timelineDueAttention(int count) {
    return '$count heute zu erledigen';
  }

  @override
  String timelineNextUp(String title) {
    return 'Weiter: $title';
  }

  @override
  String timelinePhaseProgress(int done, int total) {
    return '$done/$total erledigt';
  }

  @override
  String timelineProgressPercent(int percent) {
    return '$percent% erledigt – weiter so!';
  }

  @override
  String timelineStickyDoneOfTotal(int done, int total) {
    return '$done von $total erledigt';
  }

  @override
  String timelineStickyDue(int count) {
    return '$count fällig';
  }

  @override
  String timelineStickyToday(int count) {
    return '$count heute';
  }

  @override
  String timelineStreakDays(int count) {
    return '$count Tage';
  }

  @override
  String timelineTasksPlanned(int count) {
    return '$count Aufgaben für heute geplant';
  }

  @override
  String unwiderruflichLoeschen(String title) {
    return '„$title“ wird dauerhaft gelöscht.';
  }

  @override
  String userAktionFehler(String action) {
    return 'Nutzer konnte nicht ${action}t werden.';
  }

  @override
  String vorlageErstellt(String name) {
    return 'Vorlage „$name\" erstellt';
  }

  @override
  String vorlageLoeschenBestaetigung(String name) {
    return 'Möchtest du \"$name\" wirklich löschen?';
  }

  @override
  String vorlageUebernommen(String name) {
    return '„$name\" in eigene Vorlagen kopiert';
  }

  @override
  String warnLastCheck(String label, String date) {
    return 'Letzter Check: $label · $date';
  }

  @override
  String warnzeichenGespeichert(String level) {
    return 'Warnzeichen-Check gespeichert ($level)';
  }

  @override
  String get accountUndRechtliches => 'Account & Rechtliches';

  @override
  String get actionCall112 => '112 anrufen';

  @override
  String get actionUnlock => 'Entsperren';

  @override
  String get aktiveWarnungenUndNotfallaktionenPruefen =>
      'Aktive Warnungen und Notfallaktionen prüfen.';

  @override
  String get alertNotruf112 => 'Notruf 112';

  @override
  String get alleAbwaehlen => 'Alle abwählen';

  @override
  String get alleAuswaehlen => 'Alle auswählen';

  @override
  String get alleKategorienErledigt => 'Alle Kategorien erledigt!';

  @override
  String get alleTermineImBlick => 'Alle Termine im Blick';

  @override
  String get allesErledigt => 'Alles erledigt!';

  @override
  String get analyticsNutrition => 'Ernährung';

  @override
  String get analyticsOverview => 'Übersicht';

  @override
  String get analyticsPain => 'Schmerzen';

  @override
  String get analyticsVitals => 'Vitaldaten';

  @override
  String get analyticsWounds => 'Wunden';

  @override
  String get apptAllDay => 'Ganztägig';

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
  String get ausZwischenNablageEinfuegen => 'Aus Zwischenablage einfügen';

  @override
  String get authServiceGoogleSignInWasCancelledByTheUser =>
      'Der Google-Anmeldevorgang wurde abgebrochen.';

  @override
  String get badgeMedicationHero => 'Medikamenten-Held';

  @override
  String get badgeMedicationHeroDesc => '7 Tage ohne vergessene Dosis';

  @override
  String get badgeMoodTrackerDesc => 'Stimmung 20 Mal dokumentiert';

  @override
  String get badgePainTracker => 'Schmerz-Tracker';

  @override
  String get badgePainTrackerDesc => 'Schmerzen 20 Mal dokumentiert';

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
      'Bevor ich loslegen kann, brauche ich kurz deine Einwilligung';

  @override
  String get bevorstehendeArztUndKliniktermine =>
      'Bevorstehende Arzt- und Kliniktermine';

  @override
  String get bildAuswaehlen => 'Bild auswählen';

  @override
  String get bitteGibEinenKeyEin => 'Bitte gib einen Key ein.';

  @override
  String get blutwerteAbgegeben => 'Blutwerte abgegeben';

  @override
  String caregiverRemoved(String name) {
    return '$name wurde entfernt';
  }

  @override
  String get challengeGeschafft => 'Challenge geschafft!';

  @override
  String get checklisteFuerDieKlinik => 'Checkliste für die Klinik';

  @override
  String get cpAbdominalBelt => 'Bauchgurt/Stütze prüfen';

  @override
  String get cpAbdominalBeltDesc => 'Sitz und Trageweise prüfen';

  @override
  String get cpAbdominalProtection => 'Bauchmuskelschutz';

  @override
  String get cpAbdominalProtectionDesc =>
      'Nicht pressen, beim Aufstehen zur Seite rollen';

  @override
  String get cpAdmission => 'Aufnahme';

  @override
  String get cpAdmissionDesc => 'Bitte pünktlich in der Klinik melden';

  @override
  String get cpBandageCheck => 'Verband kontrollieren';

  @override
  String get cpBandageCheckDesc => 'Verbandszustand prüfen und dokumentieren';

  @override
  String get cpBreathingExercises => 'Atemübungen';

  @override
  String get cpBreathingExercisesHeartDesc =>
      'Tiefe Atemzüge zur Lungenpflege – besonders wichtig nach Herzoperationen';

  @override
  String get cpBreathingExercisesSpineDesc =>
      'Tiefe Atemzüge – Rücken gerade, sanft atmen';

  @override
  String get cpCardiacRehabExercises => 'Herzreha-Übungen';

  @override
  String get cpCardiacRehabExercisesDesc =>
      'Leichtes Gehen, Kreislauf langsam aufbauen';

  @override
  String get cpCardiacRehabWalk => 'Herzreha-Spaziergang';

  @override
  String get cpCardiacRehabWalkDesc =>
      'Gehstrecke langsam steigern, Puls beobachten';

  @override
  String get cpCheckDocuments => 'Dokumente prüfen';

  @override
  String get cpCheckDocumentsDesc =>
      'Krankenkassenkarte und Unterlagen vorbereiten';

  @override
  String get cpCheckFasting => 'Nüchternheit prüfen';

  @override
  String get cpCheckFastingDesc =>
      'Keine Nahrung oder Flüssigkeit wie angewiesen';

  @override
  String get cpCheckFluidIntake => 'Flüssigkeitszufuhr prüfen';

  @override
  String get cpCheckFluidIntakeDesc =>
      'Mindestens 1,5 Liter Flüssigkeit täglich';

  @override
  String get cpCheckOrthosis => 'Orthese/Korsett prüfen';

  @override
  String get cpCheckOrthosisDesc => 'Sitz und Tragezeit prüfen';

  @override
  String get cpCheckVitals => 'Vitalzeichen prüfen';

  @override
  String get cpCheckVitalsDesc => 'Puls/Temperatur kurz notieren';

  @override
  String get cpCheckWarnings => 'Warnzeichen prüfen';

  @override
  String get cpCheckWarningsDesc =>
      'Fieber, Rötung, Schwellung, starke Schmerzen?';

  @override
  String get cpCompressionStockings => 'Kompressionsstrümpfe prüfen';

  @override
  String get cpCompressionStockingsDesc =>
      'Sitz und Zustand der Strümpfe prüfen';

  @override
  String get cpConfirmOpInfo => 'OP-Informationen bestätigen';

  @override
  String get cpConfirmOpInfoDesc => 'Offene Fragen mit dem Team klären';

  @override
  String get cpDietProgression => 'Kostaufbau';

  @override
  String get cpDietProgressionDesc =>
      'Leichte Kost, Schonkost → langsam steigern';

  @override
  String get cpDocumentBowel => 'Stuhlgang dokumentieren';

  @override
  String get cpDocumentBowelDesc =>
      'Verdauung beobachten – wichtig für den Kostaufbau';

  @override
  String get cpEveningDose => 'Abenddosis wie vorgeschrieben';

  @override
  String get cpFinalCheck => 'Abschlusskontrolle';

  @override
  String get cpFinalCheckDesc => 'Abschlussuntersuchung und Entlassung';

  @override
  String get cpFirstMobilisation => 'Erste Mobilisation';

  @override
  String get cpFirstMobilisationDesc =>
      'Kurz aufsetzen/aufstehen mit Unterstützung';

  @override
  String get cpFollowUpAppointment => 'Nachsorgetermin';

  @override
  String get cpFollowUpDesc1 => 'Fortschrittskontrolle in der Klinik';

  @override
  String get cpFollowUpDesc2 => 'Zweite Fortschrittskontrolle';

  @override
  String get cpFollowUpDesc3 => 'Dritte Fortschrittskontrolle';

  @override
  String get cpGaitTraining => 'Gangschulung';

  @override
  String get cpGaitTrainingDesc => 'Sicheres Gehen mit/ohne Hilfsmittel üben';

  @override
  String get cpGoForWalk => 'Spazieren gehen';

  @override
  String get cpGoForWalkDesc =>
      'Jeden Tag etwas weiter laufen – Kreislauf stärken';

  @override
  String get cpIncreaseActivity => 'Aktivität steigern';

  @override
  String get cpIncreaseActivityDesc =>
      'Aktivität langsam steigern – auf Körpersignale achten';

  @override
  String get cpInformCompanion => 'Begleitperson informieren';

  @override
  String get cpInformCompanionDesc => 'Fahrt und Treffpunkt abstimmen';

  @override
  String get cpLegExercises => 'Beinübungen durchführen';

  @override
  String get cpLegExercisesDesc =>
      'Füße kreisen, Beine anspannen – Thromboseprophylaxe';

  @override
  String get cpMorningDose => 'Morgendosis wie vorgeschrieben';

  @override
  String get cpNoonDose => 'Mittagsdosis wie vorgeschrieben';

  @override
  String get cpNormalDietProgression => 'Normale Ernährung aufbauen';

  @override
  String get cpNormalDietProgressionDesc =>
      'Verdauung beobachten – schrittweise zur normalen Ernährung';

  @override
  String get cpObserveWound => 'Wunde beobachten';

  @override
  String get cpObserveWoundDesc =>
      'Heilungsverlauf beobachten und dokumentieren';

  @override
  String get cpPackHospitalBag => 'Kliniktasche packen';

  @override
  String get cpPackHospitalBagDesc =>
      'Dokumente, Kleidung und Ladekabel einpacken';

  @override
  String get cpPainDiary => 'Schmerztagebuch';

  @override
  String get cpPainDiaryDesc =>
      'Schmerzverlauf dokumentieren – bessert es sich?';

  @override
  String get cpPhysioExercises => 'Physiotherapie-Übungen';

  @override
  String get cpPhysioExercisesDesc => 'Übungen wie angewiesen durchführen';

  @override
  String get cpRecordPainLevel => 'Schmerzniveau erfassen';

  @override
  String get cpRecordPainLevelDesc => 'Schmerzniveau in der App eingeben';

  @override
  String get cpScarCare => 'Narbenpflege';

  @override
  String get cpScarCareDesc => 'Narbe sanft eincremen und beobachten';

  @override
  String get cpSpineProtection => 'Rückenschutzhaltung';

  @override
  String get cpSpineProtectionDesc =>
      'Kein Verdrehen oder Beugen der Wirbelsäule';

  @override
  String get cpStabilisationExercises => 'Stabilisationsübungen';

  @override
  String get cpStabilisationExercisesDesc =>
      'Rumpfstabilisation wie angewiesen – schrittweise steigern';

  @override
  String get cpSternumProtection => 'Sternumschutz';

  @override
  String get cpSternumProtectionDesc =>
      'Kein Heben über 5 kg, Arme nah am Körper halten';

  @override
  String get cpTakeMedication => 'Medikamente einnehmen';

  @override
  String get cpTakeWoundPhoto => 'Wundfoto aufnehmen';

  @override
  String get cpTakeWoundPhotoDesc =>
      'Foto zur Fortschrittsverfolgung dokumentieren';

  @override
  String get cpTakeWoundPhotoProgress => 'Wundfoto aufnehmen';

  @override
  String get cpTakeWoundPhotoProgressDesc =>
      'Heilungsfortschritt weiter dokumentieren';

  @override
  String get cpWeeklySelfCheck => 'Wöchentliche Selbstkontrolle';

  @override
  String get cpWeeklySelfCheckDesc =>
      'Heilungsfortschritt auswerten und dokumentieren';

  @override
  String get dasRehaSystemMitTimerIstGoldWert =>
      'Das Reha-System mit Timer ist Gold wert.';

  @override
  String get datenEingeben => 'Daten eingeben';

  @override
  String debugEmail(String email) {
    return 'E-Mail: $email';
  }

  @override
  String get debugLinkedPatients => 'Verknüpfte Patienten';

  @override
  String get debugNotAvailable => 'nicht verfügbar';

  @override
  String get debugNotLoggedIn => 'nicht angemeldet';

  @override
  String get debugOnlyForAdmins => 'Nur für Admins verfügbar.';

  @override
  String get debugOnlyInDebug => 'Nur in Debug-Builds verfügbar.';

  @override
  String debugRole(String role) {
    return 'Rolle: $role';
  }

  @override
  String debugUid(String uid) {
    return 'UID: $uid';
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
  String get einnahmeDokumentieren => 'Einnahme dokumentieren';

  @override
  String get empty7DaysNoData => '7 Tage: keine Daten';

  @override
  String get emptyNoMacros => 'Keine Makros erfasst';

  @override
  String get emptyNoNotifications => 'Keine Benachrichtigungen';

  @override
  String get emptyNoRedFlags => 'Keine offenen Red Flags';

  @override
  String get emptyNoVitals => 'Noch keine Vitaldaten erfasst';

  @override
  String get emptyNoVitalsShort => 'Noch keine Vitaldaten';

  @override
  String get emptyTasksInPlan => 'Noch keine Aufgaben im Plan.';

  @override
  String get emptyTodayNoEntries => 'Heute: keine Einträge';

  @override
  String get erinnerungenAnMedikamenteneinnahme =>
      'Erinnerungen an Medikamenteneinnahme';

  @override
  String get erstelle => 'Erstelle…';

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
  String get fehlerBeimSpeichernErneut =>
      'Fehler beim Speichern. Bitte erneut versuchen.';

  @override
  String fehlerGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String fehlerMitDetails(String error) {
    return 'Fehler: $error';
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
      'Der Google-Anmeldevorgang wurde abgebrochen.';

  @override
  String get habenSieAtembeschwerdenOderKurzatmigkeit =>
      'Haben Sie Atembeschwerden oder Kurzatmigkeit?';

  @override
  String get halteEinenFreienEintragInDeinerTimelineFest =>
      'Halte einen freien Eintrag in deiner Timeline fest.';

  @override
  String get hintDescribeInDetail =>
      'Beschreibe dein Anliegen so genau wie möglich…';

  @override
  String get hintShortDescription => 'Kurze Beschreibung deines Anliegens';

  @override
  String get ichWarNervoesVorDerOPDieRedFlagWarnung =>
      'Ich war nervös vor der OP. Die Red-Flag Warnung';

  @override
  String itemDeletedMessage(String title) {
    return '„$title“ gelöscht';
  }

  @override
  String itemDeletedPermanently(String title) {
    return '„$title“ wird dauerhaft gelöscht.';
  }

  @override
  String get keyNichtGefunden => 'Key nicht gefunden.';

  @override
  String get knieTEP58Jahre => 'Knie-TEP, 58 Jahre';

  @override
  String get kritischerSymptomCheck => 'Kritischer Symptom-Check';

  @override
  String get labelCategory => 'Kategorie';

  @override
  String get labelContentOptional => 'Inhalt (optional)';

  @override
  String get labelCustomMinutes => 'Eigene Minuten';

  @override
  String get labelDescriptionOptional => 'Beschreibung (optional)';

  @override
  String get labelInviteCode => 'Einladungscode';

  @override
  String labelInviteCodeValue(String code) {
    return 'Code: $code';
  }

  @override
  String get labelLinkType => 'Link-Typ';

  @override
  String get labelLocation => 'Ort';

  @override
  String get labelLocationDetails => 'Ortsdetails';

  @override
  String get labelNote => 'Notiz';

  @override
  String get labelObservation => 'Beobachtung';

  @override
  String get labelReminder => 'Erinnerung';

  @override
  String get labelSubject => 'Betreff';

  @override
  String get labelTitle => 'Titel';

  @override
  String get labelTitleRequired => 'Titel *';

  @override
  String get labelType => 'Typ';

  @override
  String get mahlzeitenUndEmpfehlungen => 'Mahlzeiten & Empfehlungen';

  @override
  String get measurementSaved => 'Messung gespeichert';

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
      'Nach meiner Knie-OP hatte ich hundert Fragen.';

  @override
  String get nachrichtNsenden => 'Nachricht\nsenden';

  @override
  String get notifChannelAppointments =>
      'Erinnerungen für bevorstehende Termine';

  @override
  String get notifChannelMedication => 'Medikamentenerinnerung';

  @override
  String get notifChannelMedicationDesc =>
      'Tägliche Erinnerungen für Medikamente';

  @override
  String get notifChannelVitals => 'Vitaldaten-Erinnerung';

  @override
  String get notifChannelVitalsDesc =>
      'Tägliche Erinnerung für Vitaldatenmessungen';

  @override
  String notifDoctorAnswered(String name) {
    return 'Dr. $name hat deine Frage beantwortet';
  }

  @override
  String get notifMeasureVitals => 'Vitaldaten messen';

  @override
  String notifObservationFrom(String name) {
    return 'Beobachtung von $name';
  }

  @override
  String get notifWoundAlarm => 'Wund-Alarm';

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
  String get patientNhinzufuegen => 'Patient\nhinzufügen';

  @override
  String get planeHinUndRueckfahrtZurKlinik =>
      'Plane Hin- und Rückfahrt zur Klinik.';

  @override
  String get proActiveSubtitle => 'Alle Funktionen freigeschaltet';

  @override
  String get proActiveTitle => 'Pro aktiv';

  @override
  String get proEntziehen => 'Pro entziehen';

  @override
  String get proGeben => 'Pro vergeben';

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
  String get speichere => 'Speichere…';

  @override
  String get speichert => 'Speichert…';

  @override
  String get streakGerettet => 'Streak gerettet!';

  @override
  String get symptomCheckServiceNotruf112 => 'Notruf 112';

  @override
  String get symptomU2011Check => 'Symptom‑Check';

  @override
  String systemVorlageFehler(String error) {
    return 'Fehler: $error';
  }

  @override
  String get timelineRoutesAufgabeHinzufuegen => 'Aufgabe hinzufügen';

  @override
  String get timelineRoutesNotizErstellen => 'Notiz erstellen';

  @override
  String get timelineTransportTitle => 'Transportplanung';

  @override
  String get trittMeinemOperationsbegleiterBeiNN =>
      'Tritt meinem Operationsbegleiter bei!\n\n';

  @override
  String get uebungenTimerUndFortschritt => 'Übungen, Timer & Fortschritt';

  @override
  String get updatesProStatusUndAppHinweise =>
      'Updates, Pro-Status & App-Hinweise';

  @override
  String userBlocked(String name) {
    return '$name wurde gesperrt.';
  }

  @override
  String userDeleted(String name) {
    return '$name wurde gelöscht.';
  }

  @override
  String userGesperrtEntsperrt(String action) {
    return 'Nutzer $action.';
  }

  @override
  String userUnblocked(String name) {
    return '$name wurde entsperrt.';
  }

  @override
  String get vitalsNotizOptional => 'Notiz (optional)';

  @override
  String get vorWaehrendUndNachDerOP => 'Vor, während & nach der OP';

  @override
  String get vorlageErzeugen => 'Vorlage erstellen';

  @override
  String warningCheckSaved(String level) {
    return 'Warnüberprüfung gespeichert ($level)';
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
  String get wirdZugewiesen => 'Wird zugewiesen…';

  @override
  String get wunddokumentation => 'Wunddokumentation';

  @override
  String get wundenDokumentieren => 'Wunden dokumentieren';

  @override
  String get zusammenfassungFuerDenArzt => 'Zusammenfassung für den Arzt';

  @override
  String get rtsTitle => 'Sportfreigabe-Test';

  @override
  String get rtsNewAssessment => 'Neuen Test starten';

  @override
  String get rtsLatestResult => 'Letztes Ergebnis';

  @override
  String get rtsHistory => 'Testverlauf';

  @override
  String get rtsScore => 'Gesamtscore';

  @override
  String get rtsCleared => 'Freigegeben ✓';

  @override
  String get rtsAlmostReady => 'Fast bereit';

  @override
  String get rtsNotReady => 'Noch nicht bereit';

  @override
  String get rtsClearedMessage =>
      'Dein Score liegt über dem Schwellenwert. Du kannst mit sportlicher Belastung beginnen – spreche vorher noch einmal mit deinem Arzt.';

  @override
  String get rtsAlmostReadyMessage =>
      'Du bist auf einem guten Weg. Setze dein Training fort und wiederhole den Test in ein paar Wochen.';

  @override
  String get rtsNotReadyMessage =>
      'Dein Körper braucht noch etwas Zeit. Konzentriere dich auf Rehabilitation und Kräftigung, bevor du wieder Sport treibst.';

  @override
  String get rtsEmptyTitle => 'Bist du bereit für Sport?';

  @override
  String get rtsEmptySubtitle =>
      'Starte deinen ersten Fitness-Test. Statt starrer Zeitvorgaben misst du Kraft, Balance und Stabilität – und siehst anhand eines Scores, ob du wieder Sport treiben kannst.';

  @override
  String get rtsAssessmentTitle => 'Fitness-Test';

  @override
  String get rtsResultTitle => 'Testergebnis';

  @override
  String get rtsBreakdown => 'Einzelergebnisse';

  @override
  String get rtsFinishAssessment => 'Auswerten';

  @override
  String get rtsDeleteTitle => 'Test löschen';

  @override
  String get rtsDeleteConfirm =>
      'Dieses Testergebnis wird unwiderruflich gelöscht.';

  @override
  String get rtsValidationHint => 'Bitte fülle alle Pflichtfelder aus.';

  @override
  String get rtsNotesLabel => 'Notiz (optional)';

  @override
  String get rtsNotesHint => 'z. B. Tagesform, Bedingungen …';

  @override
  String rtsStepOf(String current, String total) {
    return 'Schritt $current/$total';
  }

  @override
  String get rtsTestLsiTitle => 'Kraftseitenvergleich (LSI)';

  @override
  String get rtsTestLsiDesc =>
      'Vergleiche die Leistung der betroffenen Seite mit der gesunden Seite – z.B. Haltezeit beim Einbeinstand oder Wiederholungen einer einbeinigen Übung.';

  @override
  String get rtsTestLsiHint =>
      'Führe dieselbe Übung auf beiden Seiten durch und trage die Werte ein. Ein LSI ≥ 90 % gilt als optimale Freigabeschwelle.';

  @override
  String get rtsLsiSeconds => 'Sekunden';

  @override
  String get rtsLsiReps => 'Wiederholungen';

  @override
  String rtsLsiAffected(String unit) {
    return 'Betroffene Seite ($unit)';
  }

  @override
  String rtsLsiHealthy(String unit) {
    return 'Gesunde Seite ($unit)';
  }

  @override
  String rtsLsiDetailValue(
    String affected,
    String healthy,
    String unit,
    String percent,
  ) {
    return 'Betroffen: $affected $unit / Gesund: $healthy $unit → LSI: $percent';
  }

  @override
  String get rtsTestBalanceTitle => 'Einbeinstand-Balance';

  @override
  String get rtsTestBalanceDesc =>
      'Stehe auf dem betroffenen Bein und halte die Balance so lang wie möglich. Miss die Zeit in Sekunden.';

  @override
  String get rtsTestBalanceHint =>
      'Führe den Test auf einer stabilen, flachen Fläche durch. 30 Sekunden entsprechen einem vollen Score.';

  @override
  String get rtsBalanceSeconds => 'Haltezeit (Sekunden)';

  @override
  String rtsBalanceDetailValue(String seconds) {
    return '$seconds Sekunden';
  }

  @override
  String get rtsTestStabilityTitle => 'Stabilität (Einbeinige Kniebeuge)';

  @override
  String get rtsTestStabilityDesc =>
      'Wie gut kannst du eine kontrollierte einbeinige Kniebeuge auf dem betroffenen Bein durchführen?';

  @override
  String get rtsStability1 =>
      '1 – Gar nicht möglich, starke Schmerzen oder fehlende Kontrolle.';

  @override
  String get rtsStability2 =>
      '2 – Ansatzweise möglich, aber mit deutlichen Einschränkungen.';

  @override
  String get rtsStability3 =>
      '3 – Möglich mit spürbaren Kompensationen oder leichten Schmerzen.';

  @override
  String get rtsStability4 => '4 – Fast problemlos, minimale Unsicherheit.';

  @override
  String get rtsStability5 => '5 – Vollständig kontrolliert und schmerzfrei.';

  @override
  String rtsStabilityDetailValue(String rating) {
    return 'Selbstbewertung: $rating / 5';
  }

  @override
  String get rtsTestPainTitle => 'Schmerzfreiheit bei Belastung';

  @override
  String get rtsTestPainDesc =>
      'Wie stark sind deine Schmerzen bei sportspezifischer Belastung (z. B. Laufen, Springen, Richtungswechsel)? Bewerte auf einer Skala von 0–10.';

  @override
  String get rtsPainNoKein => '0 – Kein Schmerz';

  @override
  String get rtsPainSevere => '10 – Stärkster Schmerz';

  @override
  String rtsPainDetailValue(String level) {
    return 'NRS: $level / 10';
  }

  @override
  String get rtsSportTypeTitle => 'Sportart';

  @override
  String get rtsSportTypeDesc => 'Welchen Sport möchtest du wieder ausüben?';

  @override
  String get rtsSportRunning => 'Laufen';

  @override
  String get rtsSportSoccer => 'Fußball / Teamsport';

  @override
  String get rtsSportStrength => 'Kraftsport';

  @override
  String get rtsSportCycling => 'Radfahren';

  @override
  String get rtsSportSwimming => 'Schwimmen';

  @override
  String get rtsSportMartialArts => 'Kampfsport';

  @override
  String get rtsSportOther => 'Sonstige';

  @override
  String get rtsTestHopTitle => 'Sprungkraft-Seitenvergleich (Hop-Test)';

  @override
  String get rtsTestHopDesc =>
      'Springe auf dem betroffenen Bein so weit wie möglich vorwärts und messe die Weite. Wiederhole den Test auf der gesunden Seite.';

  @override
  String get rtsTestHopHint =>
      'Führe 3 Versuche durch und nimm die beste Weite. Ein LSI ≥ 90 % gilt als optimale Freigabeschwelle.';

  @override
  String get rtsHopAffected => 'Betroffene Seite (cm)';

  @override
  String get rtsHopHealthy => 'Gesunde Seite (cm)';

  @override
  String rtsHopDetailValue(String affected, String healthy, String percent) {
    return 'Betroffen: $affected cm / Gesund: $healthy cm → LSI: $percent';
  }

  @override
  String get rtsTestTugTitle => 'Timed Up and Go (TUG)';

  @override
  String get rtsTestTugDesc =>
      'Stehe von einem Stuhl auf, gehe 3 Meter geradeaus, kehre um und setze dich wieder. Miss die Gesamtzeit.';

  @override
  String get rtsTestTugHint =>
      'Verwende den Stoppuhr-Button oder trage die Zeit manuell ein. Unter 10 Sekunden gilt als sehr gut.';

  @override
  String rtsTugDetailValue(String seconds) {
    return '$seconds Sekunden';
  }

  @override
  String get rtsTimerStart => 'Stoppuhr starten';

  @override
  String get rtsTimerStop => 'Stopp';

  @override
  String get rtsTimerReset => 'Zurücksetzen';

  @override
  String get rtsTimerRestart => 'Neu starten';

  @override
  String get rtsTimerOrManual => 'Oder manuell eingeben:';

  @override
  String get rtsTimerManualLabel => 'Zeit in Sekunden';

  @override
  String get rtsScoreTrend => 'Score-Verlauf';

  @override
  String get supplementAddNew => 'Supplement hinzufügen';

  @override
  String get supplementEdit => 'Supplement bearbeiten';

  @override
  String get supplementName => 'Name';

  @override
  String get supplementBrand => 'Marke (optional)';

  @override
  String get supplementDose => 'Dosis (z.B. 1000 IE)';

  @override
  String get supplementCategoryLabel => 'Kategorie';

  @override
  String get supplementCategoryVitamine => 'Vitamine';

  @override
  String get supplementCategoryMineralien => 'Mineralien';

  @override
  String get supplementCategoryAminosaeuren => 'Aminosäuren';

  @override
  String get supplementCategoryKraeuter => 'Kräuter & Pflanzen';

  @override
  String get supplementCategoryProbiotika => 'Probiotika';

  @override
  String get supplementCategoryFettsaeuren => 'Fettsäuren';

  @override
  String get supplementCategoryProteine => 'Proteine';

  @override
  String get supplementCategorySonstiges => 'Sonstiges';

  @override
  String get supplementTimeSlots => 'Einnahmezeiten';

  @override
  String get supplementSave => 'Speichern';

  @override
  String get supplementTabToday => 'Heute';

  @override
  String get supplementTabMine => 'Meine';

  @override
  String get supplementTabRecommendations => 'Empfehlungen';

  @override
  String get supplementTodayProgress => 'Heutige Einnahme';

  @override
  String get supplementTodayHistory => 'Heutige Einnahmen';

  @override
  String get supplementLogSuccess => 'Einnahme gespeichert ✓';

  @override
  String get supplementLogManual => 'Manuell eintragen';

  @override
  String get supplementStockLow => 'Vorrat niedrig';

  @override
  String get supplementStockEmpty => 'Vorrat aufgebraucht';

  @override
  String get supplementEmptyState =>
      'Noch keine Supplemente angelegt.\nTippe + um loszulegen.';

  @override
  String get supplementDeleteTitle => 'Supplement löschen?';

  @override
  String get supplementDeleteBody =>
      'Möchtest du dieses Supplement wirklich löschen?';

  @override
  String get supplementDoseGuidance => 'Dosierungsempfehlung';

  @override
  String get supplementNoRecommendations => 'Keine Empfehlungen verfügbar';

  @override
  String get tabOverview => 'Übersicht';

  @override
  String get tabDoctors => 'Ärzte';

  @override
  String get tabTeam => 'Team';

  @override
  String get tabPatients => 'Patienten';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabCalendar => 'Kalender';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabReport => 'Report';

  @override
  String get tabWound => 'Wunde';

  @override
  String get tabPain => 'Schmerz';

  @override
  String get tabDocuments => 'Dokumente';

  @override
  String get tabMedications => 'Medikamente';

  @override
  String get tabQuestions => 'Fragen';

  @override
  String get tabNotes => 'Notizen';

  @override
  String get tabObservations => 'Beobachtungen';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingDay => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get today => 'Heute';

  @override
  String get profil => 'Profil';

  @override
  String get patienten => 'Patienten';

  @override
  String get weekdayMonday => 'Montag';

  @override
  String get weekdayTuesday => 'Dienstag';

  @override
  String get weekdayWednesday => 'Mittwoch';

  @override
  String get weekdayThursday => 'Donnerstag';

  @override
  String get weekdayFriday => 'Freitag';

  @override
  String get weekdaySaturday => 'Samstag';

  @override
  String get weekdaySunday => 'Sonntag';

  @override
  String get weekdayShortMo => 'Mo';

  @override
  String get weekdayShortTu => 'Di';

  @override
  String get weekdayShortWe => 'Mi';

  @override
  String get weekdayShortTh => 'Do';

  @override
  String get weekdayShortFr => 'Fr';

  @override
  String get weekdayShortSa => 'Sa';

  @override
  String get weekdayShortSu => 'So';

  @override
  String get phasePreOp => 'Prä-OP';

  @override
  String get phaseOpDay => 'OP-Tag';

  @override
  String get phasePostOp => 'Post-OP';

  @override
  String get phaseDischarged => 'Entlassen';

  @override
  String get phaseDistribution => 'Phasenverteilung';

  @override
  String get statusActive => 'Aktiv';

  @override
  String get statusDeactivated => 'Deaktiviert';

  @override
  String get notProvided => 'Nicht hinterlegt';

  @override
  String get fieldType => 'Typ';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldNotes => 'Notizen';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldDescriptionOptional => 'Beschreibung (optional)';

  @override
  String get sorting => 'Sortierung';

  @override
  String get sortName => 'Name';

  @override
  String get sortOpDate => 'OP-Datum';

  @override
  String get sortLastEntry => 'Letzter Eintrag';

  @override
  String get sortSeverity => 'Schweregrad';

  @override
  String get totalPatients => 'Gesamtpatienten';

  @override
  String get activePatients => 'Aktive Patienten';

  @override
  String get openRedFlags => 'Offene Red Flags';

  @override
  String get compliance => 'Compliance';

  @override
  String get total => 'Gesamt';

  @override
  String countActive(int count) {
    return '$count aktiv';
  }

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get templates => 'Vorlagen';

  @override
  String get monthlyReport => 'Monatsbericht';

  @override
  String get myPatients => 'Meine Patienten';

  @override
  String get patientStatus => 'Patienten-Status';

  @override
  String get allPatientsGreen => 'Alle Patienten im grünen Bereich';

  @override
  String get attentionRequired => 'Aufmerksamkeit erforderlich';

  @override
  String get noAppointmentsToday => 'Keine Termine heute – freier Tag!';

  @override
  String appointmentsCount(int count) {
    return '$count Termine';
  }

  @override
  String showAllAppointments(int count) {
    return 'Alle $count Termine anzeigen →';
  }

  @override
  String practiceOf(String name) {
    return 'Praxis von $name';
  }

  @override
  String get searchPatient => 'Patient suchen …';

  @override
  String get noPatientsFound => 'Keine Patienten gefunden.';

  @override
  String get noPatientsLinked => 'Keine Patienten verknüpft.';

  @override
  String get noPatientsLinkedYet => 'Noch keine Patienten verknüpft';

  @override
  String get noPatientsInCategory => 'Keine Patienten in dieser Kategorie';

  @override
  String patientsCountLabel(int count) {
    return 'Patienten ($count)';
  }

  @override
  String get selectPatientForDetails =>
      'Patient auswählen, um Details anzuzeigen';

  @override
  String opDatePrefix(String date) {
    return 'OP: $date';
  }

  @override
  String countSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get proActive => 'Pro aktiv';

  @override
  String get validUntil => 'Gültig bis';

  @override
  String get source => 'Quelle';

  @override
  String get proKey => 'Pro-Key';

  @override
  String get appStoreName => 'App Store';

  @override
  String get googlePlayName => 'Google Play';

  @override
  String get subscription => 'Abo';

  @override
  String get freeTier => 'Free';

  @override
  String get upgradeNow => 'Jetzt upgraden';

  @override
  String get redeemKey => 'Key einlösen';

  @override
  String get praxisPro => 'Praxis Pro';

  @override
  String get praxisProSubtitle => 'Unbegrenzte Patienten & mehr';

  @override
  String get upgradeNowArrow => 'Jetzt upgraden →';

  @override
  String get sectionContactData => 'Kontaktdaten';

  @override
  String get sectionDoctors => 'Ärzte';

  @override
  String get sectionTeam => 'Team';

  @override
  String get sectionPatients => 'Patienten';

  @override
  String get orgProfileNotFound => 'Organisationsprofil nicht gefunden.';

  @override
  String get verified => 'Verifiziert';

  @override
  String get verificationPending => 'Prüfung ausstehend';

  @override
  String get practiceInformation => 'Praxisinformationen';

  @override
  String get openingHours => 'Öffnungszeiten';

  @override
  String get specialties => 'Spezialgebiete';

  @override
  String get professionalDetails => 'Berufliche Angaben';

  @override
  String get approbation => 'Approbation';

  @override
  String get kvNumber => 'KV-Nummer';

  @override
  String get practiceName => 'Praxisname';

  @override
  String get yourProfile => 'Dein Profil';

  @override
  String get accountAndSupport => 'Konto & Support';

  @override
  String get profileImageUploadError =>
      'Profilbild konnte nicht hochgeladen werden.';

  @override
  String doctorsCountLabel(int count) {
    return 'Ärzte ($count)';
  }

  @override
  String get selectDoctorForDetails => 'Arzt auswählen, um Details anzuzeigen';

  @override
  String get errorLoadingDoctors => 'Fehler beim Laden der Ärzte.';

  @override
  String get errorLoading => 'Fehler beim Laden.';

  @override
  String get errorLoadingPatients =>
      'Patientenliste konnte nicht geladen werden.';

  @override
  String get errorLoadingStaff => 'Fehler beim Laden der Mitarbeiter.';

  @override
  String joinedOn(String date) {
    return 'Beigetreten am $date';
  }

  @override
  String get inviteCode => 'Einladungscode';

  @override
  String get inviteCodeDescription =>
      'Teilen Sie diesen Code mit verifizierten Ärzten, die Ihrer Organisation beitreten möchten.';

  @override
  String get inviteCodeLoadError => 'Code konnte nicht geladen werden.';

  @override
  String joinRequestsCountLabel(int count) {
    return 'Beitrittsanfragen ($count)';
  }

  @override
  String timeAgoMinutes(int count) {
    return 'vor $count Min.';
  }

  @override
  String timeAgoHours(int count) {
    return 'vor $count Std.';
  }

  @override
  String timeAgoDays(int count) {
    return 'vor $count Tagen';
  }

  @override
  String get noDoctorsYet => 'Noch keine Ärzte';

  @override
  String get addDoctorsToOrg =>
      'Fügen Sie Ärzte hinzu, um Ihre Organisation aufzubauen.';

  @override
  String get createNewDoctor => 'Neuen Arzt anlegen';

  @override
  String get createDoctor => 'Arzt erstellen';

  @override
  String get creating => 'Wird erstellt…';

  @override
  String get validationRequired => 'Pflichtfeld';

  @override
  String get validationInvalidEmail => 'Ungültige E-Mail';

  @override
  String get validationMinChars8 => 'Mindestens 8 Zeichen.';

  @override
  String confirmAddDoctorToOrg(String name) {
    return 'Möchten Sie $name wirklich Ihrer Organisation hinzufügen?';
  }

  @override
  String confirmRemoveDoctorFromOrg(String name) {
    return 'Möchten Sie $name wirklich aus der Organisation entfernen? Der Arzt wird unabhängig und behält seinen Account.';
  }

  @override
  String confirmActivateStaff(String name) {
    return 'Möchten Sie $name wieder aktivieren? Der Login wird wieder möglich.';
  }

  @override
  String confirmDeactivateStaff(String name) {
    return 'Möchten Sie $name deaktivieren? Der Login wird gesperrt.';
  }

  @override
  String staffActivated(String name) {
    return '$name wurde aktiviert';
  }

  @override
  String staffDeactivated(String name) {
    return '$name wurde deaktiviert';
  }

  @override
  String confirmRemoveStaff(String name) {
    return 'Möchten Sie $name wirklich entfernen? Der Zugang wird sofort widerrufen und der Account deaktiviert.';
  }

  @override
  String get actionActivate => 'aktivieren';

  @override
  String get actionDeactivate => 'deaktivieren';

  @override
  String staffCountLabel(int count) {
    return 'Mitarbeitende ($count)';
  }

  @override
  String get noStaffYet => 'Noch keine Mitarbeitenden';

  @override
  String get createStaffHint =>
      'Erstellen Sie Mitarbeiter-Accounts für Ihr Team.';

  @override
  String get createStaffTeamHint =>
      'Erstellen Sie Accounts für Ihr Praxisteam,\num gemeinsam Patienten zu betreuen.';

  @override
  String get permissionRead => 'Lesen';

  @override
  String get permissionWrite => 'Schreiben';

  @override
  String get caregiverNoLinkedPatient =>
      'Noch kein Patient verknüpft.\nBitte lasse dich über einen Einladungscode verbinden.';

  @override
  String get observationLabel => 'Beobachtung';

  @override
  String confirmDisconnectPatient(String name) {
    return 'Möchten Sie die Verbindung zu $name wirklich trennen?';
  }

  @override
  String taskForPatient(String name) {
    return 'Aufgabe für $name';
  }

  @override
  String selectTemplateForPatient(String name) {
    return 'Wählen Sie eine Vorlage für $name:';
  }

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get selectStartDateHint => 'Startdatum wählen (z.B. OP-Datum)';

  @override
  String get assigning => 'Wird zugewiesen…';

  @override
  String recurrenceDaily(int count) {
    return 'Täglich, ${count}x';
  }

  @override
  String recurrenceWeekdays(int count) {
    return 'Werktags, ${count}x';
  }

  @override
  String recurrenceEveryNDays(int days, int count) {
    return 'Alle $days Tage, ${count}x';
  }

  @override
  String patientsMarkedRead(int count) {
    return '$count Patienten als gelesen markiert';
  }

  @override
  String groupMessageToPatients(int count) {
    return 'Gruppennachricht an $count Patienten';
  }

  @override
  String get hintEnterMessage => 'Nachricht eingeben …';

  @override
  String messageSentToPatients(int count) {
    return 'Nachricht an $count Patienten gesendet';
  }

  @override
  String pdfReportCreating(int count) {
    return 'PDF-Bericht für $count Patienten wird erstellt …';
  }

  @override
  String get groupMessage => 'Gruppennachricht';

  @override
  String get pdfReport => 'PDF-Bericht';

  @override
  String get calendarDay => 'Tag';

  @override
  String get specialtyGeneralSurgery => 'Allgemeinchirurgie';

  @override
  String get specialtyOrthopedics => 'Orthopädie & Unfallchirurgie';

  @override
  String get specialtyVisceralSurgery => 'Viszeralchirurgie';

  @override
  String get specialtyCardiacSurgery => 'Herzchirurgie';

  @override
  String get specialtyNeurosurgery => 'Neurochirurgie';

  @override
  String get specialtyVascularSurgery => 'Gefäßchirurgie';

  @override
  String get specialtyPlasticSurgery => 'Plastische Chirurgie';

  @override
  String get specialtyUrology => 'Urologie';

  @override
  String get specialtyGynecology => 'Gynäkologie';

  @override
  String get specialtyEnt => 'HNO';

  @override
  String get specialtyOphthalmology => 'Augenheilkunde';

  @override
  String get specialtyInternalMedicine => 'Innere Medizin';

  @override
  String get specialtyAnesthesiology => 'Anästhesiologie';

  @override
  String get specialtyOther => 'Sonstige';

  @override
  String get passwordMin8Chars => 'Mindestens 8 Zeichen.';

  @override
  String staffConfirmActivateBody(String name) {
    return 'Möchten Sie $name wieder aktivieren? Der Login wird wieder möglich.';
  }

  @override
  String staffConfirmDeactivateBody(String name) {
    return 'Möchten Sie $name deaktivieren? Der Login wird gesperrt.';
  }

  @override
  String staffWasActivated(String name) {
    return '$name wurde aktiviert';
  }

  @override
  String staffWasDeactivated(String name) {
    return '$name wurde deaktiviert';
  }

  @override
  String staffRemoveConfirmBody(String name) {
    return 'Möchten Sie $name wirklich entfernen? Der Zugang wird sofort widerrufen und der Account deaktiviert.';
  }

  @override
  String get teamHeader => 'Team';

  @override
  String get staffLoadError => 'Fehler beim Laden der Mitarbeiter.';

  @override
  String get statusDisabled => 'Deaktiviert';

  @override
  String get noStaffYetTitle => 'Noch keine Mitarbeiter';

  @override
  String get noStaffYetSubtitle =>
      'Erstellen Sie Mitarbeiter-Accounts für Ihr Team.';

  @override
  String nSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get patientListLoadError =>
      'Patientenliste konnte nicht geladen werden.';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByOpDate => 'OP-Datum';

  @override
  String get sortByLastEntry => 'Letzter Eintrag';

  @override
  String get sortBySeverity => 'Schweregrad';

  @override
  String get title => 'Titel';

  @override
  String get enterMessage => 'Nachricht eingeben …';

  @override
  String staffActivateConfirmBody(String name) {
    return 'Möchten Sie $name wieder aktivieren? Der Login wird wieder möglich.';
  }

  @override
  String staffDeactivateConfirmBody(String name) {
    return 'Möchten Sie $name deaktivieren? Der Login wird gesperrt.';
  }

  @override
  String staffPermissionsSummary(int readCount, int writeCount) {
    return '$readCount Lesen · $writeCount Schreiben';
  }

  @override
  String get pdTabReport => 'Report';

  @override
  String get pdTabRedFlags => 'Red Flags';

  @override
  String get pdTabWound => 'Wunde';

  @override
  String get pdTabPain => 'Schmerz';

  @override
  String get pdTabDocuments => 'Dokumente';

  @override
  String get pdTabMedication => 'Medikamente';

  @override
  String get pdTabQuestions => 'Fragen';

  @override
  String get pdTabNotes => 'Notizen';

  @override
  String get phaseEntlassen => 'Entlassen';

  @override
  String disconnectConfirmBody(String name) {
    return 'Möchten Sie die Verbindung zu $name wirklich trennen?';
  }

  @override
  String terminFuerPatient(String name) {
    return 'Termin für $name';
  }

  @override
  String aufgabeFuerPatient(String name) {
    return 'Aufgabe für $name';
  }

  @override
  String get startdatumWaehlen => 'Startdatum wählen (z. B. OP-Datum)';

  @override
  String vorlageFuerPatient(String name) {
    return 'Wählen Sie eine Vorlage für $name:';
  }

  @override
  String templateAppliedCount(String name, int count, String suffix) {
    return '$name: $count Aufgabe$suffix zugewiesen';
  }

  @override
  String nAufgabenColon(int count, String suffix) {
    return '$count Aufgabe$suffix:';
  }

  @override
  String nAufgaben(int count, String suffix) {
    return '$count Aufgabe$suffix';
  }

  @override
  String get vorlageErstellen => 'Vorlage erstellen';

  @override
  String get doctorProfileNotSpecified => 'Nicht hinterlegt';

  @override
  String get doctorProfilePracticeInfo => 'Praxisinformationen';

  @override
  String get doctorProfileWebsite => 'Website';

  @override
  String get doctorProfileOpeningHours => 'Öffnungszeiten';

  @override
  String get doctorProfileSpecialties => 'Spezialgebiete';

  @override
  String get doctorProfileProfessionalInfo => 'Berufliche Angaben';

  @override
  String get doctorProfileApprobation => 'Approbation';

  @override
  String get doctorProfileKvNumber => 'KV-Nummer';

  @override
  String get doctorProfilePracticeName => 'Praxisname';

  @override
  String get doctorProfileStaffMember => 'Mitarbeiter/in';

  @override
  String get doctorProfileAccountSupport => 'Konto & Support';

  @override
  String get doctorProfileImageUploadError =>
      'Profilbild konnte nicht hochgeladen werden.';

  @override
  String get doctorProfileYourProfile => 'Dein Profil';

  @override
  String get doctorProfileVerified => 'Verifiziert';

  @override
  String get doctorProfileVerificationPending => 'Prüfung ausstehend';

  @override
  String get doctorProfileClosed => 'Geschlossen';

  @override
  String get doctorProfileNoSpecialties => 'Keine Spezialgebiete hinterlegt';

  @override
  String get doctorProfileNewSpecialtyHint => 'Neues Spezialgebiet…';

  @override
  String get patientSuchen => 'Patient suchen…';

  @override
  String get fehlerBeimLaden => 'Fehler beim Laden.';

  @override
  String get keinePatienenGefunden => 'Keine Patienten gefunden.';

  @override
  String patientenAnzahl(int count) {
    return 'Patienten ($count)';
  }

  @override
  String get patientAuswaehlenUmDetailsAnzuzeigen =>
      'Patient auswählen, um Details anzuzeigen';

  @override
  String opDatumKurz(int day, int month, int year) {
    return 'OP: $day.$month.$year';
  }

  @override
  String appointmentCount(int count) {
    return '$count Termine';
  }

  @override
  String get noAppointmentsFreeDay => 'Keine Termine – freier Tag!';

  @override
  String showAllAppointmentsCount(int count) {
    return 'Alle $count Termine anzeigen';
  }

  @override
  String get totalLabel => 'Gesamt';

  @override
  String get broadcastSend => 'Senden';

  @override
  String broadcastSentCount(int count) {
    return 'Broadcast an $count Patienten gesendet';
  }

  @override
  String get broadcastToAllPatients => 'Broadcast an alle Patienten';

  @override
  String broadcastWillBeSentTo(int count) {
    return 'Wird an $count Patienten gesendet';
  }

  @override
  String get sending => 'Sende…';

  @override
  String appointmentDeleteMessage(String title, String patient) {
    return 'Möchten Sie den Termin \"$title\" für $patient wirklich löschen?';
  }

  @override
  String eventDeleteMessage(String title) {
    return 'Möchten Sie den Termin \"$title\" wirklich löschen?';
  }

  @override
  String get appointmentEdit => 'Termin bearbeiten';

  @override
  String get notes => 'Notizen';

  @override
  String get type => 'Typ';

  @override
  String get saving => 'Speichern…';

  @override
  String get practiceAppointmentCreate => 'Praxis-Termin erstellen';

  @override
  String get practiceAppointmentEdit => 'Praxis-Termin bearbeiten';

  @override
  String get nochKeinePatientenInDerOrganisation =>
      'Noch keine Patienten in der Organisation.';

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
      'Ich helfe dir bei der Verwaltung deiner Organisation, Ärzten, Mitarbeitern und Statistiken.';

  @override
  String get bellaSubtitleOrganisation => 'Dein Organisations-Assistent 🐰';

  @override
  String get bellaFeatureBilling => 'Abrechnung';

  @override
  String get bellaFeatureDoctors => 'Ärzte';

  @override
  String get bellaFeatureOrgStats => 'Statistiken';

  @override
  String get bellaFeatureTeam => 'Team';

  @override
  String get bellaChipDoctorBroadcast => 'Nachricht an alle Patienten senden';

  @override
  String get bellaChipDoctorCreateAppointment => 'Termin für Patient erstellen';

  @override
  String get bellaChipDoctorInvitePatient => 'Neuen Patienten einladen';

  @override
  String get bellaChipManageDoctors => 'Wie verwalte ich meine Ärzte?';

  @override
  String get bellaChipOrgBillingInfo => 'Wie ist unser Abonnement-Status?';

  @override
  String get bellaChipOrgDashboard => 'Zeig mir unsere Organisations-Übersicht';

  @override
  String get bellaChipOrgInviteDoctor => 'Einen neuen Arzt einladen';

  @override
  String get bellaChipOrgStats => 'Zeig mir unsere Statistiken';

  @override
  String get bellaChipStaffCreateAppointment => 'Termin für Patient erstellen';
}
