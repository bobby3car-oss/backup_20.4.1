import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../ui/ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _mailEnabled = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!
        : 'Nicht verfügbar';
    const buildName = String.fromEnvironment(
      'FLUTTER_BUILD_NAME',
      defaultValue: 'dev',
    );
    const buildNumber = String.fromEnvironment(
      'FLUTTER_BUILD_NUMBER',
      defaultValue: '0',
    );

    return GlassPage(
      title: 'Einstellungen',
      titleEmoji: '⚙️',
      titleColor: AppColors.grey600,
      horizontalPadding: AppSpacing.lg,
      children: [
        _SectionCard(
          title: 'Account',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('E-Mail: $email'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async => AuthService().signOut(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Benachrichtigungen',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Push'),
                subtitle: const Text(
                  'Platzhalter - TODO: echte Settings anbinden',
                ),
                value: _pushEnabled,
                onChanged: (value) => setState(() => _pushEnabled = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('E-Mail'),
                subtitle: const Text(
                  'Platzhalter - TODO: echte Settings anbinden',
                ),
                value: _mailEnabled,
                onChanged: (value) => setState(() => _mailEnabled = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Daten',
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.upload_file_rounded),
                title: const Text('Daten exportieren'),
                subtitle: const Text(
                  'Platzhalter - TODO: Export implementieren',
                ),
                onTap: () => _snack(context, 'Export kommt als nächstes'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_sweep_rounded),
                title: const Text('Daten zurücksetzen'),
                subtitle: const Text(
                  'Platzhalter - TODO: Reset implementieren',
                ),
                onTap: () => _snack(context, 'Reset kommt als nächstes'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Pro',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_rounded),
            title: const Text('Pro Status'),
            subtitle: const Text('Abo, Restore & Pro Key'),
            onTap: () => Navigator.of(context).pushNamed('/pro-status'),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Rechtliches',
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.business_rounded),
                title: const Text('Impressum'),
                onTap: () => Navigator.of(context).pushNamed('/imprint'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_rounded),
                title: const Text('Datenschutz'),
                onTap: () => Navigator.of(context).pushNamed('/privacy'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.gavel_rounded),
                title: const Text('AGB'),
                subtitle: const Text('Platzhalter - TODO: AGB-Screen ergänzen'),
                onTap: () => _snack(context, 'AGB folgt im nächsten Schritt'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Version',
          child: Text('Version $buildName+$buildNumber'),
        ),
      ],
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
