import 'package:flutter/material.dart';
import '../model/color_edit.dart';

class AppColors {
  static const bg        = Color(0xFF111111);
  static const surface   = Color(0xFF1E1E1E);
  static const accent    = Color(0xFFE0E0E0);
  static const muted     = Color(0xFF555555);
  static const highlight = Color(0xFFFFFFFF);

  static const colorRange = <ColorRange, Color>{
    ColorRange.red:     Color(0xFFFF3B30),
    ColorRange.orange:  Color(0xFFFF9500),
    ColorRange.yellow:  Color(0xFFFFCC00),
    ColorRange.green:   Color(0xFF34C759),
    ColorRange.cyan:    Color(0xFF5AC8FA),
    ColorRange.blue:    Color(0xFF007AFF),
    ColorRange.purple:  Color(0xFFAF52DE),
    ColorRange.magenta: Color(0xFFFF2D55),
  };
}

class AppTextStyles {
  static const screenTitle = TextStyle(
    color: AppColors.highlight,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 4,
  );

  static const sectionLabel = TextStyle(
    color: AppColors.highlight,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 4,
  );

  static const sliderLabel = TextStyle(
    color: AppColors.accent,
    fontSize: 11,
    letterSpacing: 3,
    fontWeight: FontWeight.w500,
  );

  static const sliderValue = TextStyle(
    color: AppColors.highlight,
    fontSize: 13,
    fontWeight: FontWeight.w300,
    letterSpacing: 1,
  );

  static const chipLabel = TextStyle(
    color: AppColors.muted,
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: FontWeight.w600,
  );

  static const mutedSmall = TextStyle(
    color: AppColors.muted,
    fontSize: 10,
    letterSpacing: 2,
  );
}

class AppSliderTheme {
  static SliderThemeData of(BuildContext context) =>
      SliderTheme.of(context).copyWith(
        trackHeight: 1,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: AppColors.highlight,
        inactiveTrackColor: AppColors.muted,
        thumbColor: AppColors.highlight,
        overlayColor: Colors.white12,
      );
}
