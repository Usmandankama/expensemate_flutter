import 'package:expense_mate_flutter/bindings/home_bindings.dart';
import 'package:expense_mate_flutter/bindings/reciept_binding.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';
import 'package:expense_mate_flutter/screens/RecieptScanner/receipt_scanner.dart';
import 'package:expense_mate_flutter/screens/home/home_screen.dart';
import 'package:expense_mate_flutter/screens/home/home_shell.dart';
import 'package:expense_mate_flutter/screens/splash_screen/splash_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Initialize local storage
  Get.put(HomeController());
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
          getPages: [
            // Home Route
            GetPage(
              name: '/',
              page: () => const HomeScreen(),
              binding: HomeBinding(),
            ),
            // Receipt Scanner Route
            GetPage(
              name: '/scan-receipt',
              page: () => const ReceiptScannerPage(),
              binding:
                  ReceiptBinding(), // This injects your OCR & Backend services!
            ),
          ],
          debugShowCheckedModeBanner: false,
          home: _decideStartingScreen(),
        );
      },
    );
  }

  Widget _decideStartingScreen() {
    final box = GetStorage();
    bool isFirstTime = box.read("isFirstTime") ?? true; // Default is true

    if (isFirstTime) {
      // Set first-time flag to false after showing splash screen
      box.write("isFirstTime", false);
      return const SplashTimer();
    } else {
      return const HomeShell();
    }
  }
}
