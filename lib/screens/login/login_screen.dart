import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/components/actionButton.dart';
import 'package:expense_mate_flutter/screens/home/home_screen.dart';
import 'package:expense_mate_flutter/screens/home/home_shell.dart';
import 'package:expense_mate_flutter/screens/login/forgot_password_screen.dart';
import 'package:expense_mate_flutter/screens/register/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../components/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final box = GetStorage();

  late TextEditingController emailController;
  late TextEditingController passwordController;
  RxBool isLoading = false.obs; // Show loading indicator

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: box.read('email') ?? '');
    passwordController = TextEditingController(
      text: box.read('password') ?? '',
    );
  }

  Future<void> login() async {
    // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    //   Get.snackbar("Error", "Email and password cannot be empty",
    //       snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    //   return;
    // }

    // isLoading.value = true;
    // try {
    //   await authController.loginUser(
    //     email: emailController.text.trim(),
    //     password: passwordController.text.trim(),
    //   );
    //   Get.offAll(() => const HomeShell()); // Navigate to home on success
    // } catch (e) {
    //   Get.snackbar("Login Failed", e.toString(),
    //       snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    // } finally {
    //   isLoading.value = false;
    // }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.primaryColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 140),
                Text(
                  'Sign in or \ncreate an account',
                  style: TextStyle(
                    color: AppColors.fontWhite,
                    fontFamily: 'Montserrat',
                    fontSize: 36.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50.h),
                CustomTextfield(
                  label: 'Email',
                  icon: Icons.email,
                  controller: emailController,
                ),
                SizedBox(height: 23.h),
                CustomTextfield(
                  label: 'Password',
                  icon: Icons.lock,
                  controller: passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const forgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                Obx(
                  () => isLoading.value
                      ? CircularProgressIndicator(
                          color: AppColors.secondaryColor,
                        )
                      : ActionButton(title: 'Sign in', onPressed: login),
                ),
                SizedBox(height: 50.h),
                Text(
                  'or login with',
                  style: TextStyle(
                    color: AppColors.fontWhite,
                    fontSize: 17.sp,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  height: 50.h,
                  width: 300.w,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () {}, // Google login function (if needed)
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/google.png', height: 21.h),
                        SizedBox(width: 10.w),
                        Text(
                          'Login with Google',
                          style: TextStyle(
                            color: AppColors.fontDark,
                            fontSize: 16.sp,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.fontWhite,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
