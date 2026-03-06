import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../screens/qr_scanner_screen.dart';
import '../../../ui/ui.dart';
import '../data/doctor_invite_service.dart';

/// Patient-facing screen to connect with a doctor by entering an invite code.
///
/// Supports manual code entry, QR scanning, and deep-link pre-fill.
class ConnectDoctorScreen extends StatefulWidget {
  const ConnectDoctorScreen({super.key, this.initialCode});

  /// Pre-filled code, typically from a deep link.
  final String? initialCode;

  @override
  State<ConnectDoctorScreen> createState() => _ConnectDoctorScreenState();
}

class _ConnectDoctorScreenState extends State<ConnectDoctorScreen>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  final _service = DoctorInviteService();

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

    if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!;
    }

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
    _codeController.dispose();
    _focusNode.dispose();
    _iconCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Bitte gib den Code deines Arztes ein.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _service.acceptInvite(code);
      if (!mounted) return;

      HapticFeedback.heavyImpact();
      setState(() {
        _loading = false;
        _success = true;
      });
      _playSuccessAnimation();
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _loading = false;
        _error = _mapError(e);
      });
    }
  }

  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('ungültiger code') || msg.contains('not found')) {
      return 'Code nicht gefunden. Bitte prüfe die Eingabe.';
    }
    if (msg.contains('abgelaufen') || msg.contains('expired')) {
      return 'Dieser Code ist abgelaufen. Bitte frage deinen Arzt nach einem neuen.';
    }
    if (msg.contains('bereits') || msg.contains('already')) {
      return 'Dieser Code wurde bereits verwendet.';
    }
    if (msg.contains('nicht eingeloggt')) {
      return 'Du bist nicht eingeloggt. Bitte melde dich an.';
    }
    return 'Verbindung fehlgeschlagen. Bitte versuche es erneut.';
  }

  Future<void> _scanQrCode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && mounted) {
      setState(() {
        _codeController.text = code;
        _error = null;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) return;

    // Try to extract a doctor invite code from a link or raw code
    final extracted = _extractDoctorCode(text);
    if (extracted != null && mounted) {
      setState(() {
        _codeController.text = extracted;
        _error = null;
      });
    } else if (mounted) {
      setState(() {
        _codeController.text = text.toUpperCase();
        _error = null;
      });
    }
  }

  String? _extractDoctorCode(String input) {
    // Deep link: .../doctor-invite/ABCD1234
    final linkMatch = RegExp(
      r'doctor-invite/([A-Za-z0-9]{6,12})',
      caseSensitive: false,
    ).firstMatch(input);
    if (linkMatch != null) return linkMatch.group(1)!.toUpperCase();

    // Raw 8-char alphanumeric code
    final trimmed = input.trim().toUpperCase();
    if (RegExp(r'^[A-Z2-9]{8}$').hasMatch(trimmed)) return trimmed;

    return null;
  }

  Future<void> _playSuccessAnimation() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _iconCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _contentCtrl.forward();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
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
    return GestureDetector(
      key: const ValueKey('form'),
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: _goBack,
            ),
            title: Text(
              'Mit Arzt verbinden',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: true,
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),

                // ── Hero illustration ──────────────────────────
                _buildHeroSection(),

                const SizedBox(height: 32),

                // ── Code input card ────────────────────────────
                _buildCodeInputCard(),

                const SizedBox(height: 20),

                // ── Quick actions ──────────────────────────────
                _buildQuickActions(),

                const SizedBox(height: 24),

                // ── Info box ───────────────────────────────────
                _buildInfoBox(),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Doctor icon in gradient circle
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.accent.withValues(alpha: 0.10),
              ],
            ),
          ),
          child: const Center(
            child: Text('👨‍⚕️', style: TextStyle(fontSize: 44)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Arzt-Code eingeben',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Dein Arzt hat dir einen Verbindungscode gegeben?\nGib ihn hier ein, um euch zu verbinden.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCodeInputCard() {
    return GlassContainer(
      variant: GlassVariant.thick,
      elevation: GlassElevation.medium,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label
          Row(
            children: [
              Icon(Icons.vpn_key_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Verbindungscode',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Code input field
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _error != null
                    ? AppColors.error.withValues(alpha: 0.5)
                    : AppColors.grey200,
              ),
            ),
            child: TextField(
              controller: _codeController,
              focusNode: _focusNode,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Menlo',
                fontFamilyFallback: ['Courier New', 'monospace'],
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'ABCD1234',
                hintStyle: TextStyle(
                  fontFamily: 'Menlo',
                  fontFamilyFallback: const ['Courier New', 'monospace'],
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                  color: AppColors.grey300,
                ),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              inputFormatters: [
                UpperCaseTextFormatter(),
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(12),
              ],
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
            ),
          ),

          // Error message
          if (_error != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Submit button
          GlassButton(
            onPressed: _loading ? null : _submit,
            label: 'Verbinden',
            icon: Icons.link_rounded,
            isLoading: _loading,
            expand: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            emoji: '📷',
            label: 'QR-Code\nscannen',
            onTap: _scanQrCode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            emoji: '📋',
            label: 'Aus Zwischen-\nablage einfügen',
            onTap: _pasteFromClipboard,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return GlassContainer(
      variant: GlassVariant.thin,
      elevation: GlassElevation.flat,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'So funktioniert\'s',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1. Dein Arzt erstellt einen Code in seiner App\n'
                  '2. Du gibst den Code hier ein oder scannst den QR-Code\n'
                  '3. Dein Arzt kann deinen Fortschritt begleiten',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Success state ──────────────────────────────────────────────────

  Widget _buildSuccess() {
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
                color: AppColors.success.withValues(alpha: 0.12),
              ),
              child: const Center(
                child: Text('🩺', style: TextStyle(fontSize: 52)),
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
                  'Verbunden!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Du bist jetzt mit deinem Arzt verbunden.\n'
                  'Er kann deinen Fortschritt in der App verfolgen.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
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
                GlassButton(
                  onPressed: _goBack,
                  label: 'Fertig',
                  icon: Icons.check_rounded,
                  expand: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick action tile ────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
            ),
          ],
        ),
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
