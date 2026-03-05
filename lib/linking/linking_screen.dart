import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/user_profile_service.dart';

class LinkingScreen extends StatefulWidget {
  const LinkingScreen({super.key, UserProfileService? profileService})
    : _profileService = profileService;

  final UserProfileService? _profileService;

  @override
  State<LinkingScreen> createState() => _LinkingScreenState();
}

class _LinkingScreenState extends State<LinkingScreen> {
  final _acceptController = TextEditingController();
  final _functions = FirebaseFunctions.instance;
  bool _busy = false;
  DocumentLinkType _linkType = DocumentLinkType.doctor;
  bool _canRead = true;
  bool _canWrite = false;
  String? _latestInviteCode;

  @override
  void dispose() {
    _acceptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileService = widget._profileService ?? UserProfileService();
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Linking')),
      body: FutureBuilder<AppUserRole>(
        future: profileService.getMyRole(),
        builder: (context, snapshot) {
          final role = snapshot.data ?? AppUserRole.patient;
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (role == AppUserRole.patient || role == AppUserRole.admin)
                _buildCreateInviteCard(),
              const SizedBox(height: 16),
              if (role == AppUserRole.doctor ||
                  role == AppUserRole.caregiver ||
                  role == AppUserRole.admin)
                _buildAcceptInviteCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreateInviteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Einladung erstellen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DocumentLinkType>(
              initialValue: _linkType,
              items: DocumentLinkType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(growable: false),
              onChanged: _busy
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _linkType = value);
                    },
              decoration: const InputDecoration(labelText: 'Link Typ'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Lesen erlauben'),
              value: _canRead,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _canRead = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Schreiben erlauben'),
              value: _canWrite,
              onChanged: _busy
                  ? null
                  : (value) {
                      setState(() {
                        _canWrite = value;
                        if (value) _canRead = true;
                      });
                    },
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _busy ? null : _createInvite,
              child: Text(_busy ? 'Erstelle...' : 'Einladung erstellen'),
            ),
            if (_latestInviteCode != null) ...[
              const SizedBox(height: 10),
              SelectableText('Code: $_latestInviteCode'),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _latestInviteCode ?? ''),
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Code kopiert')));
                },
                icon: const Icon(Icons.copy),
                label: const Text('Code kopieren'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptInviteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invite Code akzeptieren',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _acceptController,
              decoration: const InputDecoration(labelText: 'Invite Code'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _busy ? null : _acceptInvite,
              child: Text(_busy ? 'Akzeptiere...' : 'Akzeptieren'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createInvite() async {
    setState(() => _busy = true);
    try {
      final callable = _functions.httpsCallable('createInvite');
      final result = await callable.call(<String, dynamic>{
        'linkType': _linkType.name,
        'permissions': <String, dynamic>{'read': _canRead, 'write': _canWrite},
      });
      if (result.data is! Map) {
        throw StateError('Ungültige Server-Antwort');
      }
      final data = Map<String, dynamic>.from(result.data as Map);
      final code = (data['code'] ?? '').toString();
      if (code.isEmpty) throw StateError('Kein Invite Code erhalten');
      setState(() => _latestInviteCode = code);
    } catch (error) {
      if (kDebugMode) debugPrint('[LinkingScreen] createInvite error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einladung konnte nicht erstellt werden.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _acceptInvite() async {
    final code = _acceptController.text.trim();
    if (code.isEmpty) return;
    setState(() => _busy = true);
    try {
      final callable = _functions.httpsCallable('acceptInvite');
      await callable.call(<String, dynamic>{'code': code});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invite akzeptiert.')));
      _acceptController.clear();
    } catch (error) {
      if (kDebugMode) debugPrint('[LinkingScreen] acceptInvite error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Einladung konnte nicht akzeptiert werden.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

enum DocumentLinkType { doctor, caregiver }

extension on DocumentLinkType {
  String get label => this == DocumentLinkType.doctor ? 'Arzt' : 'Angehoerige';
}
