class OpInfoSection {
  const OpInfoSection({
    required this.id,
    required this.title,
    required this.entries,
  });

  final String id;
  final String title;
  final List<OpInfoEntry> entries;
}

class OpInfoEntry {
  const OpInfoEntry({required this.title, required this.body});

  final String title;
  final String body;
}

const opInfoSections = <OpInfoSection>[
  OpInfoSection(
    id: 'before_op',
    title: 'Vor der OP',
    entries: [
      OpInfoEntry(
        title: 'Vorbereitung zuhause',
        body:
            'Organisiere Transport, Unterlagen und Unterstützung für die ersten Tage nach der OP.',
      ),
      OpInfoEntry(
        title: 'Essen und Trinken',
        body:
            'Halte dich an die Vorgaben der Klinik zum Nüchternsein vor dem Eingriff.',
      ),
      OpInfoEntry(
        title: 'Wichtige Unterlagen',
        body:
            'Bring Versichertenkarte, Aufklärung, Medikamentenliste und relevante Befunde mit.',
      ),
    ],
  ),
  OpInfoSection(
    id: 'op_day',
    title: 'OP-Tag',
    entries: [
      OpInfoEntry(
        title: 'Ankunft in der Klinik',
        body:
            'Plane ausreichend Puffer ein und melde dich zur vereinbarten Zeit an.',
      ),
      OpInfoEntry(
        title: 'Ablauf',
        body:
            'Vor dem Eingriff erfolgen meist kurze Untersuchungen, Aufklärung und OP-Vorbereitung.',
      ),
    ],
  ),
  OpInfoSection(
    id: 'after_op',
    title: 'Nach der OP',
    entries: [
      OpInfoEntry(
        title: 'Erholung',
        body:
            'Ruhe, ausreichende Flüssigkeit und die Einhaltung der ärztlichen Anweisungen sind zentral.',
      ),
      OpInfoEntry(
        title: 'Kontrollen',
        body:
            'Wahrgenommene Nachsorgetermine helfen, Heilungsverlauf und Risiken früh zu erkennen.',
      ),
    ],
  ),
  OpInfoSection(
    id: 'anesthesia',
    title: 'Narkose',
    entries: [
      OpInfoEntry(
        title: 'Narkoseformen',
        body:
            'Je nach Eingriff kommen Vollnarkose oder regionale Verfahren in Frage.',
      ),
      OpInfoEntry(
        title: 'Nachwirkungen',
        body:
            'Müdigkeit, leichte Übelkeit oder Halsschmerzen sind möglich und klingen oft rasch ab.',
      ),
    ],
  ),
  OpInfoSection(
    id: 'pain',
    title: 'Schmerz',
    entries: [
      OpInfoEntry(
        title: 'Schmerzbeobachtung',
        body:
            'Dokumentiere dein Schmerzlevel regelmäßig, um Veränderungen gut einschätzen zu können.',
      ),
      OpInfoEntry(
        title: 'Wann handeln?',
        body:
            'Starke oder plötzlich zunehmende Schmerzen sollten ärztlich abgeklärt werden.',
      ),
    ],
  ),
  OpInfoSection(
    id: 'movement',
    title: 'Bewegung',
    entries: [
      OpInfoEntry(
        title: 'Frühmobilisation',
        body:
            'Frühe, angepasste Bewegung kann Heilung unterstützen und Komplikationen vorbeugen.',
      ),
      OpInfoEntry(
        title: 'Belastung',
        body:
            'Belastung nur im empfohlenen Rahmen steigern und auf Warnzeichen achten.',
      ),
    ],
  ),
  OpInfoSection(
    id: 'wound',
    title: 'Wunde',
    entries: [
      OpInfoEntry(
        title: 'Wundpflege',
        body:
            'Halte die Wunde sauber und trocken und beachte Verbands- und Duschhinweise.',
      ),
      OpInfoEntry(
        title: 'Warnzeichen',
        body:
            'Rötung, starke Schwellung, Fieber oder Sekret sollten zeitnah geprüft werden.',
      ),
    ],
  ),
  OpInfoSection(
    id: 'medication',
    title: 'Medikamente',
    entries: [
      OpInfoEntry(
        title: 'Einnahmeplan',
        body:
            'Nimm Medikamente nach Plan ein und ändere Dosis oder Schema nicht eigenständig.',
      ),
      OpInfoEntry(
        title: 'Nebenwirkungen',
        body:
            'Bei auffälligen Nebenwirkungen oder Unsicherheit bitte medizinisch rückfragen.',
      ),
    ],
  ),
];
