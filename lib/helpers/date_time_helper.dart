import 'package:intl/intl.dart';

class DateTimeHelper {
  // Format: DD/MM/YYYY
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
  
  // Format: HH:MM
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  // Format: DD/MM/YYYY HH:MM
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  // Format: Thứ 2, 01/01/2023
  static String formatDateWithWeekday(DateTime dateTime) {
    return '${_getWeekdayInVietnamese(dateTime.weekday)}, ${formatDate(dateTime)}';
  }
  
  // Format: Tháng 1, 2023
  static String formatMonth(DateTime dateTime) {
    return 'Tháng ${dateTime.month}, ${dateTime.year}';
  }
  
  // Format: 2 giờ trước, 5 phút trước, Vừa xong, v.v.
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  
  // Chuyển đổi giây thành format: 2h 30m
  static String formatDuration(int minutes) {
    final hours = (minutes / 60).floor();
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${mins > 0 ? '${mins}m' : ''}';
    } else {
      return '${mins}m';
    }
  }
  
  // Lấy ngày đầu tiên của tuần
  static DateTime getFirstDayOfWeek(DateTime date) {
    // Trong Dart, ngày đầu tiên của tuần là thứ hai (weekday = 1)
    return date.subtract(Duration(days: date.weekday - 1));
  }
  
  // Lấy ngày cuối cùng của tuần
  static DateTime getLastDayOfWeek(DateTime date) {
    // Ngày cuối cùng của tuần là Chủ nhật (weekday = 7)
    return date.add(Duration(days: 7 - date.weekday));
  }
  
  // Lấy ngày đầu tiên của tháng
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  // Lấy ngày cuối cùng của tháng
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  // Chuyển đổi weekday sang tiếng Việt
  static String _getWeekdayInVietnamese(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ Hai';
      case 2:
        return 'Thứ Ba';
      case 3:
        return 'Thứ Tư';
      case 4:
        return 'Thứ Năm';
      case 5:
        return 'Thứ Sáu';
      case 6:
        return 'Thứ Bảy';
      case 7:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }
}