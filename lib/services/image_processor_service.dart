
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

Uint8List _processImage(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final brightness = params['brightness'] as double;

  final image = img.decodeImage(bytes)!;
  final adjusted = img.adjustColor(image, brightness: brightness);

  return Uint8List.fromList(img.encodeJpg(adjusted));
}

class ImageProcessorService {
  Future<Uint8List> adjustBrightness(Uint8List bytes, double value) async {
    return await compute(_processImage, {
      'bytes': bytes,
      'brightness': value,
    });
  }
}