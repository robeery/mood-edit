import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../viewmodel/editor_viewmodel.dart';

class EditorDrawer extends StatelessWidget {
  final EditorViewModel vm;
  final VoidCallback onPickImage;

  const EditorDrawer({super.key, required this.vm, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
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
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.accent, size: 20),
              title: const Text(
                'OPEN NEW PICTURE',
                style: TextStyle(color: AppColors.accent, fontSize: 11, letterSpacing: 2),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onPickImage();
              },
            ),
            const Divider(color: AppColors.muted, height: 1),
            ExpansionTile(
              iconColor: AppColors.accent,
              collapsedIconColor: AppColors.muted,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                'OPERATIONS',
                style: const TextStyle(color: AppColors.accent, fontSize: 11, letterSpacing: 2),
              ),
              children: [
                _buildModeTile(context, Icons.tune, 'BASIC OPERATIONS', EditorMode.basic),
                _buildModeTile(context, Icons.palette_outlined, 'SELECTIVE COLOR', EditorMode.selectiveColor),
                _buildModeTile(context, Icons.gradient_outlined, 'COLOR GRADING', EditorMode.colorGrading),
              ],
            ),
            const Divider(color: AppColors.muted, height: 1),
            ListTile(
              leading: Icon(
                Icons.auto_awesome,
                color: vm.editorMode == EditorMode.askAi ? AppColors.highlight : AppColors.accent,
                size: 20,
              ),
              title: Text(
                'ASK AI',
                style: TextStyle(
                  color: vm.editorMode == EditorMode.askAi ? AppColors.highlight : AppColors.accent,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              onTap: () {
                vm.setEditorMode(EditorMode.askAi);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile(BuildContext context, IconData icon, String label, EditorMode mode) {
    final isActive = vm.editorMode == mode;
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
        vm.setEditorMode(mode);
        Navigator.of(context).pop();
      },
    );
  }
}
