import 'rehab_exercise.dart';
import '../../../ui/theme/app_icons.dart';

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
      exerciseIcon: AppIcons.bloating,
                    exerciseIconColor: AppIcons.bloatingColor,
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
      exerciseIcon: AppIcons.kneeOp,
                    exerciseIconColor: AppIcons.kneeOpColor,
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
      exerciseIcon: AppIcons.kneeOp,
                    exerciseIconColor: AppIcons.kneeOpColor,
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
      exerciseIcon: AppIcons.hipOp,
                    exerciseIconColor: AppIcons.hipOpColor,
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

    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Atemübungen (zusätzlich)
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'breathing_triflow',
      title: 'Atemtrainer (Triflow)',
      emoji: '💨',
      description:
          'Setzen Sie sich aufrecht hin. Atmen Sie das Mundstück umschließend '
          'langsam und tief ein — versuchen Sie, die Kugeln im Gerät so lange '
          'wie möglich oben zu halten. Dann normal ausatmen.',
      category: RehabCategory.breathing,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.opday,
      durationSeconds: 20,
      sets: 5,
      restSeconds: 15,
      tips: [
        'Auch ohne Gerät möglich: durch einen Strohhalm einatmen.',
        'Ziel: tiefe, vollständige Einatmung trainieren.',
        'Verhindert Lungenentzündung nach Narkose.',
      ],
    ),
    RehabExercise(
      id: 'breathing_4_7_8',
      title: '4-7-8 Atemtechnik',
      emoji: '🌬️',
      description:
          'Einatmen durch die Nase: 4 Sekunden zählen. Luft anhalten: '
          '7 Sekunden. Durch den Mund ausatmen: 8 Sekunden lang. '
          'Dieser Rhythmus aktiviert das parasympathische Nervensystem.',
      category: RehabCategory.breathing,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.preop,
      durationSeconds: 20,
      sets: 4,
      restSeconds: 10,
      tips: [
        'Ideal vor dem Einschlafen oder bei Nervosität.',
        'Hilft auch gegen Schmerzen.',
        'Zunge hinter die oberen Schneidezähne legen.',
      ],
    ),
    RehabExercise(
      id: 'breathing_diaphragm',
      title: 'Zwerchfell-Kräftigung',
      emoji: '🫁',
      description:
          'Legen Sie ein leichtes Buch auf den Bauch. Atmen Sie ein und heben '
          'Sie dabei bewusst das Buch an. Halten Sie drei Sekunden. Atmen Sie '
          'kontrolliert aus und lassen Sie das Buch sinken.',
      category: RehabCategory.breathing,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 4,
      restSeconds: 10,
      tips: [
        'Stärkt das Zwerchfell gezielt.',
        'Verhindert flache Schonatmung.',
        'Brustkorb bleibt möglichst ruhig.',
      ],
    ),
    RehabExercise(
      id: 'breathing_cough',
      title: 'Abhusten mit Schienung',
      emoji: '🤧',
      description:
          'Drücken Sie ein Kissen fest auf die OP-Wunde / den Bauch. '
          'Atmen Sie tief ein, dann husten Sie kräftig gegen das Kissen. '
          'Das Kissen stabilisiert die Narbe und reduziert Schmerzen.',
      category: RehabCategory.breathing,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.opday,
      durationSeconds: 15,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Wichtig nach Bauch- und Thorax-OPs.',
        'Schleim muss raus — nicht unterdrücken.',
        'Alternativ: Huffing (kräftiges HA-Ausatmen).',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Mobilisation (zusätzlich)
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'mob_neck_rotation',
      title: 'Kopf drehen',
      emoji: '🔄',
      description:
          'Sitzen Sie aufrecht. Drehen Sie den Kopf langsam nach rechts, '
          'bis ein leichtes Ziehen spürbar ist — halten. Zurück zur Mitte, '
          'dann nach links. Kinn bleibt auf Schulterhöhe.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.preop,
      durationSeconds: 20,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Schultern bleiben entspannt unten.',
        'Auch im Bett möglich.',
        'Beugt Nackenverspannungen durch Liegen vor.',
      ],
    ),
    RehabExercise(
      id: 'mob_shoulder_shrug',
      title: 'Schulterheben',
      emoji: '🤷',
      description:
          'Ziehen Sie beide Schultern gleichzeitig hoch zu den Ohren. '
          '3 Sekunden halten, dann bewusst fallen lassen und entspannen. '
          'Spüren Sie den Unterschied zwischen Anspannung und Entspannung.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.preop,
      durationSeconds: 15,
      sets: 4,
      reps: 8,
      restSeconds: 10,
      tips: [
        'Löst Verspannungen im Schulter-Nacken-Bereich.',
        'Kann im Sitzen oder Stehen durchgeführt werden.',
        'Gleichmäßig atmen — nicht pressen.',
      ],
    ),
    RehabExercise(
      id: 'mob_arm_circle',
      title: 'Armkreisen',
      emoji: '🔃',
      description:
          'Strecken Sie die Arme seitlich aus. Machen Sie kleine Kreise — '
          'erst vorwärts, dann rückwärts. Kreise langsam vergrößern.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.preop,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Schultern dabei unten lassen.',
        'Fördert die Durchblutung im Schulterbereich.',
        'Gut als Aufwärmübung vor weiteren Übungen.',
      ],
    ),
    RehabExercise(
      id: 'mob_trunk_rotation',
      title: 'Oberkörper-Rotation',
      emoji: '🔄',
      description:
          'Sitzen Sie aufrecht auf einem Stuhl. Verschränken Sie die Arme '
          'vor der Brust. Drehen Sie den Oberkörper langsam nach rechts — '
          'halten. Zurück zur Mitte, dann nach links.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 20,
      sets: 3,
      reps: 8,
      restSeconds: 10,
      tips: [
        'Das Becken bleibt fest auf dem Stuhl.',
        'Nur soweit drehen wie schmerzfrei möglich.',
        'Mobilisiert die Brustwirbelsäule.',
      ],
    ),
    RehabExercise(
      id: 'mob_cat_cow',
      title: 'Katze-Kuh (Vierfüßler)',
      emoji: '🐱',
      description:
          'Vierfüßlerstand: Hände unter den Schultern, Knie unter der Hüfte. '
          'Einatmen — Hohlkreuz machen, Kopf heben (Kuh). '
          'Ausatmen — Rücken rund machen, Kinn zur Brust (Katze).',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      tips: [
        'Bewegung an den Atem koppeln.',
        'Fließend und langsam arbeiten.',
        'Mobilisiert die gesamte Wirbelsäule.',
      ],
    ),
    RehabExercise(
      id: 'mob_hip_circle',
      title: 'Hüftkreisen',
      emoji: '⭕',
      description:
          'Stehen Sie hüftbreit, Hände an der Hüfte. Kreisen Sie das Becken '
          'langsam im Uhrzeigersinn — große, fließende Kreise. '
          'Nach der Hälfte die Richtung wechseln.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Knie bleiben leicht gebeugt.',
        'Oberkörper bleibt möglichst ruhig.',
        'Ggf. an einem Stuhl festhalten.',
      ],
    ),
    RehabExercise(
      id: 'mob_gentle_walk',
      title: 'Gehen auf der Stelle',
      emoji: '🚶',
      description:
          'Gehen Sie auf der Stelle — heben Sie die Knie abwechselnd '
          'leicht an. Arme dürfen mitschwingen. Gleichmäßiges Tempo halten.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 40,
      sets: 3,
      restSeconds: 15,
      tips: [
        'In der Nähe einer Stütze bleiben.',
        'Nicht zu hoch mit den Knien.',
        'Fördert Kreislauf und Koordination.',
      ],
    ),
    RehabExercise(
      id: 'mob_heel_toe_walk',
      title: 'Fersen-Zehen-Gang',
      emoji: '👣',
      description:
          'Gehen Sie langsam in einer Linie: Ferse des vorderen Fußes berührt '
          'die Zehenspitzen des hinteren Fußes. Blick geradeaus. '
          'Arme seitlich für Balance.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      restSeconds: 15,
      tips: [
        'Neben einer Wand gehen für Sicherheit.',
        'Trainiert Gleichgewicht und Propriozeption.',
        'Blick auf einen festen Punkt richten.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Stretching (zusätzlich)
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'stretch_hamstring',
      title: 'Oberschenkelrückseite dehnen',
      emoji: '🦵',
      description:
          'Sitzen Sie auf der Bettkante. Strecken Sie ein Bein nach vorn auf '
          'dem Bett, Zehenspitzen anziehen. Lehnen Sie den Oberkörper leicht '
          'nach vorn, bis eine Dehnung hinter dem Oberschenkel spürbar ist.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Rücken bleibt gerade — nicht einrunden.',
        'Beide Seiten gleichmäßig dehnen.',
        'Dehnung halten, nicht wippen.',
      ],
    ),
    RehabExercise(
      id: 'stretch_chest',
      title: 'Brustdehnung im Türrahmen',
      emoji: '🚪',
      description:
          'Stellen Sie sich in einen Türrahmen. Unterarme links und rechts '
          'an den Rahmen (Ellbogen auf Schulterhöhe). Machen Sie einen '
          'kleinen Schritt nach vorn, bis eine Dehnung in der Brust spürbar ist.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Öffnet den Brustkorb nach langem Liegen.',
        'Schulterblätter zusammenziehen.',
        'Nicht zu weit nach vorn lehnen.',
      ],
    ),
    RehabExercise(
      id: 'stretch_quad',
      title: 'Oberschenkel-Vorderseite dehnen',
      emoji: '🦩',
      description:
          'Stehen Sie neben einem Stuhl. Greifen Sie den Fuß der zu dehnenden '
          'Seite und ziehen Sie die Ferse Richtung Gesäß. Knie zeigen nach '
          'unten. Mit der anderen Hand am Stuhl festhalten.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Hüfte nach vorn schieben für mehr Dehnung.',
        'Knie nicht zur Seite drehen.',
        'Beide Seiten gleichmäßig.',
      ],
    ),
    RehabExercise(
      id: 'stretch_shoulder_cross',
      title: 'Schulter-Querdehnung',
      emoji: '✝️',
      description:
          'Führen Sie einen Arm gestreckt vor der Brust zur Gegenseite. '
          'Mit der anderen Hand den Arm leicht zum Körper ziehen. '
          'Dehnung in der Schulterrückseite spüren.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 20,
      sets: 3,
      restSeconds: 10,
      opTypes: ['shoulder'],
      tips: [
        'Schulter nicht hochziehen.',
        'Nur soweit wie schmerzfrei.',
        'Beide Seiten dehnen.',
      ],
    ),
    RehabExercise(
      id: 'stretch_piriformis',
      title: 'Piriformis-Dehnung',
      emoji: '🍐',
      description:
          'Rückenlage: Legen Sie den Knöchel des zu dehnenden Beins auf das '
          'Knie des anderen Beins (Figur-4-Position). Ziehen Sie das untere '
          'Bein zur Brust, bis eine tiefe Dehnung im Gesäß spürbar wird.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      restSeconds: 15,
      tips: [
        'Kopf bleibt am Boden.',
        'Löst Ischias-ähnliche Beschwerden.',
        'Beide Seiten dehnen.',
      ],
    ),
    RehabExercise(
      id: 'stretch_child_pose',
      title: 'Kindeshaltung (Child\'s Pose)',
      emoji: '🧒',
      description:
          'Kniestand: Setzen Sie das Gesäß auf die Fersen. Strecken Sie die '
          'Arme weit nach vorne auf den Boden. Stirn ablegen. '
          'Tief in den Rücken atmen und Position halten.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Entspannung für den ganzen Rücken.',
        'Knie können etwas auseinander sein.',
        'Gleichmäßig tief atmen.',
      ],
    ),
    RehabExercise(
      id: 'stretch_lateral',
      title: 'Seitliche Rumpfdehnung',
      emoji: '🌊',
      description:
          'Stehen Sie aufrecht, Füße hüftbreit. Strecken Sie einen Arm über '
          'den Kopf und beugen Sie den Oberkörper zur Gegenseite. '
          'Dehnung in der Flanke spüren. Andere Seite wiederholen.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 20,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Hüfte bleibt gerade — nicht zur Seite kippen.',
        'Gleichmäßig atmen.',
        'Öffnet die Zwischenrippenmuskulatur.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // ALLGEMEIN — Kräftigung (zusätzlich)
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'strength_clam',
      title: 'Muschel (Clam)',
      emoji: '🐚',
      description:
          'Seitenlage, Knie angewinkelt, Füße aufeinander. Heben Sie das '
          'obere Knie langsam nach oben (wie eine Muschel, die sich öffnet). '
          'Füße bleiben zusammen. Langsam schließen.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      reps: 12,
      restSeconds: 15,
      tips: [
        'Becken bleibt stabil — nicht nach hinten rollen.',
        'Stärkt die Hüft-Außenrotatoren.',
        'Theraband um die Knie für mehr Widerstand.',
      ],
    ),
    RehabExercise(
      id: 'strength_mini_squat',
      title: 'Mini-Kniebeuge',
      emoji: '🏋️',
      description:
          'Stehen Sie hüftbreit, Hände vor der Brust. Beugen Sie die Knie '
          'leicht (ca. 30–45°) — als würden Sie sich auf einen hohen Hocker '
          'setzen. Kurz halten, wieder hochdrücken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 20,
      tips: [
        'Knie bleiben hinter den Zehenspitzen.',
        'Gewicht auf den Fersen.',
        'Anfangs am Stuhl festhalten.',
      ],
    ),
    RehabExercise(
      id: 'strength_plank',
      title: 'Unterarmstütz (Plank)',
      emoji: '📏',
      description:
          'Unterarmstütz: Ellbogen unter den Schultern, Körper bildet eine '
          'gerade Linie von Kopf bis Fuß. Bauch fest anspannen. '
          'Position halten — gleichmäßig atmen.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.hard,
      phase: RehabPhase.followup,
      durationSeconds: 30,
      sets: 3,
      restSeconds: 30,
      tips: [
        'Hüfte nicht durchhängen lassen.',
        'Leichtere Variante: auf den Knien.',
        'Stärkt die gesamte Rumpfmuskulatur.',
      ],
    ),
    RehabExercise(
      id: 'strength_heel_raise',
      title: 'Fersenheben (Wadentraining)',
      emoji: '⬆️',
      description:
          'Stehen Sie aufrecht (ggf. an einer Stuhllehne festhalten). '
          'Heben Sie langsam beide Fersen vom Boden, stellen Sie sich auf '
          'die Zehenspitzen. Kurz halten, langsam absenken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.ankle,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      reps: 12,
      restSeconds: 15,
      tips: [
        'Fördert die Venenpumpe in den Waden.',
        'Fortschritt: einbeinig.',
        'Langsam hoch und noch langsamer runter.',
      ],
    ),
    RehabExercise(
      id: 'strength_seated_leg_ext',
      title: 'Kniestreckung im Sitzen',
      emoji: '🦵',
      description:
          'Sitzen Sie aufrecht auf einem Stuhl. Strecken Sie ein Bein langsam '
          'nach vorn, bis das Knie ganz durchgestreckt ist. '
          'Kurz halten, langsam absenken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      tips: [
        'Oberschenkel bleibt auf dem Stuhl.',
        'Fußspitze anziehen für mehr Muskelaktivierung.',
        'Nicht mit Schwung arbeiten.',
      ],
    ),
    RehabExercise(
      id: 'strength_prone_leg_curl',
      title: 'Beinbeuger (Bauchlage)',
      emoji: '🦿',
      description:
          'Bauchlage: Beugen Sie langsam ein Knie und führen Sie die Ferse '
          'Richtung Gesäß. In der Mitte kurz halten, dann kontrolliert '
          'wieder strecken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 25,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      opTypes: ['knee'],
      tips: [
        'Becken bleibt am Boden.',
        'Trainiert die ischiokrurale Muskulatur.',
        'Fortschritt: Gewichtsmanschette.',
      ],
    ),
    RehabExercise(
      id: 'strength_side_leg_raise',
      title: 'Seitliches Beinheben (Stehen)',
      emoji: '↔️',
      description:
          'Stehen Sie seitlich an einem Stuhl. Heben Sie das äußere Bein '
          'gestreckt zur Seite (ca. 30°). Kurz halten, langsam senken. '
          'Oberkörper bleibt aufrecht.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 25,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      tips: [
        'Nicht mit dem Oberkörper ausweichen.',
        'Stärkt den Gluteus medius.',
        'Wichtig für stabiles Gangbild.',
      ],
    ),
    RehabExercise(
      id: 'strength_superman',
      title: 'Superman (Rückenstrecker)',
      emoji: '🦸',
      description:
          'Bauchlage: Strecken Sie gleichzeitig den rechten Arm und das '
          'linke Bein vom Boden ab. Kurz halten, ablegen. '
          'Dann linker Arm und rechtes Bein.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      reps: 8,
      restSeconds: 20,
      tips: [
        'Blick zum Boden für neutrale HWS.',
        'Nur wenige cm vom Boden abheben.',
        'Stärkt den unteren Rücken und die Gesäßmuskulatur.',
      ],
    ),
    RehabExercise(
      id: 'strength_dead_bug',
      title: 'Dead Bug (Rumpfstabilität)',
      emoji: '🪲',
      description:
          'Rückenlage: Arme zur Decke, Knie 90° angewinkelt. Strecken Sie '
          'langsam den rechten Arm nach hinten und gleichzeitig das linke '
          'Bein nach vorn. Zurück zur Mitte, dann die andere Seite.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      reps: 8,
      restSeconds: 20,
      tips: [
        'Unterer Rücken bleibt am Boden!',
        'Langsam und kontrolliert arbeiten.',
        'Hervorragend für die tiefe Rumpfmuskulatur.',
      ],
    ),
    RehabExercise(
      id: 'strength_step_up',
      title: 'Step-Up (Stufensteigen)',
      emoji: '🪜',
      description:
          'Stellen Sie sich vor eine niedrige Stufe. Steigen Sie mit dem '
          'operierten Bein auf die Stufe, dann das andere nach. '
          'Zurück: gesundes Bein zuerst runter, dann das operierte.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.followup,
      durationSeconds: 30,
      sets: 3,
      reps: 10,
      restSeconds: 20,
      tips: [
        'Geländer oder Stuhllehne zum Festhalten.',
        'Knie darf nicht nach innen kippen.',
        'Alltagsnahes Krafttraining.',
      ],
    ),
    RehabExercise(
      id: 'strength_single_leg_balance',
      title: 'Einbeinstand',
      emoji: '🦩',
      description:
          'Stehen Sie auf einem Bein, das andere Knie leicht angehoben. '
          'Position halten. Bei Bedarf an einem Stuhl festhalten. '
          'Blick auf einen festen Punkt richten.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.general,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 20,
      sets: 4,
      restSeconds: 15,
      tips: [
        'Trainiert Gleichgewicht und Sprunggelenk.',
        'Fortschritt: Augen schließen.',
        'Beide Seiten gleich lange üben.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // KNIE-SPEZIFISCH (zusätzlich)
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'knee_terminal_ext',
      title: 'Endgradige Kniestreckung',
      exerciseIcon: AppIcons.kneeOp,
                    exerciseIconColor: AppIcons.kneeOpColor,
      description:
          'Sitzen Sie mit einer Rolle unter dem Knie. Strecken Sie das Knie '
          'langsam vollständig durch, sodass die Ferse abhebt. '
          'Kurz halten, langsam beugen.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 25,
      sets: 3,
      reps: 12,
      restSeconds: 15,
      opTypes: ['knee'],
      tips: [
        'Trainiert die letzte Streckung — häufig vernachlässigt!',
        'Handtuchrolle oder kleiner Ball unters Knie.',
        'Fußspitze anziehen.',
      ],
    ),
    RehabExercise(
      id: 'knee_wall_slide',
      title: 'Wand-Kniebeuge',
      exerciseIcon: AppIcons.kneeOp,
                    exerciseIconColor: AppIcons.kneeOpColor,
      description:
          'Lehnen Sie sich mit dem Rücken an die Wand. Rutschen Sie langsam '
          'nach unten (ca. 45° Kniebeugung). Position halten, dann hoch.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.followup,
      durationSeconds: 30,
      sets: 3,
      reps: 8,
      restSeconds: 20,
      opTypes: ['knee'],
      tips: [
        'Sicherer als freie Kniebeugen.',
        'Füße etwas vor der Wand positionieren.',
        'Fortschritt: tiefer rutschen.',
      ],
    ),
    RehabExercise(
      id: 'knee_step_down',
      title: 'Kontrolliertes Stufen-Absteigen',
      exerciseIcon: AppIcons.kneeOp,
                    exerciseIconColor: AppIcons.kneeOpColor,
      description:
          'Stehen Sie auf einer niedrigen Stufe. Senken Sie langsam einen '
          'Fuß zum Boden, indem Sie das Standbein-Knie kontrolliert beugen. '
          'Die Ferse tippt kurz an, dann wieder hoch.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.knee,
      difficulty: RehabDifficulty.hard,
      phase: RehabPhase.followup,
      durationSeconds: 30,
      sets: 3,
      reps: 8,
      restSeconds: 20,
      opTypes: ['knee'],
      tips: [
        'Knie darf nicht nach innen kippen!',
        'Trainiert exzentrische Kontrolle.',
        'Geländer zum Festhalten.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // HÜFTE-SPEZIFISCH (zusätzlich)
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'hip_bridge_single',
      title: 'Einbeinige Brücke',
      exerciseIcon: AppIcons.hipOp,
                    exerciseIconColor: AppIcons.hipOpColor,
      description:
          'Rückenlage, beide Knie angewinkelt. Strecken Sie ein Bein nach '
          'oben. Heben Sie das Becken mit dem Standbein an, bis der Körper '
          'eine Linie bildet. Halten, langsam senken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.hard,
      phase: RehabPhase.followup,
      durationSeconds: 25,
      sets: 3,
      reps: 8,
      restSeconds: 20,
      opTypes: ['hip'],
      tips: [
        'Becken darf nicht zur Seite kippen.',
        'Erst wenn beidbeinige Brücke sicher klappt.',
        'Hervorragend für Gluteus maximus.',
      ],
    ),
    RehabExercise(
      id: 'hip_extension_prone',
      title: 'Beinstrecken in Bauchlage',
      exerciseIcon: AppIcons.hipOp,
                    exerciseIconColor: AppIcons.hipOpColor,
      description:
          'Bauchlage: Heben Sie ein gestrecktes Bein langsam von der '
          'Unterlage ab (ca. 15–20 cm). Kurz halten, langsam senken. '
          'Becken bleibt am Boden.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 25,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      opTypes: ['hip'],
      tips: [
        'Trainiert die Hüftstrecker.',
        'Nicht ins Hohlkreuz gehen.',
        'Beide Seiten üben.',
      ],
    ),
    RehabExercise(
      id: 'hip_adduction',
      title: 'Bein-Adduktion (Seitlage)',
      exerciseIcon: AppIcons.hipOp,
                    exerciseIconColor: AppIcons.hipOpColor,
      description:
          'Seitenlage auf der operierten Seite. Das obere Bein auf einem '
          'Kissen ablegen. Heben Sie das untere (operierte) Bein langsam '
          'an. Kurz halten, senken.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 25,
      sets: 3,
      reps: 10,
      restSeconds: 15,
      opTypes: ['hip'],
      tips: [
        'Trainiert die Innenseite der Oberschenkel.',
        'Ergänzt die Abduktionsübung.',
        'Langsam und kontrolliert.',
      ],
    ),
    RehabExercise(
      id: 'hip_sit_to_stand',
      title: 'Aufstehen (Hüft-fokussiert)',
      exerciseIcon: AppIcons.hipOp,
                    exerciseIconColor: AppIcons.hipOpColor,
      description:
          'Setzen Sie sich auf einen erhöhten Stuhl. Stehen Sie auf, indem '
          'Sie sich nach vorn lehnen und mit den Beinen drücken — ohne die '
          'Hände zur Hilfe zu nehmen. Kontrolliert zurücksetzen.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.hip,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week1,
      durationSeconds: 30,
      sets: 3,
      reps: 8,
      restSeconds: 20,
      opTypes: ['hip'],
      tips: [
        'Hüfte nicht über 90° beugen (OP-Vorsichtsmaßnahme).',
        'Erhöhter Sitz (Kissen) erleichtert den Start.',
        'Alltagsnahes Funktionstraining.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // SCHULTER-SPEZIFISCH (zusätzlich)
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'shoulder_isometric_ext_rot',
      title: 'Isometrische Außenrotation',
      emoji: '🤛',
      description:
          'Stehen Sie seitlich an einer Wand. Ellbogen 90° gebeugt, am Körper. '
          'Drücken Sie den Handrücken gegen die Wand — 5 Sekunden halten. '
          'Dabei bewegt sich der Arm NICHT.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 15,
      sets: 5,
      reps: 6,
      restSeconds: 10,
      opTypes: ['shoulder'],
      tips: [
        'Isometrisch = Muskel arbeitet ohne Bewegung.',
        'Sicher in früher Reha-Phase.',
        'Auf 50 % Kraft starten, langsam steigern.',
      ],
    ),
    RehabExercise(
      id: 'shoulder_internal_rotation',
      title: 'Innenrotation (Schulter)',
      emoji: '🔄',
      description:
          'Stehen Sie aufrecht, Ellbogen am Körper, 90° gebeugt. '
          'Führen Sie die Hand langsam zum Bauch (Innenrotation). '
          'Widerstand durch Theraband oder freie Hand der Gegenseite.',
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
        'Ergänzt die Außenrotation.',
        'Ellbogen bleibt am Körper.',
        'Schultergürtel stabil halten.',
      ],
    ),
    RehabExercise(
      id: 'shoulder_scapula_squeeze',
      title: 'Schulterblatt-Zusammenziehen',
      emoji: '🦅',
      description:
          'Sitzen oder stehen Sie aufrecht. Ziehen Sie beide Schulterblätter '
          'kräftig nach hinten-unten zusammen, als wollten Sie einen Stift '
          'dazwischen einklemmen. Halten, dann lösen.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 20,
      sets: 4,
      reps: 10,
      restSeconds: 10,
      opTypes: ['shoulder'],
      tips: [
        'Verbessert die Haltung.',
        'Grundlage für alle Schulterübungen.',
        'Auch im Bett möglich.',
      ],
    ),
    RehabExercise(
      id: 'shoulder_assisted_flexion',
      title: 'Assistierte Schulterbeugung',
      emoji: '🙌',
      description:
          'Rückenlage: Greifen Sie mit beiden Händen einen Stock oder '
          'ein Handtuch. Führen Sie die Arme gestreckt über den Kopf — '
          'der gesunde Arm hilft dem operierten.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 20,
      sets: 4,
      restSeconds: 15,
      opTypes: ['shoulder'],
      tips: [
        'Schmerzfrei arbeiten!',
        'Besenstiel oder Handtuch funktioniert gut.',
        'Langsam den Bewegungsumfang steigern.',
      ],
    ),
    RehabExercise(
      id: 'shoulder_shrug_circles',
      title: 'Schulterkreise mit Gewicht',
      emoji: '🏋️',
      description:
          'Halten Sie je eine leichte Flasche (0,5l) in jeder Hand. '
          'Kreisen Sie die Schultern vorwärts, dann rückwärts. '
          'Langsame, große Kreise.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.shoulder,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.followup,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 15,
      opTypes: ['shoulder'],
      tips: [
        'Nur nach Arzt-Freigabe.',
        'Wasserflaschen als Gewicht nutzen.',
        'Fördert Durchblutung und Beweglichkeit.',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // RÜCKEN-SPEZIFISCH
    // ═══════════════════════════════════════════════════════════════
    RehabExercise(
      id: 'back_pelvic_tilt',
      title: 'Beckenkippen',
      emoji: '🔻',
      description:
          'Rückenlage, Knie angewinkelt. Kippen Sie das Becken so, '
          'dass der untere Rücken flach auf den Boden drückt. '
          'Kurz halten, dann lösen. Kontrollierte Bewegung.',
      category: RehabCategory.mobilization,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.opday,
      durationSeconds: 20,
      sets: 4,
      reps: 10,
      restSeconds: 10,
      tips: [
        'Grundübung für Rücken-Patienten.',
        'Bauchmuskeln leicht anspannen.',
        'Auch als Schmerzlinderung nutzbar.',
      ],
    ),
    RehabExercise(
      id: 'back_knee_to_chest',
      title: 'Knie zur Brust',
      emoji: '🤗',
      description:
          'Rückenlage: Ziehen Sie ein Knie langsam zur Brust. '
          'Mit beiden Händen festhalten und 15 Sekunden halten. '
          'Langsam zurück, dann das andere Bein.',
      category: RehabCategory.stretching,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.easy,
      phase: RehabPhase.week1,
      durationSeconds: 25,
      sets: 3,
      restSeconds: 10,
      tips: [
        'Entspannt den unteren Rücken.',
        'Kopf bleibt am Boden.',
        'Kein Ruck — sanft heranziehen.',
      ],
    ),
    RehabExercise(
      id: 'back_bird_dog',
      title: 'Bird Dog (Vierfüßler)',
      emoji: '🐕',
      description:
          'Vierfüßlerstand: Strecken Sie den rechten Arm nach vorn und '
          'gleichzeitig das linke Bein nach hinten. Kurz halten (3 Sek.), '
          'zurück, dann die andere Seite.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.medium,
      phase: RehabPhase.week2,
      durationSeconds: 30,
      sets: 3,
      reps: 8,
      restSeconds: 15,
      tips: [
        'Rücken bleibt gerade — kein Hohlkreuz.',
        'Bauchnabel zur Wirbelsäule ziehen.',
        'Trainiert Koordination und Rumpfstabilität.',
      ],
    ),
    RehabExercise(
      id: 'back_side_plank',
      title: 'Seitstütz (Side Plank)',
      emoji: '📐',
      description:
          'Seitenlage: Stützen Sie sich auf den Unterarm. Heben Sie die '
          'Hüfte vom Boden, bis der Körper eine gerade Linie bildet. '
          'Position halten.',
      category: RehabCategory.strengthening,
      targetArea: RehabTargetArea.back,
      difficulty: RehabDifficulty.hard,
      phase: RehabPhase.followup,
      durationSeconds: 20,
      sets: 3,
      restSeconds: 20,
      tips: [
        'Leichtere Variante: Knie am Boden.',
        'Stärkt die seitliche Rumpfmuskulatur.',
        'Beide Seiten gleich lange halten.',
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
