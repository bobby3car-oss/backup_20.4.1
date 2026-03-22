import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/user_profile_service.dart';
import '../features/doctor_patients/domain/doctor_permissions.dart';

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
  DoctorPermissions _featurePermissions = const DoctorPermissions();
  bool _showFeatureDetails = false;

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
                  role == AppUserRole.family ||
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
            if (_linkType == DocumentLinkType.doctor) ...[
              const SizedBox(height: 16),
              const Text(
                'Feature-Berechtigungen',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lege fest, welche Daten der Arzt sehen und bearbeiten darf.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _QuickActionChip(
                    label: 'Alles freigeben',
                    onTap: _busy
                        ? null
                        : () => setState(() {
                              _featurePermissions = DoctorPermissions.allAccess;
                              _canRead = true;
                              _canWrite = true;
                            }),
                  ),
                  _QuickActionChip(
                    label: 'Nur Lesen',
                    onTap: _busy
                        ? null
                        : () => setState(() {
                              _featurePermissions = DoctorPermissions.readOnly;
                              _canRead = true;
                              _canWrite = false;
                            }),
                  ),
                  _QuickActionChip(
                    label: 'Minimal',
                    onTap: _busy
                        ? null
                        : () => setState(() {
                              _featurePermissions = DoctorPermissions.minimal;
                              _canRead = true;
                              _canWrite = false;
                            }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () =>
                    setState(() => _showFeatureDetails = !_showFeatureDetails),
                child: Row(
                  children: [
                    Icon(
                      _showFeatureDetails
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showFeatureDetails
                          ? 'Details ausblenden'
                          : 'Details anzeigen',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (_showFeatureDetails) ...[
                const SizedBox(height: 8),
                for (final entry
                    in DoctorPermissions.featureLabels.entries) ...[
                  _FeaturePermissionRow(
                    label: entry.value,
                    icon: DoctorPermissions.featureIcons[entry.key] ?? const IconData(0xe873, fontFamily: 'MaterialIcons'),
                    value: _featurePermissions[entry.key],
                    onChanged: _busy
                        ? null
                        : (v) => setState(() {
                              _featurePermissions =
                                  _featurePermissions.copyWithFeature(
                                      entry.key, v);
                            }),
                  ),
                ],
              ],
            ] else ...[
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
            ],
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
      final params = <String, dynamic>{
        'linkType': _linkType.name,
        'permissions': <String, dynamic>{'read': _canRead, 'write': _canWrite},
      };
      if (_linkType == DocumentLinkType.doctor) {
        params['featurePermissions'] = _featurePermissions.toMap();
      }
      final result = await callable.call(params);
      if (result.data is! Map) {
        throw StateError('Ungültige Server-Antwort');
      }
      final data = Map<String, dynamic>.from(result.data as Map);
      final code = (data['code'] ?? '').toString();
      if (code.isEmpty) throw StateError('Kein Invite Code erhalten');
      if (!mounted) return;
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

enum DocumentLinkType { doctor, family }

extension on DocumentLinkType {
  String get label => this == DocumentLinkType.doctor ? 'Arzt' : 'Angehöriger';
}

class _FeaturePermissionRow extends StatelessWidget {
  const _FeaturePermissionRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final FeatureAccess value;
  final ValueChanged<FeatureAccess>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          SegmentedButton<FeatureAccess>(
            segments: const [
              ButtonSegment(
                value: FeatureAccess.none,
                label: Text('Aus', style: TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: FeatureAccess.read,
                label: Text('Lesen', style: TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: FeatureAccess.readWrite,
                label: Text('Voll', style: TextStyle(fontSize: 11)),
              ),
            ],
            selected: {value},
            onSelectionChanged: onChanged == null
                ? null
                : (s) => onChanged!(s.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
