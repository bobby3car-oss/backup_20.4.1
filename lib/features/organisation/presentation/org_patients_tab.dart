import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/organisation_service.dart';
import '../domain/org_doctor.dart';

/// Shows a combined patient list from all doctors in the organisation.
class OrgPatientsTab extends StatefulWidget {
  const OrgPatientsTab({super.key});

  @override
  State<OrgPatientsTab> createState() => _OrgPatientsTabState();
}

class _OrgPatientsTabState extends State<OrgPatientsTab> {
  final _service = OrganisationService();
  final _firestore = FirebaseFirestore.instance;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
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
                  'Patienten',
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
                  hint: 'Patient suchen…',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
            ),

            // ── Patient list ────────────────────────────────
            SliverToBoxAdapter(
              child: StreamBuilder<List<OrgDoctor>>(
                stream: _service.watchDoctors(),
                builder: (context, doctorSnap) {
                  if (doctorSnap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (doctorSnap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Text(
                          'Fehler beim Laden.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    );
                  }

                  final doctors = doctorSnap.data ?? [];
                  if (doctors.isEmpty) {
                    return _EmptyState(
                      message: 'Noch keine Ärzte in der Organisation.',
                    );
                  }

                  final activeDoctors =
                      doctors.where((d) => d.isActive).toList();

                  return _CombinedPatientList(
                    doctors: activeDoctors,
                    firestore: _firestore,
                    searchQuery: _searchQuery,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Combined patient list that merges streams from all doctors
// ─────────────────────────────────────────────────────────────────────────────

class _CombinedPatientList extends StatelessWidget {
  const _CombinedPatientList({
    required this.doctors,
    required this.firestore,
    required this.searchQuery,
  });

  final List<OrgDoctor> doctors;
  final FirebaseFirestore firestore;
  final String searchQuery;

  /// Build a single stream that merges patients from all doctor subcollections.
  Stream<List<_OrgPatientInfo>> _watchAllPatients() {
    if (doctors.isEmpty) return Stream.value([]);

    final streams = doctors.map((doctor) {
      return firestore
          .collection('doctors/${doctor.uid}/patients')
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
                final data = doc.data();
                return _OrgPatientInfo(
                  uid: doc.id,
                  displayName:
                      (data['displayName'] ?? '').toString(),
                  email: (data['email'] ?? '').toString(),
                  diagnosis: (data['diagnosis'] ?? '').toString(),
                  doctorName: doctor.name,
                  doctorUid: doctor.uid,
                );
              }).toList());
    }).toList();

    // Combine all streams into one using a cascading merge.
    return _combineStreams(streams);
  }

  /// Combines a list of patient-list streams into one merged list stream.
  Stream<List<_OrgPatientInfo>> _combineStreams(
    List<Stream<List<_OrgPatientInfo>>> streams,
  ) {
    if (streams.isEmpty) return Stream.value([]);
    if (streams.length == 1) return streams.first;

    // Use a simple approach: listen to each and merge results.
    final latestValues = List<List<_OrgPatientInfo>>.filled(
      streams.length,
      const [],
    );

    return Stream.multi((controller) {
      final subs = <int, dynamic>{};
      for (var i = 0; i < streams.length; i++) {
        final idx = i;
        subs[idx] = streams[idx].listen(
          (patients) {
            latestValues[idx] = patients;
            // Deduplicate by patient uid (same patient may be linked to
            // multiple doctors).
            final seen = <String>{};
            final merged = <_OrgPatientInfo>[];
            for (final list in latestValues) {
              for (final p in list) {
                if (seen.add(p.uid)) merged.add(p);
              }
            }
            merged.sort((a, b) => a.displayName
                .toLowerCase()
                .compareTo(b.displayName.toLowerCase()));
            controller.add(merged);
          },
          onError: controller.addError,
        );
      }

      controller.onCancel = () {
        for (final sub in subs.values) {
          (sub as dynamic).cancel();
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<_OrgPatientInfo>>(
      stream: _watchAllPatients(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          );
        }

        var patients = snap.data ?? [];

        // Apply search filter.
        if (searchQuery.isNotEmpty) {
          patients = patients
              .where((p) =>
                  p.displayName.toLowerCase().contains(searchQuery) ||
                  p.email.toLowerCase().contains(searchQuery) ||
                  p.diagnosis.toLowerCase().contains(searchQuery) ||
                  p.doctorName.toLowerCase().contains(searchQuery))
              .toList();
        }

        if (patients.isEmpty) {
          return _EmptyState(
            message: searchQuery.isNotEmpty
                ? 'Keine Patienten gefunden.'
                : 'Noch keine Patienten vorhanden.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patienten (${patients.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...patients.indexed.map((e) => FadeSlideIn(
                  delay: Duration(milliseconds: e.$1.clamp(0, 10) * 40),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PatientCard(patient: e.$2),
                  ),
                )),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class _OrgPatientInfo {
  const _OrgPatientInfo({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.diagnosis,
    required this.doctorName,
    required this.doctorUid,
  });

  final String uid;
  final String displayName;
  final String email;
  final String diagnosis;
  final String doctorName;
  final String doctorUid;
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient Card
// ─────────────────────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final _OrgPatientInfo patient;

  String get _initials {
    final name = patient.displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
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
                Text(
                  patient.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (patient.email.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    patient.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (patient.diagnosis.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    patient.diagnosis,
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
            ],
          ),
        ],
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
