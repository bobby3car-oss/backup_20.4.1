import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/pain_repository_sync.dart';
import '../domain/pain_entry.dart';
import '../../../ui/theme/app_icons.dart';

class PainEntryEditorScreen extends StatefulWidget {
  const PainEntryEditorScreen({super.key, this.initialEntry, this.entryId});

  final PainEntry? initialEntry;
  final String? entryId;

  @override
  State<PainEntryEditorScreen> createState() => _PainEntryEditorScreenState();
}

class _PainEntryEditorScreenState extends State<PainEntryEditorScreen> {
  static final PainRepositorySync _repository = PainRepositorySync.instance;

  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  final _triggerController = TextEditingController();

  PainEntry? _editing;
  bool _loading = true;
  bool _saving = false;

  DateTime _occurredAt = DateTime.now();
  double _painLevel = 4;
  bool? _medicationTaken;
  PainType? _painType;
  BodyRegion? _bodyRegion;
  int? _durationMinutes;

  bool get _isEditMode => _editing != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    _triggerController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    PainEntry? initial = widget.initialEntry;
    String? entryId = widget.entryId;

    if (routeArgs is PainEntry) {
      initial = routeArgs;
    } else if (routeArgs is Map) {
      if (routeArgs['entry'] is PainEntry) {
        initial = routeArgs['entry'] as PainEntry;
      }
      entryId ??= routeArgs['entryId']?.toString();
    } else if (routeArgs is String && routeArgs.trim().isNotEmpty) {
      entryId ??= routeArgs.trim();
    }

    if (initial == null && entryId != null) {
      initial = await _repository.getById(entryId);
    }

    _editing = initial;
    if (initial != null) {
      _fillFrom(initial);
    } else {
      _fillDefaults();
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _fillDefaults() {
    final now = DateTime.now();
    _occurredAt = now;
    _painLevel = 4;
    _locationController.text = '';
    _noteController.text = '';
    _triggerController.text = '';
    _medicationTaken = null;
    _painType = null;
    _bodyRegion = null;
    _durationMinutes = null;
  }

  void _fillFrom(PainEntry entry) {
    _occurredAt = entry.occurredAt;
    _painLevel = entry.painLevel.toDouble();
    _locationController.text = entry.location ?? '';
    _noteController.text = entry.note;
    _triggerController.text = entry.trigger ?? '';
    _medicationTaken = entry.medicationTaken;
    _painType = entry.painType;
    _bodyRegion = entry.bodyRegion;
    _durationMinutes = entry.durationMinutes;
  }

  Color _colorForLevel(int level) {
    if (level <= 2) return const Color(0xFF34C759);
    if (level <= 4) return const Color(0xFFFFCC00);
    if (level <= 6) return const Color(0xFFFF9500);
    if (level <= 8) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3B30);
  }

  String _painDescription(int level) {
    if (level == 0) return 'Schmerzfrei';
    if (level <= 2) return 'Leicht';
    if (level <= 4) return 'Mäßig';
    if (level <= 6) return 'Mittel';
    if (level <= 8) return 'Stark';
    return 'Sehr stark';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final level = _painLevel.round();
    final color = _colorForLevel(level);

    return GlassPage(
      title: _isEditMode ? 'Eintrag bearbeiten' : 'Neuer Eintrag',
      titleIcon: AppIcons.edit,
      titleColor: AppColors.warning,
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // ── Pain level card ──────────────────────────────────
        _EditorCard(
          borderColor: color.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(icon: AppIcons.pain, iconColor: AppIcons.painColor, title: 'Schmerzlevel'),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(level ~/ 2),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$level',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        '$level/10 – ${_painDescription(level)}',
                        key: ValueKey(level),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: color,
                  inactiveTrackColor: const Color(0xFFE5E5EA),
                  thumbColor: Colors.white,
                  overlayColor: color.withValues(alpha: 0.12),
                  trackHeight: 8,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 14),
                ),
                child: Slider(
                  min: 0,
                  max: 10,
                  divisions: 10,
                  value: _painLevel,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _painLevel = value);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Keine',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                    Text('Unerträglich',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Date & Time card ──────────────────────────────────
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(icon: AppIcons.appointments,
                    iconColor: AppIcons.appointmentsColor, title: 'Wann?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateTimeTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Datum',
                      value: _formatDate(_occurredAt),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateTimeTile(
                      icon: Icons.schedule_rounded,
                      label: 'Uhrzeit',
                      value: _formatTime(_occurredAt),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Body region card ─────────────────────────────────
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(icon: AppIcons.location, iconColor: AppIcons.locationColor, title: 'Wo tut es weh?'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: BodyRegion.values.map((region) {
                  final selected = _bodyRegion == region;
                  return _SelectableChip(
                    label: region.label,
                    selected: selected,
                    onTap: () => setState(
                      () => _bodyRegion = selected ? null : region,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Pain type card ───────────────────────────────────
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(icon: AppIcons.search,
                    iconColor: AppIcons.searchColor, title: 'Art der Schmerzen'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: PainType.values.map((type) {
                  final selected = _painType == type;
                  return _SelectableChip(
                    label: type.label,
                    selected: selected,
                    onTap: () => setState(
                      () => _painType = selected ? null : type,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Duration card ────────────────────────────────────
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(icon: AppIcons.timer, iconColor: AppIcons.timerColor, title: 'Dauer'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final min in [5, 15, 30, 60, 120, 0])
                    _SelectableChip(
                      label: min == 0
                          ? 'Dauerhaft'
                          : min < 60
                              ? '$min Min.'
                              : '${min ~/ 60} Std.',
                      selected: _durationMinutes == min,
                      onTap: () => setState(
                        () => _durationMinutes =
                            _durationMinutes == min ? null : min,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Details card ─────────────────────────────────────
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(icon: AppIcons.notes,
                    iconColor: AppIcons.notesColor, title: 'Details'),
              const SizedBox(height: 10),
              _StyledTextField(
                controller: _locationController,
                label: 'Ort (optional)',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 10),
              _StyledTextField(
                controller: _triggerController,
                label: 'Auslöser (optional)',
                icon: Icons.flash_on_outlined,
              ),
              const SizedBox(height: 10),
              _StyledTextField(
                controller: _noteController,
                label: 'Notiz (optional)',
                icon: Icons.notes_rounded,
                maxLines: 4,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Medication card ──────────────────────────────────
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(icon: AppIcons.medication,
                    iconColor: AppIcons.medicationColor, title: 'Medikation'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MedChip(
                    label: 'Ja',
                    selected: _medicationTaken == true,
                    color: const Color(0xFF34C759),
                    onTap: () => setState(() => _medicationTaken =
                        _medicationTaken == true ? null : true),
                  ),
                  const SizedBox(width: 8),
                  _MedChip(
                    label: 'Nein',
                    selected: _medicationTaken == false,
                    color: const Color(0xFFFF9500),
                    onTap: () => setState(() => _medicationTaken =
                        _medicationTaken == false ? null : false),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Save button ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A74FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEditMode ? 'Änderungen speichern' : 'Speichern'),
            ),
          ),
        ),

        if (_isEditMode) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _saving ? null : _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF3B30),
                  side: const BorderSide(color: Color(0xFFFF3B30)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Eintrag löschen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _occurredAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _occurredAt.hour,
        _occurredAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _occurredAt = DateTime(
        _occurredAt.year,
        _occurredAt.month,
        _occurredAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.trim().isEmpty) {
        _showError('Bitte zuerst anmelden.');
        return;
      }
      final editing = _editing;
      final entry = PainEntry(
        id: editing?.id ?? 'pain_${now.microsecondsSinceEpoch}',
        ownerId: editing?.ownerId ?? uid,
        occurredAt: _occurredAt,
        painLevel: _painLevel.round().clamp(0, 10),
        location: _textOrNull(_locationController.text),
        note: _noteController.text.trim(),
        trigger: _textOrNull(_triggerController.text),
        medicationTaken: _medicationTaken,
        painType: _painType,
        bodyRegion: _bodyRegion,
        durationMinutes: _durationMinutes,
        createdAt: editing?.createdAt ?? now,
        updatedAt: now,
        metadata: editing?.metadata ?? const <String, dynamic>{},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final editing = _editing;
    if (editing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text(
          'Dieser Eintrag wird unwiderruflich gelöscht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Löschen',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await _repository.delete(editing.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _textOrNull(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    return '$dd.$mm.${value.year}';
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Supporting widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _EditorCard extends StatelessWidget {
  const _EditorCard({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon,
    required this.iconColor, required this.title});

  final IconData icon;


  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIcon(icon: icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0A74FF).withValues(alpha: 0.1)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF0A74FF)
                : const Color(0xFFE5E5EA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? const Color(0xFF0A74FF)
                : const Color(0xFF3C3C43),
          ),
        ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0A74FF)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF0A74FF), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _MedChip extends StatelessWidget {
  const _MedChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : const Color(0xFFE5E5EA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded, size: 16, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? color : const Color(0xFF3C3C43),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
