import 'package:expense_mate_flutter/controllers/expense_controller.dart';
import 'package:expense_mate_flutter/controllers/income_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

// Filter options for the pill bar
enum TransactionFilter { all, expenses, income }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ExpenseController expenseController = Get.put(ExpenseController());
  final IncomeController incomeController = Get.put(IncomeController());

  DateTime _selectedDate = DateTime.now();
  TransactionFilter _filter = TransactionFilter.all;

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  String _friendlyDate(DateTime date) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  /// Returns true if there is any transaction on [day]
  bool _hasTransactions(DateTime day) {
    final key = _formatDate(day);
    final hasExpense = expenseController.expenses.any((e) => e['date'] == key);
    final hasIncome = incomeController.incomeList.any((i) => i['date'] == key);
    return hasExpense || hasIncome;
  }

  @override
  void initState() {
    super.initState();
    expenseController.fetchExpenses();
    incomeController.fetchIncome();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2D),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCalendar(),
            _buildFilterPills(),
            Expanded(
              child: Obx(() {
                if (expenseController.isLoading.value ||
                    incomeController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  );
                }

                final key = _formatDate(_selectedDate);

                final expenses = expenseController.expenses
                    .where((e) => e['date'] == key)
                    .toList();

                final incomes = incomeController.incomeList
                    .where((i) => i['date'] == key)
                    .toList();

                // Apply filter
                final showExpenses = _filter != TransactionFilter.income;
                final showIncomes = _filter != TransactionFilter.expenses;

                final filteredExpenses = showExpenses ? expenses : [];
                final filteredIncomes = showIncomes ? incomes : [];

                final totalExpenses = expenses.fold<double>(
                    0, (sum, e) => sum + (e['amount'] as num).toDouble());
                final totalIncome = incomes.fold<double>(
                    0, (sum, i) => sum + (i['amount'] as num).toDouble());
                final net = totalIncome - totalExpenses;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryBar(totalIncome, totalExpenses, net),
                    _buildSectionLabel(
                      filteredExpenses.length + filteredIncomes.length,
                    ),
                    Expanded(
                      child: (filteredExpenses.isEmpty && filteredIncomes.isEmpty)
                          ? _buildEmptyState()
                          : ListView(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                              children: [
                                ...filteredExpenses.map((e) => _TransactionCard(
                                      name: e['name'] ?? '',
                                      category: e['category'] ?? 'Expense',
                                      amount: (e['amount'] as num).toDouble(),
                                      icon: e['icon'] as IconData,
                                      time: e['time'] ?? '',
                                      isExpense: true,
                                    )),
                                ...filteredIncomes.map((i) => _TransactionCard(
                                      name: i['name'] ?? '',
                                      category: i['category'] ?? 'Income',
                                      amount: (i['amount'] as num).toDouble(),
                                      icon: i['icon'] as IconData,
                                      time: i['time'] ?? '',
                                      isExpense: false,
                                    )),
                              ],
                            ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                _friendlyDate(_selectedDate),
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13.sp,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          // Avatar / profile button
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'AM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Obx(() {
      // Rebuild calendar when data loads so dots appear
      expenseController.expenses.length;
      incomeController.incomeList.length;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: TableCalendar(
          currentDay: DateTime.now(),
          focusedDay: _selectedDate,
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: CalendarFormat.week,
          availableGestures: AvailableGestures.horizontalSwipe,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selectedDay, _) {
            setState(() => _selectedDate = selectedDay);
          },

          // Show dot on days that have transactions
          eventLoader: (day) => _hasTransactions(day) ? [true] : [],

          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon:
                const Icon(Icons.chevron_left, color: Colors.white60),
            rightChevronIcon:
                const Icon(Icons.chevron_right, color: Colors.white60),
            headerPadding: EdgeInsets.symmetric(vertical: 8.h),
          ),

          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.white38,
              fontSize: 11.sp,
              fontFamily: 'Poppins',
            ),
            weekendStyle: TextStyle(
              color: Colors.white38,
              fontSize: 11.sp,
              fontFamily: 'Poppins',
            ),
          ),

          calendarStyle: CalendarStyle(
            // Default day
            defaultTextStyle: TextStyle(
              color: Colors.white70,
              fontSize: 13.sp,
              fontFamily: 'Poppins',
            ),
            // Weekend
            weekendTextStyle: TextStyle(
              color: Colors.white70,
              fontSize: 13.sp,
              fontFamily: 'Poppins',
            ),
            // Outside days (previous/next month)
            outsideTextStyle: TextStyle(
              color: Colors.white24,
              fontSize: 13.sp,
              fontFamily: 'Poppins',
            ),
            // Today
            todayTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            todayDecoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            // Selected
            selectedTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            selectedDecoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            // Activity dot
            markerDecoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            markerSize: 4.r,
            markersMaxCount: 1,
            cellMargin: EdgeInsets.all(4.r),
          ),
        ),
      );
    });
  }

  Widget _buildFilterPills() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TransactionFilter.values.map((f) {
            final labels = {
              TransactionFilter.all: 'All',
              TransactionFilter.expenses: 'Expenses',
              TransactionFilter.income: 'Income',
            };
            final isActive = _filter == f;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF3B82F6)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  labels[f]!,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white54,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(
      double totalIncome, double totalExpenses, double net) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _SummaryItem(
              label: 'Income',
              value: '+RM ${totalIncome.toStringAsFixed(2)}',
              valueColor: const Color(0xFF34D399),
            ),
            VerticalDivider(
              color: Colors.white.withOpacity(0.12),
              thickness: 1,
              width: 1,
            ),
            _SummaryItem(
              label: 'Expenses',
              value: '-RM ${totalExpenses.toStringAsFixed(2)}',
              valueColor: const Color(0xFFF87171),
            ),
            VerticalDivider(
              color: Colors.white.withOpacity(0.12),
              thickness: 1,
              width: 1,
            ),
            _SummaryItem(
              label: 'Net',
              value: 'RM ${net.toStringAsFixed(2)}',
              valueColor: net >= 0 ? Colors.white : const Color(0xFFF87171),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 10.h),
      child: Text(
        '${_friendlyDate(_selectedDate)} · $count transaction${count == 1 ? '' : 's'}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48.r, color: Colors.white24),
          SizedBox(height: 12.h),
          Text(
            'No transactions recorded\nfor this day',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white30,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Item ─────────────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Transaction Card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final String name;
  final String category;
  final double amount;
  final IconData icon;
  final String time;
  final bool isExpense;

  const _TransactionCard({
    required this.name,
    required this.category,
    required this.amount,
    required this.icon,
    required this.time,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        isExpense ? const Color(0xFFF87171) : const Color(0xFF34D399);
    final Color iconBg = isExpense
        ? const Color(0xFFF87171).withOpacity(0.18)
        : const Color(0xFF34D399).withOpacity(0.18);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(icon, color: accentColor, size: 20.r),
          ),
          SizedBox(width: 12.w),

          // Name & category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // Amount & time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'} RM ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              if (time.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 11.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}