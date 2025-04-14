// import 'package:mongo_dart/mongo_dart.dart';
// import '../models/user.dart';
// import '../../config/mongo_db.dart';

// class UserRepository {
//   static const String collectionName = 'users';

//   Future<User?> getUserById(ObjectId id) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final map = await collection.findOne(where.id(id));
//       if (map != null) {
//         return User.fromMap(map);
//       }
//       return null;
//     } catch (e) {
//       print('Lỗi khi lấy thông tin người dùng: $e');
//       return null;
//     }
//   }

//   Future<User?> getUserByEmail(String email) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final map = await collection.findOne(where.eq('email', email));
//       if (map != null) {
//         return User.fromMap(map);
//       }
//       return null;
//     } catch (e) {
//       print('Lỗi khi lấy thông tin người dùng qua email: $e');
//       return null;
//     }
//   }

//   Future<User?> getUserByUsername(String username) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final map = await collection.findOne(where.eq('username', username));
//       if (map != null) {
//         return User.fromMap(map);
//       }
//       return null;
//     } catch (e) {
//       print('Lỗi khi lấy thông tin người dùng qua username: $e');
//       return null;
//     }
//   }

//   Future<User?> createUser(User user) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
      
//       // Kiểm tra xem email hoặc username đã tồn tại chưa
//       final existingEmail = await collection.findOne(where.eq('email', user.email));
//       if (existingEmail != null) {
//         throw Exception('Email đã được sử dụng');
//       }
      
//       final existingUsername = await collection.findOne(where.eq('username', user.username));
//       if (existingUsername != null) {
//         throw Exception('Tên đăng nhập đã được sử dụng');
//       }
      
//       await collection.insert(user.toMap());
//       return user;
//     } catch (e) {
//       print('Lỗi khi tạo người dùng mới: $e');
//       rethrow;
//     }
//   }

//   Future<User?> updateUser(User user) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final updatedUser = User(
//         id: user.id,
//         username: user.username,
//         email: user.email,
//         password: user.password,
//         fullName: user.fullName,
//         avatarUrl: user.avatarUrl,
//         createdAt: user.createdAt,
//         updatedAt: DateTime.now(),
//       );
      
//       await collection.update(
//         where.id(user.id),
//         updatedUser.toMap(),
//       );
      
//       return updatedUser;
//     } catch (e) {
//       print('Lỗi khi cập nhật thông tin người dùng: $e');
//       return null;
//     }
//   }

//   Future<bool> changePassword(ObjectId userId, String newPassword) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final result = await collection.update(
//         where.id(userId),
//         modify.set('password', newPassword)
//           .set('updatedAt', DateTime.now()),
//       );
      
//       return result['ok'] == 1.0;
//     } catch (e) {
//       print('Lỗi khi đổi mật khẩu: $e');
//       return false;
//     }
//   }

//   Future<bool> deleteUser(ObjectId userId) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final result = await collection.remove(where.id(userId));
//       return result['ok'] == 1.0;
//     } catch (e) {
//       print('Lỗi khi xóa người dùng: $e');
//       return false;
//     }
//   }

//   Future<bool> updateAvatar(ObjectId userId, String? avatarUrl) async {
//   try {
//     final collection = MongoDatabase.getCollection(collectionName);
//     final result = await collection.update(
//       where.id(userId),
//       modify.set('avatarUrl', avatarUrl)
//         .set('updatedAt', DateTime.now()),
//     );
    
//     return result['ok'] == 1.0;
//   } catch (e) {
//     print('Lỗi khi cập nhật avatar: $e');
//     return false;
//   }
// }

// }
/////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:mongo_dart/mongo_dart.dart' hide State;
// import '../models/user.dart';
// import '../../config/mongo_db.dart';

// class UserRepository {
//   static const String collectionName = 'users';

//   Future<User?> getUserById(ObjectId id) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final map = await collection.findOne(where.id(id));
//       if (map != null) {
//         return User.fromMap(map);
//       }
//       return null;
//     } catch (e) {
//       print('Lỗi khi lấy thông tin người dùng: $e');
//       return null;
//     }
//   }

//   Future<User?> getUserByEmail(String email) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final map = await collection.findOne(where.eq('email', email));
//       if (map != null) {
//         return User.fromMap(map);
//       }
//       return null;
//     } catch (e) {
//       print('Lỗi khi lấy thông tin người dùng qua email: $e');
//       return null;
//     }
//   }

//   Future<User?> getUserByUsername(String username) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final map = await collection.findOne(where.eq('username', username));
//       if (map != null) {
//         return User.fromMap(map);
//       }
//       return null;
//     } catch (e) {
//       print('Lỗi khi lấy thông tin người dùng qua username: $e');
//       return null;
//     }
//   }

//   Future<User?> createUser(User user) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
      
//       // Kiểm tra xem email hoặc username đã tồn tại chưa
//       final existingEmail = await collection.findOne(where.eq('email', user.email));
//       if (existingEmail != null) {
//         throw Exception('Email đã được sử dụng');
//       }
      
//       final existingUsername = await collection.findOne(where.eq('username', user.username));
//       if (existingUsername != null) {
//         throw Exception('Tên đăng nhập đã được sử dụng');
//       }
      
//       await collection.insert(user.toMap());
//       return user;
//     } catch (e) {
//       print('Lỗi khi tạo người dùng mới: $e');
//       rethrow;
//     }
//   }

//   Future<User?> updateUser(User user) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);

//       // Tạo map với các trường cần cập nhật
//       final Map<String, dynamic> updateData = {
//         'fullName': user.fullName,
//         'updatedAt': DateTime.now().toUtc(),
//       };
      
//       // Sử dụng biến cục bộ để xử lý avatarUrl
//       final avatarUrl = user.avatarUrl;
//       if (avatarUrl != null) {
//         updateData['avatarUrl'] = avatarUrl;
//       }
      
//       print('Cập nhật user với id=${user.id}, data=$updateData');
      
//       // Sử dụng $set để chỉ cập nhật các trường đã chỉ định
//       final result = await collection.update(
//         where.id(user.id),
//         {'\$set': updateData},
//       );
      
//       print('Kết quả cập nhật: $result');
      
//       if (result['ok'] == 1.0) {
//         // Nếu cập nhật thành công, lấy lại thông tin người dùng đã cập nhật
//         return await getUserById(user.id);
//       }
      
//       return null;
//     } catch (e) {
//       print('Lỗi khi cập nhật thông tin người dùng: $e');
//       return null;
//     }
//   }

//   Future<bool> changePassword(ObjectId userId, String newPassword) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final result = await collection.update(
//         where.id(userId),
//         {'\$set': {
//           'password': newPassword,
//           'updatedAt': DateTime.now().toUtc()
//         }},
//       );
      
//       return result['ok'] == 1.0;
//     } catch (e) {
//       print('Lỗi khi đổi mật khẩu: $e');
//       return false;
//     }
//   }

//   Future<bool> deleteUser(ObjectId userId) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       final result = await collection.remove(where.id(userId));
//       return result['ok'] == 1.0;
//     } catch (e) {
//       print('Lỗi khi xóa người dùng: $e');
//       return false;
//     }
//   }

//   Future<bool> updateAvatar(ObjectId userId, String? avatarUrl) async {
//     try {
//       final collection = MongoDatabase.getCollection(collectionName);
//       print('Cập nhật avatar cho userId=$userId, avatarUrl=$avatarUrl');
      
//       final result = await collection.update(
//         where.id(userId),
//         {
//           '\$set': {
//             'avatarUrl': avatarUrl,
//             'updatedAt': DateTime.now().toUtc(),
//           },
//         },
//       );
      
//       print('Kết quả cập nhật avatar: $result');
//       return result['ok'] == 1.0;
//     } catch (e) {
//       print('Lỗi khi cập nhật avatar: $e');
//       return false;
//     }
//   }
// }


import 'package:mongo_dart/mongo_dart.dart' hide State;
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

    // Create document with the fields to update
    final Map<String, dynamic> document = {
      'fullName': user.fullName,
      'updatedAt': DateTime.now()
    };
    
    // Only add avatarUrl to the document if it's not null
    if (user.avatarUrl != null) {
      document['avatarUrl'] = user.avatarUrl;
    }
    
    print('Cập nhật user với id=${user.id}, data=$document');
    
    // Use findAndModify with proper handling of null values
    final result = await collection.findAndModify(
      query: where.id(user.id),
      update: {'\$set': document},
      returnNew: true
    );
    
    print('Kết quả cập nhật: $result');
    
    if (result != null) {
      return User.fromMap(result);
    }
    
    return null;
  } catch (e) {
    print('Lỗi khi cập nhật thông tin người dùng: $e');
    return null;
  }
}

Future<bool> updateAvatar(ObjectId userId, String? avatarUrl) async {
  try {
    final collection = MongoDatabase.getCollection(collectionName);
    print('Cập nhật avatar cho userId=$userId, avatarUrl=$avatarUrl');
    
    // Create update document
    final Map<String, dynamic> updateDoc = {
      'updatedAt': DateTime.now()
    };
    
    // Only add avatarUrl if it's not null
    if (avatarUrl != null) {
      updateDoc['avatarUrl'] = avatarUrl;
    }
    
    final result = await collection.findAndModify(
      query: where.id(userId),
      update: {'\$set': updateDoc}
    );
    
    print('Kết quả cập nhật avatar: $result');
    return result != null;
  } catch (e) {
    print('Lỗi khi cập nhật avatar: $e');
    return false;
  }
}
  Future<bool> changePassword(ObjectId userId, String newPassword) async {
    try {
      final collection = MongoDatabase.getCollection(collectionName);
      final result = await collection.findAndModify(
        query: where.id(userId),
        update: {
          '\$set': {
            'password': newPassword,
            'updatedAt': DateTime.now()
          }
        }
      );
      
      return result != null;
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