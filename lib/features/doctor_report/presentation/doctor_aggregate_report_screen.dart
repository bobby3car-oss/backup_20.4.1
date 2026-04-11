import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../features/doctor_patients/data/doctor_patient_repository.dart';
import '../../../features/doctor_patients/domain/linked_patient.dart';
import '../../../features/red_flags/domain/red_flag.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for per-patient monthly stats
// ─────────────────────────────────────────────────────────────────────────────

class _PatientMonthlyStats {
  const _PatientMonthlyStats({
    required this.patient,
    required this.painEntryCount,
    required this.avgPain,
    required this.minPain,
    required this.maxPain,
    required this.painTrend,
    required this.timelineTotalTasks,
    required this.timelineDoneTasks,
    required this.redFlags,
  });

  final LinkedPatient patient;
  final int painEntryCount;
  final double avgPain;
  final int minPain;
  final int maxPain;
  final String painTrend; // ↑ ↓ →
  final int timelineTotalTasks;
  final int timelineDoneTasks;
  final List<RedFlag> redFlags;

  double get complianceRate =>
      timelineTotalTasks > 0 ? timelineDoneTasks / timelineTotalTasks : 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class DoctorAggregateReportScreen extends StatefulWidget {
  const DoctorAggregateReportScreen({
    super.key,
    this.overrideDoctorUid,
  });

  final String? overrideDoctorUid;

  @override
  State<DoctorAggregateReportScreen> createState() =>
      _DoctorAggregateReportScreenState();
}

class _DoctorAggregateReportScreenState
    extends State<DoctorAggregateReportScreen> {
  late final DoctorPatientRepository _repo;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  String? _error;
  List<_PatientMonthlyStats> _stats = [];

  late DateTime _monthStart;
  late DateTime _monthEnd;

  @override
  void initState() {
    super.initState();
    _repo = DoctorPatientRepository(
        overrideDoctorUid: widget.overrideDoctorUid);
    final now = DateTime.now();
    _monthStart = DateTime(now.year, now.month);
    _monthEnd = DateTime(now.year, now.month + 1);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final patients = await _repo.getLinkedPatientsOnce();
      final enriched = <LinkedPatient>[];
      for (final p in patients) {
        try {
          enriched.add(await _repo.enrichPatient(p));
        } catch (_) {
          enriched.add(p);
        }
      }

      final stats = <_PatientMonthlyStats>[];
      const batchSize = 5;
      for (var i = 0; i < enriched.length; i += batchSize) {
        final batch = enriched.skip(i).take(batchSize);
        final batchStats = await Future.wait(
          batch.map((p) => _computePatientStats(p)),
        );
        stats.addAll(batchStats);
      }

      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<_PatientMonthlyStats> _computePatientStats(
      LinkedPatient patient) async {
    // ── Pain entries this month ──
    int painCount = 0;
    double painSum = 0;
    int minPain = 10;
    int maxPain = 0;
    double firstHalfAvg = 0;
    int firstHalfCount = 0;
    double secondHalfAvg = 0;
    int secondHalfCount = 0;
    final midMonth = _monthStart.add(
      Duration(days: _monthEnd.difference(_monthStart).inDays ~/ 2),
    );

    try {
      final painSnap = await _firestore
          .collection(FirestorePaths.painCollection(patient.uid))
          .where('occurredAt',
              isGreaterThanOrEqualTo: _monthStart.toIso8601String())
          .where('occurredAt', isLessThan: _monthEnd.toIso8601String())
          .orderBy('occurredAt')
          .get();

      for (final doc in painSnap.docs) {
        final data = doc.data();
        final level = (data['painLevel'] as num?)?.toInt() ?? 0;
        painSum += level;
        painCount++;
        if (level < minPain) minPain = level;
        if (level > maxPain) maxPain = level;

        final occurredAt =
            DateTime.tryParse(data['occurredAt']?.toString() ?? '');
        if (occurredAt != null) {
          if (occurredAt.isBefore(midMonth)) {
            firstHalfAvg += level;
            firstHalfCount++;
          } else {
            secondHalfAvg += level;
            secondHalfCount++;
          }
        }
      }
    } catch (_) {}

    if (painCount == 0) {
      minPain = 0;
      maxPain = 0;
    }

    String painTrend = '→';
    if (firstHalfCount > 0 && secondHalfCount > 0) {
      final firstAvg = firstHalfAvg / firstHalfCount;
      final secondAvg = secondHalfAvg / secondHalfCount;
      if (secondAvg > firstAvg + 0.5) {
        painTrend = '↑';
      } else if (secondAvg < firstAvg - 0.5) {
        painTrend = '↓';
      }
    }

    // ── Timeline compliance this month ──
    int totalTasks = 0;
    int doneTasks = 0;
    try {
      final timelineSnap = await _firestore
          .collection(FirestorePaths.timelineCollection(patient.uid))
          .where('scheduledAt',
              isGreaterThanOrEqualTo: _monthStart.toIso8601String())
          .where('scheduledAt', isLessThan: _monthEnd.toIso8601String())
          .get();

      for (final doc in timelineSnap.docs) {
        final data = doc.data();
        totalTasks++;
        final state = data['state']?.toString() ?? '';
        if (state == 'done') doneTasks++;
      }
    } catch (_) {}

    // ── Red flags (use enriched data, already loaded) ──
    final activeRedFlags = patient.redFlags
        .where((r) =>
            r.status != RedFlagStatus.resolved &&
            r.createdAt.isAfter(_monthStart) &&
            r.createdAt.isBefore(_monthEnd))
        .toList();

    return _PatientMonthlyStats(
      patient: patient,
      painEntryCount: painCount,
      avgPain: painCount > 0 ? painSum / painCount : 0,
      minPain: minPain,
      maxPain: maxPain,
      painTrend: painTrend,
      timelineTotalTasks: totalTasks,
      timelineDoneTasks: doneTasks,
      redFlags: activeRedFlags,
    );
  }

  // ── PDF export ──────────────────────────────────────────────────

  Future<void> _exportPdf() async {
    if (_stats.isEmpty) return;

    try {
      final bytes = await _buildAggregatePdf(_stats, _monthStart);
      final monthLabel = DateFormat('yyyy-MM').format(_monthStart);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Monatsbericht_$monthLabel.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF-Export fehlgeschlagen: $e')),
        );
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy', 'de').format(_monthStart);

    return GlassPage(
      title: 'Monatsbericht',
      titleIcon: Icons.assessment_rounded,
      trailing: _loading || _stats.isEmpty
          ? const SizedBox.shrink()
          : PressableScale(
              onTap: _exportPdf,
              scaleFactor: 0.90,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.65),
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.80),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Fehler: $_error',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _stats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 56, color: AppColors.grey400),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Keine Patienten verknüpft',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        120,
                      ),
                      children: [
                        // ── Month header ──
                        FadeSlideIn(
                          child: Text(
                            monthLabel,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // ── Summary cards ──
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 60),
                          child: _SummaryCards(stats: _stats),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Red-flag summary ──
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 120),
                          child: _RedFlagSummary(stats: _stats),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Per-patient breakdown ──
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 180),
                          child: _SectionHeader(
                            icon: Icons.people_rounded,
                            title: 'Patienten-Details',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ..._stats.indexed.map(
                          (e) => FadeSlideIn(
                            delay:
                                Duration(milliseconds: 240 + e.$1 * 60),
                            child: _PatientStatsCard(stats: e.$2),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary cards row
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.stats});

  final List<_PatientMonthlyStats> stats;

  @override
  Widget build(BuildContext context) {
    final totalPatients = stats.length;
    final avgCompliance = stats.isEmpty
        ? 0.0
        : stats.fold<double>(
                0, (sum, s) => sum + s.complianceRate) /
            stats.length;
    final totalRedFlags =
        stats.fold<int>(0, (sum, s) => sum + s.redFlags.length);
    final avgPain = stats.where((s) => s.painEntryCount > 0).isEmpty
        ? 0.0
        : stats
                .where((s) => s.painEntryCount > 0)
                .fold<double>(0, (sum, s) => sum + s.avgPain) /
            stats.where((s) => s.painEntryCount > 0).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.people_rounded,
                  label: 'Aktive Patienten',
                  value: '$totalPatients',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Ø Compliance',
                  value: '${(avgCompliance * 100).toStringAsFixed(0)}%',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.flag_rounded,
                  label: 'Red Flags',
                  value: '$totalRedFlags',
                  color: totalRedFlags > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.show_chart_rounded,
                  label: 'Ø Schmerz',
                  value: avgPain > 0
                      ? '${avgPain.toStringAsFixed(1)}/10'
                      : '–',
                  color: AppColors.warning,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.people_rounded,
                    label: 'Aktive Patienten',
                    value: '$totalPatients',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Ø Compliance',
                    value: '${(avgCompliance * 100).toStringAsFixed(0)}%',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.flag_rounded,
                    label: 'Red Flags',
                    value: '$totalRedFlags',
                    color: totalRedFlags > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.show_chart_rounded,
                    label: 'Ø Schmerz',
                    value: avgPain > 0
                        ? '${avgPain.toStringAsFixed(1)}/10'
                        : '–',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Red flag summary
// ─────────────────────────────────────────────────────────────────────────────

class _RedFlagSummary extends StatelessWidget {
  const _RedFlagSummary({required this.stats});

  final List<_PatientMonthlyStats> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allFlags =
        stats.expand((s) => s.redFlags).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (allFlags.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        child: Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Keine Red Flags in diesem Monat',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bySeverity = <RedFlagSeverity, int>{};
    for (final f in allFlags) {
      bySeverity[f.severity] = (bySeverity[f.severity] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.flag_rounded,
          title: 'Red-Flag-Zusammenfassung',
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusLg,
          child: Column(
            children: [
              Row(
                children: [
                  if (bySeverity[RedFlagSeverity.red] != null)
                    _FlagChip(
                      label: '${bySeverity[RedFlagSeverity.red]} Rot',
                      color: const Color(0xFFFF3B30),
                    ),
                  if (bySeverity[RedFlagSeverity.orange] != null)
                    _FlagChip(
                      label: '${bySeverity[RedFlagSeverity.orange]} Orange',
                      color: const Color(0xFFFF9500),
                    ),
                  if (bySeverity[RedFlagSeverity.yellow] != null)
                    _FlagChip(
                      label: '${bySeverity[RedFlagSeverity.yellow]} Gelb',
                      color: const Color(0xFFFFCC00),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...allFlags.take(5).map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _severityColor(f.severity),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            f.title,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('dd.MM.').format(f.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (allFlags.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '+ ${allFlags.length - 5} weitere',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _severityColor(RedFlagSeverity s) => switch (s) {
        RedFlagSeverity.red => const Color(0xFFFF3B30),
        RedFlagSeverity.orange => const Color(0xFFFF9500),
        RedFlagSeverity.yellow => const Color(0xFFFFCC00),
        RedFlagSeverity.green => const Color(0xFF34C759),
      };
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-patient stats card
// ─────────────────────────────────────────────────────────────────────────────

class _PatientStatsCard extends StatelessWidget {
  const _PatientStatsCard({required this.stats});

  final _PatientMonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = stats.patient;
    final compliance = stats.complianceRate;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient header ──
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials(p.displayName),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (p.diagnosis != null && p.diagnosis!.isNotEmpty)
                        Text(
                          p.diagnosis!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (stats.redFlags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${stats.redFlags.length} Flags',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Metrics row ──
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Compliance',
                    value: stats.timelineTotalTasks > 0
                        ? '${(compliance * 100).toStringAsFixed(0)}%'
                        : '–',
                    color: compliance >= 0.8
                        ? AppColors.success
                        : compliance >= 0.5
                            ? AppColors.warning
                            : AppColors.error,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Ø Schmerz',
                    value: stats.painEntryCount > 0
                        ? '${stats.avgPain.toStringAsFixed(1)} ${stats.painTrend}'
                        : '–',
                    color: AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Aufgaben',
                    value:
                        '${stats.timelineDoneTasks}/${stats.timelineTotalTasks}',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            if (stats.painEntryCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              // ── Pain range bar ──
              Row(
                children: [
                  Text(
                    'Schmerz: ${stats.minPain}–${stats.maxPain}/10',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: stats.avgPain / 10,
                        minHeight: 6,
                        backgroundColor:
                            AppColors.grey200,
                        valueColor: AlwaysStoppedAnimation(
                          stats.avgPain > 6
                              ? AppColors.error
                              : stats.avgPain > 3
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header (reusable)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aggregate PDF builder
// ─────────────────────────────────────────────────────────────────────────────

final _dateFmt = DateFormat('dd.MM.yyyy');

Future<Uint8List> _buildAggregatePdf(
  List<_PatientMonthlyStats> stats,
  DateTime monthStart,
) async {
  final monthLabel = DateFormat('MMMM yyyy', 'de').format(monthStart);

  final doc = pw.Document(
    title: 'Monatsbericht $monthLabel',
    author: 'Operationsbegleiter',
  );

  final totalPatients = stats.length;
  final avgCompliance = stats.isEmpty
      ? 0.0
      : stats.fold<double>(0, (sum, s) => sum + s.complianceRate) /
          stats.length;
  final totalRedFlags =
      stats.fold<int>(0, (sum, s) => sum + s.redFlags.length);
  final patientsWithPain =
      stats.where((s) => s.painEntryCount > 0).toList();
  final avgPain = patientsWithPain.isEmpty
      ? 0.0
      : patientsWithPain.fold<double>(0, (sum, s) => sum + s.avgPain) /
          patientsWithPain.length;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.blue200, width: 1),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Monatsbericht – $monthLabel',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.Text(
              'Erstellt: ${_dateFmt.format(DateTime.now())}',
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
      footer: (ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 8),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Operationsbegleiter App',
              style:
                  const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Text(
              'Seite ${ctx.pageNumber} / ${ctx.pagesCount}',
              style:
                  const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
      build: (ctx) => [
        // ── Summary section ──
        _pdfSectionTitle('Zusammenfassung'),
        _pdfKv('Aktive Patienten', '$totalPatients'),
        _pdfKv('Ø Compliance',
            '${(avgCompliance * 100).toStringAsFixed(0)}%'),
        _pdfKv('Gesamte Red Flags', '$totalRedFlags'),
        _pdfKv(
            'Ø Schmerzlevel',
            avgPain > 0
                ? '${avgPain.toStringAsFixed(1)}/10'
                : 'Keine Daten'),
        pw.SizedBox(height: 14),

        // ── Red flags ──
        if (totalRedFlags > 0) ...[
          _pdfSectionTitle('Red Flags'),
          pw.TableHelper.fromTextArray(
            headerStyle:
                pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.grey100),
            cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6, vertical: 3),
            headers: ['Patient', 'Schweregrad', 'Titel', 'Datum'],
            data: stats
                .expand((s) => s.redFlags.map((f) => [
                      s.patient.displayName,
                      f.severity.name,
                      f.title.length > 30
                          ? '${f.title.substring(0, 30)}…'
                          : f.title,
                      _dateFmt.format(f.createdAt),
                    ]))
                .toList(),
          ),
          pw.SizedBox(height: 14),
        ],

        // ── Per-patient table ──
        _pdfSectionTitle('Patienten-Details'),
        pw.TableHelper.fromTextArray(
          headerStyle:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.grey100),
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          headers: [
            'Patient',
            'Compliance',
            'Ø Schmerz',
            'Trend',
            'Aufgaben',
            'Red Flags',
          ],
          data: stats
              .map((s) => [
                    s.patient.displayName,
                    s.timelineTotalTasks > 0
                        ? '${(s.complianceRate * 100).toStringAsFixed(0)}%'
                        : '–',
                    s.painEntryCount > 0
                        ? '${s.avgPain.toStringAsFixed(1)}/10'
                        : '–',
                    s.painTrend,
                    '${s.timelineDoneTasks}/${s.timelineTotalTasks}',
                    '${s.redFlags.length}',
                  ])
              .toList(),
        ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _pdfSectionTitle(String title) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 6),
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    ),
  );
}

pw.Widget _pdfKv(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 140,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
          ),
        ),
      ],
    ),
  );
}
