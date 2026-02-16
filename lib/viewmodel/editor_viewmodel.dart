
import 'package:flutter/foundation.dart';
import '../model/edit.dart';
import '../model/color_edit.dart';
import '../model/color_grading_edit.dart';
import '../model/photo_editing_image.dart';
import '../domain/apply_edits.dart';

enum EditorMode { basic, selectiveColor, colorGrading }

class EditorViewModel extends ChangeNotifier {
  PhotoEditingImage? _photoEditingImage;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  OperationType _selectedOperation = OperationType.exposure;
  ColorRange _selectedColorRange = ColorRange.red;
  EditorMode _editorMode = EditorMode.basic;
  ColorGradingZone _selectedGradingZone = ColorGradingZone.shadows;

  bool get hasImage => _photoEditingImage != null;
  Uint8List? get processedImage => _processedImage;
  bool get isProcessing => _isProcessing;
  OperationType get selectedOperation => _selectedOperation;
  ColorRange get selectedColorRange => _selectedColorRange;
  EditorMode get editorMode => _editorMode;
  ColorGradingZone get selectedGradingZone => _selectedGradingZone;

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

  ColorGradingEdit getColorGradingEdit(ColorGradingZone zone) {
    return _photoEditingImage?.getColorGradingEdit(zone) ??
        ColorGradingEdit(zone: zone);
  }

  bool hasColorGradingEdit(ColorGradingZone zone) {
    return _photoEditingImage?.hasColorGradingEdit(zone) ?? false;
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

  void setEditorMode(EditorMode mode) {
    _editorMode = mode;
    notifyListeners();
  }

  void setSelectedGradingZone(ColorGradingZone zone) {
    _selectedGradingZone = zone;
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

  void updateColorGradingEditPreview(ColorGradingEdit edit) {
    _photoEditingImage!.addOrUpdateColorGradingEdit(edit);
    notifyListeners();
  }

  Future<Uint8List> _processAllEdits() async {
    final model = _photoEditingImage!;
    if (model.edits.isEmpty &&
        model.colorEdits.isEmpty &&
        model.colorGradingEdits.isEmpty) {
      return model.originalBytes;
    }
    return await processAllEdits(
      originalBytes: model.originalBytes,
      edits: model.edits,
      colorEdits: model.colorEdits,
      colorGradingEdits: model.colorGradingEdits,
    );
  }

  Future<void> applyEdit(Edit edit) async {
    if (_photoEditingImage == null) return;
    _isProcessing = true;
    notifyListeners();

    _photoEditingImage!.addOrUpdateEdit(edit);
    final result = await _processAllEdits();

    _processedImage = result;
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> applyColorEdit(ColorEdit colorEdit) async {
    if (_photoEditingImage == null) return;
    _isProcessing = true;
    notifyListeners();

    _photoEditingImage!.addOrUpdateColorEdit(colorEdit);
    final result = await _processAllEdits();

    _processedImage = result;
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> applyColorGradingEdit(ColorGradingEdit edit) async {
    if (_photoEditingImage == null) return;
    _isProcessing = true;
    notifyListeners();

    _photoEditingImage!.addOrUpdateColorGradingEdit(edit);
    final result = await _processAllEdits();

    _processedImage = result;
    _isProcessing = false;
    notifyListeners();
  }
}
