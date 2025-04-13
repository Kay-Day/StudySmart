class AppConstants {
  // Thông tin ứng dụng
  static const String appName = 'StudySmart';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Ứng dụng quản lý học tập cá nhân cho học sinh THPT';
  
  // Các giá trị mặc định
  static const int minPasswordLength = 6;
  static const int defaultStudySessionTime = 25; // Phút
  static const int defaultBreakTime = 5; // Phút
  
  // Các collection name trong MongoDB
  static const String usersCollection = 'users';
  static const String subjectsCollection = 'subjects';
  static const String studySessionsCollection = 'study_sessions';
  static const String goalsCollection = 'goals';
  static const String documentsCollection = 'documents';
  static const String notesCollection = 'notes';
  
  // Các key cho SharedPreferences
  static const String userPrefKey = 'current_user';
  static const String themePrefKey = 'app_theme';
  static const String notificationPrefKey = 'notification_enabled';
  
  // Các giá trị thời gian
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration toastDuration = Duration(seconds: 3);
  
  // Các giá trị kích thước
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultBorderWidth = 1.0;
  static const double defaultIconSize = 24.0;
  static const double defaultElevation = 2.0;
  
  // Các thông điệp lỗi
  static const String errorConnectionFailed = 'Không thể kết nối đến máy chủ';
  static const String errorInvalidCredentials = 'Tên đăng nhập hoặc mật khẩu không đúng';
  static const String errorUnknown = 'Đã xảy ra lỗi không xác định';
  
  // Các thông điệp thành công
  static const String successLogin = 'Đăng nhập thành công';
  static const String successRegister = 'Đăng ký tài khoản thành công';
  static const String successPasswordChanged = 'Đổi mật khẩu thành công';
}