// import 'dart:typed_data';
// import 'package:mongo_dart/mongo_dart.dart';
// import 'package:studysmart/config/mongo_db.dart';


// class MongoStorageService {
//   static const String bucketName = 'avatars';
  
//   // Lấy ảnh từ MongoDB sử dụng GridFS
//   static Future<Uint8List?> getImageFromGridFS(String imageId) async {
//     try {
//       final db = MongoDatabase.db;
//       final GridFS gridFS = GridFS(db, bucketName);
      
//       // Tìm file theo ID
//       final ObjectId id = ObjectId.parse(imageId);
//       final file = await gridFS.findOne(where.id(id));
      
//       if (file != null) {
//         return await gridFS.readFile(file);
//       }
      
//       return null;
//     } catch (e) {
//       print('Lỗi khi lấy ảnh từ MongoDB: $e');
//       return null;
//     }
//   }
  
//   // Lưu dữ liệu nhị phân vào GridFS và trả về Object ID
//   static Future<ObjectId?> storeImageBytes(
//     Uint8List imageBytes, 
//     String fileName, 
//     Map<String, dynamic> metadata
//   ) async {
//     try {
//       final db = MongoDatabase.db;
//       final GridFS gridFS = GridFS(db, bucketName);
      
//       // Lưu vào GridFS
//       return await gridFS.writeFile(
//         imageBytes,
//         fileName,
//         metadata: metadata,
//       );
//     } catch (e) {
//       print('Lỗi khi lưu dữ liệu vào GridFS: $e');
//       return null;
//     }
//   }
  
//   // Xóa file từ GridFS
//   static Future<bool> deleteFile(ObjectId fileId) async {
//     try {
//       final db = MongoDatabase.db;
//       final GridFS gridFS = GridFS(db, bucketName);
      
//       await gridFS.deleteFile(fileId);
//       return true;
//     } catch (e) {
//       print('Lỗi khi xóa file từ GridFS: $e');
//       return false;
//     }
//   }
// }

import 'dart:typed_data';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:studysmart/config/mongo_db.dart';

class MongoStorageService {
  static const String bucketName = 'avatars';
  
  // Lấy ảnh từ MongoDB sử dụng GridFS
  static Future<Uint8List?> getImageFromGridFS(String imageId) async {
    try {
      final db = MongoDatabase.db;
      final gridFS = GridFS(db, bucketName);
      
      // Tìm file theo ID
      final ObjectId id = ObjectId.parse(imageId);
      final file = await gridFS.findOne(where.id(id));
      
      if (file != null) {
        // Use chunks() method to get file data
        final chunks = await gridFS.chunks.find(where.eq('files_id', id)).toList();
        if (chunks.isNotEmpty) {
          // Combine all chunks into a single Uint8List
          final List<int> allBytes = [];
          for (var chunk in chunks) {
            final Uint8List chunkData = chunk['data'];
            allBytes.addAll(chunkData);
          }
          return Uint8List.fromList(allBytes);
        }
      }
      
      return null;
    } catch (e) {
      print('Lỗi khi lấy ảnh từ MongoDB: $e');
      return null;
    }
  }
  
  // Lưu dữ liệu nhị phân vào GridFS và trả về Object ID
  static Future<ObjectId?> storeImageBytes(
    Uint8List imageBytes, 
    String fileName, 
    Map<String, dynamic> metadata
  ) async {
    try {
      final db = MongoDatabase.db;
      final gridFS = GridFS(db, bucketName);
      
      // Create a file metadata document
      final fileId = ObjectId();
      final now = DateTime.now();
      final Map<String, dynamic> fileDoc = {
        '_id': fileId,
        'filename': fileName,
        'contentType': 'image/jpeg',
        'length': imageBytes.length,
        'chunkSize': 261120, // Default chunk size
        'uploadDate': now,
        'metadata': metadata
      };
      
      // Insert file document
      await gridFS.files.insert(fileDoc);
      
      // Split data into chunks and insert them
      const int chunkSize = 261120; // 255kb
      final int totalChunks = (imageBytes.length / chunkSize).ceil();
      
      for (int i = 0; i < totalChunks; i++) {
        final int start = i * chunkSize;
        final int end = (start + chunkSize > imageBytes.length) 
          ? imageBytes.length 
          : start + chunkSize;
        
        final Uint8List chunkData = imageBytes.sublist(start, end);
        
        final Map<String, dynamic> chunk = {
          'files_id': fileId,
          'n': i,
          'data': chunkData
        };
        
        await gridFS.chunks.insert(chunk);
      }
      
      return fileId;
    } catch (e) {
      print('Lỗi khi lưu dữ liệu vào GridFS: $e');
      return null;
    }
  }
  
  // Xóa file từ GridFS
  static Future<bool> deleteFile(ObjectId fileId) async {
    try {
      final db = MongoDatabase.db;
      final gridFS = GridFS(db, bucketName);
      
      // Delete file document
      await gridFS.files.remove(where.id(fileId));
      
      // Delete all chunks for this file
      await gridFS.chunks.remove(where.eq('files_id', fileId));
      
      return true;
    } catch (e) {
      print('Lỗi khi xóa file từ GridFS: $e');
      return false;
    }
  }
}