import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/controllers/expense_controller.dart';
import 'package:expense_mate_flutter/screens/components/custom_datepicker.dart';
import 'package:expense_mate_flutter/screens/components/custom_dropdown.dart';
import 'package:expense_mate_flutter/screens/components/custom_txtfield_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseController expenseController = Get.find<ExpenseController>();

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedCategory = '';
  IconData? selectedCategoryIcon; // Store category icon
  bool isLoading = false;

  void addExpense() async {
    setState(() {
      isLoading = true;
    });

    await expenseController.addExpense(
      name: nameController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
      description: descriptionController.text.trim(),
      category: selectedCategory,
      iconPath: selectedCategoryIcon, // Store the icon's Unicode codePoint
    );

    nameController.clear();
    amountController.clear();
    descriptionController.clear();
    setState(() {
      selectedCategory = '';
      selectedCategoryIcon = null;
      selectedDate = DateTime.now();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add expense',
          style: TextStyle(color: AppColors.fontWhite, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.fontWhite,
      ),
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            CustomDropdown(
              onCategorySelected: (String category, IconData icon) {
                setState(() {
                  selectedCategory = category;
                  selectedCategoryIcon = icon;
                });
              },
            ),
            SizedBox(height: 20.h),
            CustomTxtfield2(controller: nameController, name: 'Name', icon: Icons.insert_emoticon_rounded,),
            SizedBox(height: 30.h),
            CustomTxtfield2(controller: amountController, name: 'Amount', icon: Icons.paid,),
            SizedBox(height: 30.h),
            CustomTxtfield2(
              icon: Icons.description_outlined,
              controller: descriptionController,
              name: 'Description',
            ),
            SizedBox(height: 30.h),
            CustomDatepicker(
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),
            SizedBox(height: 100.h),
            ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  ContinuousRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.r)),
                  ),
                ),
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.secondaryColor,
                ),
              ),
              onPressed: isLoading ? null : addExpense,
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                        width: 180.w,
                        height: 60.h,
                        child: Center(
                          child: Text(
                            'Add Expense',
                            style: TextStyle(
                              color: AppColors.fontWhite,
                              fontFamily: 'montserrat',
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
