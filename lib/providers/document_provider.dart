import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../data/models/document.dart';
import '../data/repositories/document_repository.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentRepository _repository = DocumentRepository();
  
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;
  
  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadDocuments(ObjectId userId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _documents = await _repository.getDocumentsByUserId(userId, limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadDocumentsBySubject(ObjectId subjectId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _documents = await _repository.getDocumentsBySubject(subjectId, limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Document>> searchDocuments(ObjectId userId, String searchTerm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final results = await _repository.searchDocuments(userId, searchTerm);
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
  
  Future<Document?> getDocumentById(ObjectId id) async {
    try {
      return await _repository.getDocumentById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
  
  Future<bool> addDocument(Document document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newDocument = await _repository.createDocument(document);
      
      if (newDocument != null) {
        _documents.insert(0, newDocument); // Thêm vào đầu danh sách
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể thêm tài liệu';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateDocument(Document document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedDocument = await _repository.updateDocument(document);
      
      if (updatedDocument != null) {
        final index = _documents.indexWhere((d) => d.id == document.id);
        if (index != -1) {
          _documents[index] = updatedDocument;
          notifyListeners();
        }
        return true;
      }
      
      _error = 'Không thể cập nhật tài liệu';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateLastAccessDate(ObjectId documentId) async {
    try {
      final success = await _repository.updateLastAccessDate(documentId);
      
      if (success) {
        final index = _documents.indexWhere((d) => d.id == documentId);
        if (index != -1) {
          final updatedDocument = Document(
            id: _documents[index].id,
            title: _documents[index].title,
            fileName: _documents[index].fileName,
            filePath: _documents[index].filePath,
            fileType: _documents[index].fileType,
            fileSize: _documents[index].fileSize,
            userId: _documents[index].userId,
            subjectId: _documents[index].subjectId,
            tags: _documents[index].tags,
            uploadDate: _documents[index].uploadDate,
            lastAccessDate: DateTime.now(),
          );
          
          _documents[index] = updatedDocument;
          notifyListeners();
        }
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
  
  Future<bool> deleteDocument(ObjectId documentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _repository.deleteDocument(documentId);
      
      if (success) {
        _documents.removeWhere((document) => document.id == documentId);
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể xóa tài liệu';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Map<String, int>> getDocumentCountsByType(ObjectId userId) async {
    try {
      return await _repository.getDocumentCountsByType(userId);
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }
}