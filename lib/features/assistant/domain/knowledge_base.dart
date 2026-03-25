/// Categories for assistant knowledge entries.
enum AssistantCategory {
  opAblauf,
  eingriffe,
  appHilfe,
  wundeSchmerz,
}

/// A single knowledge entry the engine can match against.
class KnowledgeEntry {
  const KnowledgeEntry({
    required this.keywords,
    required this.answer,
    required this.category,
    this.allowedRoles,
  });

  final List<String> keywords;
  final String answer;
  final AssistantCategory category;

  /// If non-null, only users with one of these roles see this entry.
  /// `null` means the entry is available to all roles.
  final List<String>? allowedRoles;
}

/// The complete offline knowledge base.
const knowledgeEntries = <KnowledgeEntry>[
  // ─── OP-Ablauf ──────────────────────────────────────────────────

  KnowledgeEntry(
    keywords: ['nüchtern', 'essen', 'trinken', 'fasten', 'hunger'],
    answer:
        'In der Regel dürfen Sie 6 Stunden vor der OP nichts essen und 2 Stunden '
        'vorher nichts mehr trinken (klare Flüssigkeiten). Halten Sie sich immer '
        'an die konkreten Anweisungen Ihrer Klinik.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['vorbereitung', 'vor der op', 'was mitbringen', 'unterlagen', 'dokumente'],
    answer:
        'Bringen Sie Ihre Versichertenkarte, den Aufklärungsbogen, eine aktuelle '
        'Medikamentenliste und relevante Befunde mit. Packen Sie bequeme Kleidung, '
        'Hygieneartikel und ggf. Gehhilfen ein.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['ablauf', 'op-tag', 'operationstag', 'was passiert', 'ankommen', 'ankunft'],
    answer:
        'Am OP-Tag melden Sie sich zur vereinbarten Zeit an. Es folgen kurze '
        'Voruntersuchungen und Aufklärungsgespräche. Danach werden Sie in den '
        'OP-Bereich gebracht, die Narkose wird eingeleitet und der Eingriff '
        'durchgeführt. Danach kommen Sie in den Aufwachraum.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['nach der op', 'nachsorge', 'erholung', 'genesung', 'heilung'],
    answer:
        'Ruhe, ausreichende Flüssigkeit und die Einhaltung ärztlicher '
        'Anweisungen sind entscheidend. Nehmen Sie alle Nachsorgetermine wahr '
        'und steigern Sie Belastung nur im empfohlenen Rahmen.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['narkose', 'vollnarkose', 'regional', 'betäubung', 'anästhesie'],
    answer:
        'Je nach Eingriff kommen Vollnarkose oder regionale Verfahren '
        '(z. B. Spinalanästhesie) in Frage. Mögliche Nachwirkungen sind '
        'leichte Übelkeit, Müdigkeit oder Halsschmerzen — diese klingen meist '
        'rasch ab.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['entlassung', 'nach hause', 'krankenhaus verlassen', 'abholung', 'transport'],
    answer:
        'Klären Sie vorab, wer Sie abholt. Nach einer Narkose dürfen Sie in '
        'der Regel 24 Stunden nicht selbst Auto fahren. Die Klinik gibt Ihnen '
        'einen Entlassbrief und Medikamente mit.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['medikamente', 'blutverdünner', 'absetzen', 'pause', 'einnahme'],
    answer:
        'Manche Medikamente (z. B. Blutverdünner) müssen vor der OP pausiert '
        'werden. Ändern Sie aber nie eigenständig Ihre Medikation — sprechen '
        'Sie immer mit Ihrem Arzt.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['angst', 'nervös', 'aufgeregt', 'sorgen', 'beruhigung'],
    answer:
        'Aufregung vor einer OP ist völlig normal. Sprechen Sie offen mit Ihrem '
        'Behandlungsteam über Ihre Sorgen. Atemübungen und Ablenkung (Musik, '
        'Hörbuch) können helfen.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['aufklärung', 'einwilligung', 'unterschrift', 'consent'],
    answer:
        'Vor dem Eingriff müssen Sie die Aufklärungsbögen unterschreiben. Lesen '
        'Sie diese sorgfältig durch und stellen Sie alle Fragen vorher. Ohne '
        'Ihre Einwilligung darf nicht operiert werden.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['aufwachraum', 'nach narkose', 'aufwachen', 'recovery'],
    answer:
        'Im Aufwachraum werden Ihre Vitalwerte überwacht, bis die Narkosewirkung '
        'nachlässt. Sie bleiben dort meist 1–2 Stunden. Leichte Verwirrung, '
        'Frieren oder Übelkeit können vorkommen und sind normal.',
    category: AssistantCategory.opAblauf,
  ),

  // ─── Häufige Eingriffe ──────────────────────────────────────────

  KnowledgeEntry(
    keywords: ['knie', 'knie-tep', 'knieprothese', 'kniegelenk', 'knieersatz'],
    answer:
        'Bei einer Knie-TEP (Totalendoprothese) wird das verschlissene '
        'Kniegelenk durch ein künstliches ersetzt. Die OP dauert ca. 1–2 h. '
        'Danach beginnt sofort die Physiotherapie. Volle Belastung ist meist '
        'nach 6–12 Wochen möglich.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['hüfte', 'hüft-tep', 'hüftprothese', 'hüftgelenk', 'hüftersatz'],
    answer:
        'Bei einer Hüft-TEP wird das Hüftgelenk durch ein Implantat ersetzt. '
        'Die OP dauert ca. 1–1,5 h. Schon am OP-Tag oder am Tag danach beginnt '
        'die Mobilisation. Vollbelastung erreichen die meisten nach 6–8 Wochen.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['blinddarm', 'appendix', 'appendektomie', 'appendizitis'],
    answer:
        'Die Blinddarm-OP (Appendektomie) erfolgt meist laparoskopisch über '
        'kleine Schnitte. Im Normalfall können Sie nach 2–3 Tagen die Klinik '
        'verlassen und nach 1–2 Wochen wieder leichte Tätigkeiten aufnehmen.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['kaiserschnitt', 'sectio', 'geburt', 'entbindung'],
    answer:
        'Ein Kaiserschnitt (Sectio) dauert ca. 30–60 Minuten. Danach sollten '
        'Sie sich 6–8 Wochen schonen. Heben Sie in dieser Zeit nichts Schweres. '
        'Die Wundpflege erfolgt ähnlich wie bei anderen Bauch-OPs.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['leistenbruch', 'hernie', 'leiste', 'leistenhernie'],
    answer:
        'Ein Leistenbruch wird meist minimalinvasiv mit einem Netzimplantat '
        'versorgt. Die OP dauert ca. 30–60 Minuten. Leichte Aktivität ist '
        'nach wenigen Tagen möglich, Sport nach ca. 4 Wochen.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['gallenblase', 'cholezystektomie', 'gallensteine', 'galle'],
    answer:
        'Die Gallenblasenentfernung (Cholezystektomie) erfolgt meist '
        'laparoskopisch und dauert ca. 30–60 Minuten. Die meisten Patienten '
        'können nach 1–3 Tagen nach Hause und dürfen schrittweise wieder '
        'normal essen.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['arthroskopie', 'gelenkspiegelung', 'spiegelung', 'meniskus'],
    answer:
        'Eine Arthroskopie (Gelenkspiegelung) ist ein minimalinvasiver Eingriff, '
        'z. B. am Knie, an der Schulter oder am Sprunggelenk. Die OP dauert '
        'meist 30–60 Minuten. Oft ist sie ambulant möglich.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['schulter', 'schulter-op', 'rotatorenmanschette', 'schultergelenk'],
    answer:
        'Schulter-OPs umfassen z. B. Reparaturen der Rotatorenmanschette oder '
        'Stabilisierungen. Eine Ruhigstellung dauert meist 4–6 Wochen, '
        'Physiotherapie beginnt nach ärztlicher Freigabe.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['wirbelsäule', 'bandscheibe', 'rücken', 'bandscheibenvorfall'],
    answer:
        'Bandscheiben-OPs werden oft minimalinvasiv durchgeführt. Je nach '
        'Eingriff ist ein Krankenhausaufenthalt von 2–5 Tagen üblich. '
        'Danach folgt eine schrittweise Belastungssteigerung mit Physiotherapie.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['handgelenk', 'karpaltunnel', 'hand-op', 'hand'],
    answer:
        'Eine Karpaltunnel-OP dauert oft nur 15–30 Minuten und wird häufig '
        'ambulant durchgeführt. Leichte Beweglichkeit der Finger ist sofort '
        'erwünscht, volle Belastung nach ca. 4–6 Wochen.',
    category: AssistantCategory.eingriffe,
  ),

  // ─── App-Hilfe ──────────────────────────────────────────────────

  KnowledgeEntry(
    keywords: ['timeline', 'zeitstrahl', 'aufgaben', 'startseite', 'feed'],
    answer:
        'Die Timeline (Startseite) zeigt alle anstehenden und erledigten '
        'Aufgaben rund um Ihre OP — sortiert nach Datum. Tippen Sie auf '
        'eine Aufgabe, um sie zu öffnen oder als erledigt zu markieren.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['schmerz', 'schmerztagebuch', 'schmerz erfassen', 'schmerzlevel'],
    answer:
        'Im Schmerztagebuch (Mehr → Schmerztagebuch) können Sie Ihr '
        'Schmerzlevel (0–10) erfassen, die Körperstelle angeben und ob Sie '
        'Medikamente genommen haben. So haben Sie und Ihr Arzt einen guten '
        'Überblick über den Verlauf.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['termin', 'termine', 'kalender', 'arzttermin', 'nachsorge termin'],
    answer:
        'Unter „Termine" können Sie Arzttermine anlegen, Erinnerungen setzen '
        'und den Termintyp (Nachsorge, Physiotherapie etc.) wählen. Die App '
        'erinnert Sie rechtzeitig per Benachrichtigung.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['foto', 'fotos', 'bild', 'dokumentation', 'kamera'],
    answer:
        'Unter Mehr → Fotos können Sie Fotos Ihrer Wunde oder von '
        'Dokumenten aufnehmen. Diese werden sicher gespeichert und können '
        'bei Arztterminen gezeigt werden.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['wunde', 'wunddokumentation', 'wundverlauf'],
    answer:
        'In der Wunddokumentation (Mehr → Wunde) können Sie Fotos, '
        'Schmerzlevel und Notizen zu Ihrer Wunde festhalten. Nutzen Sie '
        'die Vergleichsfunktion, um den Heilungsverlauf zu sehen.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['medikament', 'medikamentenplan', 'dosis', 'med', 'tablette'],
    answer:
        'Unter Mehr → Medikamente können Sie Einnahmen protokollieren '
        '(Name, Dosis, Zeitpunkt). Die App erstellt kein Rezept — bitte '
        'halten Sie sich immer an die ärztliche Verordnung.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['vitalwerte', 'blutdruck', 'puls', 'vital'],
    answer:
        'Unter Mehr → Vitalwerte können Sie Blutdruck (systolisch/diastolisch) '
        'und Puls erfassen. Regelmäßige Einträge helfen, Veränderungen '
        'frühzeitig zu erkennen.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['packliste', 'koffer', 'einpacken', 'mitnehmen', 'krankenhaus tasche'],
    answer:
        'Unter Mehr → Packliste finden Sie eine Checkliste für den '
        'Krankenhausaufenthalt. Haken Sie Punkte ab, um den Überblick '
        'zu behalten.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['arztbericht', 'bericht', 'zusammenfassung', 'export'],
    answer:
        'Unter Mehr → Arztbericht erstellt die App eine Zusammenfassung '
        'Ihrer Gesundheitsdaten (Schmerz, Vitalwerte, Wundfotos). Diese '
        'können Sie beim Arzttermin zeigen oder teilen.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['linking', 'angehörige', 'einladung', 'begleiter', 'familie'],
    answer:
        'Unter Mehr → Linking können Sie Angehörige oder Begleitpersonen '
        'einladen, Ihre Daten mitzulesen. Die eingeladene Person sieht nur '
        'das, was Sie freigeben.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['benachrichtigung', 'erinnerung', 'push', 'notification', 'alarm'],
    answer:
        'Die App erinnert Sie an Termine, Medikamenten-Einnahmen und '
        'anstehende Aufgaben per Push-Benachrichtigung. Unter Einstellungen '
        'können Sie diese anpassen.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['sprache', 'sprachmemo', 'aufnahme', 'diktieren', 'memo'],
    answer:
        'Unter Mehr → Sprache & Memos können Sie Sprachaufnahmen '
        'erstellen — z. B. um Fragen an den Arzt festzuhalten oder '
        'Symptome zu beschreiben, wenn Tippen schwerfällt. (Pro-Feature)',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['pro', 'premium', 'abo', 'bezahlen', 'kosten', 'upgrade'],
    answer:
        'Mit Operationsbegleiter Pro erhalten Sie Zugang zu erweiterten '
        'Funktionen wie Sprach-Memos, Red-Flag-Warnungen und Angehörigen-Linking. '
        'Sie finden das Upgrade unter Mehr → Pro-Status.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['dokument', 'dokumente', 'pdf', 'datei', 'hochladen'],
    answer:
        'Unter „Dokumente" in der Hauptnavigation können Sie wichtige '
        'Dateien (Befunde, Arztbriefe, Rezepte) hochladen und verwalten. '
        'Diese sind jederzeit griffbereit.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['assistent', 'ki', 'chatbot', 'hilfe', 'support', 'diese app'],
    answer:
        'Ich bin Bella AI 🐰 — deine KI-Assistentin, die dir offline '
        'Informationen zu OPs, Nachsorge und App-Funktionen gibt. '
        'Ich ersetze keine ärztliche Beratung.',
    category: AssistantCategory.appHilfe,
  ),

  // ─── Wunde & Schmerz ───────────────────────────────────────────

  KnowledgeEntry(
    keywords: ['wundpflege', 'wunde pflegen', 'desinfektion', 'sauber', 'duschen'],
    answer:
        'Halten Sie die Wunde sauber und trocken. Duschen ist meist erst '
        'nach ärztlicher Freigabe erlaubt (oft nach 48 h). Verwenden Sie '
        'keine Eigenmedikation auf der Wunde ohne Rücksprache.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['verbandwechsel', 'pflaster', 'verband', 'wechseln'],
    answer:
        'Wechseln Sie den Verband nach ärztlicher Anweisung — meist alle '
        '1–2 Tage oder bei Verschmutzung. Arbeiten Sie mit sauberen Händen '
        'und sterilen Materialien.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: [
      'red flag', 'warnsignal', 'warnzeichen', 'arzt rufen', 'notfall',
      'fieber', 'rötung', 'eiter', 'schwellung', 'infektion',
    ],
    answer:
        'Suchen Sie umgehend ärztliche Hilfe bei: Fieber über 38,5 °C, '
        'zunehmender Rötung oder Schwellung um die Wunde, eitrigem oder '
        'übel riechendem Sekret, starken oder plötzlich zunehmenden Schmerzen, '
        'Taubheit oder Gefühlsverlust. Diese Hinweise ersetzen keine ärztliche '
        'Diagnose.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['schmerzen', 'schmerzmittel', 'ibuprofen', 'paracetamol', 'schmerztherapie'],
    answer:
        'Leichte bis mäßige Schmerzen nach einer OP sind normal und nehmen '
        'meist mit der Zeit ab. Nehmen Sie Schmerzmittel immer nach ärztlicher '
        'Anweisung ein. Bei starken oder zunehmenden Schmerzen kontaktieren '
        'Sie Ihr Behandlungsteam.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['bewegung', 'mobilisation', 'aufstehen', 'laufen', 'sport', 'belastung'],
    answer:
        'Frühe, angepasste Bewegung fördert die Heilung und beugt '
        'Komplikationen wie Thrombose vor. Steigern Sie die Belastung nur '
        'im empfohlenen Rahmen und achten Sie auf Warnzeichen wie Schwellung '
        'oder Schmerz.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['narbe', 'narbenpflege', 'narbenbildung'],
    answer:
        'Narben brauchen Monate, um vollständig zu reifen. Schützen Sie '
        'frische Narben vor Sonne (LSF 50+). Narbenpflege-Cremes oder '
        'Silikonpflaster können nach ärztlicher Rücksprache helfen.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['thrombose', 'embolie', 'strümpfe', 'heparin', 'spritze'],
    answer:
        'Nach OPs besteht ein erhöhtes Thromboserisiko. Tragen Sie '
        'Kompressionsstrümpfe und wenden Sie ggf. Heparin-Spritzen an, '
        'wie von Ihrem Arzt verordnet. Bewegen Sie die Beine regelmäßig.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['ernährung', 'essen nach op', 'diät', 'trinken nach op', 'kostaufbau'],
    answer:
        'Nach der OP beginnen Sie meist mit leichter Kost und steigern '
        'langsam. Trinken Sie ausreichend. Bei Bauch-OPs gibt das '
        'Behandlungsteam einen stufenweisen Kostaufbau vor.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['physiotherapie', 'reha', 'übungen', 'krankengymnastik'],
    answer:
        'Physiotherapie ist ein wichtiger Teil der Genesung, besonders nach '
        'Gelenk-OPs. Machen Sie die verordneten Übungen regelmäßig. '
        'Übertreiben Sie nicht — hören Sie auf Ihren Körper.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['krankschreibung', 'arbeitsunfähig', 'arbeit', 'büro', 'beruf'],
    answer:
        'Die Dauer der Arbeitsunfähigkeit hängt vom Eingriff und Ihrer '
        'beruflichen Tätigkeit ab. Nach kleinen Eingriffen oft 1–2 Wochen, '
        'nach größeren OPs auch 4–12 Wochen. Ihr Arzt entscheidet individuell.',
    category: AssistantCategory.wundeSchmerz,
  ),

  // ─── Erweiterte medizinische Themen ─────────────────────────────

  KnowledgeEntry(
    keywords: ['vollnarkose', 'allgemeinanästhesie', 'intubation', 'beatmung'],
    answer:
        'Bei einer Vollnarkose werden Sie durch intravenöse Medikamente '
        'in einen tiefen Schlaf versetzt. Ihre Atmung wird gesichert '
        '(Kehlkopfmaske oder Tubus). Überwacht werden Herz, Blutdruck, '
        'Sauerstoff und Temperatur. Mögliche Nachwirkungen: Übelkeit (20–30 %), '
        'Halsschmerzen, Heiserkeit, Frösteln, vorübergehende Verwirrtheit.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['spinalanästhesie', 'peridural', 'pda', 'rückenmark', 'regional'],
    answer:
        'Bei der Spinalanästhesie wird ein Betäubungsmittel in den '
        'Rückenmarkskanal gespritzt — Sie spüren von der Hüfte abwärts '
        'nichts. Ideal für Knie/Hüft-OPs und Kaiserschnitt. Kopfschmerzen '
        'danach sind selten (1–2 %), Bettruhe hilft.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['who', 'checkliste', 'team-time-out', 'sicherheit', 'verwechslung'],
    answer:
        'Vor jeder OP gibt es ein Team-Time-Out (WHO-Checkliste): Name, '
        'Eingriff und OP-Seite werden laut verifiziert. Das schützt vor '
        'Verwechslungen und ist weltweit Standard.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['ponv', 'übelkeit', 'erbrechen', 'kotzgefühl', 'schlecht'],
    answer:
        'Übelkeit und Erbrechen nach Narkose (PONV) betrifft 20–30 % der '
        'Patienten. Risikofaktoren: weiblich, Nichtraucher, Reisekrankheit. '
        'Ihr Anästhesist kann vorbeugend Medikamente geben. Melden Sie sich '
        'beim Pflegepersonal, wenn Ihnen übel ist.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['fäden', 'klammern', 'naht', 'fäden ziehen', 'entfernen'],
    answer:
        'Fäden oder Klammern werden je nach Körperstelle nach 7–14 Tagen '
        'entfernt. Gesicht: 5–7 Tage, Rumpf: 10–14 Tage, Gelenke: 12–14 '
        'Tage. Steri-Strips fallen von allein ab. Ihr Arzt legt den Termin fest.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['duschen', 'baden', 'schwimmen', 'waschen', 'sauna'],
    answer:
        'Duschen ist meist nach 48 Stunden mit Wundpflaster erlaubt — die '
        'Wunde nicht direkt unter den Wasserstrahl halten. Baden, '
        'Schwimmen und Sauna erst nach komplettem Wundschluss und '
        'Fadenzug (oft 2–3 Wochen). Fragen Sie Ihren Arzt.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['autofahren', 'fahren', 'auto', 'verkehr', 'steuer'],
    answer:
        'Nach einer Narkose dürfen Sie mindestens 24 Stunden nicht Auto fahren. '
        'Bei OPs an Armen oder Beinen hängt es von Schmerzmitteln und '
        'Beweglichkeit ab. Ihr Arzt gibt Ihnen individuelle Freigabe.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['alkohol', 'bier', 'wein', 'trinken alkohol'],
    answer:
        'Kein Alkohol für mindestens 24 Stunden nach einer Narkose. '
        'Solange Sie Schmerzmittel nehmen (besonders Opioide oder Ibuprofen), '
        'sollten Sie keinen Alkohol trinken — gefährliche Wechselwirkungen!',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['verstopfung', 'stuhlgang', 'darm', 'verdauung', 'obstipation'],
    answer:
        'Verstopfung nach OPs ist häufig — Narkose, Schmerzmittel (Opioide) '
        'und Bettruhe verlangsamen den Darm. Trinken Sie viel, essen Sie '
        'Ballaststoffe und bewegen Sie sich. Ggf. leichtes Abführmittel '
        'nach ärztlicher Rücksprache.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['reha', 'anschlussheilbehandlung', 'ahb', 'kur', 'stationäre reha'],
    answer:
        'Eine Anschlussheilbehandlung (AHB/Reha) wird bei größeren Eingriffen '
        'empfohlen (Hüft/Knie-TEP, Wirbelsäulen-OPs). Der Antrag läuft über '
        'den Sozialdienst der Klinik. Dauer: meist 3 Wochen stationär.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['müdigkeit', 'erschöpfung', 'fatigue', 'schlapp', 'energie'],
    answer:
        'Ausgeprägte Müdigkeit (Fatigue) nach einer OP ist normal und kann '
        'Wochen anhalten. Ihr Körper braucht Energie zum Heilen. Gönnen Sie '
        'sich Pausen, aber bleiben Sie in Bewegung. Bei anhaltender '
        'Erschöpfung sprechen Sie mit Ihrem Arzt.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['schlaf', 'schlafstörung', 'einschlafen', 'durchschlafen', 'insomnia'],
    answer:
        'Schlafprobleme nach einer OP sind häufig — Schmerzen, Medikamente '
        'und Sorgen können den Schlaf stören. Tipps: feste Schlafzeiten, '
        'kein Bildschirm vor dem Schlafen, ruhige Umgebung, Entspannungsübungen. '
        'Sprechen Sie bei anhaltenden Problemen mit Ihrem Arzt.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['zweitmeinung', 'anderer arzt', 'alternative', 'noch ein arzt'],
    answer:
        'Eine Zweitmeinung einzuholen ist Ihr Recht als Patient. '
        'Bitten Sie Ihren Arzt um Befunde und Bilder. Viele Krankenkassen '
        'unterstützen Zweitmeinungsprogramme. Dies ist kein Misstrauen, '
        'sondern gute Selbstfürsorge.',
    category: AssistantCategory.opAblauf,
  ),

  KnowledgeEntry(
    keywords: ['kühlen', 'kälte', 'eis', 'kühlpack', 'eisbeutel'],
    answer:
        'Kühlung reduziert Schwellung und Schmerz nach OPs. Legen Sie ein '
        'Tuch zwischen Kühlpack und Haut (nie direkt!). 15–20 Minuten kühlen, '
        'dann 45 Minuten Pause. Besonders hilfreich in den ersten 48 Stunden.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['hochlagerung', 'hochlegen', 'schwellung', 'anschwellen'],
    answer:
        'Hochlagerung der operierten Stelle (über Herzhöhe) hilft gegen '
        'Schwellung. Besonders wichtig bei Knie-, Fuß- und Hand-OPs. '
        'Kissen unter das Bein/den Arm legen. In den ersten Tagen möglichst '
        'oft hochlagern.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['protein', 'eiweiß', 'ernährung heilung', 'zink', 'vitamin'],
    answer:
        'Proteinreiche Ernährung fördert die Wundheilung: Ei, Quark, Fisch, '
        'Hülsenfrüchte. Vitamin C (Obst, Gemüse) unterstützt das Immunsystem '
        'und Kollagenbildung. Zink (Nüsse, Vollkorn) fördert die Wundheilung. '
        'Ausreichend trinken (mindestens 1,5–2 Liter/Tag).',
    category: AssistantCategory.wundeSchmerz,
  ),

  // ─── Häufige Eingriffe (erweitert) ──────────────────────────────

  KnowledgeEntry(
    keywords: ['schilddrüse', 'thyreoidektomie', 'struma', 'schilddrüsen-op'],
    answer:
        'Bei der Schilddrüsen-OP wird ein Teil oder die gesamte Schilddrüse '
        'entfernt. OP: 1–3 Stunden, Klinik: 2–4 Tage. Risiken: Heiserkeit '
        '(Stimmbandnerv-Nähe), Kalzium-Mangel. Bei Totalentfernung: lebenslange '
        'Hormon-Tabletten (L-Thyroxin).',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['mandel', 'tonsillektomie', 'mandel-op', 'hals'],
    answer:
        'Die Mandel-OP (Tonsillektomie) dauert ca. 20–30 Minuten. '
        'Schmerzen beim Schlucken für 1–2 Wochen sind normal. Weiche, '
        'kühle Kost (Eis, Pudding, Suppe). WICHTIG: Nachblutungsgefahr '
        'bis Tag 14 — bei Blutung aus dem Mund SOFORT in die Klinik!',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['prostata', 'turp', 'prostatektomie', 'prostata-op'],
    answer:
        'Prostata-OPs: TURP (durch die Harnröhre, 1–2h) bei gutartiger '
        'Vergrößerung; radikale Prostatektomie (offen/roboterassistiert, '
        '2–4h) bei Krebs. Katheter für Tage bis Wochen. Inkontinenz-Training '
        'wichtig. Potenz kann beeinträchtigt sein — besprechen Sie dies vorab.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['katarakt', 'grauer star', 'augen-op', 'linse'],
    answer:
        'Die Katarakt-OP (Grauer Star) ist ambulant, dauert 15–20 Minuten '
        'unter Lokalanästhesie. Sehverbesserung oft schon am nächsten Tag. '
        'Augentropfen nach Schema benutzen. Nicht am Auge reiben. Keine '
        'schwere Belastung für 1–2 Wochen.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['hallux', 'zeh', 'fuss-op', 'fuß', 'großzehe', 'ballen'],
    answer:
        'Bei der Hallux-Valgus-Korrektur wird der Großzehenballen begradigt. '
        'OP: 30–60 Minuten. Spezialschuh für 4–6 Wochen. Schwellung kann '
        'Monate anhalten. Normaler Schuh nach ca. 6–8 Wochen.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['hysterektomie', 'gebärmutter', 'gebärmutterentfernung', 'uterus'],
    answer:
        'Die Gebärmutterentfernung erfolgt vaginal, laparoskopisch oder '
        'offen. Klinik: 2–7 Tage. Schonung: 4–6 Wochen. Kein schweres '
        'Heben, kein Sport, kein Geschlechtsverkehr für 6 Wochen. '
        'Die Hormone werden weiterhin von den Eierstöcken produziert.',
    category: AssistantCategory.eingriffe,
  ),

  KnowledgeEntry(
    keywords: ['darm', 'kolon', 'darm-op', 'stoma', 'colostomie'],
    answer:
        'Darm-OPs (laparoskopisch oder offen) erfordern 5–14 Tage Klinik. '
        'Stufenweiser Kostaufbau nach Arztanordnung. Bei manchen Eingriffen '
        'wird vorübergehend ein künstlicher Darmausgang (Stoma) angelegt, '
        'der später meist zurückverlegt wird.',
    category: AssistantCategory.eingriffe,
  ),

  // ─── Erweiterte App-Hilfe ───────────────────────────────────────

  KnowledgeEntry(
    keywords: ['navigation', 'menü', 'aufbau', 'wo finde ich'],
    answer:
        'Die App hat 4 Hauptbereiche unten: Timeline (Startseite), '
        'Dokumente, Termine und Mehr (☰). Die meisten Funktionen '
        'finden Sie unter „Mehr" — tippen Sie auf das ☰ Symbol unten rechts.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['sync', 'synchronisation', 'cloud', 'backup', 'sichern'],
    answer:
        'Ihre Daten werden automatisch in der Cloud gesichert. Die App '
        'funktioniert auch offline — Änderungen werden synchronisiert, '
        'sobald Sie wieder online sind.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['op-datum', 'op eintragen', 'operation datum', 'wann ist op'],
    answer:
        'Ihr OP-Datum können Sie im Profil eintragen: Mehr → Profil → '
        'OP-Details. Dort können Sie auch den OP-Typ und OP-Modus '
        '(ambulant/stationär) festlegen. Die Timeline passt sich '
        'automatisch an Ihr OP-Datum an.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['gamification', 'xp', 'punkte', 'badge', 'level', 'belohnung'],
    answer:
        'Für erledigte Aufgaben in der Timeline bekommen Sie XP-Punkte '
        'und können Badges freischalten — das motiviert zur regelmäßigen '
        'Nutzung. Ihr Fortschritt wird auf der Timeline angezeigt.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['quick', 'schnellaktion', 'schnellzugriff', 'schnell'],
    answer:
        'Quick-Actions ermöglichen den Schnellzugriff auf häufige '
        'Aktionen direkt von der Timeline, z. B. Schmerz erfassen oder '
        'Vitalwerte eintragen. Tippen Sie auf das Plus-Symbol auf der '
        'Startseite.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['health', 'apple health', 'google fit', 'health connect', 'gesundheit'],
    answer:
        'Mit Pro können Sie Vitalwerte aus Apple Health (iOS) oder '
        'Google Health Connect (Android) synchronisieren. Gehen Sie zu '
        'Profil → Gesundheits-Sync. Unterstützt werden Blutdruck, '
        'Puls, Körpertemperatur, Sauerstoffsättigung (SpO₂), Gewicht '
        'und Schritte. Manuell eingegebene Werte werden auch zurück '
        'in Apple Health / Health Connect geschrieben.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['pin', 'face id', 'touch id', 'sicherheit', 'sperre', 'schutz'],
    answer:
        'Sie können Ihre App mit PIN oder Face ID / Touch ID schützen. '
        'Aktivieren Sie dies unter Mehr → Profil → Sicherheit. So '
        'haben nur Sie Zugriff auf Ihre Gesundheitsdaten.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['arzt rolle', 'arzt dashboard', 'arzt verknüpfen', 'mein arzt'],
    answer:
        'Ärzte haben ein eigenes Dashboard mit Patientenübersicht, '
        'Kalender und Berichten. Ihr Arzt kann Sie per Einladungscode '
        'verknüpfen. Sie können Ihre verknüpften Ärzte unter Mehr → '
        'Meine Ärzte sehen und verwalten.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['konto löschen', 'account löschen', 'abmelden', 'deaktivieren'],
    answer:
        'Sie können Ihr Konto unter Mehr → Profil → Konto löschen '
        'dauerhaft entfernen. Alle Daten werden unwiderruflich gelöscht. '
        'Pro-Abos müssen Sie separat im App Store / Google Play kündigen.',
    category: AssistantCategory.appHilfe,
  ),

  KnowledgeEntry(
    keywords: ['bella', 'ki', 'kostenlos', 'gratis', 'umsonst'],
    answer:
        'Ich bin Bella AI 🐰 — deine kostenlose KI-Assistentin! Du brauchst '
        'kein Pro-Abo, um mit mir zu chatten. Ich helfe dir bei Fragen rund '
        'um deine OP, Nachsorge und die App-Bedienung.',
    category: AssistantCategory.appHilfe,
  ),

  // ─── Vitalwerte Normalwerte ─────────────────────────────────────

  KnowledgeEntry(
    keywords: ['blutdruck normal', 'blutdruck werte', 'systolisch', 'diastolisch', 'hypertonie'],
    answer:
        'Blutdruck-Normalwerte: optimal <120/80 mmHg, normal <130/85, '
        'erhöht ≥140/90 (Hypertonie). Nach OPs kann der Blutdruck schwanken '
        '— Schmerz erhöht ihn oft. Zu niedrig (<90/60): Schwindel, langsam '
        'aufstehen. Messen Sie regelmäßig und tragen Sie die Werte in die App ein.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['puls normal', 'herzfrequenz', 'tachykardie', 'herzrasen'],
    answer:
        'Normaler Ruhepuls: 60–100 Schläge/Minute. Nach OPs kann der Puls '
        'erhöht sein (Schmerz, Fieber, Flüssigkeitsmangel). Puls über 100 '
        'in Ruhe oder unter 50 → Arzt informieren. Sportler haben oft '
        'niedrigeren Ruhepuls (40–60), das ist normal.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['temperatur normal', 'fieber messen', 'subfebril', 'körpertemperatur'],
    answer:
        'Normale Körpertemperatur: 36,5–37,4°C. Leicht erhöht (37,5–38,4°C, '
        'subfebril) ist nach OPs 1–2 Tage normal. Ab 38,5°C: Fieber → '
        'mögliches Infektzeichen, bitte Arzt kontaktieren. Ab 39,5°C: '
        'hohes Fieber → dringend ärztliche Behandlung.',
    category: AssistantCategory.wundeSchmerz,
  ),

  KnowledgeEntry(
    keywords: ['sauerstoff', 'spo2', 'sättigung', 'oximeter', 'pulsoximeter'],
    answer:
        'Normale Sauerstoffsättigung (SpO₂): 95–100 %. Unter 94 % ist '
        'vermindert — tiefes Atmen und Arzt informieren. Unter 90 % ist '
        'kritisch und ein Notfall. Nach OPs regelmäßig messen, besonders '
        'bei Lungenerkrankungen.',
    category: AssistantCategory.wundeSchmerz,
  ),

  // ─── Arzt / Staff – klinische Einträge ─────────────────────────

  KnowledgeEntry(
    keywords: ['icd', 'icd-10', 'diagnose code', 'klassifikation'],
    answer:
        'ICD-10: M17 = Gonarthrose, M16 = Koxarthrose, K35 = Appendizitis, '
        'T81 = Komplikation nach Eingriff, T84 = Komplikation durch '
        'orthopädische Implantate. Vollständige Codes findest du im DIMDI-Katalog '
        'oder im Arzt-Dashboard unter Patientenakte → Diagnosen.',
    category: AssistantCategory.eingriffe,
    allowedRoles: ['doctor', 'staff'],
  ),

  KnowledgeEntry(
    keywords: ['laborwerte', 'labor', 'crp', 'leukozyten', 'hb', 'hämoglobin'],
    answer:
        'Referenzbereiche postoperativ: CRP kann 24–72 h physiologisch auf '
        '50–100 mg/l steigen. Leukozyten 4–10 Tsd/µl (Leukozytose >12 Tsd '
        'abklären). Hb-Abfall >2 g/dl → Nachblutung? Quick/INR bei '
        'Antikoagulation kontrollieren. Bei auffälligen Werten: Verlaufskontrolle '
        'und klinische Korrelation.',
    category: AssistantCategory.wundeSchmerz,
    allowedRoles: ['doctor', 'staff'],
  ),

  KnowledgeEntry(
    keywords: ['dashboard', 'patientenübersicht', 'arzt dashboard', 'patienten verwalten'],
    answer:
        'Im Arzt-Dashboard siehst du alle verknüpften Patienten auf einen Blick. '
        'Status-Ampeln zeigen: 🟢 alles okay, 🟡 Aufmerksamkeit nötig, 🔴 dringend. '
        'Tippe auf einen Patienten für Details (Schmerztagebuch, Vitalwerte, '
        'Medikamente, Wunddoku, Red Flags). Einladen über Mehr → Patienten → Einladen.',
    category: AssistantCategory.appHilfe,
    allowedRoles: ['doctor', 'staff'],
  ),

  // ─── Family – Angehörigen-Einträge ─────────────────────────────

  KnowledgeEntry(
    keywords: ['unterstützen', 'helfen', 'angehörige', 'begleiten', 'caregiver'],
    answer:
        'Als Angehöriger kannst du enorm viel beitragen: Begleite den Patienten '
        'zu Terminen, hilf bei der Medikamenteneinnahme, motiviere zu Übungen '
        'und sorge für eine positive Atmosphäre. Nutze die geteilte Übersicht '
        'in der App, um informiert zu bleiben. Vergiss dabei nicht: deine eigene '
        'Gesundheit ist genauso wichtig — nimm dir Auszeiten.',
    category: AssistantCategory.opAblauf,
    allowedRoles: ['patient'],
  ),

  KnowledgeEntry(
    keywords: ['sorgen', 'angst angehörige', 'belastung', 'überfordert', 'stress'],
    answer:
        'Es ist völlig normal, sich als Angehöriger belastet oder überfordert '
        'zu fühlen. Sprich offen über deine Gefühle — mit Freunden, Familie '
        'oder professioneller Unterstützung. Viele Kliniken bieten auch '
        'Angehörigen-Beratung an. Du hilfst am besten, wenn es dir selbst gut geht.',
    category: AssistantCategory.opAblauf,
    allowedRoles: ['patient'],
  ),
];
