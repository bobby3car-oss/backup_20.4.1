import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/auth_service.dart';

/// Gate that requires a 4-digit PIN before granting access to [AdminHome].
class AdminPinGate extends StatefulWidget {
  const AdminPinGate({super.key, required this.child});

  final Widget child;

  @override
  State<AdminPinGate> createState() => _AdminPinGateState();
}

class _AdminPinGateState extends State<AdminPinGate> {
  static const _correctPin = '6605';

  final _controller = TextEditingController();
  bool _unlocked = false;
  String? _error;
  int _attempts = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    final input = _controller.text.trim();
    if (input == _correctPin) {
      setState(() => _unlocked = true);
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
    if (_unlocked) return widget.child;

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
                child: const Text('Entsperren'),
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
