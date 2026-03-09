import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/staff_management_service.dart';

/// Screen for a user to accept a staff invite by entering the code.
///
/// Supports manual entry and deep-link pre-fill via [initialCode].
class AcceptStaffInviteScreen extends StatefulWidget {
  const AcceptStaffInviteScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<AcceptStaffInviteScreen> createState() =>
      _AcceptStaffInviteScreenState();
}

class _AcceptStaffInviteScreenState extends State<AcceptStaffInviteScreen>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  final _service = StaffManagementService();

  bool _loading = false;
  bool _success = false;
  String? _error;

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

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Bitte geben Sie den Einladungscode ein.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _service.acceptStaffInvite(code);
      if (!mounted) return;
      setState(() => _success = true);
      _iconCtrl.forward();
      _contentCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() {
        _error = msg.contains('not-found')
            ? 'Code nicht gefunden.'
            : msg.contains('expired')
                ? 'Code abgelaufen.'
                : msg.contains('already used')
                    ? 'Code wurde bereits eingelöst.'
                    : msg.contains('own invite')
                        ? 'Sie können Ihren eigenen Code nicht einlösen.'
                        : msg.contains('another doctor')
                            ? 'Sie sind bereits einem anderen Arzt zugeordnet.'
                            : msg.contains('Doctors and admins')
                                ? 'Ärzte und Administratoren können nicht als '
                                    'Mitarbeiter registriert werden.'
                                : 'Fehler: $msg';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mitarbeiter-Einladung'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: _success ? _buildSuccess(theme) : _buildForm(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.badge_rounded,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Einladungscode eingeben',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Geben Sie den Code ein, den Sie von\nIhrer Arztpraxis erhalten haben.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GlassContainer(
          padding: AppSpacing.paddingLg,
          child: TextField(
            controller: _codeController,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              letterSpacing: 6,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'CODE EINGEBEN',
              hintStyle: theme.textTheme.headlineSmall?.copyWith(
                letterSpacing: 6,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              UpperCaseTextFormatter(),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Code einlösen'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    return FadeTransition(
      opacity: _contentCtrl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _iconScale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Willkommen im Team!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sie sind jetzt als Mitarbeiter/in registriert.\n'
            'Starten Sie die App neu, um das Dashboard zu sehen.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text('Fertig'),
          ),
        ],
      ),
    );
  }
}

/// Input formatter that converts to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
