import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      // if (expenseController.isLoading.value ||
      //     incomeController.isLoading.value) {
      //   return const Center(child: CircularProgressIndicator());
      // }

      // if (expenseController.expenses.isEmpty &&
      //     incomeController.incomeList.isEmpty) {
      //   return const Center(child: Text("No transactions found."));
      // }

      // // Merge expenses and income into a single list
      // List<Map<String, dynamic>> transactions = [
      //   ...expenseController.expenses.map((e) => {...e, 'type': 'expense'}),
      //   ...incomeController.incomeList.map((i) => {...i, 'type': 'income'}),
      // ];

      // Sort transactions by date (assuming 'date' is a valid format for sorting)
      // transactions.sort((a, b) => b['date'].compareTo(a['date']));

      // Take the 8 most recent transactions
      // int itemCount = min(8, transactions.length);

      return SizedBox(
        height: 400,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            // final transaction = transactions[index];
            // final isIncome = transaction['type'] == 'income';

            // return Card(
            //   color: AppColors.accentColor,
            //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   elevation: 3,
            //   child: ListTile(
            //     leading: CircleAvatar(
            //       backgroundColor: Colors.white,
            //       child: Icon(
            //         transaction['icon'] ??
            //             (isIncome ? Icons.arrow_downward : Icons.arrow_upward),
            //         size: 20,
            //         color: AppColors.primaryColor,
            //       ),
            //     ),
            //     title: Text(
            //       transaction['name'],
            //       style: const TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: AppColors.fontWhite,
            //       ),
            //     ),
            //     subtitle: Text(
            //       "${transaction['category']} - ${transaction['date']}",
            //       style: const TextStyle(color: AppColors.fontLight),
            //     ),
            //     trailing: Text(
            //       (isIncome ? "+ \$" : "- \$") +
            //           transaction['amount'].toStringAsFixed(2),
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: isIncome ? Colors.green : Colors.red,
            //       ),
            //     ),
            //   ),
            // );
          },
        ),
      );
    });
  }
}
