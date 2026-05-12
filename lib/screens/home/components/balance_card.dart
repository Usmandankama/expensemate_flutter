import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'home_colors.dart';

// ─── Balance Card Component ─────────────────────────────────────────────────────
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HomeColors.accent,
            HomeColors.accent.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: HomeColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: HomeColors.white20,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Obx(
                  () => Text(
                    controller.userName.isNotEmpty
                        ? controller.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: HomeColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        color: HomeColors.white70,
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.userName,
                        style: TextStyle(
                          color: HomeColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed('/notifications'),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: HomeColors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: HomeColors.textPrimary,
                    size: 20.r,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Total Balance',
            style: TextStyle(
              color: HomeColors.white70,
              fontSize: 12.sp,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 6.h),
          Obx(
            () => Text(
              'RM ${controller.totalBalance.value.toStringAsFixed(2)}',
              style: TextStyle(
                color: HomeColors.textPrimary,
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: BalancePill(
                  label: 'Income',
                  valueObs: controller.totalIncome,
                  color: HomeColors.success,
                  prefix: '+',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: BalancePill(
                  label: 'Expenses',
                  valueObs: controller.totalSpent,
                  color: HomeColors.error,
                  prefix: '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─── Balance Pill Widget ───────────────────────────────────────────────────────
class BalancePill extends StatelessWidget {
  final String label;
  final RxDouble valueObs;
  final Color color;
  final String prefix;

  const BalancePill({
    super.key,
    required this.label,
    required this.valueObs,
    required this.color,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: HomeColors.white10,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: HomeColors.white70,
              fontSize: 11.sp,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 3.h),
          Obx(
            () => Text(
              '$prefix RM ${valueObs.value.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
