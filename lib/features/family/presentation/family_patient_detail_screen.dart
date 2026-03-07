import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../../observations/data/observation_repository.dart';
import '../../observations/domain/observation_entry.dart';
import '../data/family_repository.dart';
import '../domain/family_visibility.dart';
import '../domain/linked_family_patient.dart';

/// Detail view for one patient.
///
/// Shows data sections based on the [FamilyVisibility] permissions
/// the patient has granted. Each section is a collapsible card.
class FamilyPatientDetailScreen extends StatefulWidget {
  const FamilyPatientDetailScreen({super.key, required this.patient});

  final LinkedFamilyPatient patient;

  @override
  State<FamilyPatientDetailScreen> createState() =>
      _FamilyPatientDetailScreenState();
}

class _FamilyPatientDetailScreenState extends State<FamilyPatientDetailScreen> {
  final _repo = FamilyRepository();
  late FamilyVisibility _visibility;

  @override
  void initState() {
    super.initState();
    _visibility = widget.patient.visibility;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;

    return GlassPage(
      title: p.patientName,
      titleEmoji: '🏥',
      titleColor: AppColors.primary,
      showBackButton: true,
      horizontalPadding: AppSpacing.lg,
      children: [
        // Patient info header
        _PatientHeader(patient: p),
        const SizedBox(height: AppSpacing.xxl),

        // Data sections based on visibility
        if (_visibility.timeline) ...[
          _SectionHeader(icon: Icons.checklist_rounded, title: 'Aufgaben & Plan'),
          const SizedBox(height: AppSpacing.sm),
          _TimelineSection(patientId: p.patientId),
          const SizedBox(height: AppSpacing.xxl),
        ],

        if (_visibility.observations) ...[
          _SectionHeader(
            icon: Icons.note_alt_outlined,
            title: 'Beobachtungen',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ObservationsSection(patientId: p.patientId),
          const SizedBox(height: AppSpacing.xxl),
        ],

        if (_visibility.vitals) ...[
          _SectionHeader(
            icon: Icons.monitor_heart_outlined,
            title: 'Vitalwerte',
          ),
          const SizedBox(height: AppSpacing.sm),
          _GenericDataSection(
            stream: _repo.watchVitals(p.patientId),
            emptyMessage: 'Keine Vitalwerte vorhanden.',
            itemBuilder: (data) => _VitalTile(data: data),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],

        if (_visibility.pain) ...[
          _SectionHeader(icon: Icons.healing_rounded, title: 'Schmerztagebuch'),
          const SizedBox(height: AppSpacing.sm),
          _GenericDataSection(
            stream: _repo.watchPain(p.patientId),
            emptyMessage: 'Keine Schmerzeinträge vorhanden.',
            itemBuilder: (data) => _PainTile(data: data),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],

        if (_visibility.wounds) ...[
          _SectionHeader(
            icon: Icons.photo_camera_outlined,
            title: 'Wunddokumentation',
          ),
          const SizedBox(height: AppSpacing.sm),
          _GenericDataSection(
            stream: _repo.watchWounds(p.patientId),
            emptyMessage: 'Keine Wundeinträge vorhanden.',
            itemBuilder: (data) => _WoundTile(data: data),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],

        if (_visibility.appointments) ...[
          _SectionHeader(
            icon: Icons.calendar_today_rounded,
            title: 'Termine',
          ),
          const SizedBox(height: AppSpacing.sm),
          _GenericDataSection(
            stream: _repo.watchAppointments(p.patientId),
            emptyMessage: 'Keine Termine vorhanden.',
            itemBuilder: (data) => _AppointmentTile(data: data),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],

        if (_visibility.redFlags) ...[
          _SectionHeader(
            icon: Icons.flag_rounded,
            title: 'Warnhinweise',
          ),
          const SizedBox(height: AppSpacing.sm),
          _GenericDataSection(
            stream: _repo.watchRedFlags(p.patientId),
            emptyMessage: 'Keine Warnhinweise.',
            itemBuilder: (data) => _RedFlagTile(data: data),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],

        // Messages section (always visible)
        _SectionHeader(icon: Icons.chat_outlined, title: 'Nachrichten'),
        const SizedBox(height: AppSpacing.sm),
        _MessagesSection(patientId: p.patientId),

        const SizedBox(height: 100), // bottom padding
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Patient Header
// ═════════════════════════════════════════════════════════════════════════════

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient});

  final LinkedFamilyPatient patient;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              patient.avatarInitials,
              style: tt.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.patientName,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (patient.opType != null)
                  Text(
                    patient.opType!,
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section Header
// ═════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Timeline Section
// ═════════════════════════════════════════════════════════════════════════════

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.timelineCollection(patientId))
          .orderBy('scheduledAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorRow(message: '${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _EmptyRow(message: 'Noch keine Aufgaben im Plan.');
        }

        return GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              for (var i = 0; i < docs.length && i < 10; i++)
                _timelineItem(context, docs[i].data()),
              if (docs.length > 10)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    '+ ${docs.length - 10} weitere Aufgaben',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineItem(BuildContext context, Map<String, dynamic> data) {
    final title = data['title'] as String? ?? '';
    final state = data['state'] as String? ?? 'planned';
    final isDone = state == 'done' || state == 'skipped';

    return ListTile(
      dense: true,
      leading: Icon(
        isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: isDone ? AppColors.success : AppColors.grey400,
        size: 20,
      ),
      title: Text(
        title,
        style: isDone
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: AppColors.textSecondary,
              )
            : null,
      ),
      trailing: _StateBadge(state: state),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Observations Section (read + write)
// ═════════════════════════════════════════════════════════════════════════════

class _ObservationsSection extends StatelessWidget {
  _ObservationsSection({required this.patientId});

  final String patientId;
  final ObservationRepository _repo = ObservationRepository();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<List<ObservationEntry>>(
          stream: _repo.watchObservations(patientId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorRow(message: '${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data!;
            if (entries.isEmpty) {
              return _EmptyRow(message: 'Noch keine Beobachtungen.');
            }

            return GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  for (var i = 0; i < entries.length && i < 10; i++)
                    ListTile(
                      dense: true,
                      leading: _severityIcon(entries[i].severity),
                      title: Text(
                        entries[i].text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${entries[i].authorName} · ${_formatDate(entries[i].createdAt)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        GlassButton(
          onPressed: () => _showAddObservation(context),
          label: 'Beobachtung hinzufügen',
          icon: Icons.add_rounded,
          variant: GlassButtonVariant.secondary,
          expand: true,
        ),
      ],
    );
  }

  void _showAddObservation(BuildContext context) {
    final textController = TextEditingController();
    var selectedSeverity = ObservationSeverity.info;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Neue Beobachtung'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Beobachtung',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ObservationSeverity>(
                    segments: const [
                      ButtonSegment(
                        value: ObservationSeverity.info,
                        label: Text('Info'),
                        icon: Icon(Icons.info_outline),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.warning,
                        label: Text('Warnung'),
                        icon: Icon(Icons.warning_amber),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.critical,
                        label: Text('Kritisch'),
                        icon: Icon(Icons.error_outline),
                      ),
                    ],
                    selected: {selectedSeverity},
                    onSelectionChanged: (selection) {
                      setDialogState(() => selectedSeverity = selection.first);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () async {
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    await _repo.addObservation(
                      patientId: patientId,
                      text: text,
                      severity: selectedSeverity,
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _severityIcon(ObservationSeverity severity) {
    return switch (severity) {
      ObservationSeverity.info =>
        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
      ObservationSeverity.warning =>
        const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
      ObservationSeverity.critical =>
        const Icon(Icons.error_outline, color: Colors.red, size: 20),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Messages Section
// ═════════════════════════════════════════════════════════════════════════════

class _MessagesSection extends StatefulWidget {
  const _MessagesSection({required this.patientId});

  final String patientId;

  @override
  State<_MessagesSection> createState() => _MessagesSectionState();
}

class _MessagesSectionState extends State<_MessagesSection> {
  final _repo = FamilyRepository();
  final _textCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Message list
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _repo.watchMessages(widget.patientId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return _EmptyRow(message: 'Noch keine Nachrichten.');
            }

            return GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  for (var i = 0; i < docs.length && i < 20; i++)
                    _messageTile(context, docs[i].data()),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        // Compose
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nachricht schreiben...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _repo.sendMessage(
        patientId: widget.patientId,
        text: text,
      );
      _textCtrl.clear();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  Widget _messageTile(BuildContext context, Map<String, dynamic> data) {
    final text = data['text'] as String? ?? '';
    final author = data['authorName'] as String? ?? '';
    final created = data['createdAt'];
    String time = '';
    if (created is Timestamp) {
      final dt = created.toDate();
      time = '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}. '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }

    return ListTile(
      dense: true,
      title: Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$author · $time',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Generic Data Section (for vitals, pain, wounds, appointments, red flags)
// ═════════════════════════════════════════════════════════════════════════════

class _GenericDataSection extends StatelessWidget {
  const _GenericDataSection({
    required this.stream,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final String emptyMessage;
  final Widget Function(Map<String, dynamic> data) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorRow(message: '${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _EmptyRow(message: emptyMessage);
        }

        return GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              for (var i = 0; i < docs.length && i < 10; i++)
                itemBuilder(docs[i].data()),
            ],
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Data Item Tiles
// ═════════════════════════════════════════════════════════════════════════════

class _VitalTile extends StatelessWidget {
  const _VitalTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final systolic = data['systolic'] ?? '';
    final diastolic = data['diastolic'] ?? '';
    final pulse = data['pulse'] ?? '';
    final temp = data['temperature'];
    final measured = data['measuredAt'];
    String time = '';
    if (measured is Timestamp) {
      final dt = measured.toDate();
      time =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}. ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return ListTile(
      dense: true,
      leading:
          const Icon(Icons.monitor_heart_outlined, size: 20, color: AppColors.primary),
      title: Text('$systolic/$diastolic mmHg · $pulse bpm'),
      subtitle: Text(
        '${temp != null ? '$temp°C · ' : ''}$time',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _PainTile extends StatelessWidget {
  const _PainTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final level = data['level'] ?? data['intensity'] ?? 0;
    final note = data['note'] as String? ?? '';
    final recorded = data['recordedAt'];
    String time = '';
    if (recorded is Timestamp) {
      final dt = recorded.toDate();
      time =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}. ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.healing_rounded,
        size: 20,
        color: (level as num) >= 7 ? AppColors.error : AppColors.warning,
      ),
      title: Text('Schmerzlevel: $level/10'),
      subtitle: Text(
        '${note.isNotEmpty ? '$note · ' : ''}$time',
        style: Theme.of(context).textTheme.labelSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _WoundTile extends StatelessWidget {
  const _WoundTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final note = data['note'] as String? ?? data['description'] as String? ?? '';
    final created = data['createdAt'];
    String time = '';
    if (created is Timestamp) {
      final dt = created.toDate();
      time =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    }

    return ListTile(
      dense: true,
      leading:
          const Icon(Icons.photo_camera_outlined, size: 20, color: AppColors.accent),
      title: Text(note.isNotEmpty ? note : 'Wunddokumentation'),
      subtitle: Text(time, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Termin';
    final dateTime = data['dateTime'];
    String time = '';
    if (dateTime is Timestamp) {
      final dt = dateTime.toDate();
      time =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return ListTile(
      dense: true,
      leading: const Icon(Icons.calendar_today_rounded,
          size: 20, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(time, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _RedFlagTile extends StatelessWidget {
  const _RedFlagTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? data['text'] as String? ?? '';
    final severity = data['severity'] as String? ?? 'medium';
    final color = severity == 'high' ? AppColors.error : AppColors.warning;

    return ListTile(
      dense: true,
      leading: Icon(Icons.flag_rounded, size: 20, color: color),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ═════════════════════════════════════════════════════════════════════════════

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});
  final String state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      'done' => ('Erledigt', AppColors.success),
      'skipped' => ('Übersprungen', AppColors.grey500),
      'due' || 'inProgress' => ('Fällig', AppColors.warning),
      _ => ('Geplant', AppColors.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text('Fehler: $message',
          style: TextStyle(color: AppColors.error, fontSize: 12)),
    );
  }
}
