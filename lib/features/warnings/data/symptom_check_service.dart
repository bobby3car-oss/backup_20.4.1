import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/timeline_engine.dart';
import '../../../firebase/timeline_repository.dart';
import '../../red_flags/data/red_flag_repository_sync.dart';
import '../../red_flags/domain/red_flag.dart';
import '../domain/symptom_check_result.dart';
import 'symptom_check_repository_sync.dart';

/// Orchestrates saving a symptom-check result and creating downstream
/// artefacts: Red Flag (if red), Timeline event.
class SymptomCheckService {
  SymptomCheckService._();

  static final TimelineRepository _timelineRepository = TimelineRepository();

  static Future<SymptomCheckResult> submit({
    required Map<String, SymptomSeverity> answers,
    required SymptomCheckLevel level,
    required String recommendation,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();
    final id =
        'sc_${now.millisecondsSinceEpoch}_${now.microsecond}';

    final result = SymptomCheckResult(
      id: id,
      ownerId: uid,
      answers: answers,
      overallLevel: level,
      recommendation: recommendation,
      createdAt: now,
    );

    // 1. Persist the check.
    await SymptomCheckRepositorySync.instance.add(result);

    // 2. Red Flag for red results.
    if (level == SymptomCheckLevel.red) {
      await _createRedFlag(result, uid, now);
    }

    // 3. Timeline event.
    await _createTimelineEvent(result, uid, now);

    return result;
  }

  // ── Red-Flag creation ────────────────────────────────────────────────

  static Future<void> _createRedFlag(
    SymptomCheckResult result,
    String uid,
    DateTime now,
  ) async {
    final symptoms = result.criticalSymptoms;
    final symptomsText =
        symptoms.isEmpty ? 'Mehrere Symptome' : symptoms.join(', ');

    final flag = RedFlag(
      id: 'rf_symptom_${result.id}',
      ownerId: uid,
      severity: RedFlagSeverity.red,
      status: RedFlagStatus.open,
      source: RedFlagSource.symptomCheck,
      title: 'Kritischer Symptom-Check',
      summary:
          'Symptom-Check hat kritische Werte ergeben: $symptomsText',
      recommendedAction:
          'Kontaktieren Sie umgehend Ihren Arzt oder suchen Sie '
          'die nächste Notaufnahme auf.',
      actions: const [
        RedFlagAction(label: 'Arzt kontaktieren', icon: '📞'),
        RedFlagAction(
          label: 'Notruf 112',
          icon: '🚨',
          route: 'tel:112',
        ),
      ],
      sourceRefId: result.id,
      createdAt: now,
      updatedAt: now,
      metadata: <String, dynamic>{
        'symptomCheckId': result.id,
        'totalScore': result.totalScore,
      },
    );

    try {
      await RedFlagRepositorySync.instance.upsert(flag);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SymptomCheckService] Red-Flag creation failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  // ── Timeline event creation ──────────────────────────────────────────

  static Future<void> _createTimelineEvent(
    SymptomCheckResult result,
    String uid,
    DateTime now,
  ) async {
    final subtitle = switch (result.overallLevel) {
      SymptomCheckLevel.green => 'Alles im grünen Bereich',
      SymptomCheckLevel.yellow => 'Bitte beobachten',
      SymptomCheckLevel.red => 'Ärztlichen Rat einholen',
    };

    final item = TimelineItem(
      id: 'tl_symptom_${result.id}',
      type: TaskType.checklist,
      title: 'Symptom-Check: ${result.overallLevel.label}',
      subtitle: subtitle,
      scheduledAt: now,
      priority: result.overallLevel == SymptomCheckLevel.red
          ? TaskPriority.critical
          : TaskPriority.normal,
      state: TaskState.done,
      deeplinkRoute: 'symptom_check',
      metadata: <String, dynamic>{
        'symptomCheckId': result.id,
        'overallLevel': result.overallLevel.name,
      },
      createdAt: now,
      updatedAt: now,
      doneAt: now,
    );

    try {
      await _timelineRepository.upsertItem(item);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[SymptomCheckService] Timeline event creation failed: $error',
        );
        debugPrint('$stackTrace');
      }
    }
  }
}
