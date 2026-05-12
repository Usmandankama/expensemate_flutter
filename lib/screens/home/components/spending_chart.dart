import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_colors.dart';

// ─── Spending Chart Component ───────────────────────────────────────────────────
class SpendingChart extends StatelessWidget {
  const SpendingChart({super.key});

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
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spending trend',
                  style: TextStyle(
                    color: HomeColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                PeriodToggle(controller: controller),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Chart
            SizedBox(
              height: 180.h,
              child: Obx(() => LineChart(
                LineChartData(
                  minY: controller.chartMinValue.value,
                  maxY: controller.chartMaxValue.value,
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.weeklySpending
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: HomeColors.accent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: HomeColors.accent.withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: controller.chartRange.value / 4,
                        getTitlesWidget: (val, _) => Text(
                          'RM${val.toInt()}',
                          style: TextStyle(
                            color: HomeColors.white30,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          const days = [
                            'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                          ];
                          final i = val.toInt();
                          if (i < 0 || i >= days.length) return const SizedBox();
                          return Text(
                            days[i],
                            style: TextStyle(
                              color: HomeColors.white30,
                              fontSize: 9.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: controller.chartRange.value / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: HomeColors.white10,
                      strokeWidth: 1,
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF1E3A5F),
                      getTooltipItems: (spots) => spots
                          .map(
                            (s) => LineTooltipItem(
                              'RM ${s.y.toStringAsFixed(0)}',
                              TextStyle(
                                color: HomeColors.textPrimary,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Period Toggle Widget ─────────────────────────────────────────────────────
class PeriodToggle extends StatelessWidget {
  final HomeController controller;
  
  const PeriodToggle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: SpendingPeriod.values.map((p) {
          final label = p == SpendingPeriod.week ? '7D' : '30D';
          final isActive = controller.selectedPeriod.value == p;
          return GestureDetector(
            onTap: () => controller.setPeriod(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.only(left: 5.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isActive ? HomeColors.accent : HomeColors.white10,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? HomeColors.textPrimary : HomeColors.white30,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
