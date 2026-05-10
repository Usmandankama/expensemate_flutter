import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SpendingPeriod { week, month }

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Core observables ────────────────────────────────────────────────────────

  final RxString userName = ''.obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxBool isLoading = false.obs;

  // ── Chart ───────────────────────────────────────────────────────────────────

  final RxList<double> weeklySpending = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  final Rx<SpendingPeriod> selectedPeriod = SpendingPeriod.week.obs;

  // ── Category breakdown ──────────────────────────────────────────────────────

  final RxList<Map<String, dynamic>> categoryBreakdown =
      <Map<String, dynamic>>[].obs;

  // ── AI Insight ──────────────────────────────────────────────────────────────

  final RxString aiInsight = ''.obs;
  final RxBool isInsightLoading = false.obs;

  // ── Recent transactions ─────────────────────────────────────────────────────

  final RxList<Map<String, dynamic>> recentTransactions =
      <Map<String, dynamic>>[].obs;

  // ── Internal cache (so period toggle doesn't re-fetch Firebase) ─────────────

  List<Map<String, dynamic>> _cachedExpenses = [];

  // ── Category colour + icon map ──────────────────────────────────────────────
  // Keys are lowercase — must match whatever category strings Gemini writes.

  static const Map<String, Color> _categoryColors = {
    'food': Color(0xFFF87171),
    'transport': Color(0xFF3B82F6),
    'entertainment': Color(0xFFA78BFA),
    'health': Color(0xFFFBBF24),
    'shopping': Color(0xFFF472B6),
    'utilities': Color(0xFF34D399),
    'education': Color(0xFF60A5FA),
    'other': Color(0xFF94A3B8),
  };

  static const Map<String, IconData> _categoryIcons = {
    'food': Icons.restaurant_outlined,
    'transport': Icons.local_gas_station_outlined,
    'entertainment': Icons.sports_esports_outlined,
    'health': Icons.local_pharmacy_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'utilities': Icons.bolt_outlined,
    'education': Icons.school_outlined,
    'other': Icons.category_outlined,
  };

  Color _colorFor(String cat) =>
      _categoryColors[cat.toLowerCase()] ?? const Color(0xFF94A3B8);

  IconData _iconFor(String cat) =>
      _categoryIcons[cat.toLowerCase()] ?? Icons.category_outlined;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_fetchUserName(), _fetchFinancials()]);
    fetchAiInsight();
  }

  Future<void> refreshData() => _loadAll();

  // ── Period toggle ───────────────────────────────────────────────────────────

  void setPeriod(SpendingPeriod period) {
    selectedPeriod.value = period;
    _buildSpendingChart(); // uses cache — no Firebase call
  }

  // ── User name ───────────────────────────────────────────────────────────────

  Future<void> _fetchUserName() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();

      // Adjust 'name' / 'displayName' to match your Firestore user document field
      userName.value =
          (data?['name'] ??
                  data?['displayName'] ??
                  _auth.currentUser?.displayName ??
                  'there')
              as String;
    } catch (_) {
      userName.value = _auth.currentUser?.displayName ?? 'there';
    }
  }

  // ── Main financial fetch ────────────────────────────────────────────────────

  Future<void> _fetchFinancials() async {
    try {
      isLoading(true);
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not logged in';

      // Fetch expenses and incomes in parallel — same path pattern as your
      // ExpenseController and IncomeController
      final results = await Future.wait([
        _firestore
            .collection('users')
            .doc(uid)
            .collection('expenses')
            .orderBy('createdAt', descending: true)
            .get(),
        _firestore
            .collection('users')
            .doc(uid)
            .collection('income')
            .orderBy('createdAt', descending: true)
            .get(),
      ]);

      final expenseSnap = results[0];
      final incomeSnap = results[1];

      // ── Parse expenses ────────────────────────────────────────────────────

      final expenses = expenseSnap.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        data['isExpense'] = true;
        // Reconstruct IconData the same way your ExpenseController does
        data['icon'] = data['iconPath'] != null
            ? IconData(int.parse(data['iconPath']), fontFamily: 'MaterialIcons')
            : _iconFor(data['category'] ?? '');
        return data;
      }).toList();

      // ── Parse incomes ─────────────────────────────────────────────────────

      final incomes = incomeSnap.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        data['isExpense'] = false;
        data['icon'] = data['iconPath'] != null
            ? IconData(int.parse(data['iconPath']), fontFamily: 'MaterialIcons')
            : Icons.account_balance_wallet_outlined;
        return data;
      }).toList();

      // ── Totals ────────────────────────────────────────────────────────────

      final spent = expenses.fold<double>(
        0,
        (sum, e) => sum + (e['amount'] as num).toDouble(),
      );
      final income = incomes.fold<double>(
        0,
        (sum, i) => sum + (i['amount'] as num).toDouble(),
      );

      totalSpent.value = spent;
      totalIncome.value = income;
      totalBalance.value = income - spent;

      // ── Derived data ──────────────────────────────────────────────────────

      _cachedExpenses = expenses;
      _buildCategoryBreakdown(expenses);
      _buildSpendingChart();
      _buildRecentTransactions(expenses, incomes);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading(false);
    }
  }

  // ── Category breakdown ──────────────────────────────────────────────────────

  void _buildCategoryBreakdown(List<Map<String, dynamic>> expenses) {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      final cat = (e['category'] as String? ?? 'other').toLowerCase();
      totals[cat] = (totals[cat] ?? 0) + (e['amount'] as num).toDouble();
    }

    if (totals.isEmpty) {
      categoryBreakdown.value = [];
      return;
    }

    final grandTotal = totals.values.fold<double>(0, (a, b) => a + b);

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    categoryBreakdown.value = sorted.take(4).map((entry) {
      final label = entry.key[0].toUpperCase() + entry.key.substring(1);
      return <String, dynamic>{
        'name': label,
        'icon': _iconFor(entry.key),
        'color': _colorFor(entry.key),
        'amount': entry.value,
        'percentage': (entry.value / grandTotal).clamp(0.0, 1.0),
      };
    }).toList();
  }

  // ── Spending chart ──────────────────────────────────────────────────────────

  void _buildSpendingChart() {
    final now = DateTime.now();
    final isWeek = selectedPeriod.value == SpendingPeriod.week;
    final bucketCount = isWeek ? 7 : 30;
    final buckets = List<double>.filled(bucketCount, 0);

    for (final e in _cachedExpenses) {
      final ts = e['createdAt'];
      if (ts == null) continue;
      final date = (ts as Timestamp).toDate();
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < bucketCount) {
        // Most recent day = last index
        buckets[bucketCount - 1 - diff] += (e['amount'] as num).toDouble();
      }
    }

    weeklySpending.value = buckets;
  }

  // ── Recent transactions ─────────────────────────────────────────────────────

  void _buildRecentTransactions(
    List<Map<String, dynamic>> expenses,
    List<Map<String, dynamic>> incomes,
  ) {
    final all = [...expenses, ...incomes];

    all.sort((a, b) {
      final aTs = a['createdAt'] as Timestamp?;
      final bTs = b['createdAt'] as Timestamp?;
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return bTs.compareTo(aTs);
    });

    recentTransactions.value = all.take(5).map((tx) {
      final ts = tx['createdAt'] as Timestamp?;
      return <String, dynamic>{
        'name': tx['name'] ?? '',
        'category':
            tx['category'] ?? (tx['isExpense'] == true ? 'Expense' : 'Income'),
        'date': ts != null ? _friendlyDate(ts.toDate()) : (tx['date'] ?? ''),
        'amount': (tx['amount'] as num).toDouble(),
        'icon': tx['icon'] as IconData,
        'isExpense': tx['isExpense'] as bool? ?? true,
      };
    }).toList();
  }

  // ── AI Insight ──────────────────────────────────────────────────────────────

  Future<void> fetchAiInsight() async {
    if (isInsightLoading.value) return;
    isInsightLoading.value = true;

    try {
      final topCategory = categoryBreakdown.isNotEmpty
          ? categoryBreakdown.first['name'] as String
          : 'general spending';

      final topAmount = categoryBreakdown.isNotEmpty
          ? (categoryBreakdown.first['amount'] as double).toStringAsFixed(0)
          : '0';

      final prompt =
          '''
You are a personal finance assistant. Analyse this user's spending data and 
give ONE concise, friendly insight (max 2 sentences). Mention specific numbers 
and one actionable tip. Do not use markdown or bullet points.

Data:
- Total spent this month: RM ${totalSpent.value.toStringAsFixed(2)}
- Total income this month: RM ${totalIncome.value.toStringAsFixed(2)}
- Net balance: RM ${totalBalance.value.toStringAsFixed(2)}
- Top spending category: $topCategory (RM $topAmount)
- Daily spending (oldest to today): ${weeklySpending.map((v) => v.toStringAsFixed(0)).join(', ')} RM
''';

      // TODO: swap the lines below for your real Gemini call:
      //   final result = await GeminiService.generate(prompt);
      //   aiInsight.value = result;
      debugPrint('[Gemini Prompt] $prompt');

      // Placeholder response until Gemini is wired in:
      await Future.delayed(const Duration(milliseconds: 800));
      aiInsight.value =
          'Your top spending category is $topCategory at RM $topAmount this month. '
          'Try setting a weekly limit to keep it under control.';
    } catch (e) {
      aiInsight.value = 'Could not load insight. Tap to retry.';
    } finally {
      isInsightLoading.value = false;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _friendlyDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
