import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PendingEditsBar extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onDiscard;

  const PendingEditsBar({super.key, required this.onApply, required this.onDiscard});

  @override
  Widget build(BuildContext context) {
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
            onTap: onDiscard,
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
            onTap: onApply,
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
}
