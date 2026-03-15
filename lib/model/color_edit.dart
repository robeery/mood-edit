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

  ColorEdit({
    required this.range,
    double hue = 0,
    double saturation = 0,
    double luminance = 0,
  })  : hue = hue.round().toDouble(),
        saturation = saturation.round().toDouble(),
        luminance = luminance.round().toDouble();

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

  Map<String, dynamic> toJson() => {
        'range': range.name,
        'hue': hue,
        'saturation': saturation,
        'luminance': luminance,
      };
      
  //debug purposes
  @override
  String toString() =>
      'ColorEdit(${range.name}: H=$hue, S=$saturation, L=$luminance)';
}