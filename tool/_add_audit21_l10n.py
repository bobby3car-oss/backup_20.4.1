#!/usr/bin/env python3
"""Add missing l10n keys found in audit session 21."""

import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N = os.path.join(ROOT, 'lib', 'l10n')

# ── New keys per locale ──────────────────────────────────────────────────────

NEW_DE = {
  "notifSettingsTitle": "Benachrichtigungen",
  "notifCenter": "Benachrichtigungszentrale",
  "notifCenterSubtitle": "Alle Benachrichtigungen anzeigen",
  "notifCategories": "Kategorien",
  "notifGlobalEnabled": "Benachrichtigungen aktiv",
  "notifGlobalDisabled": "Alle deaktiviert",
  "notifActiveCount": "{active} von {total} Kategorien aktiv",
  "@notifActiveCount": {
    "placeholders": {
      "active": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "notifCatTasks": "Aufgaben & Timeline",
  "notifCatTasksSub": "Fällige und erledigte Aufgaben",
  "notifCatAppointments": "Termine",
  "notifCatAppointmentsSub": "Bevorstehende Arzt- und Kliniktermine",
  "notifCatMedication": "Medikamente",
  "notifCatMedicationSub": "Erinnerungen an Medikamenteneinnahme",
  "notifCatWounds": "Wundalarme",
  "notifCatWoundsSub": "Warnungen bei kritischen Wundkontroll-Ergebnissen",
  "notifCatObservations": "Beobachtungen",
  "notifCatObservationsSub": "Neue Beobachtungen von Ärzten & Begleitern",
  "notifCatSystem": "System",
  "notifCatSystemSub": "Updates, Pro-Status & App-Hinweise",

  "helpFaqTitle": "Häufig gestellte Fragen",
  "helpContactTitle": "Kontakt",
  "helpContactDesc": "Sie haben eine Frage, die hier nicht beantwortet wird? Erstellen Sie ein Ticket oder schreiben Sie uns eine E-Mail.",
  "helpEmailSubject": "Operationsbegleiter – Support-Anfrage",
  "helpFaq1Question": "Wie werden meine Daten gespeichert?",
  "helpFaq1Answer": "Ihre Daten werden lokal auf Ihrem Gerät und verschlüsselt in Google Firebase (Cloud Firestore) gespeichert. Der Zugriff ist auf Ihr Nutzerkonto beschränkt. Weitere Details finden Sie in der Datenschutzerklärung unter Einstellungen \u2192 Datenschutz.",
  "helpFaq2Question": "Wie kann ich mein Pro-Abo kündigen?",
  "helpFaq2Answer": "Das Pro-Abonnement wird über den App Store (Apple) bzw. Google Play Store verwaltet. Öffnen Sie dort Ihre Abo-Verwaltung und kündigen Sie das Abo mindestens 24 Stunden vor Ablauf der aktuellen Periode.",
  "helpFaq3Question": "Wie funktioniert die Wunddokumentation?",
  "helpFaq3Answer": "Öffnen Sie \u201eWunddokumentation\u201c im Hauptmenü oder der Timeline. Fotografieren Sie die Wunde mit der Kamera oder wählen Sie ein Bild aus der Galerie. Die Fotos werden chronologisch gespeichert und können über den Vergleichs-Modus nebeneinander angezeigt werden.",
  "helpFaq4Question": "Kann ich meinen Account löschen?",
  "helpFaq4Answer": "Ja. Gehen Sie zu Einstellungen \u2192 Daten \u2192 \u201eDaten zurücksetzen\u201c. Dort haben Sie die Möglichkeit, alle Daten zu löschen oder Ihren Account vollständig zu entfernen. Diese Aktion kann nicht rückgängig gemacht werden.",
  "helpFaq5Question": "Wer kann meine Gesundheitsdaten sehen?",
  "helpFaq5Answer": "Nur Sie und die Personen, denen Sie über die Einladungsfunktion Zugang gewährt haben (Arzt oder Angehörige). Niemand sonst hat Zugriff auf Ihre Daten.",
  "helpFaq6Question": "Was bedeuten die Warnstufen beim Symptom-Check?",
  "helpFaq6Answer": "🟢 Grün = unbedenklich, normale Genesungserscheinungen.\n🟡 Gelb = beobachten, beim nächsten Arzttermin ansprechen.\nRot = zeitnah ärztlichen Rat einholen.",

  "qrScanHint": "Richte die Kamera auf den QR-Code\\nder Einladung",

  "resetDialogContent": "Möchten Sie nur Ihre lokalen Gesundheitsdaten löschen oder Ihren gesamten Account dauerhaft entfernen?",
  "deleteDialogContent": "Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten werden unwiderruflich gelöscht.",
  "reauthHint": "Bitte melde dich ab und erneut an, dann versuche es nochmal.",
  "syncNever": "Noch nie synchronisiert",
  "syncJustNow": "Gerade eben",
  "syncMinutesAgo": "Vor {count} {count, plural, =1{Minute} other{Minuten}}",
  "@syncMinutesAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncHoursAgo": "Vor {count} {count, plural, =1{Stunde} other{Stunden}}",
  "@syncHoursAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncDaysAgo": "Vor {count} {count, plural, =1{Tag} other{Tagen}}",
  "@syncDaysAgo": {
    "placeholders": {"count": {"type": "int"}}
  },

  "profileTitle": "Profil",
  "opInformationTitle": "OP-Informationen",
  "healthSyncSectionTitle": "Health Sync",
  "subscriptionTitle": "Abonnement",
  "healthSyncNotSupported": "Health-Sync wird auf diesem Gerät nicht unterstützt.",
  "healthConnectRequired": "Bitte installiere Health Connect aus dem Play Store.",
  "healthPermissionDenied": "Berechtigung für Gesundheitsdaten wurde nicht erteilt.",
  "healthSyncCount": "{count} Messungen synchronisiert",
  "@healthSyncCount": {
    "placeholders": {"count": {"type": "int"}}
  },
  "profileYourProfile": "Dein Profil",
  "profileFullComplete": "Profil vollständig",
  "profilePercentComplete": "Profil {percent}% ausgefüllt",
  "@profilePercentComplete": {
    "placeholders": {"percent": {"type": "int"}}
  },
  "profileAgeYears": "{age} Jahre",
  "@profileAgeYears": {
    "placeholders": {"age": {"type": "int"}}
  },
  "profileOpIn": "OP in {days} T.",
  "@profileOpIn": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileOpToday": "OP heute",
  "profileOpAgo": "OP vor {days} T.",
  "@profileOpAgo": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileProMember": "Pro Mitglied",
  "profileUpgradePro": "Upgrade auf Pro",
  "profileVerified": "Verifiziert",

  "proActive": "Pro aktiv",
  "proManageSubscription": "Abo & Details verwalten",
  "proUnlockNow": "Jetzt freischalten",
}

NEW_EN = {
  "notifSettingsTitle": "Notifications",
  "notifCenter": "Notification Center",
  "notifCenterSubtitle": "Show all notifications",
  "notifCategories": "Categories",
  "notifGlobalEnabled": "Notifications active",
  "notifGlobalDisabled": "All disabled",
  "notifActiveCount": "{active} of {total} categories active",
  "@notifActiveCount": {
    "placeholders": {
      "active": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "notifCatTasks": "Tasks & Timeline",
  "notifCatTasksSub": "Due and completed tasks",
  "notifCatAppointments": "Appointments",
  "notifCatAppointmentsSub": "Upcoming doctor and clinic appointments",
  "notifCatMedication": "Medication",
  "notifCatMedicationSub": "Medication intake reminders",
  "notifCatWounds": "Wound Alerts",
  "notifCatWoundsSub": "Warnings for critical wound check results",
  "notifCatObservations": "Observations",
  "notifCatObservationsSub": "New observations from doctors & caregivers",
  "notifCatSystem": "System",
  "notifCatSystemSub": "Updates, Pro status & app notes",

  "helpFaqTitle": "Frequently Asked Questions",
  "helpContactTitle": "Contact",
  "helpContactDesc": "Have a question that isn't answered here? Create a ticket or send us an email.",
  "helpEmailSubject": "Operationsbegleiter – Support Request",
  "helpFaq1Question": "How is my data stored?",
  "helpFaq1Answer": "Your data is stored locally on your device and encrypted in Google Firebase (Cloud Firestore). Access is restricted to your user account. Further details can be found in the Privacy Policy under Settings \u2192 Privacy.",
  "helpFaq2Question": "How can I cancel my Pro subscription?",
  "helpFaq2Answer": "The Pro subscription is managed through the App Store (Apple) or Google Play Store. Open your subscription management there and cancel at least 24 hours before the end of the current period.",
  "helpFaq3Question": "How does wound documentation work?",
  "helpFaq3Answer": "Open 'Wound Documentation' in the main menu or timeline. Photograph the wound with the camera or select an image from the gallery. Photos are saved chronologically and can be displayed side by side in comparison mode.",
  "helpFaq4Question": "Can I delete my account?",
  "helpFaq4Answer": "Yes. Go to Settings \u2192 Data \u2192 'Reset Data'. There you can delete all data or permanently remove your account. This action cannot be undone.",
  "helpFaq5Question": "Who can see my health data?",
  "helpFaq5Answer": "Only you and the people you have granted access to via the invitation feature (doctor or family members). Nobody else has access to your data.",
  "helpFaq6Question": "What do the warning levels in the symptom check mean?",
  "helpFaq6Answer": "🟢 Green = harmless, normal recovery symptoms.\n🟡 Yellow = monitor, discuss at your next doctor's appointment.\nRed = seek medical advice promptly.",

  "qrScanHint": "Point the camera at the QR code\\nof the invitation",

  "resetDialogContent": "Would you like to delete only your local health data or permanently remove your entire account?",
  "deleteDialogContent": "This action cannot be undone. All your data will be permanently deleted.",
  "reauthHint": "Please sign out and sign in again, then try again.",
  "syncNever": "Never synced",
  "syncJustNow": "Just now",
  "syncMinutesAgo": "{count} {count, plural, =1{minute} other{minutes}} ago",
  "@syncMinutesAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncHoursAgo": "{count} {count, plural, =1{hour} other{hours}} ago",
  "@syncHoursAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncDaysAgo": "{count} {count, plural, =1{day} other{days}} ago",
  "@syncDaysAgo": {
    "placeholders": {"count": {"type": "int"}}
  },

  "profileTitle": "Profile",
  "opInformationTitle": "Surgery Information",
  "healthSyncSectionTitle": "Health Sync",
  "subscriptionTitle": "Subscription",
  "healthSyncNotSupported": "Health Sync is not supported on this device.",
  "healthConnectRequired": "Please install Health Connect from the Play Store.",
  "healthPermissionDenied": "Health data permission was not granted.",
  "healthSyncCount": "{count} measurements synced",
  "@healthSyncCount": {
    "placeholders": {"count": {"type": "int"}}
  },
  "profileYourProfile": "Your Profile",
  "profileFullComplete": "Profile complete",
  "profilePercentComplete": "Profile {percent}% complete",
  "@profilePercentComplete": {
    "placeholders": {"percent": {"type": "int"}}
  },
  "profileAgeYears": "{age} years",
  "@profileAgeYears": {
    "placeholders": {"age": {"type": "int"}}
  },
  "profileOpIn": "Surgery in {days} d.",
  "@profileOpIn": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileOpToday": "Surgery today",
  "profileOpAgo": "Surgery {days} d. ago",
  "@profileOpAgo": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileProMember": "Pro Member",
  "profileUpgradePro": "Upgrade to Pro",
  "profileVerified": "Verified",

  "proActive": "Pro active",
  "proManageSubscription": "Manage subscription & details",
  "proUnlockNow": "Unlock now",
}

NEW_RU = {
  "notifSettingsTitle": "Уведомления",
  "notifCenter": "Центр уведомлений",
  "notifCenterSubtitle": "Показать все уведомления",
  "notifCategories": "Категории",
  "notifGlobalEnabled": "Уведомления активны",
  "notifGlobalDisabled": "Все отключены",
  "notifActiveCount": "{active} из {total} категорий активны",
  "@notifActiveCount": {
    "placeholders": {
      "active": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "notifCatTasks": "Задачи и Timeline",
  "notifCatTasksSub": "Предстоящие и выполненные задачи",
  "notifCatAppointments": "Приёмы",
  "notifCatAppointmentsSub": "Предстоящие приёмы у врача и в клинике",
  "notifCatMedication": "Медикаменты",
  "notifCatMedicationSub": "Напоминания о приёме лекарств",
  "notifCatWounds": "Тревоги ран",
  "notifCatWoundsSub": "Предупреждения при критических результатах осмотра ран",
  "notifCatObservations": "Наблюдения",
  "notifCatObservationsSub": "Новые наблюдения от врачей и сопровождающих",
  "notifCatSystem": "Система",
  "notifCatSystemSub": "Обновления, Pro-статус и уведомления приложения",

  "helpFaqTitle": "Часто задаваемые вопросы",
  "helpContactTitle": "Контакт",
  "helpContactDesc": "У вас есть вопрос, на который здесь нет ответа? Создайте тикет или напишите нам по электронной почте.",
  "helpEmailSubject": "Operationsbegleiter – Запрос в поддержку",
  "helpFaq1Question": "Как хранятся мои данные?",
  "helpFaq1Answer": "Ваши данные хранятся локально на вашем устройстве и в зашифрованном виде в Google Firebase (Cloud Firestore). Доступ ограничен вашей учётной записью.",
  "helpFaq2Question": "Как отменить подписку Pro?",
  "helpFaq2Answer": "Подписка Pro управляется через App Store (Apple) или Google Play Store. Откройте управление подписками и отмените не менее чем за 24 часа до окончания текущего периода.",
  "helpFaq3Question": "Как работает документация ран?",
  "helpFaq3Answer": "Откройте «Документация ран» в главном меню или Timeline. Сфотографируйте рану камерой или выберите изображение из галереи. Фотографии сохраняются хронологически.",
  "helpFaq4Question": "Могу ли я удалить свой аккаунт?",
  "helpFaq4Answer": "Да. Перейдите в Настройки → Данные → «Сбросить данные». Там вы можете удалить все данные или полностью удалить свой аккаунт.",
  "helpFaq5Question": "Кто может видеть мои данные о здоровье?",
  "helpFaq5Answer": "Только вы и те, кому вы предоставили доступ через функцию приглашения (врач или родственники).",
  "helpFaq6Question": "Что означают уровни предупреждений при проверке симптомов?",
  "helpFaq6Answer": "🟢 Зелёный = безопасно, нормальные симптомы восстановления.\n🟡 Жёлтый = наблюдать, обсудить на следующем приёме.\nКрасный = обратиться к врачу.",

  "qrScanHint": "Наведите камеру на QR-код\\nприглашения",

  "resetDialogContent": "Хотите удалить только локальные данные о здоровье или полностью удалить свой аккаунт?",
  "deleteDialogContent": "Это действие нельзя отменить. Все ваши данные будут безвозвратно удалены.",
  "reauthHint": "Пожалуйста, выйдите и войдите снова, затем попробуйте ещё раз.",
  "syncNever": "Ещё не синхронизировалось",
  "syncJustNow": "Только что",
  "syncMinutesAgo": "{count} мин. назад",
  "@syncMinutesAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncHoursAgo": "{count} ч. назад",
  "@syncHoursAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncDaysAgo": "{count} дн. назад",
  "@syncDaysAgo": {
    "placeholders": {"count": {"type": "int"}}
  },

  "profileTitle": "Профиль",
  "opInformationTitle": "Информация об операции",
  "healthSyncSectionTitle": "Health Sync",
  "subscriptionTitle": "Подписка",
  "healthSyncNotSupported": "Health Sync не поддерживается на этом устройстве.",
  "healthConnectRequired": "Пожалуйста, установите Health Connect из Play Store.",
  "healthPermissionDenied": "Разрешение на данные о здоровье не было предоставлено.",
  "healthSyncCount": "{count} измерений синхронизировано",
  "@healthSyncCount": {
    "placeholders": {"count": {"type": "int"}}
  },
  "profileYourProfile": "Ваш профиль",
  "profileFullComplete": "Профиль заполнен",
  "profilePercentComplete": "Профиль заполнен на {percent}%",
  "@profilePercentComplete": {
    "placeholders": {"percent": {"type": "int"}}
  },
  "profileAgeYears": "{age} лет",
  "@profileAgeYears": {
    "placeholders": {"age": {"type": "int"}}
  },
  "profileOpIn": "ОП через {days} д.",
  "@profileOpIn": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileOpToday": "ОП сегодня",
  "profileOpAgo": "ОП {days} д. назад",
  "@profileOpAgo": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileProMember": "Pro участник",
  "profileUpgradePro": "Обновить до Pro",
  "profileVerified": "Подтверждён",

  "proActive": "Pro активен",
  "proManageSubscription": "Управление подпиской",
  "proUnlockNow": "Разблокировать сейчас",
}

NEW_TR = {
  "notifSettingsTitle": "Bildirimler",
  "notifCenter": "Bildirim Merkezi",
  "notifCenterSubtitle": "Tüm bildirimleri göster",
  "notifCategories": "Kategoriler",
  "notifGlobalEnabled": "Bildirimler aktif",
  "notifGlobalDisabled": "Tümü devre dışı",
  "notifActiveCount": "{total} kategoriden {active} aktif",
  "@notifActiveCount": {
    "placeholders": {
      "active": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "notifCatTasks": "Görevler ve Timeline",
  "notifCatTasksSub": "Bekleyen ve tamamlanan görevler",
  "notifCatAppointments": "Randevular",
  "notifCatAppointmentsSub": "Yaklaşan doktor ve klinik randevuları",
  "notifCatMedication": "İlaçlar",
  "notifCatMedicationSub": "İlaç alma hatırlatmaları",
  "notifCatWounds": "Yara Uyarıları",
  "notifCatWoundsSub": "Kritik yara kontrolü sonuçları uyarıları",
  "notifCatObservations": "Gözlemler",
  "notifCatObservationsSub": "Doktorlar ve bakıcılardan yeni gözlemler",
  "notifCatSystem": "Sistem",
  "notifCatSystemSub": "Güncellemeler, Pro durumu ve uygulama notları",

  "helpFaqTitle": "Sık Sorulan Sorular",
  "helpContactTitle": "İletişim",
  "helpContactDesc": "Burada cevaplanmayan bir sorunuz mu var? Bir destek talebi oluşturun veya bize e-posta gönderin.",
  "helpEmailSubject": "Operationsbegleiter – Destek Talebi",
  "helpFaq1Question": "Verilerim nasıl saklanıyor?",
  "helpFaq1Answer": "Verileriniz cihazınızda yerel olarak ve Google Firebase'de (Cloud Firestore) şifreli olarak saklanır. Erişim kullanıcı hesabınızla sınırlıdır.",
  "helpFaq2Question": "Pro aboneliğimi nasıl iptal edebilirim?",
  "helpFaq2Answer": "Pro abonelik App Store (Apple) veya Google Play Store üzerinden yönetilir. Abonelik yönetiminizi açın ve mevcut dönemin bitiminden en az 24 saat önce iptal edin.",
  "helpFaq3Question": "Yara dokümantasyonu nasıl çalışır?",
  "helpFaq3Answer": "Ana menüden veya Timeline'dan 'Yara Dokümantasyonu'nu açın. Yaranın fotoğrafını çekin veya galeriden bir resim seçin.",
  "helpFaq4Question": "Hesabımı silebilir miyim?",
  "helpFaq4Answer": "Evet. Ayarlar → Veriler → 'Verileri Sıfırla' bölümüne gidin. Tüm verileri silebilir veya hesabınızı tamamen kaldırabilirsiniz.",
  "helpFaq5Question": "Sağlık verilerimi kim görebilir?",
  "helpFaq5Answer": "Yalnızca siz ve davetiye özelliği ile erişim verdiğiniz kişiler (doktor veya aile üyeleri).",
  "helpFaq6Question": "Semptom kontrolündeki uyarı seviyeleri ne anlama geliyor?",
  "helpFaq6Answer": "🟢 Yeşil = zararsız, normal iyileşme belirtileri.\n🟡 Sarı = izle, bir sonraki doktor randevusunda konuş.\nKırmızı = acilen tıbbi tavsiye alın.",

  "qrScanHint": "Kamerayı davetin QR koduna\\nyönlendirin",

  "resetDialogContent": "Yalnızca yerel sağlık verilerinizi silmek mi yoksa hesabınızı kalıcı olarak kaldırmak mı istiyorsunuz?",
  "deleteDialogContent": "Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.",
  "reauthHint": "Lütfen çıkış yapıp tekrar giriş yapın, sonra tekrar deneyin.",
  "syncNever": "Henüz senkronize edilmedi",
  "syncJustNow": "Az önce",
  "syncMinutesAgo": "{count} dk. önce",
  "@syncMinutesAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncHoursAgo": "{count} sa. önce",
  "@syncHoursAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncDaysAgo": "{count} gün önce",
  "@syncDaysAgo": {
    "placeholders": {"count": {"type": "int"}}
  },

  "profileTitle": "Profil",
  "opInformationTitle": "Ameliyat Bilgileri",
  "healthSyncSectionTitle": "Health Sync",
  "subscriptionTitle": "Abonelik",
  "healthSyncNotSupported": "Health Sync bu cihazda desteklenmiyor.",
  "healthConnectRequired": "Lütfen Play Store'dan Health Connect yükleyin.",
  "healthPermissionDenied": "Sağlık verileri izni verilmedi.",
  "healthSyncCount": "{count} ölçüm senkronize edildi",
  "@healthSyncCount": {
    "placeholders": {"count": {"type": "int"}}
  },
  "profileYourProfile": "Profiliniz",
  "profileFullComplete": "Profil tamamlandı",
  "profilePercentComplete": "Profil %{percent} tamamlandı",
  "@profilePercentComplete": {
    "placeholders": {"percent": {"type": "int"}}
  },
  "profileAgeYears": "{age} yaşında",
  "@profileAgeYears": {
    "placeholders": {"age": {"type": "int"}}
  },
  "profileOpIn": "Ameliyata {days} g.",
  "@profileOpIn": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileOpToday": "Ameliyat bugün",
  "profileOpAgo": "Ameliyat {days} g. önce",
  "@profileOpAgo": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileProMember": "Pro Üye",
  "profileUpgradePro": "Pro'ya Yükselt",
  "profileVerified": "Doğrulandı",

  "proActive": "Pro aktif",
  "proManageSubscription": "Abonelik ve detayları yönet",
  "proUnlockNow": "Şimdi aç",
}

NEW_AR = {
  "notifSettingsTitle": "الإشعارات",
  "notifCenter": "مركز الإشعارات",
  "notifCenterSubtitle": "عرض جميع الإشعارات",
  "notifCategories": "الفئات",
  "notifGlobalEnabled": "الإشعارات مفعّلة",
  "notifGlobalDisabled": "الكل معطّل",
  "notifActiveCount": "{active} من {total} فئة مفعّلة",
  "@notifActiveCount": {
    "placeholders": {
      "active": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "notifCatTasks": "المهام والجدول الزمني",
  "notifCatTasksSub": "المهام المستحقة والمنجزة",
  "notifCatAppointments": "المواعيد",
  "notifCatAppointmentsSub": "مواعيد الطبيب والعيادة القادمة",
  "notifCatMedication": "الأدوية",
  "notifCatMedicationSub": "تذكيرات تناول الأدوية",
  "notifCatWounds": "تنبيهات الجروح",
  "notifCatWoundsSub": "تحذيرات عند نتائج فحص الجروح الحرجة",
  "notifCatObservations": "الملاحظات",
  "notifCatObservationsSub": "ملاحظات جديدة من الأطباء والمرافقين",
  "notifCatSystem": "النظام",
  "notifCatSystemSub": "التحديثات وحالة Pro وملاحظات التطبيق",

  "helpFaqTitle": "الأسئلة الشائعة",
  "helpContactTitle": "التواصل",
  "helpContactDesc": "لديك سؤال لم تتم الإجابة عليه هنا؟ أنشئ تذكرة دعم أو أرسل لنا بريداً إلكترونياً.",
  "helpEmailSubject": "Operationsbegleiter – طلب دعم",
  "helpFaq1Question": "كيف يتم تخزين بياناتي؟",
  "helpFaq1Answer": "يتم تخزين بياناتك محلياً على جهازك ومشفرة في Google Firebase. الوصول مقيد بحسابك.",
  "helpFaq2Question": "كيف يمكنني إلغاء اشتراك Pro؟",
  "helpFaq2Answer": "تتم إدارة اشتراك Pro عبر App Store أو Google Play Store. افتح إدارة الاشتراكات وقم بالإلغاء قبل 24 ساعة على الأقل من نهاية الفترة الحالية.",
  "helpFaq3Question": "كيف يعمل توثيق الجروح؟",
  "helpFaq3Answer": "افتح 'توثيق الجروح' من القائمة الرئيسية. التقط صورة للجرح أو اختر صورة من المعرض.",
  "helpFaq4Question": "هل يمكنني حذف حسابي؟",
  "helpFaq4Answer": "نعم. انتقل إلى الإعدادات ← البيانات ← 'إعادة تعيين البيانات'. يمكنك حذف جميع البيانات أو إزالة حسابك بالكامل.",
  "helpFaq5Question": "من يمكنه رؤية بياناتي الصحية؟",
  "helpFaq5Answer": "أنت فقط والأشخاص الذين منحتهم حق الوصول عبر ميزة الدعوة (طبيب أو أفراد العائلة).",
  "helpFaq6Question": "ماذا تعني مستويات التحذير في فحص الأعراض؟",
  "helpFaq6Answer": "🟢 أخضر = غير مقلق، أعراض تعافٍ طبيعية.\n🟡 أصفر = راقب، ناقش في الموعد القادم.\nأحمر = اطلب استشارة طبية فوراً.",

  "qrScanHint": "وجّه الكاميرا إلى رمز QR\\nالخاص بالدعوة",

  "resetDialogContent": "هل تريد حذف بياناتك الصحية المحلية فقط أم إزالة حسابك بالكامل نهائياً؟",
  "deleteDialogContent": "لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك نهائياً.",
  "reauthHint": "يرجى تسجيل الخروج وتسجيل الدخول مرة أخرى، ثم حاول مجدداً.",
  "syncNever": "لم تتم المزامنة بعد",
  "syncJustNow": "الآن",
  "syncMinutesAgo": "قبل {count} دقيقة",
  "@syncMinutesAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncHoursAgo": "قبل {count} ساعة",
  "@syncHoursAgo": {
    "placeholders": {"count": {"type": "int"}}
  },
  "syncDaysAgo": "قبل {count} يوم",
  "@syncDaysAgo": {
    "placeholders": {"count": {"type": "int"}}
  },

  "profileTitle": "الملف الشخصي",
  "opInformationTitle": "معلومات العملية",
  "healthSyncSectionTitle": "Health Sync",
  "subscriptionTitle": "الاشتراك",
  "healthSyncNotSupported": "Health Sync غير مدعوم على هذا الجهاز.",
  "healthConnectRequired": "يرجى تثبيت Health Connect من Play Store.",
  "healthPermissionDenied": "لم يتم منح إذن البيانات الصحية.",
  "healthSyncCount": "تمت مزامنة {count} قياس",
  "@healthSyncCount": {
    "placeholders": {"count": {"type": "int"}}
  },
  "profileYourProfile": "ملفك الشخصي",
  "profileFullComplete": "الملف الشخصي مكتمل",
  "profilePercentComplete": "الملف الشخصي مكتمل بنسبة {percent}%",
  "@profilePercentComplete": {
    "placeholders": {"percent": {"type": "int"}}
  },
  "profileAgeYears": "{age} سنة",
  "@profileAgeYears": {
    "placeholders": {"age": {"type": "int"}}
  },
  "profileOpIn": "العملية بعد {days} ي.",
  "@profileOpIn": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileOpToday": "العملية اليوم",
  "profileOpAgo": "العملية قبل {days} ي.",
  "@profileOpAgo": {
    "placeholders": {"days": {"type": "int"}}
  },
  "profileProMember": "عضو Pro",
  "profileUpgradePro": "ترقية إلى Pro",
  "profileVerified": "موثّق",

  "proActive": "Pro مفعّل",
  "proManageSubscription": "إدارة الاشتراك والتفاصيل",
  "proUnlockNow": "فتح الآن",
}

def add_keys(filename, new_keys):
    path = os.path.join(L10N, filename)
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    added = 0
    for k, v in new_keys.items():
        if k not in data:
            data[k] = v
            added += 1

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')

    plain_keys = len([k for k in new_keys if not k.startswith('@')])
    print(f'{filename}: added {added} entries ({plain_keys} user-facing keys)')

if __name__ == '__main__':
    add_keys('app_de.arb', NEW_DE)
    add_keys('app_en.arb', NEW_EN)
    add_keys('app_ru.arb', NEW_RU)
    add_keys('app_tr.arb', NEW_TR)
    add_keys('app_ar.arb', NEW_AR)
    print('Done!')
