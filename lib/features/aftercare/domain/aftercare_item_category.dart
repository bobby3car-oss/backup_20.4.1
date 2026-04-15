import 'package:flutter/material.dart';

/// Category of an aftercare item within a treatment phase.
enum AftercareItemCategory {
  wound,
  dressing,
  sutureRemoval,
  weightBearing,
  rom,
  physio,
  cpm,
  aid,
  medication,
  supplement,
  custom;

  static AftercareItemCategory fromString(String? value) => switch (value) {
        'wound' => AftercareItemCategory.wound,
        'dressing' => AftercareItemCategory.dressing,
        'sutureRemoval' || 'suture_removal' => AftercareItemCategory.sutureRemoval,
        'weightBearing' || 'weight_bearing' => AftercareItemCategory.weightBearing,
        'rom' => AftercareItemCategory.rom,
        'physio' => AftercareItemCategory.physio,
        'cpm' => AftercareItemCategory.cpm,
        'aid' => AftercareItemCategory.aid,
        'medication' => AftercareItemCategory.medication,
        'supplement' => AftercareItemCategory.supplement,
        'custom' => AftercareItemCategory.custom,
        _ => AftercareItemCategory.custom,
      };

  /// German display label used in the builder UI.
  String get displayName => switch (this) {
        AftercareItemCategory.wound => 'Wunde',
        AftercareItemCategory.dressing => 'Verband',
        AftercareItemCategory.sutureRemoval => 'Fäden / Klammern',
        AftercareItemCategory.weightBearing => 'Belastung',
        AftercareItemCategory.rom => 'Bewegungsumfang',
        AftercareItemCategory.physio => 'Physiotherapie',
        AftercareItemCategory.cpm => 'CPM-Schiene',
        AftercareItemCategory.aid => 'Hilfsmittel',
        AftercareItemCategory.medication => 'Medikamente',
        AftercareItemCategory.supplement => 'Supplemente',
        AftercareItemCategory.custom => 'Individuell',
      };

  /// Icon for the category chip / builder step.
  IconData get icon => switch (this) {
        AftercareItemCategory.wound => Icons.healing_rounded,
        AftercareItemCategory.dressing => Icons.medical_services_rounded,
        AftercareItemCategory.sutureRemoval => Icons.content_cut_rounded,
        AftercareItemCategory.weightBearing => Icons.fitness_center_rounded,
        AftercareItemCategory.rom => Icons.open_with_rounded,
        AftercareItemCategory.physio => Icons.accessibility_new_rounded,
        AftercareItemCategory.cpm => Icons.settings_rounded,
        AftercareItemCategory.aid => Icons.support_rounded,
        AftercareItemCategory.medication => Icons.medication_rounded,
        AftercareItemCategory.supplement => Icons.eco_rounded,
        AftercareItemCategory.custom => Icons.edit_note_rounded,
      };
}

/// The type/scope of an aftercare template.
enum AftercareTemplateType {
  system,
  organization,
  doctor;

  static AftercareTemplateType fromString(String? value) => switch (value) {
        'system' => AftercareTemplateType.system,
        'organization' => AftercareTemplateType.organization,
        'doctor' => AftercareTemplateType.doctor,
        _ => AftercareTemplateType.doctor,
      };
}
