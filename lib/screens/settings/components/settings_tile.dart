import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  const SettingsTile({super.key, required this.text, required this.icon, required this.onPressed});
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(5.sp),
        height: 70.h,
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.all(
            Radius.circular(20.r),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
                      color: AppColors.fontWhite,
                    ),
                  ),
                ],
              ),
              Icon(
              icon,
                color: AppColors.fontWhite,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
