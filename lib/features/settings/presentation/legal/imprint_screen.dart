import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

class ImprintScreen extends StatelessWidget {
  const ImprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Impressum',
      titleEmoji: '📄',
      titleColor: AppColors.textSecondary,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'TODO: Hier den vollständigen Impressumstext einfügen.\n\n'
            'Platzhalter:\n'
            '- Anbieter: Operationsbegleiter GmbH\n'
            '- Anschrift: Musterstraße 1, 12345 Musterstadt\n'
            '- Kontakt: kontakt@example.com\n'
            '- Vertretungsberechtigte Person: Max Mustermann\n'
            '- Registereintrag/USt-ID: TODO ergänzen',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
