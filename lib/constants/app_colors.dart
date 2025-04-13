import 'package:flutter/material.dart';

class AppColors {
  // Màu chính
  static const Color primary = Color(0xFF4263EB);
  static const Color primaryVariant = Color(0xFF364FC7);
  static const Color secondary = Color(0xFF12B886);
  static const Color secondaryVariant = Color(0xFF0CA678);
  
  // Màu trung tính
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFF03E3E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212529);
  static const Color onSurface = Color(0xFF212529);
  static const Color onError = Color(0xFFFFFFFF);
  
  // Màu văn bản
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF495057);
  static const Color textHint = Color(0xFF868E96);
  static const Color textDisabled = Color(0xFFADB5BD);
  
  // Màu đường viền
  static const Color border = Color(0xFFDEE2E6);
  static const Color divider = Color(0xFFE9ECEF);
  
  // Màu trạng thái
  static const Color success = Color(0xFF12B886);
  static const Color warning = Color(0xFFFCC419);
  static const Color info = Color(0xFF228BE6);
  static const Color disabled = Color(0xFFCED4DA);
  
  // Màu biểu đồ
  static const List<Color> chartColors = [
    Color(0xFF4263EB), // Xanh dương
    Color(0xFF12B886), // Xanh lá
    Color(0xFFFCC419), // Vàng
    Color(0xFFF76707), // Cam
    Color(0xFFF03E3E), // Đỏ
    Color(0xFF7950F2), // Tím
    Color(0xFF15AABF), // Xanh ngọc
    Color(0xFF212529), // Đen
  ];
  
  // Màu gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4263EB), Color(0xFF364FC7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF12B886), Color(0xFF0CA678)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Màu môn học mặc định
  static const List<Color> subjectColors = [
    Color(0xFF4263EB), // Xanh dương
    Color(0xFF12B886), // Xanh lá
    Color(0xFFF76707), // Cam
    Color(0xFFF03E3E), // Đỏ
    Color(0xFF7950F2), // Tím
    Color(0xFF15AABF), // Xanh ngọc
    Color(0xFFFCC419), // Vàng
    Color(0xFF212529), // Đen
  ];
  
  // Chuyển đổi từ chuỗi hex sang Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  
  // Chuyển đổi từ Color sang chuỗi hex
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8)}';
  }
}