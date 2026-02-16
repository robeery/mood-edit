
import 'dart:math';
import 'package:image/image.dart' as img;
import '../model/color_grading_edit.dart';
import 'color_operations.dart' show rgbToHsl, hslToRgb;

//these functions will be improved in the future
//prototypes
double _zoneWeight(double lum, ColorGradingZone zone) 
{
  const sigma = 50.0;
  switch (zone) {
    case ColorGradingZone.shadows:
      return exp(-(lum * lum) / (2 * sigma * sigma));
    case ColorGradingZone.midtones:
      final d = lum - 128;
      return exp(-(d * d) / (2 * sigma * sigma));
    case ColorGradingZone.highlights:
      final d = lum - 255;
      return exp(-(d * d) / (2 * sigma * sigma));
    case ColorGradingZone.global:
      return 1.0;
  }
}



double _lerpHue(double from, double to, double t) {
  double diff = (to - from) % 360;
  if (diff > 180) diff -= 360;                    
  return (from + diff * t) % 360;
}

img.Image applyColorGrading(img.Image image, List<ColorGradingEdit> edits) {
  final activeEdits = edits.where((e) => !e.isEmpty).toList();
  if (activeEdits.isEmpty) return image;

  final output = img.Image.from(image);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      final lum = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b);

      final hsl = rgbToHsl(r, g, b);
      double h = hsl[0];
      double s = hsl[1];
      final l = hsl[2];

      for (final edit in activeEdits) {
        final w = _zoneWeight(lum, edit.zone);
        final t = w * (edit.strength / 100.0);

        // Blend hue toward the target tint color
        h = _lerpHue(h, edit.hue, t);
        // Boost saturation so the tint becomes visible on neutral pixels.
        

        //t*x, x=30?
        s = (s + t * 80).clamp(0.0, 100.0);
      }

      final rgb = hslToRgb(h, s, l);

      output.setPixel(x, y, img.ColorRgb8(
        rgb[0].clamp(0, 255).toInt(),
        rgb[1].clamp(0, 255).toInt(),
        rgb[2].clamp(0, 255).toInt(),
      ));
    }
  }

  return output;
}
