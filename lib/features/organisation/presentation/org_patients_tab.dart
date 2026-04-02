import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../../doctor_patients/presentation/patient_detail_screen.dart';
import '../data/organisation_service.dart';
import '../domain/org_patient.dart';
import '../../../l10n/app_localizations.dart';

/// Breakpoint above which the master–detail side-by-side layout is used.
const _kDesktopBreakpoint = 900.0;

/// Shows a combined patient list from all doctors in the organisation.
class OrgPatientsTab extends StatefulWidget {
  const OrgPatientsTab({super.key});

  @override
  State<OrgPatientsTab> createState() => _OrgPatientsTabState();
}

class _OrgPatientsTabState extends State<OrgPatientsTab> {
  final _service = OrganisationService();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── Master-detail selection ──────────────────────────────────
  OrgPatient? _selectedPatient;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  LinkedPatient _toLinkedPatient(OrgPatient p) {
    return LinkedPatient(
      uid: p.patientId,
      displayName: p.patientName,
      email: p.patientEmail,
      diagnosis: p.diagnosis?.isNotEmpty == true ? p.diagnosis : null,
      opDate: p.opDate,
    );
  }

  void _onPatientTap(OrgPatient patient) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _kDesktopBreakpoint) {
      setState(() => _selectedPatient = patient);
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => PatientDetailScreen(
            patient: _toLinkedPatient(patient),
            doctorUid: patient.doctorId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
      final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final master = SafeArea(
      bottom: false,
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(bottom: 120),
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  bottom: AppSpacing.lg,
                ),
                child: Text(
                  l.patienten,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ── Search bar ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: GlassTextField(
                  controller: _searchCtrl,
                  hint: l.patientSuchen,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
            ),

            // ── Patient list ────────────────────────────────
            SliverToBoxAdapter(
              child: StreamBuilder<List<OrgPatient>>(
                stream: _service.watchAllOrgPatients(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Text(
                          l.fehlerBeimLaden,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    );
                  }

                  var patients = snap.data ?? [];

                  if (patients.isEmpty) {
                    return _EmptyState(
                      message: l.nochKeinePatientenInDerOrganisation,
                    );
                  }

                  // Apply search filter.
                  if (_searchQuery.isNotEmpty) {
                    patients = patients
                        .where((p) =>
                            p.patientName
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            p.patientEmail
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            (p.diagnosis ?? '')
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            p.doctorName
                                .toLowerCase()
                                .contains(_searchQuery))
                        .toList();
                  }

                  if (patients.isEmpty) {
                    return _EmptyState(
                      message: l.keinePatienenGefunden,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.patientenAnzahl(patients.length),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...patients.indexed.map((e) => FadeSlideIn(
                            delay: Duration(
                                milliseconds:
                                    e.$1.clamp(0, 10) * 40),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: _PatientCard(
                                patient: e.$2,
                                onTap: () => _onPatientTap(e.$2),
                                isSelected:
                                    _selectedPatient?.patientId ==
                                        e.$2.patientId,
                              ),
                            ),
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    return MasterDetailLayout(
      masterWidget: master,
      detailWidget: _selectedPatient != null
          ? PatientDetailScreen(
              key: ValueKey(_selectedPatient!.patientId),
              patient: _toLinkedPatient(_selectedPatient!),
              doctorUid: _selectedPatient!.doctorId,
            )
          : null,
      detailSelected: _selectedPatient != null,
      onBackFromDetail: () => setState(() => _selectedPatient = null),
      emptyIcon: Icons.people_outline_rounded,
      emptyText: l.patientAuswaehlenUmDetailsAnzuzeigen,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient Card
// ─────────────────────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    this.onTap,
    this.isSelected = false,
  });

  final OrgPatient patient;
  final VoidCallback? onTap;
  final bool isSelected;

  String get _initials {
    final name = patient.patientName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  Color get _warnColor => switch (patient.warnStatus) {
        OrgPatientWarnStatus.red => AppColors.error,
        OrgPatientWarnStatus.yellow => AppColors.warning,
        OrgPatientWarnStatus.green => AppColors.success,
        OrgPatientWarnStatus.unknown => AppColors.grey400,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final diagnosis = patient.diagnosis ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(color: AppColors.primary, width: 2),
              )
            : null,
        child: GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accent.withValues(alpha: 0.12),
            child: Text(
              _initials,
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patient.patientName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (patient.warnStatus != OrgPatientWarnStatus.unknown)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _warnColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (patient.patientEmail.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    patient.patientEmail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (diagnosis.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    diagnosis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                patient.doctorName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (patient.opDate != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l.opDatumKurz(patient.opDate!.day, patient.opDate!.month, patient.opDate!.year),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
