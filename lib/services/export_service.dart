import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:saver_gallery/saver_gallery.dart';
import '../model/export_settings.dart';

class ExportService {
  Future<void> saveToGallery(Uint8List imageBytes, ExportSettings settings) async {
    final encoded = _encode(imageBytes, settings);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final result = await SaverGallery.saveImage(
      encoded,
      fileName: 'edited_$timestamp.${settings.format.extension}',
      androidRelativePath: 'Pictures/Licenta',
      skipIfExists: false,
    );

    if (!result.isSuccess) {
      throw Exception('Failed to save image');
    }
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
