import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../viewmodel/editor_viewmodel.dart';

class ModeTabBar extends StatelessWidget {
  final EditorMode currentMode;
  final ValueChanged<EditorMode> onModeChanged;

  const ModeTabBar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  static const _modes = [
    (mode: EditorMode.basic,          icon: Icons.tune,              label: 'BASIC'),
    (mode: EditorMode.selectiveColor, icon: Icons.palette_outlined,  label: 'COLOR'),
    (mode: EditorMode.colorGrading,   icon: Icons.gradient_outlined, label: 'GRADING'),
    (mode: EditorMode.askAi,          icon: Icons.auto_awesome,      label: 'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      //might have to tweak these values later on other devices
      padding: const EdgeInsets.only(top: 4, bottom: 0, left: 16, right:16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _modes.map((m) {
          final isActive = currentMode == m.mode;
          return GestureDetector(
            onTap: () => onModeChanged(m.mode),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m.icon,
                  size: 16,
                  color: isActive ? AppColors.highlight : AppColors.muted,
                ),
                const SizedBox(height: 1),
                Text(
                  m.label,
                  style: TextStyle(
                    color: isActive ? AppColors.highlight : AppColors.muted,
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
