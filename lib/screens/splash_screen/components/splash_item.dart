import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constatnts/colors.dart';

class SplashItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  const SplashItem(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(height: 130.h),
          SizedBox(
            height: 315.h,
            width: 400.w,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          SizedBox(height: 30.h),
          Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32.sp,
                    fontFamily: 'Montserrat',
                    color: AppColors.fontWhite),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Montserrat',
                    color: AppColors.fontWhite),
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}
