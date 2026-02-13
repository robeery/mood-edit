
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/edit.dart';
import '../models/photo_editing_image.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  PhotoEditingImage? _photoEditingImage;
  Uint8List? _processedImage;
  bool _isProcessing = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _photoEditingImage = PhotoEditingImage(originalBytes: bytes);
        _processedImage = bytes;
      });
    }
  }

  Future<void> _applyEdit(Edit edit) async {
    if (_photoEditingImage == null) return;

    setState(() => _isProcessing = true);

    _photoEditingImage!.addOrUpdateEdit(edit);
    final result = await _photoEditingImage!.applyAllEdits();

    setState(() {
      _processedImage = result;
      _isProcessing = false;
    });
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Brightness
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Brightness'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _applyEdit(Edit(
                      type: OperationType.brightness,
                      value: (_photoEditingImage!.getValue(OperationType.brightness) - 1.0).clamp(-100.0, 100.0),
                    )),
                  ),
                  Text(_photoEditingImage!.getValue(OperationType.brightness).toStringAsFixed(1)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _applyEdit(Edit(
                      type: OperationType.brightness,
                      value: (_photoEditingImage!.getValue(OperationType.brightness) + 1.0).clamp(-100.0, 100.0),
                    )),
                  ),
                ],
              ),
            ],
          ),

          // Exposure
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exposure'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _applyEdit(Edit(
                      type: OperationType.exposure,
                      value: (_photoEditingImage!.getValue(OperationType.exposure) - 1.0).clamp(-100.0, 100.0),
                    )),
                  ),
                  Text(_photoEditingImage!.getValue(OperationType.exposure).toStringAsFixed(1)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _applyEdit(Edit(
                      type: OperationType.exposure,
                      value: (_photoEditingImage!.getValue(OperationType.exposure) + 1.0).clamp(-100.0, 100.0),
                    )),
                  ),
                ],
              ),
            ],
          ),

          // Warmth
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Warmth'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _applyEdit(Edit(
                      type: OperationType.warmth,
                      value: (_photoEditingImage!.getValue(OperationType.warmth) - 1.0).clamp(-100.0, 100.0),
                    )),
                  ),
                  Text(_photoEditingImage!.getValue(OperationType.warmth).toStringAsFixed(1)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _applyEdit(Edit(
                      type: OperationType.warmth,
                      value: (_photoEditingImage!.getValue(OperationType.warmth) + 1.0).clamp(-100.0, 100.0),
                    )),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Change Image'),
          ),

          const SizedBox(height: 8),

          // debug purpose button
          ElevatedButton(onPressed: () {print(_photoEditingImage!.edits.toString());}, child: const Text("Print log edits"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Editor')),
      body: _photoEditingImage == null
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
                _buildControls(),
              ],
            ),
    );
  }
}