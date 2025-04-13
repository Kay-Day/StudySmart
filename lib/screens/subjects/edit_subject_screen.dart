import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../data/models/subject.dart';
import '../../helpers/validation_helper.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditSubjectScreen extends StatefulWidget {
  final Subject subject;
  
  const EditSubjectScreen({
    Key? key,
    required this.subject,
  }) : super(key: key);

  @override
  _EditSubjectScreenState createState() => _EditSubjectScreenState();
}

class _EditSubjectScreenState extends State<EditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetHoursController;
  late String _selectedColor;
  late int _targetHours;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _descriptionController = TextEditingController(text: widget.subject.description ?? '');
    _targetHours = widget.subject.targetHoursPerWeek;
    _targetHoursController = TextEditingController(text: _targetHours.toString());
    _selectedColor = widget.subject.color.replaceFirst('#', '');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetHoursController.dispose();
    super.dispose();
  }
  
  Future<void> _updateSubject() async {
    if (_formKey.currentState!.validate()) {
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      
      final updatedSubject = Subject(
        id: widget.subject.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: '#$_selectedColor',
        userId: widget.subject.userId,
        targetHoursPerWeek: _targetHours,
        createdAt: widget.subject.createdAt,
      );
      
      final success = await subjectProvider.updateSubject(updatedSubject);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật môn học thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(subjectProvider.error ?? 'Không thể cập nhật môn học'),
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
      appBar: CustomAppBar(
        title: 'Chỉnh Sửa ${widget.subject.name}',
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
                  text: 'Cập Nhật Môn Học',
                  onPressed: _updateSubject,
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