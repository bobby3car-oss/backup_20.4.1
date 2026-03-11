import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../ui/ui.dart';
import '../data/doctor_invite_service.dart';
import '../domain/doctor_invite.dart';

class InviteSheet extends StatefulWidget {
  const InviteSheet({super.key});

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet> {
  final _service = DoctorInviteService();
  DoctorInvite? _invite;
  bool _busy = false;
  String? _error;

  String get _deepLink =>
      'https://operationsbegleiter-860e7.web.app/doctor-invite/${_invite!.code}';

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final invite = await _service.createInvite();
      if (!mounted) return;
      setState(() => _invite = invite);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_invite == null) return;
    await _service.shareInvite(_invite!);
  }

  @override
  void initState() {
    super.initState();
    _create();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
              'Patient einladen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Zeigen Sie den QR-Code vor oder teilen Sie den Code mit Ihrem Patienten.',
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
            else if (_invite != null) ...[
              // ── QR Code ──
              GlassContainer(
                padding: AppSpacing.paddingLg,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      child: QrImageView(
                        data: _deepLink,
                        version: QrVersions.auto,
                        size: 180,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.textPrimary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.textPrimary,
                        ),
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _invite!.code,
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
                      'Gültig für 48 Stunden',
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
                          ClipboardData(text: _invite!.code),
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
