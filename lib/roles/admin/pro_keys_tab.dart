import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProKeysTab extends StatefulWidget {
  const ProKeysTab({super.key});

  @override
  State<ProKeysTab> createState() => _ProKeysTabState();
}

class _ProKeysTabState extends State<ProKeysTab> {
  final _fn = FirebaseFunctions.instanceFor(region: 'europe-west1');

  List<Map<String, dynamic>> _keys = [];
  bool _loading = false;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'limit': 200};
      if (_statusFilter != null) params['status'] = _statusFilter;

      final result = await _fn
          .httpsCallable('listProKeys')
          .call<Map<String, dynamic>>(params);

      final rawKeys = result.data['keys'] as List<dynamic>? ?? [];
      setState(() {
        _keys = rawKeys.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[ProKeysTab] loadKeys error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keys konnten nicht geladen werden.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createKey() async {
    final grantDays = await showDialog<int>(
      context: context,
      builder: (ctx) => _CreateKeyDialog(),
    );
    if (grantDays == null) return;

    try {
      final result = await _fn
          .httpsCallable('createProKeys')
          .call<Map<String, dynamic>>({
        'count': 1,
        'grantDays': grantDays,
      });

      final createdKeys = result.data['keys'] as List<dynamic>? ?? [];
      if (createdKeys.isNotEmpty && mounted) {
        final rawKey = createdKeys.first['key'] as String? ?? '?';
        await _showRawKeyDialog(rawKey, grantDays);
        _loadKeys();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ProKeysTab] createKey error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Key konnte nicht erstellt werden.')),
        );
      }
    }
  }

  Future<void> _showRawKeyDialog(String rawKey, int grantDays) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Key erstellt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dieser Key wird nur einmal angezeigt!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                rawKey,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gültig für $grantDays Tage Pro-Zugang',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rawKey));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('In Zwischenablage kopiert!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Kopieren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fertig'),
          ),
        ],
      ),
    );
  }

  Future<void> _disableKey(String keyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Key deaktivieren?'),
        content: const Text(
          'Der Key kann danach nicht mehr eingelöst werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Deaktivieren'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _fn.httpsCallable('disableProKey').call<void>({'keyId': keyId});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Key deaktiviert.')),
        );
        _loadKeys();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ProKeysTab] deactivateKey error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Key konnte nicht deaktiviert werden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro-Keys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
            onPressed: _loading ? null : _loadKeys,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createKey,
        icon: const Icon(Icons.add),
        label: const Text('Neuer Key'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Alle',
                    selected: _statusFilter == null,
                    onSelected: () {
                      setState(() => _statusFilter = null);
                      _loadKeys();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Aktiv',
                    selected: _statusFilter == 'active',
                    onSelected: () {
                      setState(() => _statusFilter = 'active');
                      _loadKeys();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Eingelöst',
                    selected: _statusFilter == 'redeemed',
                    onSelected: () {
                      setState(() => _statusFilter = 'redeemed');
                      _loadKeys();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Deaktiviert',
                    selected: _statusFilter == 'disabled',
                    onSelected: () {
                      setState(() => _statusFilter = 'disabled');
                      _loadKeys();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Content
          if (_loading)
            const LinearProgressIndicator(),
          Expanded(
            child: _keys.isEmpty && !_loading
                ? Center(
                    child: Text(
                      'Keine Pro-Keys vorhanden.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadKeys,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                      itemCount: _keys.length,
                      itemBuilder: (context, index) {
                        return _ProKeyCard(
                          data: _keys[index],
                          onDisable: _disableKey,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ProKeyCard extends StatelessWidget {
  const _ProKeyCard({required this.data, required this.onDisable});

  final Map<String, dynamic> data;
  final ValueChanged<String> onDisable;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final keyId = data['keyId'] as String? ?? '';
    final status = data['status'] as String? ?? 'active';
    final grantDays = data['grantDays'] as int? ?? 0;
    final createdAt = data['createdAt'] as String?;
    final redeemedAt = data['redeemedAt'] as String?;
    final redeemedBy = data['redeemedByUid'] as String?;

    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusLabel = 'Aktiv';
        statusIcon = Icons.vpn_key;
      case 'redeemed':
        statusColor = Colors.blue;
        statusLabel = 'Eingelöst';
        statusIcon = Icons.check_circle;
      case 'disabled':
        statusColor = Colors.red;
        statusLabel = 'Deaktiviert';
        statusIcon = Icons.block;
      default:
        statusColor = Colors.grey;
        statusLabel = status;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    statusLabel,
                    style: TextStyle(color: cs.surface, fontSize: 12),
                  ),
                  backgroundColor: statusColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                Text(
                  '$grantDays Tage',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${keyId.length > 20 ? '${keyId.substring(0, 20)}...' : keyId}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Erstellt: ${_formatIso(createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
            if (redeemedBy != null) ...[
              const SizedBox(height: 2),
              Text(
                'Eingelöst von: $redeemedBy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
            if (redeemedAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Eingelöst am: ${_formatIso(redeemedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
            if (status == 'active') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onDisable(keyId),
                  icon: Icon(Icons.block, size: 16, color: cs.error),
                  label: Text(
                    'Deaktivieren',
                    style: TextStyle(color: cs.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatIso(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _CreateKeyDialog extends StatefulWidget {
  @override
  State<_CreateKeyDialog> createState() => _CreateKeyDialogState();
}

class _CreateKeyDialogState extends State<_CreateKeyDialog> {
  int _grantDays = 365;

  static const _presets = [30, 90, 180, 365];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pro-Key erstellen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gültigkeit (in Tagen)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((days) {
              final selected = _grantDays == days;
              return ChoiceChip(
                label: Text('$days'),
                selected: selected,
                onSelected: (_) => setState(() => _grantDays = days),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Der Key gewährt $_grantDays Tage Pro-Zugang.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_grantDays),
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}
