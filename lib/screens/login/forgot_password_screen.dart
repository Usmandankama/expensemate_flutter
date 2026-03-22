// ignore_for_file: camel_case_types

import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/components/actionButton.dart';
import 'package:expense_mate_flutter/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../components/text_field.dart';

class forgotPasswordScreen extends StatefulWidget {
  const forgotPasswordScreen({super.key});

  @override
  State<forgotPasswordScreen> createState() => _forgotPasswordScreenState();
}

class _forgotPasswordScreenState extends State<forgotPasswordScreen> {
  TextEditingController emailController =  TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Reset password',
                style: TextStyle(
                  color: AppColors.fontWhite,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 50.h),
              const Text(
                  textAlign: TextAlign.center,
                  'Enter your registered email address and we will send you a password reset link.',
                  style: TextStyle(
                    color: AppColors.fontWhite,
                    fontFamily: 'Montserrat',
                  )),
              SizedBox(height: 50.h),
              CustomTextfield(
                label: 'Email',
                icon: Icons.email,
                controller: emailController,
              ),
              SizedBox(height: 50.h),
              ActionButton(title: 'Reset', onPressed: () {}),
              SizedBox(height: 50.h),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => const LoginScreen()));                  
                },
                child: Text(
                  'Back to login',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.sp,
                      color: AppColors.secondaryColor,),
                ),
              )
            ],
          ),
        ));
  }
}
