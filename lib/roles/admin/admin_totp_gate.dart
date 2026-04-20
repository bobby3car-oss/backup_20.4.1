import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/auth_service.dart';
import 'admin_totp_service.dart';

/// Optional TOTP gate for admin. If the admin has enrolled, a code (or a
/// trusted-device token) is required before [AdminHome] is shown. If not
/// enrolled, the gate is a pass-through — enrollment happens from settings.
///
/// Auto-locks after [_inactivityTimeout] of no interaction or when the app
/// moves to the background.
class AdminTotpGate extends StatefulWidget {
  const AdminTotpGate({super.key, required this.child, this.service});

  final Widget child;
  final AdminTotpService? service;

  @override
  State<AdminTotpGate> createState() => _AdminTotpGateState();
}

enum _GateState { bootstrapping, passthrough, needsCode, unlocked }

class _AdminTotpGateState extends State<AdminTotpGate>
    with WidgetsBindingObserver {
  static const _inactivityTimeout = Duration(minutes: 3);

  late final AdminTotpService _service = widget.service ?? AdminTotpService();
  final _codeController = TextEditingController();

  _GateState _state = _GateState.bootstrapping;
  String? _error;
  int _attempts = 0;
  bool _submitting = false;
  bool _rememberDevice = true;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _codeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lock();
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _state = _GateState.bootstrapping;
      _error = null;
    });
    try {
      final status = await _service.getStatus();
      if (!mounted) return;
      if (status != AdminTotpStatus.active) {
        // TOTP is opt-in — pass straight through when not enrolled.
        setState(() => _state = _GateState.passthrough);
        return;
      }
      // TOTP active — try trusted device first for silent unlock.
      if (await _service.hasStoredDeviceToken()) {
        final ok = await _service.verifyTrustedDevice();
        if (!mounted) return;
        if (ok) {
          setState(() => _state = _GateState.unlocked);
          _resetInactivityTimer();
          return;
        }
      }
      setState(() => _state = _GateState.needsCode);
    } on Exception catch (e) {
      if (!mounted) return;
      // Fail-open: TOTP is voluntary. A flaky callable or un-warmed function
      // must not lock the admin out of an account that may not have 2FA
      // enabled at all.
      if (kDebugMode) {
        debugPrint('[AdminTotpGate] status check failed, passing through: $e');
      }
      setState(() => _state = _GateState.passthrough);
    }
  }

  void _lock() {
    _inactivityTimer?.cancel();
    if (_state == _GateState.unlocked && mounted) {
      setState(() {
        _state = _GateState.needsCode;
        _codeController.clear();
        _error = null;
        _attempts = 0;
      });
      // Re-check in case trusted-device status can unlock silently.
      _bootstrap();
    }
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_state == _GateState.unlocked) {
      _inactivityTimer = Timer(_inactivityTimeout, _lock);
    }
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _error = 'Bitte den 6-stelligen Code eingeben.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _service.verifyCode(code: code, rememberDevice: _rememberDevice);
      if (!mounted) return;
      setState(() {
        _state = _GateState.unlocked;
        _submitting = false;
        _codeController.clear();
        _attempts = 0;
      });
      _resetInactivityTimer();
    } on Exception catch (e) {
      if (!mounted) return;
      _attempts++;
      if (_attempts >= 5) {
        await AuthService().signOut();
        return;
      }
      setState(() {
        _submitting = false;
        _error = 'Falscher Code ($e). Versuch $_attempts/5';
        _codeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _GateState.passthrough:
        return widget.child;
      case _GateState.unlocked:
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _resetInactivityTimer(),
          child: widget.child,
        );
      case _GateState.bootstrapping:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case _GateState.needsCode:
        return _buildCodePrompt();
    }
  }

  Widget _buildCodePrompt() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
                'Bitte gib den 6-stelligen Code aus deiner Authenticator-App ein.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _codeController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 28, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                    hintText: '123456',
                  ),
                  onSubmitted: (_) => _submitting ? null : _verify(),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _rememberDevice,
                onChanged: (v) =>
                    setState(() => _rememberDevice = v ?? false),
                title: const Text('Diesem Gerät vertrauen'),
                subtitle: const Text(
                  'Auf diesem Gerät 30 Tage nicht erneut fragen.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _submitting ? null : _verify,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entsperren'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => AuthService().signOut(),
                child: const Text('Abmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
