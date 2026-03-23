import 'package:expense_mate_flutter/services/api/api_service.dart';
import 'package:expense_mate_flutter/controllers/receipt_controller.dart';
import 'package:expense_mate_flutter/services/api/dio_service.dart';
import 'package:expense_mate_flutter/services/api/un_backend_api.dart';
import 'package:expense_mate_flutter/services/imagePicker/IImagePickerService.dart';
import 'package:expense_mate_flutter/services/ocr/GoogleMlKitOcrService.dart';
import 'package:expense_mate_flutter/services/ocr/ocr_service.dart';
import 'package:get/get.dart';

/// Binds dependencies for the Receipt feature.
/// Ensures that OCR and Backend API services are available before
/// the ReceiptController is injected into the widget tree.
class ReceiptBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Register the concrete implementations to their abstract interfaces.
    // Using lazyPut ensures they are only instantiated when first accessed.
    Get.lazyPut<IImagePickerService>(() => AppImagePickerService());
    Get.lazyPut<IOcrService>(() => GoogleMlKitOcrService());
    Get.lazyPut<IApiService>(() => DioApiService());
    Get.lazyPut<IBackendApi>(() => BunBackendApi(Get.find<IApiService>()));

    // 2. Register the Controller, injecting the resolved dependencies.
    Get.lazyPut<ReceiptController>(
      () => ReceiptController(
        ocrService: Get.find<IOcrService>(),
        backendApi: Get.find<IBackendApi>(),
        imagePickerService: Get.find<IImagePickerService>(),
      ),
    );
  }
}
