import 'dart:math' as math;
import 'package:expense_mate_flutter/screens/goals/create_goals_screen.dart';
import 'package:expense_mate_flutter/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';

import '../goals/saving_goals_screen.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  // ── Colour palette ──────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0F1B2D);
  static const _card = Color(0xFF1A2B40);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF34D399);
  static const _red = Color(0xFFF87171);
  static const _purple = Color(0xFFA78BFA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                _buildHeader(),
                SizedBox(height: 18.h),
                _buildBalanceCard(),
                SizedBox(height: 16.h),
                _buildActionRow(),
                SizedBox(height: 20.h),
                _buildSectionHeader(
                  'Spending trend',
                  trailing: _buildPeriodToggle(),
                ),
                _buildSpendingChart(),
                SizedBox(height: 20.h),
                _buildSectionHeader('By category', trailingText: 'See all'),
                _buildCategoryGrid(),
                SizedBox(height: 16.h),
                _buildAiInsightCard(),
                SizedBox(height: 20.h),
                _buildSectionHeader(
                  'Savings goals',
                  trailingText: 'View all',
                  onTrailingTap: () => Get.to(() => const SavingsGoalsScreen()),
                ),
                _buildSavingsGoalsPreview(),
                SizedBox(height: 20.h),
                _buildSectionHeader(
                  'Recent activity',
                  trailingText: 'View all',
                  onTrailingTap: () => Get.toNamed('/history'),
                ),
                _buildRecentTransactions(),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_blue, _purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Obx(
                  () => Text(
                    controller.userName.isNotEmpty
                        ? controller.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Obx(
                    () => Text(
                      controller.userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/notifications'),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 20.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Balance card ────────────────────────────────────────────────────────────

  Widget _buildBalanceCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: _blue.withOpacity(0.15),
          border: Border.all(color: _blue.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAL BALANCE',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 6.h),
            Obx(
              () => Text(
                'RM ${controller.totalBalance.value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
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
                  child: _BalancePill(
                    label: 'Income',
                    valueObs: controller.totalIncome,
                    color: _green,
                    prefix: '+',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _BalancePill(
                    label: 'Expenses',
                    valueObs: controller.totalSpent,
                    color: _red,
                    prefix: '-',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Action row ───────────────────────────────────────────────────────────────

  Widget _buildActionRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Add Expense',
              icon: Icons.credit_card_outlined,
              iconColor: _red,
              iconBg: _red.withOpacity(0.15),
              onTap: () => Get.toNamed('/expenses'),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => Get.toNamed('/scan-receipt'),
            child: Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 24.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _ActionButton(
              label: 'Add Income',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: _green,
              iconBg: _green.withOpacity(0.15),
              onTap: () => Get.toNamed('/income'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Spending chart ───────────────────────────────────────────────────────────

  Widget _buildSpendingChart() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 180.h,
        padding: EdgeInsets.fromLTRB(8.w, 16.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Obx(() {
          final spots = controller.weeklySpending
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList();

          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 100,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.white.withOpacity(0.06),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42.w,
                    interval: 100,
                    getTitlesWidget: (val, _) => Text(
                      'RM${val.toInt()}',
                      style: TextStyle(color: Colors.white30, fontSize: 9.sp),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, _) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      final i = val.toInt();
                      if (i < 0 || i >= days.length) return const SizedBox();
                      return Text(
                        days[i],
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 10.sp,
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
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: _blue,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) =>
                        FlDotCirclePainter(radius: 3, color: _blue),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _blue.withOpacity(0.08),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E3A5F),
                  getTooltipItems: (spots) => spots
                      .map(
                        (s) => LineTooltipItem(
                          'RM ${s.y.toStringAsFixed(0)}',
                          TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPeriodToggle() {
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
                color: isActive ? _blue : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white38,
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

  // ── Category grid ────────────────────────────────────────────────────────────

  Widget _buildCategoryGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final cats = controller.categoryBreakdown;
        if (cats.isEmpty) {
          return Center(
            child: Text(
              'No data yet',
              style: TextStyle(color: Colors.white30, fontSize: 13.sp),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.55,
          ),
          itemCount: cats.length > 4 ? 4 : cats.length,
          itemBuilder: (_, i) => _CategoryTile(data: cats[i]),
        );
      }),
    );
  }

  // ── AI Insight card ──────────────────────────────────────────────────────────

  Widget _buildAiInsightCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _purple.withOpacity(0.12),
          border: Border.all(color: _purple.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.auto_awesome, color: _purple, size: 16.r),
                ),
                SizedBox(width: 8.w),
                Text(
                  'AI Insight',
                  style: TextStyle(
                    color: _purple,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (controller.isInsightLoading.value) {
                return Row(
                  children: [
                    SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _purple,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Analysing your spending…',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                );
              }
              return Text(
                controller.aiInsight.value.isEmpty
                    ? 'Tap to generate your spending insight.'
                    : controller.aiInsight.value,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 13.sp,
                  height: 1.55,
                  fontFamily: 'Poppins',
                ),
              );
            }),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: controller.fetchAiInsight,
              child: Row(
                children: [
                  Icon(Icons.refresh, color: _purple, size: 14.r),
                  SizedBox(width: 4.w),
                  Text(
                    'Refresh insight',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Savings Goals Preview ────────────────────────────────────────────────────

  Widget _buildSavingsGoalsPreview() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: StreamBuilder<List<SavingsGoal>>(
        stream: SavingsGoalService().watchGoals(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _GoalsShimmer();
          }

          final goals = (snap.data ?? [])
              .where((g) => !g.isCompleted)
              .take(2)
              .toList();

          if (goals.isEmpty) {
            return _GoalsEmptyCard();
          }

          return Column(
            children: goals
                .map(
                  (g) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _GoalPreviewTile(goal: g),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  // ── Recent transactions ──────────────────────────────────────────────────────

  Widget _buildRecentTransactions() {
    return Obx(() {
      final items = controller.recentTransactions.take(5).toList();
      if (items.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Text(
            'No recent transactions',
            style: TextStyle(color: Colors.white30, fontSize: 13.sp),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: items
              .map(
                (tx) => _TransactionTile(
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

  // ── Section header ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    String title, {
    Widget? trailing,
    String? trailingText,
    VoidCallback? onTrailingTap,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          if (trailing != null) trailing,
          if (trailingText != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailingText,
                style: TextStyle(
                  color: _blue,
                  fontSize: 13.sp,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Utility ──────────────────────────────────────────────────────────────────

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Goals sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GoalPreviewTile extends StatefulWidget {
  final SavingsGoal goal;
  const _GoalPreviewTile({required this.goal});

  @override
  State<_GoalPreviewTile> createState() => _GoalPreviewTileState();
}

class _GoalPreviewTileState extends State<_GoalPreviewTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF34D399);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progress = Tween<double>(
      begin: 0,
      end: widget.goal.progress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _barColor => widget.goal.progress >= 1.0 ? _green : _blue;

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final pct = (goal.progress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () => Get.to(() => const SavingsGoalsScreen()),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: goal.progress >= 1.0
                ? _green.withOpacity(0.25)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Emoji + mini arc
            SizedBox(
              width: 46.w,
              height: 46.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => CustomPaint(
                      size: Size(46.w, 46.w),
                      painter: _MiniArcPainter(
                        progress: _progress.value,
                        color: _barColor,
                      ),
                    ),
                  ),
                  Text(goal.emoji, style: TextStyle(fontSize: 18.sp)),
                ],
              ),
            ),
            SizedBox(width: 12.w),

            // Name + bar + amounts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          color: _barColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(3.r),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 5,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation(_barColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RM ${goal.savedAmount.toStringAsFixed(0)} saved',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 11.sp,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'of RM ${goal.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 11.sp,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white24,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  _MiniArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (progress <= 0) return;

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniArcPainter old) => old.progress != progress;
}

class _GoalsEmptyCard extends StatelessWidget {
  static const _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const SavingsGoalsScreen()),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _blue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.savings_outlined, color: _blue, size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active goals',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Create a goal and start saving',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11.sp,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => const CreateGoalScreen());
              },
              icon: Icon(Icons.add_circle_outline_rounded, color: _blue),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsShimmer extends StatefulWidget {
  @override
  State<_GoalsShimmer> createState() => _GoalsShimmerState();
}

class _GoalsShimmerState extends State<_GoalsShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.04 + (_anim.value * 0.06);
        return Column(
          children: List.generate(
            2,
            (_) => Container(
              margin: EdgeInsets.only(bottom: 10.h),
              height: 72.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Existing sub-widgets (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _BalancePill extends StatelessWidget {
  final String label;
  final RxDouble valueObs;
  final Color color;
  final String prefix;

  const _BalancePill({
    required this.label,
    required this.valueObs,
    required this.color,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 3.h),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _ActionButton({
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
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: iconColor, size: 18.r),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
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

class _CategoryTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CategoryTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data['color'] as Color? ?? const Color(0xFF3B82F6);
    final pct = (data['percentage'] as double? ?? 0).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
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
                child: Text(
                  data['name'] as String? ?? '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'RM ${(data['amount'] as num? ?? 0).toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            '${(pct * 100).toStringAsFixed(0)}% of budget',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10.sp,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String name;
  final String category;
  final String date;
  final double amount;
  final IconData icon;
  final bool isExpense;

  const _TransactionTile({
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? const Color(0xFFF87171) : const Color(0xFF34D399);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
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
                    color: Colors.white30,
                    fontSize: 11.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}
