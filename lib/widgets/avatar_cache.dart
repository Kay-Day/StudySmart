import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:studysmart/data/services/mongo_storage_service.dart';


/// Lớp lưu trữ ảnh đại diện trong bộ nhớ để tăng hiệu suất
class AvatarCache {
  static final Map<String, Uint8List> _cache = {};
  static const int _maxCacheSize = 20; // Số lượng ảnh tối đa được lưu trong cache
  
  /// Lấy ảnh từ cache nếu có, nếu không thì tải từ GridFS
  static Future<Uint8List?> getImage(String imageId) async {
    // Kiểm tra cache trước
    if (_cache.containsKey(imageId)) {
      return _cache[imageId];
    }
    
    // Không có trong cache, tải từ GridFS
    final imageData = await MongoStorageService.getImageFromGridFS(imageId);
    
    // Nếu tải thành công, lưu vào cache
    if (imageData != null) {
      _addToCache(imageId, imageData);
    }
    
    return imageData;
  }
  
  /// Thêm ảnh vào cache, loại bỏ các mục cũ nếu cache đầy
  static void _addToCache(String imageId, Uint8List imageData) {
    // Kiểm tra kích thước cache
    if (_cache.length >= _maxCacheSize) {
      // Xóa mục đầu tiên (lâu nhất) nếu cache đầy
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    
    // Thêm vào cache
    _cache[imageId] = imageData;
  }
  
  /// Xóa ảnh khỏi cache nếu có
  static void removeFromCache(String imageId) {
    _cache.remove(imageId);
  }
  
  /// Xóa toàn bộ cache
  static void clearCache() {
    _cache.clear();
  }
}