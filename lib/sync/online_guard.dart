import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'connectivity_service.dart';

/// Returns `true` if the device is online. When offline, shows a dialog
/// informing the user that this feature requires an internet connection.
Future<bool> requireOnline(BuildContext context) async {
  if (ConnectivityService.instance.isOnline.value) return true;

  final l = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l?.connectivityRequiredTitle ?? 'Keine Internetverbindung'),
      content: Text(
        l?.connectivityRequiredMessage ??
            'Diese Funktion benötigt eine Internetverbindung. '
                'Bitte stelle eine Verbindung her und versuche es erneut.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l?.commonBack ?? 'OK'),
        ),
      ],
    ),
  );
  return false;
}
