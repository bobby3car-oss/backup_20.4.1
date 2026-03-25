import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../ui/ui.dart';

/// Full-screen dialog shown after a caregiver invite was created successfully.
/// Displays the invite code, a scannable QR code, and sharing options.
class InviteSuccessDialog extends StatelessWidget {
  const InviteSuccessDialog({
    super.key,
    required this.code,
    required this.expiresAt,
    required this.roleLabel,
  });

  final String code;
  final DateTime expiresAt;
  final String roleLabel;

  String get _deepLink => 'https://operationsbegleiter-860e7.web.app/invite/$code';

  @override
  Widget build(BuildContext context) {
    final remaining = expiresAt.difference(DateTime.now());
    final hoursLeft = remaining.inHours.clamp(0, 999);

    return GlassPage(
      title: 'Einladung erstellt',
      titleIcon: Icons.check_circle_rounded,
      titleColor: AppColors.success,
      trailing: PressableScale(
        onTap: () => Navigator.of(context).pop(),
        scaleFactor: 0.90,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.65),
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.80),
              width: 0.5,
            ),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Success icon ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusXl,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 36,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Einladung bereit!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Teile den QR-Code oder den Link mit deinem Angehörigen ($roleLabel).',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // ── QR code ──
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: AppRadius.borderRadiusXl,
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
                    Text(
                      'QR-Code scannen',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Code display ──
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.lg),
                borderRadius: AppRadius.borderRadiusLg,
                child: Column(
                  children: [
                    Text(
                      'Einladungscode',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              letterSpacing: 2.0,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code kopiert'),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: AppRadius.borderRadiusSm,
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.10),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Gültig für $hoursLeft Stunden',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Share buttons ──
              GlassButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'Tritt meinem Operationsbegleiter bei!\n\n'
                          'Öffne diesen Link: $_deepLink\n\n'
                          'Oder gib diesen Code ein: $code',
                    ),
                  );
                },
                label: 'Einladung teilen',
                icon: Icons.share_rounded,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.md),
              GlassButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _deepLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link kopiert')),
                  );
                },
                label: 'Link kopieren',
                icon: Icons.link_rounded,
                variant: GlassButtonVariant.secondary,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.md),
              GlassButton(
                onPressed: () => Navigator.of(context).pop(),
                label: 'Fertig',
                variant: GlassButtonVariant.ghost,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
    );
  }
}
