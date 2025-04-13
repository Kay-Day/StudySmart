import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../data/models/goal.dart';
import '../../data/models/subject.dart';
import '../../helpers/validation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class AddGoalScreen extends StatefulWidget {
  static const String routeName = '/add-goal';
  
  const AddGoalScreen({Key? key}) : super(key: key);

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  Subject? _selectedSubject;
  bool _isLoadingSubjects = true;
  List<Subject> _subjects = [];
  int _progressPercentage = 0;
  
  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSubjects() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      
      setState(() {
        _isLoadingSubjects = true;
      });
      
      await subjectProvider.loadSubjects(authProvider.currentUser!.id);
      
      if (mounted) {
        setState(() {
          _subjects = subjectProvider.subjects;
          _isLoadingSubjects = false;
        });
      }
    }
  }
  
  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }
  
  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập để thực hiện thao tác này'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final newGoal = Goal(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: authProvider.currentUser!.id,
        subjectId: _selectedSubject?.id,
        deadline: _deadline,
        status: _progressPercentage > 0 ? GoalStatus.inProgress : GoalStatus.notStarted,
        progressPercentage: _progressPercentage,
      );
      
      final success = await goalProvider.addGoal(newGoal);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm mục tiêu thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalProvider.error ?? 'Không thể thêm mục tiêu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Thêm Mục Tiêu',
      ),
      body: _isLoadingSubjects
          ? const LoadingIndicator(message: 'Đang tải dữ liệu...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Tiêu đề mục tiêu',
                      hintText: 'Nhập tiêu đề mục tiêu',
                      prefixIcon: Icons.title,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) => ValidationHelper.validateRequired(
                        value ?? '', 'Tiêu đề mục tiêu'
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Mô tả
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Mô tả chi tiết',
                      hintText: 'Nhập mô tả chi tiết về mục tiêu',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                      validator: (value) => ValidationHelper.validateRequired(
                        value ?? '', 'Mô tả mục tiêu'
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Chọn môn học (nếu có)
                    if (_subjects.isNotEmpty) ...[
                      const Text(
                        'Môn học (không bắt buộc):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Subject>(
                        decoration: const InputDecoration(
                          labelText: 'Chọn môn học',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.book),
                        ),
                        value: _selectedSubject,
                        hint: const Text('Chọn môn học liên quan'),
                        items: _subjects.map((subject) {
                          return DropdownMenuItem<Subject>(
                            value: subject,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.fromHex(subject.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(subject.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Chọn deadline
                    const Text(
                      'Ngày hạn chót:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDeadline,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd/MM/yyyy').format(_deadline),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tiến độ hiện tại
                    const Text(
                      'Tiến độ hiện tại:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('0%'),
                            Text(
                              '$_progressPercentage%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text('100%'),
                          ],
                        ),
                        Slider(
                          value: _progressPercentage.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.divider,
                          label: '$_progressPercentage%',
                          onChanged: (value) {
                            setState(() {
                              _progressPercentage = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Nút lưu
                    Center(
                      child: CustomButton(
                        text: 'Lưu Mục Tiêu',
                        onPressed: _saveGoal,
                        isLoading: goalProvider.isLoading,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}