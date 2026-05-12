import 'dart:math' as math;
import 'package:expense_mate_flutter/screens/goals/create_goals_screen.dart';
import 'package:expense_mate_flutter/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/controllers/theme_controller.dart';

// ─── Color Palette (matches scanner page) ────────────────────────────────────
class _C {
  static Color get bg => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.background : 
    ThemeController.to.lightTheme.colorScheme.background;
  static Color get surface => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.surface : 
    ThemeController.to.lightTheme.colorScheme.surface;
  static Color get card => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.surface : 
    ThemeController.to.lightTheme.colorScheme.surface;
  static Color get border => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.outline : 
    ThemeController.to.lightTheme.colorScheme.outline;
  static Color get accent => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.primary : 
    ThemeController.to.lightTheme.colorScheme.primary;
  static Color get accentGlow => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.primary.withOpacity(0.2) : 
    ThemeController.to.lightTheme.colorScheme.primary.withOpacity(0.2);
  static Color get success => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.secondary : 
    ThemeController.to.lightTheme.colorScheme.secondary;
  static Color get successGlow => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.secondary.withOpacity(0.15) : 
    ThemeController.to.lightTheme.colorScheme.secondary.withOpacity(0.15);
  static Color get warning => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.error : 
    ThemeController.to.lightTheme.colorScheme.error;
  static Color get warningGlow => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.error.withOpacity(0.15) : 
    ThemeController.to.lightTheme.colorScheme.error.withOpacity(0.15);
  static Color get error => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.error : 
    ThemeController.to.lightTheme.colorScheme.error;
  static Color get textPrimary => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.onSurface : 
    ThemeController.to.lightTheme.colorScheme.onSurface;
  static Color get textSecondary => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.onSurface.withOpacity(0.7) : 
    ThemeController.to.lightTheme.colorScheme.onSurface.withOpacity(0.7);
  static Color get textMuted => ThemeController.to.isDarkMode ? 
    ThemeController.to.darkTheme.colorScheme.onSurface.withOpacity(0.4) : 
    ThemeController.to.lightTheme.colorScheme.onSurface.withOpacity(0.4);
}

// ─── Animated Progress Arc ────────────────────────────────────────────────────
class _ProgressArc extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final double size;

  const _ProgressArc({
    required this.progress,
    required this.color,
    this.size = 64,
  });

  @override
  State<_ProgressArc> createState() => _ProgressArcState();
}

class _ProgressArcState extends State<_ProgressArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.progress).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
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
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ArcPainter(
          progress: _anim.value,
          color: widget.color,
          trackColor: _C.border,
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _ArcPainter(
      {required this.progress,
      required this.color,
      required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    if (progress <= 0) return;

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep * progress,
      false,
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─── Goal Card ────────────────────────────────────────────────────────────────
class _GoalCard extends StatefulWidget {
  final SavingsGoal goal;
  final SavingsGoalService service;
  final int index;

  const _GoalCard({
    required this.goal,
    required this.service,
    required this.index,
  });

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  GoalPrediction? _prediction;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _entryCtrl.forward();
    });

    _loadPrediction();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrediction() async {
    final p = await widget.service.getPrediction(widget.goal);
    if (mounted) setState(() => _prediction = p);
  }

  Color get _accentColor {
    if (widget.goal.isCompleted) return _C.success;
    if (widget.goal.isOverDeadline) return _C.error;
    if (_prediction != null && !_prediction!.isOnTrack) return _C.warning;
    return _C.accent;
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final color = _accentColor;
    final pct = (goal.progress * 100).toStringAsFixed(0);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _expanded ? color.withOpacity(0.4) : _C.border,
              ),
              boxShadow: _expanded
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.12),
                        blurRadius: 20,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Progress Arc with emoji
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _ProgressArc(
                            progress: goal.progress,
                            color: color,
                            size: 64,
                          ),
                          Text(goal.emoji,
                              style: const TextStyle(fontSize: 22)),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Name + amounts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    goal.name,
                                    style:  TextStyle(
                                      color: _C.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                if (goal.isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _C.successGlow,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child:  Text("Done",
                                        style: TextStyle(
                                            color: _C.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "RM ${goal.savedAmount.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " / RM ${goal.targetAmount.toStringAsFixed(0)}",
                                    style:  TextStyle(
                                      color: _C.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Linear progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: goal.progress,
                                backgroundColor: _C.border,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$pct% saved",
                              style:  TextStyle(
                                color: _C.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _C.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                // Expanded section
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildExpandedSection(goal, color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedSection(SavingsGoal goal, Color color) {
    return Column(
      children: [
        Divider(color: _C.border, height: 1),

        // AI Prediction
        if (_prediction != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: _C.accent, size: 14),
                      SizedBox(width: 6),
                      Text(
                        "AI Prediction",
                        style: TextStyle(
                          color: _C.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _prediction!.insight,
                    style:  TextStyle(
                      color: _C.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  if (_prediction!.avgMonthlySavings > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatPill(
                          label: "Avg/month",
                          value:
                              "RM ${_prediction!.avgMonthlySavings.toStringAsFixed(0)}",
                          color: _C.accent,
                        ),
                        if (_prediction!.requiredMonthlySavings != null) ...[
                          const SizedBox(width: 8),
                          _StatPill(
                            label: "Need/month",
                            value:
                                "RM ${_prediction!.requiredMonthlySavings!.toStringAsFixed(0)}",
                            color: _prediction!.isOnTrack
                                ? _C.success
                                : _C.warning,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

        // Deadline chip
        if (goal.deadline != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Row(
              children: [
                Icon(Icons.flag_rounded,
                    color: goal.isOverDeadline ? _C.error : _C.textMuted,
                    size: 14),
                const SizedBox(width: 6),
                Text(
                  "Deadline: ${_formatDate(goal.deadline!)}",
                  style: TextStyle(
                    color:
                        goal.isOverDeadline ? _C.error : _C.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              if (!goal.isCompleted)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAddContribution(goal),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                color: _C.bg, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "Add Savings",
                              style: TextStyle(
                                color: _C.bg,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _confirmDelete(goal),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _C.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: _C.error.withOpacity(0.3)),
                  ),
                  child:  Icon(Icons.delete_outline_rounded,
                      color: _C.error, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddContribution(SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddContributionSheet(
        goal: goal,
        service: widget.service,
        onAdded: _loadPrediction,
      ),
    );
  }

  void _confirmDelete(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _C.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:  Text("Delete Goal",
            style: TextStyle(color: _C.textPrimary)),
        content: Text(
          "Delete '${goal.name}'? This cannot be undone.",
          style:  TextStyle(color: _C.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text("Cancel",
                style: TextStyle(color: _C.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.service.deleteGoal(goal.id);
            },
            child:  Text("Delete",
                style: TextStyle(color: _C.error)),
          ),
        ],
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

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Goals Screen ─────────────────────────────────────────────────────────────
class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen>
    with SingleTickerProviderStateMixin {
  final _service = SavingsGoalService();
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<List<SavingsGoal>>(
                stream: _service.watchGoals(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return  Center(
                      child: CircularProgressIndicator(
                        color: _C.accent,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  final goals = snap.data ?? [];

                  if (goals.isEmpty) return _buildEmptyState();

                  // Summary bar
                  final active =
                      goals.where((g) => !g.isCompleted).length;
                  final completed =
                      goals.where((g) => g.isCompleted).length;

                  return Column(
                    children: [
                      _buildSummaryBar(active, completed),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: goals.length,
                          itemBuilder: (_, i) => _GoalCard(
                            goal: goals[i],
                            service: _service,
                            index: i,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Padding(
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
                child:  Icon(Icons.arrow_back_ios_new_rounded,
                    color: _C.textSecondary, size: 16),
              ),
            ),
            const SizedBox(width: 16),
             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Savings Goals",
                  style: TextStyle(
                    color: _C.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  "Track what you're working towards",
                  style:
                      TextStyle(color: _C.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(int active, int completed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          _SummaryChip(
              label: "$active active",
              color: _C.accent,
              icon: Icons.track_changes_rounded),
          const SizedBox(width: 8),
          _SummaryChip(
              label: "$completed completed",
              color: _C.success,
              icon: Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _C.accentGlow,
              shape: BoxShape.circle,
            ),
            child:  Icon(Icons.savings_outlined,
                color: _C.accent, size: 36),
          ),
          const SizedBox(height: 20),
           Text(
            "No goals yet",
            style: TextStyle(
              color: _C.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
           Text(
            "Create your first savings goal\nand start tracking your progress",
            textAlign: TextAlign.center,
            style: TextStyle(color: _C.textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => Get.to(() => const CreateGoalScreen()),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient:  LinearGradient(
            colors: [_C.accent, Color(0xFF0099BB)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _C.accent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child:  Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: _C.bg, size: 20),
            SizedBox(width: 8),
            Text(
              "New Goal",
              style: TextStyle(
                color: _C.bg,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}