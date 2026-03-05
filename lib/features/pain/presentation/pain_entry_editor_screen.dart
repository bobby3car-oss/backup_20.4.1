import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/pain_repository_sync.dart';
import '../domain/pain_entry.dart';

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
  }

  void _fillFrom(PainEntry entry) {
    _occurredAt = entry.occurredAt;
    _painLevel = entry.painLevel.toDouble();
    _locationController.text = entry.location ?? '';
    _noteController.text = entry.note;
    _triggerController.text = entry.trigger ?? '';
    _medicationTaken = entry.medicationTaken;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GlassPage(
      title: _isEditMode ? 'Eintrag bearbeiten' : 'Eintrag erstellen',
      titleEmoji: '😣',
      titleColor: AppColors.warning,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Schmerzlevel: ${_painLevel.round()} / 10',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                min: 0,
                max: 10,
                divisions: 10,
                value: _painLevel,
                label: _painLevel.round().toString(),
                onChanged: (value) => setState(() => _painLevel = value),
              ),
              const SizedBox(height: 12),
              _DateTimeRow(
                label: 'Datum',
                value: _formatDate(_occurredAt),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              _DateTimeRow(
                label: 'Uhrzeit',
                value: _formatTime(_occurredAt),
                onTap: _pickTime,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Ort (optional)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _triggerController,
                decoration: const InputDecoration(
                  labelText: 'Trigger (optional)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Notiz'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<bool?>(
                initialValue: _medicationTaken,
                items: const [
                  DropdownMenuItem<bool?>(
                    value: null,
                    child: Text('Medikation genommen: Unbekannt'),
                  ),
                  DropdownMenuItem<bool?>(
                    value: true,
                    child: Text('Medikation genommen: Ja'),
                  ),
                  DropdownMenuItem<bool?>(
                    value: false,
                    child: Text('Medikation genommen: Nein'),
                  ),
                ],
                onChanged: (value) => setState(() => _medicationTaken = value),
                decoration: const InputDecoration(labelText: 'Medikation'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Speichert...' : 'Speichern'),
              ),
              if (_isEditMode) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _saving ? null : _delete,
                  child: const Text('Löschen'),
                ),
              ],
            ],
          ),
        ),
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
    if (picked == null) return;
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
    if (picked == null) return;
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

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onTap,
    );
  }
}
