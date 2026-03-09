import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bella_chat_overlay.dart';
import 'bella_fab.dart';
import 'bella_overlay_controller.dart';

/// Wraps any child widget with the Bella AI floating button and chat
/// overlay.  Placed inside [MaterialApp.builder] so Bella appears on
/// every screen — including pushed routes.
///
/// The FAB and overlay are only shown when a user is signed in (i.e.
/// not on login/signup/onboarding screens).
class BellaOverlayWrapper extends StatefulWidget {
  const BellaOverlayWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<BellaOverlayWrapper> createState() => _BellaOverlayWrapperState();
}

class _BellaOverlayWrapperState extends State<BellaOverlayWrapper> {
  final _controller = BellaOverlayController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isSignedIn = snapshot.data != null;

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // The actual app content (navigator, screens, etc.)
              widget.child,

              // Only show Bella when the user is authenticated.
              if (isSignedIn) ...[
              // Chat overlay (behind FAB, above content).
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  if (!_controller.isOpen) return const SizedBox.shrink();
                  return BellaChatOverlay(controller: _controller);
                },
              ),

              // Floating 🐰 button.
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  if (_controller.isOpen) return const SizedBox.shrink();
                  return BellaFab(controller: _controller);
                },
              ),
            ],
          ],
          ),
        );
      },
    );
  }
}
