import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../helpers/validation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '/change-password';
  
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu xác nhận không khớp'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      
      if (success && mounted) {
        // Xóa dữ liệu đã nhập
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Quay lại màn hình trước đó
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Đổi mật khẩu thất bại'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Đổi Mật Khẩu',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Để đổi mật khẩu, vui lòng nhập mật khẩu hiện tại và mật khẩu mới.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Mật khẩu hiện tại
              PasswordTextField(
                controller: _currentPasswordController,
                labelText: 'Mật khẩu hiện tại',
                hintText: 'Nhập mật khẩu hiện tại',
                validator: ValidationHelper.validatePassword,
              ),
              const SizedBox(height: 16),
              
              // Mật khẩu mới
              PasswordTextField(
                controller: _newPasswordController,
                labelText: 'Mật khẩu mới',
                hintText: 'Nhập mật khẩu mới',
                validator: ValidationHelper.validatePassword,
              ),
              const SizedBox(height: 16),
              
              // Xác nhận mật khẩu mới
              PasswordTextField(
                controller: _confirmPasswordController,
                labelText: 'Xác nhận mật khẩu mới',
                hintText: 'Nhập lại mật khẩu mới',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu mới';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Nút lưu
              CustomButton(
                text: 'Đổi Mật Khẩu',
                onPressed: _changePassword,
                isLoading: authProvider.isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}