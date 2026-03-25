import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/task_orchestrator.dart';
import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../data/wound_repository_sync.dart';
import '../domain/wound_entry.dart';
import '../../../ui/theme/app_icons.dart';

class WoundScreen extends StatefulWidget {
  const WoundScreen({super.key, this.relatedTaskId});

  final String? relatedTaskId;

  @override
  State<WoundScreen> createState() => _WoundScreenState();
}

class _WoundScreenState extends State<WoundScreen> {
  static final WoundRepositorySync _repository = WoundRepositorySync.instance;
  static final ImagePicker _picker = ImagePicker();
  static final TaskOrchestrator _taskOrchestrator = TaskOrchestrator();

  final TextEditingController _noteController = TextEditingController();
  int _pain = 3;
  String? _bodyLocation;
  String? _photoPath;
  String? _draftEntryId;
  String? _resolvedTaskId;
  bool _resolvedRouteArgs = false;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedRouteArgs) return;
    _resolvedRouteArgs = true;

    _resolvedTaskId = widget.relatedTaskId;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final map = Map<String, dynamic>.from(args);
      _resolvedTaskId =
          (map['taskId'] as String?) ??
          (map['relatedTaskId'] as String?) ??
          _resolvedTaskId;
    } else if (args is String && args.isNotEmpty) {
      _resolvedTaskId = args;
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final entryId = _draftEntryId ?? WoundEntry.generateId(now);
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = WoundEntry(
        id: entryId,
        ownerId: uid,
        createdAt: now,
        updatedAt: now,
        bodyLocation: _bodyLocation,
        pain: _pain.clamp(0, 10),
        note: _noteController.text.trim(),
        photoPath: _photoPath,
        relatedTaskId: widget.relatedTaskId,
        metadata: const <String, dynamic>{'source': 'wound_screen'},
      );
      await _repository.upsert(entry);
      final relatedTaskId = _resolvedTaskId;
      if (relatedTaskId != null && relatedTaskId.isNotEmpty) {
        await _taskOrchestrator.setState(relatedTaskId, TaskState.done);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickPhoto() async {
    XFile? selected;

    try {
      selected = await _picker.pickImage(source: ImageSource.camera);
    } on PlatformException {
      selected = await _picker.pickImage(source: ImageSource.gallery);
    } catch (_) {
      selected = null;
    }

    if (selected == null) return;

    try {
      final now = DateTime.now();
      final entryId = _draftEntryId ?? WoundEntry.generateId(now);
      final docs = await getApplicationDocumentsDirectory();
      final woundsDir = Directory('${docs.path}/wounds');
      if (!await woundsDir.exists()) {
        await woundsDir.create(recursive: true);
      }
      final extension = _fileExtension(selected.path);
      final targetPath = '${woundsDir.path}/$entryId$extension';
      final copied = await File(selected.path).copy(targetPath);

      if (!mounted) return;
      setState(() {
        _draftEntryId = entryId;
        _photoPath = copied.path;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e, fallback: 'Foto konnte nicht geladen werden.'))),
        );
      }
    }
  }

  String _fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return '.jpg';
    return path.substring(dot);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassPage(
      title: 'Wunddokumentation',
      titleIcon: AppIcons.wound,
      titleColor: AppColors.success,
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.xl),
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: AppRadius.borderRadiusLg,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Foto', style: tt.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.borderRadiusMd,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.grey100,
                  alignment: Alignment.center,
                  child: _photoPath == null
                      ? const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 34,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Noch kein Foto',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : Image.file(
                          File(_photoPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassButton(
                onPressed: _pickPhoto,
                label: 'Foto hinzufügen',
                icon: Icons.add_a_photo_outlined,
                expand: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: AppRadius.borderRadiusLg,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Schmerzscore', style: tt.titleMedium),
                  const Spacer(),
                  Text(
                    '$_pain/10',
                    style: tt.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _pain.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (value) {
                  setState(() => _pain = value.round());
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _bodyLocation,
                decoration: const InputDecoration(
                  labelText: 'Körperstelle (optional)',
                ),
                items: const <String>['Knie', 'Hüfte', 'Bauch', 'Sonstiges']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _bodyLocation = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              GlassTextField(
                controller: _noteController,
                label: 'Notiz',
                hint: 'Wie sieht die Wunde aus? Besonderheiten?',
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GlassButton(
                onPressed: _saving ? null : _save,
                label: _saving ? 'Speichert...' : 'Speichern',
                icon: Icons.check_rounded,
                expand: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
