import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/services/goal_service.dart';
import 'package:expense_mate_flutter/screens/goals/create_goals_screen.dart';
import 'home_colors.dart';

// ─── Goals Preview Component ───────────────────────────────────────────────────
class GoalsPreview extends StatelessWidget {
  const GoalsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: StreamBuilder<List<SavingsGoal>>(
        stream: SavingsGoalService().watchGoals(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const GoalsShimmer();
          }

          final goals = (snap.data ?? [])
              .where((g) => !g.isCompleted)
              .take(2)
              .toList();

          if (goals.isEmpty) {
            return const GoalsEmptyCard();
          }

          return Column(
            children: goals
                .map(
                  (g) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: GoalPreviewTile(goal: g),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

// ─── Goal Preview Tile ───────────────────────────────────────────────────────
class GoalPreviewTile extends StatefulWidget {
  final SavingsGoal goal;
  const GoalPreviewTile({super.key, required this.goal});

  @override
  State<GoalPreviewTile> createState() => GoalPreviewTileState();
}

class GoalPreviewTileState extends State<GoalPreviewTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

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

  Color get _barColor => widget.goal.progress >= 1.0 ? HomeColors.success : HomeColors.accent;

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final pct = (goal.progress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () => Get.to(() => const SavingsGoalsScreen()),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: HomeColors.white10,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: goal.progress >= 1.0
                ? HomeColors.success.withOpacity(0.25)
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
                      painter: MiniArcPainter(
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
                            color: HomeColors.textPrimary,
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
                        backgroundColor: HomeColors.white10,
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
                          color: HomeColors.white30,
                          fontSize: 11.sp,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'of RM ${goal.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: HomeColors.white30,
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
              color: HomeColors.white20,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mini Arc Painter ─────────────────────────────────────────────────────────
class MiniArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  MiniArcPainter({required this.progress, required this.color});

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
        ..color = HomeColors.white10
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
  bool shouldRepaint(MiniArcPainter old) => old.progress != progress;
}

// ─── Goals Empty Card ─────────────────────────────────────────────────────────
class GoalsEmptyCard extends StatelessWidget {
  const GoalsEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const SavingsGoalsScreen()),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: HomeColors.white10,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: HomeColors.accent.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: HomeColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.savings_outlined, color: HomeColors.accent, size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active goals',
                    style: TextStyle(
                      color: HomeColors.white70,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Create a goal and start saving',
                    style: TextStyle(
                      color: HomeColors.white30,
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
              icon: Icon(Icons.add_circle_outline_rounded, color: HomeColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Goals Shimmer ───────────────────────────────────────────────────────────
class GoalsShimmer extends StatefulWidget {
  const GoalsShimmer({super.key});

  @override
  State<GoalsShimmer> createState() => GoalsShimmerState();
}

class GoalsShimmerState extends State<GoalsShimmer>
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

// ─── Placeholder Savings Goals Screen ───────────────────────────────────────────
class SavingsGoalsScreen {
  const SavingsGoalsScreen();
}
