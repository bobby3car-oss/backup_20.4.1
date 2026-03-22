/// Pre-defined suggested questions grouped by operation type.
///
/// Key = operation type identifier, value = list of suggested question texts.
/// The special key `allgemein` provides questions that apply to every operation.
const Map<String, List<String>> suggestedQuestions = <String, List<String>>{
  'allgemein': [
    'Wann sind die Fäden/Klammern zu entfernen?',
    'Welche Medikamente soll ich absetzen?',
    'Wie lange darf ich nach der OP nicht duschen oder baden?',
    'Wann ist der erste Kontrolltermin?',
    'Welche Warnsignale erfordern sofortige ärztliche Hilfe?',
    'Wie lange muss ich nach der OP im Bett bleiben?',
    'Was darf ich in den ersten Tagen essen und trinken?',
    'Wann darf ich wieder arbeiten?',
  ],
  'knie': [
    'Wann darf ich wieder Auto fahren?',
    'Wie lange muss ich Thrombosestrümpfe tragen?',
    'Ab wann darf ich das Knie voll belasten?',
    'Welche Übungen soll ich zu Hause machen?',
    'Brauche ich eine Reha oder Physiotherapie?',
    'Darf ich Treppen steigen?',
  ],
  'huefte': [
    'Wie lange gelten die Bewegungseinschränkungen?',
    'Wann darf ich wieder auf der operierten Seite schlafen?',
    'Brauche ich einen Toilettensitzerhöher?',
    'Wie lange darf ich nicht schwer heben?',
    'Wann darf ich wieder Auto fahren?',
    'Welche Sportarten sind langfristig erlaubt?',
  ],
  'schulter': [
    'Wie lange muss ich die Schlinge/Orthese tragen?',
    'Ab wann beginnt die Physiotherapie?',
    'Darf ich den Arm über Schulterhöhe heben?',
    'Wann darf ich wieder am Computer arbeiten?',
    'Wie schlafe ich am besten nach der OP?',
  ],
  'herz': [
    'Wann darf ich mich wieder körperlich belasten?',
    'Welche Medikamente muss ich dauerhaft nehmen?',
    'Wie kontrolliere ich Blutdruck und Puls zu Hause?',
    'Wann kann ich wieder Auto fahren?',
    'Darf ich fliegen und ab wann?',
    'Worauf muss ich bei der Ernährung achten?',
  ],
  'bauch': [
    'Wann darf ich wieder schwer heben?',
    'Wie pflege ich die Narbe richtig?',
    'Was darf ich in der ersten Woche essen?',
    'Wann darf ich wieder Sport treiben?',
    'Wie erkenne ich eine Wundheilungsstörung?',
  ],
  'augen': [
    'Wie lange darf ich nicht lesen oder am Bildschirm arbeiten?',
    'Wann darf ich mich wieder bücken?',
    'Welche Augentropfen brauche ich und wie lange?',
    'Wann kann ich wieder Auto fahren?',
    'Darf ich nach der OP fliegen?',
  ],
};

/// Returns suggested questions for the given [opType], always including
/// the generic questions. Returns only generic questions if [opType]
/// has no specific entry.
List<String> suggestedQuestionsFor(String? opType) {
  final general = suggestedQuestions['allgemein'] ?? const <String>[];
  if (opType == null || opType.trim().isEmpty) return general;

  final key = opType.trim().toLowerCase();
  final specific = suggestedQuestions[key];
  if (specific == null) return general;

  return <String>[...specific, ...general];
}
