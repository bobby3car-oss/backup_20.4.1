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
  String get agbTermsLink => 'Условия использования';

  @override
  String get agbAndConnector => ' и ';

  @override
  String get agbPrivacyLink => 'Политику конфиденциальности';

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

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingGetStarted => 'Начнём';

  @override
  String get onboardingSlide1Title => 'Ваш цифровой\nпомощник по операции';

  @override
  String get onboardingSlide1Subtitle =>
      'Вся информация о вашей операции –\nбезопасно и удобно в одном месте.';

  @override
  String get onboardingSlide1Feature1 => 'Пошаговое сопровождение';

  @override
  String get onboardingSlide1Feature2 => 'Разработано для пациентов';

  @override
  String get onboardingSlide1Feature3 => 'Всё в одном месте';

  @override
  String get onboardingSlide2Title => 'Ваша операция\nв обзоре';

  @override
  String get onboardingSlide2Subtitle =>
      'От подготовки до реабилитации –\nвсё чётко спланировано.';

  @override
  String get onboardingSlide2Feature1 => 'Чек-лист подготовки';

  @override
  String get onboardingSlide2Feature2 => 'Список вещей для клиники';

  @override
  String get onboardingSlide2Feature3 => 'Все приёмы под контролем';

  @override
  String get onboardingSlide3Title => 'Отслеживайте\nздоровье';

  @override
  String get onboardingSlide3Subtitle =>
      'Следите за показателями здоровья\nи симптомами в любое время.';

  @override
  String get onboardingSlide3Feature1 => 'Показатели и пульс';

  @override
  String get onboardingSlide3Feature2 => 'Дневник боли';

  @override
  String get onboardingSlide3Feature3 => 'Проверка симптомов';

  @override
  String get onboardingSlide4Title => 'Заживление\nран';

  @override
  String get onboardingSlide4Subtitle =>
      'Документируйте процесс заживления\nс помощью фото и сравнений.';

  @override
  String get onboardingSlide4Feature1 => 'Фотодокументация';

  @override
  String get onboardingSlide4Feature2 => 'Функция сравнения';

  @override
  String get onboardingSlide4Feature3 => 'Умные подсказки';

  @override
  String get onboardingSlide5Title => 'На связи с\nвашей командой';

  @override
  String get onboardingSlide5Subtitle =>
      'Подключайте близких и делитесь\nважной информацией с врачом.';

  @override
  String get onboardingSlide5Feature1 => 'Пригласить близких';

  @override
  String get onboardingSlide5Feature2 => 'Делиться отчётами';

  @override
  String get onboardingSlide5Feature3 => 'Прямое общение';

  @override
  String get authSlideTitle => 'Готовы начать?';

  @override
  String get authSlideSubtitle =>
      'Создайте аккаунт или войдите,\nчтобы начать сопровождение операции.';

  @override
  String get authSlideRegister => 'Зарегистрироваться';

  @override
  String get authSlideLogin => 'Войти';

  @override
  String get authSlideDoctorRegister => 'Регистрация врача';

  @override
  String get authSlideGuestMode => 'Попробовать без аккаунта';

  @override
  String get loginWelcomeBack => 'С возвращением';

  @override
  String get loginSubtitle => 'Войдите в свой аккаунт.';

  @override
  String get loginPasswordResetSent =>
      'Если аккаунт существует, письмо отправлено.';

  @override
  String get loginEnterEmailFirst => 'Сначала введите вашу почту.';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginQuickLogin => 'Быстрый вход';

  @override
  String get loginQuickLoginHint => 'Доступно после первого входа';

  @override
  String get doctorRegTitle => 'Регистрация врача';

  @override
  String get doctorRegRoleBadge => 'Доступ для врачей';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'После регистрации наша команда проверит ваши данные.';

  @override
  String get doctorRegPersonalData => 'Личные данные';

  @override
  String get doctorRegNameHint => 'Д-р Иван Иванов';

  @override
  String get doctorRegServiceEmail => 'Рабочая почта';

  @override
  String get doctorRegEmailHint => 'doctor@clinic.ru';

  @override
  String get doctorRegEmailRequired => 'Введите почту';

  @override
  String get doctorRegEmailInvalid => 'Введите корректную почту';

  @override
  String get doctorRegPasswordMin8 => 'Минимум 8 символов';

  @override
  String get doctorRegProfessionalData => 'Профессиональные данные';

  @override
  String get doctorRegSpecialty => 'Специальность';

  @override
  String get doctorRegSelectSpecialty => 'Выберите специальность';

  @override
  String get doctorRegSpecialtyRequired => 'Пожалуйста, выберите специальность';

  @override
  String get doctorRegApprobation => 'Номер лицензии';

  @override
  String get doctorRegApprobationHint => 'Ваш номер лицензии';

  @override
  String get doctorRegApprobationRequired => 'Введите номер лицензии';

  @override
  String get doctorRegPractice => 'Практика / Клиника';

  @override
  String get doctorRegPracticeHint => 'Название практики или клиники';

  @override
  String get doctorRegPracticeRequired => 'Введите название';

  @override
  String get doctorRegKvNumber => 'Страховой номер (необязательно)';

  @override
  String get doctorRegKvHint => 'Если есть';

  @override
  String get doctorRegSubmitting => 'Отправка…';

  @override
  String get doctorRegSubmit => 'Запросить доступ';

  @override
  String get doctorRegDisclaimer =>
      'Ваши данные обрабатываются конфиденциально и используются только для верификации.';

  @override
  String get medicalDisclaimer =>
      'Это приложение не является медицинским изделием и не заменяет лечение у врача.';
}
