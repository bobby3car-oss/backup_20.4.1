import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/doctor_notes_repository.dart';
import '../domain/doctor_note.dart';
import '../../../l10n/app_localizations.dart';

/// Available tags for categorizing doctor notes.
const _availableTags = ['Befund', 'Verlauf', 'TODO', 'Wichtig', 'Medikation'];

/// Note type display config.
const _noteTypeConfig = <NoteType, ({IconData icon, String label, Color color})>{
  NoteType.freeform: (
    icon: Icons.notes_rounded,
    label: 'Freitext',
    color: AppColors.grey500,
  ),
  NoteType.soap: (
    icon: Icons.medical_information_rounded,
    label: 'SOAP',
    color: AppColors.primary,
  ),
  NoteType.discharge: (
    icon: Icons.exit_to_app_rounded,
    label: 'Entlassung',
    color: AppColors.accent,
  ),
};

/// Tab shown inside PatientDetailScreen for private doctor notes.
class DoctorNotesTab extends StatefulWidget {
  const DoctorNotesTab({super.key, required this.patientId, this.doctorUid});

  final String patientId;

  /// Doctor UID override for staff mode.
  final String? doctorUid;

  @override
  State<DoctorNotesTab> createState() => _DoctorNotesTabState();
}

class _DoctorNotesTabState extends State<DoctorNotesTab> {
  late final DoctorNotesRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = DoctorNotesRepository(overrideDoctorUid: widget.doctorUid);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<List<DoctorNote>>(
      stream: _repo.watchNotes(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data ?? [];

        if (notes.isEmpty) {
          return _EmptyState(onAdd: () => _showEditor(context));
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                100,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return FadeSlideIn(
                  delay: Duration(milliseconds: 40 * index),
                  child: _NoteCard(
                    note: note,
                    onTap: () => _showEditor(context, note: note),
                    onTogglePin: () async {
                      try {
                        await _repo.togglePin(note.id, !note.pinned);
                      } catch (e) {
                        debugPrint('Error toggling pin: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text(l.pinError)),
                          );
                        }
                      }
                    },
                    onDelete: () => _confirmDelete(note),
                  ),
                );
              },
            ),
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: Row(
                children: [
                  _MiniFab(
                    icon: Icons.medical_information_rounded,
                    label: 'SOAP',
                    color: AppColors.primary,
                    onTap: () => _showEditor(context,
                        initialType: NoteType.soap),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MiniFab(
                    icon: Icons.exit_to_app_rounded,
                    label: 'Entlassung',
                    color: AppColors.accent,
                    onTap: () => _showEditor(context,
                        initialType: NoteType.discharge),
                  ),
                  const Spacer(),
                  PressableScale(
                    child: FloatingActionButton(
                      onPressed: () => _showEditor(context),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditor(BuildContext context,
      {DoctorNote? note, NoteType? initialType}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteEditorSheet(
        patientId: widget.patientId,
        note: note,
        repo: _repo,
        initialType: initialType,
      ),
    );
  }

  Future<void> _confirmDelete(DoctorNote note) async {
    final l = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.noteDelete),
        content: Text(l.notizLoeschenBestaetigung(note.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _repo.deleteNote(note.id);
      } catch (e) {
        debugPrint('Error deleting note: $e');
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.noteDeleteError)),
          );
        }
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Note Card
// ─────────────────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  final DoctorNote note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typeConfig = _noteTypeConfig[note.noteType]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PressableScale(
        child: GlassCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.pinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.push_pin_rounded,
                          size: 14, color: AppColors.warning),
                    ),
                  if (note.noteType != NoteType.freeform) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeConfig.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeConfig.icon,
                              size: 12, color: typeConfig.color),
                          const SizedBox(width: 3),
                          Text(
                            typeConfig.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: typeConfig.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    onSelected: (v) {
                      if (v == 'pin') onTogglePin();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(
                            note.pinned ? 'Lospinnen' : 'Anpinnen'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l.delete,
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
              // ── SOAP preview ────────────────────────────────────
              if (note.noteType == NoteType.soap &&
                  note.soapData != null &&
                  !note.soapData!.isEmpty) ...[
                const SizedBox(height: 6),
                _SoapPreview(soap: note.soapData!),
              ]
              // ── Discharge preview ───────────────────────────────
              else if (note.noteType == NoteType.discharge &&
                  note.dischargeData != null &&
                  !note.dischargeData!.isEmpty) ...[
                const SizedBox(height: 6),
                _DischargePreview(data: note.dischargeData!),
              ]
              // ── Freeform content ────────────────────────────────
              else if (note.content.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.tags.map((tag) {
                    final color = _tagColor(tag);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                _formatDate(note.updatedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _tagColor(String tag) => switch (tag) {
        'Befund' => AppColors.primary,
        'Verlauf' => AppColors.success,
        'TODO' => AppColors.warning,
        'Wichtig' => AppColors.error,
        'Medikation' => AppColors.accent,
        _ => AppColors.grey500,
      };

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} – '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

// ── SOAP Preview (compact card-inlined) ─────────────────────────────────────

class _SoapPreview extends StatelessWidget {
  const _SoapPreview({required this.soap});
  final SoapData soap;

  @override
  Widget build(BuildContext context) {
    final entries = [
      if (soap.subjective.isNotEmpty) ('S', soap.subjective),
      if (soap.objective.isNotEmpty) ('O', soap.objective),
      if (soap.assessment.isNotEmpty) ('A', soap.assessment),
      if (soap.plan.isNotEmpty) ('P', soap.plan),
    ];
    return Column(
      children: entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 18,
                child: Text(
                  e.$1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  e.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Discharge Preview (compact card-inlined) ────────────────────────────────

class _DischargePreview extends StatelessWidget {
  const _DischargePreview({required this.data});
  final DischargeData data;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    if (data.diagnosis.isNotEmpty) lines.add('Dx: ${data.diagnosis}');
    if (data.procedure.isNotEmpty) lines.add('OP: ${data.procedure}');
    if (data.medication.isNotEmpty) lines.add('Rx: ${data.medication}');
    if (data.followUp.isNotEmpty) lines.add('F/U: ${data.followUp}');
    return Text(
      lines.join(' · '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        height: 1.3,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editor Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({
    required this.patientId,
    required this.repo,
    this.note,
    this.initialType,
  });

  final String patientId;
  final DoctorNotesRepository repo;
  final DoctorNote? note;
  final NoteType? initialType;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final Set<String> _selectedTags;
  late NoteType _noteType;
  bool _saving = false;

  // SOAP controllers
  late final TextEditingController _sCtrl;
  late final TextEditingController _oCtrl;
  late final TextEditingController _aCtrl;
  late final TextEditingController _pCtrl;

  // Discharge controllers
  late final TextEditingController _diagnosisCtrl;
  late final TextEditingController _procedureCtrl;
  late final TextEditingController _findingsCtrl;
  late final TextEditingController _medicationCtrl;
  late final TextEditingController _followUpCtrl;
  late final TextEditingController _restrictionsCtrl;
  late final TextEditingController _dischargeNotesCtrl;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _noteType = widget.initialType ?? note?.noteType ?? NoteType.freeform;
    _titleCtrl = TextEditingController(text: note?.title ?? '');
    _contentCtrl = TextEditingController(text: note?.content ?? '');
    _selectedTags = Set.from(note?.tags ?? []);

    final soap = note?.soapData ?? const SoapData();
    _sCtrl = TextEditingController(text: soap.subjective);
    _oCtrl = TextEditingController(text: soap.objective);
    _aCtrl = TextEditingController(text: soap.assessment);
    _pCtrl = TextEditingController(text: soap.plan);

    final dc = note?.dischargeData ?? const DischargeData();
    _diagnosisCtrl = TextEditingController(text: dc.diagnosis);
    _procedureCtrl = TextEditingController(text: dc.procedure);
    _findingsCtrl = TextEditingController(text: dc.findings);
    _medicationCtrl = TextEditingController(text: dc.medication);
    _followUpCtrl = TextEditingController(text: dc.followUp);
    _restrictionsCtrl = TextEditingController(text: dc.restrictions);
    _dischargeNotesCtrl = TextEditingController(text: dc.notes);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _sCtrl.dispose();
    _oCtrl.dispose();
    _aCtrl.dispose();
    _pCtrl.dispose();
    _diagnosisCtrl.dispose();
    _procedureCtrl.dispose();
    _findingsCtrl.dispose();
    _medicationCtrl.dispose();
    _followUpCtrl.dispose();
    _restrictionsCtrl.dispose();
    _dischargeNotesCtrl.dispose();
    super.dispose();
  }

  SoapData _buildSoap() => SoapData(
        subjective: _sCtrl.text.trim(),
        objective: _oCtrl.text.trim(),
        assessment: _aCtrl.text.trim(),
        plan: _pCtrl.text.trim(),
      );

  DischargeData _buildDischarge() => DischargeData(
        diagnosis: _diagnosisCtrl.text.trim(),
        procedure: _procedureCtrl.text.trim(),
        findings: _findingsCtrl.text.trim(),
        medication: _medicationCtrl.text.trim(),
        followUp: _followUpCtrl.text.trim(),
        restrictions: _restrictionsCtrl.text.trim(),
        notes: _dischargeNotesCtrl.text.trim(),
      );

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    final soap = _noteType == NoteType.soap ? _buildSoap() : null;
    final discharge =
        _noteType == NoteType.discharge ? _buildDischarge() : null;
    final content = _noteType == NoteType.freeform
        ? _contentCtrl.text.trim()
        : '';

    try {
      if (_isEditing) {
        await widget.repo.updateNote(
          noteId: widget.note!.id,
          title: title,
          content: content,
          tags: _selectedTags.toList(),
          noteType: _noteType,
          soapData: soap,
          dischargeData: discharge,
        );
      } else {
        await widget.repo.createNote(
          patientId: widget.patientId,
          title: title,
          content: content,
          tags: _selectedTags.toList(),
          noteType: _noteType,
          soapData: soap,
          dischargeData: discharge,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.saveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        bottomInset + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              _isEditing ? 'Notiz bearbeiten' : 'Neue Notiz',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Note Type selector ───────────────────────────────
            _NoteTypeSelector(
              selected: _noteType,
              onChanged: (t) => setState(() => _noteType = t),
            ),
            const SizedBox(height: AppSpacing.lg),

            GlassTextField(
              controller: _titleCtrl,
              label: 'Titel',
              prefixIcon: Icons.title_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Type-specific fields ─────────────────────────────
            if (_noteType == NoteType.freeform) ...[
              GlassTextField(
                controller: _contentCtrl,
                label: 'Inhalt',
                prefixIcon: Icons.notes_rounded,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
              ),
            ] else if (_noteType == NoteType.soap) ...[
              _SoapField(letter: 'S', label: 'Subjektiv', hint: 'Beschwerden, Anamnese', controller: _sCtrl),
              const SizedBox(height: AppSpacing.sm),
              _SoapField(letter: 'O', label: 'Objektiv', hint: 'Befunde, Vitalwerte', controller: _oCtrl),
              const SizedBox(height: AppSpacing.sm),
              _SoapField(letter: 'A', label: 'Assessment', hint: 'Diagnosen, Beurteilung', controller: _aCtrl),
              const SizedBox(height: AppSpacing.sm),
              _SoapField(letter: 'P', label: 'Plan', hint: 'Therapie, Verordnungen', controller: _pCtrl),
            ] else if (_noteType == NoteType.discharge) ...[
              _DischargeField(label: 'Diagnose', icon: Icons.local_hospital_rounded, controller: _diagnosisCtrl),
              const SizedBox(height: AppSpacing.sm),
              _DischargeField(label: 'Eingriff / Prozedur', icon: Icons.content_cut_rounded, controller: _procedureCtrl),
              const SizedBox(height: AppSpacing.sm),
              _DischargeField(label: 'Befunde', icon: Icons.biotech_rounded, controller: _findingsCtrl, maxLines: 3),
              const SizedBox(height: AppSpacing.sm),
              _DischargeField(label: 'Medikation bei Entlassung', icon: Icons.medication_rounded, controller: _medicationCtrl, maxLines: 3),
              const SizedBox(height: AppSpacing.sm),
              _DischargeField(label: 'Wiedervorstellung / Follow-up', icon: Icons.event_rounded, controller: _followUpCtrl),
              const SizedBox(height: AppSpacing.sm),
              _DischargeField(label: 'Einschränkungen / Schonung', icon: Icons.do_not_disturb_alt_rounded, controller: _restrictionsCtrl, maxLines: 2),
              const SizedBox(height: AppSpacing.sm),
              _DischargeField(label: 'Sonstige Hinweise', icon: Icons.info_outline_rounded, controller: _dischargeNotesCtrl, maxLines: 3),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Tags
            Text(l.categories,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                )),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (selected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.grey300,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            GlassButton(
              onPressed: _saving ? null : _save,
              label: _saving ? 'Speichern …' : l.save,
              icon: Icons.check_rounded,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note Type Selector ──────────────────────────────────────────────────────

class _NoteTypeSelector extends StatelessWidget {
  const _NoteTypeSelector({required this.selected, required this.onChanged});
  final NoteType selected;
  final ValueChanged<NoteType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: NoteType.values.map((type) {
        final config = _noteTypeConfig[type]!;
        final isSelected = type == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != NoteType.values.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(type);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? config.color.withValues(alpha: 0.12)
                      : AppColors.grey100,
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: isSelected ? config.color : AppColors.grey300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(config.icon,
                        size: 20,
                        color: isSelected
                            ? config.color
                            : AppColors.grey500),
                    const SizedBox(height: 4),
                    Text(
                      config.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? config.color
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── SOAP Field ──────────────────────────────────────────────────────────────

class _SoapField extends StatelessWidget {
  const _SoapField({
    required this.letter,
    required this.label,
    required this.hint,
    required this.controller,
  });
  final String letter;
  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassTextField(
            controller: controller,
            label: label,
            hint: hint,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }
}

// ── Discharge Field ─────────────────────────────────────────────────────────

class _DischargeField extends StatelessWidget {
  const _DischargeField({
    required this.label,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
  });
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: controller,
      label: label,
      prefixIcon: icon,
      maxLines: maxLines,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_add_outlined,
              size: 48, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Noch keine Notizen',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Private Notizen zu diesem Patienten\nsind nur für Sie sichtbar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey400,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            onPressed: onAdd,
            label: l.ersteNotizErstellen,
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }
}

// ── Mini FAB for quick note type creation ───────────────────────────────────

class _MiniFab extends StatelessWidget {
  const _MiniFab({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderRadiusPill,
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
