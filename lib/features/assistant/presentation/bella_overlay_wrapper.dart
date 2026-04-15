import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_gate.dart';
import '../../../main.dart';
import '../../pro/data/entitlement_service.dart';
import '../../onboarding_tutorial/presentation/tutorial_keys.dart';
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
  String? _lastUid;
  EntitlementService? _entitlementService;
  late final Stream<User?> _authStream =
      FirebaseAuth.instance.authStateChanges();

  void _onEntitlementChanged() {
    _controller.isPro = _entitlementService?.isPro ?? false;
  }

  @override
  void dispose() {
    _entitlementService?.entitlement.removeListener(_onEntitlementChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthGate.guestModeNotifier,
      builder: (context, guestMode, _) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Use currentUser as fallback for when the stream hasn't emitted yet
        // (e.g. hot-restart, tab switch). Avoids Bella flicker on sign-in.
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        final isSignedIn = user != null;

        // Clear all Bella state when user signs out or switches account.
        if (user?.uid != _lastUid) {
          _lastUid = user?.uid;
          if (!isSignedIn) {
            _controller.clearChat();
          }
        }

        if (isSignedIn) {
          // Defer Firestore reads to after the current frame so they
          // don't block rendering (both methods guard against duplicate
          // calls internally).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller.loadRole();
            _controller.loadChatHistory();
          });
          final pro = ProServices.maybeOf(context);
          if (pro != null) {
            final es = pro.entitlementService;
            if (_entitlementService != es) {
              _entitlementService?.entitlement
                  .removeListener(_onEntitlementChanged);
              _entitlementService = es;
              es.entitlement.addListener(_onEntitlementChanged);
            }
            _controller.isPro = es.isPro;
          }
        }

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Explicit light background so the black Flutter canvas never
              // shows through system dialogs (ATT, notifications, etc.).
              const ColoredBox(color: Color(0xFFF2F2F7)),
              // The actual app content (navigator, screens, etc.)
              widget.child,

              // Show Bella when signed in or in guest mode.
              // Hidden on login/signup/onboarding carousel (isSignedIn=false).
              if (isSignedIn || guestMode) ...[
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
                  return KeyedSubtree(
                    key: TutorialKeys.instance.bellaKey,
                    child: BellaFab(controller: _controller),
                  );
                },
              ),
            ],
          ],
          ),
        );
      },
    );
      },
    );
  }
}
