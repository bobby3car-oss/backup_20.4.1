import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../documents/data/documents_repository_local.dart';
import '../../documents/domain/document_item.dart';
import '../../../notifications/local_notifications.dart';
import '../data/medication_reminder_repository_sync.dart';
import '../data/medication_reminder_scheduler.dart';
import '../data/medication_repository_sync.dart';
import '../domain/medication_intake.dart';
import '../domain/medication_reminder.dart';
import '../../../ui/theme/app_icons.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  static final MedicationRepositorySync _repository =
      MedicationRepositorySync.instance;
  static final MedicationReminderRepositorySync _reminderRepository =
      MedicationReminderRepositorySync.instance;

  final DocumentsRepositoryLocal _documentsRepository =
      DocumentsRepositoryLocal.instance;
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  bool _savingLog = false;

  String? _currentUserId() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.trim().isEmpty) return null;
      return uid;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait<void>([
      _repository.loadFromDisk(),
      _reminderRepository.loadFromDisk(),
      _documentsRepository.loadFromDisk(),
    ]);
    await Future.wait<void>([
      _repository.pullLatest(),
      _reminderRepository.pullLatest(),
    ]);
    await MedicationReminderScheduler.instance.rescheduleAll();
  }

  Future<void> _saveManualLog({
    MedicationReminder? seededReminder,
    bool clearForm = false,
  }) async {
    final name = seededReminder?.medicationName ?? _nameController.text.trim();
    if (name.isEmpty || _savingLog) return;

    setState(() => _savingLog = true);
    try {
      final now = DateTime.now();
      final uid = _currentUserId() ?? 'local_device';
      final dose = seededReminder?.dose ?? _doseController.text.trim();
      final entry = MedicationIntake(
        id: 'med_${now.microsecondsSinceEpoch}',
        ownerId: uid,
        name: name,
        dose: dose.isEmpty ? null : dose,
        takenAt: now,
        createdAt: now,
        updatedAt: now,
        metadata: <String, dynamic>{
          'source': seededReminder == null
              ? 'medication_manual_hub'
              : 'medication_reminder',
          if (seededReminder != null) 'reminderId': seededReminder.id,
          if (seededReminder?.note != null) 'note': seededReminder!.note,
        },
      );
      await _repository.upsert(entry);

      if (seededReminder != null) {
        await LocalNotifications.cancelMedicationSnooze(seededReminder.id);
      }

      if (clearForm) {
        _nameController.clear();
        _doseController.clear();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            seededReminder == null
                ? 'Einnahme dokumentiert'
                : '${seededReminder.medicationName} dokumentiert',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error saving medication log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Speichern der Einnahme')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingLog = false);
    }
  }

  Future<void> _openReminderEditor({MedicationReminder? existing}) async {
    final draft = await showModalBottomSheet<_ReminderDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MedicationReminderEditorSheet(initial: existing),
    );
    if (!mounted || draft == null) return;

    final now = DateTime.now();
    final uid = _currentUserId() ?? 'local_device';
    final reminder =
        (existing ??
                MedicationReminder(
                  id: 'med_alarm_${now.microsecondsSinceEpoch}',
                  ownerId: uid,
                  medicationName: draft.name,
                  dose: draft.dose,
                  note: draft.note,
                  hour: draft.time.hour,
                  minute: draft.time.minute,
                  isEnabled: draft.isEnabled,
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              medicationName: draft.name,
              dose: draft.dose,
              clearDose: draft.dose == null,
              note: draft.note,
              clearNote: draft.note == null,
              hour: draft.time.hour,
              minute: draft.time.minute,
              isEnabled: draft.isEnabled,
              updatedAt: now,
            );

    try {
      await _reminderRepository.upsert(reminder);
      await MedicationReminderScheduler.instance.syncReminder(reminder);

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Medikamentenwecker gespeichert'
                : 'Medikamentenwecker aktualisiert',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error saving medication reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Speichern des Weckers')),
        );
      }
    }
  }

  Future<void> _deleteReminder(MedicationReminder reminder) async {
    try {
      await _reminderRepository.delete(reminder.id);
      await MedicationReminderScheduler.instance.cancel(reminder.id);
      await LocalNotifications.cancelMedicationSnooze(reminder.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reminder.medicationName} entfernt'),
          action: SnackBarAction(
            label: 'Rückgängig',
            onPressed: () async {
              try {
                await _reminderRepository.upsert(reminder);
                await MedicationReminderScheduler.instance.syncReminder(reminder);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${reminder.medicationName} wiederhergestellt'),
                  ),
                );
              } catch (e) {
                debugPrint('Error restoring medication reminder: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fehler beim Wiederherstellen')),
                  );
                }
              }
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error deleting medication reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Löschen des Weckers')),
        );
      }
    }
  }

  Future<void> _snoozeReminder(
    MedicationReminder reminder,
    Duration duration,
  ) async {
    try {
      await LocalNotifications.scheduleMedicationSnooze(
        reminder: reminder,
        duration: duration,
      );
    } catch (e) {
      debugPrint('[MedicationScreen] _snoozeReminder failed: $e');
      return;
    }
    if (!mounted) return;
    final minutes = duration.inMinutes;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${reminder.medicationName} erinnert dich in $minutes Minuten erneut',
        ),
        action: SnackBarAction(
          label: 'Abbrechen',
          onPressed: () =>
              LocalNotifications.cancelMedicationSnooze(reminder.id),
        ),
      ),
    );
  }

  void _openDocuments({DocumentType? type, String? query, String? label}) {
    Navigator.of(context).pushNamed(
      '/documents',
      arguments: <String, dynamic>{
        'source': 'medication_hub',
        if (type != null) 'type': type.name,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        if (label != null && label.trim().isNotEmpty) 'contextLabel': label,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MedicationReminder>>(
      stream: _reminderRepository.watchAll(),
      builder: (context, reminderSnapshot) {
        final reminders =
            (reminderSnapshot.data ?? const <MedicationReminder>[])
                .where((item) => !item.isDeleted)
                .toList(growable: false);

        return StreamBuilder<List<MedicationIntake>>(
          stream: _repository.watchAll(),
          builder: (context, intakeSnapshot) {
            final intakes = (intakeSnapshot.data ?? const <MedicationIntake>[])
                .where((item) => !item.isDeleted)
                .toList(growable: false);

            return StreamBuilder<List<DocumentItem>>(
              stream: _documentsRepository.watchAll(),
              builder: (context, docsSnapshot) {
                final documents = docsSnapshot.data ?? const <DocumentItem>[];
                final now = DateTime.now();
                final activeReminders = reminders
                    .where((item) => item.isEnabled)
                    .toList(growable: false);
                final nextReminder = _nextReminder(activeReminders, now);
                final todayLogs = _todayLogs(intakes, now);
                final prescriptionCount = documents
                    .where((item) => item.type == DocumentType.rezept)
                    .length;

                return GlassPage(
                  title: 'Medikamenten-Hub',
                  titleIcon: AppIcons.medication,
                  titleColor: AppColors.warning,
                  trailing: _HeaderActionButton(
                    icon: Icons.folder_open_rounded,
                    onTap: () => _openDocuments(),
                  ),
                  children: [
                    _MedicationHeroCard(
                      nextReminder: nextReminder,
                      activeCount: activeReminders.length,
                      todayCount: todayLogs.length,
                      onAddReminder: _openReminderEditor,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Therapieplan',
                      subtitle:
                          'Lege feste Einnahmezeiten an und lass dich täglich erinnern.',
                      actionLabel: 'Neu',
                      onAction: _openReminderEditor,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (reminders.isEmpty)
                      _EmptyStateCard(
                        icon: AppIcons.notifications,
                    iconColor: AppIcons.notificationsColor,
                        title: 'Noch kein Medikamentenwecker',
                        subtitle:
                            'Starte mit einem täglichen Alarm für dein nächstes Medikament.',
                        actionLabel: 'Wecker anlegen',
                        onAction: _openReminderEditor,
                      )
                    else
                      ...reminders.map(
                        (reminder) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _ReminderCard(
                            reminder: reminder,
                            onLogNow: () =>
                                _saveManualLog(seededReminder: reminder),
                            onSnooze: (duration) =>
                                _snoozeReminder(reminder, duration),
                            onEdit: () =>
                                _openReminderEditor(existing: reminder),
                            onDelete: () => _deleteReminder(reminder),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Sofort dokumentieren',
                      subtitle:
                          'Für Bedarfsmedikation oder spontane Einnahmen ohne festen Plan.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ManualLogCard(
                      nameController: _nameController,
                      doseController: _doseController,
                      saving: _savingLog,
                      onSave: () => _saveManualLog(clearForm: true),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _MedicationDocsCard(
                      totalDocuments: documents.length,
                      prescriptionCount: prescriptionCount,
                      onOpenDocuments: () => _openDocuments(),
                      onOpenPrescriptions: () => _openDocuments(
                        type: DocumentType.rezept,
                        label: 'Rezepte',
                      ),
                      onOpenMedicationPlans: () => _openDocuments(
                        query: 'medik',
                        label: 'Medikationsplan',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Dokumentation',
                      subtitle:
                          'Dein Verlauf der letzten Einnahmen bleibt sauber nachvollziehbar.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (intakes.isEmpty)
                      _EmptyStateCard(
                        icon: AppIcons.documents,
                    iconColor: AppIcons.documentsColor,
                        title: 'Noch keine Dokumentation',
                        subtitle:
                            'Sobald du Medikamente einnimmst, tauchen sie hier chronologisch auf.',
                        actionLabel: 'Jetzt dokumentieren',
                        onAction: () => _saveManualLog(clearForm: true),
                      )
                    else
                      _HistoryCard(intakes: intakes),
                    const SizedBox(height: AppSpacing.massive),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  MedicationReminder? _nextReminder(
    List<MedicationReminder> reminders,
    DateTime now,
  ) {
    if (reminders.isEmpty) return null;
    final sorted = List<MedicationReminder>.from(reminders)
      ..sort((a, b) => a.nextOccurrence(now).compareTo(b.nextOccurrence(now)));
    return sorted.first;
  }

  List<MedicationIntake> _todayLogs(
    List<MedicationIntake> items,
    DateTime now,
  ) {
    return items
        .where((item) {
          final taken = item.takenAt;
          return taken.year == now.year &&
              taken.month == now.month &&
              taken.day == now.day;
        })
        .toList(growable: false);
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.70),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.90)),
        ),
        child: Icon(icon, size: 18, color: AppColors.grey800),
      ),
    );
  }
}

class _MedicationHeroCard extends StatelessWidget {
  const _MedicationHeroCard({
    required this.nextReminder,
    required this.activeCount,
    required this.todayCount,
    required this.onAddReminder,
  });

  final MedicationReminder? nextReminder;
  final int activeCount;
  final int todayCount;
  final VoidCallback onAddReminder;

  @override
  Widget build(BuildContext context) {
    final headline = nextReminder == null
        ? 'Baue deinen Medikamentenplan auf.'
        : '${nextReminder!.medicationName} um ${nextReminder!.timeLabel}';
    final subline = nextReminder == null
        ? 'Wecker, Verlauf und Unterlagen liegen danach an einem Ort.'
        : nextReminder!.note?.trim().isNotEmpty == true
        ? nextReminder!.note!.trim()
        : 'Nächste geplante Einnahme heute oder morgen.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C6CF2), Color(0xFF36B3FF), Color(0xFF8AE0C9)],
        ),
        borderRadius: AppRadius.borderRadiusXxl,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C6CF2).withValues(alpha: 0.24),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.borderRadiusLg,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.alarm_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                activeCount == 0 ? 'Noch leer' : '$activeCount aktiv',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Plan, Wecker, Doku',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            headline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Heute dokumentiert',
                  value: '$todayCount',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroMetric(
                  label: 'Aktive Wecker',
                  value: '$activeCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddReminder,
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text('Medikamentenwecker anlegen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: AppSpacing.md),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onLogNow,
    required this.onSnooze,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationReminder reminder;
  final VoidCallback onLogNow;
  final ValueChanged<Duration> onSnooze;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = reminder.isEnabled ? AppColors.warning : AppColors.grey500;
    final next = reminder.nextOccurrence();
    final nextText = _relativeNext(next);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.95),
                      accent.withValues(alpha: 0.58),
                    ],
                  ),
                  borderRadius: AppRadius.borderRadiusLg,
                ),
                child: Center(
                  child: Text(
                    reminder.timeLabel,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicationName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        if (reminder.dose != null &&
                            reminder.dose!.trim().isNotEmpty)
                          reminder.dose!.trim(),
                        nextText,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Bearbeiten'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Entfernen'),
                  ),
                ],
              ),
            ],
          ),
          if (reminder.note != null && reminder.note!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.52),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Text(
                reminder.note!.trim(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ElevatedButton.icon(
                onPressed: onLogNow,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Jetzt dokumentieren'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: reminder.isEnabled
                    ? () => _showSnoozeSheet(context)
                    : null,
                icon: const Icon(Icons.snooze_rounded),
                label: const Text('Snooze'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey800,
                  side: BorderSide(
                    color: AppColors.grey300.withValues(alpha: 0.9),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Anpassen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey800,
                  side: BorderSide(
                    color: AppColors.grey300.withValues(alpha: 0.9),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _relativeNext(DateTime next) {
    final now = DateTime.now();
    final diff = DateTime(
      next.year,
      next.month,
      next.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'heute';
    if (diff == 1) return 'morgen';
    return 'in $diff Tagen';
  }

  Future<void> _showSnoozeSheet(BuildContext context) async {
    final options = <Duration>[
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(hours: 1),
    ];
    final choice = await showModalBottomSheet<Duration>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options)
                  ListTile(
                    leading: const Icon(Icons.snooze_rounded),
                    title: Text('${option.inMinutes} Minuten'),
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (choice != null) onSnooze(choice);
  }
}

class _ManualLogCard extends StatelessWidget {
  const _ManualLogCard({
    required this.nameController,
    required this.doseController,
    required this.saving,
    required this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController doseController;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bedarfsmedikation oder zusätzliche Einnahme',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ideal für Schmerzmittel, spontane Anpassungen oder Rücksprachen mit dem Team.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel(label: 'Medikament'),
          const SizedBox(height: AppSpacing.xs),
          _InputField(
            controller: nameController,
            hint: 'z.B. Ibuprofen',
            prefixIcon: Icons.medication_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _FieldLabel(label: 'Dosis'),
          const SizedBox(height: AppSpacing.xs),
          _InputField(
            controller: doseController,
            hint: 'z.B. 400 mg',
            prefixIcon: Icons.opacity_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(saving ? 'Speichert...' : 'Einnahme dokumentieren'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationDocsCard extends StatelessWidget {
  const _MedicationDocsCard({
    required this.totalDocuments,
    required this.prescriptionCount,
    required this.onOpenDocuments,
    required this.onOpenPrescriptions,
    required this.onOpenMedicationPlans,
  });

  final int totalDocuments;
  final int prescriptionCount;
  final VoidCallback onOpenDocuments;
  final VoidCallback onOpenPrescriptions;
  final VoidCallback onOpenMedicationPlans;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: const Color(0xFFFFD9A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.16),
                  borderRadius: AppRadius.borderRadiusLg,
                ),
                child: const Icon(
                  Icons.folder_copy_rounded,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rezepte & Medikationsunterlagen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '$prescriptionCount Rezepte · $totalDocuments Dokumente gesamt',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Lege Verordnungen, Anweisungen und Befunde direkt bei deiner Medikation ab, damit Dosierung und Verlauf zusammen bleiben.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenPrescriptions,
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Rezepte'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: Color(0xFFFFD9A8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenMedicationPlans,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Medikationsplan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: Color(0xFFFFD9A8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenDocuments,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Alle Dokumente'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: Color(0xFFFFD9A8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.intakes});

  final List<MedicationIntake> intakes;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MedicationIntake>>{};
    for (final intake in intakes.take(20)) {
      final key = _dayKey(intake.takenAt);
      grouped.putIfAbsent(key, () => <MedicationIntake>[]).add(intake);
    }
    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (
            var sectionIndex = 0;
            sectionIndex < keys.length;
            sectionIndex++
          ) ...[
            if (sectionIndex > 0) const SizedBox(height: AppSpacing.lg),
            Text(
              _humanDay(DateTime.parse(keys[sectionIndex])),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.grey700),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...grouped[keys[sectionIndex]]!.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _HistoryRow(item: item),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _dayKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _humanDay(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Heute';
    if (diff == -1) return 'Gestern';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final MedicationIntake item;

  @override
  Widget build(BuildContext context) {
    final hh = item.takenAt.hour.toString().padLeft(2, '0');
    final mm = item.takenAt.minute.toString().padLeft(2, '0');
    final note = item.metadata['note']?.toString();
    final detailParts = <String>[
      if (item.dose != null && item.dose!.trim().isNotEmpty) item.dose!.trim(),
      if (note != null && note.trim().isNotEmpty) note.trim(),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.58),
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                if (detailParts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    detailParts.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$hh:$mm',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.grey700),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;


  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        children: [
          GlassIcon(icon: icon, color: iconColor, size: 36),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_rounded),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusPill,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(color: AppColors.grey800),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.62),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.95)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: AppColors.grey600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _ReminderDraft {
  const _ReminderDraft({
    required this.name,
    required this.dose,
    required this.note,
    required this.time,
    required this.isEnabled,
  });

  final String name;
  final String? dose;
  final String? note;
  final TimeOfDay time;
  final bool isEnabled;
}

class _MedicationReminderEditorSheet extends StatefulWidget {
  const _MedicationReminderEditorSheet({this.initial});

  final MedicationReminder? initial;

  @override
  State<_MedicationReminderEditorSheet> createState() =>
      _MedicationReminderEditorSheetState();
}

class _MedicationReminderEditorSheetState
    extends State<_MedicationReminderEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _doseController;
  late final TextEditingController _noteController;
  late TimeOfDay _time;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initial?.medicationName ?? '',
    );
    _doseController = TextEditingController(text: widget.initial?.dose ?? '');
    _noteController = TextEditingController(text: widget.initial?.note ?? '');
    _time = TimeOfDay(
      hour: widget.initial?.hour ?? 8,
      minute: widget.initial?.minute ?? 0,
    );
    _isEnabled = widget.initial?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final dose = _doseController.text.trim();
    final note = _noteController.text.trim();

    Navigator.of(context).pop(
      _ReminderDraft(
        name: name,
        dose: dose.isEmpty ? null : dose,
        note: note.isEmpty ? null : note,
        time: _time,
        isEnabled: _isEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  widget.initial == null
                      ? 'Medikamentenwecker'
                      : 'Wecker bearbeiten',
                  style: tt.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Lege Name, Dosis, Tageszeit und eine kurze Anweisung fest.',
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _FieldLabel(label: 'Medikament'),
                const SizedBox(height: AppSpacing.xs),
                _InputField(
                  controller: _nameController,
                  hint: 'z.B. Amoxicillin',
                  prefixIcon: Icons.medication_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel(label: 'Dosis'),
                const SizedBox(height: AppSpacing.xs),
                _InputField(
                  controller: _doseController,
                  hint: 'z.B. 1 Tablette',
                  prefixIcon: Icons.local_hospital_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel(label: 'Anweisung / Notiz'),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadius.borderRadiusLg,
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: TextField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'z.B. nach dem Essen oder mit Wasser einnehmen',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: AppRadius.borderRadiusXl,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Tägliche Uhrzeit',
                              style: tt.titleLarge,
                            ),
                          ),
                          TextButton(
                            onPressed: _pickTime,
                            child: Text(_time.format(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Wecker aktiv'),
                        subtitle: const Text('Täglich als lokaler Alarm'),
                        value: _isEnabled,
                        activeThumbColor: AppColors.warning,
                        onChanged: (value) =>
                            setState(() => _isEnabled = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Speichern'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
