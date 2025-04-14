// import 'package:flutter/material.dart';
// import '../data/models/user.dart';
// import '../data/services/auth_service.dart';

// class AuthProvider extends ChangeNotifier {
//   final AuthService _authService = AuthService();
  
//   User? _currentUser;
//   bool _isLoading = false;
//   String? _error;
  
//   User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isLoggedIn => _currentUser != null;
  
//   AuthProvider() {
//     _initCurrentUser();
//   }
  
//   Future<void> _initCurrentUser() async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       _currentUser = await _authService.getCurrentUser();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> register({
//     required String username,
//     required String email,
//     required String password,
//     required String fullName,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       _currentUser = await _authService.register(
//         username: username,
//         email: email,
//         password: password,
//         fullName: fullName,
//       );
      
//       return _currentUser != null;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> login(String emailOrUsername, String password) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       _currentUser = await _authService.login(emailOrUsername, password);
      
//       if (_currentUser == null) {
//         _error = 'Tên đăng nhập hoặc mật khẩu không đúng';
//         return false;
//       }
      
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<void> logout() async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       await _authService.logout();
//       _currentUser = null;
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> changePassword(String currentPassword, String newPassword) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       final success = await _authService.changePassword(currentPassword, newPassword);
      
//       if (!success) {
//         _error = 'Mật khẩu hiện tại không đúng';
//       }
      
//       return success;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> updateUserInfo({
//     required String fullName,
//     String? avatarUrl,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       final updatedUser = await _authService.updateUserInfo(
//         fullName: fullName,
//         avatarUrl: avatarUrl,
//       );
      
//       if (updatedUser != null) {
//         _currentUser = updatedUser;
//         return true;
//       }
      
//       _error = 'Không thể cập nhật thông tin người dùng';
//       return false;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> updateAvatar(String? avatarUrl) async {
//   _isLoading = true;
//   _error = null;
//   notifyListeners();
  
//   try {
//     final success = await _authService.updateAvatar(avatarUrl);
    
//     if (success) {
//       // Đảm bảo _currentUser được cập nhật với avatarUrl mới
//       _currentUser = await _authService.getCurrentUser();
//       return true;
//     }
    
//     _error = 'Không thể cập nhật ảnh đại diện';
//     return false;
//   } catch (e) {
//     _error = e.toString();
//     return false;
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }
// }

import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  
  AuthProvider() {
    _initCurrentUser();
  }
  
  Future<void> _initCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,  // Thêm tham số này
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentUser = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        avatarUrl: avatarUrl,  // Truyền tham số này cho _authService.register
      );
      
      return _currentUser != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> login(String emailOrUsername, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentUser = await _authService.login(emailOrUsername, password);
      
      if (_currentUser == null) {
        _error = 'Tên đăng nhập hoặc mật khẩu không đúng';
        return false;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _authService.changePassword(currentPassword, newPassword);
      
      if (!success) {
        _error = 'Mật khẩu hiện tại không đúng';
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateUserInfo({
    required String fullName,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedUser = await _authService.updateUserInfo(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      
      if (updatedUser != null) {
        _currentUser = updatedUser;
        return true;
      }
      
      _error = 'Không thể cập nhật thông tin người dùng';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAvatar(String? avatarUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _authService.updateAvatar(avatarUrl);
      
      if (success) {
        // Đảm bảo _currentUser được cập nhật với avatarUrl mới
        _currentUser = await _authService.getCurrentUser();
        return true;
      }
      
      _error = 'Không thể cập nhật ảnh đại diện';
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