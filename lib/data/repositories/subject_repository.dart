import 'package:mongo_dart/mongo_dart.dart';
import '../models/subject.dart';
import '../../config/mongo_db.dart';

class SubjectRepository {
  static const String collectionName = 'subjects';

  Future<List<Subject>> getSubjectsByUserId(ObjectId userId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(where.eq('userId', userId)).toList();
      return maps.map((map) => Subject.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách môn học: $e');
      return [];
    }
  }

  Future<Subject?> getSubjectById(ObjectId id) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne(where.id(id));
      if (map != null) {
        return Subject.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin môn học: $e');
      return null;
    }
  }

  Future<Subject?> createSubject(Subject subject) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      await collection.insert(subject.toMap());
      return subject;
    } catch (e) {
      print('Lỗi khi tạo môn học mới: $e');
      return null;
    }
  }

  Future<Subject?> updateSubject(Subject subject) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final updatedSubject = Subject(
        id: subject.id,
        name: subject.name,
        color: subject.color,
        userId: subject.userId,
        targetHoursPerWeek: subject.targetHoursPerWeek,
        icon: subject.icon,
        description: subject.description,
        createdAt: subject.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await collection.update(
        where.id(subject.id),
        updatedSubject.toMap(),
      );
      
      return updatedSubject;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin môn học: $e');
      return null;
    }
  }

  Future<bool> deleteSubject(ObjectId subjectId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.remove(where.id(subjectId));
      return result['ok'] == 1.0;
    } catch (e) {
      print('Lỗi khi xóa môn học: $e');
      return false;
    }
  }

  Future<int> getSubjectCount(ObjectId userId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final count = await collection.count(where.eq('userId', userId));
      return count;
    } catch (e) {
      print('Lỗi khi đếm số môn học: $e');
      return 0;
    }
  }
}