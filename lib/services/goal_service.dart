import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class SavingsGoal {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  final double savedAmount;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isCompleted;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
  });

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => (targetAmount - savedAmount).clamp(0.0, double.infinity);
  bool get isOverDeadline =>
      deadline != null && DateTime.now().isAfter(deadline!) && !isCompleted;

  factory SavingsGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsGoal(
      id: doc.id,
      name: data['name'] ?? '',
      emoji: data['emoji'] ?? '🎯',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      savedAmount: (data['savedAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'emoji': emoji,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'createdAt': Timestamp.fromDate(createdAt),
        'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
        'isCompleted': isCompleted,
      };
}

// ─── Contribution Model ───────────────────────────────────────────────────────

class GoalContribution {
  final String id;
  final double amount;
  final String? note;
  final DateTime date;

  GoalContribution({
    required this.id,
    required this.amount,
    this.note,
    required this.date,
  });

  factory GoalContribution.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalContribution(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      note: data['note'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'amount': amount,
        'note': note,
        'date': Timestamp.fromDate(date),
      };
}

// ─── AI Prediction Model ──────────────────────────────────────────────────────

class GoalPrediction {
  final double avgMonthlySavings;
  final DateTime? estimatedCompletion;
  final double? requiredMonthlySavings; // if deadline is set
  final bool isOnTrack;
  final String insight;
  final double monthsBehind; // 0 if on track

  GoalPrediction({
    required this.avgMonthlySavings,
    this.estimatedCompletion,
    this.requiredMonthlySavings,
    required this.isOnTrack,
    required this.insight,
    this.monthsBehind = 0,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────

class SavingsGoalService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _goalsRef =>
      _db.collection('users').doc(_uid).collection('savingsGoals');

  CollectionReference _contributionsRef(String goalId) =>
      _goalsRef.doc(goalId).collection('contributions');

  // ── CRUD ────────────────────────────────────────────────────────────────────

  Stream<List<SavingsGoal>> watchGoals() {
    return _goalsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SavingsGoal.fromFirestore(d)).toList());
  }

  Future<String> createGoal({
    required String name,
    required String emoji,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    final doc = await _goalsRef.add(SavingsGoal(
      id: '',
      name: name,
      emoji: emoji,
      targetAmount: targetAmount,
      savedAmount: 0,
      createdAt: DateTime.now(),
      deadline: deadline,
    ).toFirestore());
    return doc.id;
  }

  Future<void> addContribution({
    required String goalId,
    required double amount,
    String? note,
  }) async {
    final batch = _db.batch();

    // Add contribution record
    final contribRef = _contributionsRef(goalId).doc();
    batch.set(
        contribRef,
        GoalContribution(
          id: '',
          amount: amount,
          note: note,
          date: DateTime.now(),
        ).toFirestore());

    // Update goal savedAmount
    final goalRef = _goalsRef.doc(goalId);
    batch.update(goalRef, {
      'savedAmount': FieldValue.increment(amount),
    });

    await batch.commit();

    // Check if completed
    final goalSnap = await goalRef.get();
    final goal = SavingsGoal.fromFirestore(goalSnap);
    if (goal.savedAmount >= goal.targetAmount) {
      await goalRef.update({'isCompleted': true});
    }
  }

  Future<void> deleteGoal(String goalId) async {
    await _goalsRef.doc(goalId).delete();
  }

  // ── AI Prediction ────────────────────────────────────────────────────────────

  /// Pulls transaction history from Firebase to calculate avg monthly savings,
  /// then predicts completion based on the goal's remaining amount.
  Future<GoalPrediction> getPrediction(SavingsGoal goal) async {
    // Get last 3 months of transactions
    final threeMonthsAgo =
        DateTime.now().subtract(const Duration(days: 90));

    final txSnap = await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .where('date', isGreaterThan: Timestamp.fromDate(threeMonthsAgo))
        .get();

    double totalIncome = 0;
    double totalExpenses = 0;

    for (final doc in txSnap.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final type = data['type'] ?? '';

      if (type == 'income') {
        totalIncome += amount;
      } else {
        totalExpenses += amount;
      }
    }

    // Average monthly net savings over the period
    final monthsCovered = (txSnap.docs.isEmpty) ? 1.0 : 3.0;
    final avgMonthlySavings =
        ((totalIncome - totalExpenses) / monthsCovered).clamp(0.0, double.infinity);

    final remaining = goal.remaining;

    // No savings history — can't predict
    if (avgMonthlySavings <= 0) {
      return GoalPrediction(
        avgMonthlySavings: 0,
        isOnTrack: false,
        insight:
            "Start adding income entries so we can predict your savings timeline.",
        monthsBehind: 0,
      );
    }

    // Estimated months to completion at current rate
    final monthsNeeded = remaining / avgMonthlySavings;
    final estimatedCompletion = DateTime.now()
        .add(Duration(days: (monthsNeeded * 30).round()));

    // If there's a deadline, calculate required monthly savings
    double? requiredMonthly;
    bool isOnTrack = true;
    double monthsBehind = 0;
    String insight;

    if (goal.deadline != null) {
      final daysLeft = goal.deadline!.difference(DateTime.now()).inDays;
      final monthsLeft = daysLeft / 30;

      if (monthsLeft <= 0) {
        isOnTrack = false;
        insight = "⚠️ Deadline has passed. Consider extending it.";
      } else {
        requiredMonthly = remaining / monthsLeft;
        isOnTrack = avgMonthlySavings >= requiredMonthly;

        if (isOnTrack) {
          insight =
              "✅ You're on track! At your current rate you'll hit this goal ${_formatDate(estimatedCompletion)}.";
        } else {
          monthsBehind = monthsNeeded - monthsLeft;
          final shortfall = requiredMonthly - avgMonthlySavings;
          insight =
              "⚠️ You're RM ${shortfall.toStringAsFixed(0)} short per month. Save RM ${requiredMonthly.toStringAsFixed(0)}/month to hit your deadline.";
        }
      }
    } else {
      // No deadline — just show estimated completion
      insight =
          "📅 At your current savings rate you'll reach this goal ${_formatDate(estimatedCompletion)}.";
    }

    return GoalPrediction(
      avgMonthlySavings: avgMonthlySavings,
      estimatedCompletion: estimatedCompletion,
      requiredMonthlySavings: requiredMonthly,
      isOnTrack: isOnTrack,
      insight: insight,
      monthsBehind: monthsBehind,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'by ${months[date.month - 1]} ${date.year}';
  }
}