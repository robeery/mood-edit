import 'package:flutter/material.dart';
import '../../../model/color_edit.dart';
import '../../../theme/app_theme.dart';
import '../../../viewmodel/editor_viewmodel.dart';

class ColorEditPanel extends StatelessWidget {
  final EditorViewModel vm;

  const ColorEditPanel({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSliders(context),
        _buildColorBar(),
      ],
    );
  }

  Widget _buildSliders(BuildContext context) {
    final colorEdit = vm.getColorEdit(vm.selectedColorRange);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          _buildSliderRow(context, 'HUE', colorEdit.hue,
            (v) => vm.applyColorEdit(colorEdit.copyWith(hue: v)),
            (v) => vm.updateColorEditPreview(colorEdit.copyWith(hue: v)),
          ),
          _buildSliderRow(context, 'SAT', colorEdit.saturation,
            (v) => vm.applyColorEdit(colorEdit.copyWith(saturation: v)),
            (v) => vm.updateColorEditPreview(colorEdit.copyWith(saturation: v)),
          ),
          _buildSliderRow(context, 'LUM', colorEdit.luminance,
            (v) => vm.applyColorEdit(colorEdit.copyWith(luminance: v)),
            (v) => vm.updateColorEditPreview(colorEdit.copyWith(luminance: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(BuildContext context, String label, double value,
      Function(double) onChangeEnd, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(label, style: AppTextStyles.mutedSmall),
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

  Widget _buildColorBar() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ColorRange.values.length,
        itemBuilder: (context, index) {
          final range = ColorRange.values[index];
          final isSelected = range == vm.selectedColorRange;
          final hasEdit = vm.hasColorEdit(range);
          final color = AppColors.colorRange[range]!;

          return GestureDetector(
            onTap: () => vm.setSelectedColorRange(range),
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
