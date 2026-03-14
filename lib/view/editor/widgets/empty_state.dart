import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onPickImage;

  const EmptyState({super.key, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPickImage,
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
}
