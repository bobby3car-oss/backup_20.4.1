import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/organisation_service.dart';
import '../domain/org_patient.dart';

/// Read-only patient detail screen for organisation users.
///
/// Fetches all patient data through the [getOrgPatientDetail] Cloud Function
/// instead of direct Firestore access (which org users don't have).
class OrgPatientDetailScreen extends StatefulWidget {
  const OrgPatientDetailScreen({
    super.key,
    required this.patient,
  });

  final OrgPatient patient;

  @override
  State<OrgPatientDetailScreen> createState() => _OrgPatientDetailScreenState();
}

class _OrgPatientDetailScreenState extends State<OrgPatientDetailScreen> {
  final _service = OrganisationService();
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.fetchOrgPatientDetail(widget.patient.patientId);
  }

  void _refresh() {
    setState(() {
      _detailFuture = _service.fetchOrgPatientDetail(widget.patient.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPage(
      title: widget.patient.patientName,
      titleIcon: Icons.person_rounded,
      trailing: IconButton(
        onPressed: _refresh,
        icon: const Icon(Icons.refresh_rounded),
        tooltip: l.update,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ),
            );
          }

          final data = snap.data!;
          final patient =
              Map<String, dynamic>.from(data['patient'] as Map? ?? {});
          final timeline = _castList(data['timeline']);
          final redFlags = _castList(data['redFlags']);
          final vitals = _castList(data['vitals']);
          final pain = _castList(data['pain']);
          final appointments = _castList(data['appointments']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Read-only badge ─────────────────────────────
              FadeSlideIn(
                child: _InfoBanner(text: l.orgPatientReadOnly),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Patient header card ─────────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: _PatientHeaderCard(
                  patient: patient,
                  orgPatient: widget.patient,
                  l: l,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Red Flags ────────────────────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: _SectionCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.error,
                  title: l.orgPatientRedFlags,
                  emptyText: l.orgPatientNoRedFlags,
                  items: redFlags,
                  itemBuilder: (item) => _RedFlagTile(item: item),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Timeline ─────────────────────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _SectionCard(
                  icon: Icons.timeline_rounded,
                  iconColor: AppColors.primary,
                  title: l.orgPatientTimeline,
                  emptyText: l.orgPatientNoTimeline,
                  items: timeline,
                  itemBuilder: (item) => _TimelineTile(item: item),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Vitals ───────────────────────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: _SectionCard(
                  icon: Icons.monitor_heart_rounded,
                  iconColor: AppColors.success,
                  title: l.orgPatientVitals,
                  emptyText: l.orgPatientNoVitals,
                  items: vitals,
                  itemBuilder: (item) => _VitalTile(item: item),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Pain ─────────────────────────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: _SectionCard(
                  icon: Icons.sentiment_dissatisfied_rounded,
                  iconColor: AppColors.warning,
                  title: l.orgPatientPain,
                  emptyText: l.orgPatientNoPain,
                  items: pain,
                  itemBuilder: (item) => _PainTile(item: item),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Appointments ─────────────────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: _SectionCard(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.accent,
                  title: l.orgPatientAppointments,
                  emptyText: l.orgPatientNoAppointments,
                  items: appointments,
                  itemBuilder: (item) => _AppointmentTile(item: item),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static List<Map<String, dynamic>> _castList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Banner
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppRadius.borderRadiusMd,
      child: Row(
        children: [
          Icon(Icons.visibility_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient Header Card
// ─────────────────────────────────────────────────────────────────────────────

class _PatientHeaderCard extends StatelessWidget {
  const _PatientHeaderCard({
    required this.patient,
    required this.orgPatient,
    required this.l,
  });

  final Map<String, dynamic> patient;
  final OrgPatient orgPatient;
  final AppLocalizations l;

  String get _initials {
    final name = orgPatient.patientName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  Color get _warnColor => switch (orgPatient.warnStatus) {
        OrgPatientWarnStatus.red => AppColors.error,
        OrgPatientWarnStatus.yellow => AppColors.warning,
        OrgPatientWarnStatus.green => AppColors.success,
        OrgPatientWarnStatus.unknown => AppColors.grey400,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diagnosis = orgPatient.diagnosis ?? '';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
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
                            orgPatient.patientName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (orgPatient.warnStatus !=
                            OrgPatientWarnStatus.unknown)
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _warnColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (orgPatient.patientEmail.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        orgPatient.patientEmail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          // ── Details row ──────────────────────────────────
          if (diagnosis.isNotEmpty)
            _DetailRow(
              icon: Icons.medical_information_rounded,
              label: 'Diagnose',
              value: diagnosis,
            ),
          if (orgPatient.opDate != null)
            _DetailRow(
              icon: Icons.event_rounded,
              label: 'OP',
              value: DateFormat('dd.MM.yyyy').format(orgPatient.opDate!),
            ),
          _DetailRow(
            icon: Icons.local_hospital_rounded,
            label: l.orgPatientDoctor,
            value: orgPatient.doctorName,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.emptyText,
    required this.items,
    required this.itemBuilder,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String emptyText;
  final List<Map<String, dynamic>> items;
  final Widget Function(Map<String, dynamic>) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    '${items.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Text(
              emptyText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...items.map(itemBuilder),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item Tiles
// ─────────────────────────────────────────────────────────────────────────────

class _RedFlagTile extends StatelessWidget {
  const _RedFlagTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = (item['severity'] ?? '').toString();
    final title = (item['title'] ?? '').toString();
    final createdAt = _parseDate(item['createdAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            size: 16,
            color: severity == 'high' ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (createdAt != null)
            Text(
              DateFormat('dd.MM.').format(createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (item['title'] ?? '').toString();
    final type = (item['type'] ?? '').toString();
    final status = (item['status'] ?? '').toString();
    final createdAt = _parseDate(item['createdAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            _timelineIcon(type),
            size: 16,
            color: status == 'done' ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (createdAt != null)
            Text(
              DateFormat('dd.MM.').format(createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  static IconData _timelineIcon(String type) => switch (type) {
        'medication' => Icons.medication_rounded,
        'exercise' => Icons.fitness_center_rounded,
        'appointment' => Icons.calendar_today_rounded,
        'vitals' => Icons.monitor_heart_rounded,
        'pain' => Icons.sentiment_dissatisfied_rounded,
        _ => Icons.circle_outlined,
      };
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = (item['type'] ?? '').toString();
    final value = item['value']?.toString() ?? '-';
    final unit = (item['unit'] ?? '').toString();
    final createdAt = _parseDate(item['createdAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.monitor_heart_rounded,
              size: 16, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Text(
            type,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '$value $unit',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (createdAt != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              DateFormat('dd.MM.').format(createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PainTile extends StatelessWidget {
  const _PainTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = (item['level'] as num?)?.toInt() ?? 0;
    final location = (item['location'] ?? '').toString();
    final createdAt = _parseDate(item['createdAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 16,
            color: level >= 7
                ? AppColors.error
                : level >= 4
                    ? AppColors.warning
                    : AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$level/10',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else
            const Spacer(),
          if (createdAt != null)
            Text(
              DateFormat('dd.MM.').format(createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (item['title'] ?? '').toString();
    final dateTime = _parseDate(item['dateTime']);
    final location = (item['location'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location.isNotEmpty)
                  Text(
                    location,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (dateTime != null)
            Text(
              DateFormat('dd.MM. HH:mm').format(dateTime),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
