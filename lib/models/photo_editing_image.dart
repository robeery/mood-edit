

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'edit.dart';
import '../services/image_operations.dart';


Uint8List _applyEdits(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final edits = params['edits'] as List<Edit>;

  img.Image image = img.decodeImage(bytes)!;

    for (final operationType in OperationType.values) {
    final edit = edits.where((e) => e.type == operationType).firstOrNull;
    if (edit == null) continue;

    final value = edit.value / 100.0;

    switch (operationType) {
      case OperationType.exposure:
        image = applyExposure(image, value);
        break;
      case OperationType.brightness:
        image = applyBrightness(image, value);
        break;
      case OperationType.highlights:
        image = applyHighlights(image, value);
        break;
      case OperationType.shadows:
        image = applyShadows(image, value);
        break;
      case OperationType.contrast:
        image = applyContrast(image, value);
        break;
      case OperationType.warmth:
        image = applyWarmth(image, value);
        break;
      case OperationType.tint:
        image = applyTint(image, value);
        break;
      case OperationType.sharpness:
        image = applySharpness(image, value);
        break;
    }
  }

  return Uint8List.fromList(img.encodeJpg(image));
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