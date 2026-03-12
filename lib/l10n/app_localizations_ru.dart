// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Операционный помощник';

  @override
  String get languageLabel => 'Язык';

  @override
  String get languageName => 'Русский';

  @override
  String get languageChangeTitle => 'Выбрать язык';

  @override
  String get tabStart => 'Сегодня';

  @override
  String get tabAppointments => 'Записи';

  @override
  String get tabDocuments => 'Документы';

  @override
  String get tabMore => 'Ещё';

  @override
  String get login => 'Вход';

  @override
  String get loginAction => 'Войти';

  @override
  String get loginLoading => 'Вход…';

  @override
  String loginFailed(String error) {
    return 'Ошибка входа: $error';
  }

  @override
  String loginAppleFailed(String error) {
    return 'Ошибка входа через Apple: $error';
  }

  @override
  String loginGoogleFailed(String error) {
    return 'Ошибка входа через Google: $error';
  }

  @override
  String get loginWithApple => 'Войти через Apple';

  @override
  String get loginWithGoogle => 'Войти через Google';

  @override
  String get or => 'или';

  @override
  String get noAccountYet => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get signupTitle => 'Регистрация';

  @override
  String get createAccountTitle => 'Создать\nаккаунт';

  @override
  String get createAccountSubtitle => 'Заполните поля, чтобы начать.';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get creatingAccount => 'Создание аккаунта…';

  @override
  String get fieldName => 'Имя';

  @override
  String get fieldFullName => 'Полное имя';

  @override
  String get fieldEmail => 'Электронная почта';

  @override
  String get fieldPassword => 'Пароль';

  @override
  String get fieldConfirmPassword => 'Подтвердите пароль';

  @override
  String get fieldRepeatPassword => 'Повторите пароль';

  @override
  String get fieldBirthDate => 'Дата рождения';

  @override
  String get fieldBirthDateHint => 'ДД.ММ.ГГГГ';

  @override
  String get fieldBirthDatePicker => 'Выберите дату рождения';

  @override
  String get validationNameRequired => 'Введите имя';

  @override
  String get validationEmailInvalid => 'Введите действительный email';

  @override
  String get validationBirthDateRequired => 'Выберите дату рождения';

  @override
  String get validationPasswordMin6 => 'Минимум 6 символов';

  @override
  String get validationRepeatPassword => 'Повторите пароль';

  @override
  String get validationPasswordsMismatch => 'Пароли не совпадают';

  @override
  String get validationPasswordsMismatchLegacy => 'Пароли не совпадают.';

  @override
  String get errorEmailInUse => 'Этот email уже используется.';

  @override
  String get errorInvalidEmail => 'Недействительный email адрес.';

  @override
  String get errorWeakPassword => 'Пароль слишком слабый.';

  @override
  String errorRegistrationFailed(String error) {
    return 'Ошибка регистрации: $error';
  }

  @override
  String get agbAcceptPrefix => 'Я принимаю ';

  @override
  String get agbAcceptLink => 'Условия и Политику конфиденциальности';

  @override
  String get datePickerCancel => 'Отмена';

  @override
  String get datePickerConfirm => 'Подтвердить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsNotAvailable => 'Недоступно';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsPush => 'Push';

  @override
  String get settingsEmailNotif => 'Электронная почта';

  @override
  String get settingsPlaceholder => 'Скоро будет доступно';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsExportData => 'Экспорт данных';

  @override
  String get settingsExportPlaceholder => 'Экспорт скоро будет доступен';

  @override
  String get settingsExportSnack => 'Экспорт будет добавлен позже';

  @override
  String get settingsResetData => 'Сбросить данные';

  @override
  String get settingsResetPlaceholder => 'Сброс скоро будет доступен';

  @override
  String get settingsResetSnack => 'Сброс будет добавлен позже';

  @override
  String get settingsPro => 'Pro';

  @override
  String get settingsProStatus => 'Pro Статус';

  @override
  String get settingsProSubtitle => 'Подписка и восстановление';

  @override
  String get settingsLegal => 'Правовая информация';

  @override
  String get settingsImprint => 'Выходные данные';

  @override
  String get settingsPrivacy => 'Конфиденциальность';

  @override
  String get settingsTerms => 'Условия';

  @override
  String get settingsTermsPlaceholder => 'Условия скоро будут добавлены';

  @override
  String get settingsTermsSnack => 'Условия будут добавлены позже';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String commonError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get commonInProgress => 'В разработке';

  @override
  String get commonUnnamed => 'Без имени';

  @override
  String get commonPatients => 'Пациенты';

  @override
  String get commonNoPatientsYet => 'Пациентов пока нет. Нажмите +';

  @override
  String commonPatientOpened(String name) {
    return 'Пациент открыт: $name';
  }

  @override
  String get connectivityOfflineBanner =>
      'Вы не в сети. Изменения будут синхронизированы, как только вы снова подключитесь.';

  @override
  String get connectivityRequiredTitle => 'Нет подключения к интернету';

  @override
  String get connectivityRequiredMessage =>
      'Для этой функции требуется подключение к интернету. Пожалуйста, подключитесь и повторите попытку.';

  @override
  String get staffTeam => 'TODO:ru: Team';

  @override
  String get staffInvite => 'TODO:ru: Einladen';

  @override
  String get staffInviteTitle => 'TODO:ru: Mitarbeiter einladen';

  @override
  String get staffInviteSubtitle =>
      'TODO:ru: Teilen Sie diesen Code mit Ihrem/Ihrer Mitarbeiter/in';

  @override
  String get staffInviteValid => 'TODO:ru: Gültig für 7 Tage';

  @override
  String get staffInviteCopy => 'TODO:ru: Kopieren';

  @override
  String get staffInviteShare => 'TODO:ru: Teilen';

  @override
  String get staffInviteCodeLabel => 'TODO:ru: Einladungscode';

  @override
  String get staffAcceptTitle => 'TODO:ru: Mitarbeiter-Einladung';

  @override
  String get staffAcceptCodeHint => 'TODO:ru: CODE EINGEBEN';

  @override
  String get staffAcceptSubmit => 'TODO:ru: Code einlösen';

  @override
  String get staffAcceptSuccess => 'TODO:ru: Willkommen im Team!';

  @override
  String get staffAcceptSuccessBody =>
      'TODO:ru: Sie sind jetzt als Mitarbeiter/in registriert.\nStarten Sie die App neu, um das Dashboard zu sehen.';

  @override
  String get staffAcceptDone => 'TODO:ru: Fertig';

  @override
  String get staffRevokedTitle => 'TODO:ru: Zugang widerrufen';

  @override
  String get staffRevokedBody =>
      'TODO:ru: Ihr Mitarbeiter-Zugang wurde deaktiviert. Bitte wenden Sie sich an Ihren Arzt.';

  @override
  String get staffPermissionsTitle => 'TODO:ru: Berechtigungen';

  @override
  String get staffPermissionsSave => 'TODO:ru: Speichern';

  @override
  String get staffRemoveTitle => 'TODO:ru: Mitarbeiter entfernen';

  @override
  String get staffRemoveConfirm => 'TODO:ru: Wirklich entfernen?';

  @override
  String get staffRemoveAction => 'TODO:ru: Entfernen';

  @override
  String get staffEmptyTitle => 'TODO:ru: Noch kein Team';

  @override
  String get staffEmptySubtitle =>
      'TODO:ru: Laden Sie Ihre Mitarbeitenden ein, um Ihr Praxis-Dashboard zu teilen.';

  @override
  String get staffRole => 'TODO:ru: Mitarbeiter/in';

  @override
  String get staffPractice => 'TODO:ru: Praxis';

  @override
  String get staffMyPermissions => 'TODO:ru: Meine Berechtigungen';

  @override
  String get staffAccessNone => 'TODO:ru: Kein Zugriff';

  @override
  String get staffAccessRead => 'TODO:ru: Lesen';

  @override
  String get staffAccessReadWrite => 'TODO:ru: Lesen & Schreiben';

  @override
  String get staffPendingInvites => 'TODO:ru: Offene Einladungen';
}
