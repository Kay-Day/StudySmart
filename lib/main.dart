import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/mongo_db.dart';
import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/study_session_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/document_provider.dart';
import 'providers/note_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/subjects/add_subject_screen.dart';
import 'screens/goals/add_goal_screen.dart';
import 'screens/documents/add_document_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/about_screen.dart';
import 'theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo kết nối MongoDB
  try {
    await MongoDatabase.initialize();
    print('Đã kết nối thành công đến MongoDB!');
  } catch (e) {
    print('Lỗi khi kết nối đến MongoDB: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => StudySessionProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light, // Mặc định sử dụng theme sáng
        initialRoute: '/login', // Màn hình ban đầu khi mở ứng dụng
        routes: {
          // Xác thực
          LoginScreen.routeName: (context) => const LoginScreen(),
          RegisterScreen.routeName: (context) => const RegisterScreen(),
          
          // Màn hình chính
          HomeScreen.routeName: (context) => const HomeScreen(),
          
          // Môn học
          AddSubjectScreen.routeName: (context) => const AddSubjectScreen(),
          
          // Mục tiêu
          AddGoalScreen.routeName: (context) => const AddGoalScreen(),
          
          // Tài liệu
          AddDocumentScreen.routeName: (context) => const AddDocumentScreen(),
          
          // Cài đặt
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          ChangePasswordScreen.routeName: (context) => const ChangePasswordScreen(),
          AboutScreen.routeName: (context) => const AboutScreen(),
        },
      ),
    );
  }
}