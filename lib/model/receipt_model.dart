// lib/models/receipt_item.dart
class ReceiptItem {
  final int? id; // Added ID because the backend returns it
  final String name;
  final double amount;
  final String category;

  ReceiptItem({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      id: json['id'] as int?,
      // Matching the backend: 'name', 'amount', 'category'
      name: json['name'] as String? ?? 'Unknown Item',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Other',
    );
  }
}