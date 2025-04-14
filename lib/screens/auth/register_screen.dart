// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/app_colors.dart';
// import '../../constants/app_constants.dart';
// import '../../helpers/validation_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_app_bar.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_text_field.dart';

// class RegisterScreen extends StatefulWidget {
//   static const String routeName = '/register';
  
//   const RegisterScreen({Key? key}) : super(key: key);

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _fullNameController = TextEditingController();
  
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _fullNameController.dispose();
//     super.dispose();
//   }
  
//   Future<void> _register() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
//       if (_passwordController.text != _confirmPasswordController.text) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Mật khẩu xác nhận không khớp'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//         return;
//       }
      
//       final success = await authProvider.register(
//         username: _usernameController.text.trim(),
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//         fullName: _fullNameController.text.trim(),
//       );
      
//       if (success && mounted) {
//         Navigator.of(context).pushReplacementNamed('/home');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(AppConstants.successRegister),
//             backgroundColor: AppColors.success,
//           ),
//         );
//       } else if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.error ?? 'Đăng ký thất bại'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
    
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Đăng Ký Tài Khoản',
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Form đăng ký
//                 CustomTextField(
//                   controller: _fullNameController,
//                   labelText: 'Họ và tên',
//                   hintText: 'Nhập họ và tên đầy đủ',
//                   prefixIcon: Icons.person,
//                   textCapitalization: TextCapitalization.words,
//                   validator: (value) => ValidationHelper.validateRequired(value, 'Họ và tên'),
//                 ),
//                 const SizedBox(height: 16),
                
//                 CustomTextField(
//                   controller: _usernameController,
//                   labelText: 'Tên đăng nhập',
//                   hintText: 'Nhập tên đăng nhập',
//                   prefixIcon: Icons.account_circle,
//                   validator: (value) => ValidationHelper.validateUsername(value),
//                 ),
//                 const SizedBox(height: 16),
                
//                 CustomTextField(
//                   controller: _emailController,
//                   labelText: 'Email',
//                   hintText: 'Nhập địa chỉ email',
//                   prefixIcon: Icons.email,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) => ValidationHelper.validateEmail(value),
//                 ),
//                 const SizedBox(height: 16),
                
//                 PasswordTextField(
//                   controller: _passwordController,
//                   labelText: 'Mật khẩu',
//                   hintText: 'Nhập mật khẩu',
//                   validator: (value) => ValidationHelper.validatePassword(value),
//                 ),
//                 const SizedBox(height: 16),
                
//                 PasswordTextField(
//                   controller: _confirmPasswordController,
//                   labelText: 'Xác nhận mật khẩu',
//                   hintText: 'Nhập lại mật khẩu',
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng xác nhận mật khẩu';
//                     }
//                     if (value != _passwordController.text) {
//                       return 'Mật khẩu xác nhận không khớp';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 32),
                
//                 // Nút đăng ký
//                 CustomButton(
//                   text: 'Đăng Ký',
//                   onPressed: _register,
//                   isLoading: authProvider.isLoading,
//                   isFullWidth: true,
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Đã có tài khoản
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Đã có tài khoản? ',
//                       style: TextStyle(color: AppColors.textSecondary),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text(
//                         'Đăng nhập',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
// Sửa cách import để tránh xung đột với lớp State và Center
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../helpers/validation_helper.dart';
import '../../helpers/image_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  File? _selectedImageFile;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }
  
  Future<void> _selectImage() async {
    final image = await showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ảnh đại diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                final imageFile = await ImageHelper.pickImageFromGallery();
                Navigator.of(context).pop(imageFile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () async {
                final imageFile = await ImageHelper.takePhoto();
                Navigator.of(context).pop(imageFile);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
    
    if (image != null) {
      setState(() {
        _selectedImageFile = image;
      });
    }
  }
  
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu xác nhận không khớp'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Save avatar image if selected
      String? avatarPath;
      try {
        if (_selectedImageFile != null) {
          // Generate a temporary ID to save the avatar with
          final tempId = ObjectId();
          avatarPath = await ImageHelper.saveProfileImage(
            _selectedImageFile!, 
            tempId.toString()
          );
          print('Đã lưu ảnh đại diện tại: $avatarPath');
        }
      } catch (e) {
        print('Lỗi khi lưu ảnh đại diện: $e');
      }
      
      final success = await authProvider.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        avatarUrl: avatarPath,
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successRegister),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Đăng ký thất bại'),
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
        title: 'Đăng Ký Tài Khoản',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ảnh đại diện
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary,
                        child: _selectedImageFile != null 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.file(
                                _selectedImageFile!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: _selectImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Form đăng ký
                CustomTextField(
                  controller: _fullNameController,
                  labelText: 'Họ và tên',
                  hintText: 'Nhập họ và tên đầy đủ',
                  prefixIcon: Icons.person,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => ValidationHelper.validateRequired(value, 'Họ và tên'),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _usernameController,
                  labelText: 'Tên đăng nhập',
                  hintText: 'Nhập tên đăng nhập',
                  prefixIcon: Icons.account_circle,
                  validator: (value) => ValidationHelper.validateUsername(value),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Nhập địa chỉ email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => ValidationHelper.validateEmail(value),
                ),
                const SizedBox(height: 16),
                
                PasswordTextField(
                  controller: _passwordController,
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu',
                  validator: ValidationHelper.validatePassword,
                ),
                const SizedBox(height: 16),
                
                PasswordTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Xác nhận mật khẩu',
                  hintText: 'Nhập lại mật khẩu',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Nút đăng ký
                CustomButton(
                  text: 'Đăng Ký',
                  onPressed: _register,
                  isLoading: authProvider.isLoading,
                  isFullWidth: true,
                ),
                const SizedBox(height: 16),
                
                // Đã có tài khoản
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}