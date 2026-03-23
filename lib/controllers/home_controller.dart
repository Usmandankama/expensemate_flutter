import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable variables (.obs)
  final userName = "Alex".obs;
  final totalBalance = 20000.0.obs;
  final totalSpent = 120.0.obs;
  final totalIncome = 15000.0.obs;

  // Logic to refresh data could go here
  void refreshData() {
    // Call your IBackendApi here eventually
  }
}