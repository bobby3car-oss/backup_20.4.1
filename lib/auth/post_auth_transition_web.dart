import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';

/// On web, a full page reload is the most reliable way to transition after
/// authentication.  Firebase Auth persists the session to IndexedDB; the
/// reload picks it up and AuthGate bootstraps cleanly.
Future<void> finishPostAuthTransition(BuildContext context) async {
  html.window.location.reload();
  // The page is reloading — suspend so callers don't continue.
  await Completer<void>().future;
}

Future<void> reloadCurrentPage() async {
  html.window.location.reload();
  // The page is reloading — suspend so callers don't continue.
  await Completer<void>().future;
}