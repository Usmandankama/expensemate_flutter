import 'package:expense_mate_flutter/bindings/home_bindings.dart';
import 'package:expense_mate_flutter/bindings/reciept_binding.dart';
import 'package:expense_mate_flutter/controllers/auth_controller.dart';
import 'package:expense_mate_flutter/controllers/expense_controller.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'package:expense_mate_flutter/controllers/income_controller.dart';
import 'package:expense_mate_flutter/controllers/theme_controller.dart';
import 'package:expense_mate_flutter/controllers/user_controller.dart';
import 'package:expense_mate_flutter/firebase_options.dart';
import 'package:expense_mate_flutter/theme/app_theme.dart';
import 'package:expense_mate_flutter/utils/animation_utils.dart';
import 'package:expense_mate_flutter/screens/RecieptScanner/receipt_scanner.dart';
import 'package:expense_mate_flutter/screens/expenses/expense_screen.dart';
import 'package:expense_mate_flutter/screens/home/home_screen.dart';
import 'package:expense_mate_flutter/screens/home/home_shell.dart';
import 'package:expense_mate_flutter/screens/income/income_screen.dart';
import 'package:expense_mate_flutter/screens/login/login_screen.dart';
import 'package:expense_mate_flutter/screens/register/register_screen.dart';
import 'package:expense_mate_flutter/screens/splash_screen/splash_timer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Initialize local storage
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  Get.put(UserController());
  Get.put(AuthController());
  Get.put(IncomeController());
  Get.put(ExpenseController());
  Get.put(HomeController());
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) {
        return GetMaterialApp(
          initialRoute: "/",
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.to.themeMode,
          defaultTransition: Transition.rightToLeft,
          transitionDuration: AppAnimations.medium,
          getPages: [
            // Home Shell Route (main navigation)
            GetPage(
              name: '/',
              page: () => const HomeShell(),
              transition: Transition.fadeIn,
              transitionDuration: AppAnimations.slow,
            ),
            // Home Screen Route (dashboard content)
            GetPage(
              name: '/home',
              page: () => const HomeScreen(),
              binding: HomeBinding(),
              transition: Transition.rightToLeft,
            ),
            // Receipt Scanner Route
            GetPage(
              name: '/scan-receipt',
              page: () => const ReceiptScannerPage(),
              binding:
                  ReceiptBinding(), // This injects your OCR & Backend services!
              transition: Transition.upToDown,
              transitionDuration: AppAnimations.medium,
            ),
            GetPage(
              name: "/login", 
              page: () => const LoginScreen(),
              transition: Transition.fadeIn,
              transitionDuration: AppAnimations.medium,
            ),
            GetPage(
              name: "/register", 
              page: () => const RegisterScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: "/expenses", 
              page: () => const ExpenseScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: "/income", 
              page: () => const IncomeScreen(),
              transition: Transition.rightToLeft,
            ),
          ],
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  // Widget _decideStartingScreen() {
  //   final box = GetStorage();
  //   bool isFirstTime = box.read("isFirstTime") ?? true; // Default is true

  //   if (isFirstTime) {
  //     box.write("isFirstTime", false);
  //     return const SplashTimer();
  //   } else {
  //     return const HomeShell();
  //   }
  // }
}
