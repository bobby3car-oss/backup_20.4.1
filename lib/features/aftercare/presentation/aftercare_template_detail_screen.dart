import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../export/aftercare_pdf_export_service.dart';
import '../data/aftercare_template_service.dart';
import '../domain/aftercare_item.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_phase.dart';
import '../domain/aftercare_template.dart';
import 'aftercare_builder_screen.dart';

/// Read-only detail view for an aftercare template.
///
/// Shows all phases and items grouped by category, with actions to
/// edit, duplicate or delete the template.
class AftercareTemplateDetailScreen extends StatefulWidget {
  const AftercareTemplateDetailScreen({
    super.key,
    required this.template,
    required this.service,
    this.onUpdated,
    this.isAdmin = false,
    this.isOrganization = false,
    this.organizationId,
  });

  final AftercareTemplate template;
  final AftercareTemplateService service;
  final VoidCallback? onUpdated;
  final bool isAdmin;
  final bool isOrganization;
  final String? organizationId;

  @override
  State<AftercareTemplateDetailScreen> createState() =>
      _AftercareTemplateDetailScreenState();
}

class _AftercareTemplateDetailScreenState
    extends State<AftercareTemplateDetailScreen> {
  bool _isAdopting = false;

  bool get _canEdit {
    // Admin can edit system templates in admin mode.
    if (widget.isAdmin &&
        widget.template.templateType == AftercareTemplateType.system) {
      return true;
    }
    if (widget.template.templateType == AftercareTemplateType.system) {
      return false;
    }
    // Organization templates can be edited by any org member.
    if (widget.template.templateType == AftercareTemplateType.organization) {
      return true;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && widget.template.createdBy == uid;
  }

  /// Whether this user can adopt (clone) system templates into their scope.
  bool get _canAdopt {
    if (widget.template.templateType != AftercareTemplateType.system) {
      return false;
    }
    // Admin mode shows edit controls, not adopt.
    if (widget.isAdmin) return false;
    return true;
  }

  void _edit(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => AftercareBuilderScreen(
          service: widget.service,
          organizationId: widget.template.organizationId,
          existingTemplate: widget.template,
        ),
      ),
    );
  }

  void _duplicate(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => AftercareBuilderScreen(
          service: widget.service,
          organizationId: widget.template.organizationId,
          existingTemplate: widget.template,
          isDuplicate: true,
        ),
      ),
    );
  }

  /// 1-click adopt: clones a system template into the user's scope.
  Future<void> _adopt(BuildContext context) async {
    if (_isAdopting) return;
    setState(() => _isAdopting = true);
    try {
      final targetType = widget.isOrganization
          ? AftercareTemplateType.organization
          : AftercareTemplateType.doctor;
      await widget.service.adoptTemplate(
        widget.template,
        targetType: targetType,
        organizationId: widget.organizationId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vorlage übernommen'),
          ),
        );
        widget.onUpdated?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdopting = false);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Vorlage löschen?'),
        content: Text(
          '„${widget.template.title}" wird unwiderruflich gelöscht.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await widget.service.deleteTemplate(
      templateId: widget.template.id,
      templateType: widget.template.templateType,
    );
    widget.onUpdated?.call();
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _exportBlankPdf(BuildContext context) async {
    final exporter = AftercarePdfExportService();
    try {
      await exporter.exportTemplateBlankPdf(widget.template);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF-Export fehlgeschlagen: ${userFacingError(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    return GlassPage(
      title: template.title,
      titleIcon: Icons.medical_information_rounded,
      trailing: _canEdit
          ? PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded,
                  color: AppColors.primary),
              onSelected: (v) {
                switch (v) {
                  case 'export':
                    _exportBlankPdf(context);
                    break;
                  case 'edit':
                    _edit(context);
                    break;
                  case 'duplicate':
                    _duplicate(context);
                    break;
                  case 'delete':
                    _delete(context);
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'export', child: Text('Blanko-PDF exportieren')),
                PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                PopupMenuItem(value: 'duplicate', child: Text('Duplizieren')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Löschen',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.primary),
                  tooltip: 'Blanko-PDF exportieren',
                  onPressed: () => _exportBlankPdf(context),
                ),
                if (_canAdopt)
                  _isAdopting
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.primary),
                          tooltip: 'Vorlage übernehmen',
                          onPressed: () => _adopt(context),
                        ),
              ],
            ),
      scrollableBody: (headerHeight) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            physics: adaptiveScrollPhysics,
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: headerHeight + AppSpacing.md,
              bottom: 120,
            ),
        children: [
          // ── Meta info ─────────────────────────────────────────
          FadeSlideIn(
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template type badge
                  _DetailTypeBadge(type: template.templateType),
                  const SizedBox(height: AppSpacing.sm),
                  if (template.description.isNotEmpty) ...[
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _MetaChip(
                        icon: Icons.medical_services_outlined,
                        label: template.surgeryType.isNotEmpty
                            ? template.surgeryType
                            : 'Kein OP-Typ',
                      ),
                      _MetaChip(
                        icon: Icons.location_on_outlined,
                        label: template.bodyRegion.isNotEmpty
                            ? template.bodyRegion
                            : 'Keine Region',
                      ),
                      _MetaChip(
                        icon: Icons.layers_outlined,
                        label: '${template.phases.length} Phasen',
                      ),
                      _MetaChip(
                        icon: Icons.tag_rounded,
                        label: 'v${template.version}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Phases ────────────────────────────────────────────
          for (var i = 0; i < template.phases.length; i++) ...[
            FadeSlideIn(
              delay: Duration(milliseconds: 80 + i * 50),
              child: _PhaseDetailCard(
                phase: template.phases[i],
                index: i,
              ),
            ),
          ],

          // ── System template hint ──────────────────────────────
          if (template.templateType == AftercareTemplateType.system &&
              !widget.isAdmin)
            FadeSlideIn(
              delay: Duration(
                  milliseconds: 80 + template.phases.length * 50),
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.grey500),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'System-Vorlagen können nicht bearbeitet werden. '
                          'Erstellen Sie eine Kopie, um sie anzupassen.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
      ),
    );
  }
}

class _PhaseDetailCard extends StatelessWidget {
  const _PhaseDetailCard({required this.phase, required this.index});

  final AftercarePhase phase;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Group items by category for cleaner display.
    final grouped = <AftercareItemCategory, List<AftercareItem>>{};
    for (final item in phase.items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final dayLabel = phase.endDayOffset != null
        ? 'Tag ${phase.startDayOffset}–${phase.endDayOffset}'
        : 'Ab Tag ${phase.startDayOffset}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase header
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.title,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        dayLabel,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey500,
                                  fontSize: 11,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (grouped.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.glassBorder),
              const SizedBox(height: AppSpacing.sm),

              for (final entry in grouped.entries)
                _CategoryGroup(
                  category: entry.key,
                  items: entry.value,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({required this.category, required this.items});

  final AftercareItemCategory category;
  final List<AftercareItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 14, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                category.displayName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                bottom: 2,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.grey400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.startDayOffset != null)
                    Text(
                      _dayLabel(item),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                            fontSize: 10,
                          ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _dayLabel(AftercareItem item) {
    final e = item.endDayOffset;
    if (e == null) return 'Tag ${item.startDayOffset}';
    return 'Tag ${item.startDayOffset}–$e';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetailTypeBadge extends StatelessWidget {
  const _DetailTypeBadge({required this.type});

  final AftercareTemplateType type;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (type) {
      AftercareTemplateType.doctor => (
          'Eigene Vorlage',
          AppColors.primary,
          Icons.person_rounded,
        ),
      AftercareTemplateType.organization => (
          'Organisations-Vorlage',
          AppColors.accent,
          Icons.business_rounded,
        ),
      AftercareTemplateType.system => (
          'System-Vorlage',
          AppColors.success,
          Icons.public_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
