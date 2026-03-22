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
  String get tutorialStep1Title => 'Добро пожаловать';

  @override
  String get tutorialStep1Desc =>
      'Здесь вы найдёте всю важную информацию о вашей операции.';

  @override
  String get tutorialStep2Title => 'Записи';

  @override
  String get tutorialStep2Desc =>
      'Управляйте записями к врачу и подготовкой к операции.';

  @override
  String get tutorialStep3Title => 'Чек-листы';

  @override
  String get tutorialStep3Desc => 'Выполняйте личные задачи шаг за шагом.';

  @override
  String get tutorialStep4Title => 'Узнайте больше';

  @override
  String get tutorialStep4Desc =>
      'В разделе \'Ещё\' вы найдёте настройки, помощь и дополнительные функции.';

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
}
