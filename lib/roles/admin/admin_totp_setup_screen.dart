import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'admin_totp_service.dart';

/// First-time enrollment screen for the admin authenticator (TOTP).
///
/// Shows a QR code generated from the otpauth URL returned by the server,
/// plus the raw base32 secret as a manual-entry fallback. On successful
/// confirmation the device is trusted (remember-me) so the user does not get
/// prompted again on the next launch.
class AdminTotpSetupScreen extends StatefulWidget {
  const AdminTotpSetupScreen({super.key, this.service});

  final AdminTotpService? service;

  @override
  State<AdminTotpSetupScreen> createState() => _AdminTotpSetupScreenState();
}

class _AdminTotpSetupScreenState extends State<AdminTotpSetupScreen> {
  late final AdminTotpService _service = widget.service ?? AdminTotpService();
  final _codeController = TextEditingController();

  AdminTotpEnrollment? _enrollment;
  bool _loading = true;
  bool _submitting = false;
  bool _rememberDevice = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startEnrollment();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _startEnrollment() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final enrollment = await _service.beginEnrollment();
      if (!mounted) return;
      setState(() {
        _enrollment = enrollment;
        _loading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Einrichtung konnte nicht gestartet werden: $e';
      });
    }
  }

  Future<void> _confirm() async {
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
      await _service.confirmEnrollment(
        code: code,
        rememberDevice: _rememberDevice,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Code wurde nicht akzeptiert: $e';
        _codeController.clear();
      });
    }
  }

  Future<void> _copySecret() async {
    final secret = _enrollment?.secret;
    if (secret == null || secret.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: secret));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Secret in Zwischenablage kopiert')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authenticator einrichten')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _enrollment == null
            ? _buildError()
            : _buildEnrollment(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unbekannter Fehler',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _startEnrollment,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollment() {
    final enrollment = _enrollment!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '1. Scannen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Öffne deine Authenticator-App (Google Authenticator, Authy, '
            '1Password …) und scanne diesen QR-Code.',
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: enrollment.otpauthUrl,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oder Secret manuell eingeben',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  enrollment.secret,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: _copySecret,
                icon: const Icon(Icons.copy),
                tooltip: 'Secret kopieren',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '2. Code eingeben',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gib den aktuell angezeigten 6-stelligen Code aus deiner '
            'Authenticator-App ein.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(
              counterText: '',
              errorText: _error,
              border: const OutlineInputBorder(),
              hintText: '123456',
            ),
            onSubmitted: (_) => _submitting ? null : _confirm(),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _rememberDevice,
            onChanged: (v) => setState(() => _rememberDevice = v ?? false),
            title: const Text('Diesem Gerät vertrauen'),
            subtitle: const Text(
              'Auf diesem Gerät nicht erneut nach dem Code fragen (30 Tage).',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _confirm,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Authenticator aktivieren'),
          ),
        ],
      ),
    );
  }
}
