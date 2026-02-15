

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'color_edit.dart';
import 'edit.dart';
import '../services/image_operations.dart';
import '../services/color_operations.dart';


Uint8List _applyEdits(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final edits = params['edits'] as List<Edit>;
  final colorEdits = params['colorEdits'] as List<ColorEdit>;

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
      case OperationType.vibrance:
        image = applyVibrance(image, value);
        break;
      case OperationType.blackpoint:
        image = applyBlackpoint(image, value);
        break;
      case OperationType.vignette:
        image = applyVignette(image, value);
        break;
      case OperationType.noiseReduction:
        image = applyNoiseReduction(image, value);
        break;
      case OperationType.grain:
        image = applyGrain(image, value);
        break;
      case OperationType.fade:
        image = applyFade(image, value);
        break;
    }
  }

   for (final colorEdit in colorEdits) {
    image = applyColorEdit(image, colorEdit);
  }

  return Uint8List.fromList(img.encodeJpg(image));
}



class PhotoEditingImage {
  final Uint8List originalBytes;
  final List<Edit> edits;

  final List<ColorEdit> colorEdits;

  PhotoEditingImage({
    required this.originalBytes,
    List<Edit>? edits,
    List<ColorEdit>? colorEdits,
  }) : edits = edits ?? [],
       colorEdits = colorEdits ?? [];


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

  ColorEdit getColorEdit(ColorRange range) {
    return colorEdits.where((e) => e.range == range).firstOrNull ?? ColorEdit(range: range);
  }

  bool hasEdit(OperationType type) {
    return edits.any((e) => e.type == type && e.value.abs() > 0.001);
  }

  bool hasColorEdit(ColorRange range) {
    return colorEdits.any((e) => e.range == range && !e.isEmpty);
  }

  void addOrUpdateColorEdit(ColorEdit colorEdit) {
  colorEdits.removeWhere((e) => e.range == colorEdit.range);
  if (!colorEdit.isEmpty) {
    colorEdits.add(colorEdit);
  }
}



  Future<Uint8List> applyAllEdits() async {
    if (edits.isEmpty && colorEdits.isEmpty) return originalBytes;

    return await compute(_applyEdits, {
      'bytes': originalBytes,
      'edits': edits,
      'colorEdits': colorEdits,
    });
  }
}