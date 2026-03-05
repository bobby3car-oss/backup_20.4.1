import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Datenschutz',
      titleEmoji: '🔒',
      titleColor: AppColors.textSecondary,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'TODO: Hier die vollständige Datenschutzerklärung einfügen.\n\n'
            'Platzhalter-Inhalte:\n'
            '- Verarbeitete Datenkategorien\n'
            '- Zweck und Rechtsgrundlagen\n'
            '- Speicherdauer\n'
            '- Weitergabe an Dritte\n'
            '- Rechte der betroffenen Personen\n'
            '- Kontakt Datenschutzbeauftragte/r (falls vorhanden)',
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
