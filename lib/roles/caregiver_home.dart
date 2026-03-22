import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../features/observations/data/observation_repository.dart';
import '../features/observations/domain/observation_entry.dart';
import '../features/pro/data/entitlement_service.dart';
import '../features/pro/domain/entitlement.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../firebase/firebase_paths.dart';
import '../main.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';

class CaregiverHome extends StatefulWidget {
  const CaregiverHome({super.key});

  @override
  State<CaregiverHome> createState() => _CaregiverHomeState();
}

class _CaregiverHomeState extends State<CaregiverHome> {
  int _currentIndex = 0;
  String? _linkedPatientId;
  bool _loadingPatient = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedPatient();
  }

  Future<void> _loadLinkedPatient() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final linksQuery = await FirebaseFirestore.instance
          .collectionGroup('links')
          .where('linkedUid', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .where('linkType', isEqualTo: 'caregiver')
          .limit(1)
          .get();

      if (linksQuery.docs.isNotEmpty) {
        final linkDoc = linksQuery.docs.first;
        // Path: patients/{patientId}/links/{linkId}
        final patientId = linkDoc.reference.parent.parent?.id;
        if (mounted) {
          setState(() {
            _linkedPatientId = patientId;
            _loadingPatient = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingPatient = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPatient = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPatient) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_linkedPatientId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Begleiter')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Noch kein Patient verknüpft.\n'
                  'Bitte lasse dich über einen Einladungscode verbinden.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async => AuthService().signOut(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screens = <Widget>[
      _CaregiverTimelineTab(patientId: _linkedPatientId!),
      _CaregiverObservationsTab(patientId: _linkedPatientId!),
      const _CaregiverProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(index: _currentIndex, children: screens),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassBottomNavigationBar(
                items: const [
                  GlassNavItem(
                    icon: Icons.timeline_outlined,
                    activeIcon: Icons.timeline,
                    label: 'Plan',
                  ),
                  GlassNavItem(
                    icon: Icons.note_alt_outlined,
                    activeIcon: Icons.note_alt,
                    label: 'Beobachtungen',
                  ),
                  GlassNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profil',
                  ),
                ],
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only view of the patient's timeline.
class _CaregiverTimelineTab extends StatelessWidget {
  const _CaregiverTimelineTab({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patienten-Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => AuthService().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(FirestorePaths.timelineCollection(patientId))
            .orderBy('scheduledAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(userFacingError(snapshot.error!)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Noch keine Aufgaben im Plan.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = data['title'] as String? ?? '';
              final subtitle = data['subtitle'] as String? ?? '';
              final state = data['state'] as String? ?? 'planned';
              final isDone = state == 'done' || state == 'skipped';

              return Card(
                child: ListTile(
                  leading: Icon(
                    isDone
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isDone ? Colors.green : null,
                  ),
                  title: Text(
                    title,
                    style: isDone
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                  subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                  trailing: Text(
                    state.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDone ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Tab for viewing and creating caregiver observations.
class _CaregiverObservationsTab extends StatelessWidget {
  _CaregiverObservationsTab({required this.patientId});

  final String patientId;
  final ObservationRepository _repo = ObservationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Beobachtungen')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddObservationDialog(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: StreamBuilder<List<ObservationEntry>>(
        stream: _repo.watchObservations(patientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(userFacingError(snapshot.error!)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text('Noch keine Beobachtungen eingetragen.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  leading: _severityIcon(entry.severity),
                  title: Text(entry.text,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${entry.authorName} · ${_formatDate(entry.createdAt)}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddObservationDialog(BuildContext context) {
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
                      setDialogState(
                          () => selectedSeverity = selection.first);
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
                    try {
                      await _repo.addObservation(
                        patientId: patientId,
                        text: text,
                        severity: selectedSeverity,
                      );
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(userFacingError(e))),
                        );
                      }
                      return;
                    }
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
    switch (severity) {
      case ObservationSeverity.info:
        return const Icon(Icons.info_outline, color: Colors.blue);
      case ObservationSeverity.warning:
        return const Icon(Icons.warning_amber, color: Colors.orange);
      case ObservationSeverity.critical:
        return const Icon(Icons.error_outline, color: Colors.red);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

// ══════════════════════════════════════════════════════════════════════
// Caregiver Profile Tab
// ══════════════════════════════════════════════════════════════════════

class _CaregiverProfileTab extends StatefulWidget {
  const _CaregiverProfileTab();

  @override
  State<_CaregiverProfileTab> createState() => _CaregiverProfileTabState();
}

class _CaregiverProfileTabState extends State<_CaregiverProfileTab> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted) {
      setState(() {
        _userData = doc.data();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = FirebaseAuth.instance.currentUser;
    final name =
        _userData?['displayName'] as String? ?? user?.displayName ?? '';
    final email = user?.email ?? '';
    final proServices = ProServices.maybeOf(context);
    final entitlementService = proServices?.entitlementService;

    return GlassPage(
      title: 'Profil',
      titleIcon: AppIcons.profile,
      titleColor: AppColors.primary,
      showBackButton: false,
      horizontalPadding: AppSpacing.lg,
      children: [
        // Avatar header
        _CaregiverAvatarHeader(
          name: name,
          email: email,
          entitlementService: entitlementService,
          onBadgeTap: () {
            if (entitlementService != null &&
                !entitlementService.entitlement.value.isActive) {
              SmartPaywall.trigger(
                context: context,
                triggerContext: TriggerContext.settingsProButton,
              );
            }
          },
        ),

        const SizedBox(height: 20),

        // Subscription section
        if (entitlementService != null)
          _CaregiverSubscriptionCard(
            entitlementService: entitlementService,
            onUpgrade: () =>
                SmartPaywall.trigger(
                  context: context,
                  triggerContext: TriggerContext.settingsProButton,
                ),
            onManage: () =>
                Navigator.of(context).pushNamed('/pro-status'),
          ),

        const SizedBox(height: 20),

        // Account section
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konto',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings_rounded),
                title: const Text('Einstellungen'),
                trailing:
                    const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () =>
                    Navigator.of(context).pushNamed('/settings'),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout_rounded,
                    color: Colors.red.shade400),
                title: Text('Abmelden',
                    style: TextStyle(color: Colors.red.shade400)),
                onTap: () async => AuthService().signOut(),
              ),
            ],
          ),
        ),

        // Extra bottom padding for navigation bar
        const SizedBox(height: 100),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
// Caregiver Avatar Header
// ──────────────────────────────────────────────────────────────────────

class _CaregiverAvatarHeader extends StatelessWidget {
  const _CaregiverAvatarHeader({
    required this.name,
    required this.email,
    required this.entitlementService,
    required this.onBadgeTap,
  });

  final String name;
  final String email;
  final EntitlementService? entitlementService;
  final VoidCallback onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return GlassContainer(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: tt.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isNotEmpty ? name : 'Begleiter',
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: tt.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (entitlementService != null)
            ValueListenableBuilder<Entitlement>(
              valueListenable: entitlementService!.entitlement,
              builder: (_, ent, _) {
                final isPro = ent.isActive;
                return GestureDetector(
                  onTap: onBadgeTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPro
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.textSecondary.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                    child: Text(
                      isPro ? '⭐ Pro' : 'Basis',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isPro
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
// Caregiver Subscription Card
// ──────────────────────────────────────────────────────────────────────

class _CaregiverSubscriptionCard extends StatelessWidget {
  const _CaregiverSubscriptionCard({
    required this.entitlementService,
    required this.onUpgrade,
    required this.onManage,
  });

  final EntitlementService entitlementService;
  final VoidCallback onUpgrade;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Entitlement>(
      valueListenable: entitlementService.entitlement,
      builder: (context, ent, _) {
        return ent.isActive
            ? _buildProCard(context, ent)
            : _buildFreeCard(context);
      },
    );
  }

  Widget _buildProCard(BuildContext context, Entitlement ent) {
    final tt = Theme.of(context).textTheme;
    String planLabel = 'Pro';
    if (ent.proProductId != null) {
      planLabel = ent.proProductId!.contains('yearly')
          ? 'Pro – Jahresabo'
          : 'Pro – Monatsabo';
    }

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  planLabel,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onManage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: AppRadius.borderRadiusLg,
                  ),
                  child: Text(
                    'Verwalten',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (ent.proExpiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Gültig bis ${ent.proExpiresAt!.day.toString().padLeft(2, '0')}.${ent.proExpiresAt!.month.toString().padLeft(2, '0')}.${ent.proExpiresAt!.year}',
              style: tt.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFreeCard(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIcon(icon: AppIcons.packageBox, color: AppIcons.packageBoxColor, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Basis',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onUpgrade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: AppRadius.borderRadiusLg,
                  ),
                  child: Text(
                    'Pro entdecken',
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade für erweiterte Funktionen.',
            style: tt.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
