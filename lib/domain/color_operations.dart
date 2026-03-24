import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../model/color_edit.dart';

//each range defined as (center, halfWidth) in degrees
//boundaries roughly aligned to Lightroom HSL ranges
const Map<ColorRange, (double, double)> _colorRangeParams = {
  ColorRange.red:     (0,   15),
  ColorRange.orange:  (30,  15),
  ColorRange.yellow:  (60,  15),
  ColorRange.green:   (112, 38),
  ColorRange.cyan:    (172, 18),   // core ends at 190, fades to 200
  ColorRange.blue:    (225, 30),   // core starts at 195, sky (200+) lands here
  ColorRange.purple:  (270, 15),
  ColorRange.magenta: (315, 30),
};

List<double> rgbToHsl(double r, double g, double b) {
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

List<double> hslToRgb(double h, double s, double l) {
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
//raised cosine weight: 1.0 inside core, smooth fade at edges, 0 outside
const double _fadeWidth = 10.0;

double _hueWeight(double hue, ColorRange range, [double fade = _fadeWidth]) {
  final (center, halfWidth) = _colorRangeParams[range]!;
  double dist = (hue - center).abs();
  if (dist > 180) dist = 360 - dist;

  if (dist <= halfWidth) return 1.0;
  if (dist >= halfWidth + fade) return 0.0;

  //cosine fade in the transition zone
  final t = (dist - halfWidth) / fade;
  return 0.5 * (1.0 + cos(t * pi));
}

//box blur on a flat array, averages available neighbors at edges
Float64List _boxBlur(Float64List data, int w, int h, int radius) {
  final out = Float64List(w * h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      double sum = 0;
      int count = 0;
      for (int dy = -radius; dy <= radius; dy++) {
        final ny = y + dy;
        if (ny < 0 || ny >= h) continue;
        for (int dx = -radius; dx <= radius; dx++) {
          final nx = x + dx;
          if (nx < 0 || nx >= w) continue;
          sum += data[ny * w + nx];
          count++;
        }
      }
      out[y * w + x] = sum / count;
    }
  }
  return out;
}

//applies all color edits in one go with pre-smoothed hue/sat and blurred luminance
img.Image applyAllColorEdits(img.Image image, List<ColorEdit> edits) {
  final activeEdits = edits.where((e) => !e.isEmpty).toList();
  if (activeEdits.isEmpty) return image;

  final output = img.Image.from(image);
  final w = image.width;
  final h = image.height;
  final n = w * h;

  //precompute shift values
  final shifts = activeEdits.map((e) => (
    range: e.range,
    hue: e.hue / 100.0 * 40,
    sat: e.saturation / 100.0 * 50,
    lum: e.luminance / 100.0 * 30,
  )).toList();

  //pre-processing: smooth out hue and saturation across neighbors
  //hue is decomposed into cos/sin to handle the 360 wraparound correctly
  final hueCos = Float64List(n);
  final hueSin = Float64List(n);
  final rawSat = Float64List(n);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final pixel = image.getPixel(x, y);
      final hsl = rgbToHsl(pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0);
      final hRad = hsl[0] * pi / 180.0;
      final idx = y * w + x;
      hueCos[idx] = cos(hRad);
      hueSin[idx] = sin(hRad);
      rawSat[idx] = hsl[1];
    }
  }

  //9x9 blur on hue components and saturation
  final blurCos = _boxBlur(hueCos, w, h, 4);
  final blurSin = _boxBlur(hueSin, w, h, 4);
  final smoothSat = _boxBlur(rawSat, w, h, 4);

  //recover smoothed hue from blurred cos/sin
  final smoothHue = Float64List(n);
  for (int i = 0; i < n; i++) {
    var deg = atan2(blurSin[i], blurCos[i]) * 180.0 / pi;
    if (deg < 0) deg += 360.0;
    smoothHue[i] = deg;
  }

  //pass 1: compute per-pixel luminance delta using smoothed hue/sat
  final lumDeltas = Float64List(n);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final pixel = image.getPixel(x, y);
      final hsl = rgbToHsl(pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0);
      final l = hsl[2];

      final idx = y * w + x;
      final sHue = smoothHue[idx];
      final sSat = smoothSat[idx];

      final satGate = (sSat / 30.0).clamp(0.0, 1.0);

      double totalLum = 0;
      double totalLumW = 0;

      for (final shift in shifts) {
        final baseLumW = _hueWeight(sHue, shift.range, 15.0);
        final gate = shift.lum >= 0
            ? (sSat / 50.0).clamp(0.0, 1.0)
            : satGate;
        final lumW = baseLumW * gate;
        if (lumW > 0.01) {
          totalLum += shift.lum * lumW;
          totalLumW += lumW;
        }
      }

      if (totalLumW > 1.0) totalLum /= totalLumW;

      //soft power curve to compute the final delta
      double newL;
      if (totalLum >= 0) {
        final t = l / 100.0;
        final shifted = t + totalLum / 100.0 * (1 - t * t);
        newL = shifted.clamp(0.0, 1.0) * 100.0;
      } else {
        final t = l / 100.0;
        final shifted = t + totalLum / 100.0 * (t * (2 - t));
        newL = shifted.clamp(0.0, 1.0) * 100.0;
      }

      lumDeltas[idx] = newL - l;
    }
  }

  //pass 2: 5x5 blur the luminance deltas
  final blurredLum = _boxBlur(lumDeltas, w, h, 2);

  //pass 3: apply hue/sat (using smoothed values) + blurred luminance
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final pixel = image.getPixel(x, y);

      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      final hsl = rgbToHsl(r, g, b);
      final l = hsl[2];

      final idx = y * w + x;
      final sHue = smoothHue[idx];
      final sSat = smoothSat[idx];

      final satGate = (sSat / 30.0).clamp(0.0, 1.0);

      double totalHue = 0;
      double totalSat = 0;
      double maxW = 0;

      for (final shift in shifts) {
        final wt = _hueWeight(sHue, shift.range) * satGate;
        if (wt > 0.01) {
          totalHue += shift.hue * wt;
          totalSat += shift.sat * wt;
          if (wt > maxW) maxW = wt;
        }
      }

      final lumDelta = blurredLum[idx];
      if (maxW <= 0.01 && lumDelta.abs() <= 0.01) continue;

      final newH = (sHue + totalHue) % 360;
      final newS = (hsl[1] + totalSat).clamp(0.0, 100.0);
      final newL = (l + lumDelta).clamp(0.0, 100.0);

      final rgb = hslToRgb(newH, newS, newL);

      output.setPixel(x, y, img.ColorRgb8(
        rgb[0].clamp(0, 255).toInt(),
        rgb[1].clamp(0, 255).toInt(),
        rgb[2].clamp(0, 255).toInt(),
      ));
    }
  }

  return output;
}