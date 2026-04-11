import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../auth/auth_service.dart';
import '../../../main.dart';
import '../../../roles/admin/widgets/csv_export.dart';
import '../../../screens/help_screen.dart';
import '../../pro/domain/org_entitlement.dart';
import '../../pro/presentation/org_paywall_screen.dart';
import '../data/organisation_service.dart';
import '../domain/organisation.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import 'org_billing_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Editing section enum
// ─────────────────────────────────────────────────────────────────────────────

enum _Section { general, contact, openingHours }

/// Profile tab for the organisation dashboard.
class OrgProfileTab extends StatefulWidget {
  const OrgProfileTab({super.key});

  @override
  State<OrgProfileTab> createState() => _OrgProfileTabState();
}

class _OrgProfileTabState extends State<OrgProfileTab> {
  final _service = OrganisationService();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<Organisation?>(
      stream: _service.watchOrganisation(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final org = snap.data;
        if (org == null) {
          return GlassPage(
            title: l.sectionProfile,
            titleIcon: Icons.business_rounded,
            titleColor: AppColors.primary,
            showBackButton: false,
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: AppRadius.borderRadiusLg,
                child: Text(
                  l.orgProfileNotFound,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              FadeSlideIn(
                child: GlassButton(
                  onPressed: () => AuthService().signOut(),
                  icon: Icons.logout_rounded,
                  label: l.logout,
                  variant: GlassButtonVariant.ghost,
                  expand: true,
                ),
              ),
            ],
          );
        }

        return _OrgProfileContent(org: org);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile content (stateful for editing)
// ─────────────────────────────────────────────────────────────────────────────

class _OrgProfileContent extends StatefulWidget {
  const _OrgProfileContent({required this.org});

  final Organisation org;

  @override
  State<_OrgProfileContent> createState() => _OrgProfileContentState();
}

class _OrgProfileContentState extends State<_OrgProfileContent> {
  final _service = OrganisationService();

  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _websiteCtrl;
  late String _orgType;
  late Map<String, _OHEntry> _openingHours;

  _Section? _editing;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _syncFromOrg(widget.org);
  }

  @override
  void didUpdateWidget(covariant _OrgProfileContent old) {
    super.didUpdateWidget(old);
    if (old.org.uid != widget.org.uid) _syncFromOrg(widget.org);
  }

  void _syncFromOrg(Organisation org) {
    _nameCtrl = TextEditingController(text: org.name);
    _addressCtrl = TextEditingController(text: org.address);
    _contactCtrl = TextEditingController(text: org.contactPerson);
    _phoneCtrl = TextEditingController(text: org.phone ?? '');
    _websiteCtrl = TextEditingController(text: org.website ?? '');
    _orgType = org.orgType;
    _openingHours = {};
    if (org.openingHours != null) {
      for (final entry in org.openingHours!.entries) {
        _openingHours[entry.key] = _OHEntry(
          from: entry.value.from,
          to: entry.value.to,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final name = widget.org.name;
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  bool _isEditing(_Section s) => _editing == s;

  void _toggle(_Section s) {
    Haptic.light();
    setState(() => _editing = (_editing == s) ? null : s);
  }

  Future<void> _save(_Section section) async {
    setState(() => _busy = true);
    try {
      final fields = <String, dynamic>{};
      switch (section) {
        case _Section.general:
          fields['name'] = _nameCtrl.text.trim();
          fields['orgType'] = _orgType;
        case _Section.contact:
          fields['address'] = _addressCtrl.text.trim();
          fields['contactPerson'] = _contactCtrl.text.trim();
          fields['phone'] = _phoneCtrl.text.trim();
          fields['website'] = _websiteCtrl.text.trim();
        case _Section.openingHours:
          final ohMap = <String, dynamic>{};
          for (final entry in _openingHours.entries) {
            ohMap[entry.key] = {
              'fromHour': entry.value.from.hour,
              'fromMinute': entry.value.from.minute,
              'toHour': entry.value.to.hour,
              'toMinute': entry.value.to.minute,
            };
          }
          fields['openingHours'] = ohMap;
      }
      await _service.updateProfile(fields);
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        Haptic.medium();
        setState(() => _editing = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.orgProfileSaved)),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[OrgProfileTab] save error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.orgProfileSaveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportOrgData(AppLocalizations l) async {
    try {
      final patients = await _service.fetchAllOrgPatients();
      if (!mounted) return;

      if (patients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.orgExportEmpty)),
        );
        return;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final rows = patients.map((p) {
        return [
          p.patientName,
          p.patientEmail,
          p.diagnosis ?? '',
          p.opDate != null ? DateFormat('dd.MM.yyyy').format(p.opDate!) : '',
          p.doctorName,
          p.warnStatus.name,
        ];
      }).toList();

      if (!mounted) return;

      await exportCsv(
        context: context,
        fileName: 'org_export_$dateStr.csv',
        headers: [
          'Patient',
          'E-Mail',
          'Diagnose',
          'OP-Datum',
          l.orgPatientDoctor,
          'Status',
        ],
        rows: rows,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[OrgProfileTab] export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.orgExportError)),
        );
      }
    }
  }

  static const _orgTypes = [
    'Klinik / Krankenhaus',
    'MVZ',
    'Praxis-Netzwerk',
    'Rehabilitationseinrichtung',
    'Sonstige',
  ];

  TextStyle get _valueStyle => const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final org = widget.org;

    return GlassPage(
      title: l.sectionProfile,
      titleIcon: Icons.business_rounded,
      titleColor: AppColors.primary,
      showBackButton: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          if (isDesktop) return _buildDesktop(l, theme, org);
          return _buildMobile(l, theme, org);
        },
      ),
    );
  }

  // ── Desktop: 2-column layout ──────────────────────────────────

  Widget _buildDesktop(AppLocalizations l, ThemeData theme, Organisation org) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(l, theme, org),
              const SizedBox(height: AppSpacing.xxl),
              _buildGeneralSection(l, org),
              const SizedBox(height: AppSpacing.lg),
              _buildContactSection(l, org),
              const SizedBox(height: AppSpacing.xxl),
              ..._buildAccountSupportSection(l, delay: 200),
              const SizedBox(height: AppSpacing.xxxl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: GlassButton(
                  onPressed: () => AuthService().signOut(),
                  icon: Icons.logout_rounded,
                  label: l.logout,
                  variant: GlassButtonVariant.ghost,
                  expand: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOpeningHoursSection(l),
              const SizedBox(height: AppSpacing.lg),
              _OrgProStatusSection(org: org),
              const SizedBox(height: AppSpacing.lg),
              OrgBillingSection(orgUid: org.uid),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile: linear layout ─────────────────────────────────────

  Widget _buildMobile(AppLocalizations l, ThemeData theme, Organisation org) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHero(l, theme, org),
        const SizedBox(height: AppSpacing.xxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _buildGeneralSection(l, org),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: _buildContactSection(l, org),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: _buildOpeningHoursSection(l),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: _OrgProStatusSection(org: org),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 230),
          child: OrgBillingSection(orgUid: org.uid),
        ),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildAccountSupportSection(l, delay: 260),
        const SizedBox(height: AppSpacing.xxxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 320),
          child: GlassButton(
            onPressed: () => AuthService().signOut(),
            icon: Icons.logout_rounded,
            label: l.logout,
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ── Hero ──────────────────────────────────────────────────────

  Widget _buildHero(AppLocalizations l, ThemeData theme, Organisation org) {
    return FadeSlideIn(
      child: GlassContainer(
        variant: GlassVariant.thick,
        elevation: GlassElevation.high,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        borderRadius: AppRadius.borderRadiusXl,
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                _initials,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          org.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final orgEnt = ProServices.maybeOf(context)
                              ?.orgEntitlementService;
                          if (orgEnt == null) return const SizedBox.shrink();
                          return ValueListenableBuilder<OrgEntitlement>(
                            valueListenable: orgEnt.entitlement,
                            builder: (_, ent, _) {
                              if (!ent.isActive) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.12),
                                    borderRadius: AppRadius.borderRadiusPill,
                                    border: Border.all(
                                      color: AppColors.success
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  if (org.orgType.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      org.orgType,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    org.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── General Info (editable) ───────────────────────────────────

  Widget _buildGeneralSection(AppLocalizations l, Organisation org) {
    final editing = _isEditing(_Section.general);
    return _EditableSection(
      icon: Icons.business_rounded,
      iconColor: AppColors.primary,
      title: l.orgSettingsGeneralInfo,
      isEditing: editing,
      onEditToggle: () => _toggle(_Section.general),
      onSave: _busy ? null : () => _save(_Section.general),
      child: Column(
        children: [
          _FieldRow(
            icon: Icons.badge_outlined,
            label: l.orgRegOrgName,
            child: editing
                ? _inlineField(_nameCtrl, onChanged: () => setState(() {}))
                : Text(org.name.isEmpty ? l.nichtHinterlegt : org.name,
                    style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.category_rounded,
            label: l.orgRegOrgType,
            child: editing
                ? DropdownButton<String>(
                    value: _orgTypes.contains(_orgType) ? _orgType : null,
                    isExpanded: true,
                    items: _orgTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _orgType = v);
                    },
                  )
                : Text(
                    org.orgType.isEmpty ? l.nichtHinterlegt : org.orgType,
                    style: _valueStyle),
          ),
          if (org.createdAt != null) ...[
            _divider(),
            _FieldRow(
              icon: Icons.calendar_today_rounded,
              label: l.erstelltAm,
              child: Text(_formatDate(org.createdAt!, l), style: _valueStyle),
            ),
          ],
        ],
      ),
    );
  }

  // ── Contact info (editable) ───────────────────────────────────

  Widget _buildContactSection(AppLocalizations l, Organisation org) {
    final editing = _isEditing(_Section.contact);
    return _EditableSection(
      icon: Icons.contact_phone_rounded,
      iconColor: AppColors.accent,
      title: l.orgSettingsContactInfo,
      isEditing: editing,
      onEditToggle: () => _toggle(_Section.contact),
      onSave: _busy ? null : () => _save(_Section.contact),
      child: Column(
        children: [
          _FieldRow(
            icon: Icons.person_outline_rounded,
            label: l.orgRegContactPerson,
            child: editing
                ? _inlineField(_contactCtrl)
                : Text(
                    org.contactPerson.isEmpty
                        ? l.nichtHinterlegt
                        : org.contactPerson,
                    style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.email_outlined,
            label: l.fieldEmail,
            child: Text(org.email, style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.phone_outlined,
            label: l.orgRegPhone,
            child: editing
                ? _inlineField(_phoneCtrl, keyboardType: TextInputType.phone)
                : Text(
                    (org.phone ?? '').isEmpty
                        ? l.nichtHinterlegt
                        : org.phone!,
                    style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.location_on_outlined,
            label: l.orgRegAddress,
            child: editing
                ? _inlineField(_addressCtrl, maxLines: 2)
                : Text(
                    org.address.isEmpty ? l.nichtHinterlegt : org.address,
                    style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.language_rounded,
            label: l.orgSettingsWebsite,
            child: editing
                ? _inlineField(_websiteCtrl, keyboardType: TextInputType.url)
                : Text(
                    (org.website ?? '').isEmpty
                        ? l.nichtHinterlegt
                        : org.website!,
                    style: _valueStyle),
          ),
        ],
      ),
    );
  }

  // ── Opening hours (editable) ──────────────────────────────────

  Widget _buildOpeningHoursSection(AppLocalizations l) {
    final editing = _isEditing(_Section.openingHours);
    final dayKeys = [
      'monday', 'tuesday', 'wednesday', 'thursday',
      'friday', 'saturday', 'sunday',
    ];
    final dayLabels = [
      l.weekdayMonday, l.weekdayTuesday, l.weekdayWednesday,
      l.weekdayThursday, l.weekdayFriday, l.weekdaySaturday,
      l.weekdaySunday,
    ];

    return _EditableSection(
      icon: Icons.schedule_rounded,
      iconColor: AppColors.success,
      title: l.orgSettingsOpeningHours,
      isEditing: editing,
      onEditToggle: () => _toggle(_Section.openingHours),
      onSave: _busy ? null : () => _save(_Section.openingHours),
      child: Column(
        children: [
          for (var i = 0; i < dayKeys.length; i++) ...[
            if (i > 0) _divider(),
            _buildDayRow(dayKeys[i], dayLabels[i], editing),
          ],
        ],
      ),
    );
  }

  Widget _buildDayRow(String key, String label, bool editing) {
    final entry = _openingHours[key];
    if (!editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(entry != null ? entry.format() : '–', style: _valueStyle),
          ],
        ),
      );
    }

    final hasEntry = entry != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Checkbox(
            value: hasEntry,
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _openingHours[key] = _OHEntry(
                    from: const TimeOfDay(hour: 8, minute: 0),
                    to: const TimeOfDay(hour: 17, minute: 0),
                  );
                } else {
                  _openingHours.remove(key);
                }
              });
            },
          ),
          if (hasEntry) ...[
            _timeButton(entry.from, (t) {
              setState(() =>
                  _openingHours[key] = _OHEntry(from: t, to: entry.to));
            }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('–'),
            ),
            _timeButton(entry.to, (t) {
              setState(() =>
                  _openingHours[key] = _OHEntry(from: entry.from, to: t));
            }),
          ],
        ],
      ),
    );
  }

  Widget _timeButton(TimeOfDay time, ValueChanged<TimeOfDay> onPicked) {
    return InkWell(
      borderRadius: AppRadius.borderRadiusSm,
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (t != null) onPicked(t);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }



  // ── Account & support section ─────────────────────────────────

  List<Widget> _buildAccountSupportSection(AppLocalizations l,
      {int delay = 200}) {
    return [
      FadeSlideIn(
        delay: Duration(milliseconds: delay),
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.borderRadiusLg,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: const Icon(Icons.help_outline_rounded,
                      size: 20, color: AppColors.primary),
                ),
                title: Text(l.helpHilfeUndSupport),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HelpScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: const Icon(Icons.download_rounded,
                      size: 20, color: AppColors.textSecondary),
                ),
                title: Text(l.orgSettingsDataExport),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                contentPadding: EdgeInsets.zero,
                onTap: () => _exportOrgData(l),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  // ── Helpers ───────────────────────────────────────────────────

  Widget _inlineField(
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => onChanged?.call(),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l) {
    final months = [
      l.monthJanuary, l.monthFebruary, l.monthMarch, l.monthApril,
      l.monthMay, l.monthJune, l.monthJuly, l.monthAugust,
      l.monthSeptember, l.monthOctober, l.monthNovember, l.monthDecember,
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Shared private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _EditableSection extends StatelessWidget {
  const _EditableSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isEditing,
    required this.onEditToggle,
    required this.onSave,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isEditing;
  final VoidCallback onEditToggle;
  final VoidCallback? onSave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.12),
                      iconColor.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PressableScale(
                onTap: onEditToggle,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isEditing
                        ? AppColors.primary.withValues(alpha: 0.10)
                        : AppColors.grey100,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Icon(
                    isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    size: 16,
                    color: isEditing ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.lg),
          child,
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.xl),
            GlassButton(
              onPressed: onSave,
              label: l.save,
              icon: Icons.check_rounded,
              expand: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _divider() => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Divider(
        color: AppColors.textSecondary.withValues(alpha: 0.12),
        height: 1,
      ),
    );



// ─────────────────────────────────────────────────────────────────────────────
// Pro status section
// ─────────────────────────────────────────────────────────────────────────────

class _OrgProStatusSection extends StatelessWidget {
  const _OrgProStatusSection({required this.org});

  final Organisation org;

  @override
  Widget build(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    final orgEnt = pro?.orgEntitlementService;

    if (orgEnt == null) return const SizedBox.shrink();

    return ValueListenableBuilder<OrgEntitlement>(
      valueListenable: orgEnt.entitlement,
      builder: (context, ent, _) {
        final l = AppLocalizations.of(context)!;
        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.borderRadiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: ent.isActive
                        ? AppColors.success
                        : const Color(0xFF007AFF),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l.proStatus,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (ent.isActive) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderRadiusPill,
                        border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 6),
                          Text(
                            l.proActiveTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (ent.proExpiresAt != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _FieldRow(
                    icon: Icons.event_rounded,
                    label: l.validUntil(''),
                    child: Text(
                      _formatDate(ent.proExpiresAt!, l),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ] else ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.10),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                      child: Text(
                        l.freeTier,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          final p = ProServices.of(context);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OrgPaywallScreen(
                                billingService: p.billingService,
                                orgEntitlementService:
                                    p.orgEntitlementService,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.workspace_premium_rounded,
                            size: 18),
                        label: Text(l.upgradeNow),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final p = ProServices.of(context);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OrgPaywallScreen(
                                billingService: p.billingService,
                                orgEntitlementService:
                                    p.orgEntitlementService,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.vpn_key_rounded, size: 18),
                        label: Text(l.redeemKey),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF007AFF),
                          side: const BorderSide(
                            color: Color(0xFF007AFF),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime date, AppLocalizations l) {
    final months = [
      l.monthJanuary, l.monthFebruary, l.monthMarch, l.monthApril,
      l.monthMay, l.monthJune, l.monthJuly, l.monthAugust,
      l.monthSeptember, l.monthOctober, l.monthNovember, l.monthDecember,
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Opening hours helper
// ─────────────────────────────────────────────────────────────────────────────

class _OHEntry {
  _OHEntry({required this.from, required this.to});

  final TimeOfDay from;
  final TimeOfDay to;

  String format() {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(from.hour)}:${pad(from.minute)} – ${pad(to.hour)}:${pad(to.minute)}';
  }
}
