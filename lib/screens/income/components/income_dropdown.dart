import 'package:flutter/material.dart';
import 'package:expense_mate_flutter/constatnts/colors.dart';

class IncomeDropdown extends StatefulWidget {
  final Function(String, IconData) onCategorySelected;

  const IncomeDropdown({super.key, required this.onCategorySelected});

  @override
  _IncomeDropdownState createState() => _IncomeDropdownState();
}

class _IncomeDropdownState extends State<IncomeDropdown> {
  final List<String> categories = [
    "Salary",
    "Investment",
    "Rewards",
    "Gifts",
    "Business",
    "Miscellaneous",
  ];

  String selectedCategory = "Salary";

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Salary":
        return Icons.paid;
      case "Investment":
        return Icons.trending_up;
      case "Rewards":
        return Icons.leaderboard;
      case "Gifts":
        return Icons.card_giftcard_rounded;
      case "Business":
        return Icons.incomplete_circle;
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