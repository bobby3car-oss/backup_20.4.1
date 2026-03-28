import '../l10n/app_localizations.dart';

/// Resolves a [templateId] from [care_plan_templates.dart] into
/// a localized (title, subtitle) pair at display time.
///
/// Returns `null` if [templateId] is unknown – the caller should
/// fall back to [TimelineItem.title] / [TimelineItem.subtitle].
(String title, String subtitle)? localizedTemplate(
  AppLocalizations l,
  String templateId,
) {
  return switch (templateId) {
    // ── Preop ──
    'preop_documents' => (l.templatePreopDocumentsTitle, l.templatePreopDocumentsSubtitle),
    'preop_companion' => (l.templatePreopCompanionTitle, l.templatePreopCompanionSubtitle),
    'preop_bag' => (l.templatePreopBagTitle, l.templatePreopBagSubtitle),
    // ── OP-Tag ──
    'opday_admission' => (l.templateOpdayAdmissionTitle, l.templateOpdayAdmissionSubtitle),
    'opday_fasting' => (l.templateOpdayFastingTitle, l.templateOpdayFastingSubtitle),
    'opday_info' => (l.templateOpdayInfoTitle, l.templateOpdayInfoSubtitle),
    'opday_mobilization' => (l.templateOpdayMobilizationTitle, l.templateOpdayMobilizationSubtitle),
    // ── Week 1 · universal ──
    'week1_wound_photo' => (l.templateWeek1WoundPhotoTitle, l.templateWeek1WoundPhotoSubtitle),
    'week1_pain_score' => (l.templateWeek1PainScoreTitle, l.templateWeek1PainScoreSubtitle),
    'week1_vitals' => (l.templateWeek1VitalsTitle, l.templateWeek1VitalsSubtitle),
    'week1_dressing' => (l.templateWeek1DressingTitle, l.templateWeek1DressingSubtitle),
    'meds_morning' => (l.templateMedsMorningTitle, l.templateMedsMorningSubtitle),
    'meds_midday' => (l.templateMedsMorningTitle, l.templateMedsMiddaySubtitle),
    'meds_evening' => (l.templateMedsMorningTitle, l.templateMedsEveningSubtitle),
    'week1_hydration' => (l.templateWeek1HydrationTitle, l.templateWeek1HydrationSubtitle),
    'week1_redflags' => (l.templateWeek1RedFlagsTitle, l.templateWeek1RedFlagsSubtitle),
    // ── Week 1 · Ortho ──
    'week1_compression' => (l.templateWeek1CompressionTitle, l.templateWeek1CompressionSubtitle),
    'week1_leg_exercises' => (l.templateWeek1LegExercisesTitle, l.templateWeek1LegExercisesSubtitle),
    'week1_mobilization' => (l.templateWeek1MobilizationTitle, l.templateWeek1MobilizationSubtitle),
    'week1_joint_rom' => (l.templateWeek1JointRomTitle, l.templateWeek1JointRomSubtitle),
    // ── Week 1 · Cardio ──
    'week1_breathing_cardio' => (l.templateWeek1BreathingCardioTitle, l.templateWeek1BreathingCardioSubtitle),
    'week1_sternum_protection' => (l.templateWeek1SternumTitle, l.templateWeek1SternumSubtitle),
    'week1_blood_pressure' => (l.templateWeek1BloodPressureTitle, l.templateWeek1BloodPressureSubtitle),
    'week1_cardiac_rehab' => (l.templateWeek1CardiacRehabTitle, l.templateWeek1CardiacRehabSubtitle),
    // ── Week 1 · Abdominal ──
    'week1_diet_buildup' => (l.templateWeek1DietBuildupTitle, l.templateWeek1DietBuildupSubtitle),
    'week1_no_straining' => (l.templateWeek1NoStrainingTitle, l.templateWeek1NoStrainingSubtitle),
    'week1_abdominal_support' => (l.templateWeek1AbdominalSupportTitle, l.templateWeek1AbdominalSupportSubtitle),
    'week1_bowel_diary' => (l.templateWeek1BowelDiaryTitle, l.templateWeek1BowelDiarySubtitle),
    // ── Week 1 · Spine ──
    'week1_back_posture' => (l.templateWeek1BackPostureTitle, l.templateWeek1BackPostureSubtitle),
    'week1_orthosis' => (l.templateWeek1OrthosisTitle, l.templateWeek1OrthosisSubtitle),
    'week1_breathing_spine' => (l.templateWeek1BreathingSpineTitle, l.templateWeek1BreathingSpineSubtitle),
    'week1_spine_stabilization' => (l.templateWeek1SpineStabilizationTitle, l.templateWeek1SpineStabilizationSubtitle),
    // ── Week 2 · universal ──
    'week2_wound_observe' => (l.templateWeek2WoundObserveTitle, l.templateWeek2WoundObserveSubtitle),
    'week2_pain' => (l.templateWeek2PainTitle, l.templateWeek2PainSubtitle),
    // ── Week 2 · Ortho ──
    'week2_walk' => (l.templateWeek2WalkTitle, l.templateWeek2WalkSubtitle),
    'week2_physio' => (l.templateWeek2PhysioTitle, l.templateWeek2PhysioSubtitle),
    'week2_gait_training' => (l.templateWeek2GaitTitle, l.templateWeek2GaitSubtitle),
    // ── Week 2 · Cardio ──
    'week2_cardiac_walk' => (l.templateWeek2CardiacWalkTitle, l.templateWeek2CardiacWalkSubtitle),
    // ── Week 2 · Abdominal ──
    'week2_diet_normalize' => (l.templateWeek2DietNormalizeTitle, l.templateWeek2DietNormalizeSubtitle),
    // ── Followup ──
    'followup_day7' => (l.templateFollowupDay7Title, l.templateFollowupDay7Subtitle),
    'followup_day14' => (l.templateFollowupDay7Title, l.templateFollowupDay14Subtitle),
    'followup_scar_care' => (l.templateFollowupScarCareTitle, l.templateFollowupScarCareSubtitle),
    'followup_activity' => (l.templateFollowupActivityTitle, l.templateFollowupActivitySubtitle),
    'followup_wound_photo' => (l.templateFollowupWoundPhotoTitle, l.templateFollowupWoundPhotoSubtitle),
    'followup_weekly_check' => (l.templateFollowupWeeklyCheckTitle, l.templateFollowupWeeklyCheckSubtitle),
    'followup_day21' => (l.templateFollowupDay7Title, l.templateFollowupDay21Subtitle),
    'followup_day28' => (l.templateFollowupDay28Title, l.templateFollowupDay28Subtitle),
    _ => null,
  };
}

/// Localized phase title for the timeline grouping header.
String localizedPhaseTitle(AppLocalizations l, String phase) {
  return switch (phase) {
    'personal' => l.timelinePhasePersonal,
    'preop' => l.timelinePhasePreop,
    'opday' => l.timelinePhaseOpday,
    'week1' => l.timelinePhaseWeek1,
    'week2' => l.timelinePhaseWeek2,
    'followup' => l.timelinePhaseFollowup,
    _ => l.timelinePhaseDefault,
  };
}

/// Localized weekday name (1 = Monday … 7 = Sunday).
String localizedWeekday(AppLocalizations l, int weekday) {
  return switch (weekday) {
    1 => l.timelineMonday,
    2 => l.timelineTuesday,
    3 => l.timelineWednesday,
    4 => l.timelineThursday,
    5 => l.timelineFriday,
    6 => l.timelineSaturday,
    7 => l.timelineSunday,
    _ => '',
  };
}
