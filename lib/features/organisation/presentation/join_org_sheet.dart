import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/org_membership_service.dart';
import '../../../l10n/app_localizations.dart';

/// Bottom sheet for a doctor to join an organisation using an invite code.
class JoinOrgSheet extends StatefulWidget {
  const JoinOrgSheet({super.key});

  @override
  State<JoinOrgSheet> createState() => _JoinOrgSheetState();
}

class _JoinOrgSheetState extends State<JoinOrgSheet> {
  final _codeCtrl = TextEditingController();
  final _service = OrgMembershipService();
  var _loading = false;
  var _success = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Bitte Einladungscode eingeben');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _service.submitJoinRequest(code);
      if (mounted) setState(() => _success = true);
    } catch (e) {
      if (mounted) setState(() => _error = userFacingError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return GlassContainer(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ListView(
                controller: scrollController,
                children: [
                  // ── Handle ──────────────────────────────
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    l.orgJoin,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Geben Sie den Einladungscode Ihrer Organisation ein. '
                    'Nach dem Absenden muss die Organisation Ihre Anfrage bestätigen.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  if (_success) ...[
                    // ── Success state ────────────────────────
                    Icon(Icons.check_circle_rounded,
                        size: 56, color: AppColors.success),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Anfrage gesendet!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Die Organisation wird Ihre Anfrage prüfen. '
                      'Sie werden benachrichtigt, sobald eine Entscheidung getroffen wurde.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    GlassButton(
                      onPressed: () => Navigator.pop(context),
                      label: l.close,
                      expand: true,
                    ),
                  ] else ...[
                    // ── Code input ──────────────────────────
                    TextField(
                      controller: _codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l.einladungscode,
                        prefixIcon: const Icon(Icons.vpn_key_rounded),
                        hintText: l.zBA1B2C3D4,
                        errorText: _error,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    GlassButton(
                      onPressed: _loading ? null : _submit,
                      label: _loading
                          ? l.orgRegSubmitting
                          : 'Anfrage absenden',
                      icon: Icons.send_rounded,
                      expand: true,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
