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
  String get authSlideTrustSignals =>
      'Kostenlos · Keine Kreditkarte · In 30 Sek. startklar';

  @override
  String get authSlideSocialProof =>
      '4,9 ★ · 2.500+ Patienten vertrauen der App';

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
  String appointmentForPatient(String name) {
    return 'Создать приём для пациента';
  }

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

  @override
  String get scSeverityNone => 'Нет';

  @override
  String get scSeverityMild => 'Лёгкое';

  @override
  String get scSeverityModerate => 'Умеренное';

  @override
  String get scSeveritySevere => 'Сильное';

  @override
  String get scLevelGreen => 'Зелёный';

  @override
  String get scLevelYellow => 'Жёлтый';

  @override
  String get scLevelRed => 'Красный';

  @override
  String get scLevelTitleYellow => 'Пожалуйста, наблюдайте';

  @override
  String get scRecommendGreen =>
      'Ваши симптомы в норме. Продолжайте регулярно фиксировать данные и следуйте плану восстановления.';

  @override
  String get scRecommendYellow =>
      'Некоторые симптомы незначительно отклонены. Наблюдайте за развитием в течение следующих 24 часов. Обратитесь к врачу при ухудшении.';

  @override
  String get scRecommendRed =>
      'Ваши симптомы указывают на возможное осложнение. Немедленно обратитесь к врачу или в ближайшее отделение неотложной помощи.';

  @override
  String get scSymPain => 'Боль';

  @override
  String get scSymNausea => 'Тошнота';

  @override
  String get scSymBreathing => 'Дыхание';

  @override
  String get scSymDizziness => 'Головокружение';

  @override
  String get scSymWound => 'Состояние раны';

  @override
  String get scSymPainSub => 'Насколько сильна ваша боль в области операции?';

  @override
  String get scSymNauseaSub => 'Испытываете ли вы тошноту или позывы к рвоте?';

  @override
  String get scSymBreathingSub =>
      'Испытываете ли вы затруднение дыхания или одышку?';

  @override
  String get scSymDizzinessSub =>
      'Чувствуете ли вы головокружение или слабость?';

  @override
  String get scSymWoundSub =>
      'Проявляет ли рана отклонения (покраснение, выделения)?';

  @override
  String get scTitle => 'Проверка симптомов';

  @override
  String get scSymptomsSection => 'Оценка симптомов';

  @override
  String get scYourInputs => 'Ваши данные';

  @override
  String get scIntroBody =>
      'Оцените каждый симптом. В конце вы получите заключение с рекомендацией.';

  @override
  String get scSetDailyReminder => 'Установить ежедневное напоминание';

  @override
  String get scActionsTitle => 'Рекомендуемые действия';

  @override
  String get scSaveResult => 'Сохранить результат';

  @override
  String get scSaving => 'Сохранение…';

  @override
  String get scSaved => 'Сохранено ✓';

  @override
  String scResultBadge(String label) {
    return 'Результат: $label';
  }

  @override
  String scReminderActive(String time) {
    return 'Напоминание: $time';
  }

  @override
  String scReminderSet(String time) {
    return 'Напоминание установлено на $time';
  }

  @override
  String get nichtHinterlegt => 'Не указано';

  @override
  String get fieldName => 'Имя';

  @override
  String get fieldPhone => 'Номер телефона';

  @override
  String get fieldWeight => 'Вес';

  @override
  String get fieldSmoker => 'Курильщик';

  @override
  String get fieldOpType => 'Вид операции';

  @override
  String get fieldOpDate => 'Дата операции';

  @override
  String get fieldOpModus => 'Режим операции';

  @override
  String get fieldHospitalPhone => 'Телефон больницы';

  @override
  String get fieldDoctorPhone => 'Телефон врача';

  @override
  String get eiBloodType => 'Группа крови';

  @override
  String get eiAllergies => 'Аллергии';

  @override
  String get eiInsurance => 'Страховка';

  @override
  String get eiHospital => 'Больница';

  @override
  String get eiConditions => 'Предшествующие заболевания';

  @override
  String get eiMedications => 'Лекарства';

  @override
  String get eiOfflineBanner =>
      'Нет соединения – пожалуйста, загрузите экстренную информацию при наличии интернета.';

  @override
  String get eiNoDataHint =>
      'Данные о экстренной ситуации не сохранены.\nВнесите данные в своём профиле.';

  @override
  String get eiOpenProfile => 'Открыть профиль';

  @override
  String get eiShareHeader => '🆘 ЭКСТРЕННАЯ ИНФОРМАЦИЯ';

  @override
  String get eiShareEmergency => 'Скорая помощь: 112';

  @override
  String get eiSummaryNameHint => 'напр.: Иван Иванов';

  @override
  String get eiSummaryPhoneHint => 'напр.: +7 900 1234567';

  @override
  String get eiSummaryOpType => 'Тип операции';

  @override
  String get eiSummaryOpDateUnknown => 'Ещё не известно';

  @override
  String get eiSummaryTreatment => 'Лечение';

  @override
  String get eiSummaryAmbulant => 'Амбулаторно';

  @override
  String eiShareBloodType(String value) {
    return 'Группа крови: $value';
  }

  @override
  String eiShareAllergies(String value) {
    return 'Аллергии: $value';
  }

  @override
  String eiShareContact(String name) {
    return 'Контакт при чрезвычайной ситуации: $name';
  }

  @override
  String eiSharePhone(String value) {
    return 'Тел.: $value';
  }

  @override
  String eiShareHospital(String name) {
    return 'Больница: $name';
  }

  @override
  String eiShareHospitalPhone(String value) {
    return 'Тел. больницы: $value';
  }

  @override
  String eiShareDoctor(String name) {
    return 'Врач: $name';
  }

  @override
  String eiShareDoctorPhone(String value) {
    return 'Тел. врача: $value';
  }

  @override
  String eiShareInsurance(String value) {
    return 'Страховка: $value';
  }

  @override
  String get notfallInfoTeilen => 'Поделиться экстренной информацией';

  @override
  String get notruf112 => 'Скорая помощь 112';

  @override
  String get fehlerSpeichernErneut => 'Ошибка сохранения. Попробуйте снова.';

  @override
  String get fehlerBeimSpeichern => 'Ошибка сохранения.';

  @override
  String get woWirstDuBehandelt => 'Где вы будете проходить лечение?';

  @override
  String get fastGeschafft => 'Почти готово!';

  @override
  String get opClinic => 'Клиника';

  @override
  String get deinGesundheitsprofil => 'Ваш профиль здоровья';

  @override
  String get aktuelleMedikamente => 'Текущие медикаменты';

  @override
  String get oPTypEingeben => 'Введите тип операции';

  @override
  String get mitKrankenhausaufenthalt => 'С пребыванием в больнице';

  @override
  String get profilGespeichertKurz => 'Профиль сохранён';

  @override
  String get koerperwerteUndGesundheit => 'Показатели тела и здоровье';

  @override
  String get notfallkontaktUndNotfallInfo => 'Экстренный контакт и информация';

  @override
  String get bezeichnungEingeben => 'Введите название';

  @override
  String get pINAktivieren => 'Активировать PIN';

  @override
  String get n4StelligerZugangsPIN => '4-значный PIN доступа';

  @override
  String get proEntdecken => 'Открыть Pro';

  @override
  String get aktuellesPasswort => 'Текущий пароль';

  @override
  String get passwortSpeichern => 'Сохранить пароль';

  @override
  String labelHinzufuegen(String label) {
    return 'Добавить $label';
  }

  @override
  String get vitalwerte => 'Жизненные показатели';

  @override
  String get neueMessung => 'Новое измерение';

  @override
  String get systolisch => 'Систолическое';

  @override
  String get diastolisch => 'Диастолическое';

  @override
  String get puls => 'Пульс';

  @override
  String get normalSystolisch => 'Норма: 90–140';

  @override
  String get normalDiastolisch => 'Норма: 60–90';

  @override
  String get normalPuls => 'Норма: 60–100';

  @override
  String get weitereWerteOptional =>
      'Дополнительные показатели (необязательно)';

  @override
  String get vitalsErinnerung => 'Напоминание';

  @override
  String get taeglicheMesserinnerung => 'Ежедневное напоминание об измерении';

  @override
  String get temperatur => 'Температура';

  @override
  String get normalTemperatur => 'Норма: 36,0–37,5 °C';

  @override
  String get normalO2Saettigung => 'Норма: 95–100 %';

  @override
  String get notizOptional => 'Заметка (необязательно)';

  @override
  String get mindZweiEintraege => 'Мин. 2 записи для графика';

  @override
  String get vitalsTipp =>
      'Совет: записывайте показатели каждый день – это поможет замечать тенденции заранее.';

  @override
  String get chartLast5 => '5 записей';

  @override
  String get chartDays7 => '7 дней';

  @override
  String get chartDays30 => '30 дней';

  @override
  String get blutdruck => 'Артериальное давление';

  @override
  String get trageVitalwerteEin => 'Введите ваши текущие показатели.';

  @override
  String normalbereichValue(String min, String max, String unit) {
    return 'Норма: $min–$max $unit';
  }

  @override
  String neueMessungenSync(int count) {
    return '$count новых измерений синхронизовано';
  }

  @override
  String get neueMessungEintragen => 'Добавить измерение';

  @override
  String get messungGespeichert => 'Измерение сохранено';

  @override
  String get schmerzfrei => 'Без боли';

  @override
  String get sehrStark => 'Очень сильная';

  @override
  String get schmerztagebuch => 'Дневник боли';

  @override
  String get wieStarkSindDeineSchmerzen => 'Насколько сильна ваша боль?';

  @override
  String get woTutEsWeh => 'Где болит?';

  @override
  String get optionalTippeAufEineRegion => 'Необязательно – нажмите на область';

  @override
  String get artDerSchmerzen => 'Тип боли';

  @override
  String get optionalWieFuehltEsSichAn =>
      'Необязательно – как это чувствуется?';

  @override
  String get avgSiebenTage => 'Ø 7 дней';

  @override
  String get gesamt => 'Всего';

  @override
  String get trendLabel => 'Тренд';

  @override
  String get minMax => 'Мин / Макс';

  @override
  String eintraegeInsgesamt(int count) {
    return '$count записей всего';
  }

  @override
  String get mehrMitPro => 'Больше с Pro';

  @override
  String letzteEintraege(int count) {
    return 'Последние $count записи';
  }

  @override
  String letzteEintraegeGratis(int count) {
    return 'Последние $count записи (5 бесплатно)';
  }

  @override
  String get letzteEintraegeHeader => 'Последние записи';

  @override
  String get alleAnzeigen => 'Все →';

  @override
  String get gradesEben => 'Только что';

  @override
  String vorMinuten(int min) {
    return '$min мин. назад';
  }

  @override
  String vorStunden(int h) {
    return '$h ч. назад';
  }

  @override
  String get gestern => 'Вчера';

  @override
  String vorTagen(int days) {
    return '$days дней назад';
  }

  @override
  String get ortOptional => 'Место (необязательно)';

  @override
  String get ausloeserOptional => 'Триггер (необязательно)';

  @override
  String get painEntryEditorNotizOptional => 'Заметка (необязательно)';

  @override
  String get eintragBearbeiten => 'Редактировать запись';

  @override
  String get schmerzlevel => 'Уровень боли';

  @override
  String get wann => 'Когда?';

  @override
  String get datumLabel => 'Дата';

  @override
  String get uhrzeitLabel => 'Время';

  @override
  String get dauerLabel => 'Продолжительность';

  @override
  String get dauerhaft => 'Постоянная';

  @override
  String minMinuten(int min) {
    return '$min мин.';
  }

  @override
  String stundenLabel(int h) {
    return '$h ч.';
  }

  @override
  String get medikationLabel => 'Лекарство';

  @override
  String get eintragLoeschen => 'Удалить запись';

  @override
  String get kalender => 'Календарь';

  @override
  String get proLabel => 'Pro';

  @override
  String get filterAktiv => 'Фильтр активен';

  @override
  String get filtern => 'Фильтр';

  @override
  String get koerperregion => 'Область тела';

  @override
  String get schmerzart => 'Тип боли';

  @override
  String get insights => 'Аналитика';

  @override
  String haeufigstesGebiet(String region) {
    return 'Наиболее частая область: $region';
  }

  @override
  String get keineEintraegeFilter => 'Нет записей с этими фильтрами';

  @override
  String get nochKeineEintraege => 'Записей пока нет';

  @override
  String get tippeAufNeuenEintrag => 'Нажмите \"+ Новая запись\", чтобы начать';

  @override
  String avgWert(String val) {
    return 'Ø $val';
  }

  @override
  String get heute => 'Сегодня';

  @override
  String get montag => 'Понедельник';

  @override
  String get dienstag => 'Вторник';

  @override
  String get mittwoch => 'Среда';

  @override
  String get donnerstag => 'Четверг';

  @override
  String get freitag => 'Пятница';

  @override
  String get samstag => 'Суббота';

  @override
  String get sonntag => 'Воскресенье';

  @override
  String get moKurz => 'Пн';

  @override
  String get diKurz => 'Вт';

  @override
  String get miKurz => 'Ср';

  @override
  String get doKurz => 'Чт';

  @override
  String get frKurz => 'Пт';

  @override
  String get saKurz => 'Сб';

  @override
  String get soKurz => 'Вс';

  @override
  String get keinSchmerz => 'Нет';

  @override
  String get kalenderMitProFreischalten => 'Откройте календарь с Pro';

  @override
  String get keineDetails => 'Нет подробностей';

  @override
  String get minLabel => 'Мин';

  @override
  String get maxLabel => 'Макс';

  @override
  String get bellaAnalyse => 'Анализ Bella';

  @override
  String get emptyNoEntries => 'Записей пока нет';

  @override
  String get emptyWoundDocHint =>
      'Документируйте процесс заживления ежедневными фотографиями.';

  @override
  String get ersteDokumentationStarten => 'Начать первую документацию';

  @override
  String get neuesFotoAufnehmen => 'Сделать новое фото';

  @override
  String get woundHubKoerperstelle => 'Место на теле';

  @override
  String get neuErfassen => 'Новая запись';

  @override
  String get verlaufVergleichen => 'Сравнить прогресс';

  @override
  String get koerperstelle => 'Место на теле';

  @override
  String get keinFotoAnalyse => 'Фото отсутствует.';

  @override
  String get n1FotoPflaster => '1. Фото: пластырь';

  @override
  String get zeigtDenZustandDesVerbands => 'Показывает состояние повязки';

  @override
  String get n2FotoWunde => '2. Фото: рана';

  @override
  String get nachAbnehmenDesPflasters => 'После снятия пластыря';

  @override
  String get linksA => 'Левая (A)';

  @override
  String get rechtsB => 'Правая (B)';

  @override
  String schmerzScore(int score) {
    return 'Уровень боли: $score/10';
  }

  @override
  String get fotoLadeFehler => 'Не удалось загрузить фото.';

  @override
  String get fotoHinzufuegen => 'Добавить фото';

  @override
  String get fotoQuelleWaehlen => 'Выбрать источник фото';

  @override
  String get kameraOeffnen => 'Камера';

  @override
  String get ausGalerieWaehlen => 'Из галереи';

  @override
  String get fotoAendern => 'Изменить фото';

  @override
  String get fotoEntfernen => 'Удалить фото';

  @override
  String get kameraBerechtigungFehlt =>
      'Доступ к камере запрещён. Пожалуйста, разрешите доступ в настройках.';

  @override
  String get fotoMediathekBerechtigungFehlt =>
      'Доступ к фотогалерее запрещён. Пожалуйста, разрешите доступ в настройках.';

  @override
  String get kameraFehlerVersucheGalerie =>
      'Камера недоступна. Пожалуйста, выберите фото из галереи.';

  @override
  String get koerperstelleOptional => 'Место на теле (необязательно)';

  @override
  String get woundCompareTitle => 'Сравнение ран';

  @override
  String get woundCompareSlider => 'Прогресс';

  @override
  String get woundCompareCompare => 'Сравнение';

  @override
  String get emptyNoPhotos => 'Фотографий пока нет.';

  @override
  String get emptyWoundCompareHint =>
      'Добавьте фотографии к документации раны для сравнения прогресса.';

  @override
  String get wundDokumentationTitle => 'Документация раны';

  @override
  String get woundNoPhotoYet => 'Фото пока нет';

  @override
  String get woundNoteHint => 'Как выглядит рана? Что-то примечательное?';

  @override
  String get notizLabel => 'Заметка';

  @override
  String get woundHistoryTitle => 'История раны';

  @override
  String get woundDiaryTitle => 'Дневник раны';

  @override
  String get woundDiarySubtitle =>
      'Хронологический обзор заживления раны с фото и заметками.';

  @override
  String get woundPhotoGuideTitle => 'Руководство по фото';

  @override
  String get woundPhotoGuideSubtitle =>
      'Для хорошей документации рекомендуем 2 фото в день:';

  @override
  String get woundPhotoTip =>
      'Совет: обеспечьте хорошее освещение и фотографируйте под одним углом.';

  @override
  String get woundNoNotiz => 'Нет заметки';

  @override
  String get woundDetailTitle => 'Детали раны';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get woundDeleteConfirmMessage =>
      'Эта запись о ране будет удалена навсегда.';

  @override
  String get woundMinEntriesForCompare =>
      'Для сравнения нужно минимум 2 записи.';

  @override
  String get woundDiscoveryTip =>
      'Совет: фотографируйте рану регулярно – так вы заметите изменения с первого взгляда.';

  @override
  String woundEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей',
      few: '$count записи',
      one: '1 запись',
    );
    return '$_temp0';
  }

  @override
  String get woundNoPhotoCaptured => 'Фото отсутствует';

  @override
  String get woundTapForDetails => 'Нажмите для подробностей';

  @override
  String get woundComparePick2 => 'Выберите два фото для сравнения';

  @override
  String get woundModeSplit => 'Разделить';

  @override
  String get woundModeOverlay => 'Наложение';

  @override
  String woundComparePhotosSelected(int count) {
    return '$count / 2 фото выбрано';
  }

  @override
  String get woundCompareTapInstruction =>
      'Нажмите на фотографии ниже, которые хотите сравнить.';

  @override
  String get before => 'До';

  @override
  String get after => 'После';

  @override
  String get woundHygieneStep1 => 'Тщательно вымойте руки';

  @override
  String get woundHygieneStep2 => '🩹 Сухая смена пластыря';

  @override
  String get woundHygieneStep3 =>
      'Проверка раны: сухая? Не красная? Нет свежего кровотечения?';

  @override
  String get woundHygieneStep4 =>
      'Не прикасайтесь к ране, не манипулируйте, без кремов';

  @override
  String get woundHygieneStep5 => 'Замените пластырь, не касаясь прокладки';

  @override
  String get woundHygieneStep6 => 'Снова вымойте руки';

  @override
  String get woundHygieneTitle => '🧴 Рекомендации по гигиене раны';

  @override
  String get woundHygieneWarning => 'При покраснении обратитесь в клинику';

  @override
  String woundHygieneAckLabel(String date) {
    return '✅ Прочитано $date';
  }

  @override
  String get kalorienKcal => 'Калории (ккал)';

  @override
  String get nutritionProteinG => 'Белки (г)';

  @override
  String get wasserMl => 'Вода (мл)';

  @override
  String get nameDerVorlage => 'Название шаблона';

  @override
  String get zBHaferbreiMitBeeren => 'напр. овсяная каша с ягодами';

  @override
  String get zbVollkornbrot => 'напр. цельнозерновой хлеб с сыром';

  @override
  String get proteinG => 'Белки (г)';

  @override
  String get nutritionKohlenhG => 'Углеводы (г)';

  @override
  String get nutritionFettG => 'Жиры (г)';

  @override
  String templateWirdEntfernt(String name) {
    return '«$name» будет удалён из ваших шаблонов.';
  }

  @override
  String get naehrwerteOptional => 'Питательные вещества (необязательно)';

  @override
  String get kohlenhG => 'Углеводы (г)';

  @override
  String get fettG => 'Жиры (г)';

  @override
  String get getrunkenMl => 'Выпито (мл)';

  @override
  String get vertraeglichkeit => 'Переносимость';

  @override
  String get mahlzeitSpeichern => 'Сохранить приём пищи';

  @override
  String wasserMlDescription(int ml) {
    return 'Вода $mlмл';
  }

  @override
  String wasserMlAdded(int ml) {
    return '+$mlмл воды добавлено';
  }

  @override
  String get vorlageLabel => 'Шаблон';

  @override
  String get wasserTracking => 'Отслеживание воды';

  @override
  String get favoriten => 'Избранное';

  @override
  String get tippeZumSchnellenWiederholen => 'Нажмите для быстрого повтора';

  @override
  String get mahlzeitLabel => 'Приём пищи';

  @override
  String get wasHastDuGegessen => 'Что вы ели?';

  @override
  String get optionalWasserTeeEtc => 'Необязательно – вода, чай и т.д.';

  @override
  String get optionalWieVertragen => 'Необязательно – как вы перенесли еду?';

  @override
  String get symptomeNachDemEssen => 'Симптомы после еды';

  @override
  String get optionalTippeAuf =>
      'Необязательно – нажмите на подходящие симптомы';

  @override
  String get naehrwerteTitle => 'Питательные вещества';

  @override
  String get optionalKalorienProtein =>
      'Необязательно – калории, белки, углеводы, жиры';

  @override
  String get vorlagenTitle => 'Шаблоны';

  @override
  String empfehlungFuerOp(String opType) {
    return 'Рекомендация для операции $opType';
  }

  @override
  String empfehlungFuerOpTag(int day) {
    return ' · День $day';
  }

  @override
  String get empfehlungenTitle => 'Рекомендации';

  @override
  String heuteMahlzeitenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count приёмов пищи',
      few: '$count приёма пищи',
      one: '1 приём пищи',
    );
    return '$_temp0';
  }

  @override
  String get kcalLabel => 'ккал';

  @override
  String get proteinLabel => 'Белки';

  @override
  String get wasserLabel => 'Вода';

  @override
  String symptomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count симптомов',
      few: '$count симптома',
      one: '1 симптом',
    );
    return '$_temp0';
  }

  @override
  String keineFilterEintraege(String mealType) {
    return 'Нет записей $mealType';
  }

  @override
  String get ersteMahlzeitTipp =>
      'Нажмите +, чтобы добавить первый приём пищи.';

  @override
  String get beschreibungLabel => 'Описание';

  @override
  String get zbVollkornbrotQuark => 'напр. цельнозерновой хлеб с творогом';

  @override
  String get zbZahl => 'напр. 250';

  @override
  String get symptomeLabel => 'Симптомы';

  @override
  String get notizZuSymptomenOptional => 'Заметка о симптомах (необязательно)';

  @override
  String get eintrBearbeiten => 'Редактировать запись';

  @override
  String get neueMahlzeit => 'Новый приём пищи';

  @override
  String get eintrLoeschen => 'Удалить запись';

  @override
  String get mealTypeFruehstueck => 'Завтрак';

  @override
  String get mealTypeMittagessen => 'Обед';

  @override
  String get mealTypeAbendessen => 'Ужин';

  @override
  String get mealTypeSnack => 'Перекус';

  @override
  String get symptomUebelkeit => 'Тошнота';

  @override
  String get symptomBlaehungen => 'Вздутие';

  @override
  String get symptomSchmerzen => 'Боль';

  @override
  String get symptomSodbrennen => 'Изжога';

  @override
  String get symptomDurchfall => 'Диарея';

  @override
  String get symptomVerstopfung => 'Запор';

  @override
  String get symptomMuedigkeit => 'Усталость';

  @override
  String get symptomSonstige => 'Другое';

  @override
  String get nochmal => 'Ещё раз';

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
  String get apptAddFirstHint => 'Нажмите +, чтобы добавить первую запись.';

  @override
  String get apptCancelAppt => 'Отменить';

  @override
  String get apptConfirmationPending => 'Ожидается подтверждение';

  @override
  String get apptConfirmDeclineHint => 'Пожалуйста, подтвердите или отклоните.';

  @override
  String get apptCreatedByDoctor => 'Создано врачом';

  @override
  String get apptDeleteTitle => 'Удалить запись';

  @override
  String get apptEditTitle => 'Редактировать запись';

  @override
  String get apptHintCustomMinutes => 'Минуты';

  @override
  String get apptHintDoctor => 'напр. Д-р Иванов';

  @override
  String get apptHintLocation => 'напр. городская клиника';

  @override
  String get apptHintLocationDetails => 'Детали (отделение, палата)';

  @override
  String get apptHintNote => 'Необязательная заметка…';

  @override
  String get apptHintTitle => 'напр. контрольный осмотр';

  @override
  String get apptLabelCustomMinutes => 'Минуты';

  @override
  String get apptLabelDate => 'Дата';

  @override
  String get apptLabelDoctor => 'Врач / Специалист';

  @override
  String get apptLabelEndTime => 'Время окончания';

  @override
  String get apptLabelFurtherDetails => 'Доп. сведения';

  @override
  String get apptLabelFurtherReminders => 'Доп. напоминания';

  @override
  String get apptLabelLocation => 'Место';

  @override
  String get apptLabelNote => 'Заметка';

  @override
  String get apptLabelPriority => 'Приоритет';

  @override
  String get apptLabelReminder => 'Напоминание';

  @override
  String get apptLabelRepeatUntil => 'До';

  @override
  String get apptLabelStartTime => 'Время начала';

  @override
  String get apptLabelTime => 'Время';

  @override
  String get apptLabelTitleRequired => 'Заголовок *';

  @override
  String get apptLabelType => 'Тип';

  @override
  String get apptMarkAsDone => 'Отметить как выполненное';

  @override
  String get apptMarkAsPlanned => 'Отметить как запланированное';

  @override
  String get apptNewTitle => 'Новая запись';

  @override
  String get apptNoAppointments => 'Нет записей';

  @override
  String get apptNoResults => 'Нет результатов';

  @override
  String get apptNoResultsHint => 'Попробуйте другие запросы или фильтры.';

  @override
  String get apptPriorityHigh => 'Высокий';

  @override
  String get apptPriorityLow => 'Низкий';

  @override
  String get apptPriorityMedium => 'Средний';

  @override
  String get apptPriorityUrgent => 'Срочный';

  @override
  String get apptReminderAtTime => 'В назначенное время';

  @override
  String get apptReminderCustom => 'Настраиваемый';

  @override
  String get apptReminderDay1 => 'За 1 день';

  @override
  String get apptReminderDays2 => 'За 2 дня';

  @override
  String get apptReminderHour1 => 'За 1 час';

  @override
  String get apptReminderHours2 => 'За 2 часа';

  @override
  String get apptReminderMin15 => 'За 15 минут';

  @override
  String get apptReminderMin30 => 'За 30 минут';

  @override
  String get apptReminderNone => 'Нет';

  @override
  String get apptRepeatDaily => 'Ежедневно';

  @override
  String get apptRepeatMonthly => 'Ежемесячно';

  @override
  String get apptRepeatNone => 'Нет';

  @override
  String get apptRepeatWeekly => 'Еженедельно';

  @override
  String get apptSaving => 'Сохранение…';

  @override
  String get apptStatusCanceled => 'Отменено';

  @override
  String get apptStatusCompleted => 'Завершено';

  @override
  String get apptStatusConfirmed => 'Подтверждено';

  @override
  String get apptStatusDeclined => 'Отклонено';

  @override
  String get apptStatusDone => 'Выполнено';

  @override
  String get apptStatusPending => 'Ожидается';

  @override
  String get apptStatusPlanned => 'Запланировано';

  @override
  String get apptTitleRequired => 'Заголовок обязателен.';

  @override
  String get apptTodayNone => 'Сегодня нет записей';

  @override
  String get apptTodayTitle => 'Записи сегодня';

  @override
  String get apptTypeCall => 'Звонок';

  @override
  String get apptTypeFollowUp => 'Наблюдение';

  @override
  String get apptTypeImaging => 'Визуализация';

  @override
  String get apptTypeOther => 'Другое';

  @override
  String get apptTypePhysio => 'Физиотерапия';

  @override
  String get apptTypeSurgery => 'Операция';

  @override
  String get apptViewCalendar => 'Календарь';

  @override
  String get apptViewList => 'Список';

  @override
  String get apptYesterday => 'Вчера';

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
  String get bellaActionCancelled => 'Отменено';

  @override
  String get bellaActionCreated => 'Запись создана ✓';

  @override
  String get bellaActionFailed => 'Ошибка создания';

  @override
  String get bellaArztBriefing => 'Bella Arzt-Briefing';

  @override
  String get bellaAskDirectly => 'Или задайте вопрос напрямую:';

  @override
  String get bellaBriefingGenerating => 'Bella создаёт ваш врачебный брифинг …';

  @override
  String get bellaBriefingIsProFeature => 'Врачебный брифинг — функция Pro';

  @override
  String get bellaBriefingNotSignedIn => 'Пожалуйста, войдите в систему.';

  @override
  String get bellaBriefingPersonalTitle => 'Ваш персональный врачебный брифинг';

  @override
  String get bellaBriefingProDescription =>
      'С Pro Bella создаёт персональное резюме для вашего следующего визита к врачу.';

  @override
  String get bellaChipAddTask => 'Добавь задачу: проверить рану';

  @override
  String get bellaChipAppFunctions => 'Какие функции есть в приложении?';

  @override
  String get bellaChipCallDoctor => 'Когда мне звонить врачу?';

  @override
  String get bellaChipCreateAppointment => 'Создай приём завтра в 10:00';

  @override
  String get bellaChipDoctorDashboard => 'Как работает панель врача?';

  @override
  String get bellaChipDoctorReport => 'Как создать отчёт врача?';

  @override
  String get bellaChipGeneralDashboard => 'Как работает панель управления?';

  @override
  String get bellaChipKneeTep => 'Информация о протезировании колена';

  @override
  String get bellaChipLinkPatient => 'Как привязать пациента?';

  @override
  String get bellaChipLogBloodPressure => 'Записать давление 120/80';

  @override
  String get bellaChipLogMedication => 'Я только что принял ибупрофен';

  @override
  String get bellaChipLogPain => 'Записать боль: колено, уровень 4';

  @override
  String get bellaChipMedications => 'Как вносить мои лекарства?';

  @override
  String get bellaChipMyTasks => 'Каковы мои задачи?';

  @override
  String get bellaChipOpDay => 'Что происходит в день операции?';

  @override
  String get bellaChipPrepareOp => 'Как подготовиться к операции?';

  @override
  String get bellaChipSymptomCheck => 'Начать проверку симптомов';

  @override
  String get bellaChipTimeline => 'Как работает расписание?';

  @override
  String get bellaChipVerifyAccount => 'Как верифицировать аккаунт врача?';

  @override
  String get bellaChipViewPatientData => 'Как просматривать данные пациентов?';

  @override
  String get bellaChipViewPatientDataStaff =>
      'Как просматривать данные пациентов?';

  @override
  String get bellaConsentAccepted => 'Согласие дано';

  @override
  String get bellaConsentBody =>
      'ИИ-ассистент (Bella AI) использует внешний сервис (NVIDIA Corporation, США) для ответов на ваши вопросы.\n\nВаши сообщения чата передаются в этот сервис. Никакие другие персональные данные не передаются.\n\nВы можете отозвать своё согласие в любое время в Настройках.\n\nПравовое основание: ст. 6(1)(а) и ст. 9(2)(а) GDPR.';

  @override
  String get bellaConsentDeclined => 'Согласие отклонено';

  @override
  String get bellaConsentTitle => 'Уведомление о конфиденциальности';

  @override
  String get bellaConsentYes => 'Да, согласен';

  @override
  String get bellaDailyAnalysis => 'Ежедневный анализ Bella';

  @override
  String get bellaDefaultWoundPrompt =>
      'Пожалуйста, проанализируйте это фото раны.';

  @override
  String get bellaDescriptionDoctor =>
      'Я помогаю вам с панелью врача, управлением пациентами и клиническими вопросами.';

  @override
  String get bellaDescriptionPatient =>
      'Я отвечаю на ваши вопросы об операции, послеоперационном уходе и приложении.';

  @override
  String get bellaDescriptionStaff =>
      'Я помогаю вам с панелью сотрудников и уходом за пациентами.';

  @override
  String get bellaDisclaimer =>
      'Не является медицинской консультацией – при жалобах обратитесь к врачу.';

  @override
  String get bellaFeatureAftercare => 'Послеоперационный уход';

  @override
  String get bellaFeatureAppHelp => 'Помощь по приложению';

  @override
  String get bellaFeatureDashboard => 'Панель';

  @override
  String get bellaFeatureMedicalKnowledge => 'Об операции';

  @override
  String get bellaFeaturePatients => 'Пациенты';

  @override
  String get bellaFeatureTasks => 'Задачи';

  @override
  String get bellaFeatureWarnings => 'Предупреждения';

  @override
  String get bellaGreeting => 'Привет! Я Bella AI 🐰';

  @override
  String get bellaNoAnswerReceived => 'Ответ не получен. Попробуйте снова. 🐰';

  @override
  String get bellaProactivePainTrend =>
      'Уровень боли растёт – хотите поговорить об этом?';

  @override
  String get bellaProUpgrade => 'Перейти на Pro сейчас';

  @override
  String get bellaSays => 'Bella говорит:';

  @override
  String get bellaSubtitleDoctor => 'Ваш клинический ассистент 🐰';

  @override
  String get bellaSubtitlePatient => 'Ваш помощник по операции 🐰';

  @override
  String get bellaSubtitleStaff => 'Ваш ассистент клиники 🐰';

  @override
  String get bellaWoundAnalysisTitle => 'Анализ раны';

  @override
  String get bellaWoundDisclaimer =>
      'Не заменяет медицинский диагноз. При сомнениях обратитесь к своей медицинской команде.';

  @override
  String get bellaWoundObservations => 'Наблюдения';

  @override
  String get bellaWoundProgressComparison => 'Сравнение прогресса';

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
  String get calendarAddedSuccess => 'Запись добавлена в календарь';

  @override
  String get calendarAddToCalendarBody =>
      'Хотите добавить эту запись в календарь устройства или поделиться как .ics-файл?';

  @override
  String get calendarExportFailed => 'Экспорт в календарь не удался';

  @override
  String get calendarMonth => 'Месяц';

  @override
  String get calendarNoEvents => 'Нет приёмов на этот день';

  @override
  String get calendarTitle => 'Календарь';

  @override
  String get calendarWeek => 'Неделя';

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
  String get monthApril => 'Апрель';

  @override
  String get monthAugust => 'Август';

  @override
  String get monthDecember => 'Декабрь';

  @override
  String get monthFebruary => 'Февраль';

  @override
  String get monthJanuary => 'Январь';

  @override
  String get monthJuly => 'Июль';

  @override
  String get monthJune => 'Июнь';

  @override
  String get monthMarch => 'Март';

  @override
  String get monthMay => 'Май';

  @override
  String get monthNovember => 'Ноябрь';

  @override
  String get monthOctober => 'Октябрь';

  @override
  String get monthSeptember => 'Сентябрь';

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
  String get placeholderLoading => 'Загрузка…';

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
  String get rfActiveWarnings => 'Активные предупреждения';

  @override
  String get rfCheckStart => 'Начать проверку';

  @override
  String get rfEmergencyFollowSteps => 'Следуйте этим шагам по порядку.';

  @override
  String get rfEmergencyInstructions => 'Экстренные инструкции';

  @override
  String get rfEmergencyStep1Desc => 'Сядьте или лягте. Дышите спокойно.';

  @override
  String get rfEmergencyStep1Title => 'Сохраняйте спокойствие';

  @override
  String get rfEmergencyStep2Desc =>
      'Запишите текущие жалобы и их интенсивность.';

  @override
  String get rfEmergencyStep2Title => 'Проверьте симптомы';

  @override
  String get rfEmergencyStep3Desc =>
      'Позвоните своему врачу или в клинику и опишите симптомы.';

  @override
  String get rfEmergencyStep3Title => 'Позвоните врачу';

  @override
  String get rfEmergencyStep4Desc =>
      'При одышке, потере сознания или сильном кровотечении немедленно звоните 112.';

  @override
  String get rfEmergencySubtitle =>
      'Немедленные меры при одышке, потере сознания или сильном кровотечении.';

  @override
  String get rfEscalate => 'Эскалировать';

  @override
  String get rfNoActiveWarnings => 'Нет активных предупреждений. Продолжайте!';

  @override
  String get rfNoFlags => 'Нет красных флажков';

  @override
  String get rfProAutoDetect =>
      'С Pro система автоматически обнаруживает критические значения из боли, виталов и других данных.';

  @override
  String get rfProFeatureSubtitle =>
      'Вводите жалобы вручную или обновитесь до Pro.';

  @override
  String get rfProFeatureTitle =>
      'Автоматическое обнаружение красных флажков — функция Pro.';

  @override
  String get rfSeverityDescGreen => 'Ваши показатели в норме. Так держать!';

  @override
  String get rfSeverityDescOrange =>
      'Несколько показателей отклонены. Обратитесь к врачу скоро.';

  @override
  String get rfSeverityDescRed =>
      'Обнаружены критические показатели. Рекомендована немедленная медицинская помощь.';

  @override
  String get rfSeverityDescYellow =>
      'Некоторые показатели слегка за пределами нормы. Наблюдайте.';

  @override
  String get rfSeverityOrange => 'Оранжевый';

  @override
  String get rfSeverityRed => 'Красный';

  @override
  String get rfSeverityTitleGreen => 'Всё в порядке';

  @override
  String get rfSeverityTitleOrange => 'Повышенный риск';

  @override
  String get rfSeverityTitleRed => 'Действуйте немедленно';

  @override
  String get rfSeverityTitleYellow => 'Лёгкое отклонение';

  @override
  String get rfSeverityYellow => 'Жёлтый';

  @override
  String get rfSourceManual => 'Вручную';

  @override
  String get rfSourceObservation => 'Наблюдение';

  @override
  String get rfSourcePain => 'Боль';

  @override
  String get rfSourceSymptomCheck => 'Проверка симптомов';

  @override
  String get rfSourceTimeline => 'Задача временной шкалы';

  @override
  String get rfSourceVitals => 'Жизненные показатели';

  @override
  String get rfSourceWarningCheck => 'Проверка предупреждений';

  @override
  String get rfSourceWound => 'Данные о ране';

  @override
  String get rfStatusAcknowledged => 'Просмотрен';

  @override
  String get rfStatusEscalated => 'Эскалирован';

  @override
  String get rfStatusMonitoring => 'Наблюдение';

  @override
  String get rfStatusOpen => 'Открыт';

  @override
  String get rfStatusResolved => 'Решён';

  @override
  String get rfWarningCheckSubtitle =>
      'Быстрая проверка важнейших симптомов – занимает всего 30 секунд.';

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
  String get sectionSupplements => 'Добавки';

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
      'Постепенно увеличивать активность – прислушиваться к телу';

  @override
  String get templateFollowupActivityTitle => 'Увеличить нагрузку';

  @override
  String get templateFollowupDay14Subtitle => 'Второй контрольный осмотр';

  @override
  String get templateFollowupDay21Subtitle => 'Третий контрольный осмотр';

  @override
  String get templateFollowupDay28Subtitle =>
      'Заключительное обследование и выписка';

  @override
  String get templateFollowupDay28Title => 'Заключительный осмотр';

  @override
  String get templateFollowupDay7Subtitle => 'Контроль в клинике';

  @override
  String get templateFollowupDay7Title => 'Контрольный приём';

  @override
  String get templateFollowupScarCareSubtitle =>
      'Аккуратно наносить крем на рубец и наблюдать';

  @override
  String get templateFollowupScarCareTitle => 'Уход за рубцом';

  @override
  String get templateFollowupWeeklyCheckSubtitle =>
      'Оценить и задокументировать прогресс заживления';

  @override
  String get templateFollowupWeeklyCheckTitle => 'Еженедельная самопроверка';

  @override
  String get templateFollowupWoundPhotoSubtitle =>
      'Продолжать документировать заживление';

  @override
  String get templateFollowupWoundPhotoTitle => 'Сфотографировать рану';

  @override
  String get templateMedsEveningSubtitle => 'Вечерняя доза по плану';

  @override
  String get templateMedsMiddaySubtitle => 'Дневная доза по плану';

  @override
  String get templateMedsMorningSubtitle => 'Утренняя доза по плану';

  @override
  String get templateMedsMorningTitle => 'Принять лекарство';

  @override
  String get templateOpdayAdmissionSubtitle =>
      'Пожалуйста, явитесь в клинику вовремя';

  @override
  String get templateOpdayAdmissionTitle => 'Госпитализация';

  @override
  String get templateOpdayFastingSubtitle =>
      'Не есть и не пить согласно указаниям';

  @override
  String get templateOpdayFastingTitle => 'Проверить голодание';

  @override
  String get templateOpdayInfoSubtitle =>
      'Уточнить открытые вопросы с командой';

  @override
  String get templateOpdayInfoTitle => 'Подтвердить информацию об операции';

  @override
  String get templateOpdayMobilizationSubtitle =>
      'Сесть/встать с помощью ненадолго';

  @override
  String get templateOpdayMobilizationTitle => 'Первая мобилизация';

  @override
  String get templatePreopBagSubtitle =>
      'Упаковать документы, одежду и зарядку';

  @override
  String get templatePreopBagTitle => 'Собрать сумку в клинику';

  @override
  String get templatePreopCompanionSubtitle =>
      'Согласовать поездку и место встречи';

  @override
  String get templatePreopCompanionTitle => 'Сообщить сопровождающему';

  @override
  String get templatePreopDocumentsSubtitle =>
      'Подготовить страховой полис и результаты';

  @override
  String get templatePreopDocumentsTitle => 'Проверить документы';

  @override
  String get templateWeek1AbdominalSupportSubtitle =>
      'Проверить посадку и способ ношения';

  @override
  String get templateWeek1AbdominalSupportTitle => 'Проверить бандаж/поддержку';

  @override
  String get templateWeek1BackPostureSubtitle =>
      'Не скручивать и не сгибать позвоночник';

  @override
  String get templateWeek1BackPostureTitle => 'Щадящая поза для спины';

  @override
  String get templateWeek1BloodPressureSubtitle =>
      'Записывать значения утром и вечером';

  @override
  String get templateWeek1BloodPressureTitle => 'Измерить давление';

  @override
  String get templateWeek1BowelDiarySubtitle =>
      'Следить за пищеварением – важно для восстановления питания';

  @override
  String get templateWeek1BowelDiaryTitle => 'Документировать стул';

  @override
  String get templateWeek1BreathingCardioSubtitle =>
      'Глубокое дыхание для лёгких – особенно важно после кардиохирургии';

  @override
  String get templateWeek1BreathingCardioTitle => 'Дыхательные упражнения';

  @override
  String get templateWeek1BreathingSpineSubtitle =>
      'Глубокое дыхание – спина прямо, дышать мягко';

  @override
  String get templateWeek1BreathingSpineTitle => 'Дыхательные упражнения';

  @override
  String get templateWeek1CardiacRehabSubtitle =>
      'Лёгкая ходьба, постепенно восстанавливать кровообращение';

  @override
  String get templateWeek1CardiacRehabTitle => 'Кардиореабилитация';

  @override
  String get templateWeek1CompressionSubtitle =>
      'Проверить посадку и состояние чулок';

  @override
  String get templateWeek1CompressionTitle => 'Проверить компрессионные чулки';

  @override
  String get templateWeek1DietBuildupSubtitle =>
      'Лёгкая пища, щадящая диета → постепенно увеличивать';

  @override
  String get templateWeek1DietBuildupTitle => 'Восстановление питания';

  @override
  String get templateWeek1DressingSubtitle =>
      'Проверить и задокументировать состояние повязки';

  @override
  String get templateWeek1DressingTitle => 'Проверка повязки';

  @override
  String get templateWeek1HydrationSubtitle =>
      'Минимум 1,5 литра жидкости в день';

  @override
  String get templateWeek1HydrationTitle => 'Проверить потребление жидкости';

  @override
  String get templateWeek1JointRomSubtitle =>
      'Осторожно проверить сгибание и разгибание';

  @override
  String get templateWeek1JointRomTitle => 'Проверить подвижность сустава';

  @override
  String get templateWeek1LegExercisesSubtitle =>
      'Круговые движения стопами, напряжение ног – профилактика тромбоза';

  @override
  String get templateWeek1LegExercisesTitle => 'Упражнения для ног';

  @override
  String get templateWeek1MobilizationSubtitle =>
      'Двигаться медленно – даже маленькие шаги важны';

  @override
  String get templateWeek1MobilizationTitle => 'Встать и подвигаться';

  @override
  String get templateWeek1NoStrainingSubtitle =>
      'Не тужиться, вставать перекатом на бок';

  @override
  String get templateWeek1NoStrainingTitle => 'Щадящий режим для пресса';

  @override
  String get templateWeek1OrthosisSubtitle =>
      'Проверить посадку и время ношения';

  @override
  String get templateWeek1OrthosisTitle => 'Проверить ортез/корсет';

  @override
  String get templateWeek1PainScoreSubtitle =>
      'Ввести уровень боли в приложение';

  @override
  String get templateWeek1PainScoreTitle => 'Записать уровень боли';

  @override
  String get templateWeek1RedFlagsSubtitle =>
      'Температура, покраснение, отёк, сильная боль?';

  @override
  String get templateWeek1RedFlagsTitle => 'Проверить тревожные признаки';

  @override
  String get templateWeek1SpineStabilizationSubtitle =>
      'Стабилизация корпуса по инструкции – постепенно увеличивать';

  @override
  String get templateWeek1SpineStabilizationTitle =>
      'Упражнения на стабилизацию';

  @override
  String get templateWeek1SternumSubtitle =>
      'Не поднимать более 5 кг, руки прижать к телу';

  @override
  String get templateWeek1SternumTitle => 'Щадящий режим для грудины';

  @override
  String get templateWeek1VitalsSubtitle => 'Кратко записать пульс/температуру';

  @override
  String get templateWeek1VitalsTitle => 'Проверить показатели';

  @override
  String get templateWeek1WoundPhotoSubtitle =>
      'Сфотографировать для отслеживания';

  @override
  String get templateWeek1WoundPhotoTitle => 'Сфотографировать рану';

  @override
  String get templateWeek2CardiacWalkSubtitle =>
      'Постепенно увеличивать дистанцию, следить за пульсом';

  @override
  String get templateWeek2CardiacWalkTitle => 'Прогулка кардиореабилитации';

  @override
  String get templateWeek2DietNormalizeSubtitle =>
      'Следить за пищеварением – постепенно переходить к обычному питанию';

  @override
  String get templateWeek2DietNormalizeTitle =>
      'Восстановление обычного питания';

  @override
  String get templateWeek2GaitSubtitle =>
      'Тренировать безопасную ходьбу с/без вспомогательных средств';

  @override
  String get templateWeek2GaitTitle => 'Тренировка ходьбы';

  @override
  String get templateWeek2PainSubtitle =>
      'Записывать динамику боли – становится лучше?';

  @override
  String get templateWeek2PainTitle => 'Дневник боли';

  @override
  String get templateWeek2PhysioSubtitle =>
      'Выполнять упражнения по инструкции';

  @override
  String get templateWeek2PhysioTitle => 'Упражнения физиотерапии';

  @override
  String get templateWeek2WalkSubtitle =>
      'Каждый день ходить чуть дальше – укреплять кровообращение';

  @override
  String get templateWeek2WalkTitle => 'Прогулка';

  @override
  String get templateWeek2WoundObserveSubtitle =>
      'Контролировать и документировать заживление';

  @override
  String get templateWeek2WoundObserveTitle => 'Наблюдать за раной';

  @override
  String get templateWeek1SymptomCheckSubtitle =>
      'Как вы себя чувствуете сегодня? Проверьте и задокументируйте симптомы';

  @override
  String get templateWeek1SymptomCheckTitle => 'Проверка симптомов';

  @override
  String get termineNaechste14Tage => 'Termine nächste 14 Tage';

  @override
  String get testBenachrichtigungErstellen => 'Testbenachrichtigung erstellen';

  @override
  String get ticketChatNachrichtSchreiben => 'Nachricht schreiben…';

  @override
  String get ticketErstellen => 'Ticket erstellen';

  @override
  String get timelineAddNoteContent => 'Содержание (необязательно)';

  @override
  String get timelineAddTaskDescription => 'Описание (необязательно)';

  @override
  String get timelineAddTaskTitle => 'Заголовок';

  @override
  String get timelineBesserOrganisieren => 'Timeline besser organisieren';

  @override
  String get timelineDue => 'Срочно';

  @override
  String get timelineFriday => 'Пятница';

  @override
  String get timelineMonday => 'Понедельник';

  @override
  String get timelineMyPlan => 'Мой план';

  @override
  String get timelineNoOpenTasks => 'Нет открытых задач на сегодня';

  @override
  String get timelinePhaseDefault => 'Фаза';

  @override
  String get timelinePhaseFollowup => 'Контрольный осмотр';

  @override
  String get timelinePhaseOpday => 'День операции';

  @override
  String get timelinePhasePersonal => 'Мои записи';

  @override
  String get timelinePhasePreop => 'Подготовка';

  @override
  String get timelinePhaseWeek1 => 'Неделя 1 · Заживление и контроль';

  @override
  String get timelinePhaseWeek2 => 'Неделя 2 · Активизация';

  @override
  String get timelinePlanComplete => 'Ваш план полностью выполнен';

  @override
  String get timelineRouteAppointment => 'Добавить приём';

  @override
  String get timelineRouteAppointmentDesc =>
      'Создавайте и управляйте приёмами, связанными с операцией.';

  @override
  String get timelineRouteDocuments => 'Загрузить документы';

  @override
  String get timelineRouteMedication => 'Лекарства';

  @override
  String get timelineRouteMoodLog => 'Дневник настроения';

  @override
  String get timelineRouteMoodLogDesc =>
      'Отслеживайте настроение и выявляйте закономерности в эмоциональном состоянии.';

  @override
  String get timelineRouteNoteAdd => 'Создать заметку';

  @override
  String get timelineRouteNoteAddDesc =>
      'Добавьте произвольную запись на вашу шкалу времени.';

  @override
  String get timelineRouteNutrition => 'Дневник питания';

  @override
  String get timelineRouteNutritionDesc =>
      'Фиксируйте приёмы пищи и получайте рекомендации по питанию.';

  @override
  String get timelineRoutePainLog => 'Дневник боли';

  @override
  String get timelineRoutePainLogDesc =>
      'Фиксируйте уровень боли по шкале от 1 до 10.';

  @override
  String get timelineRouteQuestions => 'Вопросы и заметки';

  @override
  String get timelineRouteQuestionsDesc =>
      'Записывайте вопросы к хирургу и личные заметки.';

  @override
  String get timelineRouteRedFlag => 'Панель экстренных сигналов';

  @override
  String get timelineRouteRedFlagDesc =>
      'Проверьте активные предупреждения и экстренные действия.';

  @override
  String get timelineRouteRehab => 'Реабилитация';

  @override
  String get timelineRouteRehabDesc =>
      'Открывает обзор реабилитации с упражнениями и прогрессом.';

  @override
  String get timelineRouteSleepLog => 'Дневник сна';

  @override
  String get timelineRouteSleepLogDesc =>
      'Фиксируйте продолжительность и качество сна.';

  @override
  String get timelineRoutesNotizErstellen854 => 'Notiz erstellen';

  @override
  String get timelineRouteSymptomCheck => 'Проверка симптомов';

  @override
  String get timelineRouteTaskAdd => 'Добавить задачу';

  @override
  String get timelineRouteTaskAddDesc =>
      'Создайте свою задачу для подготовки к операции.';

  @override
  String get timelineRouteTransport => 'Транспорт';

  @override
  String get timelineRouteTransportDesc =>
      'Спланируйте поездку в клинику и обратно.';

  @override
  String get timelineRouteVitals => 'Показатели здоровья';

  @override
  String get timelineRouteWoundDoc => 'Документация раны';

  @override
  String get timelineSaturday => 'Суббота';

  @override
  String get timelineSheetDocUpload => 'Загрузить документ';

  @override
  String get timelineSheetPainLevel => 'Уровень боли';

  @override
  String get timelineSheetWoundPhoto => 'Фото раны';

  @override
  String get timelineSunday => 'Воскресенье';

  @override
  String get timelineThursday => 'Четверг';

  @override
  String get timelineToday => 'Сегодня';

  @override
  String get timelineTomorrow => 'Завтра';

  @override
  String get timelineTransportDriver => 'Водитель';

  @override
  String get timelineTransportHint =>
      'Спланируйте поездку в клинику и обратно.';

  @override
  String get timelineTransportNotes => 'Заметки';

  @override
  String get timelineTransportOutbound =>
      'Поездка туда (время / место встречи)';

  @override
  String get timelineTransportReturn =>
      'Поездка обратно (время / место встречи)';

  @override
  String get timelineTuesday => 'Вторник';

  @override
  String get timelineVerknuepfung => 'Timeline-Verknüpfung';

  @override
  String get timelineViewFullPlan => 'Посмотреть весь план';

  @override
  String get timelineWednesday => 'Среда';

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
  String get warnCall112 => 'Позвонить 112';

  @override
  String get warnCheckLabel => 'Быстрая проверка:';

  @override
  String get warnContactClinic => 'Свяжитесь с клиникой при этих признаках:';

  @override
  String get warnEmergencySubtitle => 'При угрожающих жизни симптомах!';

  @override
  String get warnEmergencyTitle => 'Экстренный случай?';

  @override
  String get warnItemBleedingQ1 =>
      'Кровотечение активное и не останавливается?';

  @override
  String get warnItemBleedingQ2 => 'Повязка уже полностью пропитана?';

  @override
  String get warnItemBleedingQ3 => 'Чувствуете головокружение или слабость?';

  @override
  String get warnItemBleedingSubtitle => 'Кровь быстро пропитывает повязку';

  @override
  String get warnItemBleedingTitle => 'Сильное кровотечение';

  @override
  String get warnItemBreathQ1 => 'Одышка возникает в покое?';

  @override
  String get warnItemBreathQ2 => 'Одышка усиливается?';

  @override
  String get warnItemBreathQ3 => 'Есть боль при дыхании?';

  @override
  String get warnItemBreathSubtitle =>
      'Нехватка воздуха или затруднённое дыхание';

  @override
  String get warnItemBreathTitle => 'Одышка';

  @override
  String get warnItemFeverQ1 => 'Вы измерили температуру?';

  @override
  String get warnItemFeverQ2 => 'Температура выше 38,5 °C?';

  @override
  String get warnItemFeverQ3 => 'Есть озноб?';

  @override
  String get warnItemFeverSubtitle => 'Температура выше 38,5 °C';

  @override
  String get warnItemFeverTitle => 'Высокая температура';

  @override
  String get warnItemPainQ1 => 'Боль значительно сильнее, чем обычно?';

  @override
  String get warnItemPainQ2 => 'Обычные обезболивающие больше не помогают?';

  @override
  String get warnItemPainQ3 => 'Область боли опухла или горячая?';

  @override
  String get warnItemPainSubtitle => 'Внезапно усиливающаяся, неконтролируемая';

  @override
  String get warnItemPainTitle => 'Сильная боль';

  @override
  String get warnItemRednessQ1 => 'Покраснение распространяется?';

  @override
  String get warnItemRednessQ2 => 'Место тёплое или горячее?';

  @override
  String get warnItemRednessQ3 => 'Есть гной или выделения?';

  @override
  String get warnItemRednessSubtitle => 'Область раны выглядит воспалённой';

  @override
  String get warnItemRednessTitle => 'Нарастающее покраснение / отёк';

  @override
  String get warnItemSmellQ1 => 'Выделения имеют необычный цвет?';

  @override
  String get warnItemSmellQ2 => 'От раны отчётливо неприятный запах?';

  @override
  String get warnItemSmellQ3 => 'Объём выделений увеличился?';

  @override
  String get warnItemSmellSubtitle => 'Необычные выделения из раны';

  @override
  String get warnItemSmellTitle => 'Зловонные выделения';

  @override
  String get warnSaveCheck => 'Сохранить проверку';

  @override
  String get warnTitle => 'Предупреждения';

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
  String get weekdayShortFri => 'Пт';

  @override
  String get weekdayShortMon => 'Пн';

  @override
  String get weekdayShortSat => 'Сб';

  @override
  String get weekdayShortSun => 'Вс';

  @override
  String get weekdayShortThu => 'Чт';

  @override
  String get weekdayShortTue => 'Вт';

  @override
  String get weekdayShortWed => 'Ср';

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
      other: '$count записей',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
  }

  @override
  String apptCreatedBy(String name) {
    return 'Создано $name';
  }

  @override
  String apptDeleteContent(String title) {
    return 'Вы действительно хотите навсегда удалить «$title»?';
  }

  @override
  String apptReminderMinutes(int minutes) {
    return 'За $minutes минут';
  }

  @override
  String apptRepeatUntilDate(String date) {
    return '(до $date)';
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
    return '$label — отменено';
  }

  @override
  String bellaActionStatusCreated(String label) {
    return '$label — создано';
  }

  @override
  String bellaActionStatusFailed(String label) {
    return '$label — ошибка';
  }

  @override
  String bellaBriefingHttpError(int statusCode) {
    return 'Ошибка создания брифинга (HTTP $statusCode).';
  }

  @override
  String bellaDailyUsage(int used, int limit) {
    return '$used / $limit сообщений сегодня';
  }

  @override
  String bellaProactiveDocGap(int days) {
    return 'Вы ничего не документировали $days дней';
  }

  @override
  String bellaProactiveMedReminder(String name) {
    return 'Вы принимали $name сегодня?';
  }

  @override
  String bellaProactiveMedReminderMultiple(int count) {
    return 'Вы принимали лекарства сегодня? ($count осталось)';
  }

  @override
  String bellaProactiveOpenTasks(int count) {
    return 'У вас ещё $count открытых задач на сегодня';
  }

  @override
  String bellaProactiveStreakAtRisk(int streak) {
    return 'Ваша серия из $streak дней под угрозой!';
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
    return 'Partner-Anzeigen ($count)';
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
    return '$count активных';
  }

  @override
  String rfActiveCount(int count) {
    return 'Активных ($count)';
  }

  @override
  String rfLevelBadge(String level) {
    return 'Уровень: $level';
  }

  @override
  String rfResolvedCount(int count) {
    return 'История ($count)';
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
    return '$done/$total выполнено';
  }

  @override
  String timelineDueAttention(int count) {
    return '$count требуют внимания сегодня';
  }

  @override
  String timelineNextUp(String title) {
    return 'Далее: $title';
  }

  @override
  String timelinePhaseProgress(int done, int total) {
    return '$done/$total выполнено';
  }

  @override
  String timelineProgressPercent(int percent) {
    return '$percent% выполнено – продолжайте!';
  }

  @override
  String timelineStickyDoneOfTotal(int done, int total) {
    return '$done из $total выполнено';
  }

  @override
  String timelineStickyDue(int count) {
    return '$count просрочено';
  }

  @override
  String timelineStickyToday(int count) {
    return '$count сегодня';
  }

  @override
  String timelineStreakDays(int count) {
    return '$count дней';
  }

  @override
  String timelineTasksPlanned(int count) {
    return '$count задач запланировано на сегодня';
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
    return 'Последняя проверка: $label · $date';
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
  String get apptAllDay => 'Весь день';

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
  String get timelineTransportTitle => 'Планирование транспорта';

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
  String get rtsTitle => 'Тест возвращения в спорт';

  @override
  String get rtsNewAssessment => 'Начать новый тест';

  @override
  String get rtsLatestResult => 'Последний результат';

  @override
  String get rtsHistory => 'История тестов';

  @override
  String get rtsScore => 'Общий балл';

  @override
  String get rtsCleared => 'Допущен ✓';

  @override
  String get rtsAlmostReady => 'Почти готов';

  @override
  String get rtsNotReady => 'Ещё не готов';

  @override
  String get rtsClearedMessage =>
      'Ваш балл превышает порог. Вы можете вернуться к спорту – предварительно проконсультируйтесь с врачом.';

  @override
  String get rtsAlmostReadyMessage =>
      'Вы хорошо прогрессируете. Продолжайте тренировки и пройдите тест через несколько недель.';

  @override
  String get rtsNotReadyMessage =>
      'Вашему организму нужно больше времени. Сосредоточьтесь на реабилитации.';

  @override
  String get rtsEmptyTitle => 'Готовы вернуться в спорт?';

  @override
  String get rtsEmptySubtitle =>
      'Start your first fitness test. Instead of arbitrary time rules, measure strength, balance, and stability.';

  @override
  String get rtsAssessmentTitle => 'Фитнес-тест';

  @override
  String get rtsResultTitle => 'Результат теста';

  @override
  String get rtsBreakdown => 'Индивидуальные результаты';

  @override
  String get rtsFinishAssessment => 'Вычислить балл';

  @override
  String get rtsDeleteTitle => 'Удалить тест';

  @override
  String get rtsDeleteConfirm => 'Этот результат будет удалён невозвратно.';

  @override
  String get rtsValidationHint =>
      'Пожалуйста, заполните все обязательные поля.';

  @override
  String get rtsNotesLabel => 'Заметка (необязательно)';

  @override
  String get rtsNotesHint => 'Например: самочувствие, условия …';

  @override
  String rtsStepOf(String current, String total) {
    return 'Шаг $current/$total';
  }

  @override
  String get rtsTestLsiTitle => 'Симметрия конечностей (LSI)';

  @override
  String get rtsTestLsiDesc =>
      'Сравните показатели поражённой стороны со здоровой.';

  @override
  String get rtsTestLsiHint => 'LSI ≥ 90% — рекомендуемый порог допуска.';

  @override
  String get rtsLsiSeconds => 'Секунды';

  @override
  String get rtsLsiReps => 'Повторения';

  @override
  String rtsLsiAffected(String unit) {
    return 'Пораженная сторона ($unit)';
  }

  @override
  String rtsLsiHealthy(String unit) {
    return 'Здоровая сторона ($unit)';
  }

  @override
  String rtsLsiDetailValue(
    String affected,
    String healthy,
    String unit,
    String percent,
  ) {
    return 'Пораж.: $affected $unit / Здор.: $healthy $unit → LSI: $percent';
  }

  @override
  String get rtsTestBalanceTitle => 'Баланс на одной ноге';

  @override
  String get rtsTestBalanceDesc =>
      'Стойте на поражённой ноге как можно дольше.';

  @override
  String get rtsTestBalanceHint => '30 секунд = максимальный балл.';

  @override
  String get rtsBalanceSeconds => 'Время удержания (секунд)';

  @override
  String rtsBalanceDetailValue(String seconds) {
    return '$seconds секунд';
  }

  @override
  String get rtsTestStabilityTitle => 'Стабильность (приседания на одной ноге)';

  @override
  String get rtsTestStabilityDesc =>
      'Насколько хорошо вы можете выполнить приседания на одной ноге?';

  @override
  String get rtsStability1 => '1 — Невозможно, сильная боль.';

  @override
  String get rtsStability2 => '2 — С трудом, значительные ограничения.';

  @override
  String get rtsStability3 => '3 — Возможно с компенсациями.';

  @override
  String get rtsStability4 => '4 — Почти нормально.';

  @override
  String get rtsStability5 => '5 — Полный контроль, без боли.';

  @override
  String rtsStabilityDetailValue(String rating) {
    return 'Самооценка: $rating / 5';
  }

  @override
  String get rtsTestPainTitle => 'Боль при нагрузке';

  @override
  String get rtsTestPainDesc =>
      'Насколько сильна боль ю во время спортивных активностей? Оцените по шкале 0–10.';

  @override
  String get rtsPainNoKein => '0 — Без боли';

  @override
  String get rtsPainSevere => '10 — Максимальная боль';

  @override
  String rtsPainDetailValue(String level) {
    return 'NRS: $level / 10';
  }

  @override
  String get rtsSportTypeTitle => 'Вид спорта';

  @override
  String get rtsSportTypeDesc => 'К какому виду спорта вы хотите вернуться?';

  @override
  String get rtsSportRunning => 'Бег';

  @override
  String get rtsSportSoccer => 'Футбол / Командные виды';

  @override
  String get rtsSportStrength => 'Силовые тренировки';

  @override
  String get rtsSportCycling => 'Велоспорт';

  @override
  String get rtsSportSwimming => 'Плавание';

  @override
  String get rtsSportMartialArts => 'Единоборства';

  @override
  String get rtsSportOther => 'Другое';

  @override
  String get rtsTestHopTitle => 'Прыжок на одной ноге (Hop-Test)';

  @override
  String get rtsTestHopDesc =>
      'Прыгните как можно дальше на повреждённой ноге и измерьте расстояние. Повторите на здоровой стороне.';

  @override
  String get rtsTestHopHint =>
      'Выполните 3 попытки и запишите лучший результат. LSI ≥ 90 % — оптимальный порог для возврата к спорту.';

  @override
  String get rtsHopAffected => 'Пострадавшая сторона (см)';

  @override
  String get rtsHopHealthy => 'Здоровая сторона (см)';

  @override
  String rtsHopDetailValue(String affected, String healthy, String percent) {
    return 'Поврежд.: $affected см / Здоров.: $healthy см → LSI: $percent';
  }

  @override
  String get rtsTestTugTitle => 'Тест «Встань и иди» (TUG)';

  @override
  String get rtsTestTugDesc =>
      'Встаньте со стула, пройдите 3 метра, вернитесь и сядьте. Измерьте общее время.';

  @override
  String get rtsTestTugHint =>
      'Используйте секундомер или введите время вручную. Менее 10 секунд — отличный результат.';

  @override
  String rtsTugDetailValue(String seconds) {
    return '$seconds секунд';
  }

  @override
  String get rtsTimerStart => 'Запустить секундомер';

  @override
  String get rtsTimerStop => 'Остановить';

  @override
  String get rtsTimerReset => 'Сбросить';

  @override
  String get rtsTimerRestart => 'Перезапустить';

  @override
  String get rtsTimerOrManual => 'Или введите вручную:';

  @override
  String get rtsTimerManualLabel => 'Время в секундах';

  @override
  String get rtsScoreTrend => 'Динамика счёта';

  @override
  String get supplementAddNew => 'Добавить добавку';

  @override
  String get supplementEdit => 'Редактировать добавку';

  @override
  String get supplementName => 'Название';

  @override
  String get supplementBrand => 'Бренд (необязательно)';

  @override
  String get supplementDose => 'Доза (напр. 1000 МЕ)';

  @override
  String get supplementCategoryLabel => 'Категория';

  @override
  String get supplementCategoryVitamine => 'Витамины';

  @override
  String get supplementCategoryMineralien => 'Минералы';

  @override
  String get supplementCategoryAminosaeuren => 'Аминокислоты';

  @override
  String get supplementCategoryKraeuter => 'Травы и растения';

  @override
  String get supplementCategoryProbiotika => 'Пробиотики';

  @override
  String get supplementCategoryFettsaeuren => 'Жирные кислоты';

  @override
  String get supplementCategoryProteine => 'Белки';

  @override
  String get supplementCategorySonstiges => 'Другое';

  @override
  String get supplementTimeSlots => 'Время приёма';

  @override
  String get supplementSave => 'Сохранить';

  @override
  String get supplementTabToday => 'Сегодня';

  @override
  String get supplementTabMine => 'Мои добавки';

  @override
  String get supplementTabRecommendations => 'Рекомендации';

  @override
  String get supplementTodayProgress => 'Приём за сегодня';

  @override
  String get supplementTodayHistory => 'Сегодняшние приёмы';

  @override
  String get supplementLogSuccess => 'Приём сохранён ✓';

  @override
  String get supplementLogManual => 'Ввести вручную';

  @override
  String get supplementStockLow => 'Запас на исходе';

  @override
  String get supplementStockEmpty => 'Запас исчерпан';

  @override
  String get supplementEmptyState =>
      'Добавок пока нет.\nНажмите + чтобы начать.';

  @override
  String get supplementDeleteTitle => 'Удалить добавку?';

  @override
  String get supplementDeleteBody =>
      'Вы действительно хотите удалить эту добавку?';

  @override
  String get supplementDoseGuidance => 'Рекомендация по дозировке';

  @override
  String get supplementNoRecommendations => 'Нет доступных рекомендаций';

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
  String get statusActive => 'Активен';

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
  String get actionActivate => 'активировать';

  @override
  String get actionDeactivate => 'деактивировать';

  @override
  String staffCountLabel(int count) {
    return 'Сотрудники ($count)';
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
  String get passwordMin8Chars => 'Минимум 8 символов.';

  @override
  String staffConfirmActivateBody(String name) {
    return 'Хотите снова активировать $name? Вход снова станет возможным.';
  }

  @override
  String staffConfirmDeactivateBody(String name) {
    return 'Хотите деактивировать $name? Вход будет заблокирован.';
  }

  @override
  String staffWasActivated(String name) {
    return '$name активирован(а)';
  }

  @override
  String staffWasDeactivated(String name) {
    return '$name деактивирован(а)';
  }

  @override
  String staffRemoveConfirmBody(String name) {
    return 'Вы действительно хотите удалить $name? Доступ будет немедленно отозван, а аккаунт деактивирован.';
  }

  @override
  String get teamHeader => 'Команда';

  @override
  String get staffLoadError => 'Ошибка загрузки сотрудников.';

  @override
  String get statusDisabled => 'Отключён';

  @override
  String get noStaffYetTitle => 'Сотрудников пока нет';

  @override
  String get noStaffYetSubtitle =>
      'Создайте учётные записи сотрудников для вашей команды.';

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

  @override
  String get bellaChipDoctorCreateTask => 'Aufgabe für Patient erstellen';

  @override
  String get bellaChipDoctorCreateRedFlag => 'Warnung für Patient erstellen';

  @override
  String get bellaChipOrgBroadcast => 'Nachricht an alle Patienten senden';

  @override
  String get bellaChipStaffCreateTask => 'Aufgabe für Patient erstellen';

  @override
  String get bellaChipStaffLogVital => 'Vitalwerte für Patient eintragen';

  @override
  String get orgManagedByOrg => 'Wird von Ihrer Organisation verwaltet';

  @override
  String get orgManagedByOrgHint =>
      'Diese Einstellungen werden zentral von Ihrer Organisation gepflegt.';

  @override
  String get orgProfileEdit => 'Profil bearbeiten';

  @override
  String get orgProfileSaved => 'Organisationsprofil gespeichert';

  @override
  String get orgProfileSaveError => 'Profil konnte nicht gespeichert werden';

  @override
  String get orgSettingsTitle => 'Verwaltung';

  @override
  String get orgSettingsDoctorManagement => 'Ärzteverwaltung';

  @override
  String get orgSettingsDoctorManagementDesc =>
      'Ärzte hinzufügen, entfernen und Zugriffsrechte verwalten';

  @override
  String get orgSettingsStaffManagement => 'Mitarbeiterverwaltung';

  @override
  String get orgSettingsStaffManagementDesc =>
      'Mitarbeiter verwalten und Berechtigungen zuweisen';

  @override
  String get orgSettingsPatientOverview => 'Patientenübersicht';

  @override
  String get orgSettingsPatientOverviewDesc =>
      'Alle Patienten der Organisation einsehen';

  @override
  String get orgSettingsInviteCodes => 'Einladungscodes';

  @override
  String get orgSettingsInviteCodesDesc =>
      'Einladungscodes für neue Ärzte verwalten';

  @override
  String get orgSettingsJoinRequests => 'Beitrittsanfragen';

  @override
  String get orgSettingsJoinRequestsDesc =>
      'Offene Anfragen von Ärzten prüfen und genehmigen';

  @override
  String get orgSettingsNotifications => 'Benachrichtigungen';

  @override
  String get orgSettingsNotificationsDesc =>
      'Benachrichtigungseinstellungen der Organisation';

  @override
  String get orgSettingsBilling => 'Abrechnung & Abonnement';

  @override
  String get orgSettingsBillingDesc =>
      'Pro-Status, Rechnungen und Abonnement verwalten';

  @override
  String get orgSettingsDataExport => 'Datenexport';

  @override
  String get orgSettingsDataExportDesc =>
      'Organisationsdaten zusammenstellen und exportieren';

  @override
  String get orgSettingsAppearance => 'Erscheinungsbild';

  @override
  String get orgSettingsAppearanceDesc =>
      'Logo und Darstellung der Organisation anpassen';

  @override
  String get orgSettingsOpeningHours => 'Öffnungszeiten';

  @override
  String get orgSettingsOpeningHoursDesc =>
      'Öffnungszeiten der Einrichtung festlegen';

  @override
  String get orgSettingsWebsite => 'Webseite';

  @override
  String get orgSettingsContactInfo => 'Kontaktdaten Ihrer Organisation';

  @override
  String get orgSettingsGeneralInfo => 'Allgemeine Informationen';

  @override
  String get orgSettingsDangerZone => 'Gefahrenzone';

  @override
  String get orgSettingsDeleteOrg => 'Organisation löschen';

  @override
  String get orgSettingsDeleteOrgDesc =>
      'Organisation und alle zugehörigen Daten unwiderruflich löschen';

  @override
  String orgDoctorCount(int count) {
    return '$count Ärzte';
  }

  @override
  String orgStaffCount(int count) {
    return '$count Mitarbeiter';
  }

  @override
  String orgPatientCount(int count) {
    return '$count Patienten';
  }

  @override
  String orgPendingRequests(int count) {
    return '$count offene Anfragen';
  }

  @override
  String get orgQuickActions => 'Schnellaktionen';

  @override
  String get orgManagementSection => 'Organisation verwalten';

  @override
  String get orgSecuritySection => 'Sicherheit & Daten';

  @override
  String get orgSaveChanges => 'Änderungen speichern';
}
