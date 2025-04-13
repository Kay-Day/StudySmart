class ValidationHelper {
  // Kiểm tra email
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }
  
  // Kiểm tra mật khẩu (ít nhất 6 ký tự)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
  
  // Kiểm tra username (chỉ cho phép chữ cái, số và dấu gạch dưới, ít nhất 4 ký tự)
  static bool isValidUsername(String username) {
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{4,}$');
    return usernameRegExp.hasMatch(username);
  }
  
  // Kiểm tra chuỗi rỗng
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }
  
  // Kiểm tra số
  static bool isNumeric(String value) {
    if (value.isEmpty) {
      return false;
    }
    return num.tryParse(value) != null;
  }
  
  // Kiểm tra số nguyên dương
  static bool isPositiveInteger(String value) {
    if (value.isEmpty) {
      return false;
    }
    final n = num.tryParse(value);
    return n != null && n > 0 && n % 1 == 0;
  }
  
  // Các thông báo lỗi
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    } else if (!isValidEmail(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    } else if (!isValidPassword(value)) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
  
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên đăng nhập không được để trống';
    } else if (!isValidUsername(value)) {
      return 'Tên đăng nhập không hợp lệ (chỉ gồm chữ cái, số, dấu gạch dưới và ít nhất 4 ký tự)';
    }
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }
  
  static String? validatePositiveInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    } else if (!isPositiveInteger(value)) {
      return '$fieldName phải là số nguyên dương';
    }
    return null;
  }
}