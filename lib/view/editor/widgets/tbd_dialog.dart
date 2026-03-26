import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

void showTbdDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: const Text('COMING SOON  :)', style: AppTextStyles.screenTitle),
      content: const Text(
        'This feature is yet to be developed.',
        style: TextStyle(color: AppColors.accent, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text(
            'OK',
            style: TextStyle(color: AppColors.highlight, fontSize: 11, letterSpacing: 2),
          ),
        ),
      ],
    ),
  );
}
