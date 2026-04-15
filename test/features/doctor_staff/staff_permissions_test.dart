import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/doctor_staff/domain/staff_permissions.dart';

void main() {
  group('StaffPermissions', () {
    group('featureLabels', () {
      test('does NOT contain templates/Vorlagen', () {
        expect(
          StaffPermissions.featureLabels.containsKey('templates'),
          isFalse,
          reason: 'Templates system was removed — should not appear in UI',
        );
      });

      test('contains aftercare/Nachbehandlung', () {
        expect(
          StaffPermissions.featureLabels.containsKey('aftercare'),
          isTrue,
        );
        expect(
          StaffPermissions.featureLabels['aftercare'],
          'Nachbehandlung',
        );
      });

      test('every label key is handled by operator[]', () {
        const perms = StaffPermissions();
        for (final key in StaffPermissions.featureLabels.keys) {
          // Should return a valid level, not throw
          final level = perms[key];
          expect(
            level,
            isA<StaffAccessLevel>(),
            reason: 'operator[] should handle "$key"',
          );
        }
      });
    });

    group('copyWith aftercare', () {
      test('changes aftercare level', () {
        const perms = StaffPermissions(aftercare: StaffAccessLevel.none);
        final updated = perms.copyWith(aftercare: StaffAccessLevel.readWrite);
        expect(updated.aftercare, StaffAccessLevel.readWrite);
      });

      test('preserves other fields when changing aftercare', () {
        const perms = StaffPermissions(
          appointments: StaffAccessLevel.readWrite,
          pain: StaffAccessLevel.read,
          aftercare: StaffAccessLevel.none,
        );
        final updated = perms.copyWith(aftercare: StaffAccessLevel.read);
        expect(updated.aftercare, StaffAccessLevel.read);
        expect(updated.appointments, StaffAccessLevel.readWrite);
        expect(updated.pain, StaffAccessLevel.read);
      });

      test('null copyWith does not change aftercare', () {
        const perms = StaffPermissions(aftercare: StaffAccessLevel.readWrite);
        final updated = perms.copyWith();
        expect(updated.aftercare, StaffAccessLevel.readWrite);
      });
    });

    group('serialization', () {
      test('round-trip preserves aftercare', () {
        const perms = StaffPermissions(aftercare: StaffAccessLevel.readWrite);
        final map = perms.toMap();
        expect(map['aftercare'], 'readWrite');

        final restored = StaffPermissions.fromMap(map);
        expect(restored.aftercare, StaffAccessLevel.readWrite);
      });

      test('fromMap with missing aftercare defaults to none', () {
        final perms = StaffPermissions.fromMap({'appointments': 'read'});
        expect(perms.aftercare, StaffAccessLevel.none);
      });

      test('toMap still includes templates for backward compat', () {
        // toMap still serializes templates even though it is not in featureLabels
        const perms = StaffPermissions();
        final map = perms.toMap();
        expect(map.containsKey('templates'), isTrue);
      });
    });

    group('setLevel simulation (copyWith by feature name)', () {
      // Simulates exactly what _setLevel in StaffPermissionsSheet does
      StaffPermissions setLevel(
        StaffPermissions p,
        String feature,
        StaffAccessLevel level,
      ) {
        return p.copyWith(
          appointments: feature == 'appointments' ? level : null,
          timeline: feature == 'timeline' ? level : null,
          vitals: feature == 'vitals' ? level : null,
          pain: feature == 'pain' ? level : null,
          wounds: feature == 'wounds' ? level : null,
          documents: feature == 'documents' ? level : null,
          redFlags: feature == 'redFlags' ? level : null,
          invites: feature == 'invites' ? level : null,
          manageStaff: feature == 'manageStaff' ? level : null,
          aftercare: feature == 'aftercare' ? level : null,
        );
      }

      test('aftercare setLevel changes aftercare', () {
        const perms = StaffPermissions();
        final updated = setLevel(perms, 'aftercare', StaffAccessLevel.readWrite);
        expect(updated.aftercare, StaffAccessLevel.readWrite);
        expect(updated.appointments, StaffAccessLevel.read); // unchanged
      });

      test('every featureLabel key can be toggled via setLevel', () {
        for (final key in StaffPermissions.featureLabels.keys) {
          const perms = StaffPermissions();
          final updated = setLevel(perms, key, StaffAccessLevel.readWrite);
          expect(
            updated[key],
            StaffAccessLevel.readWrite,
            reason: 'setLevel("$key") should change that feature',
          );
        }
      });

      test('setLevel does not affect other features', () {
        for (final key in StaffPermissions.featureLabels.keys) {
          const perms = StaffPermissions(
            appointments: StaffAccessLevel.read,
            aftercare: StaffAccessLevel.none,
          );
          final updated = setLevel(perms, key, StaffAccessLevel.readWrite);

          for (final otherKey in StaffPermissions.featureLabels.keys) {
            if (otherKey == key) continue;
            expect(
              updated[otherKey],
              perms[otherKey],
              reason:
                  'Changing "$key" should not affect "$otherKey"',
            );
          }
        }
      });
    });
  });
}
