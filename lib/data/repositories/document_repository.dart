import 'package:mongo_dart/mongo_dart.dart';
import '../models/document.dart';
import '../../config/mongo_db.dart';

class DocumentRepository {
  static const String collectionName = 'documents';

  Future<List<Document>> getDocumentsByUserId(ObjectId userId, {int limit = 50}) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      // Tạo query đơn giản
      final query = {'userId': userId};
      
      // Tìm kiếm và xử lý thủ công sau đó
      final maps = await collection.find(query).toList();
      
      // Sắp xếp thủ công trong Dart
      final documents = maps.map((map) => Document.fromMap(map)).toList();
      documents.sort((a, b) => b.uploadDate.compareTo(a.uploadDate)); // Sắp xếp giảm dần
      
      // Áp dụng giới hạn
      if (documents.length > limit) {
        return documents.sublist(0, limit);
      }
      
      return documents;
    } catch (e) {
      print('Lỗi khi lấy danh sách tài liệu: $e');
      return [];
    }
  }

  Future<List<Document>> getDocumentsBySubject(ObjectId subjectId, {int limit = 50}) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final query = {'subjectId': subjectId};
      
      final maps = await collection.find(query).toList();
      
      // Sắp xếp thủ công trong Dart
      final documents = maps.map((map) => Document.fromMap(map)).toList();
      documents.sort((a, b) => b.uploadDate.compareTo(a.uploadDate)); // Sắp xếp giảm dần
      
      // Áp dụng giới hạn
      if (documents.length > limit) {
        return documents.sublist(0, limit);
      }
      
      return documents;
    } catch (e) {
      print('Lỗi khi lấy danh sách tài liệu theo môn: $e');
      return [];
    }
  }

  Future<List<Document>> searchDocuments(ObjectId userId, String searchTerm) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      
      // Tạo query với điều kiện tìm kiếm
      final query = {
        'userId': userId,
        '\$or': [
          {'title': {'\$regex': searchTerm, '\$options': 'i'}},
          {'fileName': {'\$regex': searchTerm, '\$options': 'i'}},
          {'tags': {'\$regex': searchTerm, '\$options': 'i'}}
        ]
      };
      
      // Thực hiện truy vấn cơ bản
      final maps = await collection.find(query).toList();
      
      // Sắp xếp kết quả trong Dart
      final documents = maps.map((map) => Document.fromMap(map)).toList();
      documents.sort((a, b) => b.uploadDate.compareTo(a.uploadDate)); // Sắp xếp giảm dần
      
      return documents;
    } catch (e) {
      print('Lỗi khi tìm kiếm tài liệu: $e');
      return [];
    }
  }

  Future<Document?> getDocumentById(ObjectId id) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne({'_id': id});
      if (map != null) {
        return Document.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin tài liệu: $e');
      return null;
    }
  }

  Future<Document?> createDocument(Document document) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      await collection.insert(document.toMap());
      return document;
    } catch (e) {
      print('Lỗi khi tạo tài liệu mới: $e');
      return null;
    }
  }

  Future<Document?> updateDocument(Document document) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      await collection.update(
        {'_id': document.id},
        document.toMap(),
      );
      
      return document;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin tài liệu: $e');
      return null;
    }
  }

  Future<bool> updateLastAccessDate(ObjectId documentId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.update(
        {'_id': documentId},
        {'\$set': {'lastAccessDate': DateTime.now()}},
      );
      
      return result['ok'] == 1;
    } catch (e) {
      print('Lỗi khi cập nhật ngày truy cập: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(ObjectId documentId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.remove({'_id': documentId});
      return result['ok'] == 1;
    } catch (e) {
      print('Lỗi khi xóa tài liệu: $e');
      return false;
    }
  }

  Future<Map<String, int>> getDocumentCountsByType(ObjectId userId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      
      // Truy vấn đơn giản và xử lý thủ công
      final maps = await collection.find({'userId': userId}).toList();
      
      Map<String, int> typeCountMap = {};
      for (var doc in maps) {
        final fileType = doc['fileType'] as String;
        typeCountMap[fileType] = (typeCountMap[fileType] ?? 0) + 1;
      }
      
      return typeCountMap;
    } catch (e) {
      print('Lỗi khi đếm tài liệu theo loại: $e');
      return {};
    }
  }
}