import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../data/models/subject.dart';
import '../data/repositories/subject_repository.dart';

class SubjectProvider extends ChangeNotifier {
  final SubjectRepository _repository = SubjectRepository();
  
  List<Subject> _subjects = [];
  bool _isLoading = false;
  String? _error;
  
  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadSubjects(ObjectId userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _subjects = await _repository.getSubjectsByUserId(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Subject?> getSubjectById(ObjectId id) async {
    try {
      return await _repository.getSubjectById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
  
  Future<bool> addSubject(Subject subject) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newSubject = await _repository.createSubject(subject);
      
      if (newSubject != null) {
        _subjects.add(newSubject);
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể thêm môn học';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateSubject(Subject subject) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedSubject = await _repository.updateSubject(subject);
      
      if (updatedSubject != null) {
        final index = _subjects.indexWhere((s) => s.id == subject.id);
        if (index != -1) {
          _subjects[index] = updatedSubject;
          notifyListeners();
        }
        return true;
      }
      
      _error = 'Không thể cập nhật môn học';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteSubject(ObjectId subjectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _repository.deleteSubject(subjectId);
      
      if (success) {
        _subjects.removeWhere((subject) => subject.id == subjectId);
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể xóa môn học';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}