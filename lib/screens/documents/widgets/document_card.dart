import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/document.dart';
import '../../../helpers/date_time_helper.dart';
import '../../../helpers/file_helper.dart';
import '../../../providers/document_provider.dart';
import '../document_viewer_screen.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onRefresh;
  
  const DocumentCard({
    Key? key,
    required this.document,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          // Kiểm tra file có tồn tại không
          if (await FileHelper.fileExists(document.filePath)) {
            // Cập nhật lần truy cập gần nhất
            final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
            documentProvider.updateLastAccessDate(document.id);
            
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentViewerScreen(document: document),
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không tìm thấy file'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon loại file
              Container(
                width: 48,
                height: 48,
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
              
              // Thông tin file
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          document.fileType.toUpperCase(),
                          _getFileColor(document.fileType),
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          FileHelper.formatFileSize(document.fileSize),
                          AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thêm: ${DateTimeHelper.getTimeAgo(document.uploadDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      _viewDocument(context);
                      break;
                    case 'delete':
                      _deleteDocument(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('Xem'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Future<void> _viewDocument(BuildContext context) async {
    if (await FileHelper.fileExists(document.filePath)) {
      // Cập nhật lần truy cập gần nhất
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      documentProvider.updateLastAccessDate(document.id);
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewerScreen(document: document),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy file'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _deleteDocument(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài liệu'),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài liệu "${document.title}" không? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      
      // Xóa file trên thiết bị
      await FileHelper.deleteFile(document.filePath);
      
      // Xóa document trong database
      final success = await documentProvider.deleteDocument(document.id);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa tài liệu'),
            backgroundColor: AppColors.success,
          ),
        );
        onRefresh();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(documentProvider.error ?? 'Không thể xóa tài liệu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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