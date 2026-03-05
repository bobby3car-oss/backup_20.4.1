import 'rehab_exercise.dart';

/// Static catalog of rehabilitation exercises.
/// Contains general exercises and op-specific ones (knee, hip, shoulder).
abstract final class RehabCatalog {
  static const List<RehabExercise> exercises = <RehabExercise>[
    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Atemübungen
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'breathing_deep',
      title: 'Tiefe Bauchatmung',
      emoji: '🫁',
      description:
          'Legen Sie eine Hand auf den Bauch. Atmen Sie langsam durch die Nase ein — '
          'der Bauch hebt sich. Atmen Sie durch den Mund aus — der Bauch senkt sich. '
          'Halten Sie den Rhythmus gleichmäßig.',
      category: RehabCategory.breathing,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.preop,
      durationSeconds: 30,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Am besten im Liegen oder aufrechten Sitzen üben.',
        'Nicht pressen — die Atmung soll entspannt fließen.',
        'Ideal als erste Übung nach der OP.',
      ],
    ),
    RehabExercise(
      id: 'breathing_lip',
      title: 'Lippenbremse',
      emoji: '💨',
      description:
          'Atmen Sie durch die Nase ein. Spitzen Sie die Lippen, als würden Sie '
          'eine Kerze auspusten, und atmen Sie langsam gegen den Widerstand der '
          'Lippen aus. Das Ausatmen sollte doppelt so lang wie das Einatmen sein.',
      category: RehabCategory.breathing,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.opday,
      durationSeconds: 20,
      sets: 4,
      restSeconds: 10,
      tips: [
        'Verhindert das Zusammenfallen der Atemwege.',
        'Besonders wichtig nach Narkose.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Mobilisation
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'mob_ankle_pump',
      title: 'Fußwippen (Sprunggelenkpumpe)',
      emoji: '🦶',
      description:
          'Im Liegen oder Sitzen: Ziehen Sie die Fußspitzen kräftig zum Körper '
          'und strecken Sie sie dann vom Körper weg. Wiederholen Sie die Bewegung '
          'gleichmäßig im Rhythmus.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.ankle,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.opday,
      durationSeconds: 30,
      sets: 3,
      reps: 15,
      restSeconds: 10,
      tips: [
        'Wichtigste Thrombose-Prophylaxe!',
        'Jede Stunde einige Minuten durchführen.',
        'Funktioniert auch im Bett.',
      ],
    ),
    RehabExercise(
      id: 'mob_bed_march',
      title: 'Bettmarsch',
      emoji: '🛏️',
      description:
          'Im Liegen: Ziehen Sie abwechselnd ein Knie zur Brust, indem Sie '
          'den Fuß flach über die Matratze gleiten lassen. Das Fersenschieben '
          'aktiviert Hüftbeuger und Oberschenkel.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      tips: [
        'Langsam und kontrolliert arbeiten.',
        'Bei Schmerzen den Bewegungsumfang verkleinern.',
      ],
    ),
    RehabExercise(
      id: 'mob_sit_to_stand',
      title: 'Hinsetzen & Aufstehen',
      emoji: '🪑',
      description:
          'Setzen Sie sich auf die Stuhlkante. Stellen Sie die Füße hüftbreit auf. '
          'Lehnen Sie den Oberkörper leicht vor und drücken Sie sich mit den Beinen '
          'hoch, ohne die Hände zu benutzen. Setzen Sie sich kontrolliert zurück.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week1,
      durationSeconds: 40,
      sets: 3,
      reps: 8,
      restSeconds: 20,
      tips: [
        'Stuhl an die Wand stellen für Sicherheit.',
        'Knie sollen nicht über die Zehenspitzen ragen.',
        'Fortschritt: langsamer runter, Pause unten.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Stretching
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'stretch_neck',
      title: 'Nacken-Dehnung',
      emoji: '🧘',
      description:
          'Sitzen Sie aufrecht. Neigen Sie den Kopf zur rechten Schulter — halten. '
          'Zurück zur Mitte, dann zur linken Seite. Anschließend Kinn zur Brust '
          'senken und halten.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.preop,
      durationSeconds: 20,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Schultern dabei unten lassen.',
        'Keine ruckartigen Bewegungen.',
      ],
    ),
    RehabExercise(
      id: 'stretch_calf',
      title: 'Wadendehnung',
      emoji: '🦵',
      description:
          'Stellen Sie sich vor eine Wand. Ein Bein nach hinten strecken, Ferse '
          'bleibt am Boden. Das vordere Knie leicht beugen und den Körper zur '
          'Wand drücken, bis eine Dehnung in der Wade spürbar ist.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Beide Seiten gleichmäßig dehnen.',
        'Nicht wippen — Position halten.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Kräftigung
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'strength_bridge',
      title: 'Brücke (Beckenlift)',
      emoji: '🌉',
      description:
          'Rückenlage, Knie angewinkelt, Füße aufgestellt. Heben Sie das Becken '
          'an, bis Oberkörper und Oberschenkel eine Linie bilden. Position kurz '
          'halten, dann kontrolliert absenken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 20,
      tips: [
        'Gesäß oben anspannen.',
        'Nicht ins Hohlkreuz gehen.',
        'Fortschritt: ein Bein ausstrecken.',
      ],
    ),
    RehabExercise(
      id: 'strength_wall_sit',
      title: 'Wandsitzen',
      emoji: '🧱',
      description:
          'Lehnen Sie sich mit dem Rücken an eine Wand. Rutschen Sie nach unten, '
          'bis die Knie ca. 90° gebeugt sind (oder weniger, je nach Fähigkeit). '
          'Position halten.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.hard,
      phase: RehabPhase.followup,
      durationSeconds: 30,
      sets: 3,
      restSeconds: 30,
      tips: [
        'Knie nicht über die Zehenspitzen.',
        'Anfangs kürzere Haltezeit ist okay.',
        'Gleichmäßig weiteratmen.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // KNIE-SPEZIFISCH
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'knee_quad_set',
      title: 'Quadrizeps-Anspannung',
      emoji: '🦵',
      description:
          'Rückenlage, Bein gestreckt. Spannen Sie den Oberschenkelmuskel '
          'maximal an und drücken Sie die Kniekehle in die Unterlage. '
          'Halten — dann lockern.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.opday,
      durationSeconds: 10,
      sets: 5,
      reps: 10,
      restSeconds: 10,
      opTypes: ['knee'],
      tips: [
        'Wichtigste Übung nach Knie-OP!',
        'Die Kniescheibe bewegt sich sichtbar nach oben.',
        'Mehrmals täglich durchführen.',
      ],
    ),
    RehabExercise(
      id: 'knee_heel_slide',
      title: 'Fersenschieber',
      emoji: '🦿',
      description:
          'Rückenlage: Schieben Sie die Ferse langsam zum Gesäß und beugen '
          'so das Knie. Am Endpunkt kurz halten, dann langsam strecken.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      opTypes: ['knee'],
      tips: [
        'Unterlage darf rutschig sein (Socke auf Laken).',
        'Beugung nur soweit schmerzfrei möglich.',
      ],
    ),
    RehabExercise(
      id: 'knee_straight_leg_raise',
      title: 'Gestrecktes Beinheben',
      emoji: '📐',
      description:
          'Rückenlage, operiertes Bein gestreckt, anderes angewinkelt. Spannen '
          'Sie den Oberschenkel an und heben Sie das gestreckte Bein ca. 20 cm. '
          'Kurz halten, langsam absenken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week1,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 20,
      opTypes: ['knee'],
      tips: [
        'Das Knie bleibt durchgestreckt!',
        'Langsam und kontrolliert.',
        'Erst wenn Quad-Set sicher klappt.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // HÜFTE-SPEZIFISCH
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'hip_abduction',
      title: 'Bein abspreizen (Seitlage)',
      emoji: '🦴',
      description:
          'Seitenlage auf der gesunden Seite. Heben Sie das obere (operierte) '
          'Bein gestreckt zur Decke — ca. 30 cm. Kurz halten, langsam senken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 20,
      opTypes: ['hip'],
      tips: [
        'Nicht nach vorn oder hinten kippen.',
        'Becken stabil halten.',
        'Langsam arbeiten, kein Schwung.',
      ],
    ),
    RehabExercise(
      id: 'hip_flexor_stretch',
      title: 'Hüftbeuger-Dehnung',
      emoji: '🧎',
      description:
          'Kniestand: Ein Bein nach vorn (90°-Winkel). Schieben Sie die Hüfte '
          'nach vorn, bis eine Dehnung an der Vorderseite des hinteren '
          'Oberschenkels/Hüfte spürbar ist.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 15,
      opTypes: ['hip'],
      tips: [
        'Aufrechter Oberkörper.',
        'Beide Seiten dehnen.',
        'Bei Knie-Problemen ein Kissen unterlegen.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // SCHULTER-SPEZIFISCH
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'shoulder_pendulum',
      title: 'Pendelübung (Schulter)',
      emoji: '🔄',
      description:
          'Vorbeugen, gesunder Arm stützt auf einem Tisch. Den operierten Arm '
          'hängen lassen und durch leichte Körperbewegungen kreisen — erst '
          'kleine Kreise, dann größer.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 30,
      sets: 3,
      restSeconds: 15,
      opTypes: ['shoulder'],
      tips: [
        'Die Schwerkraft macht die Arbeit — Arm locker lassen.',
        'Kein aktives Heben!',
        'Kreise in beide Richtungen.',
      ],
    ),
    RehabExercise(
      id: 'shoulder_wall_walk',
      title: 'Wandklettern',
      emoji: '🧗',
      description:
          'Stehen Sie vor einer Wand. „Klettern" Sie mit den Fingern der '
          'operierten Seite langsam die Wand hoch — so weit wie schmerzfrei '
          'möglich. Position oben kurz halten, langsam zurück.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 20,
      sets: 4,
      restSeconds: 15,
      opTypes: ['shoulder'],
      tips: [
        'Schmerzgrenze respektieren.',
        'Täglich ein bisschen höher als Ziel.',
        'Auch seitlich zur Wand versuchen.',
      ],
    ),
    RehabExercise(
      id: 'shoulder_external_rotation',
      title: 'Außenrotation (Schulter)',
      emoji: '🔧',
      description:
          'Stehen Sie aufrecht, Oberarm am Körper, Ellbogen 90° gebeugt. '
          'Drehen Sie den Unterarm langsam nach außen (wie eine Tür öffnen). '
          'Kurz halten, zurück.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.followup,
      durationSeconds: 25,
      sets: 3,
      reps: 12,
      restSeconds: 20,
      opTypes: ['shoulder'],
      tips: [
        'Leichtes Theraband für Widerstand.',
        'Ellbogen bleibt am Körper.',
        'Schulterblatt nach hinten-unten ziehen.',
      ],
    ),
  ];

  /// Returns exercises filtered by category.
  static List<RehabExercise> byCategory(RehabCategory category) {
    return exercises.where((e) => e.category == category).toList();
  }

  /// Returns exercises filtered by target area.
  static List<RehabExercise> byTargetArea(RehabTargetArea area) {
    return exercises.where((e) => e.targetArea == area).toList();
  }

  /// Returns exercises filtered by operation type (includes general).
  static List<RehabExercise> byOpType(String opType) {
    return exercises
        .where((e) => e.isGeneral || e.opTypes.contains(opType))
        .toList();
  }

  /// Returns exercises for a given rehab phase.
  static List<RehabExercise> byPhase(RehabPhase phase) {
    return exercises.where((e) => e.phase == phase).toList();
  }

  /// Returns only general (non-op-specific) exercises.
  static List<RehabExercise> get general {
    return exercises.where((e) => e.isGeneral).toList();
  }
}
