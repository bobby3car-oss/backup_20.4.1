import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
    try {
      await Future.wait<void>([
        _repository.pullLatest(),
        _reminderRepository.pullLatest(),
      ]);
    } catch (e) {
      debugPrint('[MedicationScreen] pullLatest failed (offline?): $e');
    }
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

      // ── Stock tracking: decrement remainingCount ──
      if (seededReminder != null &&
          seededReminder.remainingCount != null &&
          seededReminder.remainingCount! > 0) {
        final newCount = math.max(0, seededReminder.remainingCount! - 1);
        final updated = seededReminder.copyWith(
          remainingCount: newCount,
          updatedAt: now,
        );
        await _reminderRepository.upsert(updated);
        await MedicationReminderScheduler.instance.syncReminder(updated);
      }

      if (seededReminder != null) {
        await LocalNotifications.cancelMedicationSnooze(seededReminder.id);
      }

      if (!mounted) return;

      if (clearForm) {
        _nameController.clear();
        _doseController.clear();
      }
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
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.medicationIntakeSaveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _savingLog = false);
    }
  }

  Future<void> _openReminderEditor({MedicationReminder? existing}) async {
    final draft = await showModalBottomSheet<_EntryDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MedicationEntryEditorSheet(initial: existing),
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
                  slots: draft.slots,
                  isEnabled: draft.isEnabled,
                  createdAt: now,
                  updatedAt: now,
                  repeatPattern: draft.repeatPattern,
                  repeatDays: draft.repeatDays,
                  endDate: draft.endDate,
                  totalCount: draft.totalCount,
                  remainingCount: draft.remainingCount,
                ))
            .copyWith(
              medicationName: draft.name,
              dose: draft.dose,
              clearDose: draft.dose == null,
              note: draft.note,
              clearNote: draft.note == null,
              slots: draft.slots,
              isEnabled: draft.isEnabled,
              updatedAt: now,
              repeatPattern: draft.repeatPattern,
              repeatDays: draft.repeatDays,
              clearRepeatDays: draft.repeatDays == null,
              endDate: draft.endDate,
              clearEndDate: draft.endDate == null,
              totalCount: draft.totalCount,
              clearTotalCount: draft.totalCount == null,
              remainingCount: draft.remainingCount,
              clearRemainingCount: draft.remainingCount == null,
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
                ? 'Medikament gespeichert'
                : 'Medikament aktualisiert',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error saving medication: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.saveError)),
        );
      }
    }
  }

  Future<void> _logSlotIntake(
    MedicationReminder reminder,
    MedicationTimeSlot slot,
  ) async {
    final uid = _currentUserId() ?? 'local_device';
    final now = DateTime.now();
    final config = reminder.slots[slot];
    final effectiveDose = config?.dose?.trim().isNotEmpty == true
        ? config!.dose!.trim()
        : reminder.dose?.trim();
    try {
      final entry = MedicationIntake(
        id: 'med_${now.microsecondsSinceEpoch}',
        ownerId: uid,
        name: reminder.medicationName,
        dose: effectiveDose?.isEmpty == true ? null : effectiveDose,
        takenAt: now,
        createdAt: now,
        updatedAt: now,
        metadata: <String, dynamic>{
          'source': 'medication_reminder',
          'reminderId': reminder.id,
          'slotId': slot.name,
          if (reminder.note != null) 'note': reminder.note,
        },
      );
      await _repository.upsert(entry);

      // Decrement stock if tracked.
      if (reminder.remainingCount != null && reminder.remainingCount! > 0) {
        final newCount = math.max(0, reminder.remainingCount! - 1);
        final updated = reminder.copyWith(
          remainingCount: newCount,
          updatedAt: now,
        );
        await _reminderRepository.upsert(updated);
        await MedicationReminderScheduler.instance.syncReminder(updated);
      }

      await LocalNotifications.cancelMedicationSnooze(reminder.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${reminder.medicationName} (${slot.label}) dokumentiert',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error logging slot intake: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.medicationIntakeSaveError)),
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
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.medikamentEntfernt(reminder.medicationName)),
          action: SnackBarAction(
            label: l.rueckgaengig,
            onPressed: () async {
              try {
                await _reminderRepository.upsert(reminder);
                await MedicationReminderScheduler.instance.syncReminder(reminder);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.medikamentWiederhergestellt(reminder.medicationName)),
                  ),
                );
              } catch (e) {
                debugPrint('Error restoring medication reminder: $e');
                if (mounted) {
                  final l = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.restoreError)),
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
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.medicationAlarmDeleteError)),
        );
      }
    }
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

  Future<void> _deleteIntake(MedicationIntake intake) async {
    final l = AppLocalizations.of(context)!;
    try {
      final now = DateTime.now();
      await _repository.upsert(intake.copyWith(deletedAt: now, updatedAt: now));
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.medikamentEntfernt(intake.name)),
          action: SnackBarAction(
            label: l.rueckgaengig,
            onPressed: () async {
              try {
                await _repository.upsert(
                  intake.copyWith(clearDeletedAt: true, updatedAt: DateTime.now()),
                );
              } catch (e) {
                debugPrint('Error restoring intake: $e');
              }
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error deleting intake: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.deleteError)),
        );
      }
    }
  }

  /// 7-day adherence: (taken slots) / (total scheduled slots).
  double _weekAdherence(
    List<MedicationReminder> reminders,
    List<MedicationIntake> intakes,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int totalSlots = 0;
    int takenSlots = 0;

    for (var dayOffset = 6; dayOffset >= 0; dayOffset--) {
      final day = today.subtract(Duration(days: dayOffset));
      for (final r in reminders) {
        if (!r.isEnabled || r.isDeleted) continue;
        if (!r.occursOn(day)) continue;

        for (final slot in r.enabledSlots) {
          final config = r.slots[slot]!;
          final planned = DateTime(
            day.year,
            day.month,
            day.day,
            config.hour,
            config.minute,
          );
          if (planned.isAfter(now)) continue;
          totalSlots++;

          final taken = intakes.any((i) {
            if (i.isDeleted) return false;
            if (i.takenAt.year != day.year ||
                i.takenAt.month != day.month ||
                i.takenAt.day != day.day) return false;
            // Preferred: reminderId + slotId match
            if (i.metadata['reminderId'] == r.id &&
                i.metadata['slotId'] == slot.name) return true;
            // Legacy: reminderId match without slotId
            if (i.metadata['reminderId'] == r.id &&
                !i.metadata.containsKey('slotId')) return true;
            // Name + time proximity fallback
            if (i.name == r.medicationName) {
              return i.takenAt.difference(planned).inMinutes.abs() < 60;
            }
            return false;
          });
          if (taken) takenSlots++;
        }
      }
    }
    if (totalSlots == 0) return -1.0; // No trackable slots — signal "no data"
    return takenSlots / totalSlots;
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
                final l = AppLocalizations.of(context)!;
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
                final adherence = _weekAdherence(reminders, intakes);
                final lowStockReminders = reminders
                    .where((r) => r.isStockLow || r.isStockEmpty)
                    .toList(growable: false);

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
                      adherence: adherence,
                      onAddReminder: _openReminderEditor,
                    ),

                    // ── Stock warning ──
                    if (lowStockReminders.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _StockWarningBanner(reminders: lowStockReminders),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // ── EMP-Medikamentenplan ──
                    _EmpTableCard(
                      reminders: reminders,
                      intakes: intakes,
                      onLogSlot: _logSlotIntake,
                      onAddEntry: _openReminderEditor,
                      onEditEntry: (r) => _openReminderEditor(existing: r),
                      onDeleteEntry: _deleteReminder,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: l.sofortDokumentieren,
                      subtitle: l.bedarfsmedikationOderSpontaneEinnahmen,
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
                        label: l.nutritionRecipes,
                      ),
                      onOpenMedicationPlans: () => _openDocuments(
                        query: 'medik',
                        label: l.medicationPlan,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: l.history,
                      subtitle: l.chronologischDokumentierteEinnahmen,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (intakes.isEmpty)
                      _EmptyStateCard(
                        icon: AppIcons.documents,
                        iconColor: AppIcons.documentsColor,
                        title: l.nochKeineDokumentation,
                        subtitle:
                            'Sobald du Medikamente einnimmst, tauchen sie hier chronologisch auf.',
                        actionLabel: 'Jetzt dokumentieren',
                        onAction: () => _saveManualLog(clearForm: true),
                      )
                    else
                      _HistoryCard(
                        intakes: intakes,
                        onDelete: _deleteIntake,
                      ),
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
    required this.adherence,
    required this.onAddReminder,
  });

  final MedicationReminder? nextReminder;
  final int activeCount;
  final int todayCount;
  final double adherence;
  final VoidCallback onAddReminder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final headline = nextReminder == null
        ? 'Baue deinen Medikamentenplan auf.'
        : '${nextReminder!.medicationName} um ${nextReminder!.timeLabel}';
    final subline = nextReminder == null
        ? 'Wecker, Verlauf und Unterlagen an einem Ort.'
        : nextReminder!.note?.trim().isNotEmpty == true
            ? nextReminder!.note!.trim()
            : l.naechsteGeplanteEinnahme;
    final hasAdherenceData = adherence >= 0;
    final pct = hasAdherenceData ? (adherence * 100).round() : 0;

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
              // ── Compliance ring ──
              if (activeCount > 0 && hasAdherenceData)
                _AdherenceRing(value: adherence, pct: pct),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
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
                  label: l.heuteDokumentiert,
                  value: '$todayCount',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HeroMetric(
                  label: 'Medikamente',
                  value: '$activeCount',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HeroMetric(
                  label: l.n7TageTreue,
                  value: hasAdherenceData ? '$pct%' : '–',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddReminder,
              icon: const Icon(Icons.add_rounded),
              label: Text(l.medicationAdd),
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

class _AdherenceRing extends StatelessWidget {
  const _AdherenceRing({required this.value, required this.pct});
  final double value;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: 4,
              backgroundColor: AppColors.white.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(
                value >= 0.8
                    ? const Color(0xFF34D399)
                    : value >= 0.5
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFF87171),
              ),
            ),
          ),
          Text(
            '$pct%',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
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
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stock warning banner ──────────────────────────────────────────────────────

class _StockWarningBanner extends StatelessWidget {
  const _StockWarningBanner({required this.reminders});
  final List<MedicationReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final names = reminders.map((r) {
      final left = r.remainingCount ?? 0;
      if (left <= 0) return '${r.medicationName} (aufgebraucht)';
      return '${r.medicationName} ($left übrig)';
    }).join(', ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.14),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vorrat geht zur Neige',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  names,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error.withValues(alpha: 0.8),
                  ),
                ),
              ],
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
  });

  final String title;
  final String subtitle;

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
      ],
    );
  }
}

// ── EMP-Medikamentenplan ─────────────────────────────────────────────────────

/// EMP-style medication table.
/// Rows: one per medication | Columns: Name + 4 time slots.
class _EmpTableCard extends StatelessWidget {
  const _EmpTableCard({
    required this.reminders,
    required this.intakes,
    required this.onLogSlot,
    required this.onAddEntry,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  final List<MedicationReminder> reminders;
  final List<MedicationIntake> intakes;
  final void Function(MedicationReminder, MedicationTimeSlot) onLogSlot;
  final VoidCallback onAddEntry;
  final void Function(MedicationReminder) onEditEntry;
  final void Function(MedicationReminder) onDeleteEntry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final todayEntries = reminders
        .where((r) => r.occursOn(todayOnly))
        .toList(growable: false);

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xs,
              0,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l.medicationPlan,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: onAddEntry,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: AppColors.primary,
                  tooltip: l.medicationAdd,
                ),
              ],
            ),
          ),

          // ── Column headers ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Expanded(flex: 5, child: SizedBox()),
                ...MedicationTimeSlot.values.map(
                  (slot) => Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          slot.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slot.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey500,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: AppColors.grey200.withValues(alpha: 0.8),
          ),

          // ── Data rows ──
          if (todayEntries.isEmpty)
            _EmpEmptyState(onAdd: onAddEntry)
          else
            ...todayEntries.map(
              (entry) => _EmpTableRow(
                entry: entry,
                intakes: intakes,
                today: todayOnly,
                onLogSlot: (slot) => onLogSlot(entry, slot),
                onEdit: () => onEditEntry(entry),
                onDelete: () => onDeleteEntry(entry),
              ),
            ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _EmpTableRow extends StatelessWidget {
  const _EmpTableRow({
    required this.entry,
    required this.intakes,
    required this.today,
    required this.onLogSlot,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationReminder entry;
  final List<MedicationIntake> intakes;
  final DateTime today;
  final void Function(MedicationTimeSlot) onLogSlot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool _isTakenToday(MedicationTimeSlot slot) {
    return intakes.any((i) {
      if (i.isDeleted) return false;
      if (i.takenAt.year != today.year ||
          i.takenAt.month != today.month ||
          i.takenAt.day != today.day) return false;
      // Preferred: reminderId + slotId
      if (i.metadata['reminderId'] == entry.id &&
          i.metadata['slotId'] == slot.name) return true;
      // Legacy: reminderId without slotId
      if (i.metadata['reminderId'] == entry.id &&
          !i.metadata.containsKey('slotId')) return true;
      // Name + time proximity fallback
      if (i.name == entry.medicationName) {
        final config = entry.slots[slot];
        if (config != null) {
          final planned = DateTime(
            today.year,
            today.month,
            today.day,
            config.hour,
            config.minute,
          );
          return i.takenAt.difference(planned).inMinutes.abs() < 60;
        }
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Divider(height: 1, color: AppColors.grey100),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Name column (flex 5) ──
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.medicationName,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: entry.isEnabled
                            ? AppColors.textPrimary
                            : AppColors.grey400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.dose != null && entry.dose!.isNotEmpty)
                      Text(
                        entry.dose!,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.grey500,
                          fontSize: 11,
                        ),
                      ),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Text(
                        entry.note!,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.grey400,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (entry.remainingCount != null) ...[
                      const SizedBox(height: 3),
                      _StockBar(reminder: entry),
                    ],
                  ],
                ),
              ),

              // ── Slot columns (flex 2 each) ──
              ...MedicationTimeSlot.values.map((slot) {
                final config = entry.slots[slot];
                final active = config?.isEnabled == true && entry.isEnabled;
                final taken = active && _isTakenToday(slot);
                return Expanded(
                  flex: 2,
                  child: _SlotCell(
                    config: config,
                    active: active,
                    taken: taken,
                    onTap: (active && !taken) ? () => onLogSlot(slot) : null,
                  ),
                );
              }),

              // ── Context menu ──
              SizedBox(
                width: 32,
                child: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: AppColors.grey400,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text(l.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l.remove,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.config,
    required this.active,
    required this.taken,
    this.onTap,
  });

  final SlotConfig? config;
  final bool active;
  final bool taken;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return const Center(
        child: Text(
          '–',
          style: TextStyle(
            color: AppColors.grey300,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final slotDose = config?.dose?.trim();
    final timeText = config?.timeLabel;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        decoration: BoxDecoration(
          color: taken
              ? AppColors.success.withValues(alpha: 0.12)
              : AppColors.warning.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: taken
                ? AppColors.success.withValues(alpha: 0.35)
                : AppColors.warning.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              taken
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: taken ? AppColors.success : AppColors.warning,
            ),
            if (slotDose != null && slotDose.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  slotDose,
                  style: TextStyle(
                    fontSize: 9,
                    color: taken ? AppColors.success : AppColors.grey600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              )
            else if (timeText != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        taken ? AppColors.success : AppColors.grey500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmpEmptyState extends StatelessWidget {
  const _EmpEmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 40,
            color: AppColors.grey300,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Noch keine Medikamente',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Füge deine Medikamente und Einnahmezeiten hinzu.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(l.medicationAdd),
          ),
        ],
      ),
    );
  }
}

// ── Entry draft (passed from editor sheet to state) ──

class _EntryDraft {
  const _EntryDraft({
    required this.name,
    required this.dose,
    required this.note,
    required this.slots,
    required this.isEnabled,
    required this.repeatPattern,
    required this.repeatDays,
    required this.endDate,
    required this.totalCount,
    required this.remainingCount,
  });

  final String name;
  final String? dose;
  final String? note;
  final Map<MedicationTimeSlot, SlotConfig> slots;
  final bool isEnabled;
  final RepeatPattern repeatPattern;
  final List<int>? repeatDays;
  final DateTime? endDate;
  final int? totalCount;
  final int? remainingCount;
}

class _StockBar extends StatelessWidget {
  const _StockBar({required this.reminder});
  final MedicationReminder reminder;

  @override
  Widget build(BuildContext context) {
    final total = reminder.totalCount ?? 0;
    final remaining = reminder.remainingCount ?? 0;
    final ratio = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;
    final isLow = reminder.isStockLow || reminder.isStockEmpty;
    final barColor = isLow ? AppColors.error : AppColors.success;

    return Row(
      children: [
        Icon(
          isLow ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
          size: 14,
          color: barColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.borderRadiusPill,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$remaining${total > 0 ? '/$total' : ''} übrig',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: barColor,
          ),
        ),
      ],
    );
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
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.bedarfsmedikationOderZusaetzlicheEinnahme,
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
          _FieldLabel(label: l.medication),
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
    final l = AppLocalizations.of(context)!;
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
                label: Text(l.nutritionRecipes),
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
                label: Text(l.medicationPlan),
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
                label: Text(l.documentsAll),
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

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({required this.intakes, required this.onDelete});

  final List<MedicationIntake> intakes;
  final ValueChanged<MedicationIntake> onDelete;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  static const _initialCount = 15;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Sort newest first.
    final sorted = List<MedicationIntake>.from(widget.intakes)
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    final visible = _showAll ? sorted : sorted.take(_initialCount).toList();

    final grouped = <String, List<MedicationIntake>>{};
    for (final intake in visible) {
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
            if (sectionIndex > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(
                  color: AppColors.grey200.withValues(alpha: 0.6),
                  height: 1,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    _humanDay(DateTime.parse(keys[sectionIndex])),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.grey700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    child: Text(
                      '${grouped[keys[sectionIndex]]!.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...grouped[keys[sectionIndex]]!.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l.entryDeleteConfirm),
                        content: Text(l.medikamentWirdEntfernt(item.name)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              l.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) => widget.onDelete(item),
                  child: _HistoryRow(item: item),
                ),
              ),
            ),
          ],
          if (!_showAll && sorted.length > _initialCount)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAll = true),
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  label: Text(
                    'Alle ${sorted.length} Einträge anzeigen',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
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
    const weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final wd = weekdays[d.weekday - 1];
    return '$wd, ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
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
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

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
        keyboardType: keyboardType,
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

// ── Weekday selector for custom repeat pattern ──

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({
    required this.selectedDays,
    required this.onChanged,
  });

  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onChanged;

  static const _dayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final dayNumber = index + 1; // 1=Mo..7=So
        final selected = selectedDays.contains(dayNumber);
        return GestureDetector(
          onTap: () {
            final updated = Set<int>.from(selectedDays);
            if (selected) {
              updated.remove(dayNumber);
            } else {
              updated.add(dayNumber);
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.grey100,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.grey300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _dayLabels[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.grey700,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Medication entry editor (EMP-style) ──────────────────────────────────────

class _MedicationEntryEditorSheet extends StatefulWidget {
  const _MedicationEntryEditorSheet({this.initial});

  final MedicationReminder? initial;

  @override
  State<_MedicationEntryEditorSheet> createState() =>
      _MedicationEntryEditorSheetState();
}

class _MedicationEntryEditorSheetState
    extends State<_MedicationEntryEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _doseController;
  late final TextEditingController _noteController;
  late final TextEditingController _totalCountController;
  late final TextEditingController _remainingCountController;
  late bool _isEnabled;
  late RepeatPattern _repeatPattern;
  late Set<int> _repeatDays;
  DateTime? _endDate;

  late Map<MedicationTimeSlot, bool> _slotEnabled;
  late Map<MedicationTimeSlot, TextEditingController> _slotDoseControllers;
  late Map<MedicationTimeSlot, TimeOfDay> _slotTimes;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _nameController = TextEditingController(text: r?.medicationName ?? '');
    _doseController = TextEditingController(text: r?.dose ?? '');
    _noteController = TextEditingController(text: r?.note ?? '');
    _totalCountController =
        TextEditingController(text: r?.totalCount?.toString() ?? '');
    _remainingCountController =
        TextEditingController(text: r?.remainingCount?.toString() ?? '');
    _isEnabled = r?.isEnabled ?? true;
    _repeatPattern = r?.repeatPattern ?? RepeatPattern.daily;
    _repeatDays = r?.repeatDays != null
        ? Set<int>.from(r!.repeatDays!)
        : <int>{};
    _endDate = r?.endDate;

    _slotEnabled = {};
    _slotDoseControllers = {};
    _slotTimes = {};
    for (final slot in MedicationTimeSlot.values) {
      final config = r?.slots[slot];
      _slotEnabled[slot] = config?.isEnabled ?? false;
      _slotDoseControllers[slot] =
          TextEditingController(text: config?.dose ?? '');
      _slotTimes[slot] = TimeOfDay(
        hour: config?.hour ?? slot.defaultHour,
        minute: config?.minute ?? 0,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _noteController.dispose();
    _totalCountController.dispose();
    _remainingCountController.dispose();
    for (final c in _slotDoseControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickSlotTime(MedicationTimeSlot slot) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _slotTimes[slot]!,
    );
    if (picked == null || !mounted) return;
    setState(() => _slotTimes[slot] = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;
    setState(() => _endDate = picked);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final dose = _doseController.text.trim();
    final note = _noteController.text.trim();
    final totalStr = _totalCountController.text.trim();
    final remainStr = _remainingCountController.text.trim();
    final total = totalStr.isEmpty ? null : int.tryParse(totalStr);
    final remain = remainStr.isEmpty ? null : int.tryParse(remainStr);

    final slots = <MedicationTimeSlot, SlotConfig>{};
    for (final slot in MedicationTimeSlot.values) {
      final enabled = _slotEnabled[slot] ?? false;
      final time = _slotTimes[slot]!;
      final slotDose = _slotDoseControllers[slot]!.text.trim();
      slots[slot] = SlotConfig(
        isEnabled: enabled,
        dose: slotDose.isEmpty ? null : slotDose,
        hour: time.hour,
        minute: time.minute,
      );
    }

    Navigator.of(context).pop(
      _EntryDraft(
        name: name,
        dose: dose.isEmpty ? null : dose,
        note: note.isEmpty ? null : note,
        slots: slots,
        isEnabled: _isEnabled,
        repeatPattern: _repeatPattern,
        repeatDays:
            _repeatPattern == RepeatPattern.custom && _repeatDays.isNotEmpty
                ? _repeatDays.toList()
                : null,
        endDate: _endDate,
        totalCount: total,
        remainingCount: remain ?? total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final tt = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: true,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initial == null
                            ? l.medicationAdd
                            : 'Medikament bearbeiten',
                        style: tt.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.grey600,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Lege Namen, Dosis und Einnahmezeiten fest.',
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Name ──
                _FieldLabel(label: l.medikament),
                const SizedBox(height: AppSpacing.xs),
                _InputField(
                  controller: _nameController,
                  hint: 'z.B. Amoxicillin 500 mg',
                  prefixIcon: Icons.medication_rounded,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Default dose ──
                _FieldLabel(label: 'Standarddosis'),
                const SizedBox(height: AppSpacing.xs),
                _InputField(
                  controller: _doseController,
                  hint: 'z.B. 1 Tablette',
                  prefixIcon: Icons.local_hospital_outlined,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Note ──
                _FieldLabel(label: l.anweisungNotiz),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadius.borderRadiusLg,
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: TextField(
                    controller: _noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l.zbNachDemEssen,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── EMP Time slots ──
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: AppRadius.borderRadiusXl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l.medicationIntakeTimes, style: tt.titleLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Wähle eine oder mehrere Tageszeiten aus.',
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...MedicationTimeSlot.values.map(
                        (slot) => _SlotToggleRow(
                          slot: slot,
                          enabled: _slotEnabled[slot] ?? false,
                          time: _slotTimes[slot]!,
                          doseController: _slotDoseControllers[slot]!,
                          onToggle: (v) =>
                              setState(() => _slotEnabled[slot] = v),
                          onPickTime: () => _pickSlotTime(slot),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Notifications switch ──
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  borderRadius: AppRadius.borderRadiusXl,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.notificationsActive),
                    subtitle:
                        Text(l.medicationLocalAlarms),
                    value: _isEnabled,
                    activeThumbColor: AppColors.warning,
                    onChanged: (v) => setState(() => _isEnabled = v),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Repeat pattern ──
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: AppRadius.borderRadiusXl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.repeat_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l.repetition, style: tt.titleLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: RepeatPattern.values.map((pattern) {
                          final selected = _repeatPattern == pattern;
                          return ChoiceChip(
                            label: Text(pattern.label),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _repeatPattern = pattern),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.18),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.grey800,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      if (_repeatPattern == RepeatPattern.custom) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(l.wochentage, style: tt.titleSmall),
                        const SizedBox(height: AppSpacing.sm),
                        _WeekdaySelector(
                          selectedDays: _repeatDays,
                          onChanged: (days) =>
                              setState(() => _repeatDays = days),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_rounded,
                            color: AppColors.grey600,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _endDate == null
                                  ? 'Kein Enddatum'
                                  : 'Endet am ${_endDate!.day.toString().padLeft(2, '0')}.${_endDate!.month.toString().padLeft(2, '0')}.${_endDate!.year}',
                              style: tt.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: _pickEndDate,
                            child: Text(
                              _endDate == null ? 'Setzen' : l.aendern,
                            ),
                          ),
                          if (_endDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () =>
                                  setState(() => _endDate = null),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Stock tracking ──
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: AppRadius.borderRadiusXl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l.medicationStock, style: tt.titleLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Warnhinweis wenn der Vorrat knapp wird.',
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel(label: 'Gesamtmenge'),
                                const SizedBox(height: AppSpacing.xs),
                                _InputField(
                                  controller: _totalCountController,
                                  hint: 'z.B. 30',
                                  prefixIcon: Icons.all_inbox_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel(label: 'Verbleibend'),
                                const SizedBox(height: AppSpacing.xs),
                                _InputField(
                                  controller: _remainingCountController,
                                  hint: 'z.B. 28',
                                  prefixIcon:
                                      Icons.format_list_numbered_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                    label: Text(l.save),
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

// ── Slot toggle row (one per EMP time-of-day in the editor) ──────────────────

class _SlotToggleRow extends StatelessWidget {
  const _SlotToggleRow({
    required this.slot,
    required this.enabled,
    required this.time,
    required this.doseController,
    required this.onToggle,
    required this.onPickTime,
  });

  final MedicationTimeSlot slot;
  final bool enabled;
  final TimeOfDay time;
  final TextEditingController doseController;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.warning.withValues(alpha: 0.06)
            : AppColors.grey100.withValues(alpha: 0.5),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: enabled
              ? AppColors.warning.withValues(alpha: 0.25)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(slot.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  slot.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.textPrimary : AppColors.grey500,
                  ),
                ),
              ),
              if (enabled)
                TextButton(
                  onPressed: onPickTime,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '$hh:$mm',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              Switch.adaptive(
                value: enabled,
                activeThumbColor: AppColors.warning,
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                left: AppSpacing.xl + AppSpacing.sm,
              ),
              child: _InputField(
                controller: doseController,
                hint: l.dosisFuerDiesenZeitpunktOptional,
                prefixIcon: Icons.opacity_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

