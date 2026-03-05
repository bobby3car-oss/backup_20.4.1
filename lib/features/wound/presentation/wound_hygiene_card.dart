import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// iOS-style card showing 6 wound-hygiene recommendations with an optional
/// "Gelesen" acknowledgement chip persisted to Firestore.
class WoundHygieneCard extends StatefulWidget {
  const WoundHygieneCard({super.key});

  @override
  State<WoundHygieneCard> createState() => _WoundHygieneCardState();
}

class _WoundHygieneCardState extends State<WoundHygieneCard> {
  DateTime? _ackAt;
  bool _loading = true;

  // ── Firestore path helpers ───────────────────────────────────────────────
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _ackRef {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .collection('education_ack')
        .doc('wound_hygiene');
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadAck();
  }

  Future<void> _loadAck() async {
    try {
      final ref = _ackRef;
      if (ref == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final snap = await ref.get();
      if (!mounted) return;
      final ts = snap.data()?['ackAt'] as Timestamp?;
      setState(() {
        _ackAt = ts?.toDate();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acknowledge() async {
    final now = DateTime.now();
    setState(() => _ackAt = now);
    try {
      await _ackRef?.set({
        'ackAt': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
    } catch (_) {
      // best-effort
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────
  static const _steps = <(String, String)>[
    ('1', '✋ Hände gründlich waschen'),
    ('2', '🩹 Trockener Pflasterwechsel'),
    ('3', '📋 Wunddoku: Trocken? Nicht rot? Keine frische Blutung?'),
    (
      '4',
      '⛔ Keine Berührung der Wunde, keine Manipulation, keine Cremes/Salben',
    ),
    ('5', '✨ Pflaster ohne Berührung der Auflage erneuern'),
    ('6', '✋ Erneut Hände waschen'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title ────────────────────────────────────────────────
          const Text(
            '🧴 Wundhygiene-Empfehlungen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // ── Numbered list ────────────────────────────────────────
          ..._steps.map((step) => _StepRow(number: step.$1, text: step.$2)),

          const SizedBox(height: 16),

          // ── Warning box ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '⚠️ Bei Rötung bitte Praxis kontaktieren',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD72638),
                height: 1.4,
              ),
            ),
          ),

          // ── Ack chip ─────────────────────────────────────────────
          if (!_loading) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: _ackAt != null
                  ? _AckChip(ackAt: _ackAt!)
                  : _UnreadChip(onTap: _acknowledge),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Step row ─────────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue circle with number
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF0A74FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1C1C1E),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ack chips ────────────────────────────────────────────────────────────────

class _AckChip extends StatelessWidget {
  const _AckChip({required this.ackAt});

  final DateTime ackAt;

  @override
  Widget build(BuildContext context) {
    final label =
        '✅ Gelesen am ${ackAt.day.toString().padLeft(2, '0')}.${ackAt.month.toString().padLeft(2, '0')}.${ackAt.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }
}

class _UnreadChip extends StatelessWidget {
  const _UnreadChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF0A74FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Als gelesen markieren',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
