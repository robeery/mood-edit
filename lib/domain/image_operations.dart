import 'package:image/image.dart' as img;
import 'dart:math';

//all of these should be improved/modified later in development
//by using better/more complex formulas and more parameters
//prototype operations

img.Image applyExposure(img.Image image, double value) {
  final output = img.Image.from(image);
  final factor = 1.0 + value;

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
  final offset = value * 255;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (pixel.r + offset).clamp(0, 255).toInt();
      final g = (pixel.g + offset).clamp(0, 255).toInt();
      final b = (pixel.b + offset).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}

img.Image applyHighlights(img.Image image, double value) {
  final output = img.Image.from(image);
  final offset = value * 75;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      int _adjust(num channel) {
        if (channel > 180) {
          return (channel + offset).clamp(0, 255).toInt();
        }
        return channel.toInt();
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

img.Image applyShadows(img.Image image, double value) {
  final output = img.Image.from(image);
  final offset = value * 75;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      int _adjust(num channel) {
        if (channel < 75) {
          return (channel + offset).clamp(0, 255).toInt();
        }
        return channel.toInt();
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

img.Image applyContrast(img.Image image, double value) {
  final output = img.Image.from(image);
  final factor = (259 * (value * 255 + 255)) / (255 * (259 - value * 255));

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (factor * (pixel.r - 128) + 128).clamp(0, 255).toInt();
      final g = (factor * (pixel.g - 128) + 128).clamp(0, 255).toInt();
      final b = (factor * (pixel.b - 128) + 128).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, b));
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
  final offset = value * 20;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (pixel.r + offset).clamp(0, 255).toInt();
      final g = (pixel.g - offset).clamp(0, 255).toInt();
      output.setPixel(x, y, img.ColorRgb8(r, g, pixel.b.toInt()));
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

      final adjustment = value * (1 - s) * s;

      final factor = 1.0 + adjustment;

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
  final b = value * 255; // blackpoint threshold

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

      final factor = 1.0 - (value * (dist / maxDist));

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
  final random = Random();
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
  final lift = value * 50;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final r = (pixel.r * (1 - value) + lift).clamp(0, 255).toInt();
      final g = (pixel.g * (1 - value) + lift).clamp(0, 255).toInt();
      final b = (pixel.b * (1 - value) + lift).clamp(0, 255).toInt();

      output.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
  return output;
}