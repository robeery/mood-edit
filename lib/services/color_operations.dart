
import 'package:image/image.dart' as img;
import '../models/color_edit.dart';

// Hue ranges per color
const Map<ColorRange, (double, double)> _colorRanges = {
  ColorRange.red:     (345, 15),
  ColorRange.orange:  (15,  45),
  ColorRange.yellow:  (45,  75),
  ColorRange.green:   (75,  165),
  ColorRange.cyan:    (165, 200),
  ColorRange.blue:    (200, 260),
  ColorRange.purple:  (260, 290),
  ColorRange.magenta: (290, 345),
};

List<double> _rgbToHsl(double r, double g, double b) {
  final max = [r, g, b].reduce((a, b) => a > b ? a : b);
  final min = [r, g, b].reduce((a, b) => a < b ? a : b);
  final delta = max - min;

  double h = 0;
  double s = 0;
  final l = (max + min) / 2;

  if (delta != 0) {
    s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

    if (max == r) {
      h = ((g - b) / delta + (g < b ? 6 : 0)) / 6;
    } else if (max == g) {
      h = ((b - r) / delta + 2) / 6;
    } else {
      h = ((r - g) / delta + 4) / 6;
    }
  }

  return [h * 360, s * 100, l * 100];
}

List<double> _hslToRgb(double h, double s, double l) {
  s /= 100;
  l /= 100;
  h /= 360;

  if (s == 0) return [l * 255, l * 255, l * 255];

  double hue2rgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  final p = 2 * l - q;

  return [
    hue2rgb(p, q, h + 1 / 3) * 255,
    hue2rgb(p, q, h) * 255,
    hue2rgb(p, q, h - 1 / 3) * 255,
  ];
}

bool _isInRange(double hue, ColorRange range) {
  final (min, max) = _colorRanges[range]!;

  
  if (range == ColorRange.red) {
    return hue >= 345 || hue < 15;
  }

  return hue >= min && hue < max;
}

img.Image applyColorEdit(img.Image image, ColorEdit edit) {
  if (edit.isEmpty) return image;

  final output = img.Image.from(image);
  //might have to tweak these values
  final hueShift = edit.hue / 100.0 * 15;       //max +-15
  final satShift = edit.saturation / 100.0 * 50; // max +-50
  final lumShift = edit.luminance / 100.0 * 50;  // max +-50

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      final hsl = _rgbToHsl(r, g, b);
      final h = hsl[0];
      final s = hsl[1];
      final l = hsl[2];

     
      if (!_isInRange(h, edit.range)) {
        continue;
      }

      final newH = (h + hueShift) % 360;
      final newS = (s + satShift).clamp(0.0, 100.0);
      final newL = (l + lumShift).clamp(0.0, 100.0);

      final rgb = _hslToRgb(newH, newS, newL);

      output.setPixel(x, y, img.ColorRgb8(
        rgb[0].clamp(0, 255).toInt(),
        rgb[1].clamp(0, 255).toInt(),
        rgb[2].clamp(0, 255).toInt(),
      ));
    }
  }

  return output;
}