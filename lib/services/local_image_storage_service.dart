import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalImageStorageService {
  static final LocalImageStorageService _instance =
      LocalImageStorageService._internal();
  factory LocalImageStorageService() => _instance;
  LocalImageStorageService._internal();

  Future<String> saveImage(
    File imageFile,
    String userId,
    String imageType,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final imagesDir = Directory('${directory.path}/images/$userId');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final filename = '${imageType}_$timestamp$extension';
      final localPath = '${imagesDir.path}/$filename';

      final savedImage = await imageFile.copy(localPath);

      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  File? getImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final file = File(imagePath);
    return file.existsSync() ? file : null;
  }

  Future<void> clearUserImages(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userImagesDir = Directory('${directory.path}/images/$userId');

      if (await userImagesDir.exists()) {
        await userImagesDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing user images: $e');
    }
  }

  Future<int> getUserImageSize(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userImagesDir = Directory('${directory.path}/images/$userId');

      if (!await userImagesDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in userImagesDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('Error getting image size: $e');
      return 0;
    }
  }
}
