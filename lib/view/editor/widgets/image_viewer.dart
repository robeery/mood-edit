import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ImageViewer extends StatefulWidget {
  final Uint8List imageBytes;
  final Uint8List originalBytes;
  final bool isLoading;

  const ImageViewer({
    super.key,
    required this.imageBytes,
    required this.originalBytes,
    required this.isLoading,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  Timer? _originalViewTimer;
  bool _showingOriginal = false;

  @override
  void dispose() {
    _originalViewTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        _originalViewTimer = Timer(const Duration(milliseconds: 300), () {
          setState(() => _showingOriginal = true);
        });
      },
      onLongPressEnd: (_) {
        _originalViewTimer?.cancel();
        setState(() => _showingOriginal = false);
      },
      onLongPressCancel: () {
        _originalViewTimer?.cancel();
        setState(() => _showingOriginal = false);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(
            _showingOriginal ? widget.originalBytes : widget.imageBytes,
            fit: BoxFit.contain,
          ),
          if (_showingOriginal)
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: Colors.black54,
                child: const Text(
                  'ORIGINAL',
                  style: TextStyle(color: AppColors.accent, fontSize: 10, letterSpacing: 2),
                ),
              ),
            ),
          if (widget.isLoading)
            const CircularProgressIndicator(
              color: AppColors.highlight,
              strokeWidth: 1,
            ),
        ],
      ),
    );
  }
}
