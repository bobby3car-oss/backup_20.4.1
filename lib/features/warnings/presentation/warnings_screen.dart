import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../ui/ui.dart';
import '../data/warnings_repository_sync.dart';
import '../domain/warning_check.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Warning items builder (context-dependent, returns localized list)
// ---------------------------------------------------------------------------

class _WarningItem {
  const _WarningItem({
    required this.title,
    required this.subtitle,
    required this.field,
    this.detail,
  });

  final String title;
  final String subtitle;
  final String field; // matches WarningCheckAnswers field name
  final List<String>? detail; // optional checklist items
}

List<_WarningItem> _buildWarningItems(AppLocalizations l) => [
  _WarningItem(
    title: l.warnItemBleedingTitle,
    subtitle: l.warnItemBleedingSubtitle,
    field: 'strongBleeding',
    detail: [
      l.warnItemBleedingQ1,
      l.warnItemBleedingQ2,
      l.warnItemBleedingQ3,
    ],
  ),
  _WarningItem(
    title: l.warnItemFeverTitle,
    subtitle: l.warnItemFeverSubtitle,
    field: 'feverHigh',
    detail: [
      l.warnItemFeverQ1,
      l.warnItemFeverQ2,
      l.warnItemFeverQ3,
    ],
  ),
  _WarningItem(
    title: l.warnItemBreathTitle,
    subtitle: l.warnItemBreathSubtitle,
    field: 'shortnessOfBreath',
    detail: [
      l.warnItemBreathQ1,
      l.warnItemBreathQ2,
      l.warnItemBreathQ3,
    ],
  ),
  _WarningItem(
    title: l.warnItemPainTitle,
    subtitle: l.warnItemPainSubtitle,
    field: 'strongPain',
    detail: [
      l.warnItemPainQ1,
      l.warnItemPainQ2,
      l.warnItemPainQ3,
    ],
  ),
  _WarningItem(
    title: l.warnItemRednessTitle,
    subtitle: l.warnItemRednessSubtitle,
    field: 'increasingRedness',
    detail: [
      l.warnItemRednessQ1,
      l.warnItemRednessQ2,
      l.warnItemRednessQ3,
    ],
  ),
  _WarningItem(
    title: l.warnItemSmellTitle,
    subtitle: l.warnItemSmellSubtitle,
    field: 'badSmellSecretion',
    detail: [
      l.warnItemSmellQ1,
      l.warnItemSmellQ2,
      l.warnItemSmellQ3,
    ],
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class WarningsScreen extends StatefulWidget {
  const WarningsScreen({super.key});

  @override
  State<WarningsScreen> createState() => _WarningsScreenState();
}

class _WarningsScreenState extends State<WarningsScreen> {
  static final WarningsRepositorySync _repo = WarningsRepositorySync.instance;

  WarningCheck? _latest;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    final latest = await _repo.loadLatest();
    if (!mounted) return;
    setState(() => _latest = latest);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _call112() async {
    final uri = Uri.parse('tel:112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _onWarningTapped(_WarningItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WarningDetailSheet(
        item: item,
        onConfirm: () => _saveWarningCheck(item.field),
      ),
    );
  }

  Future<void> _saveWarningCheck(String field) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return;

    final now = DateTime.now();
    final answers = WarningCheckAnswers(
      feverHigh: field == 'feverHigh',
      increasingRedness: field == 'increasingRedness',
      strongPain: field == 'strongPain',
      badSmellSecretion: field == 'badSmellSecretion',
      shortnessOfBreath: field == 'shortnessOfBreath',
      strongBleeding: field == 'strongBleeding',
    );
    final engine = evaluateWarningCheck(answers);
    final check = WarningCheck(
      id: 'warning_${now.microsecondsSinceEpoch}',
      ownerId: uid,
      createdAt: now,
      answers: answers,
      level: engine.level,
      actionText: engine.actionText,
      metadata: const <String, dynamic>{'source': 'warnings_screen_v2'},
    );
    final l = AppLocalizations.of(context)!;
    try {
      await _repo.saveLatest(check);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _latest = check);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.warnzeichenGespeichert(engine.level.name)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final warningItems = _buildWarningItems(l);
    return GlassPage(
      title: l.warnTitle,
      titleIcon: AppIcons.warnings,
      titleColor: AppColors.error,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              // ─── Emergency card ──────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33FF3B30),
                      blurRadius: 24,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    Text(
                      l.warnEmergencyTitle,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.warnEmergencySubtitle,
                      style: TextStyle(fontSize: 15, color: Color(0xCCFFFFFF)),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _call112,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.error,
                          shape: const StadiumBorder(),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(l.warnCall112),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Section header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  l.warnContactClinic,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // ─── Warning cards ──────────────────────────────────────
              for (final item in warningItems) ...[
                GestureDetector(
                  onTap: () => _onWarningTapped(item),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.error, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 24,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        GlassIcon(icon: AppIcons.warnings, color: AppIcons.warningsColor, size: 16),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ─── Last check info ─────────────────────────────────────
              if (_latest != null) ...[
                const SizedBox(height: 8),
                _LastCheckBadge(latest: _latest!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Detail bottom sheet
// =============================================================================

class _WarningDetailSheet extends StatefulWidget {
  const _WarningDetailSheet({required this.item, required this.onConfirm});

  final _WarningItem item;
  final VoidCallback onConfirm;

  @override
  State<_WarningDetailSheet> createState() => _WarningDetailSheetState();
}

class _WarningDetailSheetState extends State<_WarningDetailSheet> {
  late final List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List.filled(widget.item.detail?.length ?? 0, false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final detail = widget.item.detail ?? const <String>[];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              GlassIcon(icon: AppIcons.warnings, color: AppIcons.warningsColor, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.item.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Checklist
          if (detail.isNotEmpty) ...[
            Text(
              l.warnCheckLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < detail.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _checked[i] = !_checked[i]),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _checked[i]
                              ? AppColors.error
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: _checked[i]
                                ? AppColors.error
                                : AppColors.grey300,
                            width: 1.5,
                          ),
                        ),
                        child: _checked[i]
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          detail[i],
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Confirm button
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirm();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(
                l.warnSaveCheck,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Last-check badge
// =============================================================================

class _LastCheckBadge extends StatelessWidget {
  const _LastCheckBadge({required this.latest});

  final WarningCheck latest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dt = latest.createdAt;
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');

    final (color, label) = switch (latest.level) {
      WarningLevel.green => (AppColors.success, l.gruen),
      WarningLevel.yellow => (AppColors.warning, l.rfSeverityYellow),
      WarningLevel.red => (AppColors.error, l.rfSeverityRed),
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.warnLastCheck(label, '$dd.$mm.${dt.year} $hh:$min'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
