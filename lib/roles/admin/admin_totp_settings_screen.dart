import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'admin_totp_service.dart';
import 'admin_totp_setup_screen.dart';

/// Self-service two-factor (TOTP) settings screen for admin.
///
/// Shows status, lets the admin opt into TOTP by launching the setup flow,
/// manage trusted devices, or reset (= disable) TOTP after confirming with a
/// fresh code.
class AdminTotpSettingsScreen extends StatefulWidget {
  const AdminTotpSettingsScreen({super.key, this.service});

  final AdminTotpService? service;

  @override
  State<AdminTotpSettingsScreen> createState() =>
      _AdminTotpSettingsScreenState();
}

class _AdminTotpSettingsScreenState extends State<AdminTotpSettingsScreen> {
  late final AdminTotpService _service = widget.service ?? AdminTotpService();

  AdminTotpStatus? _status;
  List<AdminTrustedDevice> _devices = const [];
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
      final devices = status == AdminTotpStatus.active
          ? await _service.listTrustedDevices()
          : <AdminTrustedDevice>[];
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
        builder: (_) => AdminTotpSetupScreen(service: _service),
        fullscreenDialog: true,
      ),
    );
    if (ok == true) await _refresh();
  }

  Future<void> _reset() async {
    final code = await _askCurrentCode(
      title: 'Zwei-Faktor zurücksetzen',
      message:
          'Bitte bestätige mit deinem aktuellen Authenticator-Code, dass du '
          'die Zwei-Faktor-Authentifizierung wirklich deaktivieren möchtest.',
      destructive: true,
    );
    if (code == null) return;
    try {
      await _service.resetTotp(currentCode: code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zwei-Faktor-Authentifizierung deaktiviert.'),
        ),
      );
      await _refresh();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deaktivieren fehlgeschlagen: $e')),
      );
    }
  }

  Future<void> _revoke(AdminTrustedDevice device) async {
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
    final status = _status ?? AdminTotpStatus.none;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(status: status),
        const SizedBox(height: 16),
        if (status != AdminTotpStatus.active) ...[
          const Text(
            'Schütze deinen Admin-Zugang mit einer Authenticator-App (Google '
            'Authenticator, Authy, 1Password …). Nach der Aktivierung brauchst '
            'du neben deinem Passwort einen 6-stelligen Code aus deiner App.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _startEnrollment,
            icon: const Icon(Icons.security),
            label: const Text('Authenticator einrichten'),
          ),
        ],
        if (status == AdminTotpStatus.active) ...[
          OutlinedButton.icon(
            onPressed: _reset,
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

  String _deviceSubtitle(AdminTrustedDevice d) {
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

  final AdminTotpStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      AdminTotpStatus.active => (
        'Aktiv',
        Colors.green,
        Icons.verified_user,
      ),
      AdminTotpStatus.pending => (
        'Unvollständig',
        Colors.orange,
        Icons.hourglass_empty,
      ),
      AdminTotpStatus.none => (
        'Nicht eingerichtet',
        Colors.grey,
        Icons.shield_outlined,
      ),
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
