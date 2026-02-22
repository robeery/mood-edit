import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/edit.dart';
import '../model/color_edit.dart';
import '../model/color_grading_edit.dart';
import '../viewmodel/editor_viewmodel.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final EditorViewModel _vm = EditorViewModel();
  final ImagePicker _picker = ImagePicker();

  static const _bg = Color(0xFF111111);
  static const _surface = Color(0xFF1E1E1E);
  static const _accent = Color(0xFFE0E0E0);
  static const _muted = Color(0xFF555555);
  static const _highlight = Color(0xFFFFFFFF);

  
  static const Map<ColorRange, Color> _colorRangeColors = {
    ColorRange.red:     Color(0xFFFF3B30),
    ColorRange.orange:  Color(0xFFFF9500),
    ColorRange.yellow:  Color(0xFFFFCC00),
    ColorRange.green:   Color(0xFF34C759),
    ColorRange.cyan:    Color(0xFF5AC8FA),
    ColorRange.blue:    Color(0xFF007AFF),
    ColorRange.purple:  Color(0xFFAF52DE),
    ColorRange.magenta: Color(0xFFFF2D55),
  };

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
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _bg,
          endDrawer: _buildDrawer(),
          appBar: AppBar(
            backgroundColor: _bg,
            elevation: 0,
            title: const Text(
              'EDIT',
              style: TextStyle(
                color: _highlight,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),
            centerTitle: true,
            actions: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: _accent),
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
            border: Border.all(color: _muted, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: _muted, size: 32),
              SizedBox(height: 8),
              Text(
                'Pick Image',
                style: TextStyle(color: _muted, fontSize: 12, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'MENU',
                style: const TextStyle(
                  color: _highlight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),
            ),
            const Divider(color: _muted, height: 1),

            // Open new picture
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _accent, size: 20),
              title: const Text(
                'OPEN NEW PICTURE',
                style: TextStyle(color: _accent, fontSize: 11, letterSpacing: 2),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),

            const Divider(color: _muted, height: 1),

            // Operations dropdown
            ExpansionTile(
              iconColor: _accent,
              collapsedIconColor: _muted,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                'OPERATIONS',
                style: const TextStyle(color: _accent, fontSize: 11, letterSpacing: 2),
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
      leading: Icon(icon, color: isActive ? _highlight : _muted, size: 18),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? _highlight : _muted,
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
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text(
          'RESET',
          style: TextStyle(
            color: _highlight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),
        content: const Text(
          'Are you sure you want to start over? This will reset your progress.',
          style: TextStyle(color: _accent, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'NO',
              style: TextStyle(color: _muted, fontSize: 11, letterSpacing: 2),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _vm.resetEdits();
            },
            child: const Text(
              'YES',
              style: TextStyle(color: _highlight, fontSize: 11, letterSpacing: 2),
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
          color: _surface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: _muted, width: 0.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _accent,
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
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.memory(_vm.processedImage!, fit: BoxFit.contain),
              if (_vm.isProcessing)
                Container(
                  color: Colors.black26,
                  child: const CircularProgressIndicator(
                    color: _highlight,
                    strokeWidth: 1,
                  ),
                ),
            ],
          ),
        ),

        Container(
          color: _surface,
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
                  color: _accent,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                currentValue.toStringAsFixed(0),
                style: const TextStyle(
                  color: _highlight,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: _highlight,
              inactiveTrackColor: _muted,
              thumbColor: _highlight,
              overlayColor: Colors.white12,
            ),
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
                      Text('0', style: TextStyle(color: _muted, fontSize: 10)),
                      Text('+100', style: TextStyle(color: _muted, fontSize: 10)),
                    ]
                  : [
                      Text('-100', style: TextStyle(color: _muted, fontSize: 10)),
                      Text('0', style: TextStyle(color: _muted, fontSize: 10)),
                      Text('+100', style: TextStyle(color: _muted, fontSize: 10)),
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
                color: isSelected ? _highlight : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected ? _highlight : _muted,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    operation.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? _bg : _muted,
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
                        color: isSelected ? _bg : _accent,
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
          style: const TextStyle(color: _muted, fontSize: 10, letterSpacing: 2),
        ),
      ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 1,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            activeTrackColor: _highlight,
            inactiveTrackColor: _muted,
            thumbColor: _highlight,
            overlayColor: Colors.white12,
          ),
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
            color: _highlight,
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
            style: const TextStyle(color: _muted, fontSize: 10, letterSpacing: 2),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: _highlight,
              inactiveTrackColor: _muted,
              thumbColor: _highlight,
              overlayColor: Colors.white12,
            ),
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
              color: _highlight,
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
                color: isSelected ? _highlight : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected ? _highlight : _muted,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    zone.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? _bg : _muted,
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
                        color: isSelected ? _bg : _accent,
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
          final color = _colorRangeColors[range]!;

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
                        color: isSelected ? _highlight : Colors.transparent,
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
                        color: _accent,
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
