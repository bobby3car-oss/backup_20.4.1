import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../domain/task_orchestrator_sync.dart';
import '../features/health_sync/health_sync_service.dart';
import '../features/pro/data/entitlement_service.dart';
import '../features/pro/domain/entitlement.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../firebase/firebase_paths.dart';
import '../main.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Section enum for per-section editing
// ─────────────────────────────────────────────────────────────────────────────

enum _Section { personal, op, health, emergency }

// ─────────────────────────────────────────────────────────────────────────────

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _opTypeCtrl;
  late final TextEditingController _opModusCtrl;
  late final TextEditingController _hospitalCtrl;
  late final TextEditingController _doctorNameCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _emergencyNameCtrl;
  late final TextEditingController _emergencyPhoneCtrl;
  DateTime _birthdate = DateTime(1990, 1, 1);
  DateTime? _opDate;
  String? _smokerStatus;
  List<String> _preExistingConditions = [];
  List<String> _allergies = [];
  List<String> _currentMedications = [];

  bool _pinEnabled = false;
  bool _faceIdEnabled = true;
  bool _healthSyncEnabled = false;
  bool _healthSyncLoading = true;
  _Section? _editingSection;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _opTypeCtrl = TextEditingController();
    _opModusCtrl = TextEditingController();
    _hospitalCtrl = TextEditingController();
    _doctorNameCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _emergencyNameCtrl = TextEditingController();
    _emergencyPhoneCtrl = TextEditingController();
    _loadProfile();
    _loadHealthSyncState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _opTypeCtrl.dispose();
    _opModusCtrl.dispose();
    _hospitalCtrl.dispose();
    _doctorNameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .doc(FirestorePaths.userDoc(uid))
          .get();
      if (!mounted) return;
      final data = doc.data();
      if (data != null) {
        final raw = data['birthDate'];
        if (raw is Timestamp) {
          _birthdate = raw.toDate();
        } else if (raw is String && raw.isNotEmpty) {
          _birthdate = DateTime.tryParse(raw) ?? _birthdate;
        }
        if (data['opType'] is String) {
          _opTypeCtrl.text = data['opType'] as String;
        }
        if (data['opModus'] is String) {
          _opModusCtrl.text = data['opModus'] as String;
        }
        final rawOp = data['opDate'];
        if (rawOp is Timestamp) {
          _opDate = rawOp.toDate();
        } else if (rawOp is String && rawOp.isNotEmpty) {
          _opDate = DateTime.tryParse(rawOp);
        }
        if (data['hospitalName'] is String) {
          _hospitalCtrl.text = data['hospitalName'] as String;
        }
        if (data['doctorName'] is String) {
          _doctorNameCtrl.text = data['doctorName'] as String;
        }
        if (data['weight'] is num) {
          _weightCtrl.text = (data['weight'] as num).toString();
        }
        if (data['height'] is num) {
          _heightCtrl.text = (data['height'] as num).toString();
        }
        if (data['smokerStatus'] is String) {
          _smokerStatus = data['smokerStatus'] as String;
        }
        if (data['emergencyContactName'] is String) {
          _emergencyNameCtrl.text = data['emergencyContactName'] as String;
        }
        if (data['emergencyContactPhone'] is String) {
          _emergencyPhoneCtrl.text = data['emergencyContactPhone'] as String;
        }
        if (data['preExistingConditions'] is List) {
          _preExistingConditions =
              List<String>.from(data['preExistingConditions'] as List);
        }
        if (data['allergies'] is List) {
          _allergies = List<String>.from(data['allergies'] as List);
        }
        if (data['currentMedications'] is List) {
          _currentMedications =
              List<String>.from(data['currentMedications'] as List);
        }
      }
      setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isSaving = true);
    try {
      final newName = _nameCtrl.text.trim();
      if (newName.isNotEmpty && newName != user.displayName) {
        await user.updateDisplayName(newName);
      }
      await FirebaseFirestore.instance
          .doc(FirestorePaths.userDoc(user.uid))
          .set(<String, dynamic>{
        'displayName': newName,
        'birthDate': _birthdate.toIso8601String(),
        'opType': _opTypeCtrl.text.trim(),
        'opModus': _opModusCtrl.text.trim(),
        'opDate': _opDate?.toIso8601String(),
        'hospitalName': _hospitalCtrl.text.trim(),
        'doctorName': _doctorNameCtrl.text.trim(),
        'weight': double.tryParse(_weightCtrl.text.trim()),
        'height': double.tryParse(_heightCtrl.text.trim()),
        'smokerStatus': _smokerStatus,
        'emergencyContactName': _emergencyNameCtrl.text.trim(),
        'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
        'preExistingConditions': _preExistingConditions,
        'allergies': _allergies,
        'currentMedications': _currentMedications,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (_opDate != null) {
        try {
          await TaskOrchestratorSync.instance.setOperationDate(_opDate!);
        } catch (e) {
          debugPrint('[ProfileSettings] setOperationDate failed: $e');
        }
      }

      if (mounted) {
        setState(() => _editingSection = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil gespeichert')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _loadHealthSyncState() async {
    final enabled = await HealthSyncService.instance.isEnabled;
    if (mounted) {
      setState(() {
        _healthSyncEnabled = enabled;
        _healthSyncLoading = false;
      });
    }
  }

  Future<void> _toggleHealthSync(bool value) async {
    if (value) {
      final pro = ProServices.maybeOf(context);
      if (pro == null || !pro.entitlementService.isPro) {
        if (context.mounted) {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.healthSyncFeature,
          );
        }
        return;
      }

      if (!HealthSyncService.instance.isSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Health-Sync wird auf diesem Gerät nicht unterstützt.'),
            ),
          );
        }
        return;
      }

      final granted = await HealthSyncService.instance.requestAuthorization();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Berechtigung für Gesundheitsdaten wurde nicht erteilt.'),
            ),
          );
        }
        return;
      }
    }

    await HealthSyncService.instance.setEnabled(value);
    if (mounted) setState(() => _healthSyncEnabled = value);
  }

  // ── Completion ─────────────────────────────────────────────────────────────

  double _calcCompletion() {
    int filled = 0;
    const total = 11;
    if (_nameCtrl.text.trim().isNotEmpty) filled++;
    if (_emailCtrl.text.trim().isNotEmpty) filled++;
    if (_birthdate.year != 1990) filled++;
    if (_opTypeCtrl.text.trim().isNotEmpty) filled++;
    if (_opDate != null) filled++;
    if (_opModusCtrl.text.trim().isNotEmpty) filled++;
    if (_hospitalCtrl.text.trim().isNotEmpty) filled++;
    if (_doctorNameCtrl.text.trim().isNotEmpty) filled++;
    if (_weightCtrl.text.trim().isNotEmpty) filled++;
    if (_heightCtrl.text.trim().isNotEmpty) filled++;
    if (_emergencyNameCtrl.text.trim().isNotEmpty) filled++;
    return filled / total;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int? _calcAge() {
    if (_birthdate.year == 1990 &&
        _birthdate.month == 1 &&
        _birthdate.day == 1) {
      return null;
    }
    final now = DateTime.now();
    int age = now.year - _birthdate.year;
    if (now.month < _birthdate.month ||
        (now.month == _birthdate.month && now.day < _birthdate.day)) {
      age--;
    }
    return age;
  }

  double? _calcBmi() {
    final w = double.tryParse(_weightCtrl.text.trim());
    final h = double.tryParse(_heightCtrl.text.trim());
    if (w == null || h == null || h <= 0) return null;
    final hMeters = h / 100;
    return w / (hMeters * hMeters);
  }

  int? _opCountdown() {
    if (_opDate == null) return null;
    final diff = _opDate!.difference(DateTime.now()).inDays;
    return diff;
  }

  bool _isEditingSection(_Section s) => _editingSection == s;

  void _toggleSection(_Section s) {
    setState(() {
      if (_editingSection == s) {
        _editingSection = null;
      } else {
        _editingSection = s;
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final completion = _calcCompletion();

    return GlassPage(
      title: 'Profil',
      titleIcon: AppIcons.profile,
      titleColor: AppColors.primary,
      children: [
        // ── Hero Card ──
        FadeSlideIn(
          child: _ProfileHeroCard(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            completion: completion,
            age: _calcAge(),
            bmi: _calcBmi(),
            opCountdown: _opCountdown(),
            entitlementService:
                ProServices.maybeOf(context)?.entitlementService,
            onBadgeTap: () {
              final pro = ProServices.maybeOf(context);
              if (pro != null && pro.entitlementService.isPro) {
                Navigator.of(context).pushNamed('/pro-status');
              } else {
                SmartPaywall.trigger(
                  context: context,
                  triggerContext: TriggerContext.manualOpen,
                );
              }
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Personal Data ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _EditableSection(
            icon: Icons.person_rounded,
            iconColor: AppColors.primary,
            title: 'Persönliche Daten',
            isEditing: _isEditingSection(_Section.personal),
            onEditToggle: () => _toggleSection(_Section.personal),
            onSave: _isSaving ? null : _saveProfile,
            child: _PersonalDataSection(
              nameCtrl: _nameCtrl,
              emailCtrl: _emailCtrl,
              birthdate: _birthdate,
              isEditing: _isEditingSection(_Section.personal),
              onBirthdateTap: _pickBirthdate,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── OP Information ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: _EditableSection(
            icon: Icons.medical_services_rounded,
            iconColor: AppColors.accent,
            title: 'OP-Informationen',
            isEditing: _isEditingSection(_Section.op),
            onEditToggle: () => _toggleSection(_Section.op),
            onSave: _isSaving ? null : _saveProfile,
            child: _OpInfoSection(
              opTypeCtrl: _opTypeCtrl,
              opModusCtrl: _opModusCtrl,
              opDate: _opDate,
              hospitalCtrl: _hospitalCtrl,
              doctorNameCtrl: _doctorNameCtrl,
              isEditing: _isEditingSection(_Section.op),
              onOpDateTap: _pickOpDate,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Health & Body ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: _EditableSection(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.success,
            title: 'Körperwerte & Gesundheit',
            isEditing: _isEditingSection(_Section.health),
            onEditToggle: () => _toggleSection(_Section.health),
            onSave: _isSaving ? null : _saveProfile,
            child: _HealthSection(
              weightCtrl: _weightCtrl,
              heightCtrl: _heightCtrl,
              smokerStatus: _smokerStatus,
              preExistingConditions: _preExistingConditions,
              allergies: _allergies,
              currentMedications: _currentMedications,
              isEditing: _isEditingSection(_Section.health),
              onSmokerChanged: (v) => setState(() => _smokerStatus = v),
              onConditionsChanged: (v) =>
                  setState(() => _preExistingConditions = v),
              onAllergiesChanged: (v) => setState(() => _allergies = v),
              onMedicationsChanged: (v) =>
                  setState(() => _currentMedications = v),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Emergency Contact ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
          child: _EditableSection(
            icon: Icons.emergency_rounded,
            iconColor: AppColors.error,
            title: 'Notfallkontakt',
            isEditing: _isEditingSection(_Section.emergency),
            onEditToggle: () => _toggleSection(_Section.emergency),
            onSave: _isSaving ? null : _saveProfile,
            child: _EmergencySection(
              emergencyNameCtrl: _emergencyNameCtrl,
              emergencyPhoneCtrl: _emergencyPhoneCtrl,
              isEditing: _isEditingSection(_Section.emergency),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Security ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(context, 'Sicherheit'),
              const SizedBox(height: AppSpacing.md),
              _SecurityCard(
                pinEnabled: _pinEnabled,
                faceIdEnabled: _faceIdEnabled,
                onPinChanged: (v) => setState(() => _pinEnabled = v),
                onFaceIdChanged: (v) => setState(() => _faceIdEnabled = v),
                onChangePassword: () => _showChangePasswordSheet(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Health Sync ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 380),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(context, 'Health Sync'),
              const SizedBox(height: AppSpacing.md),
              _HealthSyncCard(
                enabled: _healthSyncEnabled,
                loading: _healthSyncLoading,
                onChanged: _toggleHealthSync,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Subscription ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(context, 'Abonnement'),
              const SizedBox(height: AppSpacing.md),
              _LiveSubscriptionCard(
                entitlementService:
                    ProServices.maybeOf(context)?.entitlementService,
                onUpgrade: () => SmartPaywall.trigger(
                  context: context,
                  triggerContext: TriggerContext.manualOpen,
                ),
                onManage: () =>
                    Navigator.of(context).pushNamed('/pro-status'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('de'),
    );
    if (picked != null && mounted) setState(() => _birthdate = picked);
  }

  Future<void> _pickOpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _opDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('de'),
    );
    if (picked != null && mounted) setState(() => _opDate = picked);
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HERO CARD with completion ring + stat chips
// ═════════════════════════════════════════════════════════════════════════════

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.email,
    required this.completion,
    this.age,
    this.bmi,
    this.opCountdown,
    this.entitlementService,
    this.onBadgeTap,
  });

  final String name;
  final String email;
  final double completion;
  final int? age;
  final double? bmi;
  final int? opCountdown;
  final EntitlementService? entitlementService;
  final VoidCallback? onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return GlassContainer(
      variant: GlassVariant.thick,
      elevation: GlassElevation.high,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with completion ring
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _CompletionRingPainter(completion),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials.isEmpty ? '?' : initials,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Dein Profil' : name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    // Pro / Free badge
                    _buildBadge(context),
                  ],
                ),
              ),
            ],
          ),

          // Completion percentage
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                completion >= 1.0
                    ? Icons.check_circle_rounded
                    : Icons.pie_chart_rounded,
                size: 14,
                color: completion >= 1.0
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                completion >= 1.0
                    ? 'Profil vollständig'
                    : 'Profil ${(completion * 100).round()}% ausgefüllt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: completion >= 1.0
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Stat chips row
          if (age != null || bmi != null || opCountdown != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(height: 1, color: AppColors.grey200),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (age != null)
                  _ProfileStatChip(
                    icon: Icons.cake_outlined,
                    label: '$age Jahre',
                    color: AppColors.primary,
                  ),
                if (age != null && (bmi != null || opCountdown != null))
                  const SizedBox(width: AppSpacing.sm),
                if (bmi != null)
                  _ProfileStatChip(
                    icon: Icons.monitor_weight_outlined,
                    label: 'BMI ${bmi!.toStringAsFixed(1)}',
                    color: AppColors.accent,
                  ),
                if (bmi != null && opCountdown != null)
                  const SizedBox(width: AppSpacing.sm),
                if (opCountdown != null)
                  _ProfileStatChip(
                    icon: opCountdown! > 0
                        ? Icons.event_outlined
                        : Icons.event_available_rounded,
                    label: opCountdown! > 0
                        ? 'OP in $opCountdown T.'
                        : opCountdown == 0
                            ? 'OP heute'
                            : 'OP vor ${opCountdown!.abs()} T.',
                    color: opCountdown! > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context) {
    if (entitlementService != null) {
      return ValueListenableBuilder<Entitlement>(
        valueListenable: entitlementService!.entitlement,
        builder: (context, ent, _) {
          final isPro = ent.isPro;
          return GestureDetector(
            onTap: onBadgeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                gradient: isPro ? AppColors.primaryGradient : null,
                color: isPro ? null : AppColors.grey200,
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPro
                        ? Icons.workspace_premium_rounded
                        : Icons.arrow_upward_rounded,
                    size: 12,
                    color: isPro ? AppColors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    isPro ? 'Pro Mitglied' : 'Upgrade auf Pro',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPro ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: AppColors.success),
          SizedBox(width: AppSpacing.xs),
          Text(
            'Verifiziert',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion ring painter ──────────────────────────────────────────────────

class _CompletionRingPainter extends CustomPainter {
  _CompletionRingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    const strokeWidth = 3.5;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.grey200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [
          AppColors.primary,
          Color(0xFF5AC8FA),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CompletionRingPainter old) => old.progress != progress;
}

// ── Profile stat chip ────────────────────────────────────────────────────────

class _ProfileStatChip extends StatelessWidget {
  const _ProfileStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EDITABLE SECTION wrapper
// ═════════════════════════════════════════════════════════════════════════════

class _EditableSection extends StatelessWidget {
  const _EditableSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isEditing,
    required this.onEditToggle,
    required this.onSave,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isEditing;
  final VoidCallback onEditToggle;
  final VoidCallback? onSave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with edit toggle
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.12),
                      iconColor.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PressableScale(
                onTap: onEditToggle,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isEditing
                        ? AppColors.primary.withValues(alpha: 0.10)
                        : AppColors.grey100,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Icon(
                    isEditing
                        ? Icons.close_rounded
                        : Icons.edit_rounded,
                    size: 16,
                    color: isEditing
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.lg),

          // Section content
          child,

          // Save button when editing
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.xl),
            GlassButton(
              onPressed: onSave,
              label: 'Speichern',
              icon: Icons.check_rounded,
              expand: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PERSONAL DATA SECTION
// ═════════════════════════════════════════════════════════════════════════════

class _PersonalDataSection extends StatelessWidget {
  const _PersonalDataSection({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.birthdate,
    required this.isEditing,
    required this.onBirthdateTap,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final DateTime birthdate;
  final bool isEditing;
  final VoidCallback onBirthdateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FieldRow(
          icon: Icons.person_outline_rounded,
          label: 'Name',
          child: isEditing
              ? _inlineField(nameCtrl)
              : Text(nameCtrl.text, style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.cake_outlined,
          label: 'Geburtsdatum',
          child: isEditing
              ? GestureDetector(
                  onTap: onBirthdateTap,
                  child: Row(
                    children: [
                      Text(_fmtDate(birthdate), style: _valueStyle),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.edit_calendar_rounded,
                          size: 16, color: AppColors.primary),
                    ],
                  ),
                )
              : Text(_fmtDate(birthdate), style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.email_outlined,
          label: 'E-Mail',
          child: isEditing
              ? _inlineField(emailCtrl,
                  keyboardType: TextInputType.emailAddress)
              : Text(emailCtrl.text, style: _valueStyle),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// OP INFO SECTION
// ═════════════════════════════════════════════════════════════════════════════

class _OpInfoSection extends StatelessWidget {
  const _OpInfoSection({
    required this.opTypeCtrl,
    required this.opModusCtrl,
    required this.opDate,
    required this.hospitalCtrl,
    required this.doctorNameCtrl,
    required this.isEditing,
    required this.onOpDateTap,
  });

  final TextEditingController opTypeCtrl;
  final TextEditingController opModusCtrl;
  final DateTime? opDate;
  final TextEditingController hospitalCtrl;
  final TextEditingController doctorNameCtrl;
  final bool isEditing;
  final VoidCallback onOpDateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FieldRow(
          icon: Icons.medical_services_outlined,
          label: 'OP-Art',
          child: isEditing
              ? _inlineField(opTypeCtrl)
              : Text(
                  opTypeCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : opTypeCtrl.text,
                  style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.event_outlined,
          label: 'OP-Datum',
          child: isEditing
              ? GestureDetector(
                  onTap: onOpDateTap,
                  child: Row(
                    children: [
                      Text(
                        opDate != null ? _fmtDate(opDate!) : 'Auswählen',
                        style: _valueStyle,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.edit_calendar_rounded,
                          size: 16, color: AppColors.primary),
                    ],
                  ),
                )
              : Text(
                  opDate != null ? _fmtDate(opDate!) : 'Nicht hinterlegt',
                  style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.settings_outlined,
          label: 'OP-Modus',
          child: isEditing
              ? _inlineField(opModusCtrl)
              : Text(
                  opModusCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : opModusCtrl.text,
                  style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.local_hospital_outlined,
          label: 'Klinik',
          child: isEditing
              ? _inlineField(hospitalCtrl)
              : Text(
                  hospitalCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : hospitalCtrl.text,
                  style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.person_outline_rounded,
          label: 'Arzt',
          child: isEditing
              ? _inlineField(doctorNameCtrl)
              : Text(
                  doctorNameCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : doctorNameCtrl.text,
                  style: _valueStyle),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HEALTH SECTION with smoker segmented + chip tags
// ═════════════════════════════════════════════════════════════════════════════

class _HealthSection extends StatelessWidget {
  const _HealthSection({
    required this.weightCtrl,
    required this.heightCtrl,
    required this.smokerStatus,
    required this.preExistingConditions,
    required this.allergies,
    required this.currentMedications,
    required this.isEditing,
    required this.onSmokerChanged,
    required this.onConditionsChanged,
    required this.onAllergiesChanged,
    required this.onMedicationsChanged,
  });

  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;
  final String? smokerStatus;
  final List<String> preExistingConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final bool isEditing;
  final ValueChanged<String?> onSmokerChanged;
  final ValueChanged<List<String>> onConditionsChanged;
  final ValueChanged<List<String>> onAllergiesChanged;
  final ValueChanged<List<String>> onMedicationsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FieldRow(
          icon: Icons.monitor_weight_outlined,
          label: 'Gewicht',
          child: isEditing
              ? _inlineField(weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true))
              : Text(
                  weightCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : '${weightCtrl.text} kg',
                  style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.height_rounded,
          label: 'Größe',
          child: isEditing
              ? _inlineField(heightCtrl,
                  keyboardType: TextInputType.number)
              : Text(
                  heightCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : '${heightCtrl.text} cm',
                  style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.smoke_free_rounded,
          label: 'Raucher',
          child: isEditing
              ? _SmokerSegmentedPicker(
                  value: smokerStatus,
                  onChanged: onSmokerChanged,
                )
              : Text(smokerStatus ?? 'Nicht hinterlegt', style: _valueStyle),
        ),
        _divider(),
        _ChipTagsField(
          icon: Icons.healing_rounded,
          label: 'Vorerkrankungen',
          items: preExistingConditions,
          chipColor: AppColors.warning,
          isEditing: isEditing,
          onChanged: onConditionsChanged,
        ),
        _divider(),
        _ChipTagsField(
          icon: Icons.warning_amber_rounded,
          label: 'Allergien',
          items: allergies,
          chipColor: AppColors.error,
          isEditing: isEditing,
          onChanged: onAllergiesChanged,
        ),
        _divider(),
        _ChipTagsField(
          icon: Icons.medication_rounded,
          label: 'Medikamente',
          items: currentMedications,
          chipColor: AppColors.accent,
          isEditing: isEditing,
          onChanged: onMedicationsChanged,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EMERGENCY SECTION
// ═════════════════════════════════════════════════════════════════════════════

class _EmergencySection extends StatelessWidget {
  const _EmergencySection({
    required this.emergencyNameCtrl,
    required this.emergencyPhoneCtrl,
    required this.isEditing,
  });

  final TextEditingController emergencyNameCtrl;
  final TextEditingController emergencyPhoneCtrl;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FieldRow(
          icon: Icons.person_outline_rounded,
          label: 'Name',
          child: isEditing
              ? _inlineField(emergencyNameCtrl)
              : Text(
                  emergencyNameCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : emergencyNameCtrl.text,
                  style: _valueStyle),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.phone_outlined,
          label: 'Telefon',
          child: isEditing
              ? _inlineField(emergencyPhoneCtrl,
                  keyboardType: TextInputType.phone)
              : Text(
                  emergencyPhoneCtrl.text.isEmpty
                      ? 'Nicht hinterlegt'
                      : emergencyPhoneCtrl.text,
                  style: _valueStyle),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SMOKER SEGMENTED PICKER
// ═════════════════════════════════════════════════════════════════════════════

class _SmokerSegmentedPicker extends StatelessWidget {
  const _SmokerSegmentedPicker({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  static const _options = {
    'Nein': 'Nein',
    'Ja': 'Ja',
    'Ehemalig': 'Ehem.',
  };

  @override
  Widget build(BuildContext context) {
    final groupValue = value ?? 'Nein';
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<String>(
        groupValue: _options.containsKey(groupValue) ? groupValue : 'Nein',
        children: _options.map(
          (key, label) => MapEntry(
            key,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        onValueChanged: onChanged,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CHIP TAGS FIELD (for conditions, allergies, medications)
// ═════════════════════════════════════════════════════════════════════════════

class _ChipTagsField extends StatelessWidget {
  const _ChipTagsField({
    required this.icon,
    required this.label,
    required this.items,
    required this.chipColor,
    required this.isEditing,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final List<String> items;
  final Color chipColor;
  final bool isEditing;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 96,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (items.isEmpty && !isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text('Keine', style: _valueStyle),
                )
              else
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (int i = 0; i < items.length; i++)
                      _MedChip(
                        label: items[i],
                        color: chipColor,
                        onDelete: isEditing
                            ? () {
                                final newList = List<String>.from(items)
                                  ..removeAt(i);
                                onChanged(newList);
                              }
                            : null,
                      ),
                    if (isEditing)
                      GestureDetector(
                        onTap: () => _showAddDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: chipColor.withValues(alpha: 0.08),
                            borderRadius: AppRadius.borderRadiusPill,
                            border: Border.all(
                              color: chipColor.withValues(alpha: 0.25),
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 14, color: chipColor),
                              const SizedBox(width: 2),
                              Text(
                                'Hinzufügen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: chipColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$label hinzufügen'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Bezeichnung eingeben',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final text = value.trim();
            if (text.isNotEmpty) {
              onChanged([...items, text]);
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                onChanged([...items, text]);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}

// ── Med chip ─────────────────────────────────────────────────────────────────

class _MedChip extends StatelessWidget {
  const _MedChip({
    required this.label,
    required this.color,
    this.onDelete,
  });

  final String label;
  final Color color;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: onDelete != null ? AppSpacing.xs : AppSpacing.sm,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: AppSpacing.xxs),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close_rounded, size: 14, color: color),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SHARED field widgets
// ═════════════════════════════════════════════════════════════════════════════

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

Widget _inlineField(
  TextEditingController ctrl, {
  TextInputType? keyboardType,
}) {
  return SizedBox(
    height: 32,
    child: TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: _valueStyle,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 4),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    ),
  );
}

Widget _divider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Container(height: 1, color: AppColors.grey200),
  );
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.'
    '${d.year}';

const _valueStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
);

// ═════════════════════════════════════════════════════════════════════════════
// SECURITY CARD (unchanged functionality)
// ═════════════════════════════════════════════════════════════════════════════

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.pinEnabled,
    required this.faceIdEnabled,
    required this.onPinChanged,
    required this.onFaceIdChanged,
    required this.onChangePassword,
  });

  final bool pinEnabled;
  final bool faceIdEnabled;
  final ValueChanged<bool> onPinChanged;
  final ValueChanged<bool> onFaceIdChanged;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          _SecurityRow(
            icon: Icons.lock_outline_rounded,
            color: AppColors.accent,
            title: 'Passwort ändern',
            subtitle: 'Zuletzt geändert vor 30 Tagen',
            trailing: PressableScale(
              onTap: onChangePassword,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusPill,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.20),
                  ),
                ),
                child: const Text(
                  'Ändern',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
          _rowDivider(),
          _SecurityRow(
            icon: Icons.pin_outlined,
            color: AppColors.warning,
            title: 'PIN aktivieren',
            subtitle: '4-stelliger Zugangs-PIN',
            trailing: CupertinoSwitch(
              value: pinEnabled,
              activeTrackColor: AppColors.warning,
              onChanged: onPinChanged,
            ),
          ),
          _rowDivider(),
          _SecurityRow(
            icon: Icons.face_rounded,
            color: AppColors.success,
            title: 'Face ID / Touch ID',
            subtitle: 'Biometrische Entsperrung',
            trailing: CupertinoSwitch(
              value: faceIdEnabled,
              activeTrackColor: AppColors.success,
              onChanged: onFaceIdChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(height: 1, color: AppColors.grey200),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HEALTH SYNC CARD (unchanged functionality)
// ═════════════════════════════════════════════════════════════════════════════

class _HealthSyncCard extends StatelessWidget {
  const _HealthSyncCard({
    required this.enabled,
    required this.loading,
    required this.onChanged,
  });

  final bool enabled;
  final bool loading;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 20,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'Apple Health / Health Connect',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: AppRadius.borderRadiusPill,
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      const Text(
                        'Herzfrequenz, Blutdruck & Schritte automatisch synchronisieren',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  CupertinoSwitch(
                    value: enabled,
                    activeTrackColor: AppColors.success,
                    onChanged: onChanged,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LIVE SUBSCRIPTION CARD (unchanged functionality)
// ═════════════════════════════════════════════════════════════════════════════

class _LiveSubscriptionCard extends StatelessWidget {
  const _LiveSubscriptionCard({
    required this.entitlementService,
    required this.onUpgrade,
    required this.onManage,
  });

  final EntitlementService? entitlementService;
  final VoidCallback onUpgrade;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final service = entitlementService;
    if (service == null) {
      return _buildFreeCard(context);
    }

    return ValueListenableBuilder<Entitlement>(
      valueListenable: service.entitlement,
      builder: (context, ent, _) {
        if (ent.isPro) {
          return _buildProCard(context, ent);
        }
        return _buildFreeCard(context);
      },
    );
  }

  Widget _buildProCard(BuildContext context, Entitlement ent) {
    String planLabel;
    if (ent.proProductId?.contains('yearly') == true) {
      planLabel = 'Jahresabo';
    } else if (ent.proProductId?.contains('monthly') == true) {
      planLabel = 'Monatsabo';
    } else {
      planLabel = 'Pro Mitgliedschaft';
    }

    String? validUntil;
    if (ent.proExpiresAt != null) {
      final d = ent.proExpiresAt!;
      validUntil =
          '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.borderRadiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 24,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pro aktiv',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      planLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          if (validUntil != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(height: 1, color: AppColors.grey200),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Gültig bis $validUntil',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            onPressed: onManage,
            label: 'Abo verwalten',
            icon: Icons.settings_rounded,
            variant: GlassButtonVariant.secondary,
            expand: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFreeCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 24,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basis',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Grundfunktionen aktiv',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Schalte alle Funktionen frei – Analysen, '
                  'Sprach-Memos, Angehörige einladen und mehr.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            onPressed: onUpgrade,
            label: 'Pro entdecken',
            icon: Icons.workspace_premium_rounded,
            expand: true,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CHANGE PASSWORD SHEET (unchanged functionality)
// ═════════════════════════════════════════════════════════════════════════════

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentCtrl.text;
    final newPw = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty || newPw.isEmpty) return;
    if (newPw != confirm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwörter stimmen nicht überein')),
      );
      return;
    }
    if (newPw.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mindestens 6 Zeichen')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPw);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort geändert')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'wrong-password'
          ? 'Aktuelles Passwort ist falsch'
          : 'Fehler: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          top: AppSpacing.xxl,
          bottom: AppSpacing.xxl + bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 28,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Passwort ändern',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xxl),

            GlassTextField(
              controller: _currentCtrl,
              label: 'Aktuelles Passwort',
              prefixIcon: Icons.lock_rounded,
              obscureText: _obscureCurrent,
              suffixIcon: _visibilityToggle(
                _obscureCurrent,
                () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassTextField(
              controller: _newCtrl,
              label: 'Neues Passwort',
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscureNew,
              suffixIcon: _visibilityToggle(
                _obscureNew,
                () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassTextField(
              controller: _confirmCtrl,
              label: 'Passwort bestätigen',
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirm,
              suffixIcon: _visibilityToggle(
                _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
            GlassButton(
              onPressed: _isSaving ? null : _changePassword,
              label: 'Passwort speichern',
              icon: Icons.check_rounded,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Abbrechen',
              variant: GlassButtonVariant.ghost,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _visibilityToggle(bool obscured, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        size: 20,
        color: AppColors.grey500,
      ),
    );
  }
}
