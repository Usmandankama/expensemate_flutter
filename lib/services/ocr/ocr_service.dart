/// The abstract contract for all Optical Character Recognition (OCR) operations.
abstract class IOcrService {
  /// Extracts text from an image file at the given path.
  /// Returns the raw extracted string, or null if no text could be found.
  Future<String?> extractTextFromImage(String imagePath);
}