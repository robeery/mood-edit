
import 'package:image/image.dart' as img;

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