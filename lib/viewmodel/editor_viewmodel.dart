import 'package:flutter/foundation.dart';
import '../model/edit.dart';
import '../model/color_edit.dart';
import '../model/photo_editing_image.dart';
import '../domain/apply_edits.dart';

class EditorViewModel extends ChangeNotifier {
  PhotoEditingImage? _photoEditingImage;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  OperationType _selectedOperation = OperationType.exposure;
  ColorRange _selectedColorRange = ColorRange.red;
  bool _isColorMode = false;

  bool get hasImage => _photoEditingImage != null;
  Uint8List? get processedImage => _processedImage;
  bool get isProcessing => _isProcessing;
  OperationType get selectedOperation => _selectedOperation;
  ColorRange get selectedColorRange => _selectedColorRange;
  bool get isColorMode => _isColorMode;

  double getEditValue(OperationType type) {
    return _photoEditingImage?.getValue(type) ?? 0.0;
  }

  bool hasEdit(OperationType type) {
    return _photoEditingImage?.hasEdit(type) ?? false;
  }

  ColorEdit getColorEdit(ColorRange range) {
    return _photoEditingImage?.getColorEdit(range) ?? ColorEdit(range: range);
  }

  bool hasColorEdit(ColorRange range) {
    return _photoEditingImage?.hasColorEdit(range) ?? false;
  }

  void loadImage(Uint8List bytes) {
    _photoEditingImage = PhotoEditingImage(originalBytes: bytes);
    _processedImage = bytes;
    notifyListeners();
  }

  void setSelectedOperation(OperationType op) {
    _selectedOperation = op;
    notifyListeners();
  }

  void setSelectedColorRange(ColorRange range) {
    _selectedColorRange = range;
    notifyListeners();
  }

  void toggleColorMode() {
    _isColorMode = !_isColorMode;
    notifyListeners();
  }

  void updateEditPreview(Edit edit) {
    _photoEditingImage!.addOrUpdateEdit(edit);
    notifyListeners();
  }

  void updateColorEditPreview(ColorEdit colorEdit) {
    _photoEditingImage!.addOrUpdateColorEdit(colorEdit);
    notifyListeners();
  }

  Future<void> applyEdit(Edit edit) async {
    if (_photoEditingImage == null) return;
    _isProcessing = true;
    notifyListeners();

    _photoEditingImage!.addOrUpdateEdit(edit);
    final result = await processAllEdits(
      originalBytes: _photoEditingImage!.originalBytes,
      edits: _photoEditingImage!.edits,
      colorEdits: _photoEditingImage!.colorEdits,
    );

    _processedImage = result;
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> applyColorEdit(ColorEdit colorEdit) async {
    if (_photoEditingImage == null) return;
    _isProcessing = true;
    notifyListeners();

    _photoEditingImage!.addOrUpdateColorEdit(colorEdit);
    final result = await processAllEdits(
      originalBytes: _photoEditingImage!.originalBytes,
      edits: _photoEditingImage!.edits,
      colorEdits: _photoEditingImage!.colorEdits,
    );

    _processedImage = result;
    _isProcessing = false;
    notifyListeners();
  }
}
