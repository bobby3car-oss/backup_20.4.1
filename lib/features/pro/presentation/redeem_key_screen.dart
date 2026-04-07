import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../../screens/caregiver_screen.dart' show CaregiverScreen;
import '../data/key_redemption_service.dart';
import 'package:operationsbegleiter_v3/ui/components/glass_icon.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

// ── Dark palette (matches paywall / success screen) ─────────────────

abstract final class _C {
  static const bg = Color(0xFF0A0A0F);
  static const card = Color(0x1AFFFFFF);
  static const border = Color(0x20FFFFFF);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0x99EBEBF5);
  static const accent = Color(0xFF0A84FF);
  static const success = Color(0xFF30D158);
  static const error = Color(0xFFFF453A);
}

/// Screen for redeeming a Pro key.
///
/// Dark-mode glass-card design. On success an animated confirmation is
/// shown inline (no navigation to a separate screen).
class RedeemKeyScreen extends StatefulWidget {
  const RedeemKeyScreen({super.key});

  @override
  State<RedeemKeyScreen> createState() => _RedeemKeyScreenState();
}

class _RedeemKeyScreenState extends State<RedeemKeyScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _service = KeyRedemptionService();

  bool _loading = false;
  bool _success = false;
  String? _error;

  // ── Success animations ─────────────────────────────────────────────
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconScale;
  late final AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.92), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOut));

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _iconCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Bitte gib einen Key ein.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.redeem(key);

    if (!mounted) return;

    if (result.success) {
      final pro = ProServices.maybeOf(context);
      await pro?.entitlementService.refresh();
      await pro?.orgEntitlementService.refresh();
      if (!mounted) return;

      HapticFeedback.heavyImpact();
      setState(() {
        _loading = false;
        _success = true;
      });
      _playSuccessAnimation();
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _loading = false;
        _error = result.errorMessage;
      });
    }
  }

  Future<void> _playSuccessAnimation() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _iconCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _contentCtrl.forward();
  }

  void _goToTimeline() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openCaregiver() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const CaregiverScreen()),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        appBar: _success
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: _C.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _success ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  // ── Form state ─────────────────────────────────────────────────────

  Widget _buildForm() {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      key: const ValueKey('form'),
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),

            // ── Title ──────────────────────────────────
            Text(
              'Pro-Key einlösen',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                    letterSpacing: -0.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Gib deinen Key ein, um Pro zu aktivieren.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _C.textSecondary,
                    height: 1.45,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // ── Glass card ─────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.border),
                  ),
                  child: Column(
                    children: [
                      // Input
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Menlo',
                          fontFamilyFallback: [
                            'Courier New',
                            'monospace',
                          ],
                          color: _C.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'OBPRO-XXXX-XXXX-XXXX',
                          hintStyle: TextStyle(
                            fontFamily: 'Menlo',
                            fontFamilyFallback: const [
                              'Courier New',
                              'monospace',
                            ],
                            color: _C.textSecondary.withValues(alpha: 0.4),
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _C.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _C.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _C.accent,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _C.error),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _C.error,
                              width: 1.5,
                            ),
                          ),
                          errorText: _error,
                          errorStyle: const TextStyle(color: _C.error),
                        ),
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        onSubmitted: (_) => _submit(),
                      ),

                      const SizedBox(height: 20),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                _C.accent.withValues(alpha: 0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(l.keyActivate),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  // ── Success state ──────────────────────────────────────────────────

  Widget _buildSuccess() {
    final l = AppLocalizations.of(context)!;
    final contentCurved =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic);

    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // ── Animated checkmark ───────────────────────
          ScaleTransition(
            scale: _iconScale,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.success.withValues(alpha: 0.12),
              ),
              child: const Center(
                child: GlassIcon(icon: AppIcons.done, color: AppIcons.doneColor, size: 36),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Title + body ─────────────────────────────
          AnimatedBuilder(
            animation: contentCurved,
            builder: (_, child) => Opacity(
              opacity: contentCurved.value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - contentCurved.value)),
                child: child,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Pro aktiviert',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _C.textPrimary,
                        letterSpacing: -0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Dein Pro Zugang wurde aktiviert.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _C.textSecondary,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),

          // ── Buttons ──────────────────────────────────
          AnimatedBuilder(
            animation: contentCurved,
            builder: (_, child) => Opacity(
              opacity: contentCurved.value,
              child: child,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: _goToTimeline,
                    style: TextButton.styleFrom(
                      foregroundColor: _C.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: _C.textSecondary.withValues(alpha: 0.2),
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l.toTimeline),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openCaregiver,
                    icon: const Text(
                      '\u{1F468}\u200D\u{1F469}\u200D\u{1F467}',
                      style: TextStyle(fontSize: 18),
                    ),
                    label: Text(l.inviteFamilyMember),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Formatter: force uppercase while typing ─────────────────────────

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
