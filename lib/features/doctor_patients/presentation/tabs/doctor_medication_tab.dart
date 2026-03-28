import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Doctor-facing medication tab showing a patient's active reminders and
/// recent intake history with compliance tracking.
class DoctorMedicationTab extends StatefulWidget {
  const DoctorMedicationTab({super.key, required this.patientId});

  final String patientId;

  @override
  State<DoctorMedicationTab> createState() => _DoctorMedicationTabState();
}

class _DoctorMedicationTabState extends State<DoctorMedicationTab> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _ComplianceOverview(patientId: widget.patientId),
        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(title: 'Medikamentenplan'),
        const SizedBox(height: AppSpacing.sm),
        _RemindersList(patientId: widget.patientId),
        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(title: l.letzteEinnahmen),
        const SizedBox(height: AppSpacing.sm),
        _IntakeHistory(patientId: widget.patientId),
      ],
    );
  }
}

// ── Section Header ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ── Compliance Overview ──────────────────────────────────────────────

class _ComplianceOverview extends StatelessWidget {
  const _ComplianceOverview({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('patients/$patientId/medication_intakes')
          .where('takenAt', isGreaterThanOrEqualTo: sevenDaysAgo.toIso8601String())
          .orderBy('takenAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final intakes = snapshot.data?.docs ?? [];

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('patients/$patientId/medication_reminders')
              .snapshots(),
          builder: (context, reminderSnap) {
            final reminders = (reminderSnap.data?.docs ?? [])
                .where((d) => d.data()['isEnabled'] == true && d.data()['deletedAt'] == null)
                .toList();

            if (reminders.isEmpty) {
              return GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(Icons.medication_outlined,
                          size: 32, color: AppColors.grey400),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Keine Medikamente eingerichtet',
                          style: TextStyle(color: AppColors.grey500),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Calculate compliance: intakes in 7d / (reminders * 7)
            final expectedTotal = reminders.length * 7;
            final actualTotal = intakes.length;
            final rate = expectedTotal > 0
                ? (actualTotal / expectedTotal).clamp(0.0, 1.0)
                : 0.0;

            final color = rate > 0.8
                ? AppColors.success
                : rate > 0.5
                    ? AppColors.warning
                    : AppColors.error;

            return GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics_rounded,
                            size: 20, color: color),
                        const SizedBox(width: AppSpacing.sm),
                        const Text(
                          'Compliance (7 Tage)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(rate * 100).round()}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: AppRadius.borderRadiusPill,
                      child: LinearProgressIndicator(
                        value: rate,
                        minHeight: 8,
                        backgroundColor:
                            AppColors.grey300.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$actualTotal von $expectedTotal erwarteten Einnahmen',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Reminders List ───────────────────────────────────────────────────

class _RemindersList extends StatelessWidget {
  const _RemindersList({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('patients/$patientId/medication_reminders')
          .orderBy('medicationName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = (snapshot.data?.docs ?? [])
            .where((d) => d.data()['deletedAt'] == null)
            .toList();

        if (docs.isEmpty) {
          return GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'Kein Medikamentenplan vorhanden',
                  style: TextStyle(color: AppColors.grey500),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < docs.length; i++) ...[
              _ReminderCard(data: docs[i].data()),
              if (i < docs.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = (data['medicationName'] ?? data['name'] ?? '').toString();
    final dose = (data['dose'] ?? '').toString();
    final enabled = data['isEnabled'] as bool? ?? true;
    // Derive display time from new slots map, with fallback to legacy hour/minute
    final slotsMap = data['slots'] as Map<String, dynamic>? ?? {};
    final enabledSlotLabels = slotsMap.entries
        .where((e) => (e.value as Map?)?['isEnabled'] == true)
        .map((e) {
          switch (e.key) {
            case 'morgens': return '☀️';
            case 'mittags': return '🌤';
            case 'abends': return '🌙';
            case 'nachts': return '🌑';
            default: return e.key;
          }
        })
        .toList();
    final time = enabledSlotLabels.isNotEmpty
        ? enabledSlotLabels.join(' ')
        : (() {
            final h = (data['hour'] as int?) ?? 0;
            final m = (data['minute'] as int?) ?? 0;
            return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
          })();

    return GlassContainer(
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (enabled ? AppColors.primary : AppColors.grey400)
                    .withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 20,
                color: enabled ? AppColors.primary : AppColors.grey400,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (dose.isNotEmpty)
                    Text(
                      dose,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (!enabled) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.pause_circle_outline,
                  size: 16, color: AppColors.grey400),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Intake History ───────────────────────────────────────────────────

class _IntakeHistory extends StatelessWidget {
  const _IntakeHistory({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('patients/$patientId/medication_intakes')
          .orderBy('takenAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = (snapshot.data?.docs ?? [])
            .where((d) => d.data()['deletedAt'] == null)
            .toList();

        if (docs.isEmpty) {
          return GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'Noch keine Einnahmen dokumentiert',
                  style: TextStyle(color: AppColors.grey500),
                ),
              ),
            ),
          );
        }

        // Group by day
        final grouped = <String, List<Map<String, dynamic>>>{};
        for (final doc in docs) {
          final data = doc.data();
          final takenAt = DateTime.tryParse(data['takenAt']?.toString() ?? '');
          if (takenAt == null) continue;
          final key = '${takenAt.day.toString().padLeft(2, '0')}.'
              '${takenAt.month.toString().padLeft(2, '0')}.${takenAt.year}';
          grouped.putIfAbsent(key, () => []).add(data);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xs,
                ),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey500,
                  ),
                ),
              ),
              for (final intake in entry.value)
                _IntakeRow(data: intake),
            ],
          ],
        );
      },
    );
  }
}

class _IntakeRow extends StatelessWidget {
  const _IntakeRow({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final dose = (data['dose'] ?? '').toString();
    final takenAt = DateTime.tryParse(data['takenAt']?.toString() ?? '');
    final time = takenAt != null
        ? '${takenAt.hour.toString().padLeft(2, '0')}:${takenAt.minute.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              size: 16, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$name${dose.isNotEmpty ? ' ($dose)' : ''}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
