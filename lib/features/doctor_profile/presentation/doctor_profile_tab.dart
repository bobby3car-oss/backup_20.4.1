import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../features/doctor_staff/domain/staff_permissions.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Section enum for per-section editing
// ─────────────────────────────────────────────────────────────────────────────

enum _Section { personal, practice }

/// The profile & settings tab for the doctor account.
class DoctorProfileTab extends StatefulWidget {
  const DoctorProfileTab({super.key, this.isStaff = false, this.doctorUid});

  /// Whether the current user is a staff member.
  final bool isStaff;

  /// Doctor UID override for staff mode.
  final String? doctorUid;

  @override
  State<DoctorProfileTab> createState() => _DoctorProfileTabState();
}

class _DoctorProfileTabState extends State<DoctorProfileTab> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final DoctorPatientRepository _patientRepo;

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _busy = false;
  bool _loaded = false;
  _Section? _editingSection;
  late Stream<List<LinkedPatient>> _patientsStream;

  // Staff-specific data.
  String _doctorName = '';
  String _doctorSpecialty = '';
  StaffPermissions? _staffPermissions;

  @override
  void initState() {
    super.initState();
    _patientRepo = DoctorPatientRepository(
      overrideDoctorUid: widget.doctorUid,
    );
    _patientsStream = _patientRepo.watchLinkedPatients();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    final data = doc.data() ?? const <String, dynamic>{};

    _nameController.text = (data['displayName'] ?? '').toString();

    if (widget.isStaff) {
      // Load staff permissions from own user doc.
      if (data['staffPermissions'] != null) {
        _staffPermissions = StaffPermissions.fromMap(
          Map<String, dynamic>.from(data['staffPermissions'] as Map),
        );
      }
      // Load doctor info.
      if (widget.doctorUid != null) {
        final doctorDoc = await _firestore
            .doc(FirestorePaths.userDoc(widget.doctorUid!))
            .get();
        final dd = doctorDoc.data() ?? const <String, dynamic>{};
        _doctorName = (dd['displayName'] ?? '').toString();
        _doctorSpecialty = (dd['specialty'] ?? '').toString();
      }
    } else {
      _specialtyController.text = (data['specialty'] ?? '').toString();
      _addressController.text = (data['practiceAddress'] ?? '').toString();
      _phoneController.text = (data['phone'] ?? '').toString();
    }

    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _busy = true);
    try {
      await _firestore.doc(FirestorePaths.userDoc(uid)).set(
        <String, dynamic>{
          'displayName': _nameController.text.trim(),
          'specialty': _specialtyController.text.trim(),
          'practiceAddress': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (mounted) {
        Haptic.medium();
        setState(() => _editingSection = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil gespeichert')),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorProfileTab] save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil konnte nicht gespeichert werden.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  bool _isEditingSection(_Section s) => _editingSection == s;

  void _toggleSection(_Section s) {
    Haptic.light();
    setState(() {
      if (_editingSection == s) {
        _editingSection = null;
      } else {
        _editingSection = s;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? '';

    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.isStaff) return _buildStaffProfile(context, email);

    return GlassPage(
      title: 'Mein Profil',
      titleEmoji: '👨‍⚕️',
      titleColor: AppColors.primary,
      showBackButton: false,
      children: [
        // ── Hero Header ────────────────────────────────
        FadeSlideIn(
          child: _DoctorHeroCard(
            name: _nameController.text.trim(),
            email: email,
            initials: _initials,
            specialty: _specialtyController.text.trim(),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Section: Personal ──────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _EditableSection(
            icon: Icons.person_rounded,
            iconColor: AppColors.primary,
            title: 'Persönliche Daten',
            isEditing: _isEditingSection(_Section.personal),
            onEditToggle: () => _toggleSection(_Section.personal),
            onSave: _busy ? null : _saveProfile,
            child: Column(
              children: [
                _FieldRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  child: _isEditingSection(_Section.personal)
                      ? _inlineField(_nameController,
                          onChanged: () => setState(() {}))
                      : Text(_nameController.text, style: _valueStyle),
                ),
                _divider(),
                _FieldRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Fachrichtung',
                  child: _isEditingSection(_Section.personal)
                      ? _inlineField(_specialtyController)
                      : Text(
                          _specialtyController.text.isEmpty
                              ? 'Nicht hinterlegt'
                              : _specialtyController.text,
                          style: _valueStyle),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Section: Practice ──────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: _EditableSection(
            icon: Icons.local_hospital_rounded,
            iconColor: AppColors.accent,
            title: 'Praxisinformationen',
            isEditing: _isEditingSection(_Section.practice),
            onEditToggle: () => _toggleSection(_Section.practice),
            onSave: _busy ? null : _saveProfile,
            child: Column(
              children: [
                _FieldRow(
                  icon: Icons.location_on_outlined,
                  label: 'Adresse',
                  child: _isEditingSection(_Section.practice)
                      ? _inlineField(_addressController)
                      : Text(
                          _addressController.text.isEmpty
                              ? 'Nicht hinterlegt'
                              : _addressController.text,
                          style: _valueStyle),
                ),
                _divider(),
                _FieldRow(
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  child: _isEditingSection(_Section.practice)
                      ? _inlineField(_phoneController,
                          keyboardType: TextInputType.phone)
                      : Text(
                          _phoneController.text.isEmpty
                              ? 'Nicht hinterlegt'
                              : _phoneController.text,
                          style: _valueStyle),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Section: Linked patients ───────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.10),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(Icons.people_rounded,
                          size: 16, color: AppColors.success),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Verknüpfte Patienten',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _PatientsListCard(
                patientsStream: _patientsStream,
                patientRepo: _patientRepo,
                onRetry: () => setState(() {
                  _patientsStream = _patientRepo.watchLinkedPatients();
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Logout ─────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
          child: GlassButton(
            onPressed: () => AuthService().signOut(),
            icon: Icons.logout_rounded,
            label: 'Abmelden',
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildStaffProfile(BuildContext context, String email) {
    final theme = Theme.of(context);
    final p = _staffPermissions;
    final name = _nameController.text.trim();

    return GlassPage(
      title: 'Mein Profil',
      titleEmoji: '👩‍💼',
      titleColor: AppColors.primary,
      showBackButton: false,
      children: [
        // ── Staff Hero ─────────────────────────────────
        FadeSlideIn(
          child: GlassContainer(
            variant: GlassVariant.thick,
            elevation: GlassElevation.high,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            borderRadius: AppRadius.borderRadiusXl,
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Mitarbeiter/in' : name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13,
                        )),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: AppRadius.borderRadiusPill,
                        ),
                        child: Text(
                          'Mitarbeiter/in',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Doctor Info (read-only) ────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(Icons.local_hospital_rounded,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Praxis', style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  children: [
                    _FieldRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Arzt',
                      child: Text(
                        _doctorName.isEmpty ? '–' : _doctorName,
                        style: _valueStyle,
                      ),
                    ),
                    if (_doctorSpecialty.isNotEmpty) ...[
                      _divider(),
                      _FieldRow(
                        icon: Icons.medical_services_outlined,
                        label: 'Fachrichtung',
                        child: Text(_doctorSpecialty, style: _valueStyle),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Permissions overview ───────────────────────
        if (p != null)
          FadeSlideIn(
            delay: const Duration(milliseconds: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.10),
                          borderRadius: AppRadius.borderRadiusSm,
                        ),
                        child: const Icon(Icons.security_rounded,
                            size: 16, color: AppColors.warning),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Meine Berechtigungen',
                          style: theme.textTheme.titleLarge),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    children: StaffPermissions.featureLabels.entries
                        .map((entry) {
                      final level = p[entry.key];
                      final levelLabel =
                          StaffPermissions.accessLevelLabels[level] ?? '–';
                      final color = switch (level) {
                        StaffAccessLevel.readWrite => AppColors.success,
                        StaffAccessLevel.read => AppColors.primary,
                        StaffAccessLevel.none => AppColors.grey400,
                      };
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(entry.value,
                                  style: theme.textTheme.bodyMedium),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: AppRadius.borderRadiusPill,
                              ),
                              child: Text(
                                levelLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Logout ─────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: GlassButton(
            onPressed: () => AuthService().signOut(),
            icon: Icons.logout_rounded,
            label: 'Abmelden',
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DOCTOR HERO CARD with gradient background + specialty badge
// ═════════════════════════════════════════════════════════════════════════════

class _DoctorHeroCard extends StatelessWidget {
  const _DoctorHeroCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.specialty,
  });

  final String name;
  final String email;
  final String initials;
  final String specialty;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.thick,
      elevation: GlassElevation.high,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
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
                initials,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
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
                if (specialty.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.medical_services_rounded,
                            size: 12, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            specialty,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EDITABLE SECTION wrapper (same pattern as patient profile)
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
                    isEditing ? Icons.close_rounded : Icons.edit_rounded,
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
          child,
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
// PATIENTS LIST CARD
// ═════════════════════════════════════════════════════════════════════════════

class _PatientsListCard extends StatelessWidget {
  const _PatientsListCard({
    required this.patientsStream,
    required this.patientRepo,
    required this.onRetry,
  });

  final Stream<List<LinkedPatient>> patientsStream;
  final DoctorPatientRepository patientRepo;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LinkedPatient>>(
      stream: patientsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.borderRadiusXl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 24),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Patientenliste konnte nicht geladen werden.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Erneut versuchen'),
                ),
              ],
            ),
          );
        }
        final patients = snapshot.data ?? [];
        if (patients.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.borderRadiusXl,
            child: Row(
              children: [
                Icon(Icons.person_off_rounded,
                    color: AppColors.grey400, size: 24),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Keine Patienten verknüpft.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          borderRadius: AppRadius.borderRadiusXl,
          child: Column(
            children: [
              for (int i = 0; i < patients.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Container(height: 1, color: AppColors.grey200),
                  ),
                _PatientRow(
                  patient: patients[i],
                  patientRepo: patientRepo,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({
    required this.patient,
    required this.patientRepo,
  });

  final LinkedPatient patient;
  final DoctorPatientRepository patientRepo;

  @override
  Widget build(BuildContext context) {
    final initials = _calcInitials(patient.displayName);

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
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  patient.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.link_off, color: AppColors.error),
            tooltip: 'Verbindung trennen',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Verbindung trennen?'),
                  content: Text(
                    'Die Verbindung zu ${patient.displayName} wird getrennt.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Abbrechen'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Trennen'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                Haptic.medium();
                await patientRepo.unlinkPatient(patient.uid);
              }
            },
          ),
        ],
      ),
    );
  }

  String _calcInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
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
  VoidCallback? onChanged,
}) {
  return SizedBox(
    height: 32,
    child: TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: _valueStyle,
      onChanged: onChanged != null ? (_) => onChanged() : null,
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

const _valueStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
);
