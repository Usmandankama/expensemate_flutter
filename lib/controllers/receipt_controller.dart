import 'dart:io';
import 'package:expense_mate_flutter/model/receipt_model.dart';
import 'package:expense_mate_flutter/services/imagePicker/IImagePickerService.dart';
import 'package:get/get.dart';
import 'package:expense_mate_flutter/services/api/api_service.dart';
import 'package:expense_mate_flutter/services/ocr/ocr_service.dart';
import 'package:image_picker/image_picker.dart';

// --- STATES ---
// Excellent use of a sealed class to enforce exhaustive pattern matching in the UI.
sealed class ReceiptState {}

class ReceiptInitial extends ReceiptState {}

class ReceiptProcessingOcr extends ReceiptState {
  final File image;
  ReceiptProcessingOcr(this.image);
}

class ReceiptAnalyzingBackend extends ReceiptState {
  final File image;
  final String rawText;
  ReceiptAnalyzingBackend(this.image, this.rawText);
}

class ReceiptSuccess extends ReceiptState {
  final List<ReceiptItem> items; // Strongly typed!
  ReceiptSuccess(this.items);
}

class ReceiptError extends ReceiptState {
  final String message;
  ReceiptError(this.message);
}

// --- CONTROLLER ---
class ReceiptController extends GetxController {
  final IOcrService _ocrService;
  final IBackendApi _backendApi;
  final IImagePickerService _imagePickerService;

  // Constructor requires dependencies, ensuring they are injected via Get.find()
  ReceiptController({
    required IOcrService ocrService,
    required IBackendApi backendApi,
    required IImagePickerService imagePickerService,
  }) : _ocrService = ocrService,
       _backendApi = backendApi,
       _imagePickerService = imagePickerService;

  // Encapsulation: The Rx variable is private.
  // The UI can only read the state, not mutate it.
  final _currentState = Rx<ReceiptState>(ReceiptInitial());
  ReceiptState get state => _currentState.value;

  Future<void> captureAndProcess(ImageSource source) async {
    final File? image = await _imagePickerService.pickImage(source);
    if (image != null) {
      processReceipt(image);
    }
  }

 Future<void> processReceipt(File image) async {
  try {
    _currentState.value = ReceiptProcessingOcr(image);
    
    // 1. Extract raw text locally (On-device)
    final String? extractedText = await _ocrService.extractTextFromImage(image.path);
    
    if (extractedText == null || extractedText.trim().isEmpty) {
      _currentState.value = ReceiptError("No text found on the receipt.");
      return;
    }

    // 2. Transition to Backend Phase
    _currentState.value = ReceiptAnalyzingBackend(image, extractedText);

    // 3. Send the raw text as JSON to your Bun Backend
    // Dio will automatically convert this Map into a JSON body
    final List<ReceiptItem> structuredData = await _backendApi.uploadReceiptData(extractedText);

    // 4. Success!
    _currentState.value = ReceiptSuccess(structuredData);

  } catch (e) {
    _currentState.value = ReceiptError("Extraction Failed: $e");
  }
}

  void reset() => _currentState.value = ReceiptInitial();
}
