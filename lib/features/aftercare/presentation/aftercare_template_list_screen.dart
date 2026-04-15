import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/aftercare_template_service.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_template.dart';
import 'aftercare_builder_screen.dart';
import 'aftercare_template_detail_screen.dart';

/// Lists all aftercare templates visible to the current user.
///
/// **Admin mode** (`isAdmin`): single list of system templates with full CRUD.
///
/// **Org / Doctor mode**: tab bar separating own templates from system
/// templates. System templates show adopt / duplicate actions inline.
class AftercareTemplateListScreen extends StatefulWidget {
  const AftercareTemplateListScreen({
    super.key,
    this.doctorUid,
    this.organizationId,
    this.isAdmin = false,
    this.isOrganization = false,
  });

  final String? doctorUid;
  final String? organizationId;
  final bool isAdmin;
  final bool isOrganization;

  @override
  State<AftercareTemplateListScreen> createState() =>
      _AftercareTemplateListScreenState();
}

class _AftercareTemplateListScreenState
    extends State<AftercareTemplateListScreen>
    with SingleTickerProviderStateMixin {
  late final AftercareTemplateService _service;
  late final TabController _tabCtrl;
  String _query = '';

  /// Number of tabs: admin = 1, org = 2 (Org + System),
  /// doctor = 2 (Eigene + System) or 3 (Eigene + Org + System).
  int get _tabCount {
    if (widget.isAdmin) return 1;
    if (widget.isOrganization) return 2;
    return widget.organizationId != null ? 3 : 2;
  }

  @override
  void initState() {
    super.initState();
    _service = AftercareTemplateService(
      overrideDoctorUid: widget.doctorUid,
    );
    _tabCtrl = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openDetail(AftercareTemplate template) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => AftercareTemplateDetailScreen(
          template: template,
          service: _service,
          onUpdated: () => setState(() {}),
          isAdmin: widget.isAdmin,
          isOrganization: widget.isOrganization,
          organizationId: widget.organizationId,
        ),
      ),
    );
  }

  void _createNew() {
    final defaultType = widget.isAdmin
        ? AftercareTemplateType.system
        : widget.isOrganization
            ? AftercareTemplateType.organization
            : AftercareTemplateType.doctor;
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => AftercareBuilderScreen(
          service: _service,
          organizationId: widget.organizationId,
          defaultTemplateType: defaultType,
        ),
      ),
    );
  }

  // ── Tab definitions ─────────────────────────────────────────────────

  List<Tab> _buildTabs() {
    if (widget.isAdmin) {
      return const [Tab(text: 'System-Vorlagen')];
    }
    if (widget.isOrganization) {
      return const [
        Tab(text: 'Organisations-Vorlagen'),
        Tab(text: 'System-Vorlagen'),
      ];
    }
    // Doctor mode
    if (widget.organizationId != null) {
      return const [
        Tab(text: 'Meine Vorlagen'),
        Tab(text: 'Organisations-Vorlagen'),
        Tab(text: 'System-Vorlagen'),
      ];
    }
    return const [
      Tab(text: 'Meine Vorlagen'),
      Tab(text: 'System-Vorlagen'),
    ];
  }

  /// The stream + filter for each tab index.
  Stream<List<AftercareTemplate>> _streamForTab(int index) {
    if (widget.isAdmin) {
      return _service.getSystemTemplates();
    }
    if (widget.isOrganization) {
      return index == 0
          ? _service
              .getTemplatesForOrganization(
                organizationId: widget.organizationId!,
              )
              .map((list) => list
                  .where((t) =>
                      t.templateType == AftercareTemplateType.organization)
                  .toList())
          : _service.getSystemTemplates();
    }
    // Doctor mode
    if (widget.organizationId != null) {
      return switch (index) {
        0 => _service
            .getTemplatesForUser(organizationId: widget.organizationId)
            .map((list) => list
                .where(
                    (t) => t.templateType == AftercareTemplateType.doctor)
                .toList()),
        1 => _service
            .getTemplatesForUser(organizationId: widget.organizationId)
            .map((list) => list
                .where((t) =>
                    t.templateType == AftercareTemplateType.organization)
                .toList()),
        _ => _service.getSystemTemplates(),
      };
    }
    return index == 0
        ? _service
            .getTemplatesForUser()
            .map((list) => list
                .where(
                    (t) => t.templateType == AftercareTemplateType.doctor)
                .toList())
        : _service.getSystemTemplates();
  }

  /// Whether the FAB (create new) should show for a given tab.
  bool _showFabForTab(int index) {
    if (widget.isAdmin) return true;
    if (widget.isOrganization) return index == 0;
    // Doctor: only "Meine Vorlagen"
    return index == 0;
  }

  /// Whether a tab shows system templates (adopt/duplicate UI).
  bool _isSystemTab(int index) {
    if (widget.isAdmin) return true; // admin edits, not adopts
    if (widget.isOrganization) return index == 1;
    if (widget.organizationId != null) return index == 2;
    return index == 1;
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.isAdmin
        ? 'Nachbehandlungspläne'
        : widget.isOrganization
            ? 'Nachbehandlungsvorlagen'
            : 'Nachbehandlung';

    return GlassPage(
      title: pageTitle,
      titleIcon: Icons.medical_information_rounded,
      floatingActionButton: ListenableBuilder(
        listenable: _tabCtrl,
        builder: (context, _) {
          if (!_showFabForTab(_tabCtrl.index)) return const SizedBox.shrink();
          return GlassButton(
            onPressed: _createNew,
            label: 'Neue Vorlage',
            icon: Icons.add_rounded,
          );
        },
      ),
      scrollableBody: (headerHeight) => Column(
        children: [
          SizedBox(height: headerHeight),
          // ── Tab bar ──────────────────────────────────────────
          if (_tabCount > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.glassFillLight,
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TabBar(
                controller: _tabCtrl,
                isScrollable: _tabCount > 2,
                tabAlignment:
                    _tabCount > 2 ? TabAlignment.start : TabAlignment.fill,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle:
                    Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                unselectedLabelStyle:
                    Theme.of(context).textTheme.labelMedium,
                dividerHeight: 0,
                tabs: _buildTabs(),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          // ── Tab content ──────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                for (var i = 0; i < _tabCount; i++)
                  _TemplateTabBody(
                    key: ValueKey('tab_$i'),
                    stream: _streamForTab(i),
                    query: _query,
                    onQueryChanged: (v) => setState(() => _query = v),
                    onTap: _openDetail,
                    isSystemTab: _isSystemTab(i) && !widget.isAdmin,
                    service: _service,
                    isOrganization: widget.isOrganization,
                    organizationId: widget.organizationId,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab body — shows a single stream of templates
// ═══════════════════════════════════════════════════════════════════════════

class _TemplateTabBody extends StatefulWidget {
  const _TemplateTabBody({
    super.key,
    required this.stream,
    required this.query,
    required this.onQueryChanged,
    required this.onTap,
    required this.isSystemTab,
    required this.service,
    required this.isOrganization,
    this.organizationId,
  });

  final Stream<List<AftercareTemplate>> stream;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<AftercareTemplate> onTap;
  final bool isSystemTab;
  final AftercareTemplateService service;
  final bool isOrganization;
  final String? organizationId;

  @override
  State<_TemplateTabBody> createState() => _TemplateTabBodyState();
}

class _TemplateTabBodyState extends State<_TemplateTabBody> {
  String? _selectedRegion;

  List<AftercareTemplate> _filter(List<AftercareTemplate> all) {
    var result = all;
    if (_selectedRegion != null) {
      result = result.where((t) => t.bodyRegion == _selectedRegion).toList();
    }
    if (widget.query.isNotEmpty) {
      final q = widget.query.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.surgeryType.toLowerCase().contains(q) ||
              t.bodyRegion.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  /// Collect distinct body regions from the full template list.
  List<String> _bodyRegions(List<AftercareTemplate> all) {
    final regions = <String>{};
    for (final t in all) {
      if (t.bodyRegion.isNotEmpty) regions.add(t.bodyRegion);
    }
    final sorted = regions.toList()..sort();
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AftercareTemplate>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(
            '[AftercareTemplateList] Stream error: ${snapshot.error}',
          );
          return _ErrorBody(headerHeight: 0, error: snapshot.error);
        }

        final templates = snapshot.data;
        if (templates == null) {
          return const _LoadingBody(headerHeight: 0);
        }

        final regions = _bodyRegions(templates);
        final filtered = _filter(templates);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              physics: adaptiveScrollPhysics,
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: 120,
              ),
              children: [
                // ── Search ──────────────────────────────────
                FadeSlideIn(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GlassTextField(
                      hint: 'Vorlage suchen …',
                      prefixIcon: Icons.search_rounded,
                      onChanged: widget.onQueryChanged,
                    ),
                  ),
                ),

                // ── Body-region filter chips ────────────────
                if (regions.length > 1)
                  FadeSlideIn(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: adaptiveScrollPhysics,
                          children: [
                            _RegionChip(
                              label: 'Alle',
                              isSelected: _selectedRegion == null,
                              onTap: () =>
                                  setState(() => _selectedRegion = null),
                            ),
                            for (final r in regions)
                              _RegionChip(
                                label: r,
                                isSelected: _selectedRegion == r,
                                onTap: () => setState(() {
                                  _selectedRegion =
                                      _selectedRegion == r ? null : r;
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (widget.isSystemTab && filtered.isNotEmpty)
                  FadeSlideIn(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: AppColors.grey500),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'System-Vorlagen können direkt übernommen '
                                'oder als Kopie bearbeitet werden.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (filtered.isEmpty)
                  _EmptyState(
                    message: _selectedRegion != null
                        ? 'Keine Vorlagen für „$_selectedRegion" gefunden.'
                        : widget.isSystemTab
                            ? 'Noch keine System-Vorlagen vorhanden.'
                            : null,
                  )
                else
                  for (var i = 0; i < filtered.length; i++)
                    FadeSlideIn(
                      delay: Duration(milliseconds: 60 + i * 40),
                      child: _TemplateCard(
                        template: filtered[i],
                        onTap: () => widget.onTap(filtered[i]),
                        showAdoptActions: widget.isSystemTab,
                        service: widget.service,
                        isOrganization: widget.isOrganization,
                        organizationId: widget.organizationId,
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private widgets
// ═══════════════════════════════════════════════════════════════════════════

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({
    required this.template,
    required this.onTap,
    this.showAdoptActions = false,
    this.service,
    this.isOrganization = false,
    this.organizationId,
  });

  final AftercareTemplate template;
  final VoidCallback onTap;
  final bool showAdoptActions;
  final AftercareTemplateService? service;
  final bool isOrganization;
  final String? organizationId;

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _busy = false;

  Future<void> _adopt() async {
    if (_busy || widget.service == null) return;
    setState(() => _busy = true);
    try {
      final targetType = widget.isOrganization
          ? AftercareTemplateType.organization
          : AftercareTemplateType.doctor;
      await widget.service!.adoptTemplate(
        widget.template,
        targetType: targetType,
        organizationId: widget.organizationId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vorlage übernommen')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final phaseCount = template.phases.length;
    final itemCount =
        template.phases.fold<int>(0, (sum, p) => sum + p.items.length);

    // Collect unique categories from items
    final categories = <AftercareItemCategory>{};
    for (final phase in template.phases) {
      for (final item in phase.items) {
        categories.add(item.category);
      }
    }

    return GlassCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  template.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _TypeBadge(type: template.templateType),
            ],
          ),

          if (template.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              template.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Metadata chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (template.surgeryType.isNotEmpty)
                _InfoChip(
                  icon: Icons.medical_services_outlined,
                  label: template.surgeryType,
                ),
              if (template.bodyRegion.isNotEmpty)
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: template.bodyRegion,
                ),
              _InfoChip(
                icon: Icons.layers_outlined,
                label: '$phaseCount Phasen',
              ),
              _InfoChip(
                icon: Icons.checklist_rounded,
                label: '$itemCount Punkte',
              ),
            ],
          ),

          // Category icons
          if (categories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final cat in categories.take(6))
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Icon(
                      cat.icon,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                  ),
                if (categories.length > 6)
                  Text(
                    '+${categories.length - 6}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                          fontSize: 11,
                        ),
                  ),
              ],
            ),
          ],

          // ── Adopt / Duplicate actions (system tab only) ────
          if (widget.showAdoptActions) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, color: AppColors.glassBorder),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Übernehmen',
                    busy: _busy,
                    onTap: _adopt,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionChip(
                    icon: Icons.copy_rounded,
                    label: 'Kopie erstellen',
                    onTap: widget.onTap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

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
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassFillLight,
      borderRadius: AppRadius.borderRadiusSm,
      child: InkWell(
        borderRadius:
            const BorderRadius.all(Radius.circular(AppRadius.sm)),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.grey500),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: PressableScale(
        onTap: () {
          Haptic.selection();
          onTap();
        },
        child: AnimatedContainer(
          duration: MotionDuration.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.glassFillLight,
            borderRadius: AppRadius.borderRadiusPill,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: Column(
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 48,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Noch keine Vorlagen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message ?? 'Erstellen Sie Ihre erste Nachbehandlungsvorlage.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.headerHeight});
  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.headerHeight, this.error});
  final double headerHeight;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: headerHeight + AppSpacing.huge,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vorlagen konnten nicht geladen werden.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
