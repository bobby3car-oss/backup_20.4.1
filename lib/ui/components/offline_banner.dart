import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../sync/connectivity_service.dart';

/// A slim banner displayed at the top of the screen when offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService.instance.isOnline,
      builder: (context, online, _) {
        if (online) return const SizedBox.shrink();

        final l = AppLocalizations.of(context);
        return Material(
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
                    l?.connectivityOfflineBanner ??
                        'Du bist offline. Änderungen werden synchronisiert, sobald du wieder online bist.',
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
        );
      },
    );
  }
}
