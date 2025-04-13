import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/subject.dart';
import '../../../providers/study_session_provider.dart';
import '../../../providers/subject_provider.dart';
import '../../../providers/auth_provider.dart';
import '../edit_subject_screen.dart';
import '../subject_detail_screen.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final StudySessionProvider sessionProvider;
  final VoidCallback onRefresh;
  
  const SubjectCard({
    Key? key,
    required this.subject,
    required this.sessionProvider,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjectColor = AppColors.fromHex(subject.color);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(subject: subject),
          ),
        ).then((_) => onRefresh());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: subjectColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildPopupMenu(context),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mô tả
                  if (subject.description != null && subject.description!.isNotEmpty) ...[
                    Text(
                      subject.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Thông tin
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.timer,
                        'Mục tiêu',
                        '${subject.targetHoursPerWeek} giờ/tuần',
                      ),
                      const Spacer(),
                      _buildStartStudyButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
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
  
  Widget _buildStartStudyButton(BuildContext context) {
    final isStudying = sessionProvider.hasActiveSession && 
        sessionProvider.activeSubjectId == subject.id;
    
    return ElevatedButton.icon(
      onPressed: isStudying
          ? null // Không cho phép học nếu đang học môn này
          : sessionProvider.hasActiveSession
              ? null // Không cho phép học nếu đang học môn khác
              : () {
                  sessionProvider.startSession(subject.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bắt đầu học ${subject.name}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
      icon: Icon(
        isStudying ? Icons.hourglass_top : Icons.play_arrow,
        size: 18,
      ),
      label: Text(
        isStudying ? 'Đang học' : 'Bắt đầu học',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isStudying ? AppColors.textHint : AppColors.fromHex(subject.color),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _editSubject(context);
            break;
          case 'delete':
            _deleteSubject(context);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
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
    );
  }
  
  void _editSubject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSubjectScreen(subject: subject),
      ),
    ).then((_) => onRefresh());
  }
  
  Future<void> _deleteSubject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa môn học'),
        content: Text(
          'Bạn có chắc chắn muốn xóa môn học "${subject.name}" không? '
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
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      final success = await subjectProvider.deleteSubject(subject.id);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa môn học'),
            backgroundColor: AppColors.success,
          ),
        );
        onRefresh();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(subjectProvider.error ?? 'Không thể xóa môn học'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}