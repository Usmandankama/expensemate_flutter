import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomDatepicker extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  CustomDatepicker({super.key, required this.onDateSelected});

  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate.value,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.fontWhite, // Main color
                    onPrimary: AppColors.fontBlack, // Text color on primary
                    onSurface: AppColors.secondaryColor, // Text color
                  ),
                  dialogTheme: DialogThemeData(
                    titleTextStyle: TextStyle(color: AppColors.fontWhite),
                    backgroundColor: AppColors.accentColor,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            selectedDate.value = pickedDate;
            onDateSelected(pickedDate); // Notify parent widget
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade500, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.yMMMd().format(selectedDate.value),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: AppColors.fontWhite),
              ),
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
