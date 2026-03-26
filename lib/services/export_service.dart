import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import '../model/export_settings.dart';

class ExportService {
  Future<void> saveToGallery(Uint8List imageBytes, ExportSettings settings) async {
    final encoded = _encode(imageBytes, settings);
    final name = 'edited_${DateTime.now().millisecondsSinceEpoch}.${settings.format.extension}';
    await Gal.putImageBytes(encoded, name: name);
  }

  Uint8List _encode(Uint8List imageBytes, ExportSettings settings) {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    switch (settings.format) {
      case ImageFormat.jpg:
        return Uint8List.fromList(img.encodeJpg(image, quality: settings.quality));
      case ImageFormat.png:
        return Uint8List.fromList(img.encodePng(image));
    }
  }
}
