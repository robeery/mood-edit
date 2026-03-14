import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
class EditorDrawer extends StatelessWidget {
  final VoidCallback onPickImage;

  const EditorDrawer({super.key, required this.onPickImage});

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
          ],
        ),
      ),
    );
  }
}
