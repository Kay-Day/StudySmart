import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'profile_screen.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';
  
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cài Đặt',
      ),
      body: ListView(
        children: [
          // Thông tin người dùng
          if (user != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: user.avatarUrl != null
                        ? null // TODO: Hiển thị ảnh đại diện từ URL
                        : Text(
                            user.fullName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          
          // Tài khoản
          const ListTile(
            title: Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Thông tin cá nhân'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, ChangePasswordScreen.routeName);
            },
          ),
          
          // Giao diện
          const Divider(),
          const ListTile(
            title: Text(
              'Giao diện',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Chế độ tối'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              // TODO: Implement dark mode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chế độ tối đang được phát triển'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          
          // Thông báo
          const Divider(),
          const ListTile(
            title: Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Nhắc nhở mục tiêu'),
            value: true, // TODO: Implement notification settings
            onChanged: (value) {
              // TODO: Implement notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cài đặt thông báo đang được phát triển'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          
          // Thông tin ứng dụng
          const Divider(),
          const ListTile(
            title: Text(
              'Thông tin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Giới thiệu'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, AboutScreen.routeName);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Hỗ trợ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement support
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng hỗ trợ đang được phát triển'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.stars),
            title: const Text('Đánh giá ứng dụng'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement app rating
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đánh giá đang được phát triển'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Phiên bản ứng dụng
          Center(
            child: Text(
              'Phiên bản ${AppConstants.appVersion}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nút đăng xuất
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              onPressed: () => _showLogoutConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}