import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../data/models/document.dart';
import '../../data/models/subject.dart';
import '../../helpers/file_helper.dart';
import '../../helpers/validation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class AddDocumentScreen extends StatefulWidget {
  static const String routeName = '/add-document';
  
  const AddDocumentScreen({Key? key}) : super(key: key);

  @override
  _AddDocumentScreenState createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  
  bool _isLoadingSubjects = true;
  bool _isUploading = false;
  File? _selectedFile;
  String _fileName = '';
  int _fileSize = 0;
  String _fileType = '';
  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  List<String> _tags = [];
  
  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
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
  
  Future<void> _pickFile() async {
    setState(() {
      _isUploading = true;
    });
    
    try {
      final file = await FileHelper.pickFile(
        dialogTitle: 'Chọn tài liệu',
      );
      
      if (file != null) {
        final fileName = file.path.split('/').last;
        final fileSize = await file.length();
        final fileType = FileHelper.getFileType(fileName);
        
        setState(() {
          _selectedFile = file;
          _fileName = fileName;
          _fileSize = fileSize;
          _fileType = fileType;
          
          // Tự động điền tiêu đề từ tên file
          if (_titleController.text.isEmpty) {
            // Loại bỏ phần mở rộng
            final titleWithoutExt = fileName.contains('.')
                ? fileName.substring(0, fileName.lastIndexOf('.'))
                : fileName;
            _titleController.text = titleWithoutExt;
          }
        });
      }
    } catch (e) {
      print('Lỗi khi chọn file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  
  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagsController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Future<void> _saveDocument() async {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập để thực hiện thao tác này'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      setState(() {
        _isUploading = true;
      });
      
      try {
        // Lưu file vào thư mục ứng dụng
        final savedFilePath = await FileHelper.saveFile(_selectedFile!, _fileName);
        
        if (savedFilePath != null) {
          final newDocument = Document(
            title: _titleController.text.trim(),
            fileName: _fileName,
            filePath: savedFilePath,
            fileType: _fileType,
            fileSize: _fileSize,
            userId: authProvider.currentUser!.id,
            subjectId: _selectedSubject?.id,
            tags: _tags,
          );
          
          final success = await documentProvider.addDocument(newDocument);
          
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã thêm tài liệu thành công'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(documentProvider.error ?? 'Không thể thêm tài liệu'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể lưu file'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        print('Lỗi khi lưu tài liệu: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi lưu tài liệu: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    } else if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một file'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Thêm Tài Liệu',
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
                    // Chọn file
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Chọn tài liệu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: _selectedFile != null
                                  ? 'Chọn file khác'
                                  : 'Chọn file từ thiết bị',
                              onPressed: _pickFile,
                              icon: Icons.file_upload,
                              isLoading: _isUploading,
                              isFullWidth: true,
                            ),
                            if (_selectedFile != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getFileColor(_fileType).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getFileIcon(_fileType),
                                          color: _getFileColor(_fileType),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _fileName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                _fileType,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getFileColor(_fileType),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                FileHelper.formatFileSize(_fileSize),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Thông tin tài liệu
                    const Text(
                      'Thông tin tài liệu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Tiêu đề
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Tiêu đề tài liệu',
                      hintText: 'Nhập tiêu đề cho tài liệu',
                      prefixIcon: Icons.title,
                      validator: (value) => ValidationHelper.validateRequired(
                        value ?? '', 'Tiêu đề tài liệu'
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Chọn môn học (nếu có)
                    if (_subjects.isNotEmpty) ...[
                      const Text(
                        'Môn học (không bắt buộc):',
                        style: TextStyle(
                          fontSize: 14,
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
                    
                    // Thêm tags
                    const Text(
                      'Tags (không bắt buộc):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _tagsController,
                            labelText: 'Thêm tag',
                            hintText: 'Nhập tag và nhấn Enter',
                            prefixIcon: Icons.tag,
                            onSubmitted: _addTag,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _addTag(_tagsController.text),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                          ),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    
                    // Nút lưu
                    CustomButton(
                      text: 'Lưu Tài Liệu',
                      onPressed: _saveDocument,
                      isLoading: _isUploading,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  IconData _getFileIcon(String fileType) {
    final type = fileType.toLowerCase();
    
    if (type.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (type.contains('doc') || type.contains('word')) {
      return Icons.description;
    } else if (type.contains('xls') || type.contains('excel')) {
      return Icons.table_chart;
    } else if (type.contains('ppt') || type.contains('powerpoint')) {
      return Icons.slideshow;
    } else if (type.contains('jpg') || type.contains('jpeg') || 
               type.contains('png') || type.contains('gif')) {
      return Icons.image;
    } else if (type.contains('mp3') || type.contains('wav') || 
               type.contains('audio')) {
      return Icons.audio_file;
    } else if (type.contains('mp4') || type.contains('avi') || 
               type.contains('video')) {
      return Icons.video_file;
    } else if (type.contains('txt') || type.contains('text')) {
      return Icons.article;
    } else {
      return Icons.insert_drive_file;
    }
  }
  
  Color _getFileColor(String fileType) {
    final type = fileType.toLowerCase();
    
    if (type.contains('pdf')) {
      return Colors.red;
    } else if (type.contains('doc') || type.contains('word')) {
      return Colors.blue;
    } else if (type.contains('xls') || type.contains('excel')) {
      return Colors.green;
    } else if (type.contains('ppt') || type.contains('powerpoint')) {
      return Colors.orange;
    } else if (type.contains('jpg') || type.contains('jpeg') || 
               type.contains('png') || type.contains('gif')) {
      return Colors.purple;
    } else if (type.contains('mp3') || type.contains('wav') || 
               type.contains('audio')) {
      return Colors.pink;
    } else if (type.contains('mp4') || type.contains('avi') || 
               type.contains('video')) {
      return Colors.red.shade700;
    } else if (type.contains('txt') || type.contains('text')) {
      return Colors.grey.shade700;
    } else {
      return AppColors.primary;
    }
  }
}