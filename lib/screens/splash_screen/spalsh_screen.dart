import 'package:expense_mate_flutter/screens/login/login_screen.dart';
import 'package:expense_mate_flutter/screens/splash_screen/components/splash_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late PageController pageViewController;
  late TabController _tabController;
  int currentindex = 0;
  @override
  void initState() {
    super.initState();
    pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageViewController,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index) {
                  setState(() {
                    currentindex = index;
                  });
                },
                children: const [
                  SplashItem(
                    imagePath: 'assets/images/personal.png',
                    title: 'Stay On Track \n Stay In Control',
                    subtitle:
                        'Track your spending, set goals, and stay organized to take control of your financial future.',
                  ),
                  SplashItem(
                    imagePath: 'assets/images/savings.png',
                    title: 'Save smarter \n Live better',
                    subtitle:
                        "Whether you're saving for a vacation or building an emergency fund, we've got you covered.",
                  ),
                  SplashItem(
                    imagePath: 'assets/images/investing.png',
                    title: 'Invest for the Future',
                    subtitle:
                        'Turn your savings into investments. BudgetMate helps you learn the basics of investing, manage your portfolio, and grow your wealth over time.',
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: pageViewController,
              count: 3,
              axisDirection: Axis.horizontal,
              effect: const WormEffect(
                spacing: 8.0,
                radius: 50.0,
                dotWidth: 16.0,
                dotHeight: 16.0,
                strokeWidth: 1.5,
                dotColor: Colors.white54,
                activeDotColor: AppColors.secondaryColor,
              ),
            ),
            SizedBox(height: 10.h),
            currentindex == 2
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 100.w, vertical: 20.h),
                      ),
                      backgroundColor: const WidgetStatePropertyAll(
                        AppColors.secondaryColor,
                      ),
                      foregroundColor: const WidgetStatePropertyAll(
                        AppColors.fontWhite,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Get Started'),
                  ),
                )
                : SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
