import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  const ActionButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.r),
            ),
          ),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppColors.secondaryColor),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: 180.w,
        height: 60.h,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.fontWhite,
              fontFamily: 'montserrat',
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}
