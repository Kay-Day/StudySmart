import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();
  
  // Chọn ảnh từ thư viện
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      
      return null;
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      return null;
    }
  }
  
  // Chụp ảnh mới bằng camera
  static Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      
      return null;
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
      return null;
    }
  }
  
  // Lưu ảnh vào thư mục ứng dụng
  static Future<String?> saveProfileImage(File imageFile, String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profileImagesPath = '${appDir.path}/profile_images';
      
      // Tạo thư mục nếu chưa tồn tại
      final Directory profileImagesDir = Directory(profileImagesPath);
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }
      
      // Tạo tên file duy nhất
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final String filePath = '$profileImagesPath/$fileName';
      
      // Sao chép file vào thư mục ứng dụng
      final File savedFile = await imageFile.copy(filePath);
      
      return savedFile.path;
    } catch (e) {
      print('Lỗi khi lưu ảnh đại diện: $e');
      return null;
    }
  }
  
  // Xóa ảnh đại diện cũ nếu cần
  static Future<bool> deleteProfileImage(String? imagePath) async {
    if (imagePath == null) return true;
    
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      print('Lỗi khi xóa ảnh đại diện: $e');
      return false;
    }
  }
}