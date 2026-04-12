import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../medication/domain/medication_reminder.dart';
import '../data/supplement_intake_repository_sync.dart';
import '../data/supplement_repository_sync.dart';
import '../data/supplement_reminder_scheduler.dart';
import '../domain/supplement.dart';
import '../domain/supplement_category.dart';
import '../domain/supplement_intake.dart';
import '../domain/supplement_recommendations.dart';

class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen>
    with SingleTickerProviderStateMixin {
  static final SupplementIntakeRepositorySync _intakeRepo =
      SupplementIntakeRepositorySync.instance;
  static final SupplementRepositorySync _supplementRepo =
      SupplementRepositorySync.instance;

  late final TabController _tabCtrl;

  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _brandController = TextEditingController();
  bool _saving = false;
  SupplementCategory _selectedCategory = SupplementCategory.vitamine;

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
    _tabCtrl = TabController(length: 3, vsync: this);
    _bootstrap();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameController.dispose();
    _doseController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait<void>([
      _intakeRepo.loadFromDisk(),
      _supplementRepo.loadFromDisk(),
    ]);
    try {
      await Future.wait<void>([
        _intakeRepo.pullLatest(),
        _supplementRepo.pullLatest(),
      ]);
    } catch (e) {
      debugPrint('[SupplementsScreen] pullLatest failed (offline?): $e');
    }
    await SupplementReminderScheduler.instance.rescheduleAll();
  }

  // ════════════════════════════════════════════════════════════════════
  // Quick Intake Log
  // ════════════════════════════════════════════════════════════════════

  Future<void> _logQuickIntake({Supplement? fromSupplement}) async {
    if (_saving) return;
    final uid = _currentUserId();
    if (uid == null) return;

    if (fromSupplement != null) {
      setState(() => _saving = true);
      HapticFeedback.mediumImpact();
      final now = DateTime.now();
      final id = 'suppl_${now.millisecondsSinceEpoch}';
      final intake = SupplementIntake(
        id: id,
        ownerId: uid,
        name: fromSupplement.name,
        supplementId: fromSupplement.id,
        dose: fromSupplement.dose,
        category: fromSupplement.category,
        takenAt: now,
        createdAt: now,
        updatedAt: now,
        metadata: const {'source': 'quick_log'},
      );
      await _intakeRepo.upsert(intake);

      // Decrement stock if tracked.
      if (fromSupplement.remainingCount != null &&
          fromSupplement.remainingCount! > 0) {
        final newCount = math.max(0, fromSupplement.remainingCount! - 1);
        final updated = fromSupplement.copyWith(
          remainingCount: newCount,
          updatedAt: now,
        );
        await _supplementRepo.upsert(updated);
      }

      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.supplementLogSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _saving = false);
      return;
    }

    // Manual log via bottom sheet.
    _showManualLogSheet();
  }

  void _showManualLogSheet() {
    _nameController.clear();
    _doseController.clear();
    _selectedCategory = SupplementCategory.vitamine;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return StatefulBuilder(
          builder: (ctx2, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.supplementLogManual,
                      style: Theme.of(ctx2).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l.supplementName,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _doseController,
                    decoration: InputDecoration(
                      labelText: l.supplementDose,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SupplementCategory>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: l.supplementCategoryLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: SupplementCategory.values
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text('${c.emoji} ${c.localizedLabel(l)}'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => _selectedCategory = v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return;
                      final uid = _currentUserId() ?? '';
                      final now = DateTime.now();
                      final id = 'suppl_${now.millisecondsSinceEpoch}';
                      final intake = SupplementIntake(
                        id: id,
                        ownerId: uid,
                        name: name,
                        dose: _doseController.text.trim().isEmpty
                            ? null
                            : _doseController.text.trim(),
                        category: _selectedCategory,
                        takenAt: now,
                        createdAt: now,
                        updatedAt: now,
                        metadata: const {'source': 'manual_log'},
                      );
                      await _intakeRepo.upsert(intake);
                      if (ctx2.mounted) Navigator.pop(ctx2);
                      if (mounted) {
                        final l2 = AppLocalizations.of(context)!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l2.supplementLogSuccess),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l.supplementSave),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Add / Edit Supplement Reminder
  // ════════════════════════════════════════════════════════════════════

  void _showAddSupplementSheet({Supplement? existing}) {
    _nameController.text = existing?.name ?? '';
    _doseController.text = existing?.dose ?? '';
    _brandController.text = existing?.brand ?? '';
    var category = existing?.category ?? SupplementCategory.vitamine;
    var selectedSlots = existing?.enabledSlots.toSet() ??
        {MedicationTimeSlot.morgens};

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return StatefulBuilder(
          builder: (ctx2, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existing == null
                          ? l.supplementAddNew
                          : l.supplementEdit,
                      style: Theme.of(ctx2).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l.supplementName,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: l.supplementBrand,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _doseController,
                      decoration: InputDecoration(
                        labelText: l.supplementDose,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SupplementCategory>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: l.supplementCategoryLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: SupplementCategory.values
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child:
                                    Text('${c.emoji} ${c.localizedLabel(l)}'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => category = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(l.supplementTimeSlots,
                        style: Theme.of(ctx2).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: MedicationTimeSlot.values.map((slot) {
                        final active = selectedSlots.contains(slot);
                        return FilterChip(
                          label: Text('${slot.emoji} ${slot.label}'),
                          selected: active,
                          onSelected: (v) {
                            setModalState(() {
                              if (v) {
                                selectedSlots.add(slot);
                              } else if (selectedSlots.length > 1) {
                                selectedSlots.remove(slot);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        if (name.isEmpty) return;
                        final uid = _currentUserId() ?? '';
                        final now = DateTime.now();

                        final slots = <MedicationTimeSlot, SlotConfig>{};
                        for (final slot in MedicationTimeSlot.values) {
                          if (selectedSlots.contains(slot)) {
                            slots[slot] = existing?.slots[slot] ??
                                SlotConfig.defaultFor(slot);
                          }
                        }

                        final supplement = Supplement(
                          id: existing?.id ??
                              'supp_${now.millisecondsSinceEpoch}',
                          ownerId: uid,
                          name: name,
                          category: category,
                          brand: _brandController.text.trim().isEmpty
                              ? null
                              : _brandController.text.trim(),
                          dose: _doseController.text.trim().isEmpty
                              ? null
                              : _doseController.text.trim(),
                          slots: slots,
                          isEnabled: existing?.isEnabled ?? true,
                          createdAt: existing?.createdAt ?? now,
                          updatedAt: now,
                          repeatPattern:
                              existing?.repeatPattern ?? RepeatPattern.daily,
                          totalCount: existing?.totalCount,
                          remainingCount: existing?.remainingCount,
                          metadata: {
                            ...?existing?.metadata,
                            'source': 'supplement_form',
                          },
                        );

                        await _supplementRepo.upsert(supplement);
                        await SupplementReminderScheduler.instance
                            .syncReminder(supplement);

                        if (ctx2.mounted) Navigator.pop(ctx2);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l.supplementSave),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.sectionSupplements),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: l.supplementTabToday),
            Tab(text: l.supplementTabMine),
            Tab(text: l.supplementTabRecommendations),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplementSheet(),
        child: const Icon(Icons.add_rounded),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _TodayTab(
            intakeRepo: _intakeRepo,
            supplementRepo: _supplementRepo,
            onQuickLog: _logQuickIntake,
            onManualLog: _showManualLogSheet,
          ),
          _MySupplementsTab(
            supplementRepo: _supplementRepo,
            onEdit: (s) => _showAddSupplementSheet(existing: s),
            onDelete: (s) async {
              await _supplementRepo.delete(s.id);
              await SupplementReminderScheduler.instance.rescheduleAll();
            },
          ),
          const _RecommendationsTab(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tab 1: Today
// ════════════════════════════════════════════════════════════════════════════

class _TodayTab extends StatelessWidget {
  const _TodayTab({
    required this.intakeRepo,
    required this.supplementRepo,
    required this.onQuickLog,
    required this.onManualLog,
  });

  final SupplementIntakeRepositorySync intakeRepo;
  final SupplementRepositorySync supplementRepo;
  final Future<void> Function({Supplement? fromSupplement}) onQuickLog;
  final VoidCallback onManualLog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final today = DateTime.now();

    return StreamBuilder<List<Supplement>>(
      stream: supplementRepo.watchAll(),
      builder: (context, supplementSnap) {
        final allSupplements = (supplementSnap.data ?? [])
            .where((s) => !s.isDeleted && s.isEnabled && s.occursOn(today))
            .toList();

        return StreamBuilder<List<SupplementIntake>>(
          stream: intakeRepo.watchAll(),
          builder: (context, intakeSnap) {
            final todayIntakes = (intakeSnap.data ?? []).where((i) {
              return !i.isDeleted &&
                  i.takenAt.year == today.year &&
                  i.takenAt.month == today.month &&
                  i.takenAt.day == today.day;
            }).toList();

            final takenIds = todayIntakes
                .where((i) => i.supplementId != null)
                .map((i) => i.supplementId!)
                .toSet();

            final totalToday = allSupplements.length;
            final doneToday = allSupplements
                .where((s) => takenIds.contains(s.id))
                .length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Progress card ──
                if (totalToday > 0) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '$doneToday / $totalToday',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: doneToday == totalToday
                                  ? AppColors.success
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: totalToday > 0
                                ? doneToday / totalToday
                                : 0,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.supplementTodayProgress,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Supplement slots grouped by time ──
                for (final slot in MedicationTimeSlot.values) ...[
                  () {
                    final slotSupplements = allSupplements
                        .where((s) => s.slots[slot]?.isEnabled == true)
                        .toList();
                    if (slotSupplements.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '${slot.emoji} ${slot.label}',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        ...slotSupplements.map((supplement) {
                          final taken = takenIds.contains(supplement.id);
                          return Card(
                            color: taken
                                ? AppColors.success.withOpacity(0.1)
                                : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    supplement.category.iconColor.withOpacity(0.15),
                                child: Icon(supplement.category.icon,
                                    color: supplement.category.iconColor,
                                    size: 20),
                              ),
                              title: Text(
                                supplement.displayName,
                                style: taken
                                    ? const TextStyle(
                                        decoration: TextDecoration.lineThrough)
                                    : null,
                              ),
                              subtitle: supplement.dose != null
                                  ? Text(supplement.dose!)
                                  : null,
                              trailing: taken
                                  ? Icon(Icons.check_circle_rounded,
                                      color: AppColors.success)
                                  : IconButton(
                                      icon: const Icon(
                                          Icons.add_circle_outline_rounded),
                                      onPressed: () => onQuickLog(
                                          fromSupplement: supplement),
                                    ),
                              onTap: taken
                                  ? null
                                  : () =>
                                      onQuickLog(fromSupplement: supplement),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    );
                  }(),
                ],

                // ── Quick manual log ──
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onManualLog,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(l.supplementLogManual),
                ),

                // ── Today's intake history ──
                if (todayIntakes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(l.supplementTodayHistory,
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...todayIntakes.map((intake) {
                    final time =
                        '${intake.takenAt.hour.toString().padLeft(2, '0')}:'
                        '${intake.takenAt.minute.toString().padLeft(2, '0')}';
                    return ListTile(
                      dense: true,
                      leading: Text(intake.category.emoji,
                          style: const TextStyle(fontSize: 20)),
                      title: Text(intake.name),
                      subtitle: intake.dose != null ? Text(intake.dose!) : null,
                      trailing: Text(time,
                          style: theme.textTheme.bodySmall),
                    );
                  }),
                ],

                if (allSupplements.isEmpty && todayIntakes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.local_pharmacy_rounded,
                              size: 64,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(l.supplementEmptyState,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              )),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tab 2: My Supplements
// ════════════════════════════════════════════════════════════════════════════

class _MySupplementsTab extends StatelessWidget {
  const _MySupplementsTab({
    required this.supplementRepo,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplementRepositorySync supplementRepo;
  final void Function(Supplement) onEdit;
  final Future<void> Function(Supplement) onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return StreamBuilder<List<Supplement>>(
      stream: supplementRepo.watchAll(),
      builder: (context, snapshot) {
        final supplements = (snapshot.data ?? [])
            .where((s) => !s.isDeleted)
            .toList();

        if (supplements.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_pharmacy_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(l.supplementEmptyState,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    )),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: supplements.length,
          itemBuilder: (context, index) {
            final supplement = supplements[index];
            return Dismissible(
              key: ValueKey(supplement.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: AppColors.error,
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l.supplementDeleteTitle),
                    content: Text(l.supplementDeleteBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l.delete),
                      ),
                    ],
                  ),
                ) ??
                    false;
              },
              onDismissed: (_) => onDelete(supplement),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        supplement.category.iconColor.withOpacity(0.15),
                    child: Icon(supplement.category.icon,
                        color: supplement.category.iconColor, size: 20),
                  ),
                  title: Text(supplement.displayName),
                  subtitle: Text([
                    if (supplement.dose != null) supplement.dose!,
                    supplement.repeatLabel,
                    supplement.enabledSlots
                        .map((s) => s.label)
                        .join(', '),
                  ].join(' · ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (supplement.isStockLow)
                        Tooltip(
                          message: l.supplementStockLow,
                          child: Icon(Icons.warning_amber_rounded,
                              color: AppColors.warning, size: 20),
                        ),
                      if (supplement.isStockEmpty)
                        Tooltip(
                          message: l.supplementStockEmpty,
                          child: Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 20),
                        ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  onTap: () => onEdit(supplement),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tab 3: Recommendations
// ════════════════════════════════════════════════════════════════════════════

class _RecommendationsTab extends StatelessWidget {
  const _RecommendationsTab();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // For now show general recommendations + all OP-type recommendations.
    final recommendations =
        getSupplementRecommendationsForOp(opType: null, daysSinceOp: null);

    if (recommendations.isEmpty) {
      return Center(
        child: Text(l.supplementNoRecommendations,
            style: theme.textTheme.bodyMedium),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final rec = recommendations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(rec.icon, color: rec.iconColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(rec.title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: switch (rec.evidenceLevel) {
                          EvidenceLevel.high =>
                            AppColors.success.withOpacity(0.15),
                          EvidenceLevel.moderate =>
                            AppColors.warning.withOpacity(0.15),
                          EvidenceLevel.low =>
                            AppColors.grey400.withOpacity(0.15),
                        },
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${rec.evidenceLevel.emoji} ${rec.evidenceLevel.label}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(rec.body, style: theme.textTheme.bodyMedium),
                if (rec.doseGuidance != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.science_rounded,
                            size: 16,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${l.supplementDoseGuidance}: ${rec.doseGuidance}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${rec.category.emoji} ${rec.category.localizedLabel(l)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: rec.category.iconColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


