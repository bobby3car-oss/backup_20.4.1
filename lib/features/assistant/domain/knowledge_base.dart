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
  });

  final List<String> keywords;
  final String answer;
  final AssistantCategory category;
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
        'Ich bin der OP-Assistent — ein offline verfügbarer Helfer, der '
        'Ihnen Informationen zu OPs, Nachsorge und App-Funktionen gibt. '
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
];
