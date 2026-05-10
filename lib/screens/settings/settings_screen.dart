import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/controllers/auth_controller.dart';
import 'package:expense_mate_flutter/screens/profile/edit_profile.dart';
import 'package:expense_mate_flutter/screens/settings/components/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final authController = Get.find<AuthController>(); // Assuming you have an AuthController for logout

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 24.sp, color: AppColors.fontWhite),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // User Profile
              Center(
                child: Column(
                  children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/avatar.jpeg',
                      ),
                      radius: 60.r,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      // userController.userName.value,
                      '',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.fontWhite,
                      ),
                    ),
                    Text(
                      // userController.email.value,
                      "",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.fontLight,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Account Section
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fontLight,
                ),
              ),
              SizedBox(height: 10.h),
              SettingsTile(
                icon: Icons.person,
                text: 'Edit Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 10.h),

              SettingsTile(
                icon: Icons.email,
                text: 'Change Email',
                onPressed: () {},
              ),
              SizedBox(height: 10.h),

              SettingsTile(
                icon: Icons.lock,
                text: 'Change Password',
                onPressed: () {},
              ),

              SizedBox(height: 20.h),

              // Preferences Section
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fontLight,
                ),
              ),
              SizedBox(height: 10.h),
              SettingsTile(
                icon: Icons.notifications,
                text: 'Notifications',
                onPressed: () {},
              ),
              SizedBox(height: 10.h),

              SettingsTile(
                icon: Icons.color_lens,
                text: 'Theme & Appearance',
                onPressed: () {},
              ),
              SizedBox(height: 10.h),

              SettingsTile(
                icon: Icons.language,
                text: 'Currency',
                onPressed: () {},
              ),

              SizedBox(height: 20.h),

              // Security Section
              Text(
                'Security',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fontLight,
                ),
              ),
              SizedBox(height: 10.h),
              SettingsTile(
                icon: Icons.fingerprint,
                text: 'Enable Biometric Login',
                onPressed: () {},
              ),
              SizedBox(height: 10.h),

              SettingsTile(
                icon: Icons.security,
                text: 'Two-Factor Authentication',
                onPressed: () {},
              ),

              SizedBox(height: 20.h),

              // App Info
              Text(
                'App Info',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fontLight,
                ),
              ),
              SizedBox(height: 10.h),
              SettingsTile(
                icon: Icons.info,
                text: 'About BudgetMate',
                onPressed: () {},
              ),
              SizedBox(height: 10.h),

              SettingsTile(
                icon: Icons.privacy_tip,
                text: 'Privacy Policy',
                onPressed: () {},
              ),
              SizedBox(height: 10.h),

              SettingsTile(
                icon: Icons.article,
                text: 'Terms & Conditions',
                onPressed: () {},
              ),

              SizedBox(height: 20.h),

              // Logout
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    authController.signOut();
                  },
                  icon: Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    "Logout",
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
