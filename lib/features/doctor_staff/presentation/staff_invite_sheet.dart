import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/staff_management_service.dart';
import '../domain/staff_permissions.dart';

/// Bottom sheet that generates a staff invite code for the doctor to share.
class StaffInviteSheet extends StatefulWidget {
  const StaffInviteSheet({super.key});

  @override
  State<StaffInviteSheet> createState() => _StaffInviteSheetState();
}

class _StaffInviteSheetState extends State<StaffInviteSheet> {
  final _service = StaffManagementService();
  String? _code;
  bool _busy = false;
  String? _error;
  StaffPermissions _permissions = StaffPermissions.mfaDefault;

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = await _service.createStaffInvite(
        permissions: _permissions,
      );
      if (!mounted) return;
      setState(() => _code = code);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_code == null) return;
    await _service.shareInvite(_code!, 'Ihr Arzt');
  }

  @override
  void initState() {
    super.initState();
    _create();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey400,
                borderRadius: AppRadius.borderRadiusPill,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Mitarbeiter einladen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Teilen Sie den Code mit Ihrem Praxisteam. '
              'Der Code ist 7 Tage gültig.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_busy)
              const CircularProgressIndicator()
            else if (_error != null)
              Column(
                children: [
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: _create,
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              )
            else if (_code != null) ...[
              GlassContainer(
                padding: AppSpacing.paddingLg,
                child: Column(
                  children: [
                    Text(
                      _code!,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Gültig für 7 Tage',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(
                          ClipboardData(text: _code!),
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Code kopiert')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Kopieren'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share),
                      label: const Text('Teilen'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
