import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/components/actionButton.dart';
import 'package:expense_mate_flutter/screens/components/custom_datepicker.dart';
import 'package:expense_mate_flutter/screens/components/custom_txtfield_2.dart';
import 'package:expense_mate_flutter/screens/income/components/income_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {

  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController decriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // Store selected date
  String selectedCategory = '';
  IconData? selectedCategoryIcon; // Store category icon

  void addIncome() {
    if (namecontroller.text.isEmpty ||
        amountController.text.isEmpty ||
        decriptionController.text.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    double? amount = double.tryParse(amountController.text);
    if (amount == null) {
      Get.snackbar("Error", "Please enter a valid amount");
      return;
    }

    // incomeController.addIncome(
    //   name: namecontroller.text.trim(),
    //   amount: amount,
    //   date: DateFormat('yyyy-MM-dd').format(selectedDate),
    //   description: decriptionController.text.trim(),
    //   category: selectedCategory,
    //   iconPath: selectedCategoryIcon, // Default icon, replace if necessary
    // );

    // Clear input fields after adding
    namecontroller.clear();
    amountController.clear();
    decriptionController.clear();

    Get.snackbar("Success", "Income added successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Add income',
          style: TextStyle(
            color: AppColors.fontWhite,
            fontSize: 20.sp,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.fontWhite,
      ),
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50.h),
            IncomeDropdown(
              onCategorySelected: (String category, IconData icon) {
                setState(() {
                  selectedCategory = category;
                  selectedCategoryIcon = icon;
                });
              },
            ),
            SizedBox(height: 20.h),
            CustomTxtfield2(name: 'Name', controller: namecontroller,icon: Icons.person,),
            SizedBox(height: 20.h),
            CustomTxtfield2(name: 'Amount', controller: amountController, icon: Icons.paid),
            SizedBox(height: 20.h),
            CustomDatepicker(
              onDateSelected: (DateTime selectedDate) {
                setState(() {
                  this.selectedDate =
                      selectedDate; // Update the selected date in the parent widget
                });
              },
            ),

            SizedBox(height: 20.h),
            CustomTxtfield2(
              icon: Icons.note,
              name: 'Description',
              controller: decriptionController,
            ),
            SizedBox(height: 100.h),
            ActionButton(title: 'Add Income', onPressed: addIncome),
          ],
        ),
      ),
    );
  }
}
