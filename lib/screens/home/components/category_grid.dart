import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'home_colors.dart';

// ─── Category Grid Component ───────────────────────────────────────────────────
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: HomeColors.card,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By category',
              style: TextStyle(
                color: HomeColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final cats = controller.categoryBreakdown;
              if (cats.isEmpty) {
                return Center(
                  child: Text(
                    'No data yet',
                    style: TextStyle(
                      color: HomeColors.white30,
                      fontSize: 13.sp,
                    ),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 2.8,
                ),
                itemCount: cats.length,
                itemBuilder: (_, i) => CategoryTile(data: cats[i]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Category Tile Widget ─────────────────────────────────────────────────────
class CategoryTile extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const CategoryTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data['color'] as Color? ?? HomeColors.accent;
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeColors.white10,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(
              data['icon'] as IconData? ?? Icons.category,
              color: color,
              size: 16.r,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data['name'] as String? ?? 'Unknown',
                  style: TextStyle(
                    color: HomeColors.textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  'RM ${(data['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
