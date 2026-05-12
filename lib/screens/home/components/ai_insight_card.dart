import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'home_colors.dart';

// ─── AI Insight Card Component ─────────────────────────────────────────────────
class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HomeColors.purple.withOpacity(0.2),
              HomeColors.purple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: HomeColors.purple.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: HomeColors.purple.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: HomeColors.purple,
                    size: 16.r,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'AI Insight',
                  style: TextStyle(
                    color: HomeColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Obx(
              () => Text(
                controller.aiInsight.value.isNotEmpty
                    ? controller.aiInsight.value
                    : 'Analyzing your spending patterns...',
                style: TextStyle(
                  color: HomeColors.white70,
                  fontSize: 12.sp,
                  height: 1.4,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => controller.aiInsight.value.isNotEmpty
                  ? GestureDetector(
                      onTap: () => controller.fetchAiInsight(),
                      child: Text(
                        'Refresh',
                        style: TextStyle(
                          color: HomeColors.purple,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
