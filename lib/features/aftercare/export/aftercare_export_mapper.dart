import '../domain/aftercare_item.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_phase.dart';
import '../domain/aftercare_template.dart';
import '../domain/patient_aftercare_plan.dart';

class AftercareExportMapper {
  const AftercareExportMapper._();

  static AftercarePlanPdfData mapPlan({
    required PatientAftercarePlan plan,
    String? patientName,
    String? doctorName,
    String? organizationName,
  }) {
    return AftercarePlanPdfData(
      title: plan.title,
      patientName: patientName,
      doctorName: doctorName,
      organizationName: organizationName,
      surgeryDate: plan.surgeryDate,
      effectiveFrom: plan.effectiveFrom,
      version: plan.version,
      status: plan.status.displayName,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
      phases: plan.phases.map(_mapPhase).toList(growable: false),
    );
  }

  static AftercareTemplatePdfData mapTemplate({
    required AftercareTemplate template,
    String? organizationName,
  }) {
    return AftercareTemplatePdfData(
      title: template.title,
      description: template.description,
      surgeryType: template.surgeryType,
      bodyRegion: template.bodyRegion,
      version: template.version,
      templateType: _templateTypeLabel(template.templateType),
      organizationName: organizationName,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
      phases: template.phases.map(_mapPhase).toList(growable: false),
    );
  }

  static String _templateTypeLabel(AftercareTemplateType type) {
    return switch (type) {
      AftercareTemplateType.system => 'Systemvorlage',
      AftercareTemplateType.organization => 'Organisationsvorlage',
      AftercareTemplateType.doctor => 'Arztvorlage',
    };
  }

  static AftercarePdfPhase _mapPhase(AftercarePhase phase) {
    final grouped = <AftercareItemCategory, List<AftercareItem>>{};
    for (final item in phase.items) {
      grouped.putIfAbsent(item.category, () => <AftercareItem>[]).add(item);
    }

    final sections = grouped.entries
        .map(
          (entry) => AftercarePdfCategorySection(
            category: entry.key.displayName,
            items: entry.value
                .map(
                  (item) => AftercarePdfItem(
                    title: item.title,
                    description: item.description,
                    timeLabel: _timeLabel(item),
                    notes: item.notes,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    final dayRangeLabel = phase.endDayOffset != null
        ? 'Tag ${phase.startDayOffset} bis ${phase.endDayOffset}'
        : 'Ab Tag ${phase.startDayOffset}';

    return AftercarePdfPhase(
      title: phase.title,
      dayRangeLabel: dayRangeLabel,
      sections: sections,
    );
  }

  static String _timeLabel(AftercareItem item) {
    if (item.exactDate != null) {
      final d = item.exactDate!;
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }
    if (item.startDayOffset != null && item.endDayOffset != null) {
      return 'Tag ${item.startDayOffset} bis ${item.endDayOffset}';
    }
    if (item.startDayOffset != null) {
      return 'Ab Tag ${item.startDayOffset}';
    }
    if (item.isTimeBound) {
      return 'Zeitgebunden';
    }
    return 'Nach Bedarf';
  }
}

class AftercarePlanPdfData {
  const AftercarePlanPdfData({
    required this.title,
    this.patientName,
    this.doctorName,
    this.organizationName,
    required this.surgeryDate,
    required this.effectiveFrom,
    required this.version,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.phases,
  });

  final String title;
  final String? patientName;
  final String? doctorName;
  final String? organizationName;
  final DateTime surgeryDate;
  final DateTime effectiveFrom;
  final int version;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AftercarePdfPhase> phases;
}

class AftercareTemplatePdfData {
  const AftercareTemplatePdfData({
    required this.title,
    required this.description,
    required this.surgeryType,
    required this.bodyRegion,
    required this.version,
    required this.templateType,
    this.organizationName,
    required this.createdAt,
    required this.updatedAt,
    required this.phases,
  });

  final String title;
  final String description;
  final String surgeryType;
  final String bodyRegion;
  final int version;
  final String templateType;
  final String? organizationName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AftercarePdfPhase> phases;
}

class AftercarePdfPhase {
  const AftercarePdfPhase({
    required this.title,
    required this.dayRangeLabel,
    required this.sections,
  });

  final String title;
  final String dayRangeLabel;
  final List<AftercarePdfCategorySection> sections;
}

class AftercarePdfCategorySection {
  const AftercarePdfCategorySection({
    required this.category,
    required this.items,
  });

  final String category;
  final List<AftercarePdfItem> items;
}

class AftercarePdfItem {
  const AftercarePdfItem({
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.notes,
  });

  final String title;
  final String description;
  final String timeLabel;
  final String notes;
}
