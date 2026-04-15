import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../doctor_invite/presentation/invite_sheet.dart';
import '../data/doctor_patient_repository.dart';
import '../domain/linked_patient.dart';
import 'patient_card.dart';
import 'patient_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

/// The first tab showing a searchable list of linked patients.
class DoctorPatientsTab extends StatefulWidget {
  const DoctorPatientsTab({super.key, this.doctorUid});

  /// Doctor UID override for staff mode.
  final String? doctorUid;

  @override
  State<DoctorPatientsTab> createState() => _DoctorPatientsTabState();
}

/// Breakpoint above which the master–detail side-by-side layout is used.
const _kDesktopBreakpoint = 900.0;

class _DoctorPatientsTabState extends State<DoctorPatientsTab> {
  late final DoctorPatientRepository _repository;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  late Stream<List<LinkedPatient>> _stream;

  // ── Master-detail selection ──────────────────────────────────
  LinkedPatient? _selectedPatient;

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

  void _onPatientTap(LinkedPatient patient) {
    Haptic.light();
    final width = MediaQuery.of(context).size.width;
    if (width >= _kDesktopBreakpoint) {
      setState(() => _selectedPatient = patient);
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => PatientDetailScreen(
            patient: patient,
            doctorUid: widget.doctorUid,
          ),
        ),
      );
    }
  }

  List<LinkedPatient> _applySearch(List<LinkedPatient> patients) {
    var result = List<LinkedPatient>.of(patients);

    // Text search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.displayName.toLowerCase().contains(q);
      }).toList();
    }

    // Sort by name
    result.sort(
        (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final master = Scaffold(
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
                      l.myPatients,
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
                  hint: l.searchPatient,
                  onChanged: (v) => setState(() => _searchQuery = v),
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
                              l.patientListLoadError,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FilledButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(l.retry),
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
                    final filtered = _applySearch(patients);

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
                                  ? l.noPatientsLinkedYet
                                  : l.noPatientsInCategory,
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
                                label: Text(l.patientInvite),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextButton.icon(
                                onPressed: _retry,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(l.update),
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
                        return FadeSlideIn(
                          delay: Duration(
                            milliseconds: (index * 50).clamp(0, 400),
                          ),
                          child: PatientCard(
                            patient: patient,
                            onTap: () => _onPatientTap(patient),
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

    return MasterDetailLayout(
      masterWidget: master,
      detailWidget: _selectedPatient != null
          ? PatientDetailScreen(
              patient: _selectedPatient!,
              doctorUid: widget.doctorUid,
            )
          : null,
      detailSelected: _selectedPatient != null,
      onBackFromDetail: () => setState(() => _selectedPatient = null),
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
