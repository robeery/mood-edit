enum ColorRange {
  red,
  orange,
  yellow,
  green,
  cyan,
  blue,
  purple,
  magenta,
}

class ColorEdit {
  final ColorRange range;
  final double hue;
  final double saturation;
  final double luminance;

  const ColorEdit({
    required this.range,
    this.hue = 0,
    this.saturation = 0,
    this.luminance = 0,
  });

  ColorEdit copyWith({
    double? hue,
    double? saturation,
    double? luminance,
  }) {
    return ColorEdit(
      range: range,
      hue: hue ?? this.hue,
      saturation: saturation ?? this.saturation,
      luminance: luminance ?? this.luminance,
    );
  }

  bool get isEmpty =>
      hue.abs() < 0.001 &&
      saturation.abs() < 0.001 &&
      luminance.abs() < 0.001;

  @override
  String toString() =>
      'ColorEdit(${range.name}: H=$hue, S=$saturation, L=$luminance)';
}