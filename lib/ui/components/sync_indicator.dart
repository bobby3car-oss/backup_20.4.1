import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../sync/sync_status_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';
import '../theme/glass.dart';
import 'glass_container.dart';

/// Small cloud icon that reflects the current sync status.
///
/// - Green  = synced
/// - Yellow = syncing (with rotation animation)
/// - Red    = offline
///
/// Tapping shows a tooltip with the pending-ops count.
class SyncIndicator extends StatefulWidget {
  const SyncIndicator({super.key});

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    SyncStatusService.instance.status.addListener(_onStatusChanged);
    _onStatusChanged();
  }

  void _onStatusChanged() {
    if (!mounted) return;
    if (SyncStatusService.instance.status.value == SyncStatus.syncing) {
      _spin.repeat();
    } else {
      _spin.stop();
      _spin.reset();
    }
  }

  @override
  void dispose() {
    SyncStatusService.instance.status.removeListener(_onStatusChanged);
    _spin.dispose();
    super.dispose();
  }

  void _showDetails(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = SyncStatusService.instance.pendingCount.value;
    final status = SyncStatusService.instance.status.value;

    final String message;
    switch (status) {
      case SyncStatus.synced:
        message = l?.syncIndicatorSynced ?? 'Alles synchronisiert';
      case SyncStatus.syncing:
        message = l?.syncIndicatorSyncing(count) ??
            '$count Einträge warten auf Sync';
      case SyncStatus.offline:
        message = count > 0
            ? (l?.syncIndicatorOfflineWithCount(count) ??
                'Offline – $count Einträge warten auf Sync')
            : (l?.syncIndicatorOffline ?? 'Offline');
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(_iconForStatus(status), color: _colorForStatus(status), size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l?.syncIndicatorTitle ?? 'Synchronisation',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l?.commonBack ?? 'OK'),
          ),
        ],
      ),
    );
  }

  static IconData _iconForStatus(SyncStatus s) {
    switch (s) {
      case SyncStatus.synced:
        return Icons.cloud_done_rounded;
      case SyncStatus.syncing:
        return Icons.cloud_sync_rounded;
      case SyncStatus.offline:
        return Icons.cloud_off_rounded;
    }
  }

  static Color _colorForStatus(SyncStatus s) {
    switch (s) {
      case SyncStatus.synced:
        return AppColors.success;
      case SyncStatus.syncing:
        return AppColors.warning;
      case SyncStatus.offline:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncStatus>(
      valueListenable: SyncStatusService.instance.status,
      builder: (context, status, _) {
        final color = _colorForStatus(status);
        final icon = _iconForStatus(status);

        Widget iconWidget = Icon(icon, size: 20, color: color);

        if (status == SyncStatus.syncing) {
          iconWidget = RotationTransition(
            turns: _spin,
            child: Icon(Icons.sync_rounded, size: 20, color: color),
          );
        }

        return GestureDetector(
          onTap: () => _showDetails(context),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
            variant: GlassVariant.thin,
            elevation: GlassElevation.low,
            child: iconWidget,
          ),
        );
      },
    );
  }
}
