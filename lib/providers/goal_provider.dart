import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repository = GoalRepository();
  
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;
  
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Goal> getUpcomingGoals() {
    final now = DateTime.now();
    return _goals
        .where((goal) => 
            goal.deadline.isAfter(now) && 
            goal.status != GoalStatus.completed)
        .toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }
  
  List<Goal> getCompletedGoals() {
    return _goals
        .where((goal) => goal.status == GoalStatus.completed)
        .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  List<Goal> getOverdueGoals() {
    final now = DateTime.now();
    return _goals
        .where((goal) => 
            goal.deadline.isBefore(now) && 
            goal.status != GoalStatus.completed)
        .toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }
  
  Future<void> loadGoals(ObjectId userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _goals = await _repository.getGoalsByUserId(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadGoalsBySubject(ObjectId subjectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _goals = await _repository.getGoalsBySubject(subjectId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Goal>> getUpcomingGoalsFromServer(ObjectId userId, {int limit = 10}) async {
    try {
      return await _repository.getUpcomingGoals(userId, limit: limit);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }
  
  Future<Goal?> getGoalById(ObjectId id) async {
    try {
      return await _repository.getGoalById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
  
  Future<bool> addGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newGoal = await _repository.createGoal(goal);
      
      if (newGoal != null) {
        _goals.add(newGoal);
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể thêm mục tiêu';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedGoal = await _repository.updateGoal(goal);
      
      if (updatedGoal != null) {
        final index = _goals.indexWhere((g) => g.id == goal.id);
        if (index != -1) {
          _goals[index] = updatedGoal;
          notifyListeners();
        }
        return true;
      }
      
      _error = 'Không thể cập nhật mục tiêu';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateGoalStatus(ObjectId goalId, GoalStatus status, int progressPercentage) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _repository.updateGoalStatus(goalId, status, progressPercentage);
      
      if (success) {
        final index = _goals.indexWhere((g) => g.id == goalId);
        if (index != -1) {
          final updatedGoal = Goal(
            id: _goals[index].id,
            title: _goals[index].title,
            description: _goals[index].description,
            userId: _goals[index].userId,
            subjectId: _goals[index].subjectId,
            deadline: _goals[index].deadline,
            status: status,
            progressPercentage: progressPercentage,
            createdAt: _goals[index].createdAt,
            updatedAt: DateTime.now(),
          );
          
          _goals[index] = updatedGoal;
          notifyListeners();
        }
        return true;
      }
      
      _error = 'Không thể cập nhật trạng thái mục tiêu';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteGoal(ObjectId goalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _repository.deleteGoal(goalId);
      
      if (success) {
        _goals.removeWhere((goal) => goal.id == goalId);
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể xóa mục tiêu';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Map<String, int>> getGoalStatusCounts(ObjectId userId) async {
    try {
      return await _repository.getGoalStatusCounts(userId);
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }
}