import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../doctor_invite/presentation/invite_sheet.dart';
import '../data/doctor_patient_repository.dart';
import '../domain/linked_patient.dart';
import 'patient_card.dart';
import 'patient_detail_screen.dart';

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
  PatientPhase? _filterPhase;
  String _searchQuery = '';
  late Stream<List<LinkedPatient>> _stream;

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

  List<LinkedPatient> _applyFilters(List<LinkedPatient> patients) {
    var result = patients;
    if (_filterPhase != null) {
      result = result.where((p) => p.phase == _filterPhase).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.displayName.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q) ||
            (p.diagnosis?.toLowerCase().contains(q) ?? false);
      }).toList();
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
                    Text(
                      'Meine Patienten',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
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

              // ── Search bar ─────────────────────────────────────
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
                        selected: _filterPhase == null,
                        onTap: () => setState(() => _filterPhase = null),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(
                        label: 'Prä-OP',
                        selected: _filterPhase == PatientPhase.preOp,
                        onTap: () =>
                            setState(() => _filterPhase = PatientPhase.preOp),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(
                        label: 'Post-OP',
                        selected: _filterPhase == PatientPhase.postOp,
                        onTap: () =>
                            setState(() => _filterPhase = PatientPhase.postOp),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(
                        label: 'Entlassen',
                        selected: _filterPhase == PatientPhase.discharged,
                        onTap: () => setState(
                            () => _filterPhase = PatientPhase.discharged),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

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
                        return FadeSlideIn(
                          delay: Duration(
                            milliseconds: (index * 50).clamp(0, 400),
                          ),
                          child: _EnrichedPatientCard(
                            patient: filtered[index],
                            repository: _repository,
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
    } catch (_) {
      // Silently handle enrichment failure; show base data.
    }
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.white : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }
}
