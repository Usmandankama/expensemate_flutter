import 'dart:io';
import 'dart:convert';
import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:expense_mate_flutter/screens/components/actionButton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:expense_mate_flutter/secrets/secrets.dart' as secrets;

class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  ReceiptScannerPageState createState() => ReceiptScannerPageState();
}

class ReceiptScannerPageState extends State<ReceiptScannerPage> {
  File? _image;
  String _extractedText = "Scan a receipt to extract text";
  String _displayedDetails = "Scan a receipt to extract details";

  /// Pick an image from Camera or Gallery
  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// Send extracted text to ChatGPT API
  // Future<void> _sendToChatGPT(String text) async {
  //   const String apiKey = secrets.Secrets.chatgptApikey;
  //   const String apiUrl = "https://api.openai.com/v1/chat/completions";

  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {
  //       "Authorization": "Bearer $apiKey",
  //       "Content-Type": "application/json"
  //     },
  //     body: jsonEncode({
  //       "model": "gpt-3.5-turbo", 
  //       "messages": [
  //         {"role": "system", "content": "You are an AI that extracts and analyzes receipts."},
  //         {"role": "user", "content": text}
  //       ]
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(response.body);
  //     String chatGptResponse = responseData["choices"][0]["message"]["content"];

  //     setState(() {
  //       _displayedDetails += "\n\n🤖 ChatGPT: $chatGptResponse";
  //     });
  //   } else {
  //     setState(() {
  //       _displayedDetails += "\n\n❌ Failed to get response from ChatGPT.";
  //     });
  //   }
  // }
// TODO: Make payment for chatgpt api key
  /// Extract text from the image using ML Kit
  void _scanReceipt(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    String extractedText = recognizedText.text;
    _image = image;

    setState(() {
      _extractedText = extractedText;
      _displayedDetails = "Processing receipt...";
    });

    // Send extracted text to ChatGPT
    // await _sendToChatGPT(extractedText);
  }

  /// Show bottom sheet for image selection
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: AppColors.accentColor,
          ),
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text(
                  "Take a Picture",
                  style: TextStyle(color: AppColors.fontWhite),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await _pickImage(ImageSource.camera);
                  if (image != null) _scanReceipt(image);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text(
                  "Choose from Gallery",
                  style: TextStyle(color: AppColors.fontWhite),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await _pickImage(ImageSource.gallery);
                  if (image != null) _scanReceipt(image);
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
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: Text("Scan Receipt"),
        centerTitle: true,
        backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.fontLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              _image != null
                  ? Image.file(_image!, height: 200, fit: BoxFit.cover)
                  : Icon(Icons.receipt_long, size: 150, color: Colors.grey),
              SizedBox(height: 16),

              /// Button to scan receipt
              ActionButton(
                title: 'Scan Receipt',
                onPressed: _showImageSourceDialog,
              ),
              SizedBox(height: 16),

              /// Highlight key extracted details
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _displayedDetails,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.fontLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// Full extracted text in scrollable area
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _extractedText,
                    style: TextStyle(fontSize: 14, color: AppColors.fontLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
