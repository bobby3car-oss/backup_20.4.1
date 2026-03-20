/// Operating mode for the Bella AI assistant.
enum BellaMode {
  /// Normal chat mode — general questions & actions.
  normal,

  /// Structured symptom triage: Bella asks follow-up questions like
  /// a nurse (duration, characteristics, accompanying symptoms) and
  /// concludes with an action recommendation.
  symptomCheck;

  String toJson() => name;

  static BellaMode fromJson(String value) =>
      BellaMode.values.firstWhere((e) => e.name == value,
          orElse: () => BellaMode.normal);
}
