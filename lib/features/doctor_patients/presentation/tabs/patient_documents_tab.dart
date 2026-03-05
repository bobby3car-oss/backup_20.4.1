import 'package:flutter/material.dart';

import '../../../../features/documents/domain/document_item.dart';
import '../../../../ui/ui.dart';
import '../../data/doctor_patient_repository.dart';

/// Read-only list of a patient's documents.
class PatientDocumentsTab extends StatefulWidget {
  const PatientDocumentsTab({super.key, required this.patientId});

  final String patientId;

  @override
  State<PatientDocumentsTab> createState() => _PatientDocumentsTabState();
}

class _PatientDocumentsTabState extends State<PatientDocumentsTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = DoctorPatientRepository();

  @override
  bool get wantKeepAlive => true;

  String _formatDate(DateTime dt) =>
      '${dt.day}.${dt.month}.${dt.year}';

  IconData _docIcon(DocumentType type) => switch (type) {
        DocumentType.arztbrief => Icons.description_rounded,
        DocumentType.aufklaerung => Icons.fact_check_rounded,
        DocumentType.rezept => Icons.medication_rounded,
        DocumentType.befunde => Icons.biotech_rounded,
        DocumentType.sonstiges => Icons.insert_drive_file_rounded,
      };

  String _docLabel(DocumentType type) => switch (type) {
        DocumentType.arztbrief => 'Arztbrief',
        DocumentType.aufklaerung => 'Aufklärung',
        DocumentType.rezept => 'Rezept',
        DocumentType.befunde => 'Befunde',
        DocumentType.sonstiges => 'Sonstiges',
      };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<DocumentItem>>(
      stream: _repo.watchPatientDocuments(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open_rounded,
                    size: 48, color: AppColors.grey400),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Keine Dokumente vorhanden',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Icon(
                      _docIcon(doc.type),
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _docLabel(doc.type),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _formatDate(doc.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (doc.sizeBytes != null)
                    Text(
                      _formatSize(doc.sizeBytes!),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grey600,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
