import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  static Future<String?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Show dialog to choose image source
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await pickFromGallery();
                  if (context.mounted && path != null) {
                    Navigator.pop(context, path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await pickFromCamera();
                  if (context.mounted && path != null) {
                    Navigator.pop(context, path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
