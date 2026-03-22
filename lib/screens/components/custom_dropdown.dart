import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/constatnts/colors.dart';

class CustomDropdown extends StatefulWidget {
  final Function(String, IconData) onCategorySelected;

  const CustomDropdown({super.key, required this.onCategorySelected});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final List<String> categories = [
    "Food & Groceries",
    "Transport",
    "Rent",
    "Utilities",
    "Entertainment",
    "Healthcare",
    "Shopping",
    "Education",
    "Savings",
    "Miscellaneous",
  ];

  String selectedCategory = "Food & Groceries";

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Food & Groceries":
        return Icons.fastfood;
      case "Transport":
        return Icons.directions_car;
      case "Rent":
        return Icons.home;
      case "Utilities":
        return Icons.electric_bolt;
      case "Entertainment":
        return Icons.movie;
      case "Healthcare":
        return Icons.local_hospital;
      case "Shopping":
        return Icons.shopping_bag;
      case "Education":
        return Icons.school;
      case "Savings":
        return Icons.savings;
      case "Miscellaneous":
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade500, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryColor,
          ),
          isExpanded: true,
          dropdownColor: AppColors.accentColor,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(color: AppColors.fontWhite, fontSize: 16),
          onChanged: (value) {
            setState(() {
              selectedCategory = value!;
            });
            widget.onCategorySelected(value!, _getCategoryIcon(value));
          },
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: AppColors.secondaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(category),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
