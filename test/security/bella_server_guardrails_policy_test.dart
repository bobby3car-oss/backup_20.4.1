import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bella consent and context handling are server-guarded', () {
    final consentService = File(
      'lib/features/assistant/data/bella_consent_service.dart',
    ).readAsStringSync();
    final assistantService = File(
      'lib/features/assistant/domain/assistant_service.dart',
    ).readAsStringSync();
    final overlayController = File(
      'lib/features/assistant/presentation/bella_overlay_controller.dart',
    ).readAsStringSync();
    final briefingScreen = File(
      'lib/features/assistant/presentation/bella_briefing_screen.dart',
    ).readAsStringSync();
    final authService = File('lib/auth/auth_service.dart').readAsStringSync();
    final functionsSource = File('functions/index.js').readAsStringSync();

    expect(consentService, contains('FirestorePaths.userPrivateProfileDoc'));
    expect(consentService, contains('bellaConsent'));

    expect(
      overlayController,
      contains('BellaConsentService.instance.hasConsented'),
    );
    expect(assistantService, isNot(contains("bodyMap['context']")));

    expect(
      briefingScreen,
      isNot(contains('askassistantstream-unsezhozna-uc.a.run.app')),
    );
    expect(briefingScreen, isNot(contains('PatientContext.gather(')));

    expect(
      authService,
      isNot(contains("prefs.getBool('bella_ai_consent_given')")),
    );
    expect(
      authService,
      isNot(contains("prefs.setBool('bella_ai_consent_given'")),
    );

    expect(functionsSource, contains('assertBellaConsentGranted'));
    expect(functionsSource, isNot(contains('data.context')));
    expect(
      functionsSource,
      matches(
        RegExp(
          'exports\\.askAssistant\\s*=\\s*onCall\\(\\s*\\{[^)]*region\\s*:\\s*["\\\']europe-west1["\\\']',
          dotAll: true,
        ),
      ),
    );
    expect(
      functionsSource,
      matches(
        RegExp(
          'exports\\.askAssistantStream\\s*=\\s*onRequest\\(\\s*\\{[^)]*region\\s*:\\s*["\\\']europe-west1["\\\']',
          dotAll: true,
        ),
      ),
    );
  });
}