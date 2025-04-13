import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../data/models/document.dart';
import '../../helpers/date_time_helper.dart';
import '../../helpers/file_helper.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class DocumentViewerScreen extends StatefulWidget {
  final Document document;
  
  const DocumentViewerScreen({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  _DocumentViewerScreenState createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = true;
  String? _subjectName;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (widget.document.subjectId != null) {
        final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
        final subject = await subjectProvider.getSubjectById(widget.document.subjectId!);
        
        if (subject != null) {
          _subjectName = subject.name;
        }
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final document = widget.document;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: document.title,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải thông tin...')
          : Column(
              children: [
                // Thông tin tài liệu
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề và loại file
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getFileColor(document.fileType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                _getFileIcon(document.fileType),
                                color: _getFileColor(document.fileType),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  document.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  document.fileName,
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
                      const SizedBox(height: 16),
                      
                      // Thông tin chi tiết
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildInfoItem(
                            'Loại file',
                            document.fileType.toUpperCase(),
                            Icons.description,
                          ),
                          _buildInfoItem(
                            'Kích thước',
                            FileHelper.formatFileSize(document.fileSize),
                            Icons.data_usage,
                          ),
                          _buildInfoItem(
                            'Ngày thêm',
                            DateTimeHelper.formatDate(document.uploadDate),
                            Icons.calendar_today,
                          ),
                          if (_subjectName != null)
                            _buildInfoItem(
                              'Môn học',
                              _subjectName!,
                              Icons.book,
                            ),
                        ],
                      ),
                      
                      // Tags
                      if (document.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Tags:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: document.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppColors.border),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Nội dung file
                Expanded(
                  child: _buildFilePreview(),
                ),
              ],
            ),
    );
  }
  
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFilePreview() {
    final fileType = widget.document.fileType.toLowerCase();
    final file = File(widget.document.filePath);
    
    if (!file.existsSync()) {
      return const Center(
        child: Text(
          'Không tìm thấy file trên thiết bị',
          style: TextStyle(
            color: AppColors.error,
          ),
        ),
      );
    }
    
    if (fileType.contains('jpg') || 
        fileType.contains('jpeg') || 
        fileType.contains('png') || 
        fileType.contains('gif')) {
      // Hiển thị ảnh
      return Center(
        child: InteractiveViewer(
          child: Image.file(file),
        ),
      );
    } else if (fileType.contains('txt') || fileType.contains('text')) {
      // Hiển thị nội dung file text
      try {
        final content = file.readAsStringSync();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(content),
        );
      } catch (e) {
        return Center(
          child: Text(
            'Không thể đọc nội dung file: $e',
            style: const TextStyle(
              color: AppColors.error,
            ),
          ),
        );
      }
    } else {
      // Hiển thị thông báo cho các loại file khác
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileIcon(widget.document.fileType),
              size: 80,
              color: _getFileColor(widget.document.fileType),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể hiện thị trực tiếp loại file này',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Đường dẫn: ${widget.document.filePath}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Mở file bằng ứng dụng bên ngoài
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng mở file đang được phát triển'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Mở bằng ứng dụng khác'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
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