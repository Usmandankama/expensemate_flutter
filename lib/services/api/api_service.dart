// lib/services/api_service.dart

import 'package:expense_mate_flutter/model/receipt_model.dart';

abstract class IBackendApi {
  /// Now strictly returns a List of ReceiptItem objects.
  Future<List<ReceiptItem>> uploadReceiptData(String rawText);
}