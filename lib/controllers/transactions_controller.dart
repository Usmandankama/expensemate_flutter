import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var transactions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  /// Fetch Transactions from both Income and Expenses
  Future<void> fetchTransactions() async {
    isLoading(true);
    try {
      var incomeSnapshot = await _firestore
          .collection('income')
          .orderBy('createdAt', descending: true)
          .get();

      var expenseSnapshot = await _firestore
          .collection('expenses')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> incomes = incomeSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        data['type'] = 'income'; // Mark as income
        return data;
      }).toList();

      List<Map<String, dynamic>> expenses = expenseSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        data['type'] = 'expense'; // Mark as expense
        return data;
      }).toList();

      // Combine income and expense transactions
      transactions.assignAll([...incomes, ...expenses]);
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      isLoading(false);
    }
  }
}
