
enum ColorGradingZone { shadows, midtones, highlights, global }

class ColorGradingEdit {
  final ColorGradingZone zone;
  final double hue;        // 0-360 -> target tint color in degrees
  final double strength;   // 0-100 -> how strongly the tint is applied
  final double luminance;  // -100..+100 -> brighten/darken this zone

  const ColorGradingEdit({
    required this.zone,
    this.hue = 0,
    this.strength = 0,
    this.luminance = 0,
  });

  ColorGradingEdit copyWith({
    double? hue,
    double? strength,
    double? luminance,
  }) {
    return ColorGradingEdit(
      zone: zone,
      hue: hue ?? this.hue,
      strength: strength ?? this.strength,
      luminance: luminance ?? this.luminance,
    );
  }

  bool get isEmpty => strength.abs() < 0.001 && luminance.abs() < 0.001;

  Map<String, dynamic> toJson() => {
        'zone': zone.name,
        'hue': hue,
        'strength': strength,
        'luminance': luminance,
      };

  //debug purposes
  @override
  String toString() =>
      'ColorGradingEdit(${zone.name}: H=$hue°, S=$strength%, L=$luminance)';
}
