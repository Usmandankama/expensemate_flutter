import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'home_colors.dart';

// ─── Action Buttons Component ───────────────────────────────────────────────────
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              label: 'Add Expense',
              icon: Icons.credit_card_outlined,
              iconColor: HomeColors.error,
              iconBg: HomeColors.error.withOpacity(0.15),
              onTap: () => Get.toNamed('/expenses'),
            ),
          ),
          SizedBox(width: 12.w),
          // Scanner — hero button
          GestureDetector(
            onTap: () => Get.toNamed('/scan-receipt'),
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: HomeColors.accent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: HomeColors.textPrimary,
                size: 24.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ActionButton(
              label: 'Add Income',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: HomeColors.success,
              iconBg: HomeColors.success.withOpacity(0.15),
              onTap: () => Get.toNamed('/income'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Button Widget ───────────────────────────────────────────────────────
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: HomeColors.white10,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.r),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                color: HomeColors.white70,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
