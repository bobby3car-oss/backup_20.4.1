import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/assistant/domain/bella_action.dart';

void main() {
  group('BellaAction.fromJson', () {
    test('parses createAppointment correctly', () {
      final action = BellaAction.fromJson({
        'type': 'createAppointment',
        'params': {
          'title': 'Nachkontrolle',
          'date': '2026-04-15T10:00:00',
          'appointmentType': 'followUp',
        },
      });

      expect(action.type, BellaActionType.createAppointment);
      expect(action.params['title'], 'Nachkontrolle');
      expect(action.params['date'], '2026-04-15T10:00:00');
      expect(action.params['appointmentType'], 'followUp');
    });

    test('parses createTimelineTask correctly', () {
      final action = BellaAction.fromJson({
        'type': 'createTimelineTask',
        'params': {
          'title': 'Wundfoto aufnehmen',
          'date': '2026-04-12T19:00:00',
          'taskType': 'wound',
          'priority': 'normal',
        },
      });

      expect(action.type, BellaActionType.createTimelineTask);
      expect(action.params['title'], 'Wundfoto aufnehmen');
      expect(action.params['taskType'], 'wound');
    });

    test('parses logVital correctly', () {
      final action = BellaAction.fromJson({
        'type': 'logVital',
        'params': {
          'systolic': 125,
          'diastolic': 82,
          'pulse': 72,
          'temperature': 36.8,
        },
      });

      expect(action.type, BellaActionType.logVital);
      expect(action.params['systolic'], 125);
      expect(action.params['diastolic'], 82);
    });

    test('parses logMedication correctly', () {
      final action = BellaAction.fromJson({
        'type': 'logMedication',
        'params': {'name': 'Ibuprofen', 'dose': '400mg'},
      });

      expect(action.type, BellaActionType.logMedication);
      expect(action.params['name'], 'Ibuprofen');
    });

    test('parses logPain correctly', () {
      final action = BellaAction.fromJson({
        'type': 'logPain',
        'params': {
          'painLevel': 5,
          'bodyRegion': 'knie',
          'painType': 'stechend',
        },
      });

      expect(action.type, BellaActionType.logPain);
      expect(action.params['painLevel'], 5);
    });

    test('parses logWound correctly', () {
      final action = BellaAction.fromJson({
        'type': 'logWound',
        'params': {
          'note': 'Rand leicht gerötet',
          'pain': 3,
          'bodyLocation': 'rechtes Knie',
        },
      });

      expect(action.type, BellaActionType.logWound);
      expect(action.params['note'], 'Rand leicht gerötet');
    });

    test('parses createRedFlag correctly', () {
      final action = BellaAction.fromJson({
        'type': 'createRedFlag',
        'params': {
          'title': 'Erhöhte Temperatur',
          'severity': 'orange',
          'summary': 'Patient berichtet 38.7°C',
        },
      });

      expect(action.type, BellaActionType.createRedFlag);
      expect(action.params['severity'], 'orange');
    });

    test('parses rememberThis correctly', () {
      final action = BellaAction.fromJson({
        'type': 'rememberThis',
        'params': {
          'key': 'schmerzmedikament',
          'value': 'Ibuprofen wird nicht vertragen',
        },
      });

      expect(action.type, BellaActionType.rememberThis);
      expect(action.params['key'], 'schmerzmedikament');
    });

    test('parses invitePatient correctly', () {
      final action = BellaAction.fromJson({
        'type': 'invitePatient',
        'params': {},
      });

      expect(action.type, BellaActionType.invitePatient);
    });

    test('parses requestOrgStats correctly', () {
      final action = BellaAction.fromJson({
        'type': 'requestOrgStats',
        'params': {},
      });

      expect(action.type, BellaActionType.requestOrgStats);
    });

    test('parses inviteDoctor correctly', () {
      final action = BellaAction.fromJson({
        'type': 'inviteDoctor',
        'params': {'email': 'dr.mueller@example.com'},
      });

      expect(action.type, BellaActionType.inviteDoctor);
      expect(action.params['email'], 'dr.mueller@example.com');
    });

    test('parses sendBroadcast correctly', () {
      final action = BellaAction.fromJson({
        'type': 'sendBroadcast',
        'params': {
          'title': 'Praxis geschlossen',
          'body': 'Am 10.04. bleibt unsere Praxis geschlossen.',
          'priority': 'important',
        },
      });

      expect(action.type, BellaActionType.sendBroadcast);
      expect(action.params['title'], 'Praxis geschlossen');
      expect(action.params['body'], contains('10.04'));
      expect(action.params['priority'], 'important');
    });

    test('parses unknown type as unknown', () {
      final action = BellaAction.fromJson({
        'type': 'nonExistentAction',
        'params': {'foo': 'bar'},
      });

      expect(action.type, BellaActionType.unknown);
    });

    test('handles missing type gracefully', () {
      final action = BellaAction.fromJson({'params': {}});
      expect(action.type, BellaActionType.unknown);
    });

    test('handles missing params gracefully', () {
      final action = BellaAction.fromJson({
        'type': 'createAppointment',
      });
      expect(action.type, BellaActionType.createAppointment);
      expect(action.params, isEmpty);
    });

    test('handles non-map params gracefully', () {
      final action = BellaAction.fromJson({
        'type': 'logVital',
        'params': 'not a map',
      });
      expect(action.type, BellaActionType.logVital);
      expect(action.params, isEmpty);
    });
  });

  group('BellaAction labels and emojis', () {
    test('all action types have labels', () {
      for (final type in BellaActionType.values) {
        final action = BellaAction(type: type, params: const {});
        expect(action.label, isNotEmpty, reason: '$type should have a label');
      }
    });

    test('all action types have emojis', () {
      for (final type in BellaActionType.values) {
        final action = BellaAction(type: type, params: const {});
        expect(action.emoji, isNotEmpty, reason: '$type should have an emoji');
      }
    });

    test('sendBroadcast has correct label and emoji', () {
      final action = BellaAction(
        type: BellaActionType.sendBroadcast,
        params: const {},
      );
      expect(action.label, 'Broadcast senden');
      expect(action.emoji, '📢');
    });
  });

  group('BellaAction previewFields', () {
    test('createAppointment shows title, date, type', () {
      final action = BellaAction(
        type: BellaActionType.createAppointment,
        params: {
          'title': 'Nachkontrolle',
          'date': '2026-04-15',
          'appointmentType': 'followUp',
          'doctorName': 'Dr. Müller',
          'locationName': 'Praxis Mitte',
        },
      );
      final fields = action.previewFields;
      expect(fields['Titel'], 'Nachkontrolle');
      expect(fields['Datum'], '2026-04-15');
      expect(fields['Typ'], 'followUp');
      expect(fields['Arzt'], 'Dr. Müller');
      expect(fields['Ort'], 'Praxis Mitte');
    });

    test('sendBroadcast shows title, body, priority', () {
      final action = BellaAction(
        type: BellaActionType.sendBroadcast,
        params: {
          'title': 'Praxis geschlossen',
          'body': 'Am 10.04. geschlossen',
          'priority': 'important',
        },
      );
      final fields = action.previewFields;
      expect(fields['Titel'], 'Praxis geschlossen');
      expect(fields['Nachricht'], 'Am 10.04. geschlossen');
      expect(fields['Priorität'], 'important');
    });

    test('logVital shows blood pressure and pulse', () {
      final action = BellaAction(
        type: BellaActionType.logVital,
        params: {
          'systolic': 120,
          'diastolic': 80,
          'pulse': 72,
          'temperature': 36.5,
        },
      );
      final fields = action.previewFields;
      expect(fields['Blutdruck'], '120/80');
      expect(fields['Puls'], '72');
      expect(fields['Temperatur'], '36.5°C');
    });
  });
}
