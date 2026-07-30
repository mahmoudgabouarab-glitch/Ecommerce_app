import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'app_colors.dart';

class ImageCropHelper {
  static Future<String?> cropSquare(String sourcePath) => _crop(
        sourcePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        lock: true,
      );

  static Future<String?> cropFree(String sourcePath) => _crop(sourcePath);

  static Future<String?> _crop(
    String sourcePath, {
    CropAspectRatio? aspectRatio,
    bool lock = false,
  }) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: aspectRatio,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          lockAspectRatio: lock,
        ),
        IOSUiSettings(
          title: 'Crop image',
          aspectRatioLockEnabled: lock,
          resetAspectRatioEnabled: !lock,
        ),
      ],
    );

    return cropped?.path;
  }
}
