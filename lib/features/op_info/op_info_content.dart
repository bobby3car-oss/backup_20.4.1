import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class OpInfoCategory {
  const OpInfoCategory({
    required this.id,
    required this.emoji,
    required this.label,
    required this.intro,
    this.cards = const [],
    this.faqs = const [],
    this.warnings = const [],
  });

  final String id;
  final String emoji;
  final String label;
  final String intro;
  final List<OpInfoCard> cards;
  final List<OpInfoFaq> faqs;
  final List<OpInfoWarning> warnings;
}

class OpInfoCard {
  const OpInfoCard({required this.title, required this.body});

  final String title;
  final String body;
}

class OpInfoFaq {
  const OpInfoFaq({
    required this.question,
    required this.shortAnswer,
    this.detail,
  });

  final String question;
  final String shortAnswer;
  final String? detail;
}

enum OpWarnLevel { green, yellow, red }

class OpInfoWarning {
  const OpInfoWarning({
    required this.text,
    required this.level,
    this.action,
  });

  final String text;
  final OpWarnLevel level;
  final String? action;

  Color get color => switch (level) {
        OpWarnLevel.green => const Color(0xFF34C759),
        OpWarnLevel.yellow => const Color(0xFFFF9F0A),
        OpWarnLevel.red => const Color(0xFFFF3B30),
      };

  String get levelLabel => switch (level) {
        OpWarnLevel.green => 'Normal',
        OpWarnLevel.yellow => 'Beobachten',
        OpWarnLevel.red => 'Sofort handeln',
      };

  IconData get icon => switch (level) {
        OpWarnLevel.green => Icons.check_circle_rounded,
        OpWarnLevel.yellow => Icons.info_rounded,
        OpWarnLevel.red => Icons.warning_rounded,
      };
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

const opInfoCategories = <OpInfoCategory>[
  // ── 1. Vorbereitung ─────────────────────────────────────────────────────
  OpInfoCategory(
    id: 'preparation',
    emoji: '📝',
    label: 'Vorbereitung',
    intro:
        'Eine gute Vorbereitung gibt Ihnen Sicherheit und hilft dem '
        'Behandlungsteam, den Eingriff reibungslos durchzuführen. '
        'Planen Sie die folgenden Punkte rechtzeitig ein.',
    cards: [
      OpInfoCard(
        title: 'Nüchternheit',
        body:
            'In der Regel dürfen Sie mindestens 6 Stunden vor dem Eingriff '
            'nichts mehr essen und 2 Stunden vorher keine klaren Flüssigkeiten '
            'mehr trinken. Ihr Anästhesie-Team teilt Ihnen die genauen Zeiten '
            'mit. Das Nüchternsein senkt das Risiko von Komplikationen '
            'während der Narkose erheblich.',
      ),
      OpInfoCard(
        title: 'OP-Gebiet vorbereiten',
        body:
            'Rasieren oder reinigen Sie das Operationsgebiet nur, wenn Ihr '
            'Behandlungsteam Sie ausdrücklich dazu auffordert. Verwenden Sie '
            'keine Cremes, Deo oder Nagellack am OP-Tag, da diese die '
            'Überwachung und Desinfektion beeinträchtigen können.',
      ),
      OpInfoCard(
        title: 'Medikamente besprechen',
        body:
            'Informieren Sie Ihr Team über alle Medikamente, die Sie '
            'einnehmen – auch pflanzliche Mittel und Nahrungsergänzungen. '
            'Manche Blutverdünner oder Schmerzmittel müssen vor dem Eingriff '
            'pausiert oder angepasst werden. Ändern Sie nichts eigenmächtig.',
      ),
      OpInfoCard(
        title: 'Kliniktasche packen',
        body:
            'Packen Sie bequeme Kleidung, rutschfeste Schlappen, '
            'Hygieneartikel, Ladekabel und ggf. Kompressionsstrümpfe ein. '
            'Bringen Sie außerdem Versichertenkarte, Einwilligungsbogen, '
            'Medikamentenliste und relevante Befunde mit.',
      ),
      OpInfoCard(
        title: 'Transport & Begleitung',
        body:
            'Nach einer Narkose dürfen Sie nicht selbst Auto fahren. '
            'Organisieren Sie rechtzeitig eine Begleitperson für Hin- und '
            'Rückfahrt. Bei ambulanten Eingriffen sollte in den ersten '
            '24 Stunden jemand bei Ihnen sein.',
      ),
    ],
  ),

  // ── 2. OP-Tag ──────────────────────────────────────────────────────────
  OpInfoCategory(
    id: 'op_day',
    emoji: '🏥',
    label: 'OP-Tag',
    intro:
        'Der Operationstag folgt einem festen Ablauf. Wenn Sie wissen, '
        'was auf Sie zukommt, können Sie sich besser darauf einstellen '
        'und fühlen sich sicherer.',
    cards: [
      OpInfoCard(
        title: 'Ankunft & Anmeldung',
        body:
            'Kommen Sie pünktlich zum vereinbarten Zeitpunkt. An der '
            'Aufnahme werden Ihre Daten geprüft und Sie erhalten ein '
            'Patientenarmband. Planen Sie etwas Puffer ein, damit Sie '
            'entspannt ankommen.',
      ),
      OpInfoCard(
        title: 'Gespräch mit dem Team',
        body:
            'Vor dem Eingriff sprechen Sie nochmals mit dem Chirurgen und '
            'dem Anästhesie-Team. Dabei werden letzte Fragen geklärt, der '
            'Eingriff bestätigt und die Narkoseform besprochen. Nutzen '
            'Sie diese Gelegenheit für offene Fragen.',
      ),
      OpInfoCard(
        title: 'Vorbereitung & Eingriff',
        body:
            'Im Vorbereitungsraum erhalten Sie OP-Kleidung und ggf. eine '
            'leichte Beruhigung. Im OP-Saal überwacht das Team durchgehend '
            'Ihre Vitalwerte. Die Dauer hängt vom Eingriff ab – Ihr Arzt '
            'hat Ihnen eine Einschätzung gegeben.',
      ),
      OpInfoCard(
        title: 'Aufwachraum',
        body:
            'Nach dem Eingriff kommen Sie in den Aufwachraum, wo Sie '
            'engmaschig überwacht werden. Leichte Benommenheit, Frösteln '
            'oder Übelkeit sind normal und klingen meist schnell ab. '
            'Erst wenn Ihre Werte stabil sind, werden Sie verlegt.',
      ),
    ],
  ),

  // ── 3. Nach der OP ─────────────────────────────────────────────────────
  OpInfoCategory(
    id: 'after_op',
    emoji: '🩹',
    label: 'Nach der OP',
    intro:
        'Die ersten Tage nach dem Eingriff sind entscheidend für eine '
        'gute Heilung. Geben Sie Ihrem Körper Zeit und befolgen Sie '
        'die Empfehlungen Ihres Behandlungsteams.',
    cards: [
      OpInfoCard(
        title: 'Schmerzmittel',
        body:
            'Nehmen Sie die verordneten Schmerzmittel regelmäßig nach Plan '
            'ein – auch wenn die Schmerzen gerade erträglich sind. So '
            'verhindern Sie Schmerzspitzen und ermöglichen eine bessere '
            'Mobilisation. Ändern Sie die Dosis nie eigenmächtig.',
      ),
      OpInfoCard(
        title: 'Wundbeobachtung',
        body:
            'Halten Sie die Wunde sauber und trocken. Leichte Schwellungen '
            'und Blutergüsse im OP-Gebiet sind in den ersten Tagen normal. '
            'Achten Sie auf Rötung, starke Schwellung, Fieber oder Sekret '
            '– das sind Warnzeichen, die ärztlich geprüft werden sollten.',
      ),
      OpInfoCard(
        title: 'Frühe Bewegung',
        body:
            'Frühe, angepasste Bewegung fördert die Durchblutung und '
            'beugt Thrombosen vor. Stehen Sie auf, sobald Ihr Arzt es '
            'freigibt, und steigern Sie die Belastung nur schrittweise. '
            'Vermeiden Sie ruckartige Bewegungen im OP-Gebiet.',
      ),
      OpInfoCard(
        title: 'Ernährung & Flüssigkeit',
        body:
            'Trinken Sie ausreichend Wasser und Tee. Beginnen Sie mit '
            'leichter Kost und steigern Sie nach Verträglichkeit. '
            'Alkohol und Koffein sollten Sie in den ersten Tagen '
            'meiden, da sie die Heilung beeinträchtigen können.',
      ),
      OpInfoCard(
        title: 'Nachsorgetermine',
        body:
            'Nehmen Sie alle vereinbarten Kontrolltermine wahr, auch wenn '
            'Sie sich gut fühlen. Bei diesen Terminen prüft Ihr Arzt den '
            'Heilungsverlauf, entfernt ggf. Fäden und passt die '
            'Medikation an.',
      ),
    ],
  ),

  // ── 4. Warnzeichen ────────────────────────────────────────────────────
  OpInfoCategory(
    id: 'warnings',
    emoji: '⚠️',
    label: 'Warnzeichen',
    intro:
        'Nicht jedes Symptom nach einer OP ist besorgniserregend. '
        'Die folgende Übersicht hilft Ihnen einzuschätzen, wann Sie '
        'abwarten können und wann Sie reagieren sollten.',
    warnings: [
      OpInfoWarning(
        text: 'Leichte Schwellung und blaue Flecken im OP-Bereich',
        level: OpWarnLevel.green,
        action: 'Normal in den ersten Tagen. Kühlen und hochlagern hilft.',
      ),
      OpInfoWarning(
        text: 'Leichtes Ziehen oder Druckgefühl an der Wunde',
        level: OpWarnLevel.green,
        action:
            'Gehört zum Heilungsprozess. Schmerzmittel nach Plan '
            'einnehmen.',
      ),
      OpInfoWarning(
        text: 'Müdigkeit und Erschöpfung',
        level: OpWarnLevel.green,
        action:
            'Der Körper braucht Energie zum Heilen. Gönnen Sie sich '
            'ausreichend Ruhe.',
      ),
      OpInfoWarning(
        text: 'Zunehmende Rötung oder Schwellung um die Wunde',
        level: OpWarnLevel.yellow,
        action: 'Beim nächsten Arzttermin ansprechen oder telefonisch melden.',
      ),
      OpInfoWarning(
        text: 'Anhaltende Übelkeit oder Erbrechen über 24 Stunden',
        level: OpWarnLevel.yellow,
        action: 'Ärztlichen Rat einholen, falls es nicht nachlässt.',
      ),
      OpInfoWarning(
        text: 'Schmerzen, die trotz Medikamenten deutlich zunehmen',
        level: OpWarnLevel.yellow,
        action: 'Nicht abwarten – zeitnah ärztlich abklären lassen.',
      ),
      OpInfoWarning(
        text: 'Fieber über 38,5 °C',
        level: OpWarnLevel.red,
        action: 'Umgehend Ihre Klinik oder Ihren Arzt kontaktieren.',
      ),
      OpInfoWarning(
        text: 'Plötzliche starke Blutung oder Sekretaustritt aus der Wunde',
        level: OpWarnLevel.red,
        action: 'Sofort medizinische Hilfe rufen.',
      ),
      OpInfoWarning(
        text: 'Atemnot, starke Brustschmerzen oder Bewusstseinsveränderung',
        level: OpWarnLevel.red,
        action: 'Notruf 112 – das kann auf eine ernste Komplikation hindeuten.',
      ),
    ],
  ),

  // ── 5. Häufige Fragen ─────────────────────────────────────────────────
  OpInfoCategory(
    id: 'faq',
    emoji: '❓',
    label: 'Häufige Fragen',
    intro:
        'Hier finden Sie Antworten auf die häufigsten Fragen rund um '
        'Ihren Eingriff. Falls Ihre Frage nicht dabei ist, nutzen '
        'Sie die Funktion „Fragen für den Arzt", um sie zu notieren.',
    faqs: [
      OpInfoFaq(
        question: 'Wie lange dauert der Eingriff?',
        shortAnswer:
            'Die reine OP-Zeit variiert je nach Eingriff meist zwischen '
            '30 Minuten und mehreren Stunden.',
        detail:
            'Ihr Chirurg hat Ihnen eine individuelle Einschätzung gegeben. '
            'Rechnen Sie zusätzlich Zeit für Vorbereitung und Aufwachraum '
            'ein – insgesamt sind Sie oft 2–4 Stunden im OP-Bereich. '
            'Ihre Begleitperson wird informiert, sobald Sie im '
            'Aufwachraum sind.',
      ),
      OpInfoFaq(
        question: 'Wann darf ich wieder essen und trinken?',
        shortAnswer:
            'In der Regel dürfen Sie wenige Stunden nach dem Eingriff '
            'wieder trinken und leichte Kost zu sich nehmen.',
        detail:
            'Beginnen Sie mit kleinen Schlucken Wasser und steigern Sie '
            'langsam. Bei Vollnarkose kann leichte Übelkeit auftreten – '
            'warten Sie in dem Fall ab. Bei Eingriffen im Bauchraum '
            'gelten manchmal besondere Kostaufbau-Regeln, die Ihr Team '
            'Ihnen mitteilt.',
      ),
      OpInfoFaq(
        question: 'Welche Schmerzmittel bekomme ich?',
        shortAnswer:
            'Sie erhalten einen individuellen Schmerzplan, meist mit einer '
            'Kombination aus Basismedikament und Bedarfsmedikation.',
        detail:
            'Häufig eingesetzt werden Ibuprofen, Paracetamol oder '
            'Metamizol als Basis. Bei stärkeren Schmerzen können kurzzeitig '
            'Opioide verordnet werden. Nehmen Sie die Medikamente '
            'regelmäßig nach Plan ein und melden Sie, wenn die Schmerzen '
            'nicht ausreichend kontrolliert sind.',
      ),
      OpInfoFaq(
        question: 'Wann darf ich wieder duschen?',
        shortAnswer:
            'Meist nach 48 Stunden mit wasserfestem Pflaster, solange die '
            'Wunde nicht direkt unter den Wasserstrahl kommt.',
        detail:
            'Baden, Schwimmen und Saunagänge sollten Sie vermeiden, bis '
            'die Wunde vollständig verschlossen ist – das kann 2–4 Wochen '
            'dauern. Ihr Arzt gibt Ihnen individuelle Hinweise. Tupfen '
            'Sie die Wunde nach dem Duschen vorsichtig trocken.',
      ),
      OpInfoFaq(
        question: 'Wie lange bin ich krankgeschrieben?',
        shortAnswer:
            'Das hängt stark vom Eingriff und Ihrem Beruf ab – Ihr Arzt '
            'stellt die Bescheinigung individuell aus.',
        detail:
            'Bei kleineren ambulanten Eingriffen reichen oft wenige Tage, '
            'bei größeren Operationen können es mehrere Wochen sein. '
            'Körperlich belastende Berufe erfordern in der Regel eine '
            'längere Pause. Besprechen Sie mit Ihrem Arzt, ab wann Sie '
            'wieder arbeiten und Sport treiben dürfen.',
      ),
      OpInfoFaq(
        question: 'Wann findet die nächste Kontrolle statt?',
        shortAnswer:
            'Der erste Kontrolltermin liegt meist 5–10 Tage nach dem '
            'Eingriff, oft verbunden mit der Fadenentfernung.',
        detail:
            'Weitere Kontrollen werden je nach Heilungsverlauf vereinbart. '
            'Nutzen Sie die Termin-Funktion in der App, um nichts zu '
            'vergessen. Auch bei zufriedenstellendem Verlauf sind diese '
            'Termine wichtig, um Komplikationen frühzeitig zu erkennen.',
      ),
      OpInfoFaq(
        question: 'Was ist bei einer Narkose zu beachten?',
        shortAnswer:
            'Halten Sie sich an die Nüchternheitsregel, informieren Sie '
            'das Team über Vorerkrankungen und Allergien.',
        detail:
            'Je nach Eingriff kommen Vollnarkose, Spinalanästhesie oder '
            'Regionalverfahren in Frage. Ihr Anästhesist bespricht mit '
            'Ihnen die beste Option. Müdigkeit, leichte Übelkeit oder '
            'Halsschmerzen danach sind möglich und klingen in der Regel '
            'rasch ab. Fahren Sie nach einer Narkose nicht selbst.',
      ),
      OpInfoFaq(
        question: 'Wer ist mein Ansprechpartner bei Problemen?',
        shortAnswer:
            'Tagsüber die Station bzw. Praxis, nachts und am Wochenende '
            'die Notaufnahme oder der ärztliche Bereitschaftsdienst.',
        detail:
            'Notieren Sie sich vor der Entlassung die Telefonnummer Ihrer '
            'Station und des zuständigen Arztes. Bei lebensbedrohlichen '
            'Symptomen – Atemnot, starke Blutung, Bewusstlosigkeit – '
            'rufen Sie sofort den Notruf 112.',
      ),
    ],
  ),
];
