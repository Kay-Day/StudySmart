import 'package:mongo_dart/mongo_dart.dart';
import '../models/note.dart';
import '../../config/mongo_db.dart';

class NoteRepository {
  static const String collectionName = 'notes';

  Future<List<Note>> getNotesByUserId(ObjectId userId, {int limit = 50}) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(
        where.eq('userId', userId)
        .sortBy('updatedAt', descending: true)
        .limit(limit)
      ).toList();
      
      return maps.map((map) => Note.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách ghi chú: $e');
      return [];
    }
  }

  Future<List<Note>> getNotesBySubject(ObjectId subjectId, {int limit = 50}) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final maps = await collection.find(
        where.eq('subjectId', subjectId)
        .sortBy('updatedAt', descending: true)
        .limit(limit)
      ).toList();
      
      return maps.map((map) => Note.fromMap(map)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách ghi chú theo môn: $e');
      return [];
    }
  }
Future<List<Note>> searchNotes(ObjectId userId, String searchTerm) async {
  try {
    final collection = MongoDatabase.getCollection(collectionName);
    
    // Xây dựng pipeline tìm kiếm MongoDB
    final query = where.eq('userId', userId).map;
    query['\$or'] = [
      {'title': {'\$regex': searchTerm, '\$options': 'i'}},
      {'content': {'\$regex': searchTerm, '\$options': 'i'}},
      {'tags': {'\$regex': searchTerm, '\$options': 'i'}}
    ];
    
    final maps = await collection.find(query).toList();
    
    return maps.map((map) => Note.fromMap(map)).toList();
  } catch (e) {
    print('Lỗi khi tìm kiếm ghi chú: $e');
    return [];
  }
}

  Future<Note?> getNoteById(ObjectId id) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne(where.id(id));
      if (map != null) {
        return Note.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin ghi chú: $e');
      return null;
    }
  }

  Future<Note?> createNote(Note note) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      await collection.insert(note.toMap());
      return note;
    } catch (e) {
      print('Lỗi khi tạo ghi chú mới: $e');
      return null;
    }
  }

  Future<Note?> updateNote(Note note) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        userId: note.userId,
        subjectId: note.subjectId,
        tags: note.tags,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await collection.update(
        where.id(note.id),
        updatedNote.toMap(),
      );
      
      return updatedNote;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin ghi chú: $e');
      return null;
    }
  }

  Future<bool> deleteNote(ObjectId noteId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.remove(where.id(noteId));
      return result['ok'] == 1.0;
    } catch (e) {
      print('Lỗi khi xóa ghi chú: $e');
      return false;
    }
  }
}