import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../domain/task_orchestrator_sync.dart';
import '../features/health_sync/health_sync_service.dart';
import '../features/emergency/data/emergency_repository.dart';
import '../features/emergency/domain/emergency_info.dart';
import '../features/onboarding_tutorial/presentation/profile_completeness_card.dart';
import '../features/pro/data/entitlement_service.dart';
import '../features/pro/domain/entitlement.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../firebase/firebase_paths.dart';
import '../main.dart';
import '../security/guest_profile_store.dart';
import '../security/pin_lock_screen.dart';
import '../security/pin_lock_service.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';
import '../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Section enum for per-section editing
// ─────────────────────────────────────────────────────────────────────────────

enum ProfileSection { personal, op, health, emergency }

// ignore: constant_identifier_names
typedef _Section = ProfileSection;

// ─────────────────────────────────────────────────────────────────────────────

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key, this.initialSection});

  final ProfileSection? initialSection;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final GuestProfileStore _guestProfileStore = GuestProfileStore();

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
  late final TextEditingController _hospitalPhoneCtrl;
  late final TextEditingController _doctorPhoneCtrl;
  late final TextEditingController _insuranceInfoCtrl;
  DateTime _birthdate = DateTime(1990, 1, 1);
  DateTime? _opDate;
  String? _smokerStatus;
  String? _bloodType;
  List<String> _preExistingConditions = [];
  List<String> _allergies = [];
  List<String> _currentMedications = [];

  bool _pinEnabled = false;
  bool _healthSyncEnabled = false;
  bool _healthSyncLoading = true;
  _Section? _editingSection;
  bool _isSaving = false;
  List<Map<String, dynamic>> _previousOperations = [];

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
    _hospitalPhoneCtrl = TextEditingController();
    _doctorPhoneCtrl = TextEditingController();
    _insuranceInfoCtrl = TextEditingController();
    _editingSection = widget.initialSection;
    _loadProfile();
    _loadHealthSyncState();
    _loadPinState();
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
    _hospitalPhoneCtrl.dispose();
    _doctorPhoneCtrl.dispose();
    _insuranceInfoCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Guest mode – load from local storage.
      await _loadGuestProfile();
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .doc(FirestorePaths.userDoc(uid))
          .get();
      if (!mounted) return;
      final data = doc.data();
      if (data != null) {
        _applyProfileData(data);
      }
      setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  void _applyProfileData(Map<String, dynamic> data) {
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
    if (data['hospitalPhone'] is String) {
      _hospitalPhoneCtrl.text = data['hospitalPhone'] as String;
    }
    if (data['doctorPhone'] is String) {
      _doctorPhoneCtrl.text = data['doctorPhone'] as String;
    }
    if (data['insuranceInfo'] is String) {
      _insuranceInfoCtrl.text = data['insuranceInfo'] as String;
    }
    if (data['bloodType'] is String) {
      _bloodType = data['bloodType'] as String;
    }
    if (data['preExistingConditions'] is List) {
      _preExistingConditions = List<String>.from(
        data['preExistingConditions'] as List,
      );
    }
    if (data['allergies'] is List) {
      _allergies = List<String>.from(data['allergies'] as List);
    }
    if (data['currentMedications'] is List) {
      _currentMedications = List<String>.from(
        data['currentMedications'] as List,
      );
    }
    if (data['previousOperations'] is List) {
      _previousOperations = (data['previousOperations'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  Future<void> _loadGuestProfile() async {
    try {
      final data = await _guestProfileStore.load();
      if (data == null || !mounted) return;
      _applyProfileData(data);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('[ProfileSettings] loadGuestProfile failed: $e');
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveGuestProfile() async {
    final selectedOpDate = _opDate;
    final data = <String, dynamic>{
      'displayName': _nameCtrl.text.trim(),
      'birthDate': _birthdate.toIso8601String(),
      'opType': _opTypeCtrl.text.trim(),
      'opModus': _opModusCtrl.text.trim(),
      'opDate': selectedOpDate?.toIso8601String(),
      'hospitalName': _hospitalCtrl.text.trim(),
      'doctorName': _doctorNameCtrl.text.trim(),
      'weight': double.tryParse(_weightCtrl.text.trim()),
      'height': double.tryParse(_heightCtrl.text.trim()),
      'smokerStatus': _smokerStatus,
      'emergencyContactName': _emergencyNameCtrl.text.trim(),
      'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
      'hospitalPhone': _hospitalPhoneCtrl.text.trim(),
      'doctorPhone': _doctorPhoneCtrl.text.trim(),
      'insuranceInfo': _insuranceInfoCtrl.text.trim(),
      'bloodType': _bloodType,
      'preExistingConditions': _preExistingConditions,
      'allergies': _allergies,
      'currentMedications': _currentMedications,
    };
    await _guestProfileStore.save(data);

    // Keep emergency cache in sync for offline access.
    await _syncEmergencyCache();

    if (selectedOpDate != null) {
      await _syncOperationDate(selectedOpDate);
    }

    if (mounted) {
      final l = AppLocalizations.of(context)!;
      setState(() => _editingSection = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.profilGespeichertKurz)));
    }
  }

  Future<void> _saveProfile() async {
    final l = AppLocalizations.of(context)!;
    if (_isSaving) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Guest mode – save locally.
      setState(() => _isSaving = true);
      try {
        await _saveGuestProfile();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userFacingError(e, fallback: l.fehlerBeimSpeichern))),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
      return;
    }
    setState(() => _isSaving = true);
    try {
      final selectedOpDate = _opDate;
      final newName = _nameCtrl.text.trim();
      if (newName.isNotEmpty && newName != user.displayName) {
        try {
          await user.updateDisplayName(newName);
        } catch (e) {
          debugPrint('[ProfileSettings] updateDisplayName failed: $e');
        }
      }
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      batch.set(
        firestore.doc(FirestorePaths.userDoc(user.uid)),
        <String, dynamic>{
          'displayName': newName,
          'birthDate': _birthdate.toIso8601String(),
          'opType': _opTypeCtrl.text.trim(),
          'opModus': _opModusCtrl.text.trim(),
          'opDate': selectedOpDate?.toIso8601String(),
          'hospitalName': _hospitalCtrl.text.trim(),
          'doctorName': _doctorNameCtrl.text.trim(),
          'weight': double.tryParse(_weightCtrl.text.trim()),
          'height': double.tryParse(_heightCtrl.text.trim()),
          'smokerStatus': _smokerStatus,
          'emergencyContactName': _emergencyNameCtrl.text.trim(),
          'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
          'hospitalPhone': _hospitalPhoneCtrl.text.trim(),
          'doctorPhone': _doctorPhoneCtrl.text.trim(),
          'insuranceInfo': _insuranceInfoCtrl.text.trim(),
          'bloodType': _bloodType,
          'preExistingConditions': _preExistingConditions,
          'allergies': _allergies,
          'currentMedications': _currentMedications,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      batch.set(
        firestore.doc(FirestorePaths.patientDoc(user.uid)),
        <String, dynamic>{
          'opDate': selectedOpDate?.toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[SAVE] committing batch …');
      await batch.commit().timeout(const Duration(seconds: 10));
      debugPrint('[SAVE] batch committed OK');

      // Keep emergency cache in sync for offline access.
      await _syncEmergencyCache();

      if (selectedOpDate != null) {
        await _syncOperationDate(selectedOpDate);
      }

      if (mounted) {
        setState(() => _editingSection = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.profileSaved)));
      }
    } catch (e, st) {
      debugPrint('[SAVE] error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncEmergencyCache() async {
    try {
      final info = EmergencyInfo(
        emergencyContactName: _emergencyNameCtrl.text.trim().isEmpty
            ? null
            : _emergencyNameCtrl.text.trim(),
        emergencyContactPhone: _emergencyPhoneCtrl.text.trim().isEmpty
            ? null
            : _emergencyPhoneCtrl.text.trim(),
        hospitalName: _hospitalCtrl.text.trim().isEmpty
            ? null
            : _hospitalCtrl.text.trim(),
        hospitalPhone: _hospitalPhoneCtrl.text.trim().isEmpty
            ? null
            : _hospitalPhoneCtrl.text.trim(),
        bloodType: _bloodType,
        allergies: _allergies,
        insuranceInfo: _insuranceInfoCtrl.text.trim().isEmpty
            ? null
            : _insuranceInfoCtrl.text.trim(),
        doctorName: _doctorNameCtrl.text.trim().isEmpty
            ? null
            : _doctorNameCtrl.text.trim(),
        doctorPhone: _doctorPhoneCtrl.text.trim().isEmpty
            ? null
            : _doctorPhoneCtrl.text.trim(),
      );
      await EmergencyRepository().updateCache(info);
    } catch (_) {
      // Best-effort cache sync.
    }
  }

  Future<void> _syncOperationDate(DateTime opDate) async {
    try {
      await TaskOrchestratorSync.instance.setOperationDate(
        opDate,
        opType: _opTypeCtrl.text.trim().isNotEmpty
            ? _opTypeCtrl.text.trim()
            : null,
        opModus: _opModusCtrl.text.trim().isNotEmpty
            ? _opModusCtrl.text.trim()
            : null,
      );
    } catch (e) {
      debugPrint('[ProfileSettings] setOperationDate failed: $e');
    }
  }

  Future<void> _archiveCurrentOp() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _opDate == null) return;
    final entry = <String, dynamic>{
      'opDate': _opDate!.toIso8601String(),
      'opType': _opTypeCtrl.text.trim(),
      'opModus': _opModusCtrl.text.trim(),
    };
    try {
      await FirebaseFirestore.instance
          .doc(FirestorePaths.userDoc(uid))
          .update({
        'previousOperations': FieldValue.arrayUnion([entry]),
      });
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        setState(() => _previousOperations = [..._previousOperations, entry]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.operationArchived)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
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

  // ── PIN lock ────────────────────────────────────────────────────────────

  final PinLockService _pinLockService = PinLockService();

  Future<void> _loadPinState() async {
    final enabled = await _pinLockService.isEnabled;
    if (mounted) setState(() => _pinEnabled = enabled);
  }

  Future<void> _handlePinToggle(bool wantEnabled) async {
    if (wantEnabled) {
      // Show PIN setup screen
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              const PinLockScreen(mode: PinScreenMode.setup),
          fullscreenDialog: true,
        ),
      );
      if (result == true && mounted) {
        setState(() => _pinEnabled = true);
      }
    } else {
      // Confirm current PIN before disabling
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              const PinLockScreen(mode: PinScreenMode.confirmDisable),
          fullscreenDialog: true,
        ),
      );
      if (result == true && mounted) {
        setState(() => _pinEnabled = false);
      }
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
              content: Text(
                'Health-Sync wird auf diesem Gerät nicht unterstützt.',
              ),
            ),
          );
        }
        return;
      }

      // On Android, check if Health Connect is installed.
      final hcAvailable =
          await HealthSyncService.instance.checkHealthConnectAvailability();
      if (!hcAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bitte installiere Health Connect aus dem Play Store.',
              ),
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
                'Berechtigung für Gesundheitsdaten wurde nicht erteilt.',
              ),
            ),
          );
        }
        return;
      }
    }

    try {
      await HealthSyncService.instance.setEnabled(value);
    } catch (e) {
      debugPrint('[ProfileSettings] setEnabled failed: $e');
      return;
    }
    if (mounted) setState(() => _healthSyncEnabled = value);

    // Immediately run first sync after enabling.
    if (value) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        try {
          final count = await HealthSyncService.instance.sync(ownerId: uid);
          if (count > 0 && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$count Messungen synchronisiert'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint('[ProfileSettings] health sync failed: $e');
        }
      }
    }
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
      _editingSection = _editingSection == s ? null : s;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
            entitlementService: ProServices.maybeOf(
              context,
            )?.entitlementService,
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

        // ── Profile Completeness ──
        const ProfileCompletenessCard(),
        const SizedBox(height: AppSpacing.lg),

        // ── Personal Data ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _EditableSection(
            icon: Icons.person_rounded,
            iconColor: AppColors.primary,
            title: l.doctorRegPersonalData,
            isEditing: _isEditingSection(_Section.personal),
            isSaving: _isSaving,
            onEditToggle: () => _toggleSection(_Section.personal),
            onSave: _saveProfile,
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
            isSaving: _isSaving,
            onEditToggle: () => _toggleSection(_Section.op),
            onSave: _saveProfile,
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

        // ── Operationsverlauf (Pro) ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 170),
          child: Builder(
            builder: (ctx) {
              final isPro =
                  ProServices.maybeOf(ctx)?.entitlementService.isPro ?? false;
              return _OpHistoryCard(
                isPro: isPro,
                previousOperations: _previousOperations,
                hasCurrentOp: _opDate != null,
                onArchive: _archiveCurrentOp,
                onUpgrade: () => SmartPaywall.trigger(
                  context: ctx,
                  triggerContext: TriggerContext.operationLimit,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Health & Body ──
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: _EditableSection(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.success,
            title: l.koerperwerteUndGesundheit,
            isEditing: _isEditingSection(_Section.health),
            isSaving: _isSaving,
            onEditToggle: () => _toggleSection(_Section.health),
            onSave: _saveProfile,
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
            title: l.notfallkontaktUndNotfallInfo,
            isEditing: _isEditingSection(_Section.emergency),
            isSaving: _isSaving,
            onEditToggle: () => _toggleSection(_Section.emergency),
            onSave: _saveProfile,
            child: _EmergencySection(
              emergencyNameCtrl: _emergencyNameCtrl,
              emergencyPhoneCtrl: _emergencyPhoneCtrl,
              hospitalPhoneCtrl: _hospitalPhoneCtrl,
              doctorPhoneCtrl: _doctorPhoneCtrl,
              insuranceInfoCtrl: _insuranceInfoCtrl,
              bloodType: _bloodType,
              isEditing: _isEditingSection(_Section.emergency),
              onBloodTypeChanged: (v) => setState(() => _bloodType = v),
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
              _sectionLabel(context, l.onboardingSlide4Title),
              const SizedBox(height: AppSpacing.md),
              _SecurityCard(
                pinEnabled: _pinEnabled,
                onPinChanged: _handlePinToggle,
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
                entitlementService: ProServices.maybeOf(
                  context,
                )?.entitlementService,
                onUpgrade: () => SmartPaywall.trigger(
                  context: context,
                  triggerContext: TriggerContext.manualOpen,
                ),
                onManage: () => Navigator.of(context).pushNamed('/pro-status'),
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
          final isPro = ent.isActive;
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
        colors: const [AppColors.primary, Color(0xFF5AC8FA)],
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
    required this.isSaving,
    required this.onEditToggle,
    required this.onSave,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isEditing;
  final bool isSaving;
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
                onTap: isSaving ? null : onEditToggle,
                enabled: !isSaving,
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

          // Section content
          child,

          // Save button when editing
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.xl),
            GlassButton(
              onPressed: onSave,
              label: l.save,
              icon: Icons.check_rounded,
              isLoading: isSaving,
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
    final l = AppLocalizations.of(context)!;
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
          label: l.fieldBirthDate,
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
          label: l.fieldEmail,
          child: isEditing
              ? _inlineField(
                  emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                )
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
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        _FieldRow(
          icon: Icons.medical_services_outlined,
          label: l.fieldOpType,
          child: isEditing
              ? _inlineField(opTypeCtrl)
              : Text(
                  opTypeCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : opTypeCtrl.text,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.event_outlined,
          label: l.fieldOpDate,
          child: isEditing
              ? GestureDetector(
                  onTap: onOpDateTap,
                  child: Row(
                    children: [
                      Text(
                        opDate != null ? _fmtDate(opDate!) : l.auswaehlen,
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
                  opDate != null ? _fmtDate(opDate!) : l.nichtHinterlegt,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.settings_outlined,
          label: l.fieldOpModus,
          child: isEditing
              ? _inlineField(opModusCtrl)
              : Text(
                  opModusCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : opModusCtrl.text,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.local_hospital_outlined,
          label: l.opClinic,
          child: isEditing
              ? _inlineField(hospitalCtrl)
              : Text(
                  hospitalCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : hospitalCtrl.text,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.person_outline_rounded,
          label: l.doctor,
          child: isEditing
              ? _inlineField(doctorNameCtrl)
              : Text(
                  doctorNameCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : doctorNameCtrl.text,
                  style: _valueStyle,
                ),
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
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        _FieldRow(
          icon: Icons.monitor_weight_outlined,
          label: l.fieldWeight,
          child: isEditing
              ? _inlineField(
                  weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                )
              : Text(
                  weightCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : '${weightCtrl.text} kg',
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.height_rounded,
          label: l.groesse,
          child: isEditing
              ? _inlineField(heightCtrl, keyboardType: TextInputType.number)
              : Text(
                  heightCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : '${heightCtrl.text} cm',
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.smoke_free_rounded,
          label: l.fieldSmoker,
          child: isEditing
              ? _SmokerSegmentedPicker(
                  value: smokerStatus,
                  onChanged: onSmokerChanged,
                )
              : Text(smokerStatus ?? l.nichtHinterlegt, style: _valueStyle),
        ),
        _divider(),
        _ChipTagsField(
          icon: Icons.healing_rounded,
          label: l.eiConditions,
          items: preExistingConditions,
          chipColor: AppColors.warning,
          isEditing: isEditing,
          onChanged: onConditionsChanged,
        ),
        _divider(),
        _ChipTagsField(
          icon: Icons.warning_amber_rounded,
          label: l.eiAllergies,
          items: allergies,
          chipColor: AppColors.error,
          isEditing: isEditing,
          onChanged: onAllergiesChanged,
        ),
        _divider(),
        _ChipTagsField(
          icon: Icons.medication_rounded,
          label: l.eiMedications,
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
    required this.hospitalPhoneCtrl,
    required this.doctorPhoneCtrl,
    required this.insuranceInfoCtrl,
    required this.bloodType,
    required this.isEditing,
    required this.onBloodTypeChanged,
  });

  final TextEditingController emergencyNameCtrl;
  final TextEditingController emergencyPhoneCtrl;
  final TextEditingController hospitalPhoneCtrl;
  final TextEditingController doctorPhoneCtrl;
  final TextEditingController insuranceInfoCtrl;
  final String? bloodType;
  final bool isEditing;
  final ValueChanged<String?> onBloodTypeChanged;

  static const _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-',
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        _FieldRow(
          icon: Icons.person_outline_rounded,
          label: l.fieldName,
          child: isEditing
              ? _inlineField(emergencyNameCtrl)
              : Text(
                  emergencyNameCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : emergencyNameCtrl.text,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.phone_outlined,
          label: l.orgRegPhone,
          child: isEditing
              ? _inlineField(
                  emergencyPhoneCtrl,
                  keyboardType: TextInputType.phone,
                )
              : Text(
                  emergencyPhoneCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : emergencyPhoneCtrl.text,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.bloodtype_rounded,
          label: l.eiBloodType,
          child: isEditing
              ? DropdownButton<String>(
                  value: bloodType,
                  hint: Text(l.auswaehlen),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: _bloodTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: onBloodTypeChanged,
                )
              : Text(
                  bloodType ?? l.nichtHinterlegt,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.local_hospital_outlined,
          label: l.fieldHospitalPhone,
          child: isEditing
              ? _inlineField(
                  hospitalPhoneCtrl,
                  keyboardType: TextInputType.phone,
                )
              : Text(
                  hospitalPhoneCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : hospitalPhoneCtrl.text,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.medical_services_outlined,
          label: l.fieldDoctorPhone,
          child: isEditing
              ? _inlineField(
                  doctorPhoneCtrl,
                  keyboardType: TextInputType.phone,
                )
              : Text(
                  doctorPhoneCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : doctorPhoneCtrl.text,
                  style: _valueStyle,
                ),
        ),
        _divider(),
        _FieldRow(
          icon: Icons.shield_outlined,
          label: l.eiInsurance,
          child: isEditing
              ? _inlineField(insuranceInfoCtrl)
              : Text(
                  insuranceInfoCtrl.text.isEmpty
                      ? l.nichtHinterlegt
                      : insuranceInfoCtrl.text,
                  style: _valueStyle,
                ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SMOKER SEGMENTED PICKER
// ═════════════════════════════════════════════════════════════════════════════

class _SmokerSegmentedPicker extends StatelessWidget {
  const _SmokerSegmentedPicker({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const _options = {'Nein': 'Nein', 'Ja': 'Ja', 'Ehemalig': 'Ehem.'};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final groupValue = value ?? l.no;
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<String>(
        groupValue: _options.containsKey(groupValue) ? groupValue : l.no,
        children: _options.map(
          (key, label) => MapEntry(
            key,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
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
    final l = AppLocalizations.of(context)!;
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
                  child: Text(l.none, style: _valueStyle),
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
                              Icon(
                                Icons.add_rounded,
                                size: 14,
                                color: chipColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                l.add,
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
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.labelHinzufuegen(label)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.bezeichnungEingeben,
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
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                onChanged([...items, text]);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(l.add),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}

// ── Med chip ─────────────────────────────────────────────────────────────────

class _MedChip extends StatelessWidget {
  const _MedChip({required this.label, required this.color, this.onDelete});

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

Widget _inlineField(TextEditingController ctrl, {TextInputType? keyboardType}) {
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
    required this.onPinChanged,
    required this.onChangePassword,
  });

  final bool pinEnabled;
  final ValueChanged<bool> onPinChanged;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          _SecurityRow(
            icon: Icons.lock_outline_rounded,
            color: AppColors.accent,
            title: l.passwortAendern,
            subtitle: l.zuletztGeaendertVor30Tagen,
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
            title: l.pINAktivieren,
            subtitle: l.n4StelligerZugangsPIN,
            trailing: CupertinoSwitch(
              value: pinEnabled,
              activeTrackColor: AppColors.warning,
              onChanged: onPinChanged,
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
                        'Blutdruck, Puls, Temperatur, SpO₂, Gewicht & Schritte synchronisieren',
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
        if (ent.isActive) {
          return _buildProCard(context, ent);
        }
        return _buildFreeCard(context);
      },
    );
  }

  Widget _buildProCard(BuildContext context, Entitlement ent) {
    final l = AppLocalizations.of(context)!;
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
            label: l.proManageSubscription,
            icon: Icons.settings_rounded,
            variant: GlassButtonVariant.secondary,
            expand: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFreeCard(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
            label: l.proEntdecken,
            icon: Icons.workspace_premium_rounded,
            expand: true,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// OPERATION HISTORY CARD
// ═════════════════════════════════════════════════════════════════════════════

class _OpHistoryCard extends StatelessWidget {
  const _OpHistoryCard({
    required this.isPro,
    required this.previousOperations,
    required this.hasCurrentOp,
    required this.onArchive,
    required this.onUpgrade,
  });

  final bool isPro;
  final List<Map<String, dynamic>> previousOperations;
  final bool hasCurrentOp;
  final VoidCallback onArchive;
  final VoidCallback onUpgrade;

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '–';
    final d = DateTime.tryParse(isoDate);
    if (d == null) return isoDate;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  CupertinoIcons.calendar,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Operationsverlauf',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!isPro)
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
          const SizedBox(height: AppSpacing.md),
          if (!isPro) ...[
            const Text(
              'Verwalte mehrere Operationen und Behandlungen in einer App – mit eigenem Verlauf für jede OP.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: Text(l.proUnlock),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
          ] else ...[
            if (previousOperations.isEmpty) ...[
              const Text(
                'Noch keine archivierten Operationen.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...[
              ...previousOperations.reversed.map(
                (op) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${_formatDate(op['opDate'] as String?)}${(op['opType'] as String?)?.isNotEmpty == true ? ' – ${op['opType']}' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: AppSpacing.lg),
            ],
            if (hasCurrentOp)
              TextButton.icon(
                onPressed: onArchive,
                icon: const Icon(Icons.archive_rounded, size: 16),
                label: Text(l.markOpComplete),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
          ],
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
      final l = AppLocalizations.of(context)!;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.passwordsMismatch)),
      );
      return;
    }
    if (newPw.length < 6) {
      final l = AppLocalizations.of(context)!;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.passwordMin6)));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final l = AppLocalizations.of(context)!;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.passwordChanged)));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = userFacingError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              label: l.aktuellesPasswort,
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
              label: l.passwordConfirm,
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
              label: l.passwortSpeichern,
              icon: Icons.check_rounded,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              onPressed: () => Navigator.of(context).pop(),
              label: l.cancel,
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
