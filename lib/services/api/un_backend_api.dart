// lib/services/bun_backend_api.dart
import 'package:expense_mate_flutter/model/receipt_model.dart';
import 'package:expense_mate_flutter/services/api/api_service.dart';
import 'package:expense_mate_flutter/services/api/dio_service.dart';

class BunBackendApi implements IBackendApi {
  final IApiService _api;

  BunBackendApi(this._api);

  // lib/services/bun_backend_api.dart
@override
Future<List<ReceiptItem>> uploadReceiptData(String rawText) async {
  try {
    final response = await _api.post(
      '/expenses', // Or whatever your route is
      data: {'text': rawText},
    );

    // DEBUG: Print the raw response if you hit more type errors
    // print("BACKEND RESPONSE: ${response.data}");

    // 1. Your backend wraps the array in a 'data' key
    final dynamic responseData = response.data['data'];

    if (responseData is List) {
      return responseData
          .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Backend did not return a list in the 'data' field");
    }
  } catch (e) {
    throw "Failed to parse receipt: $e";
  }
}
}