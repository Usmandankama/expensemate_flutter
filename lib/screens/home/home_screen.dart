import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'components/analytics_text.dart';
import 'components/action_button_container.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 50.h, left: 16.w, right: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 30.h),
              _buildBalanceSection(),
              SizedBox(height: 40.h),
              _buildAnalyticsRow(),
              SizedBox(height: 30.h),
              _buildActionButtons(),
              SizedBox(height: 30.h),
              _buildRecentActivitiesHeader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatar.jpeg'),
            ),
            SizedBox(width: 12.w),
            Obx(() => Text(
              "Hello, ${controller.userName.value}",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18.sp,
                color: AppColors.fontWhite,
                fontWeight: FontWeight.w600,
              ),
            )),
          ],
        ),
        const CircleAvatar(
          backgroundColor: AppColors.accentColor,
          child: Icon(Icons.notifications, color: AppColors.fontWhite),
        ),
      ],
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Balance',
          style: TextStyle(fontSize: 16.sp, color: AppColors.fontLight),
        ),
        Obx(() => Text(
          '\$${controller.totalBalance.value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.fontWhite,
          ),
        )),
      ],
    );
  }

  Widget _buildAnalyticsRow() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() => AnalyticsText(
            titleText: 'Spent',
            amount: controller.totalSpent.value.toInt(),
          )),
          const VerticalDivider(color: AppColors.fontLight),
          Obx(() => AnalyticsText(
            titleText: 'Income',
            amount: controller.totalIncome.value.toInt(),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ActionButtonContainer(
            onpressed: () => Get.toNamed('/expenses'),
            title: 'Add Expense',
            icon: Icons.credit_card,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ActionButtonContainer(
            onpressed: () => Get.toNamed('/income'),
            title: 'Add Income',
            icon: Icons.add_card,
          ),
        ),
        SizedBox(width: 10.w),
        // THE SCANNER TRIGGER
        GestureDetector(
          onTap: () => Get.toNamed('/scan-receipt'),
          child: CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColors.accentColor,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activities',
          style: TextStyle(fontSize: 18.sp, color: AppColors.fontWhite),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('View All', style: TextStyle(color: AppColors.fontLight)),
        ),
      ],
    );
  }
}