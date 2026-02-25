
import 'package:flutter/foundation.dart';
import '../model/edit.dart';
import '../model/color_edit.dart';
import '../model/color_grading_edit.dart';
import '../model/photo_editing_image.dart';
import '../domain/apply_edits.dart';
import '../domain/parse_edits_json.dart';
import '../model/chat_message.dart';
import '../services/gemini_service.dart';

enum EditorMode { basic, selectiveColor, colorGrading, askAi }

class EditorViewModel extends ChangeNotifier {
  PhotoEditingImage? _photoEditingImage;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  bool _isWaitingForAi = false;
  OperationType _selectedOperation = OperationType.exposure;
  ColorRange _selectedColorRange = ColorRange.red;
  EditorMode _editorMode = EditorMode.basic;
  ColorGradingZone _selectedGradingZone = ColorGradingZone.shadows;
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();

  bool get hasImage => _photoEditingImage != null;
  PhotoEditingImage? getModel() => _photoEditingImage;
  Uint8List? get processedImage => _processedImage;
  bool get isProcessing => _isProcessing;
  bool get isWaitingForAi => _isWaitingForAi;
  OperationType get selectedOperation => _selectedOperation;
  ColorRange get selectedColorRange => _selectedColorRange;
  EditorMode get editorMode => _editorMode;
  ColorGradingZone get selectedGradingZone => _selectedGradingZone;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

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

  void printLogs() {
    if (_photoEditingImage == null) return;
    final model = _photoEditingImage!;
    if(model.edits.isNotEmpty)
    {
      print('Edits:');
      for (final edit in model.edits)
        print(edit.toString());


    }
    if(model.colorEdits.isNotEmpty)
    {
      print('Color Edits:');
      for (final colorEdit in model.colorEdits)
        print(colorEdit.toString());

    }
    if(model.colorGradingEdits.isNotEmpty)
    {
      print('Color Grading Edits:');
      for (final gradingEdit in model.colorGradingEdits)
        print(gradingEdit.toString());

    }
    if (model.edits.isEmpty && model.colorEdits.isEmpty && model.colorGradingEdits.isEmpty) {
      print('No edits applied.');
    }
  }

  void resetEdits() {
    if (_photoEditingImage == null) return;
    _photoEditingImage = PhotoEditingImage(
      originalBytes: _photoEditingImage!.originalBytes,
    );
    _processedImage = _photoEditingImage!.originalBytes;
    _editorMode = EditorMode.basic;
    _selectedOperation = OperationType.exposure;
    _selectedColorRange = ColorRange.red;
    _selectedGradingZone = ColorGradingZone.shadows;
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

  Future<String?> sendMessage(String text) async {
    if (text.trim().isEmpty) return null;
    if (_photoEditingImage == null) return 'No image loaded';

    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    // Call Gemini API
    _isWaitingForAi = true;
    notifyListeners();

    final String aiReply;
    try {
      aiReply = await _geminiService.sendPrompt(text, imageBytes: _processedImage);
    } catch (e) {
      _isWaitingForAi = false;
      notifyListeners();
      return e.toString();
    }

    _isWaitingForAi = false;

    // Parse and apply
    final result = parseEditsJson(aiReply);
    if (result.error != null) {
      _messages.add(ChatMessage(text: aiReply, isUser: false));
      notifyListeners();
      return result.error;
    }

    final parsed = result.edits!;
    _messages.add(ChatMessage(text: parsed.message ?? 'Edits applied.', isUser: false));
    notifyListeners();
    for (final edit in parsed.edits) {
      _photoEditingImage!.addOrUpdateEdit(edit);
    }
    for (final colorEdit in parsed.colorEdits) {
      _photoEditingImage!.addOrUpdateColorEdit(colorEdit);
    }
    for (final gradingEdit in parsed.colorGradingEdits) {
      _photoEditingImage!.addOrUpdateColorGradingEdit(gradingEdit);
    }

    _isProcessing = true;
    notifyListeners();

    _processedImage = await _processAllEdits();
    _isProcessing = false;
    notifyListeners();
    return null;
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
