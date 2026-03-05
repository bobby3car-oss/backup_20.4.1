import 'package:flutter/material.dart';

import '../../../../features/wound/domain/wound_entry.dart';
import '../../../../ui/ui.dart';
import '../../data/doctor_patient_repository.dart';

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

        return ListView.builder(
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
                  if (wound.photoPath != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.photo_rounded,
                            size: 16, color: AppColors.grey600),
                        const SizedBox(width: 4),
                        Text(
                          'Foto vorhanden',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
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
