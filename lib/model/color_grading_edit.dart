
enum ColorGradingZone { shadows, midtones, highlights, global }

class ColorGradingEdit {
  final ColorGradingZone zone;
  final double hue;       // 0-360 -> target tint color in degrees
  final double strength;  // 0-100 -> how strongly the tint is applied

  const ColorGradingEdit({
    required this.zone,
    this.hue = 0,
    this.strength = 0,
  });

  ColorGradingEdit copyWith({
    double? hue,
    double? strength,
  }) {
    return ColorGradingEdit(
      zone: zone,
      hue: hue ?? this.hue,
      strength: strength ?? this.strength,
    );
  }

  bool get isEmpty => strength.abs() < 0.001;

  //debug purposes
  @override
  String toString() =>
      'ColorGradingEdit(${zone.name}: H=$hue°, S=$strength%)';
}
