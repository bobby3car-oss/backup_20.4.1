import '../../pain/domain/pain_entry.dart';
import '../../vitals/domain/vital_entry.dart';
import '../../warnings/domain/warning_check.dart';
import '../../observations/domain/observation_entry.dart';
import 'red_flag.dart';

/// Input bundle for the rule engine.
class RedFlagEvalInput {
  const RedFlagEvalInput({
    this.latestWarningCheck,
    this.recentPainEntries = const [],
    this.recentVitalEntries = const [],
    this.recentObservations = const [],
    this.overdueTaskCount = 0,
  });

  final WarningCheck? latestWarningCheck;
  final List<PainEntry> recentPainEntries;
  final List<VitalEntry> recentVitalEntries;
  final List<ObservationEntry> recentObservations;
  final int overdueTaskCount;
}

/// Result of a single rule evaluation.
class _RuleResult {
  const _RuleResult({
    required this.severity,
    required this.source,
    required this.title,
    required this.summary,
    required this.recommendedAction,
    this.actions = const [],
    this.sourceRefId,
  });

  final RedFlagSeverity severity;
  final RedFlagSource source;
  final String title;
  final String summary;
  final String recommendedAction;
  final List<RedFlagAction> actions;
  final String? sourceRefId;
}

/// Evaluates all sources and returns a list of triggered red-flag drafts,
/// sorted by severity (red first).
///
/// The caller is responsible for deduplication and persistence.
List<RedFlag> evaluateRedFlags({
  required String ownerId,
  required RedFlagEvalInput input,
}) {
  final results = <_RuleResult>[];

  // ── 1. Warning-check rules ────────────────────────────────────────────
  final wc = input.latestWarningCheck;
  if (wc != null && wc.level != WarningLevel.green) {
    results.add(_RuleResult(
      severity: wc.level == WarningLevel.red
          ? RedFlagSeverity.red
          : RedFlagSeverity.yellow,
      source: RedFlagSource.warningCheck,
      title: wc.level == WarningLevel.red
          ? 'Kritisches Warnzeichen'
          : 'Auffälliges Warnzeichen',
      summary: _warningCheckSummary(wc),
      recommendedAction: wc.actionText,
      actions: [
        if (wc.level == WarningLevel.red)
          const RedFlagAction(
            label: 'Notruf 112',
            icon: '🚨',
            route: 'tel:112',
          ),
        const RedFlagAction(
          label: 'Arzt kontaktieren',
          icon: '📞',
        ),
      ],
      sourceRefId: wc.id,
    ));
  }

  // ── 2. Pain rules ─────────────────────────────────────────────────────
  if (input.recentPainEntries.isNotEmpty) {
    final latest = input.recentPainEntries.first;
    if (latest.painLevel >= 9) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.red,
        source: RedFlagSource.pain,
        title: 'Extrem starke Schmerzen',
        summary:
            'Schmerzlevel ${latest.painLevel}/10 – deutlich über '
            'dem kritischen Schwellenwert.',
        recommendedAction:
            'Sofort ärztliche Hilfe einholen. Aktuelle Schmerzmedikation '
            'prüfen lassen.',
        actions: const [
          RedFlagAction(label: 'Schmerz erfassen', icon: '📝', route: '/pain-log'),
          RedFlagAction(label: 'Arzt kontaktieren', icon: '📞'),
        ],
        sourceRefId: latest.id,
      ));
    } else if (latest.painLevel >= 7) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.orange,
        source: RedFlagSource.pain,
        title: 'Starke Schmerzen',
        summary:
            'Schmerzlevel ${latest.painLevel}/10 – über dem '
            'Aufmerksamkeits-Schwellenwert.',
        recommendedAction:
            'Bitte zeitnah ärztlich abklären und Schmerzmedikation anpassen.',
        actions: const [
          RedFlagAction(label: 'Schmerz erfassen', icon: '📝', route: '/pain-log'),
        ],
        sourceRefId: latest.id,
      ));
    } else if (latest.painLevel >= 5) {
      // check for rising trend
      if (input.recentPainEntries.length >= 3) {
        final trend = input.recentPainEntries
            .take(3)
            .map((e) => e.painLevel)
            .toList();
        if (trend[0] > trend[1] && trend[1] > trend[2]) {
          results.add(_RuleResult(
            severity: RedFlagSeverity.yellow,
            source: RedFlagSource.pain,
            title: 'Ansteigender Schmerzverlauf',
            summary:
                'Schmerzen steigen kontinuierlich: '
                '${trend.reversed.join(" → ")}/10.',
            recommendedAction:
                'Engmaschig beobachten und bei weiterem Anstieg ärztlich abklären.',
            actions: const [
              RedFlagAction(label: 'Schmerz erfassen', icon: '📝', route: '/pain-log'),
            ],
          ));
        }
      }
    }
  }

  // ── 3. Vital-sign rules ───────────────────────────────────────────────
  if (input.recentVitalEntries.isNotEmpty) {
    final v = input.recentVitalEntries.first;

    // Systolic blood pressure
    if (v.systolic >= 180 || v.diastolic >= 120) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.red,
        source: RedFlagSource.vitals,
        title: 'Hypertensive Krise',
        summary:
            'Blutdruck ${v.systolic}/${v.diastolic} mmHg – '
            'deutlich über dem kritischen Grenzwert.',
        recommendedAction:
            'Sofort Ruhe bewahren, hinsetzen, erneut messen. '
            'Bei Bestätigung 112 anrufen.',
        actions: const [
          RedFlagAction(label: 'Notruf 112', icon: '🚨', route: 'tel:112'),
          RedFlagAction(label: 'Vitals messen', icon: '💓', route: '/vitals'),
        ],
        sourceRefId: v.id,
      ));
    } else if (v.systolic >= 160 || v.diastolic >= 100) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.orange,
        source: RedFlagSource.vitals,
        title: 'Erhöhter Blutdruck',
        summary:
            'Blutdruck ${v.systolic}/${v.diastolic} mmHg – '
            'über dem Aufmerksamkeits-Schwellenwert.',
        recommendedAction:
            'Bitte zeitnah ärztlich abklären.',
        actions: const [
          RedFlagAction(label: 'Vitals messen', icon: '💓', route: '/vitals'),
        ],
        sourceRefId: v.id,
      ));
    }

    // Tachycardia / Bradycardia
    if (v.pulse >= 130) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.red,
        source: RedFlagSource.vitals,
        title: 'Starke Tachykardie',
        summary: 'Puls ${v.pulse} bpm – deutlich erhöht.',
        recommendedAction:
            'Setzen Sie sich hin, trinken Sie Wasser, messen Sie erneut. '
            'Bei Persistenz ärztliche Hilfe einholen.',
        actions: const [
          RedFlagAction(label: 'Vitals messen', icon: '💓', route: '/vitals'),
          RedFlagAction(label: 'Arzt kontaktieren', icon: '📞'),
        ],
        sourceRefId: v.id,
      ));
    } else if (v.pulse >= 110) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.yellow,
        source: RedFlagSource.vitals,
        title: 'Erhöhter Puls',
        summary: 'Puls ${v.pulse} bpm – leicht erhöht.',
        recommendedAction:
            'Bitte Puls engmaschig beobachten.',
        actions: const [
          RedFlagAction(label: 'Vitals messen', icon: '💓', route: '/vitals'),
        ],
        sourceRefId: v.id,
      ));
    } else if (v.pulse <= 40) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.red,
        source: RedFlagSource.vitals,
        title: 'Bradykardie',
        summary: 'Puls ${v.pulse} bpm – kritisch niedrig.',
        recommendedAction: 'Sofort ärztliche Hilfe einholen.',
        actions: const [
          RedFlagAction(label: 'Notruf 112', icon: '🚨', route: 'tel:112'),
        ],
        sourceRefId: v.id,
      ));
    }
  }

  // ── 4. Observation rules ──────────────────────────────────────────────
  for (final obs in input.recentObservations) {
    if (obs.severity == ObservationSeverity.critical) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.red,
        source: RedFlagSource.observation,
        title: 'Kritische Beobachtung',
        summary: obs.text.length > 120
            ? '${obs.text.substring(0, 120)}…'
            : obs.text,
        recommendedAction:
            'Sofort ärztliche Hilfe einholen.',
        actions: const [
          RedFlagAction(label: 'Arzt kontaktieren', icon: '📞'),
        ],
        sourceRefId: obs.id,
      ));
    } else if (obs.severity == ObservationSeverity.warning) {
      results.add(_RuleResult(
        severity: RedFlagSeverity.yellow,
        source: RedFlagSource.observation,
        title: 'Auffällige Beobachtung',
        summary: obs.text.length > 120
            ? '${obs.text.substring(0, 120)}…'
            : obs.text,
        recommendedAction:
            'Bitte engmaschig beobachten und bei Verschlechterung '
            'ärztlich abklären.',
        sourceRefId: obs.id,
      ));
    }
  }

  // ── 5. Task overdue rules ─────────────────────────────────────────────
  if (input.overdueTaskCount >= 5) {
    results.add(_RuleResult(
      severity: RedFlagSeverity.yellow,
      source: RedFlagSource.timeline,
      title: 'Viele überfällige Aufgaben',
      summary:
          '${input.overdueTaskCount} Aufgaben überfällig – '
          'der Behandlungsplan wird nicht eingehalten.',
      recommendedAction:
          'Bitte Aufgaben abarbeiten oder mit dem Arzt besprechen.',
      actions: const [
        RedFlagAction(label: 'Timeline öffnen', icon: '📋', route: '/timeline'),
      ],
    ));
  }

  // ── Build RedFlag objects ─────────────────────────────────────────────
  final now = DateTime.now();
  final flags = results.map((r) {
    final id = 'rf_${r.source.name}_${now.microsecondsSinceEpoch}';
    return RedFlag(
      id: id,
      ownerId: ownerId,
      severity: r.severity,
      status: RedFlagStatus.open,
      source: r.source,
      title: r.title,
      summary: r.summary,
      recommendedAction: r.recommendedAction,
      actions: r.actions,
      sourceRefId: r.sourceRefId,
      createdAt: now,
      updatedAt: now,
    );
  }).toList();

  // Sort: red > orange > yellow > green
  flags.sort(
    (a, b) => b.severity.index.compareTo(a.severity.index),
  );

  return flags;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _warningCheckSummary(WarningCheck wc) {
  final triggered = <String>[];
  if (wc.answers.strongBleeding) triggered.add('Starke Blutung');
  if (wc.answers.feverHigh) triggered.add('Hohes Fieber');
  if (wc.answers.shortnessOfBreath) triggered.add('Atemnot');
  if (wc.answers.strongPain) triggered.add('Starke Schmerzen');
  if (wc.answers.increasingRedness) triggered.add('Zunehmende Rötung');
  if (wc.answers.badSmellSecretion) triggered.add('Übelriechendes Sekret');
  if (triggered.isEmpty) return 'Keine spezifischen Symptome gemeldet.';
  return 'Symptome: ${triggered.join(", ")}.';
}

/// Derives the overall severity from a list of active flags.
RedFlagSeverity overallSeverity(List<RedFlag> flags) {
  if (flags.isEmpty) return RedFlagSeverity.green;
  final active = flags.where((f) => f.status.isActive);
  if (active.isEmpty) return RedFlagSeverity.green;
  return active
      .map((f) => f.severity)
      .reduce((a, b) => a.index > b.index ? a : b);
}
