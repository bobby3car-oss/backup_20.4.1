import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/auth_service.dart';
import '../../l10n/app_localizations.dart';

/// Gate that requires a 4-digit PIN before granting access to [AdminHome].
///
/// The PIN is injected at build time via `--dart-define=ADMIN_PIN=xxxx`.
/// It is stored as a SHA-256 hash so the cleartext value never appears
/// in the compiled binary.
///
/// Auto-locks after [_inactivityTimeout] of no touch interaction or when the
/// app moves to the background.
class AdminPinGate extends StatefulWidget {
  const AdminPinGate({super.key, required this.child});

  final Widget child;

  @override
  State<AdminPinGate> createState() => _AdminPinGateState();
}

class _AdminPinGateState extends State<AdminPinGate>
    with WidgetsBindingObserver {
  /// The PIN is supplied via `--dart-define=ADMIN_PIN=xxxx`.
  /// We hash it immediately so the cleartext is never retained.
  static const _rawPin = String.fromEnvironment('ADMIN_PIN');
  static final String _correctPinHash = _rawPin.isEmpty
      ? ''
      : sha256.convert(utf8.encode(_rawPin)).toString();

  static const _inactivityTimeout = Duration(minutes: 3);

  final _controller = TextEditingController();
  bool _unlocked = false;
  String? _error;
  int _attempts = 0;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Lock immediately when app goes to background.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lock();
    }
  }

  void _lock() {
    _inactivityTimer?.cancel();
    if (_unlocked && mounted) {
      setState(() {
        _unlocked = false;
        _controller.clear();
        _error = null;
      });
    }
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_unlocked) {
      _inactivityTimer = Timer(_inactivityTimeout, _lock);
    }
  }

  void _verify() {
    if (_correctPinHash.isEmpty) {
      setState(() => _error = 'Admin-PIN nicht konfiguriert (ADMIN_PIN fehlt).');
      return;
    }
    final input = _controller.text.trim();
    final inputHash = sha256.convert(utf8.encode(input)).toString();
    if (inputHash == _correctPinHash) {
      setState(() => _unlocked = true);
      _resetInactivityTimer();
    } else {
      _attempts++;
      if (_attempts >= 5) {
        // Too many failed attempts — sign out for safety.
        AuthService().signOut();
        return;
      }
      setState(() {
        _error = 'Falscher Code. Versuch $_attempts/5';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_unlocked) {
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _resetInactivityTimer(),
        child: widget.child,
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Admin-Zugang',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bitte gib den 4-stelligen Sicherheitscode ein.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 12,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _verify(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _verify,
                child: Text(l.unlock),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => AuthService().signOut(),
                child: Text(l.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
