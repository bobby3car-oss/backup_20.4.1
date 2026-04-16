import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sensitive callable exports are pinned to europe-west1', () {
    final source = File('functions/index.js').readAsStringSync();
    const callableNames = <String>[
      'resolveBootstrapSession',
      'createInvite',
      'acceptInvite',
      'createDoctorInvite',
      'acceptDoctorInvite',
      'acceptDoctorPermanentCode',
      'updateLinkPermissions',
      'unlinkPatient',
      'createStaffMember',
      'updateStaffMember',
      'resetStaffPassword',
      'toggleStaffDisabled',
      'updateStaffPermissions',
      'removeStaff',
      'getDoctorPermanentCode',
      'registerDoctor',
      'notifyDoctorAppointment',
      'registerOrganisation',
      'registerOrgDoctor',
      'removeOrgDoctor',
      'updateOrgProfile',
      'getOrgInviteCode',
      'requestJoinOrganisation',
      'resolveOrgJoinRequest',
      'getOrgPatients',
      'getOrgStats',
      'getOrgPatientDetail',
      'debugLinkedPatients',
    ];

    final missing = <String>[];
    for (final callableName in callableNames) {
      final regionPinnedExport = RegExp(
        'exports\\.$callableName\\s*=\\s*onCall\\(\\s*\\{[^)]*region\\s*:\\s*["\\\']europe-west1["\\\']',
        dotAll: true,
      );
      if (!regionPinnedExport.hasMatch(source)) {
        missing.add(callableName);
      }
    }

    expect(
      missing,
      isEmpty,
      reason: missing.isEmpty
          ? null
          : 'Add region: "europe-west1" to callable exports: ${missing.join(', ')}',
    );
  });
}