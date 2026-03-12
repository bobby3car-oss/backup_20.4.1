import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/staff_management_service.dart';
import '../domain/staff_permissions.dart';
import 'staff_permissions_sheet.dart';
import '../domain/staff_member.dart';

/// Bottom sheet that lets a doctor create a new staff member account.
class CreateStaffSheet extends StatefulWidget {
  const CreateStaffSheet({super.key});

  @override
  State<CreateStaffSheet> createState() => _CreateStaffSheetState();
}

class _CreateStaffSheetState extends State<CreateStaffSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _service = StaffManagementService();

  var _permissions = StaffPermissions.mfaDefault;
  var _loading = false;
  var _obscurePassword = true;
  var _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _editPermissions() async {
    // Create a temporary member to pass to the permissions sheet.
    final tempMember = StaffMember(
      uid: '',
      displayName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      status: StaffStatus.active,
      permissions: _permissions,
    );
    final updated = await showModalBottomSheet<StaffPermissions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffPermissionsSheet(member: tempMember),
    );
    if (updated != null && mounted) {
      setState(() => _permissions = updated);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _service.createStaffMember(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        permissions: _permissions,
      );
      if (mounted) Navigator.pop(context, true);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        final message = switch (e.code) {
          'already-exists' => 'Diese E-Mail-Adresse ist bereits vergeben.',
          'invalid-argument' => e.message ?? 'Ungültige Eingabe.',
          _ => 'Fehler: ${e.message}',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Handle + Header ──
                  Padding(
                    padding: AppSpacing.screenPadding.copyWith(
                      top: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.grey400,
                            borderRadius: AppRadius.borderRadiusPill,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Mitarbeiter erstellen',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Erstellen Sie einen neuen Account für Ihr Praxisteam.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),

                  // ── Form fields ──
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: AppSpacing.screenPadding,
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Bitte geben Sie einen Namen ein.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'E-Mail',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Bitte geben Sie eine E-Mail ein.';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Bitte geben Sie eine gültige E-Mail ein.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _passwordCtrl,
                          decoration: InputDecoration(
                            labelText: 'Passwort',
                            prefixIcon:
                                const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.length < 8) {
                              return 'Mindestens 8 Zeichen erforderlich.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _confirmCtrl,
                          decoration: InputDecoration(
                            labelText: 'Passwort bestätigen',
                            prefixIcon:
                                const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v != _passwordCtrl.text) {
                              return 'Passwörter stimmen nicht überein.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Permissions preview ──
                        GlassCard(
                          onTap: _editPermissions,
                          child: Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Berechtigungen',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _permissionSummary(),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Submit button ──
                  Padding(
                    padding: AppSpacing.screenPadding.copyWith(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Mitarbeiter erstellen'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  String _permissionSummary() {
    final readCount = StaffPermissions.featureLabels.keys
        .where((f) => _permissions.canRead(f))
        .length;
    final writeCount = StaffPermissions.featureLabels.keys
        .where((f) => _permissions.canWrite(f))
        .length;
    return '$readCount Lesen · $writeCount Schreiben';
  }
}
