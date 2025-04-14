// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/app_colors.dart';
// import '../../helpers/validation_helper.dart';
// import '../../helpers/image_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_app_bar.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_text_field.dart';

// class ProfileScreen extends StatefulWidget {
//   static const String routeName = '/profile';
  
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _fullNameController;
//   late TextEditingController _emailController;
//   late TextEditingController _usernameController;
  
//   File? _selectedImageFile;
//   bool _isUpdatingAvatar = false;
  
//   @override
//   void initState() {
//     super.initState();
//     final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
//     _fullNameController = TextEditingController(text: user?.fullName ?? '');
//     _emailController = TextEditingController(text: user?.email ?? '');
//     _usernameController = TextEditingController(text: user?.username ?? '');
//   }
  
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _usernameController.dispose();
//     super.dispose();
//   }
  
//   Future<void> _selectImage() async {
//     final image = await showDialog<File?>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Chọn ảnh đại diện'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Chọn từ thư viện'),
//               onTap: () async {
//                 final imageFile = await ImageHelper.pickImageFromGallery();
//                 Navigator.of(context).pop(imageFile);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Chụp ảnh mới'),
//               onTap: () async {
//                 final imageFile = await ImageHelper.takePhoto();
//                 Navigator.of(context).pop(imageFile);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(null),
//             child: const Text('Hủy'),
//           ),
//         ],
//       ),
//     );
    
//     if (image != null) {
//       setState(() {
//         _selectedImageFile = image;
//       });
//     }
//   }
  
//   Future<void> _updateAvatar() async {
//     if (_selectedImageFile == null) return;
    
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.currentUser == null) return;
    
//     setState(() {
//       _isUpdatingAvatar = true;
//     });
    
//     try {
//       // Lưu ảnh vào thư mục ứng dụng
//       final savedImagePath = await ImageHelper.saveProfileImage(
//         _selectedImageFile!,
//         authProvider.currentUser!.id.toString(),
//       );
      
//       if (savedImagePath != null && mounted) {
//         // Cập nhật avatar URL
//         final success = await authProvider.updateAvatar(savedImagePath);
        
//         if (success && mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Đã cập nhật ảnh đại diện'),
//               backgroundColor: AppColors.success,
//             ),
//           );
//         } else if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(authProvider.error ?? 'Không thể cập nhật ảnh đại diện'),
//               backgroundColor: AppColors.error,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('Lỗi khi cập nhật ảnh đại diện: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Lỗi khi cập nhật ảnh đại diện: $e'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUpdatingAvatar = false;
//         });
//       }
//     }
//   }
  
//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
//       final success = await authProvider.updateUserInfo(
//         fullName: _fullNameController.text.trim(),
//       );
      
//       if (success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Cập nhật thông tin thành công'),
//             backgroundColor: AppColors.success,
//           ),
//         );
        
//         // Nếu có ảnh mới, cập nhật ảnh đại diện
//         if (_selectedImageFile != null) {
//           await _updateAvatar();
//         }
//       } else if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.error ?? 'Cập nhật thông tin thất bại'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;
    
//     if (user == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text('Bạn cần đăng nhập để xem thông tin này'),
//         ),
//       );
//     }
    
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Thông Tin Cá Nhân',
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Ảnh đại diện
//               Center(
//                 child: Stack(
//                   children: [
//                     // Hiển thị ảnh
//                     CircleAvatar(
//                       radius: 60,
//                       backgroundColor: AppColors.primary,
//                       child: _selectedImageFile != null 
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(60),
//                             child: Image.file(
//                               _selectedImageFile!,
//                               width: 120,
//                               height: 120,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : user.avatarUrl != null && user.avatarUrl!.isNotEmpty
//                             ? _buildAvatarImage(user.avatarUrl!)
//                             : Text(
//                                 user.fullName.substring(0, 1).toUpperCase(),
//                                 style: const TextStyle(
//                                   fontSize: 40,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                     ),
//                     // Nút thay đổi ảnh
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: InkWell(
//                         onTap: _isUpdatingAvatar ? null : _selectImage,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: AppColors.secondary,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.white,
//                               width: 2,
//                             ),
//                           ),
//                           child: _isUpdatingAvatar
//                               ? const SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Icon(
//                                   Icons.camera_alt,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Thông tin cá nhân
//               CustomTextField(
//                 controller: _fullNameController,
//                 labelText: 'Họ và tên',
//                 hintText: 'Nhập họ và tên của bạn',
//                 prefixIcon: Icons.person,
//                 textCapitalization: TextCapitalization.words,
//                 validator: (value) => ValidationHelper.validateRequired(
//                   value ?? '', 'Họ và tên'
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Email (chỉ đọc)
//               CustomTextField(
//                 controller: _emailController,
//                 labelText: 'Email',
//                 prefixIcon: Icons.email,
//                 readOnly: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 16),
              
//               // Username (chỉ đọc)
//               CustomTextField(
//                 controller: _usernameController,
//                 labelText: 'Tên đăng nhập',
//                 prefixIcon: Icons.account_circle,
//                 readOnly: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),
              
//               // Nút lưu
//               CustomButton(
//                 text: 'Cập Nhật Thông Tin',
//                 onPressed: _updateProfile,
//                 isLoading: authProvider.isLoading,
//                 isFullWidth: true,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildAvatarImage(String avatarUrl) {
//     // Kiểm tra xem đường dẫn có phải là đường dẫn local không
//     if (avatarUrl.startsWith('/')) {
//       // Đường dẫn local
//       final file = File(avatarUrl);
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(60),
//         child: Image.file(
//           file,
//           width: 120,
//           height: 120,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return const Icon(
//               Icons.person,
//               size: 40,
//               color: Colors.white,
//             );
//           },
//         ),
//       );
//     } else {
//       // URL từ internet
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(60),
//         child: Image.network(
//           avatarUrl,
//           width: 120,
//           height: 120,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return const CircularProgressIndicator(
//               color: Colors.white,
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return const Icon(
//               Icons.person,
//               size: 40,
//               color: Colors.white,
//             );
//           },
//         ),
//       );
//     }
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../helpers/validation_helper.dart';
import '../../helpers/image_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  
  File? _selectedImageFile;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
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
  
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser == null) return;
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Xử lý cập nhật avatar nếu có chọn ảnh mới
        String? newAvatarPath;
        if (_selectedImageFile != null) {
          // Lưu ảnh vào thư mục ứng dụng
          newAvatarPath = await ImageHelper.saveProfileImage(
            _selectedImageFile!,
            authProvider.currentUser!.id.toString(),
          );
          
          print('Đã lưu ảnh mới tại: $newAvatarPath');
        }
        
        // Sau đó cập nhật thông tin người dùng
        final success = await authProvider.updateUserInfo(
          fullName: _fullNameController.text.trim(),
          avatarUrl: newAvatarPath, // Truyền đường dẫn ảnh mới (nếu có)
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Cập nhật thông tin thất bại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        print('Lỗi khi cập nhật thông tin: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật thông tin: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Bạn cần đăng nhập để xem thông tin này'),
        ),
      );
    }
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Thông Tin Cá Nhân',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ảnh đại diện
              Center(
                child: Stack(
                  children: [
                    // Hiển thị ảnh
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
                        : user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? _buildAvatarImage(user.avatarUrl!)
                            : Text(
                                user.fullName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                    // Nút thay đổi ảnh
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _isLoading ? null : _selectImage,
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
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
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
              
              // Thông tin cá nhân
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Họ và tên',
                hintText: 'Nhập họ và tên của bạn',
                prefixIcon: Icons.person,
                textCapitalization: TextCapitalization.words,
                validator: (value) => ValidationHelper.validateRequired(
                  value ?? '', 'Họ và tên'
                ),
              ),
              const SizedBox(height: 16),
              
              // Email (chỉ đọc)
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                prefixIcon: Icons.email,
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 16),
              
              // Username (chỉ đọc)
              CustomTextField(
                controller: _usernameController,
                labelText: 'Tên đăng nhập',
                prefixIcon: Icons.account_circle,
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 32),
              
              // Nút lưu
              CustomButton(
                text: 'Cập Nhật Thông Tin',
                onPressed: _updateProfile,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAvatarImage(String avatarUrl) {
    // Kiểm tra xem đường dẫn có phải là đường dẫn local không
    if (avatarUrl.startsWith('/')) {
      // Đường dẫn local
      final file = File(avatarUrl);
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.file(
          file,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Lỗi khi hiển thị ảnh từ đường dẫn local: $error');
            return const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            );
          },
        ),
      );
    } else {
      // URL từ internet
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          avatarUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator(
              color: Colors.white,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Lỗi khi hiển thị ảnh từ URL: $error');
            return const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            );
          },
        ),
      );
    }
  }
}