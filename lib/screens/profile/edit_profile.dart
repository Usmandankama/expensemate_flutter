import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserController userController = Get.put(UserController());

  void _showEditBottomSheet(String title, TextEditingController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: controller,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {
                // Save logic here
                Get.back();
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.fontWhite,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 24.sp, color: AppColors.fontWhite),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/avatar.jpeg',
                    ),
                    radius: 70.r,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18.r,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Name", style: TextStyle(color: Colors.white)),
              subtitle: Text("Usman", style: TextStyle(color: Colors.white70)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap:
                  () => _showEditBottomSheet(
                    "Edit Name",
                    TextEditingController(text: "Usman"),
                  ),
            ),
            Divider(color: Colors.white24),
            ListTile(
              title: Text("Email", style: TextStyle(color: Colors.white)),
              subtitle: Text(
                "hello@gmail.com",
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap:
                  () => _showEditBottomSheet(
                    "Edit Email",
                    TextEditingController(text: "hello@gmail.com"),
                  ),
            ),
            Divider(color: Colors.white24),
            ListTile(
              title: Text("Username", style: TextStyle(color: Colors.white)),
              subtitle: Text(
                "@usman123",
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap:
                  () => _showEditBottomSheet(
                    "Edit Username",
                    TextEditingController(text: "@usman123"),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
