/// Types of actions Bella AI can execute for Pro users.
enum BellaActionType {
  createAppointment,
  createTimelineTask,
  logVital,
  logMedication,
  logPain,
}

/// Status of a proposed Bella action.
enum BellaActionStatus { pending, confirmed, cancelled, failed }

/// A structured action that Bella proposes in response to a user request.
class BellaAction {
  const BellaAction({
    required this.type,
    required this.params,
  });

  final BellaActionType type;
  final Map<String, dynamic> params;

  /// Parse from the JSON payload sent by the Cloud Function.
  factory BellaAction.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? '').toString();
    final type = BellaActionType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => BellaActionType.createTimelineTask,
    );
    final params = json['params'] is Map<String, dynamic>
        ? json['params'] as Map<String, dynamic>
        : <String, dynamic>{};
    return BellaAction(type: type, params: params);
  }

  /// Human-readable label for display in the confirmation card.
  String get label => switch (type) {
        BellaActionType.createAppointment => 'Termin anlegen',
        BellaActionType.createTimelineTask => 'Aufgabe erstellen',
        BellaActionType.logVital => 'Vitalwert eintragen',
        BellaActionType.logMedication => 'Medikament loggen',
        BellaActionType.logPain => 'Schmerz erfassen',
      };

  /// Emoji icon for the action type.
  String get emoji => switch (type) {
        BellaActionType.createAppointment => '📅',
        BellaActionType.createTimelineTask => '📋',
        BellaActionType.logVital => '🩺',
        BellaActionType.logMedication => '💊',
        BellaActionType.logPain => '😣',
      };

  /// Summary of the key params for the confirmation card preview.
  Map<String, String> get previewFields {
    final fields = <String, String>{};
    switch (type) {
      case BellaActionType.createAppointment:
        if (params['title'] != null) fields['Titel'] = params['title'];
        if (params['date'] != null) fields['Datum'] = params['date'];
        if (params['appointmentType'] != null) {
          fields['Typ'] = params['appointmentType'];
        }
        if (params['doctorName'] != null) {
          fields['Arzt'] = params['doctorName'];
        }
        if (params['locationName'] != null) {
          fields['Ort'] = params['locationName'];
        }
      case BellaActionType.createTimelineTask:
        if (params['title'] != null) fields['Titel'] = params['title'];
        if (params['date'] != null) fields['Datum'] = params['date'];
        if (params['taskType'] != null) fields['Typ'] = params['taskType'];
      case BellaActionType.logVital:
        if (params['systolic'] != null && params['diastolic'] != null) {
          fields['Blutdruck'] = '${params['systolic']}/${params['diastolic']}';
        }
        if (params['pulse'] != null) fields['Puls'] = '${params['pulse']}';
        if (params['temperature'] != null) {
          fields['Temperatur'] = '${params['temperature']}°C';
        }
      case BellaActionType.logMedication:
        if (params['name'] != null) fields['Medikament'] = params['name'];
        if (params['dose'] != null) fields['Dosis'] = params['dose'];
      case BellaActionType.logPain:
        if (params['painLevel'] != null) {
          fields['Schmerzlevel'] = '${params['painLevel']}/10';
        }
        if (params['bodyRegion'] != null) {
          fields['Region'] = params['bodyRegion'];
        }
        if (params['painType'] != null) fields['Art'] = params['painType'];
    }
    return fields;
  }
}
