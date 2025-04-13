import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../data/models/study_session.dart';
import '../data/repositories/study_session_repository.dart';

class StudySessionProvider extends ChangeNotifier {
  final StudySessionRepository _repository = StudySessionRepository();
  
  List<StudySession> _sessions = [];
  bool _isLoading = false;
  String? _error;
  
  // Các biến để theo dõi phiên học đang diễn ra
  StudySession? _activeSession;
  DateTime? _startTime;
  ObjectId? _activeSubjectId;
  
  List<StudySession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSession => _activeSession != null;
  StudySession? get activeSession => _activeSession;
  DateTime? get startTime => _startTime;
  ObjectId? get activeSubjectId => _activeSubjectId;
  
  Future<void> loadSessions(ObjectId userId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _sessions = await _repository.getSessionsByUserId(userId, limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadSessionsByDateRange(
    ObjectId userId,
    DateTime startDate,
    DateTime endDate
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _sessions = await _repository.getSessionsByDateRange(userId, startDate, endDate);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadSessionsBySubject(ObjectId subjectId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _sessions = await _repository.getSessionsBySubject(subjectId, limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<StudySession?> getSessionById(ObjectId id) async {
    try {
      return await _repository.getSessionById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
  
  // Bắt đầu một phiên học mới
  void startSession(ObjectId subjectId) {
    if (_activeSession != null) {
      // Đã có phiên học đang diễn ra
      _error = 'Đã có phiên học đang diễn ra';
      notifyListeners();
      return;
    }
    
    _startTime = DateTime.now();
    _activeSubjectId = subjectId;
    notifyListeners();
  }
  
  // Kết thúc phiên học hiện tại
  Future<bool> endSession(ObjectId userId, String? notes, int productivityRating) async {
    if (_startTime == null || _activeSubjectId == null) {
      _error = 'Không có phiên học nào đang diễn ra';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final endTime = DateTime.now();
      final durationMinutes = endTime.difference(_startTime!).inMinutes;
      
      if (durationMinutes < 1) {
        _error = 'Phiên học quá ngắn (dưới 1 phút)';
        _startTime = null;
        _activeSubjectId = null;
        return false;
      }
      
      final session = StudySession(
        userId: userId,
        subjectId: _activeSubjectId!,
        startTime: _startTime!,
        endTime: endTime,
        durationMinutes: durationMinutes,
        notes: notes,
        productivityRating: productivityRating,
      );
      
      final createdSession = await _repository.createSession(session);
      
      if (createdSession != null) {
        _sessions.insert(0, createdSession); // Thêm vào đầu danh sách
        _activeSession = null;
        _startTime = null;
        _activeSubjectId = null;
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể lưu phiên học';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Hủy phiên học hiện tại
  void cancelSession() {
    _activeSession = null;
    _startTime = null;
    _activeSubjectId = null;
    notifyListeners();
  }
  
  Future<bool> deleteSession(ObjectId sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _repository.deleteSession(sessionId);
      
      if (success) {
        _sessions.removeWhere((session) => session.id == sessionId);
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể xóa phiên học';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Map<String, int>> getTotalStudyTimeBySubject(
    ObjectId userId, 
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      return await _repository.getTotalStudyTimeBySubject(userId, startDate, endDate);
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }
  
  Future<int> getTotalStudyTime(
    ObjectId userId, 
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      return await _repository.getTotalStudyTime(userId, startDate, endDate);
    } catch (e) {
      _error = e.toString();
      return 0;
    }
  }
}