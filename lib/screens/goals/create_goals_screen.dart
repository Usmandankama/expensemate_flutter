import 'package:expense_mate_flutter/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ─── Shared Colors ────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF080C14);
  static const surface = Color(0xFF0F1520);
  static const card = Color(0xFF141C2E);
  static const border = Color(0xFF1E2D4A);
  static const accent = Color(0xFF00D4FF);
  static const accentGlow = Color(0x3300D4FF);
  static const success = Color(0xFF00F5A0);
  static const textPrimary = Color(0xFFE8F4FF);
  static const textSecondary = Color(0xFF6B8BB0);
  static const textMuted = Color(0xFF2E4060);
  static const error = Color(0xFFFF4D6D);
}

// ─── Emoji Picker Options ─────────────────────────────────────────────────────
const _kEmojis = [
  '🎯', '🏠', '✈️', '🚗', '💻', '📱', '🎓', '💍',
  '🏋️', '🎮', '📷', '🏖️', '🎸', '👟', '⌚', '🐶',
];

// ─── Create Goal Screen ───────────────────────────────────────────────────────
class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen>
    with SingleTickerProviderStateMixin {
  final _service = SavingsGoalService();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedEmoji = '🎯';
  DateTime? _deadline;
  bool _isSaving = false;

  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _service.createGoal(
        name: _nameCtrl.text.trim(),
        emoji: _selectedEmoji,
        targetAmount: double.parse(_amountCtrl.text),
        deadline: _deadline,
      );
      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create goal: $e"),
          backgroundColor: _C.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _C.accent,
              surface: _C.card,
            ),
            dialogBackgroundColor: _C.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEmojiPicker(),
                          const SizedBox(height: 24),
                          _buildLabel("Goal Name"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameCtrl,
                            hint: "e.g. New Laptop",
                            validator: (v) => v == null || v.trim().isEmpty
                                ? "Enter a goal name"
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildLabel("Target Amount (RM)"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _amountCtrl,
                            hint: "e.g. 2000",
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'))
                            ],
                            prefix: const Text("RM ",
                                style: TextStyle(
                                    color: _C.accent,
                                    fontWeight: FontWeight.w700)),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Enter an amount";
                              final n = double.tryParse(v);
                              if (n == null || n <= 0) return "Enter a valid amount";
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildLabel("Deadline (Optional)"),
                          const SizedBox(height: 8),
                          _buildDeadlinePicker(),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                        ],
                      ),
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
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _C.textSecondary, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Savings Goal",
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                "What are you saving towards?",
                style: TextStyle(color: _C.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _C.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Pick an Icon"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _kEmojis.map((e) {
            final selected = e == _selectedEmoji;
            return GestureDetector(
              onTap: () => setState(() => _selectedEmoji = e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? _C.accentGlow : _C.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? _C.accent.withOpacity(0.6)
                        : _C.border,
                  ),
                ),
                child: Center(
                  child: Text(e, style: const TextStyle(fontSize: 22)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: _C.textPrimary, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _C.textMuted, fontSize: 14),
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, top: 14),
                child: prefix,
              )
            : null,
        filled: true,
        fillColor: _C.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.error),
        ),
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    return GestureDetector(
      onTap: _pickDeadline,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _deadline != null
                ? _C.accent.withOpacity(0.4)
                : _C.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: _deadline != null ? _C.accent : _C.textMuted,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              _deadline != null
                  ? _formatDate(_deadline!)
                  : "No deadline set",
              style: TextStyle(
                color: _deadline != null ? _C.textPrimary : _C.textMuted,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (_deadline != null)
              GestureDetector(
                onTap: () => setState(() => _deadline = null),
                child: const Icon(Icons.close_rounded,
                    color: _C.textMuted, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isSaving
              ? null
              : const LinearGradient(
                  colors: [_C.accent, Color(0xFF0099BB)],
                ),
          color: _isSaving ? _C.border : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isSaving
              ? null
              : [
                  BoxShadow(
                    color: _C.accent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: _C.accent,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Create Goal",
                  style: TextStyle(
                    color: _C.bg,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─── Add Contribution Bottom Sheet ───────────────────────────────────────────
class AddContributionSheet extends StatefulWidget {
  final SavingsGoal goal;
  final SavingsGoalService service;
  final VoidCallback? onAdded;

  const AddContributionSheet({
    super.key,
    required this.goal,
    required this.service,
    this.onAdded,
  });

  @override
  State<AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<AddContributionSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Quick amount presets
  final _presets = [10.0, 50.0, 100.0, 500.0];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await widget.service.addContribution(
        goalId: widget.goal.id,
        amount: double.parse(_amountCtrl.text),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      widget.onAdded?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: $e"), backgroundColor: _C.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.remaining;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.goal.emoji,
                    style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goal.name,
                      style: const TextStyle(
                        color: _C.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "RM ${remaining.toStringAsFixed(2)} remaining",
                      style: const TextStyle(
                          color: _C.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick presets
            Wrap(
              spacing: 8,
              children: _presets.map((p) {
                return GestureDetector(
                  onTap: () =>
                      _amountCtrl.text = p.toStringAsFixed(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _C.accentGlow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _C.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      "RM ${p.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: _C.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Amount field
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'))
              ],
              autofocus: true,
              style: const TextStyle(
                  color: _C.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800),
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter an amount";
                final n = double.tryParse(v);
                if (n == null || n <= 0) return "Enter a valid amount";
                return null;
              },
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: const TextStyle(
                    color: _C.textMuted,
                    fontSize: 28,
                    fontWeight: FontWeight.w800),
                prefixText: "RM ",
                prefixStyle: const TextStyle(
                  color: _C.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                filled: true,
                fillColor: _C.card,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.accent),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Note field
            TextFormField(
              controller: _noteCtrl,
              style:
                  const TextStyle(color: _C.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Add a note (optional)",
                hintStyle:
                    const TextStyle(color: _C.textMuted, fontSize: 14),
                filled: true,
                fillColor: _C.card,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.accent),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            GestureDetector(
              onTap: _isSaving ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: _isSaving
                      ? null
                      : const LinearGradient(
                          colors: [_C.success, Color(0xFF00BF7A)],
                        ),
                  color: _isSaving ? _C.border : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isSaving
                      ? null
                      : [
                          BoxShadow(
                            color: _C.success.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: _C.success, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.savings_rounded,
                                color: _C.bg, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Add to Goal",
                              style: TextStyle(
                                color: _C.bg,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}