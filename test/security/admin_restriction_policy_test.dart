import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Policy tests that verify the admin role restriction is fail-closed:
/// - Client never grants admin when ADMIN_EMAIL is unconfigured.
/// - Server (Cloud Functions) demotes unauthorized admin emails.
/// - Firestore rules prevent users from writing their own role field.
void main() {
  group('Client-side admin restriction (fail-closed)', () {
    late String userProfileSource;
    late String authGateSource;

    setUpAll(() {
      userProfileSource =
          File('lib/auth/user_profile_service.dart').readAsStringSync();
      authGateSource = File('lib/auth/auth_gate.dart').readAsStringSync();
    });

    test(
        'UserProfileService._enforceAdminRestriction rejects admin '
        'when allowedAdminEmail is empty', () {
      // The method must NOT contain a pattern like:
      //   if (allowedAdminEmail.isEmpty) return role;
      // Instead it should demote to patient.
      final failOpenPattern = RegExp(
        r'allowedAdminEmail\.isEmpty\)\s*return\s+role',
      );
      expect(
        failOpenPattern.hasMatch(userProfileSource),
        isFalse,
        reason: '_enforceAdminRestriction must be fail-closed when '
            'ADMIN_EMAIL is not configured',
      );
    });

    test(
        'AuthGate._roleFromClaims rejects admin claims '
        'when allowedAdminEmail is empty', () {
      // Must not return AppUserRole.admin when email is empty.
      final failOpenPattern = RegExp(
        r'allowedAdminEmail\.isEmpty\)\s*return\s+AppUserRole\.admin',
      );
      expect(
        failOpenPattern.hasMatch(authGateSource),
        isFalse,
        reason: '_roleFromClaims must be fail-closed when '
            'ADMIN_EMAIL is not configured',
      );
    });

    test('Firestore rules prevent self-write of role field', () {
      final rules = File('firestore.rules').readAsStringSync();
      // The rules must block the role field from user self-writes.
      expect(
        rules.contains("'role'"),
        isTrue,
        reason: 'Firestore rules must list role as a protected field',
      );
      expect(
        rules.contains('affectedKeys'),
        isTrue,
        reason: 'Firestore rules must use affectedKeys to block role changes',
      );
    });
  });

  group('Server-side admin restriction', () {
    late String functionsSource;

    setUpAll(() {
      functionsSource = File('functions/index.js').readAsStringSync();
    });

    test('enforceAdminRestriction Firestore trigger exists', () {
      expect(
        functionsSource.contains('exports.enforceAdminRestriction'),
        isTrue,
        reason: 'Server must have a Firestore trigger that demotes '
            'unauthorized admin accounts',
      );
    });

    test(
        'enforceAdminRestriction checks ALLOWED_ADMIN_EMAIL '
        'and demotes mismatches', () {
      // The trigger must check email against ALLOWED_ADMIN_EMAIL
      // and set admin custom claim to false.
      expect(
        functionsSource.contains('ADMIN_AUTO_DEMOTED'),
        isTrue,
        reason: 'enforceAdminRestriction must log demotion to audit log',
      );
    });

    test('setUserRole rejects non-allowed emails for admin role', () {
      // setUserRole must check target email against ALLOWED_ADMIN_EMAIL
      // before granting admin.
      final setUserRoleSection = functionsSource.substring(
        functionsSource.indexOf('exports.setUserRole'),
      );
      expect(
        setUserRoleSection.contains('ALLOWED_ADMIN_EMAIL'),
        isTrue,
        reason: 'setUserRole must validate target email before '
            'granting admin role',
      );
    });

    test('refreshAdminClaim demotes unauthorized email', () {
      final section = functionsSource.substring(
        functionsSource.indexOf('exports.refreshAdminClaim'),
      );
      expect(
        section.contains('ADMIN_AUTO_DEMOTED'),
        isTrue,
        reason: 'refreshAdminClaim must log demotion when email '
            'does not match ALLOWED_ADMIN_EMAIL',
      );
    });
  });

  group('AdminPinGate hardening', () {
    late String pinGateSource;

    setUpAll(() {
      pinGateSource =
          File('lib/roles/admin/admin_pin_gate.dart').readAsStringSync();
    });

    test('AdminPinGate has inactivity auto-lock', () {
      expect(
        pinGateSource.contains('_inactivityTimer'),
        isTrue,
        reason: 'AdminPinGate must auto-lock after inactivity',
      );
      expect(
        pinGateSource.contains('_inactivityTimeout'),
        isTrue,
        reason: 'AdminPinGate must define an inactivity timeout',
      );
    });

    test('AdminPinGate locks on app background', () {
      expect(
        pinGateSource.contains('WidgetsBindingObserver'),
        isTrue,
        reason: 'AdminPinGate must observe app lifecycle',
      );
      expect(
        pinGateSource.contains('AppLifecycleState.paused'),
        isTrue,
        reason: 'AdminPinGate must lock when app is paused',
      );
    });

    test('AdminPinGate wraps child in Listener for activity tracking', () {
      expect(
        pinGateSource.contains('Listener'),
        isTrue,
        reason: 'AdminPinGate must track pointer events to '
            'reset the inactivity timer',
      );
    });
  });
}
