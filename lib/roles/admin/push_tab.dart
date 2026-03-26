import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_functions.dart';

import 'widgets/admin_confirmation_dialog.dart';
import '../../l10n/app_localizations.dart';

class PushTab extends StatefulWidget {
  const PushTab({super.key});

  @override
  State<PushTab> createState() => _PushTabState();
}

class _PushTabState extends State<PushTab> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _uidController = TextEditingController();

  String _targetType = 'all'; // all | role | user | system
  String _roleTarget = 'patient';
  String _systemTemplate = 'maintenance';
  bool _sending = false;

  static const _roleOptions = <String, String>{
    'patient': 'Patienten',
    'doctor': 'Ärzte',
  };

  static const _systemTemplates = <String, (String, String)>{
    'maintenance': ('Wartungsarbeiten', 'Die App wird vorübergehend gewartet. Bitte versuche es später erneut.'),
    'update': ('Update verfügbar', 'Eine neue Version der App ist verfügbar. Bitte aktualisiere jetzt.'),
    'news': ('Neuigkeiten', 'Es gibt neue Inhalte in deiner App. Öffne sie jetzt und bleib auf dem Laufenden.'),
    'reminder': ('Erinnerung', 'Vergiss nicht, deine heutigen Aufgaben in der App zu erledigen.'),
    'downtime': ('Störung bekannt', 'Wir arbeiten gerade an einem technischen Problem. Danke für deine Geduld.'),
    'feature': ('Neue Funktion', 'Entdecke neue Funktionen in deiner App. Jetzt öffnen!'),
  };

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  void _applyTemplate(String key) {
    final template = _systemTemplates[key];
    if (template == null) return;
    _titleController.text = template.$1;
    _bodyController.text = template.$2;
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.titleAndMessageRequired)),
      );
      return;
    }

    // Build target description for confirmation
    final targetDesc = switch (_targetType) {
      'all' => 'alle Nutzer',
      'role' => 'alle ${_roleOptions[_roleTarget] ?? _roleTarget}',
      'user' => 'User ${_uidController.text.trim()}',
      _ => l.system,
    };

    if (!mounted) return;
    final confirmed = await AdminConfirmationDialog.show(
      context,
      title: 'Push senden?',
      message: 'Nachricht "$title" an $targetDesc senden?',
      severity: AdminActionSeverity.dangerous,
      confirmLabel: l.send,
    );
    if (!confirmed) return;

    setState(() => _sending = true);
    try {
      final params = <String, dynamic>{
        'title': title,
        'body': body,
        'targetType': _targetType,
      };
      if (_targetType == 'role') params['targetValue'] = _roleTarget;
      if (_targetType == 'user') params['targetValue'] = _uidController.text.trim();

      await adminFunctions().httpsCallable('sendAdminNotification').call<void>(params);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Push an $targetDesc gesendet!')),
        );
        _titleController.clear();
        _bodyController.clear();
        _uidController.clear();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PushTab] send error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.pushSendError)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsPush)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ── Target selection ─────────────────────────────────
          Text(l.targetGroup, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'all', label: Text(l.all), icon: Icon(Icons.people, size: 18)),
              ButtonSegment(value: 'role', label: Text(l.role), icon: Icon(Icons.badge, size: 18)),
              ButtonSegment(value: 'user', label: Text(l.user), icon: Icon(Icons.person, size: 18)),
              ButtonSegment(value: 'system', label: Text(l.system), icon: Icon(Icons.settings, size: 18)),
            ],
            selected: {_targetType},
            onSelectionChanged: (v) {
              setState(() => _targetType = v.first);
              if (_targetType == 'system') _applyTemplate(_systemTemplate);
            },
          ),
          const SizedBox(height: 16),

          // ── Role picker ─────────────────────────────────────
          if (_targetType == 'role') ...[
            DropdownButtonFormField<String>(
              initialValue: _roleTarget,
              decoration: const InputDecoration(labelText: 'Rolle auswählen'),
              items: _roleOptions.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _roleTarget = v ?? 'patient'),
            ),
            const SizedBox(height: 16),
          ],

          // ── UID input ───────────────────────────────────────
          if (_targetType == 'user') ...[
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(
                labelText: 'User UID',
                prefixIcon: Icon(Icons.fingerprint),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── System templates ────────────────────────────────
          if (_targetType == 'system') ...[
            DropdownButtonFormField<String>(
              initialValue: _systemTemplate,
              decoration: const InputDecoration(labelText: 'Vorlage'),
              items: _systemTemplates.entries
                  .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value.$1),
                  ))
                  .toList(),
              onChanged: (v) {
                setState(() => _systemTemplate = v ?? 'maintenance');
                _applyTemplate(v ?? 'maintenance');
              },
            ),
            const SizedBox(height: 16),
          ],

          // ── Title & body ────────────────────────────────────
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titel',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            decoration: InputDecoration(
              labelText: l.message,
              prefixIcon: Icon(Icons.message),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // ── Preview ─────────────────────────────────────────
          Text(l.preview, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.amber),
              title: Text(
                _titleController.text.isEmpty ? 'Titel...' : _titleController.text,
                style: TextStyle(
                  color: _titleController.text.isEmpty ? cs.onSurfaceVariant : null,
                ),
              ),
              subtitle: Text(
                _bodyController.text.isEmpty ? 'Nachricht...' : _bodyController.text,
                style: TextStyle(
                  color: _bodyController.text.isEmpty ? cs.onSurfaceVariant : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Send button ─────────────────────────────────────
          FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(_sending ? 'Wird gesendet...' : 'Push senden'),
          ),

          const SizedBox(height: 32),

          // ── History ─────────────────────────────────────────
          Text(l.history, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('adminNotifications')
                .orderBy('timestamp', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Noch keine Push-Benachrichtigungen gesendet.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final d = doc.data();
                  final ts = d['timestamp'] as Timestamp?;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.notifications, size: 20),
                      title: Text(d['title'] as String? ?? '–',
                        style: Theme.of(context).textTheme.titleSmall),
                      subtitle: Text(
                        '${d['targetType'] ?? '–'} · ${d['recipientCount'] ?? '?'} Empfänger',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: ts != null
                          ? Text(_formatTimestamp(ts),
                              style: Theme.of(context).textTheme.labelSmall)
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}. '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
