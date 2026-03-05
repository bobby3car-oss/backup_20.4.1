import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/medication_repository_sync.dart';
import '../domain/medication_intake.dart';

/// Card-layout medication documentation screen.
class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  static final MedicationRepositorySync _repository =
      MedicationRepositorySync.instance;

  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final id = 'med_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final dose = _doseController.text.trim();
      final entry = MedicationIntake(
        id: id,
        ownerId: uid,
        name: name,
        dose: dose.isEmpty ? null : dose,
        takenAt: now,
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'medication_screen'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      _nameController.clear();
      _doseController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Einnahme dokumentiert'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  String _dayKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _humanDay(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Heute';
    if (diff == -1) return 'Gestern';
    return _formatDate(d);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Medikamenten-Doku',
      titleEmoji: '💊',
      titleColor: AppColors.primary,
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.xl),

        // ── Card 1: Einnahme dokumentieren ───────────────────
        _IosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Einnahme dokumentieren',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 18),

              // Medikament field
              const Text(
                'Medikament',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 6),
              _StyledTextField(
                controller: _nameController,
                placeholder: 'z.B. Ibuprofen',
              ),

              const SizedBox(height: 16),

              // Dosis field
              const Text(
                'Dosis (optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 6),
              _StyledTextField(
                controller: _doseController,
                placeholder: 'z.B. 400mg',
              ),

              const SizedBox(height: 24),

              // Save button
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
                      : const Text('Dokumentieren'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Card 2: Einnahmen / Tag ──────────────────────────
        StreamBuilder<List<MedicationIntake>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final all = (snapshot.data ?? const <MedicationIntake>[])
                .where((e) => !e.isDeleted)
                .toList();
            return _IosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Einnahmen / Tag',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (all.isEmpty)
                    _buildEmptyState()
                  else
                    _buildGroupedList(all),
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
          Text('💊', style: TextStyle(fontSize: 40)),
          SizedBox(height: 8),
          Text(
            'Noch keine Einträge',
            style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Grouped list ────────────────────────────────────────────────────────
  Widget _buildGroupedList(List<MedicationIntake> items) {
    // Group by day key (sorted newest-first already).
    final grouped = <String, List<MedicationIntake>>{};
    for (final item in items) {
      final key = _dayKey(item.takenAt);
      grouped.putIfAbsent(key, () => <MedicationIntake>[]).add(item);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final key in sortedKeys) ...[
          // Day header
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              _humanDay(DateTime.parse(key)),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
          // Entries for that day
          ...grouped[key]!.map(
            (entry) => _IntakeRow(entry: entry, formatTime: _formatTime),
          ),
          const SizedBox(height: 6),
        ],
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

// ── Styled text field ────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({required this.controller, required this.placeholder});

  final TextEditingController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(fontSize: 16, color: Color(0xFFAEAEB2)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

// ── Intake row ───────────────────────────────────────────────────────────────

class _IntakeRow extends StatelessWidget {
  const _IntakeRow({required this.entry, required this.formatTime});

  final MedicationIntake entry;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Pill icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0A74FF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('💊', style: TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          // Name + dose
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                if (entry.dose != null)
                  Text(
                    entry.dose!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
              ],
            ),
          ),
          // Time
          Text(
            formatTime(entry.takenAt),
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}
