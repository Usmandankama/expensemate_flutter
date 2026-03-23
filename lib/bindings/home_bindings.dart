// lib/bindings/home_binding.dart
import 'package:get/get.dart';
import 'package:expense_mate_flutter/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true keeps the controller alive even if you pop the screen,
    // which is usually what you want for a primary Home screen.
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}