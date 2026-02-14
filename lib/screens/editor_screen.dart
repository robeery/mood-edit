
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
  OperationType _selectedOperation = OperationType.exposure;

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

  
  static const _bg = Color(0xFF111111);
  static const _surface = Color(0xFF1E1E1E);
  static const _accent = Color(0xFFE0E0E0);
  static const _muted = Color(0xFF555555);
  static const _highlight = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'EDIT',
          style: TextStyle(
            color: _highlight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_photoEditingImage != null)
            IconButton(
              icon: const Icon(Icons.photo_library_outlined, color: _accent),
              onPressed: _pickImage,
            ),
        ],
      ),
      body: _photoEditingImage == null
          ? _buildEmptyState()
          : _buildEditor(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: _muted, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: _muted, size: 32),
              SizedBox(height: 8),
              Text(
                'Pick Image',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.memory(_processedImage!, fit: BoxFit.contain),
              if (_isProcessing)
                Container(
                  color: Colors.black26,
                  child: const CircularProgressIndicator(
                    color: _highlight,
                    strokeWidth: 1,
                  ),
                ),
            ],
          ),
        ),

        // Bottom controls
        Container(
          color: _surface,
          child: Column(
            children: [
              _buildSlider(),
              _buildOperationBar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    final currentValue = _photoEditingImage!.getValue(_selectedOperation);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // Operation name + value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedOperation.name.toUpperCase(),
                style: const TextStyle(
                  color: _accent,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                currentValue.toStringAsFixed(0),
                style: const TextStyle(
                  color: _highlight,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: _highlight,
              inactiveTrackColor: _muted,
              thumbColor: _highlight,
              overlayColor: Colors.white12,
            ),
            child: Slider(
              min: _selectedOperation.minValue,
              max: _selectedOperation.maxValue,
              value: currentValue,
              onChanged: (value) {
                setState(() {
                  _photoEditingImage!.addOrUpdateEdit(Edit(
                    type: _selectedOperation,
                    value: value,
                  ));
                });
              },
              onChangeEnd: (value) {
                _applyEdit(Edit(type: _selectedOperation, value: value));
              },
            ),
          ),

          // min/max labels
           Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _selectedOperation.minValue == 0
            ? [
                Text('0', style: TextStyle(color: _muted, fontSize: 10)),
                Text('+100', style: TextStyle(color: _muted, fontSize: 10)),
              ]
            : [
                Text('-100', style: TextStyle(color: _muted, fontSize: 10)),
                Text('0', style: TextStyle(color: _muted, fontSize: 10)),
                Text('+100', style: TextStyle(color: _muted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationBar() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: OperationType.values.length,
        itemBuilder: (context, index) {
          final operation = OperationType.values[index];
          final isSelected = operation == _selectedOperation;
          final hasEdit = _photoEditingImage!.getValue(operation) != 0.0;

          return GestureDetector(
            onTap: () => setState(() => _selectedOperation = operation),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _highlight : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected ? _highlight : _muted,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    operation.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? _bg : _muted,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasEdit) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? _bg : _accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}