import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/family/domain/family_visibility.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/pro_feature_gate_view.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../firebase/firebase_paths.dart';
import '../main.dart';
import '../ui/ui.dart';
import 'invite_success_dialog.dart';
import '../ui/theme/app_icons.dart';

// ── Data models ──────────────────────────────────────────────────────────────

enum CaregiverRole { partner, parent, child, friend, other }

extension CaregiverRoleMeta on CaregiverRole {
  String get label => switch (this) {
    CaregiverRole.partner => 'Partner/in',
    CaregiverRole.parent => 'Elternteil',
    CaregiverRole.child => 'Kind',
    CaregiverRole.friend => 'Freund/in',
    CaregiverRole.other => 'Sonstige',
  };

  IconData get icon => switch (this) {
    CaregiverRole.partner => Icons.favorite_rounded,
    CaregiverRole.parent => Icons.family_restroom_rounded,
    CaregiverRole.child => Icons.child_care_rounded,
    CaregiverRole.friend => Icons.people_rounded,
    CaregiverRole.other => Icons.person_rounded,
  };

  Color get color => switch (this) {
    CaregiverRole.partner => AppColors.error,
    CaregiverRole.parent => AppColors.primary,
    CaregiverRole.child => AppColors.success,
    CaregiverRole.friend => AppColors.accent,
    CaregiverRole.other => AppColors.grey600,
  };
}

enum InviteStatus { pending, accepted, expired }

extension InviteStatusMeta on InviteStatus {
  String get label => switch (this) {
    InviteStatus.pending => 'Ausstehend',
    InviteStatus.accepted => 'Angenommen',
    InviteStatus.expired => 'Abgelaufen',
  };

  Color get color => switch (this) {
    InviteStatus.pending => AppColors.warning,
    InviteStatus.accepted => AppColors.success,
    InviteStatus.expired => AppColors.grey500,
  };

  IconData get icon => switch (this) {
    InviteStatus.pending => Icons.schedule_rounded,
    InviteStatus.accepted => Icons.check_circle_rounded,
    InviteStatus.expired => Icons.cancel_rounded,
  };
}

class _Caregiver {
  const _Caregiver({
    required this.linkId,
    required this.name,
    required this.role,
    required this.email,
    required this.avatarInitials,
    required this.connectedSince,
  });
  final String linkId;
  final String name;
  final CaregiverRole role;
  final String email;
  final String avatarInitials;
  final String connectedSince;
}

class _Invitation {
  const _Invitation({
    required this.docId,
    required this.role,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });
  final String docId;
  final CaregiverRole role;
  final InviteStatus status;
  final String createdAt;
  final DateTime? expiresAt;
}

// ─────────────────────────────────────────────────────────────────────────────

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  List<_Caregiver> _caregivers = [];
  List<_Invitation> _invitations = [];
  bool _loading = true;

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      // Load active caregiver links
      final linksSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.linksCollection(uid))
          .where('linkType', isEqualTo: 'family')
          .get();

      final caregivers = <_Caregiver>[];
      for (final doc in linksSnap.docs) {
        final d = doc.data();
        final status = d['status'] as String? ?? '';
        if (status != 'active') continue;

        final roleStr = d['role'] as String? ?? 'other';
        final role = CaregiverRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => CaregiverRole.other,
        );
        final name = d['linkedName'] as String? ?? 'Unbekannt';
        final email = d['linkedEmail'] as String? ?? '';
        final initials = name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
        final created = d['createdAt'];
        String since = '';
        if (created is Timestamp) {
          final dt = created.toDate();
          since = 'Seit ${dt.day.toString().padLeft(2, '0')}.'
              '${dt.month.toString().padLeft(2, '0')}.${dt.year}';
        }
        caregivers.add(_Caregiver(
          linkId: doc.id,
          name: name,
          role: role,
          email: email,
          avatarInitials: initials.isEmpty ? '?' : initials,
          connectedSince: since,
        ));
      }

      // Load invitations from invites sub-collection
      final invitesSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.invitesCollection(uid))
          .where('linkType', isEqualTo: 'family')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final invitations = <_Invitation>[];
      for (final doc in invitesSnap.docs) {
        final d = doc.data();
        final statusStr = d['status'] as String? ?? 'pending';
        final invStatus = statusStr == 'expired'
            ? InviteStatus.expired
            : statusStr == 'accepted'
                ? InviteStatus.accepted
                : InviteStatus.pending;

        final roleStr = d['role'] as String? ?? 'other';
        final role = CaregiverRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => CaregiverRole.other,
        );

        final created = d['createdAt'];
        String createdStr = '';
        if (created is Timestamp) {
          final dt = created.toDate();
          createdStr = '${dt.day.toString().padLeft(2, '0')}.'
              '${dt.month.toString().padLeft(2, '0')}.${dt.year}';
        }

        DateTime? expiresAt;
        final exp = d['expiresAt'];
        if (exp is Timestamp) expiresAt = exp.toDate();

        // Mark client-side expired
        final effectiveStatus =
            (invStatus == InviteStatus.pending &&
                    expiresAt != null &&
                    expiresAt.isBefore(DateTime.now()))
                ? InviteStatus.expired
                : invStatus;

        invitations.add(_Invitation(
          docId: doc.id,
          role: role,
          status: effectiveStatus,
          createdAt: createdStr,
          expiresAt: expiresAt,
        ));
      }

      if (mounted) {
        setState(() {
          _caregivers = caregivers;
          _invitations = invitations;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPro) {
      return ProFeatureGateView(
        pageTitle: 'Angehörige',
        pageIcon: AppIcons.family,
        pageColor: const Color(0xFF34C759),
        heroIcon: AppIcons.caregiver,
        heroTitle: 'Gemeinsam durch die OP-Zeit',
        heroSubtitle:
            'Lade Angehörige ein, damit sie deinen Genesungsverlauf '
            'mitverfolgen können – Transparenz schafft Sicherheit für alle.',
        primaryCta: 'Jetzt Pro freischalten',
        onPrimaryTap: () {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.relativesFeature,
          );
        },
        benefits: const <(String, String)>[
          (
            'Begleiter einladen',
            'Partner, Eltern oder Freunde per Link einladen – sie sehen, was du teilst.',
          ),
          (
            'Sichtbarkeit steuern',
            'Du entscheidest, welche Daten deine Angehörigen sehen: Schmerz, Vitals, Termine und mehr.',
          ),
          (
            'Gemeinsam stark',
            'Deine Angehörigen bleiben informiert und können dich besser unterstützen.',
          ),
        ],
        preview: const _CaregiverLockedPreview(),
      );
    }

    if (_loading) {
      return GlassPage(
        title: 'Angehörige',
        titleIcon: AppIcons.family,
        titleColor: AppColors.success,
        children: const [
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    return GlassPage(
      title: 'Angehörige',
      titleIcon: AppIcons.family,
      titleColor: AppColors.success,
      children: [
        _SummaryCard(
          caregiverCount: _caregivers.length,
          pendingCount: _invitations
              .where((i) => i.status == InviteStatus.pending)
              .length,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _sectionTitle(context, 'Verbundene Angehörige'),
        const SizedBox(height: AppSpacing.md),
        if (_caregivers.isEmpty)
          _EmptyState(
            icon: Icons.people_outline_rounded,
            message: 'Noch keine Angehörigen verbunden.',
          )
        else
          for (var i = 0; i < _caregivers.length; i++) ...[
            _CaregiverCard(
              caregiver: _caregivers[i],
              onRemove: () => _confirmRemove(context, i),
              onVisibility: () => _showVisibilitySheet(context, i),
            ),
            if (i < _caregivers.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        const SizedBox(height: AppSpacing.xxl),
        _sectionTitle(context, 'Einladungen'),
        const SizedBox(height: AppSpacing.md),
        if (_invitations.isEmpty)
          _EmptyState(
            icon: Icons.mail_outline_rounded,
            message: 'Keine offenen Einladungen.',
          )
        else
          for (var i = 0; i < _invitations.length; i++) ...[
            _InvitationCard(
              invitation: _invitations[i],
              onResend: () => _createNewInvite(_invitations[i].role),
            ),
            if (i < _invitations.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        const SizedBox(height: AppSpacing.xxl),
        GlassButton(
          onPressed: () => _showInviteSheet(context),
          label: 'Angehörigen einladen',
          icon: Icons.person_add_rounded,
          expand: true,
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  void _confirmRemove(BuildContext context, int index) {
    final caregiver = _caregivers[index];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: const Icon(
                Icons.person_remove_rounded,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Zugang entfernen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${caregiver.name} verliert den Zugriff auf Ihre '
              'Gesundheitsdaten. Diese Aktion kann rückgängig gemacht '
              'werden, indem Sie erneut einladen.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GlassButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _removeCaregiver(index);
              },
              label: 'Entfernen',
              icon: Icons.delete_outline_rounded,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              onPressed: () => Navigator.of(ctx).pop(),
              label: 'Abbrechen',
              variant: GlassButtonVariant.ghost,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _removeCaregiver(int index) async {
    final caregiver = _caregivers[index];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Extract linkedUid from linkId format: {linkedUid}_family
    final linkedUid = caregiver.linkId.replaceAll('_family', '');

    try {
      await FirebaseFunctions.instance
          .httpsCallable('unlinkPatient')
          .call<Map<String, dynamic>>({
        'patientId': uid,
        'linkType': 'family',
        'linkedUid': linkedUid,
      });
      if (mounted) {
        setState(() => _caregivers.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${caregiver.name} wurde entfernt')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    }
  }

  void _showVisibilitySheet(BuildContext context, int index) {
    final caregiver = _caregivers[index];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final linkDocPath =
        '${FirestorePaths.linksCollection(uid)}/${caregiver.linkId}';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VisibilitySheet(
        linkDocPath: linkDocPath,
        caregiverName: caregiver.name,
      ),
    );
  }

  Future<void> _createNewInvite(CaregiverRole role) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('createInvite')
          .call<Map<String, dynamic>>({
        'patientId': uid,
        'linkType': 'family',
        'role': role.name,
        'permissions': {'read': true, 'write': false},
        'expiresInHours': 72,
      });

      final data = result.data;
      final code = data['code'] as String;
      final expiresAtStr = data['expiresAt'] as String;
      final expiresAt = DateTime.parse(expiresAtStr);

      setState(() => _loading = false);

      if (mounted) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => InviteSuccessDialog(
              code: code,
              expiresAt: expiresAt,
              roleLabel: role.label,
            ),
          ),
        );
        // Refresh list after returning
        _loadFromFirestore();
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    }
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteSheet(
        onInviteSent: (role) => _createNewInvite(role),
      ),
    );
  }
}

// ── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.caregiverCount,
    required this.pendingCount,
  });

  final int caregiverCount;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          _StatBubble(
            icon: Icons.people_rounded,
            color: AppColors.primary,
            value: '$caregiverCount',
            label: 'Verbunden',
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(width: 1, height: 44, color: AppColors.grey200),
          const SizedBox(width: AppSpacing.lg),
          _StatBubble(
            icon: Icons.mail_outline_rounded,
            color: AppColors.warning,
            value: '$pendingCount',
            label: 'Ausstehend',
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
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

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      borderRadius: AppRadius.borderRadiusXl,
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.grey400),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Caregiver card ───────────────────────────────────────────────────────────

class _CaregiverCard extends StatelessWidget {
  const _CaregiverCard({
    required this.caregiver,
    required this.onRemove,
    required this.onVisibility,
  });

  final _Caregiver caregiver;
  final VoidCallback onRemove;
  final VoidCallback onVisibility;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(
                initials: caregiver.avatarInitials,
                color: caregiver.role.color,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caregiver.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      caregiver.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _RoleBadge(role: caregiver.role),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                caregiver.connectedSince,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onVisibility,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Sichtbarkeit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.error,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Entfernen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ── Role badge ───────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final CaregiverRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: role.color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(role.icon, size: 14, color: role.color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            role.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: role.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Invitation card ──────────────────────────────────────────────────────────

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.onResend,
  });

  final _Invitation invitation;
  final VoidCallback onResend;

  String _expiryLabel() {
    final exp = invitation.expiresAt;
    if (exp == null) return '';
    if (invitation.status == InviteStatus.expired) return 'Abgelaufen';
    if (invitation.status == InviteStatus.accepted) return 'Angenommen';
    final remaining = exp.difference(DateTime.now());
    if (remaining.isNegative) return 'Abgelaufen';
    final h = remaining.inHours;
    if (h > 0) return 'Gültig für $h h';
    return 'Gültig für ${remaining.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = invitation.status == InviteStatus.pending;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: invitation.status.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Icon(
                  invitation.status.icon,
                  size: 22,
                  color: invitation.status.color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Einladung – ${invitation.role.label}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _expiryLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isPending
                            ? AppColors.warning
                            : AppColors.textSecondary,
                        fontWeight:
                            isPending ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: invitation.status.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  invitation.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: invitation.status.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Erstellt am ${invitation.createdAt}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (!isPending)
                GestureDetector(
                  onTap: onResend,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Erneut einladen',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Invite sheet ─────────────────────────────────────────────────────────────

class _InviteSheet extends StatefulWidget {
  const _InviteSheet({required this.onInviteSent});

  final ValueChanged<CaregiverRole> onInviteSent;

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  CaregiverRole _selectedRole = CaregiverRole.partner;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          top: AppSpacing.xxl,
          bottom: AppSpacing.xxl + bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: const Icon(
                Icons.person_add_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Angehörigen einladen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Wählen Sie eine Rolle und erstellen Sie eine Einladung.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxl),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Rolle auswählen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: CaregiverRole.values
                  .map(
                    (role) => _RoleChip(
                      role: role,
                      selected: role == _selectedRole,
                      onTap: () => setState(() => _selectedRole = role),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Method selection
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Einladungsmethode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.borderRadiusLg,
              child: Column(
                children: [
                  _MethodRow(
                    icon: Icons.vpn_key_rounded,
                    title: 'Einladungscode',
                    subtitle: 'Code zum manuellen Eingeben',
                    color: AppColors.accent,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Container(height: 1, color: AppColors.grey200),
                  ),
                  _MethodRow(
                    icon: Icons.qr_code_rounded,
                    title: 'QR-Code',
                    subtitle: 'Scannbarer Code zum Beitreten',
                    color: AppColors.success,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Container(height: 1, color: AppColors.grey200),
                  ),
                  _MethodRow(
                    icon: Icons.link_rounded,
                    title: 'Deep Link',
                    subtitle: 'Link zum direkten Öffnen der App',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            GlassButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onInviteSent(_selectedRole);
              },
              label: 'Einladung erstellen',
              icon: Icons.send_rounded,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Abbrechen',
              variant: GlassButtonVariant.ghost,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Role chip ────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final CaregiverRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? role.color.withValues(alpha: 0.12)
              : AppColors.white.withValues(alpha: 0.60),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? role.color.withValues(alpha: 0.40)
                : AppColors.grey300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              role.icon,
              size: 16,
              color: selected ? role.color : AppColors.grey500,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              role.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? role.color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Method row ───────────────────────────────────────────────────────────────

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: AppColors.success,
        ),
      ],
    );
  }
}

// ── Visibility settings sheet ────────────────────────────────────────────────

class _VisibilitySheet extends StatefulWidget {
  const _VisibilitySheet({
    required this.linkDocPath,
    required this.caregiverName,
  });

  final String linkDocPath;
  final String caregiverName;

  @override
  State<_VisibilitySheet> createState() => _VisibilitySheetState();
}

class _VisibilitySheetState extends State<_VisibilitySheet> {
  FamilyVisibility _visibility = const FamilyVisibility();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc(widget.linkDocPath)
          .get();
      final data = doc.data();
      if (mounted) {
        setState(() {
          _visibility = FamilyVisibility.fromMap(
            data?['visibility'] as Map<String, dynamic>?,
          );
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .doc(widget.linkDocPath)
          .update({'visibility': _visibility.toMap()});
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    }
  }

  void _toggle(String key, bool value) {
    setState(() {
      _visibility = switch (key) {
        'timeline' => _visibility.copyWith(timeline: value),
        'vitals' => _visibility.copyWith(vitals: value),
        'pain' => _visibility.copyWith(pain: value),
        'wounds' => _visibility.copyWith(wounds: value),
        'appointments' => _visibility.copyWith(appointments: value),
        'medications' => _visibility.copyWith(medications: value),
        'documents' => _visibility.copyWith(documents: value),
        'redFlags' => _visibility.copyWith(redFlags: value),
        'observations' => _visibility.copyWith(observations: value),
        _ => _visibility,
      };
    });
  }

  bool _getValue(String key) {
    return switch (key) {
      'timeline' => _visibility.timeline,
      'vitals' => _visibility.vitals,
      'pain' => _visibility.pain,
      'wounds' => _visibility.wounds,
      'appointments' => _visibility.appointments,
      'medications' => _visibility.medications,
      'documents' => _visibility.documents,
      'redFlags' => _visibility.redFlags,
      'observations' => _visibility.observations,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sichtbarkeit für ${widget.caregiverName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Wähle aus, welche Daten dieser Angehörige sehen darf.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              GlassContainer(
                child: Column(
                  children: [
                    for (final entry
                        in FamilyVisibility.categoryLabels.entries) ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(entry.value),
                        value: _getValue(entry.key),
                        onChanged: (v) => _toggle(entry.key, v),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            GlassButton(
              onPressed: _saving ? null : _save,
              label: _saving ? 'Speichern...' : 'Speichern',
              icon: Icons.check_rounded,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Abbrechen',
              variant: GlassButtonVariant.ghost,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ── Pro locked preview ───────────────────────────────────────────────────────

class _CaregiverLockedPreview extends StatelessWidget {
  const _CaregiverLockedPreview();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.medium,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CaregiverPreviewChip(
                  icon: Icons.person_add_rounded,
                  label: 'Einladen',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CaregiverPreviewChip(
                  icon: Icons.visibility_rounded,
                  label: 'Steuern',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CaregiverPreviewChip(
                  icon: Icons.family_restroom_rounded,
                  label: 'Begleiten',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey100.withValues(alpha: 0.55),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Text(
              'Vorschau: Angehörige per Link einladen, Rollen zuweisen '
              'und genau festlegen, welche Daten sie sehen dürfen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaregiverPreviewChip extends StatelessWidget {
  const _CaregiverPreviewChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
