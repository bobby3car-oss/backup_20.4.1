import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/emergency_repository.dart';
import '../domain/emergency_info.dart';
import '../../../screens/profile_settings_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// Full-screen emergency view.
///
/// RED background, large text, maximum readability.
/// Works offline using locally cached data.
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyRepository _repo = EmergencyRepository();
  EmergencyInfo _info = const EmergencyInfo();
  bool _loading = true;
  /// True when the cache was empty AND the network refresh failed.
  bool _offlineNoCache = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Show cached data instantly, then refresh from network in background.
    final cached = await _repo.loadCached();
    final hasCachedData = !cached.isEmpty;
    if (mounted) setState(() { _info = cached; _loading = false; });
    try {
      final fresh = await _repo.refreshFromNetwork();
      if (mounted) setState(() { _info = fresh; _offlineNoCache = false; });
    } catch (_) {
      // Network unavailable. If there was no cached data, show offline hint.
      if (mounted && !hasCachedData) {
        setState(() => _offlineNoCache = true);
      }
    }
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _share() {
    final l = AppLocalizations.of(context)!;
    SharePlus.instance.share(ShareParams(text: _info.toShareText(l)));
  }

  // ── UI ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFCC0000),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: topPadding + 12,
                bottom: bottomPadding + 24,
              ),
              children: [
                // ── Top bar ──────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 28),
                      onPressed: _share,
                      tooltip: l.notfallInfoTeilen,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Offline / no-cache banner ─────────────────────
                if (_offlineNoCache) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l.eiOfflineBanner,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── SOS Title ────────────────────────────────────
                const Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Emergency call 112 ───────────────────────────
                _CallButton(
                  label: l.notruf112,
                  icon: Icons.local_hospital_rounded,
                  onTap: () => _call('112'),
                ),

                const SizedBox(height: 12),

                // ── Emergency contact ────────────────────────────
                if (_info.emergencyContactPhone != null &&
                    _info.emergencyContactPhone!.isNotEmpty)
                  _CallButton(
                    label: _info.emergencyContactName ?? l.emergencyContact,
                    subtitle: _info.emergencyContactPhone,
                    icon: Icons.person_rounded,
                    onTap: () => _call(_info.emergencyContactPhone!),
                  ),

                if (_info.emergencyContactPhone != null &&
                    _info.emergencyContactPhone!.isNotEmpty)
                  const SizedBox(height: 12),

                // ── Hospital ─────────────────────────────────────
                if (_info.hospitalPhone != null &&
                    _info.hospitalPhone!.isNotEmpty)
                  _CallButton(
                    label: _info.hospitalName ?? l.eiHospital,
                    subtitle: _info.hospitalPhone,
                    icon: Icons.local_hospital_outlined,
                    onTap: () => _call(_info.hospitalPhone!),
                  ),

                if (_info.hospitalPhone != null &&
                    _info.hospitalPhone!.isNotEmpty)
                  const SizedBox(height: 12),

                // ── Doctor ───────────────────────────────────────
                if (_info.doctorPhone != null &&
                    _info.doctorPhone!.isNotEmpty)
                  _CallButton(
                    label: _info.doctorName ?? l.doctor,
                    subtitle: _info.doctorPhone,
                    icon: Icons.medical_services_rounded,
                    onTap: () => _call(_info.doctorPhone!),
                  ),

                if (_info.doctorPhone != null &&
                    _info.doctorPhone!.isNotEmpty)
                  const SizedBox(height: 24),

                // ── Blood type & allergies ───────────────────────
                if (_info.bloodType != null && _info.bloodType!.isNotEmpty)
                  _InfoCard(
                    label: l.eiBloodType,
                    value: _info.bloodType!,
                    large: true,
                  ),

                if (_info.bloodType != null && _info.bloodType!.isNotEmpty)
                  const SizedBox(height: 12),

                if (_info.allergies.isNotEmpty)
                  _InfoCard(
                    label: l.eiAllergies,
                    value: _info.allergies.join(', '),
                    large: true,
                    color: const Color(0xFFFF6B00),
                  ),

                if (_info.allergies.isNotEmpty) const SizedBox(height: 12),

                // ── Insurance ────────────────────────────────────
                if (_info.insuranceInfo != null &&
                    _info.insuranceInfo!.isNotEmpty)
                  _InfoCard(
                    label: l.eiInsurance,
                    value: _info.insuranceInfo!,
                  ),

                if (_info.insuranceInfo != null &&
                    _info.insuranceInfo!.isNotEmpty)
                  const SizedBox(height: 12),

                // ── Hospital name (if no phone) ──────────────────
                if (_info.hospitalName != null &&
                    _info.hospitalName!.isNotEmpty &&
                    (_info.hospitalPhone == null || _info.hospitalPhone!.isEmpty))
                  _InfoCard(
                    label: l.eiHospital,
                    value: _info.hospitalName!,
                  ),

                // ── Empty state hint ─────────────────────────────
                if (_info.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white70,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.eiNoDataHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton.icon(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            label: Text(
                              l.eiOpenProfile,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ProfileSettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const MedicalDisclaimerBanner(inverted: true),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CALL BUTTON
// ═════════════════════════════════════════════════════════════════════════════

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFCC0000), size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF636366),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.phone_rounded, color: Color(0xFFCC0000), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// INFO CARD
// ═════════════════════════════════════════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    this.large = false,
    this.color,
  });

  final String label;
  final String value;
  final bool large;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? Colors.white;
    final textColor = color != null ? Colors.white : const Color(0xFF1C1C1E);
    final labelColor = color != null ? Colors.white70 : const Color(0xFF636366);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 28 : 18,
              fontWeight: large ? FontWeight.w800 : FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
