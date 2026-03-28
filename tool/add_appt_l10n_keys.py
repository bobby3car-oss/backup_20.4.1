#!/usr/bin/env python3
"""
Adds all appointments-feature l10n keys to the 5 ARB files.
Run from the project root: python3 tool/add_appt_l10n_keys.py
"""
import json, os, sys

L10N_DIR = os.path.join(os.path.dirname(__file__), '..', 'lib', 'l10n')

# ── new keys per locale ───────────────────────────────────────────────────────

KEYS = {
    # Appointment type labels
    'apptTypeFollowUp':         {'de': 'Nachsorge',      'en': 'Follow-up',       'ar': 'متابعة',              'ru': 'Наблюдение',          'tr': 'Takip'},
    'apptTypePhysio':           {'de': 'Physio',          'en': 'Physio',           'ar': 'علاج طبيعي',          'ru': 'Физиотерапия',        'tr': 'Fizyoterapi'},
    'apptTypeSurgery':          {'de': 'OP',              'en': 'Surgery',          'ar': 'جراحة',               'ru': 'Операция',            'tr': 'Ameliyat'},
    'apptTypeCall':             {'de': 'Telefon',         'en': 'Call',             'ar': 'مكالمة',              'ru': 'Звонок',              'tr': 'Arama'},
    'apptTypeImaging':          {'de': 'Bildgebung',      'en': 'Imaging',          'ar': 'تصوير',               'ru': 'Визуализация',        'tr': 'Görüntüleme'},
    'apptTypeOther':            {'de': 'Sonstiges',       'en': 'Other',            'ar': 'أخرى',               'ru': 'Другое',              'tr': 'Diğer'},
    # Appointment status labels
    'apptStatusPlanned':        {'de': 'Geplant',         'en': 'Planned',          'ar': 'مخطط',               'ru': 'Запланировано',       'tr': 'Planlandı'},
    'apptStatusPending':        {'de': 'Ausstehend',      'en': 'Pending',          'ar': 'معلق',                'ru': 'Ожидается',           'tr': 'Bekliyor'},
    'apptStatusConfirmed':      {'de': 'Bestätigt',       'en': 'Confirmed',        'ar': 'مؤكد',               'ru': 'Подтверждено',        'tr': 'Onaylandı'},
    'apptStatusDeclined':       {'de': 'Abgelehnt',       'en': 'Declined',         'ar': 'مرفوض',              'ru': 'Отклонено',           'tr': 'Reddedildi'},
    'apptStatusDone':           {'de': 'Erledigt',        'en': 'Done',             'ar': 'منجز',               'ru': 'Выполнено',           'tr': 'Tamamlandı'},
    'apptStatusCanceled':       {'de': 'Abgesagt',        'en': 'Canceled',         'ar': 'ملغى',               'ru': 'Отменено',            'tr': 'İptal edildi'},
    'apptStatusCompleted':      {'de': 'Abgeschlossen',   'en': 'Completed',        'ar': 'مكتمل',              'ru': 'Завершено',           'tr': 'Tamamlandı'},
    # Reminder preset labels
    'apptReminderNone':         {'de': 'Keine',           'en': 'None',             'ar': 'لا شيء',             'ru': 'Нет',                 'tr': 'Yok'},
    'apptReminderAtTime':       {'de': 'Zum Zeitpunkt',   'en': 'At the time',      'ar': 'في الوقت المحدد',    'ru': 'В назначенное время', 'tr': 'Zamanında'},
    'apptReminderMin15':        {'de': '15 Min. vorher',  'en': '15 min. before',   'ar': 'قبل 15 دقيقة',       'ru': 'За 15 минут',         'tr': '15 dakika önce'},
    'apptReminderMin30':        {'de': '30 Min. vorher',  'en': '30 min. before',   'ar': 'قبل 30 دقيقة',       'ru': 'За 30 минут',         'tr': '30 dakika önce'},
    'apptReminderHour1':        {'de': '1 Stunde vorher', 'en': '1 hour before',    'ar': 'قبل ساعة',           'ru': 'За 1 час',            'tr': '1 saat önce'},
    'apptReminderHours2':       {'de': '2 Stunden vorher','en': '2 hours before',   'ar': 'قبل ساعتين',         'ru': 'За 2 часа',           'tr': '2 saat önce'},
    'apptReminderDay1':         {'de': '1 Tag vorher',    'en': '1 day before',     'ar': 'قبل يوم',            'ru': 'За 1 день',           'tr': '1 gün önce'},
    'apptReminderDays2':        {'de': '2 Tage vorher',   'en': '2 days before',    'ar': 'قبل يومين',          'ru': 'За 2 дня',            'tr': '2 gün önce'},
    'apptReminderCustom':       {'de': 'Benutzerdefiniert','en': 'Custom',           'ar': 'مخصص',               'ru': 'Настраиваемый',       'tr': 'Özel'},
    # Repeat rule labels
    'apptRepeatNone':           {'de': 'Keine',           'en': 'None',             'ar': 'لا شيء',             'ru': 'Нет',                 'tr': 'Yok'},
    'apptRepeatDaily':          {'de': 'Täglich',         'en': 'Daily',            'ar': 'يومياً',              'ru': 'Ежедневно',           'tr': 'Günlük'},
    'apptRepeatWeekly':         {'de': 'Wöchentlich',     'en': 'Weekly',           'ar': 'أسبوعياً',            'ru': 'Еженедельно',         'tr': 'Haftalık'},
    'apptRepeatMonthly':        {'de': 'Monatlich',       'en': 'Monthly',          'ar': 'شهرياً',              'ru': 'Ежемесячно',          'tr': 'Aylık'},
    # Priority labels
    'apptPriorityLow':          {'de': 'Niedrig',         'en': 'Low',              'ar': 'منخفضة',             'ru': 'Низкий',              'tr': 'Düşük'},
    'apptPriorityMedium':       {'de': 'Mittel',          'en': 'Medium',           'ar': 'متوسطة',             'ru': 'Средний',             'tr': 'Orta'},
    'apptPriorityHigh':         {'de': 'Hoch',            'en': 'High',             'ar': 'عالية',              'ru': 'Высокий',             'tr': 'Yüksek'},
    'apptPriorityUrgent':       {'de': 'Dringend',        'en': 'Urgent',           'ar': 'عاجل',               'ru': 'Срочный',             'tr': 'Acil'},
    # Form labels
    'apptLabelDate':            {'de': 'Datum',           'en': 'Date',             'ar': 'التاريخ',            'ru': 'Дата',                'tr': 'Tarih'},
    'apptLabelTime':            {'de': 'Uhrzeit',         'en': 'Time',             'ar': 'الوقت',              'ru': 'Время',               'tr': 'Saat'},
    'apptLabelLocation':        {'de': 'Ort',             'en': 'Location',         'ar': 'المكان',             'ru': 'Место',               'tr': 'Konum'},
    'apptLabelNote':            {'de': 'Notiz',           'en': 'Note',             'ar': 'ملاحظة',             'ru': 'Заметка',             'tr': 'Not'},
    'apptLabelReminder':        {'de': 'Erinnerung',      'en': 'Reminder',         'ar': 'تذكير',              'ru': 'Напоминание',         'tr': 'Hatırlatıcı'},
    'apptLabelPriority':        {'de': 'Priorität',       'en': 'Priority',         'ar': 'الأولوية',           'ru': 'Приоритет',           'tr': 'Öncelik'},
    'apptLabelType':            {'de': 'Typ',             'en': 'Type',             'ar': 'النوع',              'ru': 'Тип',                 'tr': 'Tür'},
    'apptLabelTitleRequired':   {'de': 'Titel *',         'en': 'Title *',          'ar': 'العنوان *',          'ru': 'Заголовок *',         'tr': 'Başlık *'},
    'apptLabelStartTime':       {'de': 'Startzeit',       'en': 'Start time',       'ar': 'وقت البدء',          'ru': 'Время начала',        'tr': 'Başlangıç saati'},
    'apptLabelEndTime':         {'de': 'Endzeit',         'en': 'End time',         'ar': 'وقت الانتهاء',       'ru': 'Время окончания',     'tr': 'Bitiş saati'},
    'apptLabelDoctor':          {'de': 'Arzt / Behandler','en': 'Doctor / Practitioner','ar': 'الطبيب / المعالج','ru': 'Врач / Специалист',   'tr': 'Doktor / Uygulayıcı'},
    'apptLabelFurtherReminders':{'de': 'Weitere Erinnerungen','en': 'More reminders','ar': 'تذكيرات إضافية',    'ru': 'Доп. напоминания',   'tr': 'Ek hatırlatıcılar'},
    'apptLabelFurtherDetails':  {'de': 'Weitere Details', 'en': 'More details',     'ar': 'مزيد من التفاصيل',  'ru': 'Доп. сведения',      'tr': 'Daha fazla ayrıntı'},
    'apptLabelRepeatUntil':     {'de': 'Bis',             'en': 'Until',            'ar': 'حتى',                'ru': 'До',                  'tr': 'Kadar'},
    'apptLabelCustomMinutes':   {'de': 'Custom Minuten',  'en': 'Minutes',          'ar': 'دقائق',              'ru': 'Минуты',              'tr': 'Dakikalar'},
    # Hints
    'apptHintTitle':            {'de': 'z. B. Kontrolltermin',    'en': 'e.g. check-up appointment', 'ar': 'مثال: موعد فحص',       'ru': 'напр. контрольный осмотр',  'tr': 'örn. kontrol randevusu'},
    'apptHintLocation':         {'de': 'z. B. Klinik Musterstadt','en': 'e.g. City Hospital',        'ar': 'مثال: مستشفى المدينة', 'ru': 'напр. городская клиника',   'tr': 'örn. Şehir Hastanesi'},
    'apptHintLocationDetails':  {'de': 'Details (Station, Raum)', 'en': 'Details (ward, room)',      'ar': 'التفاصيل (الجناح، الغرفة)', 'ru': 'Детали (отделение, палата)', 'tr': 'Ayrıntılar (koğuş, oda)'},
    'apptHintNote':             {'de': 'Optionale Anmerkung…',    'en': 'Optional note…',            'ar': 'ملاحظة اختيارية…',     'ru': 'Необязательная заметка…',   'tr': 'İsteğe bağlı not…'},
    'apptHintDoctor':           {'de': 'z. B. Dr. Müller',        'en': 'e.g. Dr. Smith',            'ar': 'مثال: د. أحمد',        'ru': 'напр. Д-р Иванов',          'tr': 'örn. Dr. Yılmaz'},
    'apptHintCustomMinutes':    {'de': 'Minuten',                 'en': 'Minutes',                   'ar': 'دقائق',                'ru': 'Минуты',                    'tr': 'Dakikalar'},
    # UI / action strings
    'apptConfirmationPending':  {'de': 'Bestätigung ausstehend',  'en': 'Confirmation pending',      'ar': 'في انتظار التأكيد',    'ru': 'Ожидается подтверждение',   'tr': 'Onay bekliyor'},
    'apptMarkAsDone':           {'de': 'Als erledigt markieren',  'en': 'Mark as done',              'ar': 'وضع علامة كمنجز',      'ru': 'Отметить как выполненное',  'tr': 'Tamamlandı olarak işaretle'},
    'apptMarkAsPlanned':        {'de': 'Als geplant markieren',   'en': 'Mark as planned',           'ar': 'وضع علامة كمخطط',      'ru': 'Отметить как запланированное','tr': 'Planlandı olarak işaretle'},
    'apptCancelAppt':           {'de': 'Absagen',                 'en': 'Cancel appointment',        'ar': 'إلغاء الموعد',         'ru': 'Отменить',                  'tr': 'Randevuyu iptal et'},
    'apptViewList':             {'de': 'Liste',                   'en': 'List',                      'ar': 'قائمة',                'ru': 'Список',                    'tr': 'Liste'},
    'apptViewCalendar':         {'de': 'Kalender',                'en': 'Calendar',                  'ar': 'تقويم',                'ru': 'Календарь',                 'tr': 'Takvim'},
    'apptSaving':               {'de': 'Speichert…',              'en': 'Saving…',                   'ar': 'جارٍ الحفظ…',          'ru': 'Сохранение…',               'tr': 'Kaydediliyor…'},
    'apptTitleRequired':        {'de': 'Titel ist erforderlich.', 'en': 'Title is required.',        'ar': 'العنوان مطلوب.',       'ru': 'Заголовок обязателен.',     'tr': 'Başlık gereklidir.'},
    'apptEditTitle':            {'de': 'Termin bearbeiten',       'en': 'Edit appointment',          'ar': 'تعديل الموعد',         'ru': 'Редактировать запись',      'tr': 'Randevuyu düzenle'},
    'apptNewTitle':             {'de': 'Neuer Termin',            'en': 'New appointment',           'ar': 'موعد جديد',            'ru': 'Новая запись',              'tr': 'Yeni randevu'},
    'apptDeleteTitle':          {'de': 'Termin löschen',          'en': 'Delete appointment',        'ar': 'حذف الموعد',           'ru': 'Удалить запись',            'tr': 'Randevuyu sil'},
    'apptNoResults':            {'de': 'Keine Ergebnisse',        'en': 'No results',                'ar': 'لا توجد نتائج',        'ru': 'Нет результатов',           'tr': 'Sonuç yok'},
    'apptNoAppointments':       {'de': 'Noch keine Termine',      'en': 'No appointments yet',       'ar': 'لا مواعيد حتى الآن',  'ru': 'Нет записей',               'tr': 'Henüz randevu yok'},
    'apptNoResultsHint':        {'de': 'Versuche andere Suchbegriffe oder Filter.', 'en': 'Try different search terms or filters.', 'ar': 'جرّب مصطلحات بحث أو فلاتر مختلفة.', 'ru': 'Попробуйте другие запросы или фильтры.', 'tr': 'Farklı arama terimleri veya filtreler deneyin.'},
    'apptAddFirstHint':         {'de': 'Tippe auf + um deinen ersten Termin hinzuzufügen.', 'en': 'Tap + to add your first appointment.', 'ar': 'اضغط + لإضافة موعدك الأول.', 'ru': 'Нажмите +, чтобы добавить первую запись.', 'tr': 'İlk randevunuzu eklemek için + tuşuna basın.'},
    'apptTodayNone':            {'de': 'Heute keine Termine',     'en': 'No appointments today',     'ar': 'لا مواعيد اليوم',      'ru': 'Сегодня нет записей',       'tr': 'Bugün randevu yok'},
    'apptTodayTitle':           {'de': 'Termine heute',           'en': "Today's appointments",      'ar': 'مواعيد اليوم',         'ru': 'Записи сегодня',            'tr': 'Bugünkü randevular'},
    'apptYesterday':            {'de': 'Gestern',                 'en': 'Yesterday',                 'ar': 'أمس',                  'ru': 'Вчера',                     'tr': 'Dün'},
    'apptCreatedByDoctor':      {'de': 'Vom Arzt erstellt',       'en': 'Created by doctor',         'ar': 'أُنشئ من قِبل الطبيب', 'ru': 'Создано врачом',            'tr': 'Doktor tarafından oluşturuldu'},
    'apptAllDay':               {'de': 'Ganztägig',               'en': 'All day',                   'ar': 'طوال اليوم',           'ru': 'Весь день',                 'tr': 'Tüm gün'},
    # Month names
    'monthJanuary':             {'de': 'Januar',    'en': 'January',   'ar': 'يناير',   'ru': 'Январь',   'tr': 'Ocak'},
    'monthFebruary':            {'de': 'Februar',   'en': 'February',  'ar': 'فبراير',  'ru': 'Февраль',  'tr': 'Şubat'},
    'monthMarch':               {'de': 'März',      'en': 'March',     'ar': 'مارس',    'ru': 'Март',     'tr': 'Mart'},
    'monthApril':               {'de': 'April',     'en': 'April',     'ar': 'أبريل',   'ru': 'Апрель',   'tr': 'Nisan'},
    'monthMay':                 {'de': 'Mai',       'en': 'May',       'ar': 'مايو',    'ru': 'Май',      'tr': 'Mayıs'},
    'monthJune':                {'de': 'Juni',      'en': 'June',      'ar': 'يونيو',   'ru': 'Июнь',     'tr': 'Haziran'},
    'monthJuly':                {'de': 'Juli',      'en': 'July',      'ar': 'يوليو',   'ru': 'Июль',     'tr': 'Temmuz'},
    'monthAugust':              {'de': 'August',    'en': 'August',    'ar': 'أغسطس',   'ru': 'Август',   'tr': 'Ağustos'},
    'monthSeptember':           {'de': 'September', 'en': 'September', 'ar': 'سبتمبر',  'ru': 'Сентябрь', 'tr': 'Eylül'},
    'monthOctober':             {'de': 'Oktober',   'en': 'October',   'ar': 'أكتوبر',  'ru': 'Октябрь',  'tr': 'Ekim'},
    'monthNovember':            {'de': 'November',  'en': 'November',  'ar': 'نوفمبر',  'ru': 'Ноябрь',   'tr': 'Kasım'},
    'monthDecember':            {'de': 'Dezember',  'en': 'December',  'ar': 'ديسمبر',  'ru': 'Декабрь',  'tr': 'Aralık'},
    # Short weekday labels
    'weekdayShortMon':          {'de': 'Mo', 'en': 'Mon', 'ar': 'إث', 'ru': 'Пн', 'tr': 'Pzt'},
    'weekdayShortTue':          {'de': 'Di', 'en': 'Tue', 'ar': 'ثل', 'ru': 'Вт', 'tr': 'Sal'},
    'weekdayShortWed':          {'de': 'Mi', 'en': 'Wed', 'ar': 'أر', 'ru': 'Ср', 'tr': 'Çar'},
    'weekdayShortThu':          {'de': 'Do', 'en': 'Thu', 'ar': 'خم', 'ru': 'Чт', 'tr': 'Per'},
    'weekdayShortFri':          {'de': 'Fr', 'en': 'Fri', 'ar': 'جم', 'ru': 'Пт', 'tr': 'Cum'},
    'weekdayShortSat':          {'de': 'Sa', 'en': 'Sat', 'ar': 'سب', 'ru': 'Сб', 'tr': 'Cmt'},
    'weekdayShortSun':          {'de': 'So', 'en': 'Sun', 'ar': 'أح', 'ru': 'Вс', 'tr': 'Paz'},
}

# Parameterized keys (need @-metadata):
PARAMETERIZED = {
    'apptReminderMinutes': {
        'de': '{minutes} Min. vorher',
        'en': '{minutes} min. before',
        'ar': 'قبل {minutes} دقيقة',
        'ru': 'За {minutes} минут',
        'tr': '{minutes} dakika önce',
        '@': {
            'placeholders': {
                'minutes': {'type': 'int'}
            }
        },
    },
    'apptDeleteContent': {
        'de': 'Möchtest du \u201e{title}\u201c wirklich unwiderruflich löschen?',
        'en': 'Do you really want to permanently delete \u201c{title}\u201c?',
        'ar': 'هل تريد حذف "{title}" بشكل دائم؟',
        'ru': 'Вы действительно хотите навсегда удалить «{title}»?',
        'tr': '"{title}" öğesini kalıcı olarak silmek istiyor musunuz?',
        '@': {
            'placeholders': {
                'title': {'type': 'String'}
            }
        },
    },
    'apptCreatedBy': {
        'de': 'Erstellt von {name}',
        'en': 'Created by {name}',
        'ar': 'أُنشئ بواسطة {name}',
        'ru': 'Создано {name}',
        'tr': '{name} tarafından oluşturuldu',
        '@': {
            'placeholders': {
                'name': {'type': 'String'}
            }
        },
    },
    'apptCalendarDayCount': {
        'de': '{count, plural, one{{count} Termin} other{{count} Termine}}',
        'en': '{count, plural, one{{count} appointment} other{{count} appointments}}',
        'ar': '{count, plural, zero{لا مواعيد} one{موعد واحد} two{موعدان} few{{count} مواعيد} many{{count} موعيدًا} other{{count} مواعيد}}',
        'ru': '{count, plural, one{{count} запись} few{{count} записи} many{{count} записей} other{{count} записей}}',
        'tr': '{count, plural, one{{count} randevu} other{{count} randevu}}',
        '@': {
            'placeholders': {
                'count': {'type': 'int'}
            }
        },
    },
}

LOCALES = ['de', 'en', 'ar', 'ru', 'tr']


def load_arb(locale: str) -> dict:
    path = os.path.join(L10N_DIR, f'app_{locale}.arb')
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f, object_pairs_hook=dict)


def save_arb(locale: str, data: dict):
    path = os.path.join(L10N_DIR, f'app_{locale}.arb')
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


def main():
    for locale in LOCALES:
        data = load_arb(locale)
        added = 0

        # Plain keys
        for key, translations in KEYS.items():
            if key not in data:
                data[key] = translations[locale]
                added += 1

        # Parameterized keys
        for key, info in PARAMETERIZED.items():
            if key not in data:
                data[key] = info[locale]
                data[f'@{key}'] = info['@']
                added += 1

        save_arb(locale, data)
        print(f'[{locale}] +{added} keys written.')

    print('Done.')


if __name__ == '__main__':
    main()
