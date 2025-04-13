import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FileHelper {
  // Lấy đường dẫn thư mục lưu trữ tài liệu
  static Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final documentsPath = '${directory.path}/documents';
    
    // Tạo thư mục nếu chưa tồn tại
    final dir = Directory(documentsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return documentsPath;
  }
  
  // Lưu file vào thư mục lưu trữ
  static Future<String?> saveFile(File file, String fileName) async {
    try {
      final documentsPath = await getDocumentsDirectory();
      final filePath = '$documentsPath/$fileName';
      
      // Lưu file
      await file.copy(filePath);
      
      return filePath;
    } catch (e) {
      print('Lỗi khi lưu file: $e');
      return null;
    }
  }
  
  // Xóa file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi xóa file: $e');
      return false;
    }
  }
  
  // Kiểm tra file tồn tại
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('Lỗi khi kiểm tra file: $e');
      return false;
    }
  }
  
  // Lấy kích thước file (đơn vị byte)
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Lỗi khi lấy kích thước file: $e');
      return 0;
    }
  }
  
  // Chọn file từ thiết bị
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return File(path);
        }
      }
      
      return null;
    } catch (e) {
      print('Lỗi khi chọn file: $e');
      return null;
    }
  }
  
  // Chuyển đổi kích thước file sang dạng đọc được
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
      return '$gb GB';
    }
  }
  
  // Lấy loại file từ đuôi file
  static String getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Word';
      case 'xls':
      case 'xlsx':
        return 'Excel';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint';
      case 'txt':
        return 'Text';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image';
      case 'mp3':
      case 'wav':
      case 'ogg':
        return 'Audio';
      case 'mp4':
      case 'avi':
      case 'mkv':
        return 'Video';
      default:
        return extension.toUpperCase();
    }
  }
}