import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../sync/connectivity_service.dart';

/// A slim yellow banner that animates in/out when connectivity changes.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Set initial state without animating.
    if (!ConnectivityService.instance.isOnline.value) {
      _ctrl.value = 1.0;
    }
    ConnectivityService.instance.isOnline.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    if (ConnectivityService.instance.isOnline.value) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    ConnectivityService.instance.isOnline.removeListener(_onConnectivityChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3CD),
              border: Border(
                bottom: BorderSide(color: Color(0xFFFFD666), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 16,
                  color: Color(0xFF856404),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.connectivityOfflineBanner,
                    style: const TextStyle(
                      color: Color(0xFF856404),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
