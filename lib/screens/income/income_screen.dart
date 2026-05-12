import 'package:expense_mate_flutter/controllers/income_controller.dart';
import 'package:expense_mate_flutter/screens/components/custom_datepicker.dart';
import 'package:expense_mate_flutter/screens/income/components/income_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen>
    with SingleTickerProviderStateMixin {
  final IncomeController incomeController = Get.find<IncomeController>();

  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  IconData? _selectedIcon;
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // ── Palette ──────────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0F1B2D);
  static const _card = Color(0xFF1A2B40);
  static const _border = Color(0xFF1E3A5F);
  static const _green = Color(0xFF34D399);
  static const _greenGlow = Color(0x2234D399);
  static const _textPrimary = Color(0xFFE8F4FF);
  static const _textSecondary = Color(0xFF6B8BB0);
  static const _textMuted = Color(0xFF2E4060);
  static const _error = Color(0xFFFF4D6D);

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
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      Get.snackbar(
        "Missing category",
        "Please select an income category",
        backgroundColor: _error.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 12,
        margin: EdgeInsets.all(16.w),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isLoading = true);

    incomeController.addIncome(
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
      iconPath: _selectedIcon,
    );

    _nameCtrl.clear();
    _amountCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _selectedCategory = '';
      _selectedIcon = null;
      _selectedDate = DateTime.now();
      _isLoading = false;
    });

    Get.snackbar(
      "Income added",
      "Your income has been recorded",
      backgroundColor: _green.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16.w),
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.check_circle_outline_rounded,
          color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAmountHero(),
                          SizedBox(height: 24.h),
                          _buildLabel("Category"),
                          SizedBox(height: 8.h),
                          _buildCategoryWrapper(),
                          SizedBox(height: 20.h),
                          _buildLabel("Name"),
                          SizedBox(height: 8.h),
                          _buildField(
                            controller: _nameCtrl,
                            hint: "e.g. Monthly salary",
                            icon: Icons.badge_outlined,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? "Enter a name"
                                : null,
                          ),
                          SizedBox(height: 20.h),
                          _buildLabel("Date"),
                          SizedBox(height: 8.h),
                          _buildDatePicker(),
                          SizedBox(height: 20.h),
                          _buildLabel("Description"),
                          SizedBox(height: 8.h),
                          _buildField(
                            controller: _descCtrl,
                            hint: "Add a note (optional)",
                            icon: Icons.notes_rounded,
                            maxLines: 3,
                          ),
                          SizedBox(height: 32.h),
                          _buildSubmitButton(),
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

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _border),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textSecondary, size: 16.r),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Income",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                "Record a new income entry",
                style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.sp,
                    fontFamily: 'Poppins'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Big amount input ──────────────────────────────────────────────────────────
  Widget _buildAmountHero() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: _greenGlow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.account_balance_wallet_outlined,
                    color: _green, size: 14.r),
              ),
              SizedBox(width: 8.w),
              Text(
                "AMOUNT",
                style: TextStyle(
                  color: _green.withOpacity(0.7),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            style: TextStyle(
              color: _textPrimary,
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Enter an amount";
              final n = double.tryParse(v);
              if (n == null || n <= 0) return "Enter a valid amount";
              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "0.00",
              hintStyle: TextStyle(
                color: _textMuted,
                fontSize: 36.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
              prefixText: "RM  ",
              prefixStyle: TextStyle(
                color: _green,
                fontSize: 36.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
              errorStyle: TextStyle(color: _error, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category wrapper ──────────────────────────────────────────────────────────
  Widget _buildCategoryWrapper() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _selectedCategory.isNotEmpty
              ? _green.withOpacity(0.4)
              : _border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: IncomeDropdown(
          onCategorySelected: (category, icon) {
            setState(() {
              _selectedCategory = category;
              _selectedIcon = icon;
            });
          },
        ),
      ),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
          color: _textPrimary, fontSize: 14.sp, fontFamily: 'Poppins'),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: _textMuted, fontSize: 14.sp, fontFamily: 'Poppins'),
        prefixIcon:
            Icon(icon, color: _textSecondary, size: 18.r),
        filled: true,
        fillColor: _card,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _green.withOpacity(0.6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _error),
        ),
        errorStyle: TextStyle(color: _error, fontSize: 11.sp),
      ),
    );
  }

  // ── Date picker ───────────────────────────────────────────────────────────────
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: _green,
                surface: Color(0xFF1A2B40),
              ),
              dialogBackgroundColor: const Color(0xFF0F1B2D),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: _textSecondary, size: 18.r),
            SizedBox(width: 12.w),
            Text(
              DateFormat('dd MMM yyyy').format(_selectedDate),
              style: TextStyle(
                color: _textPrimary,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: _textMuted, size: 18.r),
          ],
        ),
      ),
    );
  }

  // ── Label ─────────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: _textSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        fontFamily: 'Poppins',
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : LinearGradient(
                  colors: [_green, const Color(0xFF00BF7A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isLoading ? _border : null,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: _isLoading
              ? null
              : [
                  BoxShadow(
                    color: _green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: const Color(0xFF0F1B2D), size: 18.r),
                    SizedBox(width: 8.w),
                    Text(
                      "Add Income",
                      style: TextStyle(
                        color: const Color(0xFF0F1B2D),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
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