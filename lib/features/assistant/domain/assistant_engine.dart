import 'knowledge_base.dart';

/// A simple offline rule-based engine that matches user queries against
/// the [knowledgeEntries] knowledge base using keyword scoring.
class AssistantEngine {
  AssistantEngine();

  static const _fallback =
      'Dazu habe ich leider keine Information. Bitte wende dich an dein '
      'medizinisches Team oder schau in die OP-Infos in der App.';

  static String _fallbackForRole(String role) => switch (role) {
        'doctor' =>
          'Dazu habe ich leider keine Information. Bitte schau in die '
          'App-Hilfe, in dein Arzt-Dashboard oder kontaktiere den Support.',
        'staff' =>
          'Dazu habe ich leider keine Information. Bitte wende dich an '
          'den zuständigen Arzt oder schau in die App-Hilfe.',
        'organisation' =>
          'Dazu habe ich leider keine Information. Bitte prüfe die '
          'Organisationsübersicht, die Ärzteverwaltung oder die Statistiken '
          'in der App.',
        'family' =>
          'Dazu habe ich leider keine Information. Bitte prüfe die '
          'freigegebenen Daten des Patienten oder frage direkt beim '
          'Behandlungsteam nach.',
        'admin' =>
          'Dazu habe ich leider keine Information. Bitte prüfe das '
          'Admin-Dashboard oder den entsprechenden Verwaltungsbereich.',
        _ => _fallback,
      };

  /// Match [input] against the knowledge base and return the best answer.
  String query(String input, {String role = 'patient'}) {
    final normalised = _normalise(input);
    if (normalised.isEmpty) return _fallbackForRole(role);

    final words = normalised.split(RegExp(r'\s+'));

    int bestScore = 0;
    KnowledgeEntry? bestEntry;

    for (final entry in knowledgeEntries) {
      // Skip entries restricted to other roles.
      if (entry.allowedRoles != null && !entry.allowedRoles!.contains(role)) {
        continue;
      }
      int score = 0;
      for (final keyword in entry.keywords) {
        final normKeyword = _normalise(keyword);
        // Check for exact word match or substring containment.
        for (final word in words) {
          if (word == normKeyword ||
              (word.length >= 3 && normKeyword.contains(word)) ||
              (normKeyword.length >= 3 && word.contains(normKeyword))) {
            score++;
            break;
          }
        }
        // Also check if the full input contains the keyword phrase.
        if (normKeyword.contains(' ') && normalised.contains(normKeyword)) {
          score += 2;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestEntry = entry;
      } else if (score == bestScore && score > 0 && bestEntry != null) {
        if (entry.category.index < bestEntry.category.index) {
          bestEntry = entry;
        }
      }
    }

    if (bestScore >= 1 && bestEntry != null) {
      return bestEntry.answer;
    }

    return _fallbackForRole(role);
  }

  /// Normalise text: lowercase, replace umlauts, strip punctuation.
  static String _normalise(String text) {
    var s = text.toLowerCase().trim();
    s = s
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss');
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}
