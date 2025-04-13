import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository = UserRepository();
  final String _userKey = 'current_user';
  
  // Mã hóa mật khẩu
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Đăng ký tài khoản
  Future<User?> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Mã hóa mật khẩu
      final hashedPassword = _hashPassword(password);
      
      final user = User(
        username: username,
        email: email,
        password: hashedPassword,
        fullName: fullName,
      );
      
      final createdUser = await _userRepository.createUser(user);
      if (createdUser != null) {
        await _saveUserToLocal(createdUser);
      }
      
      return createdUser;
    } catch (e) {
      print('Lỗi khi đăng ký tài khoản: $e');
      rethrow;
    }
  }
  
  // Đăng nhập
  Future<User?> login(String emailOrUsername, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      User? user;
      // Kiểm tra đăng nhập bằng email
      if (emailOrUsername.contains('@')) {
        user = await _userRepository.getUserByEmail(emailOrUsername);
      } else {
        // Kiểm tra đăng nhập bằng username
        user = await _userRepository.getUserByUsername(emailOrUsername);
      }
      
      if (user != null && user.password == hashedPassword) {
        await _saveUserToLocal(user);
        return user;
      }
      
      return null;
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      return null;
    }
  }
  
  // Đăng xuất
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
    }
  }
  
  // Lấy thông tin người dùng hiện tại
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final userId = ObjectId.parse(userMap['_id']);
        
        // Lấy thông tin người dùng từ database để đảm bảo dữ liệu luôn mới nhất
        return await _userRepository.getUserById(userId);
      }
      
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng hiện tại: $e');
      return null;
    }
  }
  
  // Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
  
  // Đổi mật khẩu
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return false;
      }
      
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (user.password != hashedCurrentPassword) {
        return false; // Mật khẩu hiện tại không đúng
      }
      
      final hashedNewPassword = _hashPassword(newPassword);
      final success = await _userRepository.changePassword(user.id, hashedNewPassword);
      
      if (success) {
        // Cập nhật thông tin người dùng trong local storage
        final updatedUser = await _userRepository.getUserById(user.id);
        if (updatedUser != null) {
          await _saveUserToLocal(updatedUser);
        }
      }
      
      return success;
    } catch (e) {
      print('Lỗi khi đổi mật khẩu: $e');
      return false;
    }
  }
  
  // Cập nhật thông tin người dùng
  Future<User?> updateUserInfo({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return null;
      }
      
      final updatedUser = User(
        id: currentUser.id,
        username: currentUser.username,
        email: currentUser.email,
        password: currentUser.password,
        fullName: fullName,
        avatarUrl: avatarUrl ?? currentUser.avatarUrl,
        createdAt: currentUser.createdAt,
      );
      
      final result = await _userRepository.updateUser(updatedUser);
      if (result != null) {
        await _saveUserToLocal(result);
      }
      
      return result;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      return null;
    }
  }
  
  // Lưu thông tin người dùng vào local storage
  Future<void> _saveUserToLocal(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMap = user.toMap();
      
      // Chuyển đổi ObjectId sang string để có thể lưu trong SharedPreferences
      userMap['_id'] = userMap['_id'].toString();
      
      await prefs.setString(_userKey, jsonEncode(userMap));
    } catch (e) {
      print('Lỗi khi lưu thông tin người dùng: $e');
    }
  }
}