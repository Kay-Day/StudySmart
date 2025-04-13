import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/study_session_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'add_subject_screen.dart';
import 'widgets/subject_card.dart';

class SubjectsScreen extends StatefulWidget {
  static const String routeName = '/subjects';
  
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }
  
  Future<void> _loadSubjects() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
      });
      
      await subjectProvider.loadSubjects(authProvider.currentUser!.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _addSubject() {
    Navigator.pushNamed(context, AddSubjectScreen.routeName).then((_) {
      _loadSubjects();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final sessionProvider = Provider.of<StudySessionProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Môn Học',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubjects,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải danh sách môn học...')
          : RefreshIndicator(
              onRefresh: _loadSubjects,
              child: subjectProvider.subjects.isEmpty
                  ? const EmptyState(
                      title: 'Chưa có môn học',
                      message: 'Hãy thêm môn học để theo dõi và quản lý việc học tập',
                      icon: Icons.book,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: subjectProvider.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjectProvider.subjects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: SubjectCard(
                            subject: subject,
                            sessionProvider: sessionProvider,
                            onRefresh: _loadSubjects,
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubject,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        tooltip: 'Thêm môn học',
      ),
    );
  }
}