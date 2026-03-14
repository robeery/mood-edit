import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/edit.dart';
import '../model/color_edit.dart';
import '../model/color_grading_edit.dart';
import '../viewmodel/editor_viewmodel.dart';
import '../theme/app_theme.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final EditorViewModel _vm = EditorViewModel();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _chatController = TextEditingController();
  Timer? _originalViewTimer;
  bool _showingOriginal = false;


  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _vm.loadImage(bytes);
    }
  }

  @override
  void dispose() {
    _originalViewTimer?.cancel();
    _chatController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          endDrawer: _buildDrawer(),
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: const Text(
              'EDIT',
              style: TextStyle(
                color: AppColors.highlight,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),
            centerTitle: true,
            actions: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.accent),
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
            ],
          ),
          body: !_vm.hasImage
              ? _buildEmptyState()
              : _buildEditor(),
        );
      },
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
            border: Border.all(color: AppColors.muted, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.muted, size: 32),
              SizedBox(height: 8),
              Text(
                'Pick Image',
                style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'MENU',
                style: const TextStyle(
                  color: AppColors.highlight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),
            ),
            const Divider(color: AppColors.muted, height: 1),

            // Open new picture
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.accent, size: 20),
              title: const Text(
                'OPEN NEW PICTURE',
                style: TextStyle(color: AppColors.accent, fontSize: 11, letterSpacing: 2),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),

            const Divider(color: AppColors.muted, height: 1),

            // Operations dropdown
            ExpansionTile(
              iconColor: AppColors.accent,
              collapsedIconColor: AppColors.muted,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                'OPERATIONS',
                style: const TextStyle(color: AppColors.accent, fontSize: 11, letterSpacing: 2),
              ),
              children: [
                _buildDrawerModeTile(
                  icon: Icons.tune,
                  label: 'BASIC OPERATIONS',
                  mode: EditorMode.basic,
                ),
                _buildDrawerModeTile(
                  icon: Icons.palette_outlined,
                  label: 'SELECTIVE COLOR',
                  mode: EditorMode.selectiveColor,
                ),
                _buildDrawerModeTile(
                  icon: Icons.gradient_outlined,
                  label: 'COLOR GRADING',
                  mode: EditorMode.colorGrading,
                ),
              ],
            ),

            const Divider(color: AppColors.muted, height: 1),

            // Ask AI
            ListTile(
              leading: Icon(
                Icons.auto_awesome,
                color: _vm.editorMode == EditorMode.askAi ? AppColors.highlight : AppColors.accent,
                size: 20,
              ),
              title: Text(
                'ASK AI',
                style: TextStyle(
                  color: _vm.editorMode == EditorMode.askAi ? AppColors.highlight : AppColors.accent,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              onTap: () {
                _vm.setEditorMode(EditorMode.askAi);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerModeTile({
    required IconData icon,
    required String label,
    required EditorMode mode,
  }) {
    final isActive = _vm.editorMode == mode;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      leading: Icon(icon, color: isActive ? AppColors.highlight : AppColors.muted, size: 18),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.highlight : AppColors.muted,
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
      onTap: () {
        _vm.setEditorMode(mode);
        Navigator.of(context).pop();
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text(
          'RESET',
          style: TextStyle(
            color: AppColors.highlight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),
        content: const Text(
          'Are you sure you want to start over? This will reset your progress.',
          style: TextStyle(color: AppColors.accent, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'NO',
              style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 2),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _vm.resetEdits();
            },
            child: const Text(
              'YES',
              style: TextStyle(color: AppColors.highlight, fontSize: 11, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: AppColors.muted, width: 0.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToolbarButton('RESET', _showResetDialog),
              const SizedBox(width: 12),
              _buildToolbarButton('LOGS', _vm.printLogs),
            ],
          ),
        ),
        if (_vm.hasPendingEdits) _buildPendingBar(),
        Expanded(
          child: GestureDetector(
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
                  _showingOriginal ? _vm.originalBytes! : _vm.processedImage!,
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
                if (_vm.isProcessing || _vm.isWaitingForAi)
                  Container(
                    color: Colors.black26,
                    child: const CircularProgressIndicator(
                      color: AppColors.highlight,
                      strokeWidth: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (_vm.editorMode == EditorMode.askAi)
          Expanded(child: _buildChat())
        else
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _vm.editorMode == EditorMode.basic
                    ? _buildSlider()
                    : _vm.editorMode == EditorMode.selectiveColor
                        ? _buildColorSliders()
                        : _buildGradingSliders(),
                _vm.editorMode == EditorMode.basic
                    ? _buildOperationBar()
                    : _vm.editorMode == EditorMode.selectiveColor
                        ? _buildColorBar()
                        : _buildGradingBar(),
              ],
            ),
          ),
      ],
    );
  }

  //BASIC OPS

  Widget _buildSlider() {
    final currentValue = _vm.getEditValue(_vm.selectedOperation);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _vm.selectedOperation.name.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                currentValue.toStringAsFixed(0),
                style: const TextStyle(
                  color: AppColors.highlight,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: AppSliderTheme.of(context),
            child: Slider(
              min: _vm.selectedOperation.minValue,
              max: _vm.selectedOperation.maxValue,
              value: currentValue,
              onChanged: (value) {
                _vm.updateEditPreview(
                  Edit(type: _vm.selectedOperation, value: value),
                );
              },
              onChangeEnd: (value) {
                _vm.applyEdit(Edit(type: _vm.selectedOperation, value: value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _vm.selectedOperation.minValue == 0
                  ? [
                      Text('0', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                      Text('+100', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                    ]
                  : [
                      Text('-100', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                      Text('0', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                      Text('+100', style: TextStyle(color: AppColors.muted, fontSize: 10)),
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
          final isSelected = operation == _vm.selectedOperation;
          final hasEdit = _vm.hasEdit(operation);

          return GestureDetector(
            onTap: () => _vm.setSelectedOperation(operation),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.highlight : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected ? AppColors.highlight : AppColors.muted,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    operation.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? AppColors.bg : AppColors.muted,
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
                        color: isSelected ? AppColors.bg : AppColors.accent,
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

  //COLOR

  Widget _buildColorSliders() {
  final colorEdit = _vm.getColorEdit(_vm.selectedColorRange);

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Column(
      children: [
        _buildColorSliderRow(
          'HUE',
          colorEdit.hue,
          (value) => _vm.applyColorEdit(colorEdit.copyWith(hue: value)),
          (value) => _vm.updateColorEditPreview(colorEdit.copyWith(hue: value)),
        ),
        _buildColorSliderRow(
          'SAT',
          colorEdit.saturation,
          (value) => _vm.applyColorEdit(colorEdit.copyWith(saturation: value)),
          (value) => _vm.updateColorEditPreview(colorEdit.copyWith(saturation: value)),
        ),
        _buildColorSliderRow(
          'LUM',
          colorEdit.luminance,
          (value) => _vm.applyColorEdit(colorEdit.copyWith(luminance: value)),
          (value) => _vm.updateColorEditPreview(colorEdit.copyWith(luminance: value)),
        ),
      ],
    ),
  );
}

 Widget _buildColorSliderRow(String label, double value, Function(double) onChangeEnd, Function(double) onChanged) {
  return Row(
    children: [
      SizedBox(
        width: 32,
        child: Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 2),
        ),
      ),
      Expanded(
        child: SliderTheme(
          data: AppSliderTheme.of(context),
          child: Slider(
            min: -100,
            max: 100,
            value: value,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ),
      SizedBox(
        width: 32,
        child: Text(
          value.toStringAsFixed(0),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.highlight,
            fontSize: 11,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    ],
  );
}

  // COLOR GRADING

  Widget _buildGradingSliders() {
    final edit = _vm.getColorGradingEdit(_vm.selectedGradingZone);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          _buildGradingSliderRow(
            'HUE',
            edit.hue,
            0, 360,
            '${edit.hue.toStringAsFixed(0)}°',
            (value) => _vm.applyColorGradingEdit(edit.copyWith(hue: value)),
            (value) => _vm.updateColorGradingEditPreview(edit.copyWith(hue: value)),
          ),
          _buildGradingSliderRow(
            'STR',
            edit.strength,
            0, 100,
            '${edit.strength.toStringAsFixed(0)}%',
            (value) => _vm.applyColorGradingEdit(edit.copyWith(strength: value)),
            (value) => _vm.updateColorGradingEditPreview(edit.copyWith(strength: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingSliderRow(
    String label, double value, double min, double max, String display,
    Function(double) onChangeEnd, Function(double) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 2),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: AppSliderTheme.of(context),
            child: Slider(
              min: min,
              max: max,
              value: value,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            display,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.highlight,
              fontSize: 11,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradingBar() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: ColorGradingZone.values.length,
        itemBuilder: (context, index) {
          final zone = ColorGradingZone.values[index];
          final isSelected = zone == _vm.selectedGradingZone;
          final hasEdit = _vm.hasColorGradingEdit(zone);

          return GestureDetector(
            onTap: () => _vm.setSelectedGradingZone(zone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.highlight : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected ? AppColors.highlight : AppColors.muted,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    zone.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? AppColors.bg : AppColors.muted,
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
                        color: isSelected ? AppColors.bg : AppColors.accent,
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

  Widget _buildPendingBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'APPLY CHANGES?',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _vm.discardPendingEdits(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: AppColors.muted, width: 0.5),
              ),
              child: const Text(
                'DISCARD',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _vm.applyPendingEdits(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.highlight,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'APPLY',
                style: TextStyle(
                  color: AppColors.bg,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    final messages = _vm.messages;

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !_vm.isWaitingForAi
                ? const Center(
                    child: Text(
                      'ASK AI ANYTHING',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: messages.length + (_vm.isWaitingForAi ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.muted, width: 0.5),
                            ),
                            child: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                        );
                      }
                      final msg = messages[index];
                      return Align(
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? AppColors.highlight.withValues(alpha: 0.15)
                                : AppColors.bg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: msg.isUser ? AppColors.highlight.withValues(alpha: 0.3) : AppColors.muted,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? AppColors.highlight : AppColors.accent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.muted, width: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'MODEL ',
                      style: TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: 2),
                    ),
                    DropdownButton<String>(
                      value: _vm.selectedModel,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.accent, fontSize: 11),
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.muted, size: 16),
                      items: EditorViewModel.availableModels.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(model, style: const TextStyle(fontSize: 11)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _vm.setSelectedModel(value);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(color: AppColors.highlight, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (_) => _sendChat(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.accent, size: 20),
                      onPressed: _sendChat,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChat() async {
    final text = _chatController.text;
    if (text.trim().isEmpty) return;
    _chatController.clear();
    final error = await _vm.sendMessage(text);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildColorBar() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ColorRange.values.length,
        itemBuilder: (context, index) {
          final range = ColorRange.values[index];
          final isSelected = range == _vm.selectedColorRange;
          final hasEdit = _vm.hasColorEdit(range);
          final color = AppColors.colorRange[range]!;

          return GestureDetector(
            onTap: () => _vm.setSelectedColorRange(range),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.highlight : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  if (hasEdit) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
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
