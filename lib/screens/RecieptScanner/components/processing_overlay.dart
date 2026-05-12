import 'package:flutter/material.dart';
import 'scan_colors.dart';
import 'pulse_ring.dart';
import 'spinning_arc.dart';

// ─── Scan Status Enum ─────────────────────────────────────────────────────────
enum ScanStatus { idle, ocr, processing, success, error }

// ─── Processing Overlay ───────────────────────────────────────────────────────
class ProcessingOverlay extends StatefulWidget {
  final ScanStatus status;
  final String message;
  const ProcessingOverlay({required this.status, required this.message});

  @override
  State<ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<ProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.status == ScanStatus.success;
    final isError = widget.status == ScanStatus.error;
    final iconColor =
        isSuccess ? ScanColors.success : (isError ? ScanColors.error : ScanColors.accent);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        decoration: BoxDecoration(
          color: ScanColors.bg.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (!isSuccess && !isError) ...[
                  PulseRing(color: iconColor),
                  const SpinningArc(),
                ],
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.12),
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_rounded
                        : isError
                            ? Icons.error_outline_rounded
                            : Icons.document_scanner_rounded,
                    color: iconColor,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
