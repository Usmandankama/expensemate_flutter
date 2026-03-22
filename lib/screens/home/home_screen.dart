import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/RecieptScanner/receipt_scanner.dart';
import 'package:expense_mate_flutter/screens/home/components/analytics_text.dart';
import 'package:expense_mate_flutter/screens/home/components/transaction_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'components/action_button_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/images/avatar.jpeg',
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Obx(
                              ()=>
                              Text(
                                '',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20.sp,
                                  color: AppColors.fontWhite,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(
                          backgroundColor: AppColors.accentColor,
                          child: Icon(
                            Icons.notifications,
                            color: AppColors.fontWhite,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20.sp,
                        color: AppColors.fontLight,
                      ),
                    ),
                    Text(
                      '\$20000',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.fontWhite,
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => AnalyticsText(
                            titleText: 'Total Spent',
                            amount: 120,
                            // amount: expenseController.totalAmountSpent.round(),
                          ),
                        ),
                        Obx(
                          () => AnalyticsText(
                            titleText: 'Total Income',
                            amount: 15000,
                          ),
                        ),
                        AnalyticsText(titleText: 'Goal', amount: 15000),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        ActionButtonContainer(
                          onpressed: () {
                            Get.toNamed('/expenses');
                          },
                          title: 'Add Expense',
                          icon: Icons.credit_card,
                        ),
                        SizedBox(width: 5.w),
                        ActionButtonContainer(
                          onpressed: () {
                            Get.toNamed('/income');
                          },
                          title: 'Add Income',
                          icon: Icons.add_card,
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => AddProfilePictureScreen(),
                            //   ),
                            // );
                          },
                          child: CircleAvatar(
                            radius: 30.r,
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activities',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20.sp,
                            color: AppColors.fontWhite,
                          ),
                        ),
                        Text(
                          'view all',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp,
                            color: AppColors.fontLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TransactionListView(),
            ],
          ),
        ),
      ),
    );
  }
}
