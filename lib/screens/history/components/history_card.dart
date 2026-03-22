import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 10.h),
      child: Container(
        height: 90.h,
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.all(
            Radius.circular(20.r),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.movie_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  const Text(
                    'History Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: AppColors.fontWhite,
                    ),
                  ),
                ],
              ),
              const Text(
                '\$12.00',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: AppColors.fontWhite,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
