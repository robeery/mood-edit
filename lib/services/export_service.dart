import 'dart:typed_data';
import 'package:saver_gallery/saver_gallery.dart';

class ExportService {
  Future<void> saveToGallery(Uint8List imageBytes) async {
    final result = await SaverGallery.saveImage(
      imageBytes,
      fileName: 'edited_${DateTime.now().millisecondsSinceEpoch}.jpg',
      androidRelativePath: 'Pictures/Licenta',
      skipIfExists: false,
    );

    if (!result.isSuccess) {
      throw Exception('Failed to save image');
    }
  }
}
