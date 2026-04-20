import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'user_totp_service.dart';

/// Self-service two-factor (TOTP) settings screen for doctors, orgs and staff.
///
/// Shows status, lets the user enable/disable TOTP, re-view the QR code and
/// secret after a fresh code challenge, and manage trusted devices.
class UserTotpSettingsScreen extends StatefulWidget {
  const UserTotpSettingsScreen({super.key, this.service});

  final UserTotpService? service;

  @override
  State<UserTotpSettingsScreen> createState() => _UserTotpSettingsScreenState();
}

class _UserTotpSettingsScreenState extends State<UserTotpSettingsScreen> {
  late final UserTotpService _service = widget.service ?? UserTotpService();

  UserTotpStatus? _status;
  List<UserTrustedDevice> _devices = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await _service.getStatus();
      final devices = status == UserTotpStatus.active
          ? await _service.listTrustedDevices()
          : <UserTrustedDevice>[];
      if (!mounted) return;
      setState(() {
        _status = status;
        _devices = devices;
        _loading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Status konnte nicht geladen werden: $e';
      });
    }
  }

  Future<void> _startEnrollment() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _EnrollmentScreen(service: _service),
        fullscreenDialog: true,
      ),
    );
    if (ok == true) await _refresh();
  }

  Future<void> _showSecret() async {
    final code = await _askCurrentCode(
      title: 'Aktuellen Code bestätigen',
      message:
          'Bitte gib den aktuell angezeigten 6-stelligen Code aus deiner '
          'Authenticator-App ein, um den QR-Code erneut anzuzeigen.',
    );
    if (code == null) return;
    try {
      final enrollment = await _service.revealSecret(currentCode: code);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _RevealSecretScreen(enrollment: enrollment),
          fullscreenDialog: true,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    }
  }

  Future<void> _disable() async {
    final code = await _askCurrentCode(
      title: 'Zwei-Faktor deaktivieren',
      message:
          'Bitte bestätige mit deinem aktuellen Authenticator-Code, dass du '
          'die Zwei-Faktor-Authentifizierung wirklich deaktivieren möchtest.',
      destructive: true,
    );
    if (code == null) return;
    try {
      await _service.disableTotp(currentCode: code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zwei-Faktor-Authentifizierung deaktiviert.')),
      );
      await _refresh();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deaktivieren fehlgeschlagen: $e')),
      );
    }
  }

  Future<void> _revoke(UserTrustedDevice device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gerät entfernen'),
        content: Text(
          '"${device.deviceName}" wird nicht mehr automatisch entsperrt. '
          'Beim nächsten Start dort ist ein neuer Code nötig.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.revokeDevice(device.id);
      await _refresh();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    }
  }

  Future<String?> _askCurrentCode({
    required String title,
    required String message,
    bool destructive = false,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 20, letterSpacing: 6),
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                  hintText: '123456',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              onPressed: () {
                final c = controller.text.trim();
                if (c.length == 6 && int.tryParse(c) != null) {
                  Navigator.of(ctx).pop(c);
                }
              },
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zwei-Faktor-Authentifizierung')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildBody(),
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
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _refresh,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final status = _status ?? UserTotpStatus.none;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(status: status),
        const SizedBox(height: 16),
        if (status != UserTotpStatus.active) ...[
          const Text(
            'Schütze deinen Zugang mit einer Authenticator-App (Google '
            'Authenticator, Authy, 1Password …). Nach der Aktivierung '
            'brauchst du neben deinem Passwort einen 6-stelligen Code aus '
            'deiner App, um dich auf neuen Geräten anzumelden.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _startEnrollment,
            icon: const Icon(Icons.security),
            label: const Text('Authenticator einrichten'),
          ),
        ],
        if (status == UserTotpStatus.active) ...[
          OutlinedButton.icon(
            onPressed: _showSecret,
            icon: const Icon(Icons.qr_code_2),
            label: const Text('QR-Code / Secret anzeigen'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _disable,
            icon: const Icon(Icons.lock_open),
            label: const Text('Zwei-Faktor deaktivieren'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
          const SizedBox(height: 24),
          const Text(
            'Vertraute Geräte',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Auf diesen Geräten wird 30 Tage lang nicht erneut nach dem Code '
            'gefragt.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          if (_devices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Keine vertrauten Geräte.'),
            )
          else
            ..._devices.map(
              (d) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text(d.deviceName),
                  subtitle: Text(_deviceSubtitle(d)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Entfernen',
                    onPressed: () => _revoke(d),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _deviceSubtitle(UserTrustedDevice d) {
    final df = DateFormat('dd.MM.yyyy');
    final parts = <String>[];
    if (d.createdAt != null) parts.add('erstellt ${df.format(d.createdAt!)}');
    if (d.lastUsedAt != null) parts.add('zuletzt ${df.format(d.lastUsedAt!)}');
    if (d.expiresAt != null) parts.add('läuft ab ${df.format(d.expiresAt!)}');
    return parts.join(' · ');
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final UserTotpStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      UserTotpStatus.active => ('Aktiv', Colors.green, Icons.verified_user),
      UserTotpStatus.pending => (
        'Unvollständig',
        Colors.orange,
        Icons.hourglass_empty,
      ),
      UserTotpStatus.none => ('Nicht eingerichtet', Colors.grey, Icons.shield_outlined),
    };
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: const Text('Zwei-Faktor-Authentifizierung'),
        subtitle: Text(label),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Enrollment screen (called from settings when user opts in).
// ══════════════════════════════════════════════════════════════════════════════

class _EnrollmentScreen extends StatefulWidget {
  const _EnrollmentScreen({required this.service});
  final UserTotpService service;

  @override
  State<_EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<_EnrollmentScreen> {
  final _codeController = TextEditingController();
  UserTotpEnrollment? _enrollment;
  bool _loading = true;
  bool _submitting = false;
  bool _rememberDevice = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final enrollment = await widget.service.beginEnrollment();
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
      await widget.service.confirmEnrollment(
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
            Text(_error ?? 'Unbekannter Fehler', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _start,
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
                : const Text('Zwei-Faktor aktivieren'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Re-view screen after the user proves ownership with a fresh code.
// ══════════════════════════════════════════════════════════════════════════════

class _RevealSecretScreen extends StatelessWidget {
  const _RevealSecretScreen({required this.enrollment});
  final UserTotpEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR-Code / Secret')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Scanne diesen QR-Code mit einer Authenticator-App, um deinen '
                'Account auf einem weiteren Gerät hinzuzufügen.',
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
                'Secret (manuelle Eingabe)',
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
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: enrollment.secret),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Secret in Zwischenablage kopiert'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Secret kopieren',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Konto',
                style: TextStyle(color: Colors.grey),
              ),
              Text(enrollment.email),
            ],
          ),
        ),
      ),
    );
  }
}
