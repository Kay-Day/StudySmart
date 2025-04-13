import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../data/models/note.dart';
import '../data/repositories/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();
  
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;
  
  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadNotes(ObjectId userId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _notes = await _repository.getNotesByUserId(userId, limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadNotesBySubject(ObjectId subjectId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _notes = await _repository.getNotesBySubject(subjectId, limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Note>> searchNotes(ObjectId userId, String searchTerm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final results = await _repository.searchNotes(userId, searchTerm);
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  Future<Note?> getNoteById(ObjectId id) async {
    try {
      return await _repository.getNoteById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
  
  Future<bool> addNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newNote = await _repository.createNote(note);
      
      if (newNote != null) {
        _notes.insert(0, newNote); // Thêm vào đầu danh sách
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể thêm ghi chú';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedNote = await _repository.updateNote(note);
      
      if (updatedNote != null) {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = updatedNote;
          notifyListeners();
        }
        return true;
      }
      
      _error = 'Không thể cập nhật ghi chú';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteNote(ObjectId noteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _repository.deleteNote(noteId);
      
      if (success) {
        _notes.removeWhere((note) => note.id == noteId);
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể xóa ghi chú';
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