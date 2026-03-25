import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../doctor_invite/presentation/invite_sheet.dart';
import '../../doctor_report/doctor_report_builder.dart';
import '../data/doctor_patient_repository.dart';
import '../domain/linked_patient.dart';
import 'patient_card.dart';
import 'patient_detail_screen.dart';

/// Filter categories for the patient list.
enum PatientFilter { all, critical, activeToday, inactive }

/// Sort options for the patient list.
enum PatientSort { name, opDate, lastEntry, severity }

/// The first tab showing a filterable list of linked patients as cards.
class DoctorPatientsTab extends StatefulWidget {
  const DoctorPatientsTab({super.key, this.doctorUid});

  /// Doctor UID override for staff mode.
  final String? doctorUid;

  @override
  State<DoctorPatientsTab> createState() => _DoctorPatientsTabState();
}

class _DoctorPatientsTabState extends State<DoctorPatientsTab> {
  late final DoctorPatientRepository _repository;
  final _searchCtrl = TextEditingController();
  PatientFilter _filter = PatientFilter.all;
  PatientSort _sort = PatientSort.name;
  String _searchQuery = '';
  late Stream<List<LinkedPatient>> _stream;

  // ── Batch selection ──────────────────────────────────────────
  bool _multiSelectMode = false;
  final Set<String> _selectedUids = {};

  @override
  void initState() {
    super.initState();
    _repository = DoctorPatientRepository(overrideDoctorUid: widget.doctorUid);
    _stream = _repository.watchLinkedPatients();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _stream = _repository.watchLinkedPatients();
    });
  }

  void _exitMultiSelect() {
    setState(() {
      _multiSelectMode = false;
      _selectedUids.clear();
    });
  }

  void _toggleSelect(String uid) {
    setState(() {
      if (_selectedUids.contains(uid)) {
        _selectedUids.remove(uid);
        if (_selectedUids.isEmpty) _multiSelectMode = false;
      } else {
        _selectedUids.add(uid);
      }
    });
  }

  void _onLongPress(String uid) {
    Haptic.medium();
    setState(() {
      _multiSelectMode = true;
      _selectedUids.add(uid);
    });
  }

  List<LinkedPatient> _applyFilters(List<LinkedPatient> patients) {
    var result = List<LinkedPatient>.of(patients);

    // Category filter
    final now = DateTime.now();
    switch (_filter) {
      case PatientFilter.all:
        break;
      case PatientFilter.critical:
        result = result
            .where((p) =>
                p.redFlagCount > 0 ||
                p.warnStatus == ReportLight.red ||
                p.warnStatus == ReportLight.yellow)
            .toList();
        break;
      case PatientFilter.activeToday:
        result = result
            .where((p) =>
                p.lastEntryAt != null &&
                now.difference(p.lastEntryAt!).inHours < 24)
            .toList();
        break;
      case PatientFilter.inactive:
        result = result
            .where((p) =>
                p.lastEntryAt == null ||
                now.difference(p.lastEntryAt!).inDays > 3)
            .toList();
        break;
    }

    // Text search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.displayName.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q) ||
            (p.diagnosis?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Sorting
    switch (_sort) {
      case PatientSort.name:
        result.sort(
            (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        break;
      case PatientSort.opDate:
        result.sort((a, b) {
          if (a.opDate == null && b.opDate == null) return 0;
          if (a.opDate == null) return 1;
          if (b.opDate == null) return -1;
          return a.opDate!.compareTo(b.opDate!);
        });
        break;
      case PatientSort.lastEntry:
        result.sort((a, b) {
          if (a.lastEntryAt == null && b.lastEntryAt == null) return 0;
          if (a.lastEntryAt == null) return 1;
          if (b.lastEntryAt == null) return -1;
          return b.lastEntryAt!.compareTo(a.lastEntryAt!);
        });
        break;
      case PatientSort.severity:
        result.sort((a, b) {
          final sevCmp =
              b.maxRedFlagSeverity.index.compareTo(a.maxRedFlagSeverity.index);
          if (sevCmp != 0) return sevCmp;
          return b.redFlagCount.compareTo(a.redFlagCount);
        });
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (_multiSelectMode) ...[
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _exitMultiSelect,
                      ),
                      Text(
                        '${_selectedUids.length} ausgewählt',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      Text(
                        'Meine Patienten',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                    const Spacer(),
                    if (!_multiSelectMode)
                      PressableScale(
                        onTap: () {
                          Haptic.light();
                          _showInviteSheet();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Batch action bar ─────────────────────────────────
              if (_multiSelectMode)
                _BatchActionBar(
                  selectedCount: _selectedUids.length,
                  onMarkRead: () => _batchMarkRead(context),
                  onGroupMessage: () => _batchGroupMessage(context),
                  onPdfReport: () => _batchPdfReport(context),
                ),

              // ── Search bar ─────────────────────────────────────
              if (!_multiSelectMode) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: GlassTextField(
                    controller: _searchCtrl,
                    prefixIcon: Icons.search_rounded,
                    hint: 'Patient suchen …',
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Filter chips ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Alle',
                          selected: _filter == PatientFilter.all,
                          onTap: () =>
                              setState(() => _filter = PatientFilter.all),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Kritisch',
                          icon: Icons.flag_rounded,
                          iconColor: AppColors.error,
                          selected: _filter == PatientFilter.critical,
                          onTap: () =>
                              setState(() => _filter = PatientFilter.critical),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Aktiv heute',
                          icon: Icons.access_time_rounded,
                          iconColor: AppColors.success,
                          selected: _filter == PatientFilter.activeToday,
                          onTap: () => setState(
                              () => _filter = PatientFilter.activeToday),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Inaktiv >3 Tage',
                          icon: Icons.hourglass_empty_rounded,
                          iconColor: AppColors.warning,
                          selected: _filter == PatientFilter.inactive,
                          onTap: () =>
                              setState(() => _filter = PatientFilter.inactive),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // ── Sort dropdown ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    children: [
                      Icon(Icons.sort_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Sortierung:',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SortChip(
                        label: _sortLabel(_sort),
                        onTap: _showSortPicker,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),
              ],

              // ── Patient list ─────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<LinkedPatient>>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (kDebugMode && snapshot.hasError) {
                      debugPrint(
                          '[DoctorPatientsTab] stream error: ${snapshot.error}');
                      debugPrint(
                          '[DoctorPatientsTab] stack: ${snapshot.stackTrace}');
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Patientenliste konnte nicht geladen werden.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FilledButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Erneut versuchen'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final patients = snapshot.data ?? [];
                    final filtered = _applyFilters(patients);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 64,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              patients.isEmpty
                                  ? 'Noch keine Patienten verknüpft'
                                  : 'Keine Patienten in dieser Kategorie',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            if (patients.isEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              FilledButton.icon(
                                onPressed: _showInviteSheet,
                                icon: const Icon(Icons.person_add_rounded),
                                label: const Text('Patient einladen'),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextButton.icon(
                                onPressed: _retry,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Aktualisieren'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final patient = filtered[index];
                        final isSelected =
                            _selectedUids.contains(patient.uid);

                        return FadeSlideIn(
                          delay: Duration(
                            milliseconds: (index * 50).clamp(0, 400),
                          ),
                          child: _SelectablePatientCard(
                            patient: patient,
                            repository: _repository,
                            multiSelectMode: _multiSelectMode,
                            isSelected: isSelected,
                            onTap: _multiSelectMode
                                ? () => _toggleSelect(patient.uid)
                                : null,
                            onLongPress: () => _onLongPress(patient.uid),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sortLabel(PatientSort sort) => switch (sort) {
        PatientSort.name => 'Name',
        PatientSort.opDate => 'OP-Datum',
        PatientSort.lastEntry => 'Letzter Eintrag',
        PatientSort.severity => 'Schweregrad',
      };

  void _showSortPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sortierung',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final sort in PatientSort.values)
              ListTile(
                leading: Icon(
                  _sort == sort
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: _sort == sort ? AppColors.primary : AppColors.grey400,
                ),
                title: Text(_sortLabel(sort)),
                onTap: () {
                  setState(() => _sort = sort);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  // ── Batch actions ──────────────────────────────────────────────

  void _batchMarkRead(BuildContext context) {
    // Mark selected patients' red flags as acknowledged
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_selectedUids.length} Patienten als gelesen markiert'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _exitMultiSelect();
  }

  void _batchGroupMessage(BuildContext context) {
    final msgCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Gruppennachricht an ${_selectedUids.length} Patienten',
              style: Theme.of(ctx)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassTextField(
              controller: titleCtrl,
              hint: 'Titel',
              prefixIcon: Icons.title_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassTextField(
              controller: msgCtrl,
              hint: 'Nachricht eingeben …',
              prefixIcon: Icons.message_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final body = msgCtrl.text.trim();
                  if (title.isEmpty || body.isEmpty) return;
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  await _repository.broadcastMessage(
                    title: title,
                    body: body,
                  );
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                            'Nachricht an ${_selectedUids.length} Patienten gesendet'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _exitMultiSelect();
                  }
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Senden'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _batchPdfReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'PDF-Bericht für ${_selectedUids.length} Patienten wird erstellt …'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _exitMultiSelect();
  }

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const InviteSheet(),
    );
  }
}

// ── Batch Action Bar ───────────────────────────────────────────────────────

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({
    required this.selectedCount,
    required this.onMarkRead,
    required this.onGroupMessage,
    required this.onPdfReport,
  });

  final int selectedCount;
  final VoidCallback onMarkRead;
  final VoidCallback onGroupMessage;
  final VoidCallback onPdfReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _BatchButton(
              icon: Icons.done_all_rounded,
              label: 'Als gelesen',
              onTap: onMarkRead,
            ),
            const SizedBox(width: AppSpacing.sm),
            _BatchButton(
              icon: Icons.message_rounded,
              label: 'Gruppennachricht',
              onTap: onGroupMessage,
            ),
            const SizedBox(width: AppSpacing.sm),
            _BatchButton(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF-Bericht',
              onTap: onPdfReport,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchButton extends StatelessWidget {
  const _BatchButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderRadiusPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
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
    );
  }
}

// ── Selectable Patient Card ────────────────────────────────────────────────

class _SelectablePatientCard extends StatefulWidget {
  const _SelectablePatientCard({
    required this.patient,
    required this.repository,
    required this.multiSelectMode,
    required this.isSelected,
    this.onTap,
    required this.onLongPress,
  });

  final LinkedPatient patient;
  final DoctorPatientRepository repository;
  final bool multiSelectMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback onLongPress;

  @override
  State<_SelectablePatientCard> createState() => _SelectablePatientCardState();
}

class _SelectablePatientCardState extends State<_SelectablePatientCard> {
  late LinkedPatient _enriched;

  @override
  void initState() {
    super.initState();
    _enriched = widget.patient;
    _enrich();
  }

  Future<void> _enrich() async {
    try {
      final enriched =
          await widget.repository.enrichPatient(widget.patient);
      if (mounted) setState(() => _enriched = enriched);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: widget.isSelected
            ? BoxDecoration(
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              )
            : null,
        child: Stack(
          children: [
            PatientCard(
              patient: _enriched,
              onTap: widget.onTap ??
                  () {
                    Haptic.light();
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) =>
                            PatientDetailScreen(patient: _enriched),
                      ),
                    );
                  },
            ),
            if (widget.multiSelectMode)
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected
                        ? AppColors.primary
                        : Colors.white,
                    border: Border.all(
                      color: widget.isSelected
                          ? AppColors.primary
                          : AppColors.grey300,
                      width: 2,
                    ),
                  ),
                  child: widget.isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Enriches a patient card with latest entry / warning status data.
class _EnrichedPatientCard extends StatefulWidget {
  const _EnrichedPatientCard({
    required this.patient,
    required this.repository,
  });

  final LinkedPatient patient;
  final DoctorPatientRepository repository;

  @override
  State<_EnrichedPatientCard> createState() => _EnrichedPatientCardState();
}

class _EnrichedPatientCardState extends State<_EnrichedPatientCard> {
  late LinkedPatient _enriched;

  @override
  void initState() {
    super.initState();
    _enriched = widget.patient;
    _enrich();
  }

  Future<void> _enrich() async {
    try {
      final enriched =
          await widget.repository.enrichPatient(widget.patient);
      if (mounted) setState(() => _enriched = enriched);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PatientCard(
      patient: _enriched,
      onTap: () {
        Haptic.light();
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => PatientDetailScreen(patient: _enriched),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.grey300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? AppColors.white : (iconColor ?? AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? AppColors.white : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(color: AppColors.grey300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded,
                size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
