import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  static const String routeName = '/about';
  
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Giới Thiệu',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            const Icon(
              Icons.school,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            
            // Tên ứng dụng
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Phiên bản
            Text(
              'Phiên bản ${AppConstants.appVersion}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Mô tả
            const Text(
              AppConstants.appDescription,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Thông tin chi tiết
            const _InfoSection(
              title: 'Về StudySmart',
              content: '''
StudySmart là một ứng dụng quản lý học tập được thiết kế đặc biệt cho học sinh THPT, giúp tối ưu hóa việc học tập và nâng cao hiệu quả học tập.

Với các tính năng như theo dõi thời gian học, quản lý mục tiêu và tài liệu, StudySmart giúp bạn tổ chức việc học một cách khoa học và hiệu quả hơn.
              ''',
            ),
            const SizedBox(height: 16),
            
            const _InfoSection(
              title: 'Tính năng chính',
              content: '''
• Lịch học và nhắc nhở thông minh
• Theo dõi thời gian học của từng môn
• Quản lý tài liệu học tập cá nhân
• Đặt mục tiêu và theo dõi tiến độ
• Phân tích hiệu quả học tập qua biểu đồ
              ''',
            ),
            const SizedBox(height: 16),
            
            const _InfoSection(
              title: 'Liên hệ',
              content: '''
Nếu bạn có bất kỳ câu hỏi hoặc góp ý nào, vui lòng liên hệ với chúng tôi qua:

Email: support@studysmart.com
Website: www.studysmart.com
              ''',
            ),
            const SizedBox(height: 32),
            
            // Bản quyền
            const Text(
              '© 2025 StudySmart. Đã đăng ký bản quyền.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  
  const _InfoSection({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}