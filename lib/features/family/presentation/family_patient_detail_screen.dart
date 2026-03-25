import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../../observations/data/observation_repository.dart';
import '../../observations/domain/observation_entry.dart';
import '../data/family_repository.dart';
import '../domain/family_visibility.dart';
import '../domain/linked_family_patient.dart';

/// Detail view for one patient – tab-based layout matching the doctor
/// interface. Each tab is shown only when the corresponding
/// [FamilyVisibility] permission is granted by the patient.
class FamilyPatientDetailScreen extends StatefulWidget {
  const FamilyPatientDetailScreen({super.key, required this.patient});

  final LinkedFamilyPatient patient;

  @override
  State<FamilyPatientDetailScreen> createState() =>
      _FamilyPatientDetailScreenState();
}

class _FamilyPatientDetailScreenState extends State<FamilyPatientDetailScreen> {
  final _repo = FamilyRepository();
  late final Stream<FamilyVisibility> _visibilityStream;

  @override
  void initState() {
    super.initState();
    _visibilityStream = _repo
        .watchVisibility(widget.patient.patientId)
        .distinct();
  }

  _OpData? get _opData {
    final opDate = widget.patient.opDate;
    if (opDate == null) return null;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final opDay = DateTime(opDate.year, opDate.month, opDate.day);
    return _OpData(
      daysOffset: opDay.difference(today).inDays,
      opDate: opDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final opData = _opData;
    final statusColor = opData?.statusColor ?? AppColors.primary;

    return StreamBuilder<FamilyVisibility>(
      stream: _visibilityStream,
      initialData: widget.patient.visibility,
      builder: (context, visSnap) {
        final visibility = visSnap.data ?? widget.patient.visibility;

    // Build tabs based on visibility
    final tabs = <Tab>[];
    final tabViews = <Widget>[];

    if (visibility.timeline) {
      tabs.add(const Tab(
        icon: Icon(Icons.checklist_rounded, size: 20),
        text: 'Aufgaben',
      ));
      tabViews.add(_TabBody(
        child: _TimelineSection(patientId: p.patientId),
      ));
    }
    if (visibility.observations) {
      tabs.add(const Tab(
        icon: Icon(Icons.note_alt_outlined, size: 20),
        text: 'Notizen',
      ));
      tabViews.add(_TabBody(
        child: _ObservationsSection(patientId: p.patientId),
      ));
    }
    if (visibility.vitals) {
      tabs.add(const Tab(
        icon: Icon(Icons.monitor_heart_outlined, size: 20),
        text: 'Vitalwerte',
      ));
      tabViews.add(_TabBody(
        child: _GenericDataSection(
          stream: _repo.watchVitals(p.patientId),
          emptyMessage: 'Keine Vitalwerte vorhanden.',
          itemBuilder: (data) => _VitalTile(data: data),
        ),
      ));
    }
    if (visibility.pain) {
      tabs.add(const Tab(
        icon: Icon(Icons.healing_rounded, size: 20),
        text: 'Schmerz',
      ));
      tabViews.add(_TabBody(
        child: _GenericDataSection(
          stream: _repo.watchPain(p.patientId),
          emptyMessage: 'Keine Schmerzeinträge vorhanden.',
          itemBuilder: (data) => _PainTile(data: data),
        ),
      ));
    }
    if (visibility.wounds) {
      tabs.add(const Tab(
        icon: Icon(Icons.photo_camera_outlined, size: 20),
        text: 'Wunden',
      ));
      tabViews.add(_TabBody(
        child: _GenericDataSection(
          stream: _repo.watchWounds(p.patientId),
          emptyMessage: 'Keine Wundeinträge vorhanden.',
          itemBuilder: (data) => _WoundTile(data: data),
        ),
      ));
    }
    if (visibility.appointments) {
      tabs.add(const Tab(
        icon: Icon(Icons.calendar_today_rounded, size: 20),
        text: 'Termine',
      ));
      tabViews.add(_TabBody(
        child: _GenericDataSection(
          stream: _repo.watchAppointments(p.patientId),
          emptyMessage: 'Keine Termine vorhanden.',
          itemBuilder: (data) => _AppointmentTile(data: data),
        ),
      ));
    }
    if (visibility.redFlags) {
      tabs.add(const Tab(
        icon: Icon(Icons.flag_rounded, size: 20),
        text: 'Warnungen',
      ));
      tabViews.add(_TabBody(
        child: _GenericDataSection(
          stream: _repo.watchRedFlags(p.patientId),
          emptyMessage: 'Keine Warnhinweise.',
          itemBuilder: (data) => _RedFlagTile(data: data),
        ),
      ));
    }
    if (visibility.medications) {
      tabs.add(const Tab(
        icon: Icon(Icons.medication_outlined, size: 20),
        text: 'Medikamente',
      ));
      tabViews.add(_TabBody(
        child: _GenericDataSection(
          stream: _repo.watchMedications(p.patientId),
          emptyMessage: 'Keine Medikamente vorhanden.',
          itemBuilder: (data) => _MedicationTile(data: data),
        ),
      ));
    }
    if (visibility.documents) {
      tabs.add(const Tab(
        icon: Icon(Icons.description_outlined, size: 20),
        text: 'Dokumente',
      ));
      tabViews.add(_TabBody(
        child: _GenericDataSection(
          stream: _repo.watchDocuments(p.patientId),
          emptyMessage: 'Keine Dokumente vorhanden.',
          itemBuilder: (data) => _DocumentTile(data: data),
        ),
      ));
    }

    // Messages tab – always shown
    tabs.add(const Tab(
      icon: Icon(Icons.chat_outlined, size: 20),
      text: 'Nachrichten',
    ));
    tabViews.add(_MessagesTab(patientId: p.patientId, repo: _repo));

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: Column(
            children: [
              // ── Frosted glass header ─────────────────────────
              _FamilyGlassHeader(
                name: p.patientName,
                statusColor: statusColor,
                opData: opData,
                opType: p.opType,
                tabs: tabs,
                onBack: () => Navigator.of(context).pop(),
              ),

              // ── Tab body ────────────────────────────────────
              Expanded(child: TabBarView(children: tabViews)),
            ],
          ),
        ),
      ),
    );
      },  // StreamBuilder builder
    );  // StreamBuilder
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Tab Body wrapper
// ═════════════════════════════════════════════════════════════════════════════

class _TabBody extends StatelessWidget {
  const _TabBody({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// OP Data helper model
// ═════════════════════════════════════════════════════════════════════════════

class _OpData {
  const _OpData({required this.daysOffset, required this.opDate});

  final int daysOffset;
  final DateTime opDate;

  bool get isPreOp => daysOffset > 0;
  bool get isToday => daysOffset == 0;
  bool get isPostOp => daysOffset < 0;
  int get daysSinceOp => -daysOffset;

  double get recoveryProgress =>
      isPostOp ? (daysSinceOp / 42.0).clamp(0.0, 1.0) : 0.0;

  Color get statusColor {
    if (isToday) return AppColors.warning;
    if (isPreOp) return AppColors.primary;
    return AppColors.success;
  }

  String get phaseLabel {
    if (isToday) return 'OP-Tag';
    if (isPreOp) return 'Prä-OP';
    return 'Post-OP';
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
          return _ErrorRow(message: userFacingError(snapshot.error!));
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
              return _ErrorRow(message: userFacingError(snapshot.error!));
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
    ).then((_) => textController.dispose());
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
// Messages Tab (full-height with compose bar at bottom)
// ═════════════════════════════════════════════════════════════════════════════

class _MessagesTab extends StatefulWidget {
  const _MessagesTab({required this.patientId, required this.repo});

  final String patientId;
  final FamilyRepository repo;

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
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
        // Message list (fills available space)
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: widget.repo.watchMessages(widget.patientId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'Noch keine Nachrichten.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: docs.length,
                itemBuilder: (context, i) =>
                    _messageTile(context, docs[i].data()),
              );
            },
          ),
        ),
        // Compose bar pinned at bottom
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.grey300.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: GlassContainer(
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
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded,
                            color: AppColors.primary),
                  ),
                ],
              ),
            ),
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
      await widget.repo.sendMessage(
        patientId: widget.patientId,
        text: text,
      );
      _textCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nachricht konnte nicht gesendet werden.')),
        );
      }
      debugPrint('[FamilyPatientDetail] send error: $e');
    }
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
          return _ErrorRow(message: userFacingError(snapshot.error!));
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

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ??
        data['medicationName'] as String? ??
        'Medikament';
    final dosage = data['dosage'] as String? ?? '';
    final updated = data['updatedAt'] ?? data['takenAt'];
    String time = '';
    if (updated is Timestamp) {
      final dt = updated.toDate();
      time =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}. ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return ListTile(
      dense: true,
      leading: const Icon(Icons.medication_outlined,
          size: 20, color: AppColors.primary),
      title: Text(name),
      subtitle: Text(
        '${dosage.isNotEmpty ? '$dosage · ' : ''}$time',
        style: Theme.of(context).textTheme.labelSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title =
        data['title'] as String? ?? data['name'] as String? ?? 'Dokument';
    final created = data['createdAt'];
    String time = '';
    if (created is Timestamp) {
      final dt = created.toDate();
      time =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    }

    return ListTile(
      dense: true,
      leading: const Icon(Icons.description_outlined,
          size: 20, color: AppColors.accent),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(time, style: Theme.of(context).textTheme.labelSmall),
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
      child: Text(message,
          style: TextStyle(color: AppColors.error, fontSize: 12)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Frosted-glass tab header matching GlassPage style
// ─────────────────────────────────────────────────────────────────────────────

class _FamilyGlassHeader extends StatelessWidget {
  const _FamilyGlassHeader({
    required this.name,
    required this.statusColor,
    required this.opData,
    required this.tabs,
    required this.onBack,
    this.opType,
  });

  final String name;
  final Color statusColor;
  final _OpData? opData;
  final String? opType;
  final List<Tab> tabs;
  final VoidCallback onBack;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return '${dt.day}.${dt.month}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final tt = Theme.of(context).textTheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.92),
                AppColors.background.withValues(alpha: 0.78),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.white.withValues(alpha: 0.45),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row
              SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      // Back button
                      PressableScale(
                        onTap: () {
                          Haptic.light();
                          onBack();
                        },
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
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Status dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Name + meta
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (opData != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: AppRadius.borderRadiusPill,
                                    ),
                                    child: Text(
                                      opData!.phaseLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'OP: ${_formatDate(opData!.opDate)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (opType != null && opData == null)
                                  Text(
                                    opType!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                if (opData != null && opData!.isPostOp) ...[
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: AppRadius.borderRadiusPill,
                                      child: LinearProgressIndicator(
                                        value: opData!.recoveryProgress,
                                        minHeight: 4,
                                        backgroundColor:
                                            AppColors.grey300.withValues(alpha: 0.5),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(statusColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(opData!.recoveryProgress * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab bar
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: tabs,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
