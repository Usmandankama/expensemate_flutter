// lib/services/google_ml_kit_ocr_service.dart

import 'package:expense_mate_flutter/services/ocr/ocr_service.dart';

/// The concrete implementation utilizing Google ML Kit for on-device OCR.
class GoogleMlKitOcrService implements IOcrService {
  
  @override
  Future<String?> extractTextFromImage(String imagePath) async {
    try {
      // ------------------------------------------------------------------
      // PRODUCTION IMPLEMENTATION (Requires google_mlkit_text_recognition)
      // ------------------------------------------------------------------
      // final inputImage = InputImage.fromFilePath(imagePath);
      // final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      // final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      // await textRecognizer.close(); // Prevent memory leaks!
      // return recognizedText.text;
      // ------------------------------------------------------------------

      // Mock delay to simulate the heavy computational load of on-device OCR
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulating the raw text block returned by ML Kit
      return "MOCK RECEIPT DATA\nCoffee - 4.50\nSandwich - 8.00\nTotal: 12.50";

    } catch (e) {
      // Catching and rethrowing allows the ReceiptController to handle 
      // the error gracefully and emit a ReceiptError state to the UI.
      throw Exception('OCR processing failed: $e');
    }
  }
}