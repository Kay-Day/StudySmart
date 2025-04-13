import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? _db;
  static bool _isInitialized = false;
  static const String connectionString = 'mongodb+srv://caoman26:0jNpzDDd77m8mm6O@cluster0.pkzpdcw.mongodb.net/study_tracker?retryWrites=true&w=majority';

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _db = await Db.create(connectionString);
      await _db!.open();
      _isInitialized = true;
      print('Kết nối MongoDB thành công!');
    } catch (e) {
      print('Lỗi kết nối MongoDB: $e');
      rethrow;
    }
  }

  static Db get db {
    if (!_isInitialized) {
      throw Exception('MongoDB chưa được khởi tạo! Gọi MongoDatabase.initialize() trước.');
    }
    return _db!;
  }

  static DbCollection getCollection(String collectionName) {
    return db.collection(collectionName);
  }

  static Future<void> close() async {
    if (_isInitialized) {
      await _db!.close();
      _isInitialized = false;
    }
  }
}