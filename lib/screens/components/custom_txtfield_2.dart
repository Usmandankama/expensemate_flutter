import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constatnts/colors.dart';

class CustomTxtfield2 extends StatelessWidget {
  final String name;
  final IconData icon;
  final TextEditingController controller;
  const CustomTxtfield2({
    super.key,
    required this.name,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.only(left: 10.0, top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.fontLight, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        style: TextStyle(color: AppColors.fontWhite),
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: Icon(icon, color: AppColors.secondaryColor),
          hintText: name,
          hintStyle: TextStyle(color: AppColors.fontLight),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
