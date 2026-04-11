import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../ui/ui.dart';
import '../data/doctor_invite_service.dart';
import '../../../l10n/app_localizations.dart';

class InviteSheet extends StatefulWidget {
  const InviteSheet({super.key});

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet> {
  final _service = DoctorInviteService();
  String? _code;
  bool _busy = false;
  String? _error;

  String get _deepLink => _service.buildPermanentDeepLink(_code!);

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = await _service.getPermanentCode();
      if (!mounted) return;
      setState(() => _code = code);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = userFacingError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_code == null) return;
    try {
      await _service.sharePermanentCode(_code!);
    } catch (e) {
      debugPrint('[InviteSheet] share failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              l.patientInvite,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Zeigen Sie den QR-Code vor, teilen Sie den Einladungscode '
              'oder senden Sie den Link an Ihren Patienten. '
              'Beides ist dauerhaft gültig.',
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
                    onPressed: _load,
                    child: Text(l.retry),
                  ),
                ],
              )
            else if (_code != null) ...[
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
                        size: 200,
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
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'Dauerhaft gültig',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Diesen Code können Sie ausdrucken und\n'
                      'wiederholt verwenden.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Einladungscode ──
              GlassContainer(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Einladungscode',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SelectableText(
                            _code!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(
                          ClipboardData(text: _code!),
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l.inviteCodeCopied),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      tooltip: l.codeCopy,
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
                          ClipboardData(text: _deepLink),
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(l.linkCopied)),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(l.copy),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share),
                      label: Text(l.share),
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
