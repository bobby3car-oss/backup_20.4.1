import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_service.dart';
import 'user_totp_service.dart';

/// Optional TOTP gate for non-admin roles (doctors, orgs, staff).
///
/// Flow:
///   1. Check status. If status != active → pass straight through (opt-in).
///   2. If active and a trusted device token is on this device → silent unlock.
///   3. Otherwise prompt for a 6-digit code. The user can tick "Trust device"
///      to skip the prompt on this device for 30 days.
///
/// Unlike the admin gate, this one never forces enrollment — the user opts in
/// from settings.
class UserTotpGate extends StatefulWidget {
  const UserTotpGate({super.key, required this.child, this.service});

  final Widget child;
  final UserTotpService? service;

  @override
  State<UserTotpGate> createState() => _UserTotpGateState();
}

enum _GateState { bootstrapping, passthrough, needsCode, unlocked }

class _UserTotpGateState extends State<UserTotpGate>
    with WidgetsBindingObserver {
  static const _inactivityTimeout = Duration(minutes: 15);

  late final UserTotpService _service = widget.service ?? UserTotpService();
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
    // Only lock if TOTP is active on this account.
    if (_state != _GateState.unlocked) return;
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
      if (status != UserTotpStatus.active) {
        setState(() => _state = _GateState.passthrough);
        return;
      }
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
      // Fail-open: TOTP is opt-in for non-admin roles. A flaky callable or an
      // un-warmed function must not lock the user out of an account that may
      // not even have 2FA enabled.
      if (kDebugMode) {
        debugPrint('[UserTotpGate] status check failed, passing through: $e');
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
      case _GateState.unlocked:
        final gated = _state == _GateState.unlocked;
        if (!gated) return widget.child;
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
                'Zwei-Faktor-Authentifizierung',
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
