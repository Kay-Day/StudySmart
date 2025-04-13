import 'package:mongo_dart/mongo_dart.dart';
import '../models/goal.dart';
import '../../config/mongo_db.dart';

class GoalRepository {
  static const String collectionName = 'goals';

  Future<List<Goal>> getGoalsByUserId(ObjectId userId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(
        where.eq('userId', userId)
        .sortBy('deadline')
      ).toList();
      
      return maps.map((map) => Goal.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách mục tiêu: $e');
      return [];
    }
  }

  Future<List<Goal>> getGoalsBySubject(ObjectId subjectId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(
        where.eq('subjectId', subjectId)
        .sortBy('deadline')
      ).toList();
      
      return maps.map((map) => Goal.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách mục tiêu theo môn: $e');
      return [];
    }
  }

  Future<List<Goal>> getUpcomingGoals(ObjectId userId, {int limit = 10}) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final now = DateTime.now();
      final maps = await collection.find(
        where.eq('userId', userId)
        .and(where.gt('deadline', now))
        .and(where.ne('status', GoalStatus.completed.index))
        .sortBy('deadline')
        .limit(limit)
      ).toList();
      
      return maps.map((map) => Goal.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách mục tiêu sắp đến: $e');
      return [];
    }
  }

  Future<Goal?> getGoalById(ObjectId id) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne(where.id(id));
      if (map != null) {
        return Goal.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin mục tiêu: $e');
      return null;
    }
  }

  Future<Goal?> createGoal(Goal goal) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      await collection.insert(goal.toMap());
      return goal;
    } catch (e) {
      print('Lỗi khi tạo mục tiêu mới: $e');
      return null;
    }
  }

  Future<Goal?> updateGoal(Goal goal) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final updatedGoal = Goal(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        userId: goal.userId,
        subjectId: goal.subjectId,
        deadline: goal.deadline,
        status: goal.status,
        progressPercentage: goal.progressPercentage,
        createdAt: goal.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await collection.update(
        where.id(goal.id),
        updatedGoal.toMap(),
      );
      
      return updatedGoal;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin mục tiêu: $e');
      return null;
    }
  }

  Future<bool> updateGoalStatus(ObjectId goalId, GoalStatus status, int progressPercentage) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.update(
        where.id(goalId),
        modify.set('status', status.index)
          .set('progressPercentage', progressPercentage)
          .set('updatedAt', DateTime.now()),
      );
      
      return result['ok'] == 1.0;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái mục tiêu: $e');
      return false;
    }
  }

  Future<bool> deleteGoal(ObjectId goalId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.remove(where.id(goalId));
      return result['ok'] == 1.0;
    } catch (e) {
      print('Lỗi khi xóa mục tiêu: $e');
      return false;
    }
  }

  Future<Map<String, int>> getGoalStatusCounts(ObjectId userId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final pipeline = AggregationPipelineBuilder()
        .addStage(Match(where.eq('userId', userId).map['\$query']))
        .addStage(Group(
          id: Field('status'),
          fields: {
            'count': Sum(1),
          }
        ))
        .build();
      
      final result = await collection.aggregateToStream(pipeline).toList();
      
      Map<String, int> statusCountMap = {};
      for (var doc in result) {
        final statusIndex = doc['_id'] as int;
        statusCountMap[GoalStatus.values[statusIndex].name] = doc['count'] as int;
      }
      
      return statusCountMap;
    } catch (e) {
      print('Lỗi khi đếm mục tiêu theo trạng thái: $e');
      return {};
    }
  }
}