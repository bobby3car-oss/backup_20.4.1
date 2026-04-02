import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/auth_service.dart';
import '../../../features/doctor_staff/domain/staff_permissions.dart';
import '../../../features/organisation/presentation/join_org_sheet.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../screens/help_screen.dart';
import '../../../screens/notification_settings_screen.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

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

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _tagController = TextEditingController();

  bool _busy = false;
  bool _loaded = false;
  _Section? _editingSection;

  // Verification & credentials (from doctors/{uid} workspace doc).
  bool _verified = false;
  String _approbationNumber = '';
  String _kvNumber = '';
  String _practiceName = '';

  // New profile fields.
  String? _profileImageUrl;
  bool _uploadingImage = false;
  List<String> _specialtyTags = [];
  Map<String, _OpeningHoursEntry> _openingHours = {};

  // Organisation membership.
  bool _hasOrg = false;

  // Staff-specific data.
  String _doctorName = '';
  String _doctorSpecialty = '';
  StaffPermissions? _staffPermissions;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loaded = true);
      return;
    }

    try {
      final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
      final data = doc.data() ?? const <String, dynamic>{};

      _nameController.text = (data['displayName'] ?? '').toString();

      _verified = data['doctorVerified'] == true;
      _hasOrg = data['orgId'] != null &&
          (data['orgId'] as String).isNotEmpty;

      if (widget.isStaff) {
        // Load staff permissions from own user doc.
        if (data['staffPermissions'] != null) {
          _staffPermissions = StaffPermissions.fromMap(
            Map<String, dynamic>.from(data['staffPermissions'] as Map),
          );
        }
        // Load doctor info.
        if (widget.doctorUid != null) {
          try {
            final doctorDoc = await _firestore
                .doc(FirestorePaths.userDoc(widget.doctorUid!))
                .get();
            final dd = doctorDoc.data() ?? const <String, dynamic>{};
            _doctorName = (dd['displayName'] ?? '').toString();
            _doctorSpecialty = (dd['specialty'] ?? '').toString();
          } catch (_) {
            // Doctor doc may not be readable yet.
          }
        }
      } else {
        _specialtyController.text = (data['specialty'] ?? '').toString();
        _addressController.text = (data['practiceAddress'] ?? '').toString();
        _phoneController.text = (data['phone'] ?? '').toString();

        // Load credentials from doctors/{uid} workspace doc.
        try {
          final wsDoc = await _firestore.doc('doctors/$uid').get();
          final ws = wsDoc.data() ?? const <String, dynamic>{};
          _approbationNumber = (ws['approbationNumber'] ?? '').toString();
          _kvNumber = (ws['kvNumber'] ?? '').toString();
          _practiceName = (ws['practiceName'] ?? '').toString();
          _profileImageUrl = ws['profileImageUrl'] as String?;
          _websiteController.text = (ws['website'] ?? '').toString();
          if (ws['specialtyTags'] is List) {
            _specialtyTags = List<String>.from(ws['specialtyTags'] as List);
          }
          if (ws['openingHours'] is Map) {
            final raw = Map<String, dynamic>.from(ws['openingHours'] as Map);
            _openingHours = raw.map((k, v) {
              final m = Map<String, dynamic>.from(v as Map);
              return MapEntry(k, _OpeningHoursEntry(
                from: TimeOfDay(
                  hour: (m['fromHour'] as int?) ?? 8,
                  minute: (m['fromMinute'] as int?) ?? 0,
                ),
                to: TimeOfDay(
                  hour: (m['toHour'] as int?) ?? 17,
                  minute: (m['toMinute'] as int?) ?? 0,
                ),
              ));
            });
          }
        } catch (_) {
          // Workspace doc may not exist for legacy accounts.
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorProfileTab] load error: $e');
    }

    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _busy = true);
    try {
      // Save personal data to users/{uid}.
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

      // Save practice data to doctors/{uid}.
      final ohMap = <String, dynamic>{};
      for (final entry in _openingHours.entries) {
        ohMap[entry.key] = {
          'fromHour': entry.value.from.hour,
          'fromMinute': entry.value.from.minute,
          'toHour': entry.value.to.hour,
          'toMinute': entry.value.to.minute,
        };
      }
      await _firestore.doc('doctors/$uid').set(
        <String, dynamic>{
          'website': _websiteController.text.trim(),
          'specialtyTags': _specialtyTags,
          'openingHours': ohMap,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        final l = AppLocalizations.of(context)!;
        Haptic.medium();
        setState(() => _editingSection = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.profileSaved)),
        );
      }
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (kDebugMode) debugPrint('[DoctorProfileTab] save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l.profileSaveError)),
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
    _websiteController.dispose();
    _tagController.dispose();
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

  Future<void> _pickAndUploadImage() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploadingImage = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('doctors/$uid/profile.jpg');
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(picked.path));
      }
      final url = await ref.getDownloadURL();

      await _firestore.doc('doctors/$uid').set(
        <String, dynamic>{'profileImageUrl': url},
        SetOptions(merge: true),
      );
      if (mounted) {
        setState(() => _profileImageUrl = url);
        Haptic.medium();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorProfileTab] image upload error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.doctorProfileImageUploadError)),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || _specialtyTags.contains(trimmed)) return;
    setState(() => _specialtyTags.add(trimmed));
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _specialtyTags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final email = _auth.currentUser?.email ?? '';

    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.isStaff) return _buildStaffProfile(context, email);

    return GlassPage(
      title: l.meinProfil,
      titleIcon: AppIcons.doctor,
      titleColor: AppColors.primary,
      showBackButton: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return _buildDesktopLayout(l, email);
          }
          return _buildMobileLayout(l, email);
        },
      ),
    );
  }

  // ── Desktop: 2-column layout ──────────────────────────────────

  Widget _buildDesktopLayout(AppLocalizations l, String email) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: personal data + profile image
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroCard(email),
              const SizedBox(height: AppSpacing.xxl),
              _buildPersonalSection(l),
              const SizedBox(height: AppSpacing.lg),
              if (_approbationNumber.isNotEmpty ||
                  _kvNumber.isNotEmpty ||
                  _practiceName.isNotEmpty)
                _buildCredentialsSection(),
              const SizedBox(height: AppSpacing.xxl),
              ..._buildAccountSupportSection(delay: 220),
              const SizedBox(height: AppSpacing.xxxl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: GlassButton(
                  onPressed: () => AuthService().signOut(),
                  icon: Icons.logout_rounded,
                  label: l.logout,
                  variant: GlassButtonVariant.ghost,
                  expand: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xxl),
        // Right column: practice data + opening hours
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPracticeSection(l),
              const SizedBox(height: AppSpacing.lg),
              _buildOpeningHoursSection(l),
              const SizedBox(height: AppSpacing.lg),
              _buildSpecialtyTagsSection(l),
              if (_verified && !_hasOrg && !widget.isStaff) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildOrgJoinCard(l),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile: linear layout ─────────────────────────────────────

  Widget _buildMobileLayout(AppLocalizations l, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroCard(email),
        const SizedBox(height: AppSpacing.xxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _buildPersonalSection(l),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: _buildPracticeSection(l),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: _buildOpeningHoursSection(l),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 180),
          child: _buildSpecialtyTagsSection(l),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_approbationNumber.isNotEmpty ||
            _kvNumber.isNotEmpty ||
            _practiceName.isNotEmpty) ...[
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: _buildCredentialsSection(),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        if (_verified && !_hasOrg && !widget.isStaff) ...[
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: _buildOrgJoinCard(l),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ..._buildAccountSupportSection(delay: 240),
        const SizedBox(height: AppSpacing.xxxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 280),
          child: GlassButton(
            onPressed: () => AuthService().signOut(),
            icon: Icons.logout_rounded,
            label: l.logout,
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ── Hero card ─────────────────────────────────────────────────

  Widget _buildHeroCard(String email) {
    return FadeSlideIn(
      child: _DoctorHeroCard(
        name: _nameController.text.trim(),
        email: email,
        initials: _initials,
        specialty: _specialtyController.text.trim(),
        verified: _verified,
        profileImageUrl: _profileImageUrl,
        uploadingImage: _uploadingImage,
        onPickImage: _pickAndUploadImage,
      ),
    );
  }

  // ── Personal section ──────────────────────────────────────────

  Widget _buildPersonalSection(AppLocalizations l) {
    return _EditableSection(
      icon: Icons.person_rounded,
      iconColor: AppColors.primary,
      title: l.doctorRegPersonalData,
      isEditing: _isEditingSection(_Section.personal),
      onEditToggle: () => _toggleSection(_Section.personal),
      onSave: _busy ? null : _saveProfile,
      child: Column(
        children: [
          _FieldRow(
            icon: Icons.person_outline_rounded,
            label: l.fieldName,
            child: _isEditingSection(_Section.personal)
                ? _inlineField(_nameController,
                    onChanged: () => setState(() {}))
                : Text(_nameController.text, style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.medical_services_outlined,
            label: l.doctorRegSpecialty,
            child: _isEditingSection(_Section.personal)
                ? _inlineField(_specialtyController)
                : Text(
                    _specialtyController.text.isEmpty
                        ? l.doctorProfileNotSpecified
                        : _specialtyController.text,
                    style: _valueStyle),
          ),
        ],
      ),
    );
  }

  // ── Practice section ──────────────────────────────────────────

  Widget _buildPracticeSection(AppLocalizations l) {
    return _EditableSection(
      icon: Icons.local_hospital_rounded,
      iconColor: AppColors.accent,
      title: l.doctorProfilePracticeInfo,
      isEditing: _isEditingSection(_Section.practice),
      onEditToggle: () => _toggleSection(_Section.practice),
      onSave: _busy ? null : _saveProfile,
      child: Column(
        children: [
          _FieldRow(
            icon: Icons.location_on_outlined,
            label: l.orgRegAddress,
            child: _isEditingSection(_Section.practice)
                ? _inlineField(_addressController)
                : Text(
                    _addressController.text.isEmpty
                        ? l.doctorProfileNotSpecified
                        : _addressController.text,
                    style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.phone_outlined,
            label: l.orgRegPhone,
            child: _isEditingSection(_Section.practice)
                ? _inlineField(_phoneController,
                    keyboardType: TextInputType.phone)
                : Text(
                    _phoneController.text.isEmpty
                        ? l.doctorProfileNotSpecified
                        : _phoneController.text,
                    style: _valueStyle),
          ),
          _divider(),
          _FieldRow(
            icon: Icons.language_rounded,
            label: l.doctorProfileWebsite,
            child: _isEditingSection(_Section.practice)
                ? _inlineField(_websiteController,
                    keyboardType: TextInputType.url)
                : Text(
                    _websiteController.text.isEmpty
                        ? l.doctorProfileNotSpecified
                        : _websiteController.text,
                    style: _valueStyle),
          ),
        ],
      ),
    );
  }

  // ── Opening hours section ─────────────────────────────────────

  Widget _buildOpeningHoursSection(AppLocalizations l) {
    return _EditableSection(
      icon: Icons.schedule_rounded,
      iconColor: AppColors.success,
      title: l.doctorProfileOpeningHours,
      isEditing: _isEditingSection(_Section.practice),
      onEditToggle: () => _toggleSection(_Section.practice),
      onSave: _busy ? null : _saveProfile,
      child: _OpeningHoursEditor(
        hours: _openingHours,
        isEditing: _isEditingSection(_Section.practice),
        onChanged: (updated) => setState(() => _openingHours = updated),
      ),
    );
  }

  // ── Specialty tags section ────────────────────────────────────

  Widget _buildSpecialtyTagsSection(AppLocalizations l) {
    return _EditableSection(
      icon: Icons.label_rounded,
      iconColor: AppColors.warning,
      title: l.doctorProfileSpecialties,
      isEditing: _isEditingSection(_Section.practice),
      onEditToggle: () => _toggleSection(_Section.practice),
      onSave: _busy ? null : _saveProfile,
      child: _SpecialtyTagsEditor(
        tags: _specialtyTags,
        tagController: _tagController,
        isEditing: _isEditingSection(_Section.practice),
        onAdd: _addTag,
        onRemove: _removeTag,
      ),
    );
  }

  // ── Credentials section ───────────────────────────────────────

  Widget _buildCredentialsSection() {
    final l = AppLocalizations.of(context)!;
    return Column(
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
                child: const Icon(Icons.verified_user_rounded,
                    size: 16, color: AppColors.warning),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.doctorProfileProfessionalInfo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            children: [
              if (_approbationNumber.isNotEmpty)
                _FieldRow(
                  icon: Icons.badge_outlined,
                  label: l.doctorProfileApprobation,
                  child: Text(_approbationNumber, style: _valueStyle),
                ),
              if (_approbationNumber.isNotEmpty &&
                  (_kvNumber.isNotEmpty || _practiceName.isNotEmpty))
                _divider(),
              if (_kvNumber.isNotEmpty)
                _FieldRow(
                  icon: Icons.numbers_rounded,
                  label: l.doctorProfileKvNumber,
                  child: Text(_kvNumber, style: _valueStyle),
                ),
              if (_kvNumber.isNotEmpty && _practiceName.isNotEmpty)
                _divider(),
              if (_practiceName.isNotEmpty)
                _FieldRow(
                  icon: Icons.business_rounded,
                  label: l.doctorProfilePracticeName,
                  child: Text(_practiceName, style: _valueStyle),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Org join card ─────────────────────────────────────────────

  Widget _buildOrgJoinCard(AppLocalizations l) {
    return GlassCard(
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: const Icon(Icons.business_rounded,
              size: 20, color: AppColors.accent),
        ),
        title: Text(l.orgJoin),
        subtitle: Text(l.orgJoinWithCode),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        contentPadding: EdgeInsets.zero,
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const JoinOrgSheet(),
        ),
      ),
    );
  }

  Widget _buildStaffProfile(BuildContext context, String email) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = _staffPermissions;
    final name = _nameController.text.trim();

    return GlassPage(
      title: l.doctorProfileMeinProfil,
      titleIcon: AppIcons.profile,
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
                        name.isEmpty ? l.doctorProfileStaffMember : name,
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
                          l.doctorProfileStaffMember,
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
                    Text(l.practice, style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  children: [
                    _FieldRow(
                      icon: Icons.person_outline_rounded,
                      label: l.doctor,
                      child: Text(
                        _doctorName.isEmpty ? '–' : _doctorName,
                        style: _valueStyle,
                      ),
                    ),
                    if (_doctorSpecialty.isNotEmpty) ...[
                      _divider(),
                      _FieldRow(
                        icon: Icons.medical_services_outlined,
                        label: l.doctorRegSpecialty,
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
                      Text(l.myPermissions,
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

        const SizedBox(height: AppSpacing.xxl),

        // ── Section: Konto & Support ───────────────────
        ..._buildAccountSupportSection(delay: 160),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Logout ─────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: GlassButton(
            onPressed: () => AuthService().signOut(),
            icon: Icons.logout_rounded,
            label: l.logout,
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  /// Shared "Konto & Support" section for both doctor and staff profiles.
  List<Widget> _buildAccountSupportSection({required int delay}) {
    final l = AppLocalizations.of(context)!;
    return [
      FadeSlideIn(
        delay: Duration(milliseconds: delay),
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
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: const Icon(Icons.settings_rounded,
                        size: 16, color: AppColors.accent),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l.doctorProfileAccountSupport,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Column(
                children: [
                  _ActionRow(
                    icon: AppIcons.notifications,
                    label: l.notifications,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    ),
                  ),
                  _divider(),
                  _ActionRow(
                    icon: Icons.support_agent_rounded,
                    label: l.hilfeUndSupport,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HelpScreen(),
                      ),
                    ),
                  ),
                  _divider(),
                  _ActionRow(
                    icon: AppIcons.settings,
                    label: l.settings,
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
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
    this.verified = false,
    this.profileImageUrl,
    this.uploadingImage = false,
    this.onPickImage,
  });

  final String name;
  final String email;
  final String initials;
  final String specialty;
  final bool verified;
  final String? profileImageUrl;
  final bool uploadingImage;
  final VoidCallback? onPickImage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      variant: GlassVariant.thick,
      elevation: GlassElevation.high,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          // Avatar with optional verification badge overlay.
          GestureDetector(
            onTap: onPickImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(profileImageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
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
                if (uploadingImage)
                  const Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                // Camera icon overlay
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: verified
                      ? Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.white, width: 2),
                          ),
                          child: const Icon(Icons.check_rounded,
                              size: 16, color: AppColors.white),
                        )
                      : Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 14, color: AppColors.white),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? l.doctorProfileYourProfile : name,
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
                // Verification status chip.
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: (verified ? AppColors.success : AppColors.warning)
                            .withValues(alpha: 0.10),
                        borderRadius: AppRadius.borderRadiusPill,
                        border: Border.all(
                          color:
                              (verified ? AppColors.success : AppColors.warning)
                                  .withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            verified
                                ? Icons.verified_rounded
                                : Icons.hourglass_top_rounded,
                            size: 12,
                            color: verified
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            verified ? l.doctorProfileVerified : l.doctorProfileVerificationPending,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: verified
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (specialty.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
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
    final l = AppLocalizations.of(context)!;
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
              label: l.save,
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

/// A tappable row used for navigational actions (Mitteilungen, Hilfe, etc.).
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
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
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Opening hours data & editor
// ═════════════════════════════════════════════════════════════════════════════

class _OpeningHoursEntry {
  _OpeningHoursEntry({
    required this.from,
    required this.to,
  });

  TimeOfDay from;
  TimeOfDay to;
}

class _OpeningHoursEditor extends StatelessWidget {
  const _OpeningHoursEditor({
    required this.hours,
    required this.isEditing,
    required this.onChanged,
  });

  final Map<String, _OpeningHoursEntry> hours;
  final bool isEditing;
  final ValueChanged<Map<String, _OpeningHoursEntry>> onChanged;

  static const _weekdays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localizedDays = <String, String>{
      'Montag': l.timelineMonday,
      'Dienstag': l.timelineTuesday,
      'Mittwoch': l.timelineWednesday,
      'Donnerstag': l.timelineThursday,
      'Freitag': l.timelineFriday,
    };
    return Column(
      children: _weekdays.asMap().entries.map((e) {
        final index = e.key;
        final day = e.value;
        final entry = hours[day];
        final fromLabel = entry != null
            ? '${entry.from.hour.toString().padLeft(2, '0')}:${entry.from.minute.toString().padLeft(2, '0')}'
            : '–';
        final toLabel = entry != null
            ? '${entry.to.hour.toString().padLeft(2, '0')}:${entry.to.minute.toString().padLeft(2, '0')}'
            : '–';

        return Column(
          children: [
            if (index > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Container(height: 1, color: AppColors.grey200),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      localizedDays[day] ?? day,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isEditing) ...[
                    _TimePickerButton(
                      time: entry?.from ?? const TimeOfDay(hour: 8, minute: 0),
                      onPicked: (t) {
                        final updated = Map<String, _OpeningHoursEntry>.from(hours);
                        updated[day] = _OpeningHoursEntry(
                          from: t,
                          to: entry?.to ?? const TimeOfDay(hour: 17, minute: 0),
                        );
                        onChanged(updated);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      child: Text('–',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    _TimePickerButton(
                      time: entry?.to ?? const TimeOfDay(hour: 17, minute: 0),
                      onPicked: (t) {
                        final updated = Map<String, _OpeningHoursEntry>.from(hours);
                        updated[day] = _OpeningHoursEntry(
                          from: entry?.from ??
                              const TimeOfDay(hour: 8, minute: 0),
                          to: t,
                        );
                        onChanged(updated);
                      },
                    ),
                  ] else ...[
                    Text(
                      entry != null ? '$fromLabel – $toLabel' : l.doctorProfileClosed,
                      style: _valueStyle.copyWith(
                        color: entry != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(growable: false),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  const _TimePickerButton({
    required this.time,
    required this.onPicked,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPicked;

  @override
  Widget build(BuildContext context) {
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return PressableScale(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderRadiusSm,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Specialty tags editor
// ═════════════════════════════════════════════════════════════════════════════

class _SpecialtyTagsEditor extends StatelessWidget {
  const _SpecialtyTagsEditor({
    required this.tags,
    required this.tagController,
    required this.isEditing,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final TextEditingController tagController;
  final bool isEditing;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: tags.map((tag) {
            return Chip(
              label: Text(
                tag,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
              backgroundColor: AppColors.warning.withValues(alpha: 0.10),
              side: BorderSide(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
              deleteIcon: isEditing
                  ? const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.warning)
                  : null,
              onDeleted: isEditing ? () => onRemove(tag) : null,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusPill,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(growable: false),
        ),
        if (tags.isEmpty && !isEditing)
          Text(
            l.doctorProfileNoSpecialties,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        if (isEditing) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: tagController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l.doctorProfileNewSpecialtyHint,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusSm,
                        borderSide: BorderSide(color: AppColors.grey300),
                      ),
                    ),
                    onSubmitted: onAdd,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PressableScale(
                onTap: () => onAdd(tagController.text),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: const Icon(Icons.add_rounded,
                      size: 20, color: AppColors.white),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
