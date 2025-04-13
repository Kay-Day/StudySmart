import 'package:mongo_dart/mongo_dart.dart';
import '../models/user.dart';
import '../../config/mongo_db.dart';

class UserRepository {
  static const String collectionName = 'users';

  Future<User?> getUserById(ObjectId id) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne(where.id(id));
      if (map != null) {
        return User.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne(where.eq('email', email));
      if (map != null) {
        return User.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng qua email: $e');
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final map = await collection.findOne(where.eq('username', username));
      if (map != null) {
        return User.fromMap(map);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng qua username: $e');
      return null;
    }
  }

  Future<User?> createUser(User user) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      
      // Kiểm tra xem email hoặc username đã tồn tại chưa
      final existingEmail = await collection.findOne(where.eq('email', user.email));
      if (existingEmail != null) {
        throw Exception('Email đã được sử dụng');
      }
      
      final existingUsername = await collection.findOne(where.eq('username', user.username));
      if (existingUsername != null) {
        throw Exception('Tên đăng nhập đã được sử dụng');
      }
      
      await collection.insert(user.toMap());
      return user;
    } catch (e) {
      print('Lỗi khi tạo người dùng mới: $e');
      rethrow;
    }
  }

  Future<User?> updateUser(User user) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final updatedUser = User(
        id: user.id,
        username: user.username,
        email: user.email,
        password: user.password,
        fullName: user.fullName,
        avatarUrl: user.avatarUrl,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await collection.update(
        where.id(user.id),
        updatedUser.toMap(),
      );
      
      return updatedUser;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      return null;
    }
  }

  Future<bool> changePassword(ObjectId userId, String newPassword) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.update(
        where.id(userId),
        modify.set('password', newPassword)
          .set('updatedAt', DateTime.now()),
      );
      
      return result['ok'] == 1.0;
    } catch (e) {
      print('Lỗi khi đổi mật khẩu: $e');
      return false;
    }
  }

  Future<bool> deleteUser(ObjectId userId) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.remove(where.id(userId));
      return result['ok'] == 1.0;
    } catch (e) {
      print('Lỗi khi xóa người dùng: $e');
      return false;
    }
  }
}