import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/health_sync/health_sync_service.dart';
import '../features/pro/data/entitlement_service.dart';
import '../features/pro/domain/entitlement.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../firebase/firebase_paths.dart';
import '../main.dart';
import '../ui/ui.dart';

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
  DateTime _birthdate = DateTime(1990, 1, 1);
  DateTime? _opDate;

  bool _pinEnabled = false;
  bool _faceIdEnabled = true;
  bool _healthSyncEnabled = false;
  bool _healthSyncLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _opTypeCtrl = TextEditingController();
    _opModusCtrl = TextEditingController();
    _loadProfile();
    _loadHealthSyncState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _opTypeCtrl.dispose();
    _opModusCtrl.dispose();
    super.dispose();
  }

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
        if (data['opType'] is String) _opTypeCtrl.text = data['opType'] as String;
        if (data['opModus'] is String) _opModusCtrl.text = data['opModus'] as String;
        final rawOp = data['opDate'];
        if (rawOp is Timestamp) {
          _opDate = rawOp.toDate();
        } else if (rawOp is String && rawOp.isNotEmpty) {
          _opDate = DateTime.tryParse(rawOp);
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
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        setState(() => _isEditing = false);
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
      // PRO gate
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

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Profil',
      titleEmoji: '👤',
      titleColor: AppColors.primary,
      children: [
        _AvatarHeader(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
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
        const SizedBox(height: AppSpacing.xxl),

        // ── Personal data ──
        _sectionTitle(context, 'Persönliche Daten'),
        const SizedBox(height: AppSpacing.md),
        _PersonalDataCard(
          nameCtrl: _nameCtrl,
          emailCtrl: _emailCtrl,
          birthdate: _birthdate,
          opTypeCtrl: _opTypeCtrl,
          opModusCtrl: _opModusCtrl,
          opDate: _opDate,
          isEditing: _isEditing,
          onBirthdateTap: _pickBirthdate,
          onOpDateTap: _pickOpDate,
          onEditToggle: () {
            setState(() => _isEditing = !_isEditing);
          },
          onSave: _isSaving ? null : _saveProfile,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Security ──
        _sectionTitle(context, 'Sicherheit'),
        const SizedBox(height: AppSpacing.md),
        _SecurityCard(
          pinEnabled: _pinEnabled,
          faceIdEnabled: _faceIdEnabled,
          onPinChanged: (v) => setState(() => _pinEnabled = v),
          onFaceIdChanged: (v) => setState(() => _faceIdEnabled = v),
          onChangePassword: () => _showChangePasswordSheet(context),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Health Sync ──
        _sectionTitle(context, 'Health Sync'),
        const SizedBox(height: AppSpacing.md),
        _HealthSyncCard(
          enabled: _healthSyncEnabled,
          loading: _healthSyncLoading,
          onChanged: _toggleHealthSync,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Subscription ──
        _sectionTitle(context, 'Abonnement'),
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
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
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
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _pickOpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _opDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('de'),
    );
    if (picked != null) setState(() => _opDate = picked);
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

// ── Avatar header ────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({
    required this.name,
    required this.email,
    this.entitlementService,
    this.onBadgeTap,
  });

  final String name;
  final String email;
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(email, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                if (entitlementService != null)
                  ValueListenableBuilder<Entitlement>(
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
                            gradient: isPro
                                ? AppColors.primaryGradient
                                : null,
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
                                color: isPro
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                isPro ? 'Pro Mitglied' : 'Upgrade auf Pro',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isPro
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
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
                        Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: AppColors.success,
                        ),
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Personal data card ───────────────────────────────────────────────────────

class _PersonalDataCard extends StatelessWidget {
  const _PersonalDataCard({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.birthdate,
    required this.opTypeCtrl,
    required this.opModusCtrl,
    required this.opDate,
    required this.isEditing,
    required this.onBirthdateTap,
    required this.onOpDateTap,
    required this.onEditToggle,
    required this.onSave,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final DateTime birthdate;
  final TextEditingController opTypeCtrl;
  final TextEditingController opModusCtrl;
  final DateTime? opDate;
  final bool isEditing;
  final VoidCallback onBirthdateTap;
  final VoidCallback onOpDateTap;
  final VoidCallback onEditToggle;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
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
                        const Icon(
                          Icons.edit_calendar_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
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
                ? _inlineField(
                    emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  )
                : Text(emailCtrl.text, style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.medical_services_outlined,
            label: 'OP-Art',
            child: isEditing
                ? _inlineField(opTypeCtrl)
                : Text(
                    opTypeCtrl.text.isEmpty
                        ? 'Nicht hinterlegt'
                        : opTypeCtrl.text,
                    style: _valueStyle,
                  ),
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
                        const Icon(
                          Icons.edit_calendar_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  )
                : Text(
                    opDate != null ? _fmtDate(opDate!) : 'Nicht hinterlegt',
                    style: _valueStyle,
                  ),
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
                    style: _valueStyle,
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            onPressed: isEditing ? onSave : onEditToggle,
            label: isEditing ? 'Speichern' : 'Bearbeiten',
            icon: isEditing ? Icons.check_rounded : Icons.edit_rounded,
            variant: isEditing
                ? GlassButtonVariant.primary
                : GlassButtonVariant.ghost,
            expand: true,
          ),
        ],
      ),
    );
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

  static const _valueStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

// ── Field row ────────────────────────────────────────────────────────────────

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

// ── Security card ────────────────────────────────────────────────────────────

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
            trailing: GestureDetector(
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

// ── Health Sync card ─────────────────────────────────────────────────────────

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
                          const Text(
                            'Apple Health / Health Connect',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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

// ── Live subscription card ───────────────────────────────────────────────────

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
                Icon(
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

// ── Change password sheet ────────────────────────────────────────────────────

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
