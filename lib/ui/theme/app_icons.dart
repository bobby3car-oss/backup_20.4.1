import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'colors.dart';

/// Centralised icon + colour mapping that replaces all former emoji strings.
///
/// Usage:
/// ```dart
/// GlassIcon(icon: AppIcons.wound, color: AppIcons.woundColor)
/// ```
abstract final class AppIcons {
  // ── Dokumentation ────────────────────────────────────────────────
  static const IconData wound = CupertinoIcons.bandage_fill;
  static const Color woundColor = Color(0xFFFF6B81);

  static const IconData pain = CupertinoIcons.waveform_path_ecg;
  static const Color painColor = AppColors.error;

  static const IconData voice = CupertinoIcons.mic_fill;
  static const Color voiceColor = AppColors.primary;

  static const IconData photos = CupertinoIcons.camera_fill;
  static const Color photosColor = AppColors.primary;

  static const IconData documents = CupertinoIcons.doc_fill;
  static const Color documentsColor = AppColors.primary;

  static const IconData nutrition = CupertinoIcons.leaf_arrow_circlepath;
  static const Color nutritionColor = AppColors.success;

  // ── Planung ──────────────────────────────────────────────────────
  static const IconData appointments = CupertinoIcons.calendar;
  static const Color appointmentsColor = AppColors.primary;

  static const IconData packing = CupertinoIcons.bag_fill;
  static const Color packingColor = AppColors.warning;

  static const IconData rehab = CupertinoIcons.sportscourt_fill;
  static const Color rehabColor = AppColors.success;

  // ── Sicherheit ───────────────────────────────────────────────────
  static const IconData warnings = CupertinoIcons.exclamationmark_triangle_fill;
  static const Color warningsColor = AppColors.warning;

  static const IconData redFlags = CupertinoIcons.exclamationmark_circle_fill;
  static const Color redFlagsColor = AppColors.error;

  // ── Arzt ─────────────────────────────────────────────────────────
  static const IconData questions = CupertinoIcons.question_circle_fill;
  static const Color questionsColor = AppColors.accent;

  static const IconData doctor = CupertinoIcons.person_circle_fill;
  static const Color doctorColor = AppColors.primary;

  // ── Infos ────────────────────────────────────────────────────────
  static const IconData info = CupertinoIcons.info_circle_fill;
  static const Color infoColor = AppColors.primary;

  // ── Einstellungen ────────────────────────────────────────────────
  static const IconData settings = CupertinoIcons.gear_alt_fill;
  static const Color settingsColor = AppColors.grey600;

  static const IconData privacy = CupertinoIcons.lock_fill;
  static const Color privacyColor = AppColors.grey600;

  static const IconData imprint = CupertinoIcons.doc_text_fill;
  static const Color imprintColor = AppColors.grey600;

  // ── Medizinisch ──────────────────────────────────────────────────
  static const IconData medication = CupertinoIcons.staroflife_fill;
  static const Color medicationColor = AppColors.warning;

  static const IconData supplements = CupertinoIcons.capsule_fill;
  static const Color supplementsColor = AppColors.accent;

  static const IconData vitals = CupertinoIcons.heart_fill;
  static const Color vitalsColor = AppColors.error;

  static const IconData temperature = CupertinoIcons.thermometer;
  static const Color temperatureColor = AppColors.error;

  static const IconData o2 = CupertinoIcons.wind;
  static const Color o2Color = AppColors.primary;

  static const IconData weight = Icons.monitor_weight_rounded;
  static const Color weightColor = AppColors.success;

  // ── Profil / Sozial ──────────────────────────────────────────────
  static const IconData profile = CupertinoIcons.person_fill;
  static const Color profileColor = AppColors.accent;

  static const IconData family = CupertinoIcons.person_3_fill;
  static const Color familyColor = AppColors.accent;

  static const IconData messages = CupertinoIcons.chat_bubble_2_fill;
  static const Color messagesColor = AppColors.primary;

  // ── Benachrichtigungen ───────────────────────────────────────────
  static const IconData notifications = CupertinoIcons.bell_fill;
  static const Color notificationsColor = AppColors.warning;

  // ── Stimmung ─────────────────────────────────────────────────────
  static const IconData mood = Icons.sentiment_satisfied_rounded;
  static const Color moodColor = AppColors.accent;

  // ── Fortschritt / Gamification ───────────────────────────────────
  static const IconData progress = CupertinoIcons.arrow_up_circle_fill;
  static const Color progressColor = AppColors.success;

  static const IconData streak = CupertinoIcons.flame_fill;
  static const Color streakColor = AppColors.warning;

  static const IconData achievement = CupertinoIcons.rosette;
  static const Color achievementColor = AppColors.warning;

  static const IconData done = CupertinoIcons.checkmark_circle_fill;
  static const Color doneColor = AppColors.success;

  static const IconData energy = CupertinoIcons.bolt_fill;
  static const Color energyColor = AppColors.warning;

  static const IconData pro = CupertinoIcons.star_fill;
  static const Color proColor = AppColors.warning;

  static const IconData analytics = CupertinoIcons.chart_bar_fill;
  static const Color analyticsColor = AppColors.accent;

  // ── Bearbeitung ──────────────────────────────────────────────────
  static const IconData edit = CupertinoIcons.pencil;
  static const Color editColor = AppColors.accent;

  static const IconData diary = CupertinoIcons.book_fill;
  static const Color diaryColor = AppColors.accent;

  static const IconData notes = CupertinoIcons.pencil_circle_fill;
  static const Color notesColor = AppColors.accent;

  // ── Transport / Ort ──────────────────────────────────────────────
  static const IconData ambulant = CupertinoIcons.car_fill;
  static const Color ambulantColor = AppColors.primary;

  static const IconData hospital = CupertinoIcons.building_2_fill;
  static const Color hospitalColor = AppColors.primary;

  // ── Sonstiges ────────────────────────────────────────────────────
  static const IconData support = CupertinoIcons.chat_bubble_text_fill;
  static const Color supportColor = AppColors.accent;

  static const IconData help = CupertinoIcons.chat_bubble_fill;
  static const Color helpColor = AppColors.primary;

  static const IconData flag = CupertinoIcons.flag_fill;
  static const Color flagColor = AppColors.success;

  static const IconData search = CupertinoIcons.search;
  static const Color searchColor = AppColors.primary;

  static const IconData child = CupertinoIcons.person_fill;
  static const Color childColor = AppColors.primary;

  static const IconData clipboard = CupertinoIcons.doc_on_clipboard_fill;
  static const Color clipboardColor = AppColors.primary;

  static const IconData dining = CupertinoIcons.circle_fill;
  static const Color diningColor = AppColors.warning;

  // ── Packing Categories ───────────────────────────────────────────
  static const IconData clothing = CupertinoIcons.cube_box_fill;
  static const Color clothingColor = AppColors.primary;

  static const IconData hygiene = CupertinoIcons.drop_fill;
  static const Color hygieneColor = AppColors.primaryLight;

  static const IconData technology = CupertinoIcons.bolt_fill;
  static const Color technologyColor = AppColors.grey700;

  static const IconData entertainment = CupertinoIcons.book_fill;
  static const Color entertainmentColor = AppColors.accent;

  static const IconData packageBox = CupertinoIcons.cube_box_fill;
  static const Color packageBoxColor = AppColors.grey600;

  // ── Nutrition Symptoms ───────────────────────────────────────────
  static const IconData nausea = CupertinoIcons.exclamationmark_circle_fill;
  static const Color nauseaColor = AppColors.warning;

  static const IconData bloating = CupertinoIcons.wind;
  static const Color bloatingColor = AppColors.primary;

  static const IconData heartburn = CupertinoIcons.flame_fill;
  static const Color heartburnColor = AppColors.error;

  static const IconData diarrhea = CupertinoIcons.drop_fill;
  static const Color diarrheaColor = AppColors.primary;

  static const IconData constipation = CupertinoIcons.nosign;
  static const Color constipationColor = AppColors.error;

  static const IconData fatigue = CupertinoIcons.moon_fill;
  static const Color fatigueColor = AppColors.accent;

  static const IconData other = CupertinoIcons.question_circle_fill;
  static const Color otherColor = AppColors.grey600;

  // ── Meal Types ───────────────────────────────────────────────────
  static const IconData breakfast = CupertinoIcons.sun_max_fill;
  static const Color breakfastColor = AppColors.warning;

  static const IconData lunch = CupertinoIcons.circle_fill;
  static const Color lunchColor = AppColors.primary;

  static const IconData dinner = CupertinoIcons.moon_fill;
  static const Color dinnerColor = AppColors.accent;

  static const IconData snack = CupertinoIcons.heart_fill;
  static const Color snackColor = AppColors.success;

  // ── Nutrition Targets ────────────────────────────────────────────
  static const IconData calories = CupertinoIcons.flame_fill;
  static const Color caloriesColor = AppColors.warning;

  static const IconData protein = CupertinoIcons.bolt_fill;
  static const Color proteinColor = AppColors.error;

  static const IconData water = CupertinoIcons.drop_fill;
  static const Color waterColor = AppColors.primary;

  static const IconData carbs = CupertinoIcons.circle_fill;
  static const Color carbsColor = AppColors.warning;

  static const IconData fat = CupertinoIcons.circle_fill;
  static const Color fatColor = AppColors.accent;

  // ── Pain Types ───────────────────────────────────────────────────
  static const IconData stabbing = CupertinoIcons.bolt_fill;
  static const Color stabbingColor = AppColors.error;

  static const IconData dull = CupertinoIcons.circle_fill;
  static const Color dullColor = AppColors.grey600;

  static const IconData burning = CupertinoIcons.flame_fill;
  static const Color burningColor = AppColors.error;

  static const IconData pulling = CupertinoIcons.arrow_up_arrow_down;
  static const Color pullingColor = AppColors.warning;

  static const IconData throbbing = CupertinoIcons.heart_fill;
  static const Color throbbingColor = AppColors.error;

  static const IconData pressing = CupertinoIcons.hand_raised_fill;
  static const Color pressingColor = AppColors.warning;

  static const IconData cramping = CupertinoIcons.bolt_fill;
  static const Color crampingColor = AppColors.warning;

  // ── Body Regions ─────────────────────────────────────────────────
  static const IconData head = CupertinoIcons.circle_fill;
  static const Color headColor = AppColors.accent;

  static const IconData shoulder = CupertinoIcons.person_fill;
  static const Color shoulderColor = AppColors.primary;

  static const IconData chest = CupertinoIcons.heart_fill;
  static const Color chestColor = AppColors.error;

  static const IconData arm = CupertinoIcons.hand_raised_fill;
  static const Color armColor = AppColors.primary;

  static const IconData belly = CupertinoIcons.circle_fill;
  static const Color bellyColor = AppColors.warning;

  static const IconData back = CupertinoIcons.arrow_turn_up_left;
  static const Color backColor = AppColors.primary;

  static const IconData hip = CupertinoIcons.circle_fill;
  static const Color hipColor = AppColors.accent;

  static const IconData leg = CupertinoIcons.circle_fill;
  static const Color legColor = AppColors.primary;

  static const IconData knee = CupertinoIcons.circle_fill;
  static const Color kneeColor = AppColors.warning;

  static const IconData foot = CupertinoIcons.circle_fill;
  static const Color footColor = AppColors.primary;

  static const IconData location = CupertinoIcons.location_fill;
  static const Color locationColor = AppColors.error;

  static const IconData timer = CupertinoIcons.timer;
  static const Color timerColor = AppColors.primary;

  // ── Rehab OP Types ───────────────────────────────────────────────
  static const IconData generalOp = CupertinoIcons.building_2_fill;
  static const Color generalOpColor = AppColors.primary;

  static const IconData kneeOp = CupertinoIcons.circle_fill;
  static const Color kneeOpColor = AppColors.primary;

  static const IconData hipOp = CupertinoIcons.circle_fill;
  static const Color hipOpColor = AppColors.accent;

  static const IconData shoulderOp = CupertinoIcons.person_fill;
  static const Color shoulderOpColor = AppColors.primary;

  // ── Red Flag Sources ─────────────────────────────────────────────
  static const IconData observation = CupertinoIcons.eye_fill;
  static const Color observationColor = AppColors.primary;

  static const IconData timeline = CupertinoIcons.doc_on_clipboard_fill;
  static const Color timelineColor = AppColors.primary;

  // ── Gamification Events ──────────────────────────────────────────
  static const IconData taskDone = CupertinoIcons.checkmark_circle_fill;
  static const Color taskDoneColor = AppColors.success;

  static const IconData woundLogged = CupertinoIcons.camera_fill;
  static const Color woundLoggedColor = AppColors.primary;

  static const IconData painLogged = CupertinoIcons.waveform_path_ecg;
  static const Color painLoggedColor = AppColors.error;

  static const IconData vitalsLogged = CupertinoIcons.heart_fill;
  static const Color vitalsLoggedColor = AppColors.error;

  static const IconData medicationLogged = CupertinoIcons.staroflife_fill;
  static const Color medicationLoggedColor = AppColors.warning;

  static const IconData supplementLogged = CupertinoIcons.capsule_fill;
  static const Color supplementLoggedColor = AppColors.success;

  static const IconData rehabDone = CupertinoIcons.sportscourt_fill;
  static const Color rehabDoneColor = AppColors.success;

  static const IconData challengeDone = CupertinoIcons.bolt_fill;
  static const Color challengeDoneColor = AppColors.warning;

  static const IconData badgeEarned = CupertinoIcons.rosette;
  static const Color badgeEarnedColor = AppColors.warning;

  static const IconData milestoneReached = CupertinoIcons.rosette;
  static const Color milestoneReachedColor = AppColors.warning;

  static const IconData levelUp = CupertinoIcons.star_fill;
  static const Color levelUpColor = AppColors.warning;

  static const IconData streakRecord = CupertinoIcons.flame_fill;
  static const Color streakRecordColor = AppColors.warning;

  static const IconData dailyComplete = CupertinoIcons.star_fill;
  static const Color dailyCompleteColor = AppColors.warning;

  static const IconData weeklySummary = CupertinoIcons.chart_bar_fill;
  static const Color weeklySummaryColor = AppColors.accent;

  // ── Pro / Trigger Contexts ───────────────────────────────────────
  static const IconData rocket = CupertinoIcons.arrow_up_circle_fill;
  static const Color rocketColor = AppColors.primary;

  // ── Packing Priorities ───────────────────────────────────────────
  static const IconData priorityHigh = CupertinoIcons.exclamationmark_triangle_fill;
  static const Color priorityHighColor = AppColors.warning;

  static const IconData priorityCritical = CupertinoIcons.exclamationmark_circle_fill;
  static const Color priorityCriticalColor = AppColors.error;

  // ── Neck (Hals) ──────────────────────────────────────────────────
  static const IconData neck = CupertinoIcons.circle_fill;
  static const Color neckColor = AppColors.primary;

  // ── Breathing (for rehab stages) ────────────────────────────────
  static const IconData breathing = CupertinoIcons.wind;
  static const Color breathingColor = AppColors.primary;

  // ── Additional ───────────────────────────────────────────────────
  static const IconData trophy = CupertinoIcons.rosette;
  static const Color trophyColor = AppColors.warning;

  static const IconData caregiver = CupertinoIcons.person_2_fill;
  static const Color caregiverColor = AppColors.success;

  // ── Schlaf ───────────────────────────────────────────────────────
  static const IconData sleep = CupertinoIcons.moon_fill;
  static const Color sleepColor = Color(0xFF5C4D9A);

  // ── Return to Sport ──────────────────────────────────────────────
  static const IconData rts = CupertinoIcons.sportscourt;
  static const Color rtsColor = AppColors.success;
}
