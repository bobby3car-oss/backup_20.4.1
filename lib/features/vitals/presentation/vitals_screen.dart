import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/vital_repository_sync.dart';
import '../domain/vital_entry.dart';

/// Card-layout vitals screen with sliders for systolic, diastolic & pulse.
class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  static final VitalRepositorySync _repository = VitalRepositorySync.instance;

  double _systolic = 120;
  double _diastolic = 80;
  double _pulse = 70;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final id = 'vital_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = VitalEntry(
        id: id,
        ownerId: uid,
        systolic: _systolic.round(),
        diastolic: _diastolic.round(),
        pulse: _pulse.round(),
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'vitals_screen'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messung gespeichert'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}, $hh:$min';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sys = _systolic.round();
    final dia = _diastolic.round();
    final pul = _pulse.round();

    return GlassPage(
      title: 'Vitalwerte',
      titleEmoji: '🩺',
      titleColor: const Color(0xFFFF6B6B),
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.xl),

        // ── Card 1: Neue Messung ─────────────────────────────
        _IosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Neue Messung',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 20),

              // ── Systolisch ───────────────────────────────
              _VitalSliderRow(
                label: 'Systolisch',
                value: sys,
                unit: 'mmHg',
                valueColor: const Color(0xFF0A74FF),
                min: 70,
                max: 220,
                sliderValue: _systolic,
                hint: 'Normal: 90–140',
                onChanged: (v) => setState(() => _systolic = v),
              ),
              const SizedBox(height: 18),

              // ── Diastolisch ──────────────────────────────
              _VitalSliderRow(
                label: 'Diastolisch',
                value: dia,
                unit: 'mmHg',
                valueColor: const Color(0xFF0A74FF),
                min: 40,
                max: 130,
                sliderValue: _diastolic,
                hint: 'Normal: 60–90',
                onChanged: (v) => setState(() => _diastolic = v),
              ),
              const SizedBox(height: 18),

              // ── Puls ─────────────────────────────────────
              _VitalSliderRow(
                label: 'Puls (bpm)',
                value: pul,
                unit: 'bpm',
                valueColor: const Color(0xFF34C759),
                min: 40,
                max: 180,
                sliderValue: _pulse,
                hint: 'Normal: 60–100',
                onChanged: (v) => setState(() => _pulse = v),
              ),

              const SizedBox(height: 24),

              // ── Summary pill ─────────────────────────────
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$sys/$dia',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF3B30),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('❤️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '$pul',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF34C759),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Save button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A74FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Speichern'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Card 2: Verlauf ──────────────────────────────────
        StreamBuilder<List<VitalEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <VitalEntry>[];
            return _IosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verlauf',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (items.length < 2)
                    _buildEmptyState()
                  else
                    _buildHistory(items),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: const [
          SizedBox(height: 12),
          Text('📊', style: TextStyle(fontSize: 40)),
          SizedBox(height: 8),
          Text(
            'Mind. 2 Einträge',
            style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── History ─────────────────────────────────────────────────────────────
  Widget _buildHistory(List<VitalEntry> items) {
    final recent = items.take(10).toList();
    return Column(
      children: [
        _MiniChart(entries: recent),
        const SizedBox(height: 16),
        ...recent.map((e) => _HistoryRow(entry: e, formatDate: _formatDate)),
      ],
    );
  }
}

// ── iOS card container ───────────────────────────────────────────────────────

class _IosCard extends StatelessWidget {
  const _IosCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Vital slider row ─────────────────────────────────────────────────────────

class _VitalSliderRow extends StatelessWidget {
  const _VitalSliderRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
    required this.min,
    required this.max,
    required this.sliderValue,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final int value;
  final String unit;
  final Color valueColor;
  final double min;
  final double max;
  final double sliderValue;
  final String hint;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label ',
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
            ),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: valueColor,
            inactiveTrackColor: const Color(0xFFE5E5EA),
            thumbColor: valueColor,
            overlayColor: valueColor.withValues(alpha: 0.12),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: sliderValue,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
        Center(
          child: Text(
            hint,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
          ),
        ),
      ],
    );
  }
}

// ── Mini chart ───────────────────────────────────────────────────────────────

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.entries});

  final List<VitalEntry> entries;

  @override
  Widget build(BuildContext context) {
    // Chronological order: oldest left, newest right.
    final ordered = entries.reversed.toList();
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: ordered.map((e) {
          final sysRatio = (e.systolic - 70) / 150; // 70..220
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${e.systolic}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6 + (sysRatio.clamp(0.0, 1.0) * 38),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4 + ((e.pulse - 40) / 140).clamp(0.0, 1.0) * 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── History row ──────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.formatDate});

  final VitalEntry entry;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // BP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.systolic}/${entry.diastolic}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFFFF3B30),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Pulse badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '❤️ ${entry.pulse}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF34C759),
              ),
            ),
          ),
          const Spacer(),
          Text(
            formatDate(entry.createdAt),
            style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}
