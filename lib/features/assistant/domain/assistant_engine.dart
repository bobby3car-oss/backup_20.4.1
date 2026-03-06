import 'knowledge_base.dart';

/// A simple offline rule-based engine that matches user queries against
/// the [knowledgeEntries] knowledge base using keyword scoring.
class AssistantEngine {
  AssistantEngine();

  static const _fallback =
      'Dazu habe ich leider keine Information. Bitte wende dich an dein '
      'medizinisches Team oder schau in die OP-Infos in der App.';

  /// Match [input] against the knowledge base and return the best answer.
  String query(String input) {
    final normalised = _normalise(input);
    if (normalised.isEmpty) return _fallback;

    final words = normalised.split(RegExp(r'\s+'));

    int bestScore = 0;
    KnowledgeEntry? bestEntry;

    for (final entry in knowledgeEntries) {
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

    return _fallback;
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
