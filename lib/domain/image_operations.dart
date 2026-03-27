import 'package:image/image.dart' as img;
import 'dart:math';
import 'color_operations.dart' show rgbToHsl, hslToRgb;

//all of these should be improved/modified later in development
//by using better/more complex formulas and more parameters
//prototype operations

img.Image applyExposure(img.Image image, double value) {
  final output = img.Image.from(image);
  //EV stops: +1 = 2x light, -1 = 0.5x, like a real camera
  final factor = pow(2.0, value).toDouble();

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (pixel.r * factor).clamp(0, 255).toInt();
      final g = (pixel.g * factor).clamp(0, 255).toInt();
      final b = (pixel.b * factor).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

img.Image applyBrightness(img.Image image, double value) {
  final output = img.Image.from(image);
  //gamma curve: <1 brightens, >1 darkens, preserves black and white
  final gamma = pow(2.0, -value).toDouble();

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (pow(pixel.r / 255.0, gamma) * 255).clamp(0, 255).toInt();
      final g = (pow(pixel.g / 255.0, gamma) * 255).clamp(0, 255).toInt();
      final b = (pow(pixel.b / 255.0, gamma) * 255).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

img.Image applyHighlights(img.Image image, double value) {
  final output = img.Image.from(image);
  value *= 0.7;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final lum = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;

      //smooth weight: 0 below midtones, ramps up through highlights
      final w = ((lum - 0.4) / 0.6).clamp(0.0, 1.0);
      //squared for softer onset, stronger at the top
      final strength = w * w * value;

      final r = (pixel.r + pixel.r * strength).clamp(0, 255).toInt();
      final g = (pixel.g + pixel.g * strength).clamp(0, 255).toInt();
      final b = (pixel.b + pixel.b * strength).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

img.Image applyShadows(img.Image image, double value) {
  final output = img.Image.from(image);
  value *= 0.7;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final lum = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;

      //smooth weight: 0 above midtones, ramps up into shadows
      final w = ((0.6 - lum) / 0.6).clamp(0.0, 1.0);
      final strength = w * w * value;

      //positive: lift shadows using gamma curve (like brightness)
      //negative: crush shadows using gamma curve
      final gamma = pow(2.0, -strength).toDouble();
      final r = (pow(pixel.r / 255.0, gamma) * 255).clamp(0, 255).toInt();
      final g = (pow(pixel.g / 255.0, gamma) * 255).clamp(0, 255).toInt();
      final b = (pow(pixel.b / 255.0, gamma) * 255).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

img.Image applyContrast(img.Image image, double value) {
  final contrast = value.clamp(-1.0, 1.0);
  final output = img.Image.from(image);
  if (contrast == 0.0) return output;

  //note to self:
  //maybe, in the future, implement a LUT to other functions as well
  
  //piecewise S-curve via power function, pre-baked into a LUT
  final gamma = pow(2.0, contrast);
  final lut = List<int>.filled(256, 0);
  for (int i = 0; i < 256; i++) {
    final t = i / 255.0;
    final adjusted = t < 0.5
        ? 0.5 * pow(2.0 * t, gamma)
        : 1.0 - 0.5 * pow(2.0 * (1.0 - t), gamma);
    lut[i] = (adjusted * 255).clamp(0, 255).toInt();
  }

  //apply via luminance ratio to preserve color balance
  for (final pixel in output) {
    final num r = pixel.r;
    final num g = pixel.g;
    final num b = pixel.b;

    final double lum = 0.299 * r + 0.587 * g + 0.114 * b;
    final int lumInt = lum.round().clamp(0, 255);

    if (lumInt > 0) {
      final double ratio = lut[lumInt] / lum;
      pixel.r = (r * ratio).round().clamp(0, 255);
      pixel.g = (g * ratio).round().clamp(0, 255);
      pixel.b = (b * ratio).round().clamp(0, 255);
    }
  }

  return output;
}

img.Image applyWarmth(img.Image image, double value) {
  final output = img.Image.from(image);
  final offset = value * 20;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (pixel.r + offset).clamp(0, 255).toInt();
      final b = (pixel.b - offset).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, pixel.g.toInt(), b));
    }
  }
  return output;
}

img.Image applyTint(img.Image image, double value) {
  final output = img.Image.from(image);
  //green-magenta axis: +tint = magenta (R+ G- B+), -tint = green (R- G+ B-)
  final offset = value * 15;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (pixel.r + offset).clamp(0, 255).toInt();
      final g = (pixel.g - offset * 1.5).clamp(0, 255).toInt();
      final b = (pixel.b + offset).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

img.Image applySharpness(img.Image image, double value) {
  final kernel = [
    0.0, -value, 0.0,
    -value, 1.0 + 4 * value, -value,
    0.0, -value, 0.0,
  ];

  return img.convolution(image, filter: kernel);
}


img.Image applyDefinition(img.Image image, double value) {
  
  final blurred = img.gaussianBlur(img.Image.from(image), radius: 5);
  final output = img.Image.from(image);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final orig = image.getPixel(x, y);
      final blur = blurred.getPixel(x, y);

      final r = (orig.r + (orig.r - blur.r) * value).clamp(0, 255).toInt();
      final g = (orig.g + (orig.g - blur.g) * value).clamp(0, 255).toInt();
      final b = (orig.b + (orig.b - blur.b) * value).clamp(0, 255).toInt();

      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}


img.Image applySaturation(img.Image image, double value) {
  final output = img.Image.from(image);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final hsl = rgbToHsl(pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0);
      //asymmetric: -100 fully desaturates, +100 gives a moderate boost
      final shift = value > 0 ? value * 40 : value * 100;
      final newS = (hsl[1] + shift).clamp(0.0, 100.0);
      final rgb = hslToRgb(hsl[0], newS, hsl[2]);

      output.setPixel(x, y, img.ColorRgb8(
        rgb[0].clamp(0, 255).toInt(),
        rgb[1].clamp(0, 255).toInt(),
        rgb[2].clamp(0, 255).toInt(),
      ));
    }
  }
  return output;
}

img.Image applyVibrance(img.Image image, double value) {
  final output = img.Image.from(image);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      final max = [r, g, b].reduce((a, b) => a > b ? a : b);
      final min = [r, g, b].reduce((a, b) => a < b ? a : b);
      final s = max == 0 ? 0.0 : (max - min) / max;

      //boost inversely proportional to existing saturation
      final factor = 1.0 + value * (1.0 - s);

      final mid = (r + g + b) / 3.0;
      final nr = (mid + (r - mid) * factor).clamp(0.0, 1.0);
      final ng = (mid + (g - mid) * factor).clamp(0.0, 1.0);
      final nb = (mid + (b - mid) * factor).clamp(0.0, 1.0);

      output.setPixel(x, y, img.ColorRgb8(
        (nr * 255).toInt(),
        (ng * 255).toInt(),
        (nb * 255).toInt(),
      ));
    }
  }
  return output;
}

img.Image applyBlackpoint(img.Image image, double value) {
  final output = img.Image.from(image);
  final b = value * 60; // max threshold ~60, not 255

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      int _adjust(num channel) {
        if (channel <= b) return 0;
        return ((channel - b) * (255 / (255 - b))).clamp(0, 255).toInt();
      }

      output.setPixel(x, y, img.ColorRgb8(
        _adjust(pixel.r),
        _adjust(pixel.g),
        _adjust(pixel.b),
      ));
    }
  }
  return output;
}

img.Image applyVignette(img.Image image, double value) {
  final output = img.Image.from(image);
  final centerX = image.width / 2;
  final centerY = image.height / 2;
  final maxDist = sqrt(centerX * centerX + centerY * centerY);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final dx = x - centerX;
      final dy = y - centerY;
      final dist = sqrt(dx * dx + dy * dy);

      final d = dist / maxDist;
      final factor = 1.0 - (value * d * d);

      final r = (pixel.r * factor).clamp(0, 255).toInt();
      final g = (pixel.g * factor).clamp(0, 255).toInt();
      final b = (pixel.b * factor).clamp(0, 255).toInt();

      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

//gaussian blur for now
img.Image applyNoiseReduction(img.Image image, double value) {
  final radius = (value * 3).round().clamp(1, 3);
  return img.gaussianBlur(image, radius: radius);
}

img.Image applyGrain(img.Image image, double value) {
  final output = img.Image.from(image);
  final random = Random(42);
  final intensity = value * 80;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final noise = (random.nextDouble() * 2 - 1) * intensity;

      final r = (pixel.r + noise).clamp(0, 255).toInt();
      final g = (pixel.g + noise).clamp(0, 255).toInt();
      final b = (pixel.b + noise).clamp(0, 255).toInt();

      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

img.Image applyFade(img.Image image, double value) {
  final output = img.Image.from(image);
  //fade lifts shadows and slightly desaturates, like a film wash
  final strength = value * 0.4;
  final lift = strength * 80;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final r = (pixel.r * (1 - strength) + lift).clamp(0, 255).toInt();
      final g = (pixel.g * (1 - strength) + lift).clamp(0, 255).toInt();
      final b = (pixel.b * (1 - strength) + lift).clamp(0, 255).toInt();

      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}