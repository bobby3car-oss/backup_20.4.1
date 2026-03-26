import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/spacing.dart';

/// Displays a profile completeness percentage and a checklist of missing items.
class ProfileCompletenessCard extends StatefulWidget {
  const ProfileCompletenessCard({
    super.key,
    this.onNavigateToProfile,
  });

  final VoidCallback? onNavigateToProfile;

  @override
  State<ProfileCompletenessCard> createState() =>
      _ProfileCompletenessCardState();
}

class _ProfileCompletenessCardState extends State<ProfileCompletenessCard> {
  Map<String, dynamic>? _profileData;
  bool _loading = true;
  bool _hasNewOp = false;
  bool _dismissed = false;

  static const _prefKeyLastSeenOpDate = 'last_seen_op_date';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .doc(FirestorePaths.userDoc(uid))
          .get();
      final data = doc.data();
      await _checkNewOp(data);
      if (mounted) {
        setState(() {
          _profileData = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkNewOp(Map<String, dynamic>? data) async {
    if (data == null) return;
    final prevOps = data['previousOperations'];
    final hasPrevOps =
        (prevOps is List && prevOps.isNotEmpty) ||
        (prevOps is Map && prevOps.isNotEmpty);
    if (!hasPrevOps) return;

    final opDateTime = _extractOpDate(data);
    if (opDateTime == null) return;

    final prefs = await SharedPreferences.getInstance();
    final lastSeenMs = prefs.getInt(_prefKeyLastSeenOpDate);
    if (lastSeenMs == null ||
        opDateTime.millisecondsSinceEpoch > lastSeenMs) {
      if (mounted) setState(() => _hasNewOp = true);
    }
  }

  DateTime? _extractOpDate(Map<String, dynamic> data) {
    final raw = data['opDate'];
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  Future<void> _saveLastSeenOpDate() async {
    final data = _profileData;
    if (data == null) return;
    final opDateTime = _extractOpDate(data);
    if (opDateTime == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _prefKeyLastSeenOpDate,
      opDateTime.millisecondsSinceEpoch,
    );
  }

  Future<void> _dismiss() async {
    await _saveLastSeenOpDate();
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    final l = AppLocalizations.of(context)!;
    final checks = _buildChecks(l);
    final completed = checks.where((c) => c.done).length;
    final total = checks.length;
    final progress = total > 0 ? completed / total : 0.0;
    final percent = (progress * 100).round();

    // Hide if dismissed this session.
    if (_dismissed) return const SizedBox.shrink();

    // Hide at 100% unless there's a new op that needs attention.
    if (percent >= 100 && !_hasNewOp) return const SizedBox.shrink();

    final missing = checks.where((c) => !c.done).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l.profileCompleteness,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _colorForProgress(progress),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: _dismiss,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation(_colorForProgress(progress)),
            ),
          ),
          if (_hasNewOp) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Neue OP eingetragen – bitte aktualisiere dein Profil.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (missing.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.profileStillTodo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...missing.take(4).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle_outlined,
                          size: 14, color: AppColors.grey400),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )),
            if (missing.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${missing.length - 4} ${l.profileMoreItems}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
          if (widget.onNavigateToProfile != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                    _saveLastSeenOpDate();
                    widget.onNavigateToProfile?.call();
                  },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
                child: Text(l.profileComplete),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_ProfileCheck> _buildChecks(AppLocalizations l) {
    final data = _profileData ?? <String, dynamic>{};
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? '';

    return [
      _ProfileCheck(
        label: l.profileCheckName,
        done: name.trim().isNotEmpty,
      ),
      _ProfileCheck(
        label: l.profileCheckOpDate,
        done: _hasValue(data['opDate']),
      ),
      _ProfileCheck(
        label: l.profileCheckOpType,
        done: _hasStringValue(data['opType']),
      ),
      _ProfileCheck(
        label: l.profileCheckHospital,
        done: _hasStringValue(data['hospitalName']),
      ),
      _ProfileCheck(
        label: l.profileCheckDoctor,
        done: _hasStringValue(data['doctorName']),
      ),
      _ProfileCheck(
        label: l.profileCheckEmergencyContact,
        done: _hasStringValue(data['emergencyContactName']) &&
            _hasStringValue(data['emergencyContactPhone']),
      ),
      _ProfileCheck(
        label: l.profileCheckWeight,
        done: data['weight'] is num && (data['weight'] as num) > 0,
      ),
      _ProfileCheck(
        label: l.profileCheckHeight,
        done: data['height'] is num && (data['height'] as num) > 0,
      ),
    ];
  }

  bool _hasStringValue(dynamic value) =>
      value is String && value.trim().isNotEmpty;

  bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Timestamp) return true;
    return true;
  }

  Color _colorForProgress(double p) {
    if (p >= 0.8) return AppColors.success;
    if (p >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}

class _ProfileCheck {
  const _ProfileCheck({required this.label, required this.done});

  final String label;
  final bool done;
}
