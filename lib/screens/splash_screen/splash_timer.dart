import 'dart:async';

import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/splash_screen/spalsh_screen.dart';
import 'package:flutter/material.dart';

class SplashTimer extends StatefulWidget {
  const SplashTimer({super.key});

  @override
  State<SplashTimer> createState() => _SplashTimerState();
}

class _SplashTimerState extends State<SplashTimer> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    // Create a timer for 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Image.asset('assets/images/icon.png'),
      ),
    );
  }
}
