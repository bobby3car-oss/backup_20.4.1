// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get tabStart => 'Главная';

  @override
  String get tabAppointments => 'Записи';

  @override
  String get tabMore => 'Ещё';

  @override
  String get commonBack => 'ОК';

  @override
  String get or => 'или';

  @override
  String get connectivityOfflineBanner =>
      'Вы не в сети. Изменения будут синхронизированы при подключении.';

  @override
  String get connectivityRequiredTitle => 'Нет подключения к интернету';

  @override
  String get connectivityRequiredMessage =>
      'Для этой функции требуется подключение к интернету. Подключитесь и попробуйте снова.';

  @override
  String get syncIndicatorSynced => 'Всё синхронизировано';

  @override
  String syncIndicatorSyncing(int count) {
    return '$count записей ожидают синхронизации';
  }

  @override
  String get syncIndicatorOffline => 'Не в сети';

  @override
  String syncIndicatorOfflineWithCount(int count) {
    return 'Не в сети – $count записей ожидают синхронизации';
  }

  @override
  String get syncIndicatorTitle => 'Синхронизация';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingSlide1Title => 'Добро пожаловать в Operationsbegleiter';

  @override
  String get onboardingSlide1Subtitle =>
      'Ваш личный помощник до и после операции';

  @override
  String get onboardingSlide1Feature1 =>
      'Вся важная информация на одном экране';

  @override
  String get onboardingSlide1Feature2 =>
      'Персональные чек-листы для вашей операции';

  @override
  String get onboardingSlide1Feature3 => 'Пошаговое сопровождение';

  @override
  String get onboardingSlide2Title => 'Подготовка';

  @override
  String get onboardingSlide2Subtitle => 'Оптимальная подготовка к операции';

  @override
  String get onboardingSlide2Feature1 => 'Индивидуальные планы подготовки';

  @override
  String get onboardingSlide2Feature2 => 'Напоминания о важных приёмах';

  @override
  String get onboardingSlide2Feature3 => 'Цифровое управление документами';

  @override
  String get onboardingSlide3Title => 'Послеоперационный уход';

  @override
  String get onboardingSlide3Subtitle => 'Поддержка после операции';

  @override
  String get onboardingSlide3Feature1 => 'Ежедневные проверки здоровья';

  @override
  String get onboardingSlide3Feature2 => 'Напоминания о лекарствах';

  @override
  String get onboardingSlide3Feature3 => 'Отслеживание прогресса';

  @override
  String get onboardingSlide4Title => 'Безопасность';

  @override
  String get onboardingSlide4Subtitle => 'Ваши данные в безопасности';

  @override
  String get onboardingSlide4Feature1 => 'Сквозное шифрование';

  @override
  String get onboardingSlide4Feature2 => 'Соответствие GDPR';

  @override
  String get onboardingSlide4Feature3 => 'Данные только на вашем устройстве';

  @override
  String get onboardingSlide5Title => 'Готовы?';

  @override
  String get onboardingSlide5Subtitle => 'Создайте свой профиль сейчас';

  @override
  String get onboardingSlide5Feature1 => 'Бесплатная регистрация';

  @override
  String get onboardingSlide5Feature2 => 'Готово за несколько минут';

  @override
  String get onboardingSlide5Feature3 => 'Можно удалить в любое время';

  @override
  String get authSlideTitle => 'Operationsbegleiter';

  @override
  String get authSlideSubtitle => 'Ваш личный помощник для операции';

  @override
  String get authSlideRegister => 'Регистрация';

  @override
  String get authSlideLogin => 'Войти';

  @override
  String get authSlideDoctorRegister =>
      'Зарегистрироваться как врач / организация';

  @override
  String get authSlideGuestMode => 'Гостевой режим';

  @override
  String get registerContinueAsGuest => 'Продолжить без регистрации';

  @override
  String get loginWelcomeBack => 'С возвращением';

  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginEnterEmailFirst => 'Сначала введите адрес электронной почты.';

  @override
  String get loginPasswordResetSent => 'Письмо для сброса пароля отправлено.';

  @override
  String get loginWithGoogle => 'Войти через Google';

  @override
  String get loginWithApple => 'Войти через Apple';

  @override
  String get noAccountYet => 'Ещё нет аккаунта?';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get createAccountTitle => 'Создать аккаунт';

  @override
  String get createAccountSubtitle => 'Зарегистрируйтесь, чтобы начать';

  @override
  String get fieldEmail => 'Электронная почта';

  @override
  String get fieldPassword => 'Пароль';

  @override
  String get fieldRepeatPassword => 'Повторите пароль';

  @override
  String get fieldFullName => 'Полное имя';

  @override
  String get fieldBirthDate => 'Дата рождения';

  @override
  String get fieldBirthDateHint => 'ДД.ММ.ГГГГ';

  @override
  String get fieldBirthDatePicker => 'Выберите дату рождения';

  @override
  String get validationEmailInvalid =>
      'Введите корректный адрес электронной почты.';

  @override
  String get validationPasswordMin6 =>
      'Пароль должен быть не менее 6 символов.';

  @override
  String get validationPasswordsMismatch => 'Пароли не совпадают.';

  @override
  String get validationNameRequired => 'Пожалуйста, введите ваше имя.';

  @override
  String get validationBirthDateRequired =>
      'Пожалуйста, введите дату рождения.';

  @override
  String get validationRepeatPassword => 'Пожалуйста, повторите пароль.';

  @override
  String get datePickerCancel => 'Отмена';

  @override
  String get datePickerConfirm => 'Подтвердить';

  @override
  String get agbAcceptPrefix => 'Я принимаю ';

  @override
  String get agbTermsLink => 'Условия использования';

  @override
  String get agbAndConnector => ' и ';

  @override
  String get agbPrivacyLink => 'Политику конфиденциальности';

  @override
  String get languageLabel => 'Язык';

  @override
  String get medicalDisclaimer =>
      'Это приложение не заменяет медицинскую консультацию. При проблемах со здоровьем обратитесь к врачу.';

  @override
  String get doctorRegTitle => 'Регистрация врача';

  @override
  String get doctorRegRoleBadge => 'Врач';

  @override
  String get doctorRegRoleBadgeSubtitle =>
      'Верифицированный медицинский специалист';

  @override
  String get doctorRegPersonalData => 'Личные данные';

  @override
  String get doctorRegProfessionalData => 'Профессиональные данные';

  @override
  String get doctorRegNameHint => 'Др. Иван Иванов';

  @override
  String get doctorRegEmailHint => 'doctor@clinic.ru';

  @override
  String get doctorRegEmailRequired =>
      'Пожалуйста, введите адрес электронной почты.';

  @override
  String get doctorRegEmailInvalid =>
      'Введите корректный адрес электронной почты.';

  @override
  String get doctorRegPasswordMin8 => 'Пароль должен быть не менее 8 символов.';

  @override
  String get doctorRegSpecialty => 'Специальность';

  @override
  String get doctorRegSelectSpecialty => 'Выберите специальность';

  @override
  String get doctorRegApprobation => 'Номер лицензии';

  @override
  String get doctorRegApprobationHint => 'напр. 12345678';

  @override
  String get doctorRegApprobationRequired =>
      'Пожалуйста, введите номер лицензии.';

  @override
  String get doctorRegKvNumber => 'Регистрационный номер';

  @override
  String get doctorRegKvHint => 'Необязательно';

  @override
  String get doctorRegPractice => 'Клиника / Практика';

  @override
  String get doctorRegPracticeHint => 'Название клиники или практики';

  @override
  String get doctorRegPracticeRequired => 'Пожалуйста, укажите вашу практику.';

  @override
  String get doctorRegServiceEmail => 'Рабочий адрес электронной почты';

  @override
  String get doctorRegDisclaimer =>
      'Ваши данные будут проверены, и ваш аккаунт будет активирован после успешной верификации.';

  @override
  String get doctorRegSubmit => 'Отправить регистрацию';

  @override
  String get doctorRegSubmitting => 'Отправка…';

  @override
  String get orgRegTitle => 'Регистрация организации';

  @override
  String get orgRegRoleBadge => 'Организация';

  @override
  String get orgRegRoleBadgeSubtitle =>
      'Больницы, клиники и реабилитационные центры';

  @override
  String get orgRegGeneralData => 'Общие данные';

  @override
  String get orgRegOrgData => 'Данные организации';

  @override
  String get orgRegOrgName => 'Название организации';

  @override
  String get orgRegOrgNameHint => 'напр. Университетская клиника';

  @override
  String get orgRegNameRequired => 'Пожалуйста, введите название организации.';

  @override
  String get orgRegOrgType => 'Тип организации';

  @override
  String get orgRegSelectOrgType => 'Выберите тип организации';

  @override
  String get orgRegAddress => 'Адрес';

  @override
  String get orgRegAddressHint => 'Улица, индекс, город';

  @override
  String get orgRegAddressRequired => 'Пожалуйста, введите адрес.';

  @override
  String get orgRegContactPerson => 'Контактное лицо';

  @override
  String get orgRegContactPersonHint => 'Имя и фамилия';

  @override
  String get orgRegContactPersonRequired =>
      'Пожалуйста, укажите контактное лицо.';

  @override
  String get orgRegEmail => 'Email организации';

  @override
  String get orgRegEmailHint => 'info@organisation.ru';

  @override
  String get orgRegPhone => 'Телефон';

  @override
  String get orgRegPhoneHint => '+7 495 123 4567';

  @override
  String get orgRegDisclaimer =>
      'Ваши данные будут проверены, и ваш аккаунт будет активирован после успешной верификации.';

  @override
  String get orgRegSubmit => 'Отправить регистрацию';

  @override
  String get orgRegSubmitting => 'Отправка…';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsNotAvailable => 'Настройки недоступны';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsPush => 'Push-уведомления';

  @override
  String get settingsEmailNotif => 'Email-уведомления';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsExportData => 'Экспорт данных';

  @override
  String get settingsResetData => 'Сбросить данные';

  @override
  String get settingsPro => 'Pro-версия';

  @override
  String get settingsProStatus => 'Статус Pro';

  @override
  String get settingsProSubtitle => 'Разблокировать все функции';

  @override
  String get settingsLegal => 'Правовая информация';

  @override
  String get settingsImprint => 'Импрессум';

  @override
  String get settingsPrivacy => 'Конфиденциальность';

  @override
  String get settingsTerms => 'Условия использования';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get tutorialSkip => 'Пропустить';

  @override
  String get tutorialNext => 'Далее';

  @override
  String get tutorialFinish => 'Готово';

  @override
  String get tutorialNeverShow => 'Больше не показывать';

  @override
  String get tutorialStep1Title => 'Добро пожаловать! 👋';

  @override
  String get tutorialStep1Desc =>
      'Привет, я Белла! Здесь вы найдёте всю важную информацию о вашей операции.';

  @override
  String get tutorialStep2Title => 'Ваши записи';

  @override
  String get tutorialStep2Desc =>
      'Следите за записями к врачу и подготовкой – я напомню вам вовремя.';

  @override
  String get tutorialStep3Title => 'Я всегда здесь';

  @override
  String get tutorialStep3Desc =>
      'Это я! 🐰 Нажмите на меня в любое время – я отвечу на все вопросы о вашем выздоровлении.';

  @override
  String get tutorialStep4Title => 'Узнайте больше';

  @override
  String get tutorialStep4Desc =>
      'В разделе \'Ещё\' вы найдёте настройки, помощь и дополнительные полезные функции.';

  @override
  String get profileCompleteness => 'Полнота профиля';

  @override
  String get profileStillTodo => 'Ещё нужно сделать';

  @override
  String get profileMoreItems => 'ещё';

  @override
  String get profileComplete => 'Заполнить профиль';

  @override
  String get profileCheckName => 'Указать имя';

  @override
  String get profileCheckOpDate => 'Указать дату операции';

  @override
  String get profileCheckOpType => 'Выбрать тип операции';

  @override
  String get profileCheckDoctor => 'Указать лечащего врача';

  @override
  String get profileCheckHospital => 'Указать больницу';

  @override
  String get profileCheckHeight => 'Указать рост';

  @override
  String get profileCheckWeight => 'Указать вес';

  @override
  String get profileCheckEmergencyContact =>
      'Добавить контакт для экстренной связи';

  @override
  String get doctorRegSpecialtyRequired =>
      'Пожалуйста, выберите специальность.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get done => 'Готово';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get close => 'Закрыть';

  @override
  String get retry => 'Повторить';

  @override
  String get add => 'Добавить';

  @override
  String get remove => 'Удалить';

  @override
  String get share => 'Поделиться';

  @override
  String get copy => 'Копировать';

  @override
  String get send => 'Отправить';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get reset => 'Сбросить';

  @override
  String get activate => 'Активировать';

  @override
  String get deactivate => 'Деактивировать';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get create => 'Создать';

  @override
  String get update => 'Обновить';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get all => 'Все';

  @override
  String get none => 'Нет';

  @override
  String get details => 'Подробности';

  @override
  String get info => 'Информация';

  @override
  String get warning => 'Предупреждение';

  @override
  String get urgent => 'Срочно';

  @override
  String get critical => 'Критично';

  @override
  String get high => 'Высокий';

  @override
  String get low => 'Низкий';

  @override
  String get normal => 'Нормальный';

  @override
  String get minimal => 'Минимальный';

  @override
  String get daily => 'Ежедневно';

  @override
  String get weekdays => 'Будние дни';

  @override
  String get everyNDays => 'Каждые N дней';

  @override
  String get customDay => 'Свой день';

  @override
  String get repeatUntil => 'Повторять до';

  @override
  String get repetition => 'Повторение';

  @override
  String get recurring => 'Повторяющийся';

  @override
  String get allDay => 'Весь день';

  @override
  String get notAvailable => 'Недоступно';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Выйти?';

  @override
  String get logoutAdminConfirm =>
      'Действительно выйти из панели администратора?';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Регистрация';

  @override
  String get accountRequired => 'Требуется учётная запись';

  @override
  String get passwordConfirm => 'Подтвердите пароль';

  @override
  String get passwordChanged => 'Пароль изменён';

  @override
  String get passwordReset => 'Сбросить пароль';

  @override
  String get passwordResetDone => 'Пароль был сброшен';

  @override
  String get passwordsMismatch => 'Пароли не совпадают';

  @override
  String get passwordMin6 => 'Минимум 6 символов';

  @override
  String newPasswordFor(String name) {
    return 'Новый пароль для $name';
  }

  @override
  String get deleteAccountTitle => 'Удалить аккаунт навсегда?';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteDataOnly => 'Удалить только данные';

  @override
  String get deleteFinal => 'Удалить окончательно';

  @override
  String get deleteUserAndData => 'Пользователь и все данные удалены.';

  @override
  String get resetDataTitle => 'Сбросить данные';

  @override
  String get allDataIrreversible => 'Удалить все данные безвозвратно';

  @override
  String get guestDataFound => 'Найдены локальные данные';

  @override
  String get guestDataDiscard => 'Нет, отклонить';

  @override
  String get guestDataTransfer => 'Да, перенести';

  @override
  String get settingSaveError => 'Настройка не может быть сохранена.';

  @override
  String get settingSaved => 'Настройки сохранены.';

  @override
  String get tutorialRepeat => 'Повторить обучение';

  @override
  String get tutorialRepeatSubtitle => 'Показать введение снова';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsActive => 'Уведомления включены';

  @override
  String get notificationsManage => 'Управление уведомлениями';

  @override
  String notificationsCountNew(int count) {
    return 'Уведомления ($count новых)';
  }

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get adDisplays => 'Реклама';

  @override
  String get usageStats => 'Статистика использования';

  @override
  String get crashReports => 'Отчёты о сбоях';

  @override
  String get bellaAiAssistant => 'ИИ-ассистент Белла';

  @override
  String get exportAsPdf => 'Экспорт в PDF';

  @override
  String get exportAsPdfSubtitle => 'Наглядный обзорный отчёт';

  @override
  String get exportAsJson => 'Экспорт в JSON';

  @override
  String get exportAsJsonSubtitle =>
      'Все необработанные данные для архивирования';

  @override
  String get exportCreating => 'Создание экспорта…';

  @override
  String get exportPreparing => 'Подготовка экспорта…';

  @override
  String get csvExporting => 'Экспорт CSV…';

  @override
  String get appointment => 'Приём';

  @override
  String get appointmentCreate => 'Создать приём';

  @override
  String get appointmentAdd => 'Добавить приём';

  @override
  String get appointmentConfirmed => 'Приём подтверждён';

  @override
  String get appointmentDeclined => 'Приём отклонён';

  @override
  String get appointmentDeleteConfirm => 'Удалить приём?';

  @override
  String get appointmentSaveError => 'Приём не удалось сохранить.';

  @override
  String get appointmentCreateError => 'Приём не удалось создать.';

  @override
  String get appointmentDeleteError => 'Ошибка при удалении приёма';

  @override
  String get appointmentForPatient => 'Создать приём для пациента';

  @override
  String get practiceAppointment => 'Приём в практике';

  @override
  String get practiceAppointmentOwn => 'Создать собственный внутренний приём';

  @override
  String get practiceAppointmentSaveError =>
      'Приём практики не удалось сохранить.';

  @override
  String get practiceAppointmentDeleteConfirm => 'Удалить приём практики?';

  @override
  String get calendarAddTitle => 'Добавить в календарь?';

  @override
  String get calendarNoThanks => 'Нет, спасибо';

  @override
  String get calendarShareIcs => 'Поделиться как .ics';

  @override
  String get calendarAdd => 'Добавить в календарь';

  @override
  String get medication => 'Лекарство';

  @override
  String get medicationAdd => 'Добавить лекарство';

  @override
  String get medicationPlan => 'План приёма лекарств';

  @override
  String get medicationHubOpen => 'Открыть центр лекарств';

  @override
  String get medicationIntakeTimes => 'Время приёма';

  @override
  String get medicationIntakeSaveError => 'Ошибка при сохранении приёма';

  @override
  String get medicationStock => 'Запас (необязательно)';

  @override
  String get medicationLocalAlarms =>
      'Локальные напоминания для активных времён';

  @override
  String get medicationAlarmDeleteError => 'Ошибка при удалении напоминания';

  @override
  String get patient => 'Пациент';

  @override
  String get patientInvite => 'Пригласить пациента';

  @override
  String get patientAdd => 'Добавить пациента';

  @override
  String get patientConnect => 'Связать пациента';

  @override
  String get patientLinked => 'Пациент успешно связан!';

  @override
  String get patientLinking => 'Связывание с пациентом';

  @override
  String get patientPlan => 'План пациента';

  @override
  String get patientAppointment => 'Приём пациента';

  @override
  String get patientData => 'Данные пациента';

  @override
  String get patientNoInvites => 'Нет приглашений для пациентов.';

  @override
  String get doctor => 'Врач';

  @override
  String get doctorAdd => 'Добавить врача';

  @override
  String get doctorRemove => 'Удалить врача';

  @override
  String get doctorConfirm => 'Подтвердить врача';

  @override
  String get doctorDisconnect => 'Отключить врача';

  @override
  String get doctorDeleted => 'Врач удалён.';

  @override
  String get doctorCreated => 'Врач создан';

  @override
  String get doctorDetails => 'Данные врача';

  @override
  String get doctorCreateInvite => 'Создать приглашение врача';

  @override
  String get doctorVerification => 'Верификация врача';

  @override
  String get doctorNoInvites => 'Нет приглашений для врачей.';

  @override
  String get doctorManage => 'Управление врачами';

  @override
  String get doctorEnterUid => 'Пожалуйста, введите UID врача.';

  @override
  String get doctorReportNotAvailable => 'Отчёт врача недоступен.';

  @override
  String get treatingDoctor => 'Лечащий врач';

  @override
  String get templateNew => 'Новый шаблон';

  @override
  String get templateNone => 'Шаблоны не найдены';

  @override
  String get templateDelete => 'Удалить шаблон?';

  @override
  String templateDeleteConfirm(String name) {
    return 'Вы действительно хотите удалить \"$name\"?';
  }

  @override
  String get templateSaved => 'Шаблон сохранён';

  @override
  String get templateSave => 'Сохранить шаблон';

  @override
  String get templateApply => 'Применить шаблон';

  @override
  String get templateFromTasks => 'Шаблон из задач';

  @override
  String get templateFromTasksCreate => 'Создать шаблон из задач';

  @override
  String templateCreated(String name) {
    return 'Шаблон \"$name\" создан';
  }

  @override
  String templateDuplicated(String name) {
    return '\"$name\" создан';
  }

  @override
  String get templateDuplicateError => 'Ошибка при дублировании';

  @override
  String templateAdopted(String name) {
    return '\"$name\" добавлен в собственные шаблоны';
  }

  @override
  String get templateAdoptError => 'Ошибка при принятии';

  @override
  String get templateDeleteError => 'Ошибка при удалении шаблона';

  @override
  String get templateOwnTemplates => 'Собственные шаблоны';

  @override
  String get templateDuplicate => 'Дублировать';

  @override
  String get templateAdopt => 'Принять';

  @override
  String get systemTemplates => 'Системные шаблоны';

  @override
  String get systemTemplateDelete => 'Удалить системный шаблон?';

  @override
  String get systemTemplateNone => 'Системных шаблонов ещё нет';

  @override
  String get systemTemplateFirst => 'Первый системный шаблон';

  @override
  String get task => 'Задача';

  @override
  String get taskDefine => 'Определить задачу';

  @override
  String get taskCreate => 'Создать задачу';

  @override
  String get taskCreateError => 'Задача не может быть создана.';

  @override
  String get taskAssign => 'Назначить задачу';

  @override
  String get taskRequired => 'Обязательный элемент';

  @override
  String tasksCount(int count) {
    return 'Задачи ($count)';
  }

  @override
  String tasksSelectCount(int selected, int total) {
    return 'Выберите задачи ($selected/$total):';
  }

  @override
  String get tasksSelectToApply => 'Выберите задачи для применения:';

  @override
  String get tasksNone => 'Нет задач';

  @override
  String get tasksNoneYet => 'Задач пока нет';

  @override
  String get tasksNoneAdded => 'Задачи ещё не добавлены';

  @override
  String get tasksNoneInPlan => 'В плане ещё нет задач.';

  @override
  String get tasksNoneAssigned => 'Назначенные задачи не найдены.';

  @override
  String get taskSaveError => 'Ошибка при сохранении задачи';

  @override
  String get taskRepeatCount => 'Количество повторений';

  @override
  String get taskDayOffset => 'Смещение в днях';

  @override
  String get taskDueAfterHours => 'Срок через (часов)';

  @override
  String get taskTimeOfDay => 'Время дня (необязательно)';

  @override
  String get taskMustNotForget => 'Нельзя забыть';

  @override
  String get phase => 'Фаза';

  @override
  String get phases => 'Фазы';

  @override
  String get phaseNone => 'Без фазы';

  @override
  String get phasesNone => 'Нет фаз — все задачи общие.';

  @override
  String get phaseRename => 'Переименовать фазу';

  @override
  String get inviteCreate => 'Создать приглашение';

  @override
  String get inviteCreated => 'Приглашение создано';

  @override
  String get inviteCreateError => 'Приглашение не удалось создать.';

  @override
  String get inviteAcceptError => 'Приглашение не удалось принять.';

  @override
  String get inviteRevoke => 'Отозвать приглашение?';

  @override
  String get inviteRevoked => 'Приглашение отозвано.';

  @override
  String get inviteAccepted => 'Приглашение принято.';

  @override
  String get invitations => 'Приглашения';

  @override
  String get inviteCodeCopied => 'Код приглашения скопирован';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get codeCopied => 'Код скопирован';

  @override
  String get codeCopiedExcl => 'Код скопирован!';

  @override
  String get codeEnter => 'Введите код';

  @override
  String get codeCopy => 'Копировать код';

  @override
  String get inviteFamilyMember => 'Пригласить члена семьи';

  @override
  String get observation => 'Записать наблюдение';

  @override
  String get observationNew => 'Новое наблюдение';

  @override
  String get observationsNone => 'Наблюдения ещё не записаны.';

  @override
  String get myObservations => 'Мои наблюдения';

  @override
  String get woundDoc => 'Документация ран';

  @override
  String get woundNoEntries => 'Записей о ранах ещё нет.';

  @override
  String get woundPhotoForAnalysis => 'Фото раны для анализа';

  @override
  String get woundChoosePhoto => 'Выберите фото для ИИ-анализа раны с Беллой';

  @override
  String get woundNoPhotos => 'Фото ран для анализа недоступны.';

  @override
  String get woundNoPhoto => 'Фото для анализа недоступно.';

  @override
  String get woundTakePhoto => '📷  Сделать новое фото';

  @override
  String get woundFromGallery => '🖼️  Выбрать из галереи';

  @override
  String get woundMinPhotos => 'Для сравнения нужно минимум 2 фото.';

  @override
  String get woundCompare => 'Сравнить';

  @override
  String get woundSliderMix => 'Ползунок A/B';

  @override
  String get painLevel => 'Уровень боли';

  @override
  String get painComparison => 'Сравнение уровня боли';

  @override
  String get painCourse7d => 'Динамика боли (7 дней)';

  @override
  String get painSaved => 'Значение боли сохранено';

  @override
  String painScoreOf10(int score) {
    return 'Боль: $score/10';
  }

  @override
  String painLevelOf10(int level) {
    return 'Уровень боли: $level/10';
  }

  @override
  String get unbearable => 'Невыносимая';

  @override
  String get moodSaved => 'Настроение сохранено';

  @override
  String get moodDeleteConfirm =>
      'Вы действительно хотите удалить эту запись о настроении?';

  @override
  String get nutritionDescribeMeal => 'Пожалуйста, опишите вашу еду';

  @override
  String get nutritionSaved => 'Блюдо сохранено';

  @override
  String get nutritionRecipes => 'Рецепты';

  @override
  String get nutritionDailyGoals => 'Дневные цели';

  @override
  String get vitalsMeasurementSaved => 'Измерение сохранено';

  @override
  String vitalsNewMeasurementsSync(int count) {
    return '$count новых измерений синхронизировано из Health';
  }

  @override
  String get bodyData => 'Данные тела';

  @override
  String get packingListReset => 'Сбросить список вещей?';

  @override
  String get packingListNoItems => 'Нет элементов в списке вещей.';

  @override
  String get packingListDelete => 'Удалить список?';

  @override
  String get packingListRename => 'Переименовать список';

  @override
  String get packingListNew => 'Новый список';

  @override
  String get packingListName => 'Название списка';

  @override
  String get packingListAddItem => 'Добавить элемент';

  @override
  String get documentUpload => 'Загрузить документ';

  @override
  String get documentDeleteConfirm => 'Удалить документ?';

  @override
  String get documentSavedLocally => 'Документ сохранён локально.';

  @override
  String get documentsOpen => 'Открыть документы';

  @override
  String get documentsAll => 'Все документы';

  @override
  String get noteDelete => 'Удалить заметку';

  @override
  String get noteSave => 'Сохранить заметку';

  @override
  String get noteDeleteError => 'Ошибка при удалении заметки';

  @override
  String get noteSaveError => 'Ошибка при сохранении заметки';

  @override
  String get voiceMemoSaved => 'Заметка сохранена';

  @override
  String get voiceMemoDelete => 'Удалить заметку?';

  @override
  String get voiceStartRecording => 'Начать запись';

  @override
  String get voiceNoMemos => 'Заметки не найдены.';

  @override
  String get voiceTranscriptSaved => 'Расшифровка сохранена';

  @override
  String get voiceNoTranscript =>
      'Расшифровка недоступна — сначала выполните транскрибирование.';

  @override
  String get voiceAudioNotFoundLocal => 'Аудиофайл не найден локально.';

  @override
  String get voiceAudioNotFound => 'Аудиофайл не найден.';

  @override
  String get voiceMicPermissionMissing => 'Разрешение на микрофон отсутствует.';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String get profileSaveError => 'Профиль не удалось сохранить.';

  @override
  String get yourDetails => 'Ваши данные';

  @override
  String get smokerStatus => 'Статус курильщика';

  @override
  String get hospitalClinic => 'Больница / Клиника';

  @override
  String get treatmentType => 'Тип лечения *';

  @override
  String get opDate => 'Дата операции *';

  @override
  String get currentOperation => 'Текущая операция';

  @override
  String get operationArchived => 'Операция заархивирована';

  @override
  String get markOpComplete => 'Отметить текущую операцию как завершённую';

  @override
  String get stayType => 'Тип пребывания';

  @override
  String get startDateOpDate => 'Дата начала (например, дата операции)';

  @override
  String get emergencyContact => 'Экстренный контакт';

  @override
  String get transportPlanSaved => 'Планирование транспорта сохранено';

  @override
  String get healthOverview => 'Обзор вашего здоровья';

  @override
  String get proUnlock => 'Разблокировать Pro';

  @override
  String get proRedeemKey => 'Активировать ключ Pro';

  @override
  String get proKeys => 'Ключи Pro';

  @override
  String get proKeysCreate => 'Создать ключи Pro';

  @override
  String get proGrantAccess => 'Предоставить доступ Pro';

  @override
  String get proHowManyDays => 'Сколько дней доступа Pro?';

  @override
  String get proStatusChangeError => 'Статус Pro не удалось изменить.';

  @override
  String get proManageSubscription => 'Управление подпиской';

  @override
  String get proRestorePurchase => 'Восстановить покупку';

  @override
  String staffMember(String action) {
    return 'Сотрудник $action';
  }

  @override
  String get staffUpdated => 'Сотрудник обновлён';

  @override
  String get staffRemove => 'Удалить сотрудника';

  @override
  String get staffCreate => 'Создать сотрудника';

  @override
  String get staffCreated => 'Сотрудник создан';

  @override
  String get orgJoin => 'Присоединиться к организации';

  @override
  String get orgJoinWithCode => 'Присоединиться по коду приглашения';

  @override
  String get orgConfirm => 'Подтвердить организацию';

  @override
  String get orgVerification => 'Верификация организации';

  @override
  String get ticketNew => 'Новый тикет';

  @override
  String get ticketCreated => 'Тикет создан!';

  @override
  String get ticketClosed => 'Тикет закрыт.';

  @override
  String get ticketCloseConfirm => 'Закрыть тикет?';

  @override
  String get ticketCloseExplanation => 'Тикет будет отмечен как закрытый.';

  @override
  String get tickets => 'Тикеты';

  @override
  String ticketsCountOpen(int count) {
    return 'Тикеты ($count открытых)';
  }

  @override
  String get myTickets => 'Мои тикеты';

  @override
  String get messageSendError => 'Сообщение не удалось отправить.';

  @override
  String get message => 'Сообщение';

  @override
  String get noMessagesYet => 'Сообщений пока нет.';

  @override
  String get questionAdd => 'Добавить вопрос';

  @override
  String get questionNew => 'Новый вопрос';

  @override
  String get questionCreate => 'Создать вопрос';

  @override
  String get questionDelete => 'Удалить вопрос?';

  @override
  String get loginToSaveQuestions =>
      'Пожалуйста, войдите, чтобы сохранить вопросы.';

  @override
  String get bellaSummarize => 'Резюмировать с Беллой';

  @override
  String get bellaAnalyze => 'Анализировать с Беллой';

  @override
  String get bellaGenerate => 'Сгенерировать';

  @override
  String get bellaRegenerate => 'Сгенерировать заново';

  @override
  String get bellaBriefingCopied => 'Брифинг скопирован в буфер обмена';

  @override
  String redFlagSaved(String level) {
    return 'Проверка тревожных знаков сохранена ($level)';
  }

  @override
  String get severityCourse => 'Динамика тяжести';

  @override
  String get lastFlags => 'Последние отметки';

  @override
  String get lastEntries => 'Последние записи:';

  @override
  String get photoSaved => 'Фото сохранено и синхронизировано.';

  @override
  String get photo => 'Фото';

  @override
  String get cameraOpening => 'Открытие камеры…';

  @override
  String get entryDeleted => 'Запись удалена';

  @override
  String get entryDeleteConfirm => 'Удалить запись?';

  @override
  String get entryDeleteIrreversible =>
      'Эта запись будет удалена безвозвратно.';

  @override
  String get entryDetailed => 'Подробная запись';

  @override
  String get entryNew => 'Новая запись';

  @override
  String get minTwoEntriesForComparison =>
      'Для сравнения нужно минимум 2 записи.';

  @override
  String get saveError => 'Ошибка сохранения';

  @override
  String get saveFailed => 'Ошибка сохранения';

  @override
  String get saveFailedDot => 'Ошибка сохранения.';

  @override
  String get deleteError => 'Ошибка удаления';

  @override
  String get disconnectError => 'Ошибка отключения';

  @override
  String get restoreError => 'Ошибка восстановления';

  @override
  String get pinError => 'Ошибка при закреплении';

  @override
  String get unlockFailed => 'Разблокировка не удалась.';

  @override
  String get lockFailed => 'Блокировка не удалась.';

  @override
  String get deleteFailed => 'Удаление не удалось.';

  @override
  String get actionFailed => 'Действие не удалось.';

  @override
  String get dataLoadError => 'Данные не удалось загрузить.';

  @override
  String get pageOpenError => 'Эта страница не открывается.';

  @override
  String get noLocalFile => 'Локальный файл недоступен.';

  @override
  String get fileNotFound => 'Файл не найден.';

  @override
  String get fileReadError => 'Файл не удалось прочитать.';

  @override
  String get uploadPending => 'Загрузка ожидает. Повторная попытка.';

  @override
  String get uploadFailedLocal => 'Загрузка не удалась — сохранено локально.';

  @override
  String get noEmailApp => 'Почтовое приложение не найдено';

  @override
  String get titleRequired => 'Пожалуйста, введите заголовок';

  @override
  String get titleAndMessageRequired =>
      'Заголовок и сообщение не должны быть пустыми.';

  @override
  String get titleAndUrlRequired => 'Заголовок и URL обязательны.';

  @override
  String get urlInvalid => 'Пожалуйста, введите полный http(s) URL.';

  @override
  String get imageRequired =>
      'Пожалуйста, выберите изображение для рекламы партнёра.';

  @override
  String get resultSaved => 'Результат сохранён';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена!';

  @override
  String get reportCopied => 'Отчёт скопирован в буфер обмена';

  @override
  String get allCopied => 'Все ключи скопированы в буфер обмена!';

  @override
  String get allCopy => 'Копировать все';

  @override
  String get selectSpecialty => 'Пожалуйста, выберите специальность';

  @override
  String get selectMinOneSection => 'Выберите хотя бы один раздел.';

  @override
  String errorGeneric(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get testNotificationCreated => 'Тестовое уведомление создано.';

  @override
  String get companion => 'Спутник';

  @override
  String get timeline => 'Таймлайн';

  @override
  String get toTimeline => 'К таймлайну';

  @override
  String get openDiary => 'Открыть дневник';

  @override
  String get openFullDiary => 'Открыть полный дневник';

  @override
  String get checklists => 'Чек-лист';

  @override
  String get categories => 'Категории';

  @override
  String get statistics => 'Статистика';

  @override
  String get statisticsLoadError => 'Статистику не удалось обновить.';

  @override
  String get statisticsLoading => 'Загрузка статистики...';

  @override
  String get tags => 'Теги';

  @override
  String get permissions => 'Разрешения';

  @override
  String get permissionsUpdated => 'Разрешения обновлены';

  @override
  String get myPermissions => 'Мои разрешения';

  @override
  String get readAllowed => 'Разрешить чтение';

  @override
  String get writeAllowed => 'Разрешить запись';

  @override
  String get readOnly => 'Только чтение';

  @override
  String get read => 'Чтение';

  @override
  String get settings => 'Настройки';

  @override
  String get general => 'Общее';

  @override
  String get practice => 'Практика';

  @override
  String get history => 'История';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get status => 'Статус';

  @override
  String get role => 'Роль';

  @override
  String get roleChange => 'Изменить роль';

  @override
  String get roleChangeError => 'Роль не удалось изменить.';

  @override
  String get roleDistribution => 'Распределение ролей';

  @override
  String get markAsRead => 'Отметить как прочитанное';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get pending => 'В ожидании';

  @override
  String get accepted => 'Принято';

  @override
  String get declined => 'Отклонено';

  @override
  String get resolved => 'Решено';

  @override
  String get inProgress => 'В процессе';

  @override
  String get locked => 'Заблокировано';

  @override
  String get full => 'Полный';

  @override
  String get off => 'Выкл';

  @override
  String get system => 'Система';

  @override
  String get user => 'Пользователь';

  @override
  String get overlayMode => 'Режим наложения';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get noAccess => 'Нет доступа';

  @override
  String get sureQuestion => 'Вы уверены?';

  @override
  String get disconnect => 'Отключить';

  @override
  String get disconnectConfirm => 'Отключить?';

  @override
  String get disconnected => 'Отключено';

  @override
  String get connect => 'Подключить';

  @override
  String get connectionRemove => 'Удалить соединение';

  @override
  String get archive => 'Архивировать';

  @override
  String get restore => 'Восстановить';

  @override
  String get rename => 'Переименовать';

  @override
  String get editTitle => 'Изменить заголовок';

  @override
  String get filterReset => 'Сбросить фильтр';

  @override
  String get sendEmail => 'Отправить email';

  @override
  String get day => 'День';

  @override
  String get moreTools => 'Ещё инструменты';

  @override
  String get checkAgain => 'Проверить снова';

  @override
  String get adDelete => 'Удалить рекламу?';

  @override
  String adDeleteMessage(String title) {
    return '\"$title\" будет удалена навсегда.';
  }

  @override
  String get adGlobalSettings => 'Глобальные настройки';

  @override
  String get adEnabled => 'Реклама включена';

  @override
  String get adGoogleAds => 'Google Ads';

  @override
  String get adAdmobBanner => 'Показывать баннерную рекламу AdMob';

  @override
  String get adPartnerAds => 'Партнёрская реклама';

  @override
  String adPartnerAdsCount(int count) {
    return 'Партнёрская реклама ($count)';
  }

  @override
  String get adFrequency => 'Частота';

  @override
  String get adPartnerCreate => 'Создать партнёрскую рекламу';

  @override
  String get adminActivities7d => 'Действия администратора (7 дней)';

  @override
  String get adminActionDistribution7d => 'Распределение действий (7 дней)';

  @override
  String get adminNewRegistrations30d => 'Новые регистрации (30 дней)';

  @override
  String get adminRegistrations => 'Регистрации';

  @override
  String get adminStatusOverview => 'Обзор статуса';

  @override
  String get adminAllRoles => 'Все роли';

  @override
  String get adminUserManage => 'Управление пользователями';

  @override
  String get adminUserLock => 'Заблокировать пользователя';

  @override
  String get adminAuditLog => 'Журнал аудита';

  @override
  String get adminLogsAppear => 'Журналы появятся здесь.';

  @override
  String get adminMaintenanceMode => 'Включить режим обслуживания';

  @override
  String get adminMaintenanceError => 'Режим обслуживания не удалось изменить.';

  @override
  String get adminFirebaseSmokeTest => 'Firebase Smoke Test';

  @override
  String get declineRequest => 'Отклонить запрос';

  @override
  String get requestDeclined => 'Запрос отклонён';

  @override
  String get requestNotFound => 'Запрос не найден.';

  @override
  String get requestReactivate => 'Реактивировать запрос?';

  @override
  String requestReactivated(String name) {
    return 'Запрос от $name реактивирован.';
  }

  @override
  String get reactivate => 'Реактивировать';

  @override
  String get reactivationFailed => 'Реактивация не удалась.';

  @override
  String get verificationFailed => 'Верификация не удалась.';

  @override
  String get declineReason => 'Причина отклонения';

  @override
  String get declineReasonAlt => 'Причина отклонения';

  @override
  String get internalCommentOptional =>
      'Необязательный внутренний комментарий:';

  @override
  String get decline => 'Отклонить';

  @override
  String get accept => 'Принять';

  @override
  String get revoke => 'Отозвать';

  @override
  String pushTo(String target) {
    return 'Push для $target';
  }

  @override
  String pushSent(String target) {
    return 'Push для $target отправлен.';
  }

  @override
  String get pushSendError => 'Push не удалось отправить.';

  @override
  String get kneeArthroscopy => 'Артроскопия колена';

  @override
  String get uniClinicMunich => 'Университетская клиника Мюнхена';

  @override
  String get wakeTimeMustBeAfterBed =>
      'Время подъёма должно быть позже времени сна.';

  @override
  String get qrCodeScan => 'Сканировать QR-код';

  @override
  String get releaseAll => 'Выпустить все';

  @override
  String get keyActivate => 'Активировать ключ';

  @override
  String get keyDeactivate => 'Деактивировать ключ?';

  @override
  String get keyDeactivated => 'Ключ деактивирован.';

  @override
  String get keyCreated => 'Ключ создан';

  @override
  String get keyDeactivateError => 'Ключ не удалось деактивировать.';

  @override
  String get keyCreateError => 'Ключ не удалось создать.';

  @override
  String get keysLoadError => 'Ключи не удалось загрузить.';

  @override
  String validForDays(int days) {
    return 'Действителен $days дней';
  }

  @override
  String get validityDuration => 'Срок действия:';

  @override
  String get targetGroup => 'Целевая группа';

  @override
  String get endTimeSet => 'Установить время окончания';

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
