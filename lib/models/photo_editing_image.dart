
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'edit.dart';


Uint8List _applyEdits(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final edits = params['edits'] as List<Edit>;

  img.Image image = img.decodeImage(bytes)!;

  for (final operationType in OperationType.values) {
    final edit = edits.where((e) => e.type == operationType).firstOrNull;
    if (edit == null) continue;

    switch (operationType) {
      case OperationType.exposure:
        image = img.adjustColor(image, exposure: edit.value / 100.0);
        break;
      case OperationType.brightness:
        image = img.adjustColor(image, brightness: 1.0 + (edit.value / 100.0));
        break;
      case OperationType.warmth:
        image = _applyWarmth(image, edit.value / 100.0);
        break;
    }
  }

  return Uint8List.fromList(img.encodeJpg(image));
}

img.Image _applyWarmth(img.Image image, double value) {
  final output = img.Image.from(image);
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (pixel.r + value * 20).clamp(0, 255).toInt();
      final b = (pixel.b - value * 20).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, pixel.g.toInt(), b));
    }
  }
  return output;
}

class PhotoEditingImage {
  final Uint8List originalBytes;
  final List<Edit> edits;

  PhotoEditingImage({
    required this.originalBytes,
    List<Edit>? edits,
  }) : edits = edits ?? [];

  void addOrUpdateEdit(Edit edit) {
    edits.removeWhere((e) => e.type == edit.type);
    edits.add(edit);
  }

  void removeEdit(OperationType type) {
    edits.removeWhere((e) => e.type == type);
  }

  double getValue(OperationType type) {
    return edits.where((e) => e.type == type).firstOrNull?.value ?? 0.0;
  }

  Future<Uint8List> applyAllEdits() async {
    if (edits.isEmpty) return originalBytes;

    return await compute(_applyEdits, {
      'bytes': originalBytes,
      'edits': edits,
    });
  }
}