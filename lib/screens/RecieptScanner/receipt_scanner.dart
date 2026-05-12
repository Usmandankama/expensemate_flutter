import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/components/actionButton.dart';
import 'package:expense_mate_flutter/screens/expenses/review_expenses.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;

// ─── Color Palette ────────────────────────────────────────────────────────────
class _ScanColors {
  static const bg = Color(0xFF080C14);
  static const surface = Color(0xFF0F1520);
  static const card = Color(0xFF141C2E);
  static const border = Color(0xFF1E2D4A);
  static const accent = Color(0xFF00D4FF);
  static const accentGlow = Color(0x3300D4FF);
  static const accentSoft = Color(0xFF0099BB);
  static const success = Color(0xFF00F5A0);
  static const successGlow = Color(0x3300F5A0);
  static const error = Color(0xFFFF4D6D);
  static const textPrimary = Color(0xFFE8F4FF);
  static const textSecondary = Color(0xFF6B8BB0);
  static const textMuted = Color(0xFF2E4060);
}

// ─── Scan Status Enum ─────────────────────────────────────────────────────────
enum ScanStatus { idle, ocr, processing, success, error }

// ─── Animated Scanner Line ────────────────────────────────────────────────────
class _ScanLineWidget extends StatefulWidget {
  final bool active;
  const _ScanLineWidget({required this.active});

  @override
  State<_ScanLineWidget> createState() => _ScanLineWidgetState();
}

class _ScanLineWidgetState extends State<_ScanLineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pos;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pos = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_ScanLineWidget old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _pos,
      builder: (_, __) {
        return Positioned(
          top: _pos.value * 260,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _ScanColors.accent.withOpacity(0.8),
                  _ScanColors.accent,
                  _ScanColors.accent.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _ScanColors.accentGlow,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Pulsing Ring ─────────────────────────────────────────────────────────────
class _PulseRing extends StatefulWidget {
  final Color color;
  const _PulseRing({required this.color});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _scale = Tween<double>(begin: 0.8, end: 1.4).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.7, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(_opacity.value),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Spinning Arc Loader ──────────────────────────────────────────────────────
class _SpinningArc extends StatefulWidget {
  const _SpinningArc();

  @override
  State<_SpinningArc> createState() => _SpinningArcState();
}

class _SpinningArcState extends State<_SpinningArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(80, 80),
        painter: _ArcPainter(_ctrl.value),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = _ScanColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Glow
    final glowPaint = Paint()
      ..color = _ScanColors.accent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final startAngle = 2 * math.pi * progress - math.pi / 2;
    const sweepAngle = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─── Corner Brackets ─────────────────────────────────────────────────────────
class _CornerBrackets extends StatelessWidget {
  final Color color;
  const _CornerBrackets({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BracketPainter(color),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const len = 24.0;

    // Top-left
    canvas.drawLine(Offset(0, len), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(len, 0), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - len, size.height),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - len),
        Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}

// ─── Processing Overlay ───────────────────────────────────────────────────────
class _ProcessingOverlay extends StatefulWidget {
  final ScanStatus status;
  final String message;
  const _ProcessingOverlay({required this.status, required this.message});

  @override
  State<_ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<_ProcessingOverlay>
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
        isSuccess ? _ScanColors.success : (isError ? _ScanColors.error : _ScanColors.accent);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        decoration: BoxDecoration(
          color: _ScanColors.bg.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (!isSuccess && !isError) ...[
                  _PulseRing(color: iconColor),
                  const _SpinningArc(),
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

// ─── Main Page ────────────────────────────────────────────────────────────────
class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  ReceiptScannerPageState createState() => ReceiptScannerPageState();
}

class ReceiptScannerPageState extends State<ReceiptScannerPage>
    with SingleTickerProviderStateMixin {
  File? _image;
  String _extractedText = '';
  ScanStatus _status = ScanStatus.idle;
  String _statusMessage = '';
  int _itemCount = 0;

  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _entryFade =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      imageQuality: 85,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> _sendToBunBackend(String text) async {
    const String apiUrl = "http://10.28.239.253:3000/api/expenses";

    setState(() {
      _status = ScanStatus.processing;
      _statusMessage = "AI is analysing…";
    });

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"text": text}),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> items = [];

        if (decodedData is List) {
          items = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          items = decodedData['items'] ?? decodedData['data'] ?? [decodedData];
        }

        setState(() {
          _itemCount = items.length;
          _status = ScanStatus.success;
          _statusMessage = "Found $_itemCount items";
        });

        await Future.delayed(const Duration(milliseconds: 800));

        if (items.isNotEmpty) {
          Get.to(() => ReviewExpensesScreen(scannedItems: items));
        }

        setState(() => _status = ScanStatus.idle);
      } else {
        setState(() {
          _status = ScanStatus.error;
          _statusMessage = "Server error (${response.statusCode})";
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _status = ScanStatus.idle);
      }
    } catch (e) {
      setState(() {
        _status = ScanStatus.error;
        _statusMessage = "Connection failed";
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _status = ScanStatus.idle);
    }
  }

  void _scanReceipt(File image) async {
    setState(() {
      _image = image;
      _status = ScanStatus.ocr;
      _statusMessage = "Reading receipt…";
    });

    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognized =
          await textRecognizer.processImage(inputImage);

      if (recognized.text.trim().isEmpty) {
        setState(() {
          _status = ScanStatus.error;
          _statusMessage = "No text found";
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _status = ScanStatus.idle);
        return;
      }

      setState(() => _extractedText = recognized.text);
      await _sendToBunBackend(recognized.text);
    } catch (e) {
      setState(() {
        _status = ScanStatus.error;
        _statusMessage = "OCR failed";
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _status = ScanStatus.idle);
    } finally {
      textRecognizer.close();
    }
  }

  void _retryAI() {
    if (_extractedText.isNotEmpty) _sendToBunBackend(_extractedText);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SourceSheet(
        onCamera: () async {
          Navigator.pop(context);
          final img = await _pickImage(ImageSource.camera);
          if (img != null) _scanReceipt(img);
        },
        onGallery: () async {
          Navigator.pop(context);
          final img = await _pickImage(ImageSource.gallery);
          if (img != null) _scanReceipt(img);
        },
      ),
    );
  }

  bool get _isBusy =>
      _status == ScanStatus.ocr || _status == ScanStatus.processing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ScanColors.bg,
      body: FadeTransition(
        opacity: _entryFade,
        child: SlideTransition(
          position: _entrySlide,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildViewfinder(),
                        const SizedBox(height: 24),
                        _buildStatusChip(),
                        const SizedBox(height: 20),
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _ScanColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _ScanColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _ScanColors.textSecondary, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Receipt Scanner",
                style: TextStyle(
                  color: _ScanColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                _image != null ? "Image loaded" : "Point at your receipt",
                style: const TextStyle(
                  color: _ScanColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (_extractedText.isNotEmpty && !_isBusy)
            GestureDetector(
              onTap: _retryAI,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _ScanColors.accentGlow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _ScanColors.accent.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: _ScanColors.accent, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Retry",
                      style: TextStyle(
                        color: _ScanColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Viewfinder ───────────────────────────────────────────────────────────────
  Widget _buildViewfinder() {
    final bool scanning = _status == ScanStatus.ocr;
    final bool processing = _status == ScanStatus.processing;
    final bool success = _status == ScanStatus.success;
    final bool error = _status == ScanStatus.error;

    Color bracketColor = _ScanColors.border;
    if (scanning) bracketColor = _ScanColors.accent;
    if (success) bracketColor = _ScanColors.success;
    if (error) bracketColor = _ScanColors.error;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: _ScanColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scanning
                ? _ScanColors.accent.withOpacity(0.5)
                : success
                    ? _ScanColors.success.withOpacity(0.4)
                    : _ScanColors.border,
          ),
          boxShadow: [
            if (scanning)
              BoxShadow(
                color: _ScanColors.accentGlow,
                blurRadius: 24,
                spreadRadius: 2,
              ),
            if (success)
              BoxShadow(
                color: _ScanColors.successGlow,
                blurRadius: 24,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image or placeholder
              if (_image != null)
                Image.file(_image!, fit: BoxFit.cover)
              else
                _buildEmptyViewfinder(),

              // Dark overlay when processing
              if (_isBusy || success || error)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: (_isBusy || success || error) ? 1.0 : 0.0,
                  child: _ProcessingOverlay(
                    status: _status,
                    message: _statusMessage,
                  ),
                ),

              // Corner brackets
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _CornerBrackets(color: bracketColor),
                ),
              ),

              // Scan line
              _ScanLineWidget(active: scanning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyViewfinder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _ScanColors.border.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: _ScanColors.textMuted, size: 34),
        ),
        const SizedBox(height: 16),
        const Text(
          "No receipt loaded",
          style: TextStyle(
            color: _ScanColors.textMuted,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Tap below to scan",
          style: TextStyle(
            color: _ScanColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ── Status chip ──────────────────────────────────────────────────────────────
  Widget _buildStatusChip() {
    String label;
    Color color;
    IconData icon;

    switch (_status) {
      case ScanStatus.idle:
        label = _image != null ? "Ready to scan" : "Awaiting image";
        color = _ScanColors.textSecondary;
        icon = Icons.radio_button_unchecked_rounded;
        break;
      case ScanStatus.ocr:
        label = "Reading receipt text";
        color = _ScanColors.accent;
        icon = Icons.document_scanner_rounded;
        break;
      case ScanStatus.processing:
        label = "AI processing expenses";
        color = _ScanColors.accent;
        icon = Icons.auto_awesome_rounded;
        break;
      case ScanStatus.success:
        label = "Found $_itemCount items";
        color = _ScanColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case ScanStatus.error:
        label = _statusMessage;
        color = _ScanColors.error;
        icon = Icons.warning_amber_rounded;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_status),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Widget _buildActions() {
    return GestureDetector(
      onTap: _isBusy ? null : _showImageSourceDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: _isBusy
              ? null
              : LinearGradient(
                  colors: [_ScanColors.accent, _ScanColors.accentSoft],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isBusy ? _ScanColors.border : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isBusy
              ? null
              : [
                  BoxShadow(
                    color: _ScanColors.accent.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                color: _isBusy
                    ? _ScanColors.textMuted
                    : _ScanColors.bg,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                _isBusy ? "Processing…" : "Scan Receipt",
                style: TextStyle(
                  color: _isBusy ? _ScanColors.textMuted : _ScanColors.bg,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Image Source Bottom Sheet ────────────────────────────────────────────────
class _SourceSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const _SourceSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: _ScanColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _ScanColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Import Receipt",
            style: TextStyle(
              color: _ScanColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Choose your image source",
            style: TextStyle(color: _ScanColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _SheetOption(
            icon: Icons.camera_alt_rounded,
            iconColor: _ScanColors.accent,
            iconBg: _ScanColors.accentGlow,
            title: "Take a Photo",
            subtitle: "Use your camera to capture a receipt",
            onTap: onCamera,
          ),
          const SizedBox(height: 12),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFF9B8EFF),
            iconBg: const Color(0x229B8EFF),
            title: "Choose from Gallery",
            subtitle: "Pick an existing photo from your library",
            onTap: onGallery,
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _ScanColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ScanColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ScanColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _ScanColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _ScanColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}