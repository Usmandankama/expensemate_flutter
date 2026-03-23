// lib/services/image_picker_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class IImagePickerService {
  Future<File?> pickImage(ImageSource source);
}

class AppImagePickerService implements IImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImage(ImageSource source) async {
    final XFile? selectedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1800, // Optimize image size for OCR
      imageQuality: 85,
    );
    
    if (selectedFile != null) {
      return File(selectedFile.path);
    }
    return null;
  }
}