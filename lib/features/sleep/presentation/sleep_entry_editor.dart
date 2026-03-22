import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/sleep_repository_sync.dart';
import '../domain/sleep_entry.dart';

const _kNightPurple = Color(0xFF5C4D9A);
const _kNightSurface = Color(0x1A5C4D9A);
const _kNightBorder = Color(0x335C4D9A);
const _kStarYellow = Color(0xFFFFD700);

/// Full-detail sleep entry editor with date/time pickers.
class SleepEntryEditor extends StatefulWidget {
  const SleepEntryEditor({super.key, this.initialEntry, this.entryId});

  final SleepEntry? initialEntry;
  final String? entryId;

  @override
  State<SleepEntryEditor> createState() => _SleepEntryEditorState();
}

class _SleepEntryEditorState extends State<SleepEntryEditor> {
  static final SleepRepositorySync _repository = SleepRepositorySync.instance;

  final _noteController = TextEditingController();

  SleepEntry? _editing;
  bool _loading = true;
  bool _saving = false;

  DateTime _bedTime = DateTime.now()
      .subtract(const Duration(hours: 8))
      .copyWith(second: 0, millisecond: 0, microsecond: 0);
  DateTime _wakeTime = DateTime.now()
      .copyWith(second: 0, millisecond: 0, microsecond: 0);
  double _quality = 3;
  int _disturbances = 0;

  bool get _isEditMode => _editing != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    SleepEntry? initial = widget.initialEntry;
    String? entryId = widget.entryId;

    if (routeArgs is SleepEntry) {
      initial = routeArgs;
    } else if (routeArgs is String) {
      entryId = routeArgs;
    } else if (routeArgs is Map) {
      initial = routeArgs['entry'] as SleepEntry?;
      entryId ??= routeArgs['entryId']?.toString();
    }

    if (initial != null) {
      _applyEntry(initial);
    } else if (entryId != null && entryId.isNotEmpty) {
      final loaded = await _repository.getById(entryId);
      if (loaded != null && mounted) _applyEntry(loaded);
    }

    if (mounted) setState(() => _loading = false);
  }

  void _applyEntry(SleepEntry entry) {
    _editing = entry;
    _bedTime = entry.bedTime;
    _wakeTime = entry.wakeTime;
    _quality = entry.quality.value.toDouble();
    _disturbances = entry.disturbances;
    _noteController.text = entry.note ?? '';
  }

  int get _durationMinutes {
    final diff = _wakeTime.difference(_bedTime).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  String get _durationFormatted {
    final h = _durationMinutes ~/ 60;
    final m = _durationMinutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  Future<void> _pickDateTime({required bool isBedTime}) async {
    final current = isBedTime ? _bedTime : _wakeTime;

    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final result = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    HapticFeedback.selectionClick();
    setState(() {
      if (isBedTime) {
        _bedTime = result;
      } else {
        _wakeTime = result;
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_wakeTime.isBefore(_bedTime) || _wakeTime.isAtSameMomentAs(_bedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aufwachzeit muss nach der Bettzeit liegen.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    try {
      final now = DateTime.now();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = SleepEntry(
        id: _editing?.id ?? 'sleep_${now.millisecondsSinceEpoch}',
        ownerId: _editing?.ownerId ?? uid,
        bedTime: _bedTime,
        wakeTime: _wakeTime,
        quality: SleepQuality.fromValue(_quality.round()),
        disturbances: _disturbances,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: _editing?.createdAt ?? now,
        updatedAt: now,
        metadata: <String, dynamic>{
          ...?_editing?.metadata,
          'source': 'sleep_editor',
        },
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      Navigator.of(context).pop(entry);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tt = Theme.of(context).textTheme;
    final sq = SleepQuality.fromValue(_quality.round());

    return GlassPage(
      title: _isEditMode ? 'Schlaf bearbeiten' : 'Schlaf erfassen',
      titleIcon: CupertinoIcons.moon_fill,
      titleColor: _kNightPurple,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // ── Bed time ──
        _EditorSection(
          label: 'Bettzeit',
          child: _DateTimeTile(
            icon: CupertinoIcons.moon_fill,
            dateTime: _bedTime,
            onTap: () => _pickDateTime(isBedTime: true),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Wake time ──
        _EditorSection(
          label: 'Aufwachzeit',
          child: _DateTimeTile(
            icon: CupertinoIcons.sun_max_fill,
            dateTime: _wakeTime,
            onTap: () => _pickDateTime(isBedTime: false),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Duration display ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _kNightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kNightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.timer, size: 18, color: _kNightPurple),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Dauer: $_durationFormatted',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _kNightPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Quality ──
        _EditorSection(
          label: 'Schlafqualität – ${sq.label} ${sq.emoji}',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _quality.round();
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _quality = (i + 1).toDouble());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    size: 36,
                    color: filled ? _kStarYellow : AppColors.grey400,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Disturbances ──
        _EditorSection(
          label: 'Unterbrechungen',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _disturbances > 0
                    ? () => setState(() => _disturbances--)
                    : null,
                icon: const Icon(CupertinoIcons.minus_circle_fill),
                color: _kNightPurple,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '$_disturbances',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _kNightPurple,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                onPressed: () => setState(() => _disturbances++),
                icon: const Icon(CupertinoIcons.plus_circle_fill),
                color: _kNightPurple,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Note ──
        _EditorSection(
          label: 'Notiz (optional)',
          child: TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Wie hast du geschlafen?',
              filled: true,
              fillColor: _kNightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kNightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kNightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kNightPurple, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Save ──
        GlassButton(
          onPressed: _saving ? null : _save,
          label: _saving
              ? 'Speichern…'
              : (_isEditMode ? 'Änderungen speichern' : 'Schlaf speichern'),
          icon: CupertinoIcons.moon_fill,
          isLoading: _saving,
          expand: true,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Helper widgets
// ═════════════════════════════════════════════════════════════════════════════

class _EditorSection extends StatelessWidget {
  const _EditorSection({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _kNightPurple,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.icon,
    required this.dateTime,
    required this.onTap,
  });
  final IconData icon;
  final DateTime dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final dayStr =
        '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap();
      },
      scaleFactor: 0.97,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: _kNightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kNightBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: _kNightPurple),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStr,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _kNightPurple,
                  ),
                ),
                Text(
                  dayStr,
                  style:
                      tt.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
