import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../domain/staff_member.dart';
import '../domain/staff_permissions.dart';

/// Bottom sheet that allows a doctor to edit per-feature access levels
/// for a staff member.
class StaffPermissionsSheet extends StatefulWidget {
  const StaffPermissionsSheet({
    super.key,
    required this.member,
    this.isStaff = false,
  });

  final StaffMember member;

  /// When true, the caller is a staff manager — manageStaff toggle is hidden.
  final bool isStaff;

  @override
  State<StaffPermissionsSheet> createState() => _StaffPermissionsSheetState();
}

class _StaffPermissionsSheetState extends State<StaffPermissionsSheet> {
  late StaffPermissions _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = widget.member.permissions;
  }

  void _setLevel(String feature, StaffAccessLevel level) {
    setState(() {
      _permissions = _permissions.copyWith(
        appointments: feature == 'appointments' ? level : null,
        timeline: feature == 'timeline' ? level : null,
        vitals: feature == 'vitals' ? level : null,
        pain: feature == 'pain' ? level : null,
        wounds: feature == 'wounds' ? level : null,
        documents: feature == 'documents' ? level : null,
        redFlags: feature == 'redFlags' ? level : null,
        templates: feature == 'templates' ? level : null,
        invites: feature == 'invites' ? level : null,
        manageStaff: feature == 'manageStaff' ? level : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
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
                        'Berechtigungen',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.member.displayName.isNotEmpty
                            ? widget.member.displayName
                            : widget.member.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),

                // ── Feature toggles ──
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: AppSpacing.screenPadding,
                    children: StaffPermissions.featureLabels.entries
                        .where((entry) {
                      // Staff managers cannot see/change the manageStaff toggle.
                      if (widget.isStaff && entry.key == 'manageStaff') {
                        return false;
                      }
                      return true;
                    }).map((entry) {
                      final feature = entry.key;
                      final label = entry.value;
                      final current = _permissions[feature];

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              SegmentedButton<StaffAccessLevel>(
                                segments: StaffAccessLevel.values
                                    .map(
                                      (level) => ButtonSegment(
                                        value: level,
                                        label: Text(
                                          StaffPermissions
                                                  .accessLevelLabels[level] ??
                                              level.name,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                selected: {current},
                                onSelectionChanged: (selected) {
                                  _setLevel(feature, selected.first);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
                      onPressed: () => Navigator.pop(context, _permissions),
                      child: const Text('Speichern'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
