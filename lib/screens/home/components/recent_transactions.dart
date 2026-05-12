import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'home_colors.dart';

// ─── Recent Transactions Component ─────────────────────────────────────────────
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Obx(() {
      final items = controller.recentTransactions;
      if (items.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Text(
            'No recent transactions',
            style: TextStyle(
              color: HomeColors.white30,
              fontSize: 13.sp,
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: items
              .map(
                (tx) => TransactionTile(
                  name: tx['name'] ?? '',
                  category: tx['category'] ?? '',
                  date: tx['date'] ?? '',
                  amount: (tx['amount'] as num).toDouble(),
                  icon: tx['icon'] as IconData,
                  isExpense: tx['isExpense'] as bool? ?? true,
                ),
              )
              .toList(),
        ),
      );
    });
  }
}

// ─── Transaction Tile Widget ───────────────────────────────────────────────────
class TransactionTile extends StatelessWidget {
  final String name;
  final String category;
  final String date;
  final double amount;
  final IconData icon;
  final bool isExpense;

  const TransactionTile({
    super.key,
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? HomeColors.error : HomeColors.success;
    
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: HomeColors.white10,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, color: color, size: 16.r),
          ),
          SizedBox(width: 12.w),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: HomeColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '$date · $category',
                  style: TextStyle(
                    color: HomeColors.white30,
                    fontSize: 11.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'} RM ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
