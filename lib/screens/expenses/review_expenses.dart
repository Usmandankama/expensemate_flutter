import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/components/actionButton.dart';
// Note: Make sure to import your ExpenseController
import 'package:expense_mate_flutter/controllers/expense_controller.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReviewExpensesScreen extends StatefulWidget {
  final List<dynamic> scannedItems;

  const ReviewExpensesScreen({super.key, required this.scannedItems});

  @override
  State<ReviewExpensesScreen> createState() => _ReviewExpensesScreenState();
}

class _ReviewExpensesScreenState extends State<ReviewExpensesScreen> {
  // Inject your Expense Controller (assuming it follows your Income pattern)
  final ExpenseController expenseController = Get.find<ExpenseController>();
  
  late List<dynamic> _items;

  @override
  void initState() {
    super.initState();
    // Clone the list so we can delete items locally before saving
    _items = List.from(widget.scannedItems);
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    Get.snackbar(
      "Item Removed", 
      "Swipe to delete successful.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: AppColors.fontWhite,
      duration: const Duration(seconds: 1),
    );
  }

  void _saveAllExpenses() {
    if (_items.isEmpty) {
      Get.snackbar("Error", "No items to save.");
      return;
    }

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Loop through the AI items and save them to your database
    for (var item in _items) {
      double? amount = double.tryParse(item['amount'].toString());
      String name = item['name'] ?? 'Unknown Item';
      String category = item['category'] ?? 'Other';

      if (amount != null && amount > 0) {
        expenseController.addExpense(
          name: name,
          amount: amount,
          date: todayDate,
          description: "Scanned via AI",
          category: category,
          iconPath: _getCategoryIcon(category), 
        );
      }
    }

    Get.snackbar(
      "Success", 
      "${_items.length} expenses saved successfully!",
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: AppColors.fontWhite,
    );

    // Pop back to the Dashboard (closes the review and scanner screens)
    Get.until((route) => route.isFirst); 
  }

  // Helper to map AI text categories to your UI icons
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.fastfood;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'bills': return Icons.receipt;
      case 'utilities': return Icons.bolt;
      case 'entertainment': return Icons.movie;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = _items.fold(0, (sum, item) {
      return sum + (double.tryParse(item['amount'].toString()) ?? 0.0);
    });

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: Text(
          'Review Scan',
          style: TextStyle(
            color: AppColors.fontWhite,
            fontSize: 20.sp,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.fontWhite,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            
            // Total Summary Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                children: [
                  Text(
                    "Total Detected Amount", 
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontFamily: 'Montserrat'),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "\$${totalAmount.toStringAsFixed(2)}", 
                    style: TextStyle(color: AppColors.fontWhite, fontSize: 32.sp, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // The Scrollable List of Items
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        "No items left.", 
                        style: TextStyle(color: Colors.white54, fontSize: 16.sp, fontFamily: 'Montserrat'),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final name = item['name'] ?? 'Item';
                        final category = item['category'] ?? 'Other';
                        final amount = item['amount']?.toString() ?? '0.00';

                        // Swipe-to-delete wrapper
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => _removeItem(index),
                          background: Container(
                            margin: EdgeInsets.only(bottom: 15.h),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.w),
                            child: Icon(Icons.delete, color: AppColors.fontWhite, size: 28.sp),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 15.h),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor,
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryColor.withOpacity(0.5),
                                radius: 22.r,
                                child: Icon(_getCategoryIcon(category), color: AppColors.fontWhite, size: 20.sp),
                              ),
                              title: Text(
                                name, 
                                style: TextStyle(color: AppColors.fontWhite, fontSize: 16.sp, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                category, 
                                style: TextStyle(color: Colors.white60, fontSize: 12.sp, fontFamily: 'Montserrat'),
                              ),
                              trailing: Text(
                                "\$$amount", 
                                style: TextStyle(color: Colors.greenAccent, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Confirm Button mapped to your exact custom widget
            SizedBox(height: 10.h),
            ActionButton(
              title: 'Confirm & Save (${_items.length})', 
              onPressed: _items.isEmpty ? () {} : _saveAllExpenses,
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}