import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButtonContainer extends StatelessWidget {
  final VoidCallback onPressed; // Note: Changed 'onpressed' to camelCase 'onPressed'
  final String title;
  final IconData icon;

  const ActionButtonContainer({
    super.key,
    required this.onPressed,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Wrapping in Material and InkWell gives us the native ripple effect 
    // which is standard for adaptive UI design.
    return Material(
      color: AppColors.accentColor,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          // 1. Use constraints instead of strict height/width
          constraints: BoxConstraints(
            minHeight: 60.h, 
            minWidth: 140.w, // Ensures it doesn't get too small
            maxWidth: 250.w, // Prevents massive stretching on tablets
          ),
          // 2. Use padding to give internal elements breathing room
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 3. Hugs contents tightly if allowed
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18.r, // Explicitly scale the avatar
                child: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
              ),
              SizedBox(width: 8.w),
              // 4. Wrap text in Flexible to prevent Right-Side Overflow errors
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.fontWhite,
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                  ),
                  maxLines: 1, // Keep it to one line
                  overflow: TextOverflow.ellipsis, // Add '...' if screen is too narrow
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}