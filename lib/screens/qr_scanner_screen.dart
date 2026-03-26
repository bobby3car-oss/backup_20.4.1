import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../ui/ui.dart';
import '../l10n/app_localizations.dart';

/// Full-screen QR scanner that detects invite links and returns the code.
///
/// Usage:
/// ```dart
/// final code = await Navigator.of(context).push<String>(
///   MaterialPageRoute(builder: (_) => const QrScannerScreen()),
/// );
/// ```
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;

      final code = _extractCode(raw);
      if (code != null) {
        _scanned = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
  }

  /// Extracts the invite code from a deep link or raw code input.
  String? _extractCode(String input) {
    final trimmed = input.trim().toUpperCase();

    // Permanent doctor link URL: .../doctor-link/ABCDEF1234
    final permanentMatch = RegExp(
      r'doctor-link/([A-Z0-9]{6,16})',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (permanentMatch != null) return permanentMatch.group(1);

    // Doctor invite URL: .../doctor-invite/ABCD1234
    final doctorUrlMatch = RegExp(
      r'doctor-invite/([A-Z0-9]{6,16})',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (doctorUrlMatch != null) return doctorUrlMatch.group(1);

    // Caregiver invite URL: .../invite/ABCDEF123456
    final urlMatch = RegExp(
      r'operationsbegleiter-860e7\.web\.app/invite/([A-F0-9]{12})',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (urlMatch != null) return urlMatch.group(1);

    // Raw 8-char doctor code (alphanumeric, no ambiguous chars)
    if (RegExp(r'^[A-Z2-9]{8}$').hasMatch(trimmed)) return trimmed;

    // Raw 12-char hex code (caregiver)
    if (RegExp(r'^[A-F0-9]{12}$').hasMatch(trimmed)) return trimmed;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l.qrCodeScan),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay with scan frame
          _ScanOverlay(),

          // Bottom hint
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxxl,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: AppRadius.borderRadiusLg,
                  ),
                  child: const Text(
                    'Richte die Kamera auf den QR-Code\nder Einladung',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GlassButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: l.cancel,
                  variant: GlassButtonVariant.ghost,
                  expand: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan overlay with transparent cutout ──

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanSize = constraints.maxWidth * 0.7;
        final top = (constraints.maxHeight - scanSize) / 2 - 40;
        final left = (constraints.maxWidth - scanSize) / 2;

        return Stack(
          children: [
            // Dimmed background
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: scanSize,
                      height: scanSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // blended out
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Corner decorations
            Positioned(
              top: top - 2,
              left: left - 2,
              child: _Corner(alignment: Alignment.topLeft),
            ),
            Positioned(
              top: top - 2,
              right: left - 2,
              child: _Corner(alignment: Alignment.topRight),
            ),
            Positioned(
              bottom: constraints.maxHeight - top - scanSize - 2,
              left: left - 2,
              child: _Corner(alignment: Alignment.bottomLeft),
            ),
            Positioned(
              bottom: constraints.maxHeight - top - scanSize - 2,
              right: left - 2,
              child: _Corner(alignment: Alignment.bottomRight),
            ),
          ],
        );
      },
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.isTop, required this.isLeft});
  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height * 0.6);
      path.lineTo(0, 4);
      path.quadraticBezierTo(0, 0, 4, 0);
      path.lineTo(size.width * 0.6, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width * 0.4, 0);
      path.lineTo(size.width - 4, 0);
      path.quadraticBezierTo(size.width, 0, size.width, 4);
      path.lineTo(size.width, size.height * 0.6);
    } else if (!isTop && isLeft) {
      path.moveTo(0, size.height * 0.4);
      path.lineTo(0, size.height - 4);
      path.quadraticBezierTo(0, size.height, 4, size.height);
      path.lineTo(size.width * 0.6, size.height);
    } else {
      path.moveTo(size.width * 0.4, size.height);
      path.lineTo(size.width - 4, size.height);
      path.quadraticBezierTo(size.width, size.height, size.width, size.height - 4);
      path.lineTo(size.width, size.height * 0.4);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
