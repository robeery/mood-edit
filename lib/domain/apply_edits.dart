import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../model/edit.dart';
import '../model/color_edit.dart';
import '../model/color_grading_edit.dart';
import 'image_operations.dart';
import 'color_operations.dart' as color_ops;
import 'color_grading_operations.dart' as grading_ops;


Uint8List _applyEdits(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final edits = params['edits'] as List<Edit>;
  final colorEdits = params['colorEdits'] as List<ColorEdit>;
  final colorGradingEdits = params['colorGradingEdits'] as List<ColorGradingEdit>;

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
    image = color_ops.applyColorEdit(image, colorEdit);
  }

  image = grading_ops.applyColorGrading(image, colorGradingEdits);

  return Uint8List.fromList(img.encodeJpg(image));
}

Future<Uint8List> processAllEdits({
  required Uint8List originalBytes,
  required List<Edit> edits,
  required List<ColorEdit> colorEdits,
  required List<ColorGradingEdit> colorGradingEdits,
}) async {
  if (edits.isEmpty && colorEdits.isEmpty && colorGradingEdits.isEmpty) {
    return originalBytes;
  }

  return await compute(_applyEdits, {
    'bytes': originalBytes,
    'edits': edits,
    'colorEdits': colorEdits,
    'colorGradingEdits': colorGradingEdits,
  });
}
