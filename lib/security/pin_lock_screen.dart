import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/ui.dart';
import 'pin_lock_service.dart';
import '../l10n/app_localizations.dart';

/// A fullscreen overlay that asks the user to enter the 4-digit PIN.
///
/// Used both for:
///  • **Setup** (`mode: PinScreenMode.setup`) – user creates a new PIN
///  • **Unlock** (`mode: PinScreenMode.unlock`) – user unlocks the app
///  • **Confirm** (`mode: PinScreenMode.confirmDisable`) – user confirms
///    current PIN before removing it
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key, required this.mode});

  final PinScreenMode mode;

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

enum PinScreenMode { setup, unlock, confirmDisable }

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  final _pinService = PinLockService();
  final List<int> _entered = [];
  String? _firstPin; // used during setup for confirmation
  String _title = '';
  String? _error;
  bool _locked = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _updateTitle();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _updateTitle() {
    final l = AppLocalizations.of(context)!;
    switch (widget.mode) {
      case PinScreenMode.setup:
        _title = _firstPin == null ? 'PIN eingeben' : l.pinBestaetigen;
        break;
      case PinScreenMode.unlock:
        _title = 'App entsperren';
        break;
      case PinScreenMode.confirmDisable:
        _title = 'PIN eingeben zum Deaktivieren';
        break;
    }
  }

  Future<void> _onDigit(int digit) async {
    final l = AppLocalizations.of(context)!;
    if (_entered.length >= 4 || _locked) return;
    setState(() {
      _entered.add(digit);
      _error = null;
    });
    HapticFeedback.lightImpact();

    if (_entered.length == 4) {
      final pin = _entered.join();

      switch (widget.mode) {
        case PinScreenMode.setup:
          if (_firstPin == null) {
            // First entry – ask to confirm
            _firstPin = pin;
            _entered.clear();
            setState(() => _updateTitle());
          } else {
            // Confirmation
            if (pin == _firstPin) {
              await _pinService.setPin(pin);
              if (mounted) Navigator.of(context).pop(true);
            } else {
              _triggerError(l.pinsStimmenNichtUeberein);
            }
          }
          break;

        case PinScreenMode.unlock:
          try {
            final ok = await _pinService.verify(pin);
            if (ok) {
              if (mounted) Navigator.of(context).pop(true);
            } else {
              _triggerError('Falscher PIN');
            }
          } on StateError {
            _triggerLockout();
          }
          break;

        case PinScreenMode.confirmDisable:
          try {
            final ok = await _pinService.verify(pin);
            if (ok) {
              await _pinService.removePin();
              if (mounted) Navigator.of(context).pop(true);
            } else {
              _triggerError('Falscher PIN');
            }
          } on StateError {
            _triggerLockout();
          }
          break;
      }
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() {
      _entered.removeLast();
      _error = null;
    });
    HapticFeedback.lightImpact();
  }

  void _triggerError(String msg) {
    _entered.clear();
    setState(() => _error = msg);
    _shakeCtrl.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  void _triggerLockout() {
    _entered.clear();
    setState(() {
      _locked = true;
      _error = 'Zu viele Versuche – bitte warte 30 Sekunden';
    });
    _shakeCtrl.forward(from: 0);
    HapticFeedback.heavyImpact();
    Future.delayed(PinLockService.lockoutDuration, () {
      if (mounted) setState(() => _locked = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.mode != PinScreenMode.unlock,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.mode != PinScreenMode.unlock)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                ),
              const Spacer(flex: 2),
              // Lock icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) {
                  final dx = _shakeAnim.value *
                      10 *
                      ((_shakeCtrl.value * 4 * 3.14159).remainder(3.14159) > 1.5
                          ? -1
                          : 1);
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _entered.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: filled ? 18 : 14,
                      height: filled ? 18 : 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _error != null
                            ? AppColors.error
                            : filled
                                ? AppColors.primary
                                : AppColors.grey300,
                      ),
                    );
                  }),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(flex: 1),
              // Numpad
              _buildNumpad(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _numRow([1, 2, 3]),
          const SizedBox(height: 16),
          _numRow([4, 5, 6]),
          const SizedBox(height: 16),
          _numRow([7, 8, 9]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _emptyKey(),
              _digitKey(0),
              _deleteKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numRow(List<int> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_digitKey).toList(),
    );
  }

  Widget _digitKey(int digit) {
    return GestureDetector(
      onTap: () => _onDigit(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$digit',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: AppColors.grey900,
          ),
        ),
      ),
    );
  }

  Widget _deleteKey() {
    return GestureDetector(
      onTap: _onDelete,
      child: const SizedBox(
        width: 72,
        height: 72,
        child: Icon(
          Icons.backspace_outlined,
          size: 26,
          color: AppColors.grey600,
        ),
      ),
    );
  }

  Widget _emptyKey() => const SizedBox(width: 72, height: 72);
}
