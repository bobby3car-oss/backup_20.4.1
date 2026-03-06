import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/milestone.dart';
import '../domain/recovery_event.dart';
import '../domain/xp_config.dart';
import '../gamification_service.dart';
import 'milestone_overlay.dart';

/// Wraps a child widget and listens to gamification events.
///
/// Shows [MilestoneOverlay] celebrations for level-ups, badge unlocks
/// and milestone completions.
///
/// Place this once near the root of the widget tree (e.g. inside the
/// shell / home scaffold) so overlays can be shown from any tab.
class RecoveryRewardListener extends StatefulWidget {
  const RecoveryRewardListener({
    super.key,
    required this.service,
    required this.child,
  });

  final GamificationService service;
  final Widget child;

  @override
  State<RecoveryRewardListener> createState() => _RecoveryRewardListenerState();
}

class _RecoveryRewardListenerState extends State<RecoveryRewardListener> {
  StreamSubscription<List<RecoveryEvent>>? _sub;
  int _highestLevelSeen = 0;
  final Set<String> _seenBadges = {};
  final Set<String> _seenMilestones = {};
  bool _isInitialized = false;
  bool _showingOverlay = false;
  final _overlayQueue = <_OverlayRequest>[];

  @override
  void initState() {
    super.initState();
    _initializeBaseline();
  }

  Future<void> _initializeBaseline() async {
    final state = await widget.service.getState();
    _highestLevelSeen = state.level;
    _seenBadges.addAll(state.badges.map((b) => b.id));
    for (final m in state.milestones) {
      if (m.status == MilestoneStatus.completed) {
        _seenMilestones.add(m.milestoneId);
      }
    }
    _isInitialized = true;

    _sub = widget.service.watchTodayEvents().listen(_onEvents);
  }

  void _onEvents(List<RecoveryEvent> events) {
    if (!_isInitialized || !mounted) return;

    for (final event in events) {
      switch (event.type) {
        case RecoveryEventType.levelUp:
          // Extract level from title: "Level X erreicht!"
          final match = RegExp(r'Level\s+(\d+)').firstMatch(event.title);
          if (match != null) {
            final newLevel = int.tryParse(match.group(1)!) ?? 0;
            if (newLevel > _highestLevelSeen) {
              _highestLevelSeen = newLevel;
              _enqueueOverlay(_OverlayRequest(
                title: event.title,
                subtitle: event.subtitle ?? LevelNames.forLevel(newLevel),
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF5856D6),
                xpAwarded: null,
              ));
            }
          }

        case RecoveryEventType.badgeEarned:
          final badgeId = event.relatedBadgeId;
          if (badgeId != null && !_seenBadges.contains(badgeId)) {
            _seenBadges.add(badgeId);
            final def = BadgeCatalog.byId(badgeId);
            _enqueueOverlay(_OverlayRequest(
              title: event.title,
              subtitle: event.subtitle ?? '',
              icon: def?.icon ?? Icons.military_tech_rounded,
              iconColor: def?.color ?? const Color(0xFFFF9500),
              xpAwarded: event.xpDelta > 0 ? event.xpDelta : null,
            ));
          }

        case RecoveryEventType.milestoneReached:
          final msId = event.relatedMilestoneId;
          if (msId != null && !_seenMilestones.contains(msId)) {
            _seenMilestones.add(msId);
            final def = MilestoneCatalog.byId(msId);
            _enqueueOverlay(_OverlayRequest(
              title: event.title,
              subtitle: event.subtitle ?? '',
              icon: def?.icon ?? Icons.emoji_events_rounded,
              iconColor: def?.color ?? const Color(0xFFFF9500),
              xpAwarded: event.xpDelta > 0 ? event.xpDelta : null,
            ));
          }

        default:
          break;
      }
    }
  }

  void _enqueueOverlay(_OverlayRequest req) {
    _overlayQueue.add(req);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_showingOverlay || _overlayQueue.isEmpty || !mounted) return;
    _showingOverlay = true;

    final req = _overlayQueue.removeAt(0);
    await MilestoneOverlay.show(
      context,
      title: req.title,
      subtitle: req.subtitle,
      icon: req.icon,
      iconColor: req.iconColor,
      xpAwarded: req.xpAwarded,
    );

    _showingOverlay = false;
    if (_overlayQueue.isNotEmpty && mounted) {
      // Brief pause between consecutive overlays
      await Future.delayed(const Duration(milliseconds: 400));
      _processQueue();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _OverlayRequest {
  const _OverlayRequest({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.xpAwarded,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final int? xpAwarded;
}
