import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../data/models/subject.dart';
import '../../helpers/validation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddSubjectScreen extends StatefulWidget {
  static const String routeName = '/add-subject';
  
  const AddSubjectScreen({Key? key}) : super(key: key);

  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetHoursController = TextEditingController();
  String _selectedColor = AppColors.subjectColors.first.value.toRadixString(16).substring(2);
  int _targetHours = 5;
  
  @override
  void initState() {
    super.initState();
    _targetHoursController.text = _targetHours.toString();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetHoursController.dispose();
    super.dispose();
  }
  
  Future<void> _saveSubject() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập để thực hiện thao tác này'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final newSubject = Subject(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: '#$_selectedColor',
        userId: authProvider.currentUser!.id,
        targetHoursPerWeek: _targetHours,
      );
      
      final success = await subjectProvider.addSubject(newSubject);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm môn học thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(subjectProvider.error ?? 'Không thể thêm môn học'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Thêm Môn Học',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên môn học
              CustomTextField(
                controller: _nameController,
                labelText: 'Tên môn học',
                hintText: 'Nhập tên môn học',
                prefixIcon: Icons.book,
                textCapitalization: TextCapitalization.words,
                validator: (value) => ValidationHelper.validateRequired(
                  value ?? '', 'Tên môn học'
                ),
              ),
              const SizedBox(height: 16),
              
              // Mô tả
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Mô tả (không bắt buộc)',
                hintText: 'Nhập mô tả về môn học',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Thời lượng mục tiêu
              CustomTextField(
                controller: _targetHoursController,
                labelText: 'Số giờ học mỗi tuần',
                hintText: 'Nhập số giờ mục tiêu mỗi tuần',
                prefixIcon: Icons.timer,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) => ValidationHelper.validatePositiveInteger(
                  value ?? '', 'Số giờ'
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && ValidationHelper.isPositiveInteger(value)) {
                    setState(() {
                      _targetHours = int.parse(value);
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Chọn màu
              const Text(
                'Chọn màu:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildColorPicker(),
              const SizedBox(height: 32),
              
              // Nút lưu
              Center(
                child: CustomButton(
                  text: 'Lưu Môn Học',
                  onPressed: _saveSubject,
                  isLoading: subjectProvider.isLoading,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppColors.subjectColors.map((color) {
        final colorHex = color.value.toRadixString(16).substring(2);
        final isSelected = colorHex == _selectedColor;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = colorHex;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}