import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/staff_management_service.dart';
import '../domain/staff_member.dart';
import '../../../l10n/app_localizations.dart';

/// Bottom sheet that lets a doctor edit a staff member's name and email.
class EditStaffSheet extends StatefulWidget {
  const EditStaffSheet({super.key, required this.member});

  final StaffMember member;

  @override
  State<EditStaffSheet> createState() => _EditStaffSheetState();
}

class _EditStaffSheetState extends State<EditStaffSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _service = StaffManagementService();
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.member.displayName);
    _emailCtrl = TextEditingController(text: widget.member.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();

    // Only send changed fields.
    final nameChanged = newName != widget.member.displayName;
    final emailChanged = newEmail != widget.member.email;
    if (!nameChanged && !emailChanged) {
      Navigator.pop(context);
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.updateStaffMember(
        staffUid: widget.member.uid,
        name: nameChanged ? newName : null,
        email: emailChanged ? newEmail : null,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.8,
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
                          'Mitarbeiter bearbeiten',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),

                  // ── Form fields ──
                  Expanded(
                    child: ListView(
                      controller: scrollController,
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
                          decoration: InputDecoration(
                            labelText: l.fieldEmail,
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Bitte geben Sie eine E-Mail ein.';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return l.bitteGebenSieEineGueltigeEMailEin;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Save button ──
                  Padding(
                    padding: AppSpacing.screenPadding.copyWith(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.lg,
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
                            : Text(l.save),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
