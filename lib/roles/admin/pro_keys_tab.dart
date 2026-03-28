import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

import 'admin_functions.dart';

import 'widgets/csv_export.dart';

class ProKeysTab extends StatefulWidget {
  const ProKeysTab({super.key});

  @override
  State<ProKeysTab> createState() => _ProKeysTabState();
}

class _ProKeysTabState extends State<ProKeysTab> {
  final _fn = adminFunctions();

  List<Map<String, dynamic>> _keys = [];
  bool _loading = false;
  String? _statusFilter;
  String _searchQuery = '';

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
      if (!mounted) return;
      setState(() {
        _keys = rawKeys
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[ProKeysTab] loadKeys error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.keysLoadError)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createKey() async {
    final result = await showDialog<({int grantDays, int count})>(
      context: context,
      builder: (ctx) => _CreateKeyDialog(),
    );
    if (result == null) return;

    try {
      final response = await _fn
          .httpsCallable('createProKeys')
          .call<Map<String, dynamic>>({
        'count': result.count,
        'grantDays': result.grantDays,
      });

      final createdKeys = response.data['keys'] as List<dynamic>? ?? [];
      if (createdKeys.isNotEmpty && mounted) {
        if (createdKeys.length == 1) {
          final rawKey = createdKeys.first['key'] as String? ?? '?';
          await _showRawKeyDialog(rawKey, result.grantDays);
        } else {
          final rawKeys = createdKeys
              .map((k) => (k as Map<String, dynamic>)['key'] as String? ?? '?')
              .toList();
          await _showBatchKeyDialog(rawKeys, result.grantDays);
        }
        _loadKeys();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ProKeysTab] createKey error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.keyCreateError)),
        );
      }
    }
  }

  Future<void> _showRawKeyDialog(String rawKey, int grantDays) async {
    final l = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.keyCreated),
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
                SnackBar(content: Text(l.copiedToClipboard)),
              );
            },
            icon: const Icon(Icons.copy),
            label: Text(l.copy),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }

  Future<void> _showBatchKeyDialog(List<String> keys, int grantDays) async {
    final l = AppLocalizations.of(context)!;
    final allKeys = keys.join('\n');
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.keysErstellt(keys.length)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Diese Keys werden nur einmal angezeigt!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  allKeys,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Je $grantDays Tage Pro-Zugang',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              final l = AppLocalizations.of(context)!;
              Clipboard.setData(ClipboardData(text: allKeys));
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                    content: Text(l.allCopied)),
              );
            },
            icon: const Icon(Icons.copy),
            label: Text(l.allCopy),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }

  Future<void> _disableKey(String keyId) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.keyDeactivate),
        content: const Text(
          'Der Key kann danach nicht mehr eingelöst werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l.deactivate),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _fn.httpsCallable('disableProKey').call<void>({'keyId': keyId});
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.keyDeactivated)),
        );
        _loadKeys();
      }
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (kDebugMode) debugPrint('[ProKeysTab] deactivateKey error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.keyDeactivateError)),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await exportCsv(
      context: context,
      fileName: 'pro_keys_export.csv',
      headers: ['Key', l.status, 'Tage', 'Erstellt', l.eingeloest, l.eingeloestVon],
      rows: _keys.map((k) => [
        (k['keyId'] ?? '').toString(),
        (k['status'] ?? '').toString(),
        (k['grantDays'] ?? '').toString(),
        (k['createdAt'] ?? '').toString(),
        (k['redeemedAt'] ?? '').toString(),
        (k['redeemedByUid'] ?? '').toString(),
      ]).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final visibleKeys = _searchQuery.isEmpty
        ? _keys
        : _keys.where((k) {
            final id = (k['keyId'] ?? '').toString().toLowerCase();
            final uid = (k['redeemedByUid'] ?? '').toString().toLowerCase();
            return id.contains(_searchQuery) || uid.contains(_searchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.proKeys),
        actions: [
          if (_keys.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: l.csvExportieren,
              onPressed: () => _exportCsv(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l.update,
            onPressed: _loading ? null : _loadKeys,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createKey,
        icon: Icon(Icons.add),
        label: Text(l.neuerKey),
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
                    label: l.all,
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
          const SizedBox(height: 4),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l.keyIdOderUidSuchen,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase().trim()),
            ),
          ),
          const SizedBox(height: 8),

          // Content
          if (_loading)
            const LinearProgressIndicator(),
          Expanded(
            child: visibleKeys.isEmpty && !_loading
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Keine Pro-Keys vorhanden.'
                          : 'Keine Treffer.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadKeys,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                      itemCount: visibleKeys.length,
                      itemBuilder: (context, index) {
                        return _ProKeyCard(
                          data: visibleKeys[index],
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
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final keyId = data['keyId'] as String? ?? '';
    final status = data['status'] as String? ?? 'active';
    final grantDays = (data['grantDays'] as num?)?.toInt() ?? 0;
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
        statusLabel = l.eingeloest;
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    l.deactivate,
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
  int _count = 1;

  static const _presets = [30, 90, 180, 365];
  static const _countPresets = [1, 5, 10, 25];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.proKeysCreate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.gueltigkeitInTagen,
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
          const SizedBox(height: 20),
          Text(
            'Anzahl',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _countPresets.map((c) {
              final selected = _count == c;
              return ChoiceChip(
                label: Text('$c'),
                selected: selected,
                onSelected: (_) => setState(() => _count = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '$_count Key${_count > 1 ? 's' : ''} mit je $_grantDays Tagen Pro-Zugang.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            (grantDays: _grantDays, count: _count),
          ),
          child: Text(l.create),
        ),
      ],
    );
  }
}
