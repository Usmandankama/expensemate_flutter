import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButtonContainer extends StatelessWidget {
  final VoidCallback onpressed;
  final String title;
  final IconData icon;
  const ActionButtonContainer(
      {super.key,
      required this.onpressed,
      required this.title,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        height: 70.h,
        width: 150.w,
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 5.w),
            CircleAvatar(
              child: Icon(icon, color: AppColors.primaryColor),
            ),
            SizedBox(width: 5.w),
            Text(
              title,
              style: TextStyle(
                color: AppColors.fontWhite,
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
