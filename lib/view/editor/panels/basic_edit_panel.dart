import 'package:flutter/material.dart';
import '../../../model/edit.dart';
import '../../../theme/app_theme.dart';
import '../../../viewmodel/editor_viewmodel.dart';

class BasicEditPanel extends StatelessWidget {
  final EditorViewModel vm;

  const BasicEditPanel({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSlider(context),
        _buildOperationBar(),
      ],
    );
  }

  Widget _buildSlider(BuildContext context) {
    final currentValue = vm.getEditValue(vm.selectedOperation);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vm.selectedOperation.name.toUpperCase(),
                style: AppTextStyles.sliderLabel,
              ),
              Text(
                currentValue.toStringAsFixed(0),
                style: AppTextStyles.sliderValue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: AppSliderTheme.of(context),
            child: Slider(
              min: vm.selectedOperation.minValue,
              max: vm.selectedOperation.maxValue,
              value: currentValue,
              onChanged: (value) {
                vm.updateEditPreview(
                  Edit(type: vm.selectedOperation, value: value),
                );
              },
              onChangeEnd: (value) {
                vm.applyEdit(Edit(type: vm.selectedOperation, value: value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: vm.selectedOperation.minValue == 0
                  ? [
                      Text('0', style: AppTextStyles.mutedSmall),
                      Text('+100', style: AppTextStyles.mutedSmall),
                    ]
                  : [
                      Text('-100', style: AppTextStyles.mutedSmall),
                      Text('0', style: AppTextStyles.mutedSmall),
                      Text('+100', style: AppTextStyles.mutedSmall),
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
          final isSelected = operation == vm.selectedOperation;
          final hasEdit = vm.hasEdit(operation);

          return GestureDetector(
            onTap: () => vm.setSelectedOperation(operation),
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
}
