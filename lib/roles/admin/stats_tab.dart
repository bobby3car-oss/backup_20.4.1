import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  bool _refreshing = false;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    // Auto-refresh stats on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didInitialLoad) {
        _didInitialLoad = true;
        _refreshStats();
      }
    });
  }

  Future<void> _refreshStats() async {
    setState(() => _refreshing = true);
    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      await fn.httpsCallable('getAdminStats').call<void>({});
    } catch (e) {
      if (kDebugMode) debugPrint('[StatsTab] refreshStats error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statistiken konnten nicht aktualisiert werden.')),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshStats,
            tooltip: 'Aktualisieren',
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance.doc('adminStats/global').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Daten konnten nicht geladen werden.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          if (data == null || data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text('Statistiken werden geladen...'),
                  const SizedBox(height: 12),
                  if (_refreshing)
                    const CircularProgressIndicator()
                  else
                    FilledButton.icon(
                      onPressed: _refreshStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Jetzt generieren'),
                    ),
                ],
              ),
            );
          }

          final totalUsers = data['totalUsers'] ?? 0;
          final totalPatients = data['totalPatients'] ?? 0;
          final totalDoctors = data['totalDoctors'] ?? 0;
          final totalCaregivers = data['totalCaregivers'] ?? 0;
          final proActive = data['proActive'] ?? 0;
          final updatedAt = data['updatedAt'] as Timestamp?;

          return RefreshIndicator(
            onRefresh: _refreshStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(
                  icon: Icons.people,
                  iconColor: cs.primary,
                  label: 'Nutzer gesamt',
                  value: '$totalUsers',
                ),
                _StatCard(
                  icon: Icons.person,
                  iconColor: Colors.blue,
                  label: 'Patienten',
                  value: '$totalPatients',
                ),
                _StatCard(
                  icon: Icons.medical_services,
                  iconColor: Colors.teal,
                  label: 'Ärzte',
                  value: '$totalDoctors',
                ),
                _StatCard(
                  icon: Icons.favorite,
                  iconColor: Colors.orange,
                  label: 'Begleiter',
                  value: '$totalCaregivers',
                ),
                _StatCard(
                  icon: Icons.star,
                  iconColor: Colors.amber.shade700,
                  label: 'Aktive Pro-Lizenzen',
                  value: '$proActive',
                ),
                if (updatedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'Zuletzt aktualisiert: ${_formatTimestamp(updatedAt)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
