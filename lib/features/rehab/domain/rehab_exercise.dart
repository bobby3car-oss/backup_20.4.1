/// Difficulty levels for rehabilitation exercises.
enum RehabDifficulty { easy, medium, hard }

/// Categories of rehabilitation exercises.
enum RehabCategory { mobilization, strengthening, stretching, breathing }

/// Target body areas for exercises.
enum RehabTargetArea { general, knee, hip, shoulder, back, ankle }

/// Phases of the rehabilitation process.
enum RehabPhase { preop, opday, week1, week2, followup }

/// Immutable model describing a single rehabilitation exercise.
class RehabExercise {
  const RehabExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetArea,
    required this.difficulty,
    required this.phase,
    required this.durationSeconds,
    required this.sets,
    this.reps,
    this.restSeconds = 15,
    this.tips = const <String>[],
    this.emoji = '🏋️',
    this.opTypes = const <String>[],
  });

  final String id;
  final String title;
  final String description;
  final RehabCategory category;
  final RehabTargetArea targetArea;
  final RehabDifficulty difficulty;
  final RehabPhase phase;
  final int durationSeconds;
  final int sets;
  final int? reps;
  final int restSeconds;
  final List<String> tips;
  final String emoji;
  final List<String> opTypes;

  bool get isGeneral => opTypes.isEmpty;

  String get formattedDuration {
    final total = durationSeconds * sets + restSeconds * (sets - 1);
    if (total < 60) return '${total}s';
    final min = total ~/ 60;
    final sec = total % 60;
    return sec > 0 ? '${min}m ${sec}s' : '${min}m';
  }
}
