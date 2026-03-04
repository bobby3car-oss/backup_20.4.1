import 'package:flutter/material.dart';

import '../ui/ui.dart';
import 'alert_screen.dart';
import 'caregiver_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'progress_screen.dart';
import 'symptom_checker_screen.dart';
import 'vital_signs_screen.dart';

class MehrScreen extends StatelessWidget {
  const MehrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Mehr')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Einstellungen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GlassListTile(
              leading: const Icon(
                Icons.monitor_heart_outlined,
                color: AppColors.error,
              ),
              title: const Text('Vitalwerte'),
              subtitle: const Text('Blutdruck, Puls, Temperatur'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const VitalSignsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassListTile(
              leading: const Icon(
                Icons.fact_check_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Symptom‑Check'),
              subtitle: const Text('Beschwerden bewerten & Empfehlung'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SymptomCheckerScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
              title: const Text('Red‑Flag System'),
              subtitle: const Text('Warnungen und Notfallaktionen'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AlertScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassListTile(
              leading: const Icon(
                Icons.people_outline_rounded,
                color: AppColors.success,
              ),
              title: const Text('Angehörige'),
              subtitle: const Text('Begleiter verwalten & einladen'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CaregiverScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassListTile(
              leading: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Profil'),
              subtitle: const Text('Persönliche Daten verwalten'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassListTile(
              leading: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.accent,
              ),
              title: const Text('Benachrichtigungen'),
              subtitle: const Text('Push-Einstellungen'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassListTile(
              leading: const Icon(
                Icons.trending_up_rounded,
                color: AppColors.warning,
              ),
              title: const Text('Fortschritt'),
              subtitle: const Text('Streaks, Abzeichen & Recovery'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProgressScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassListTile(
              leading: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.success,
              ),
              title: const Text('Hilfe & Support'),
              subtitle: const Text('FAQ und Kontakt'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
