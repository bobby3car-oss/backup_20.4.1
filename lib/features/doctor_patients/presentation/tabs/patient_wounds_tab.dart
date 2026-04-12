import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../features/wound/domain/wound_entry.dart';
import '../../../../features/assistant/domain/wound_analysis_result.dart';
import '../../../../ui/ui.dart';
import '../../data/doctor_patient_repository.dart';
import 'wound_photo_timeline.dart';

/// Read-only list of a patient's wound documentation entries.
class PatientWoundsTab extends StatefulWidget {
  const PatientWoundsTab({super.key, required this.patientId});

  final String patientId;

  @override
  State<PatientWoundsTab> createState() => _PatientWoundsTabState();
}

class _PatientWoundsTabState extends State<PatientWoundsTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = DoctorPatientRepository();
  bool _showTimeline = false;

  @override
  bool get wantKeepAlive => true;

  String _formatDate(DateTime dt) =>
      '${dt.day}.${dt.month}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<WoundEntry>>(
      stream: _repo.watchPatientWounds(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final wounds = snapshot.data ?? [];
        if (wounds.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.healing_rounded, size: 48, color: AppColors.grey400),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Keine Wunddokumentation vorhanden',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // View toggle: List ↔ Timeline
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: Row(
                children: [
                  _ViewToggleButton(
                    icon: Icons.list_rounded,
                    label: 'Liste',
                    selected: !_showTimeline,
                    onTap: () => setState(() => _showTimeline = false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ViewToggleButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Verlauf',
                    selected: _showTimeline,
                    onTap: () => setState(() => _showTimeline = true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showTimeline
                  ? WoundPhotoTimeline(wounds: wounds)
                  : ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: wounds.length,
          itemBuilder: (context, index) {
            final wound = wounds[index];
            return GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.healing_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          wound.bodyLocation ?? 'Keine Angabe',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      _PainBadge(level: wound.pain),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(wound.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (wound.note.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(wound.note, style: const TextStyle(fontSize: 13)),
                  ],
                  if (wound.photoPath != null ||
                      wound.photoUrl != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _WoundPhotoThumbnail(
                      photoPath: wound.photoPath,
                      photoUrl: wound.photoUrl,
                    ),
                  ],
                  if (wound.metadata['bellaAnalysis'] != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _BellaAnalysisBadge(
                      analysis: WoundAnalysisResult.fromJson(
                        Map<String, dynamic>.from(
                            wound.metadata['bellaAnalysis'] as Map),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
            ),
          ],
        );
      },
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.grey300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? AppColors.primary : AppColors.grey500),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PainBadge extends StatelessWidget {
  const _PainBadge({required this.level});

  final int level;

  Color get _color {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        '$level/10',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wound Photo Thumbnail
// ─────────────────────────────────────────────────────────────────────────────

class _WoundPhotoThumbnail extends StatelessWidget {
  const _WoundPhotoThumbnail({this.photoPath, this.photoUrl});

  final String? photoPath;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    final hasLocal =
        path != null && path.trim().isNotEmpty && File(path.trim()).existsSync();
    final hasRemote = photoUrl != null && photoUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: hasLocal
            ? Image.file(File(path.trim()), fit: BoxFit.cover)
            : hasRemote
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined,
            size: 30, color: AppColors.grey400),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bella AI Analysis Badge (expandable)
// ─────────────────────────────────────────────────────────────────────────────

class _BellaAnalysisBadge extends StatefulWidget {
  const _BellaAnalysisBadge({required this.analysis});

  final WoundAnalysisResult analysis;

  @override
  State<_BellaAnalysisBadge> createState() => _BellaAnalysisBadgeState();
}

class _BellaAnalysisBadgeState extends State<_BellaAnalysisBadge> {
  bool _expanded = false;

  Color get _statusColor => switch (widget.analysis.status) {
        'green' => AppColors.success,
        'yellow' => AppColors.warning,
        'red' => AppColors.error,
        _ => AppColors.grey400,
      };

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: _statusColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(a.statusEmoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'KI: ${a.statusLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: _statusColor,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.sm),
          if (a.observations.isNotEmpty)
            ...a.observations.map(
              (obs) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(obs,
                          style:
                              const TextStyle(fontSize: 12, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          if (a.recommendation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(a.recommendation,
                        style:
                            const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
          if (a.comparisonNote != null &&
              a.comparisonNote!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(a.comparisonNote!,
                        style:
                            const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
