import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constatnts/colors.dart';

class AnalyticsText extends StatelessWidget {
  final String titleText;
  final int amount;
  const AnalyticsText(
      {super.key, required this.titleText, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titleText,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.sp,
            color: AppColors.fontLight,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "\$$amount",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.fontWhite,
          ),
        ),
      ],
    );
  }
}
