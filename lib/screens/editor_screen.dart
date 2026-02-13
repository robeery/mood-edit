
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_processor_service.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  File? _originalFile;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  double _brightnessValue = 1.0;

  Uint8List? _originalBytes;
  final ImagePicker _picker = ImagePicker();
  final ImageProcessorService _service = ImageProcessorService();

  Future<void> _pickImage() async {

   

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _originalFile = File(pickedFile.path);
        _originalBytes = bytes;
        _processedImage = bytes;
        _brightnessValue = 1.0;
      });
    }
  }

  Future<void> _applyBrightness(double value) async {
    if (_originalFile == null) return;

    setState(() => _isProcessing = true);

    
    //final bytes = await _originalFile!.readAsBytes();
    final result = await _service.adjustBrightness(_originalBytes!, value);
    
    setState(() {
      _processedImage = result;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Editor')),
      body: _originalFile == null
          ? Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.memory(_processedImage!, fit: BoxFit.contain),
                      if (_isProcessing) const CircularProgressIndicator(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _applyBrightness(_brightnessValue += 0.1),
                            child: const Text('Brightness +'),
                          ),
                          ElevatedButton(
                            onPressed: () => _applyBrightness(_brightnessValue -= 0.1),
                            child: const Text('Brightness -'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Change Image'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}