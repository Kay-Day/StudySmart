import 'package:mongo_dart/mongo_dart.dart';
import '../models/study_session.dart';
import '../../config/mongo_db.dart';

class StudySessionRepository {
  static const String collectionName = 'study_sessions';

  Future<List<StudySession>> getSessionsByUserId(ObjectId userId, {int limit = 50}) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(
        where.eq('userId', userId)
        .sortBy('startTime', descending: true)
        .limit(limit)
      ).toList();
      
      return maps.map((map) => StudySession.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách phiên học: $e');
      return [];
    }
  }

  Future<List<StudySession>> getSessionsBySubject(ObjectId subjectId, {int limit = 50}) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(
        where.eq('subjectId', subjectId)
        .sortBy('startTime', descending: true)
        .limit(limit)
      ).toList();
      
      return maps.map((map) => StudySession.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách phiên học theo môn: $e');
      return [];
    }
  }

  Future<List<StudySession>> getSessionsByDateRange(
    ObjectId userId,
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(
        where.eq('userId', userId)
        .and(where.gte('startTime', startDate))
        .and(where.lte('endTime', endDate))
        .sortBy('startTime', descending: true)
      ).toList();
      
      return maps.map((map) => StudySession.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách phiên học theo khoảng thời gian: $e');
      return [];
    }
  }

  Future<StudySession?> getSessionById(ObjectId id) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne(where.id(id));
      if (map != null) {
        return StudySession.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin phiên học: $e');
      return null;
    }
  }

  Future<StudySession?> createSession(StudySession session) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      await collection.insert(session.toMap());
      return session;
    } catch (e) {
      print('Lỗi khi tạo phiên học mới: $e');
      return null;
    }
  }

  Future<bool> deleteSession(ObjectId sessionId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.remove(where.id(sessionId));
      return result['ok'] == 1.0;
    } catch (e) {
      print('Lỗi khi xóa phiên học: $e');
      return false;
    }
  }

  Future<Map<String, int>> getTotalStudyTimeBySubject(
    ObjectId userId, 
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final pipeline = AggregationPipelineBuilder()
        .addStage(Match(where
          .eq('userId', userId)
          .and(where.gte('startTime', startDate))
          .and(where.lte('endTime', endDate))
          .map['\$query']
        ))
        .addStage(Group(
          id: Field('subjectId'),
          fields: {
            'totalMinutes': Sum(Field('durationMinutes')),
          }
        ))
        .build();
      
      final result = await collection.aggregateToStream(pipeline).toList();
      
      Map<String, int> subjectTimeMap = {};
      for (var doc in result) {
        subjectTimeMap[doc['_id'].toString()] = doc['totalMinutes'] as int;
      }
      
      return subjectTimeMap;
    } catch (e) {
      print('Lỗi khi tính tổng thời gian học theo môn: $e');
      return {};
    }
  }

  Future<int> getTotalStudyTime(
    ObjectId userId, 
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final pipeline = AggregationPipelineBuilder()
        .addStage(Match(where
          .eq('userId', userId)
          .and(where.gte('startTime', startDate))
          .and(where.lte('endTime', endDate))
          .map['\$query']
        ))
        .addStage(Group(
          id: null,
          fields: {
            'totalMinutes': Sum(Field('durationMinutes')),
          }
        ))
        .build();
      
      final result = await collection.aggregateToStream(pipeline).toList();
      
      if (result.isNotEmpty) {
        return result.first['totalMinutes'] as int;
      }
      
      return 0;
    } catch (e) {
      print('Lỗi khi tính tổng thời gian học: $e');
      return 0;
    }
  }
}