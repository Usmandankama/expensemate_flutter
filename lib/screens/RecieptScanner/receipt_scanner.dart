import 'dart:io';
import 'dart:convert';
import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/components/actionButton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;

class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  ReceiptScannerPageState createState() => ReceiptScannerPageState();
}

class ReceiptScannerPageState extends State<ReceiptScannerPage> {
  File? _image;
  String _extractedText = "Scan a receipt to extract text";
  String _displayedDetails = "Scan a receipt to extract details";
  bool _isLoading = false;

  /// 1. Pick an image from Camera or Gallery
  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      imageQuality: 85,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// 2. Send extracted text to Bun Backend
  Future<void> _sendToBunBackend(String text) async {
    // Ensure this matches your computer's IP on the Hotspot
    const String apiUrl = "http://10.246.248.253:5000/api/expenses";

    setState(() {
      _isLoading = true;
      _displayedDetails = "⏳ AI is processing... (5-20s)";
    });

    try {
      print("🚀 Requesting: $apiUrl");
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"text": text}),
      ).timeout(const Duration(seconds: 45)); // Longer timeout for Ollama/Phi-3

      print("Status: ${response.statusCode}");
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _displayedDetails = "✅ Success: ${data['message'] ?? 'Items Saved'}";
        });
      } else {
        setState(() {
          _displayedDetails = "❌ Server Error (${response.statusCode})";
        });
        print("Error Body: ${response.body}");
      }
    } catch (e) {
      print("Connection Error: $e");
      setState(() {
        _displayedDetails = "❌ Connection Failed. Check Hotspot/Firewall.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 3. Extract text from the image using ML Kit
  void _scanReceipt(File image) async {
    setState(() {
      _image = image;
      _displayedDetails = "🔍 Running OCR...";
    });

    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.trim().isEmpty) {
        setState(() => _displayedDetails = "⚠️ No text found in image.");
        return;
      }

      setState(() {
        _extractedText = recognizedText.text;
      });

      // Automatically try to send to backend after OCR
      await _sendToBunBackend(recognizedText.text);
      
    } catch (e) {
      setState(() => _displayedDetails = "❌ OCR Failed: $e");
    } finally {
      textRecognizer.close();
    }
  }

  /// 4. Retry only the AI/Backend part
  void _retryAI() {
    if (_extractedText.isNotEmpty && _extractedText != "Scan a receipt to extract text") {
      _sendToBunBackend(_extractedText);
    }
  }

  /// 5. Show selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Receipt Source",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.greenAccent),
                title: const Text("Take a Picture", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  File? img = await _pickImage(ImageSource.camera);
                  if (img != null) _scanReceipt(img);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blueAccent),
                title: const Text("Choose from Gallery", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  File? img = await _pickImage(ImageSource.gallery);
                  if (img != null) _scanReceipt(img);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasText = _extractedText != "Scan a receipt to extract text";

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: const Text("Receipt Scanner"),
        centerTitle: true,
        backgroundColor: AppColors.accentColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image Preview Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 80, color: Colors.white24),
                          SizedBox(height: 10),
                          Text("No image selected", style: TextStyle(color: Colors.white54)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    title: 'Scan New',
                    onPressed: _isLoading ? () {} : _showImageSourceDialog,
                  ),
                ),
                if (hasText) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ActionButton(
                      title: 'Retry AI',
                      onPressed: _isLoading ? () {} : _retryAI,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Status/Details Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isLoading ? Colors.blue : Colors.transparent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading) const LinearProgressIndicator(backgroundColor: Colors.transparent),
                  const SizedBox(height: 8),
                  Text(
                    _displayedDetails,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Raw Text Scrollable Area
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _extractedText,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}