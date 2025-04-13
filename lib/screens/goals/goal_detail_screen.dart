import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../data/models/goal.dart';
import '../../data/models/subject.dart';
import '../../helpers/date_time_helper.dart';
import '../../providers/goal_provider.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  
  const GoalDetailScreen({
    Key? key,
    required this.goal,
  }) : super(key: key);

  @override
  _GoalDetailScreenState createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  bool _isLoading = true;
  Subject? _subject;
  
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
      if (widget.goal.subjectId != null) {
        final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
        _subject = await subjectProvider.getSubjectById(widget.goal.subjectId!);
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
  
  void _showUpdateProgressDialog() {
    int progress = widget.goal.progressPercentage;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật tiến độ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kéo để điều chỉnh tiến độ:'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Slider(
                      value: progress.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '$progress%',
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          progress = value.round();
                        });
                      },
                    ),
                    Text(
                      '$progress%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              GoalStatus newStatus;
              if (progress == 100) {
                newStatus = GoalStatus.completed;
              } else if (progress == 0) {
                newStatus = GoalStatus.notStarted;
              } else {
                newStatus = GoalStatus.inProgress;
              }
              
              final goalProvider = Provider.of<GoalProvider>(context, listen: false);
              final success = await goalProvider.updateGoalStatus(
                widget.goal.id,
                newStatus,
                progress,
              );
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật tiến độ'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.of(context).pop(); // Quay lại màn hình danh sách mục tiêu
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      goalProvider.error ?? 'Không thể cập nhật tiến độ',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu'),
        content: Text(
          'Bạn có chắc chắn muốn xóa mục tiêu "${widget.goal.title}" không? '
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
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      final success = await goalProvider.deleteGoal(widget.goal.id);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa mục tiêu'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(); // Quay lại màn hình danh sách mục tiêu
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalProvider.error ?? 'Không thể xóa mục tiêu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final daysLeft = widget.goal.deadline.difference(DateTime.now()).inDays;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chi Tiết Mục Tiêu',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGoal,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải thông tin...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    widget.goal.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Thông tin mục tiêu
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  
                  // Tiến độ
                  _buildProgressCard(),
                  const SizedBox(height: 16),
                  
                  // Nếu chưa hoàn thành, hiển thị nút cập nhật
                  if (widget.goal.status != GoalStatus.completed && widget.goal.status != GoalStatus.failed) ...[
                    // Nút cập nhật tiến độ
                    CustomButton(
                      text: 'Cập Nhật Tiến Độ',
                      icon: Icons.update,
                      onPressed: _showUpdateProgressDialog,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    
                    // Nút đánh dấu hoàn thành
                    CustomButton(
                      text: 'Đánh Dấu Hoàn Thành',
                      icon: Icons.check_circle,
                      type: ButtonType.secondary,
                      onPressed: () async {
                        final goalProvider = Provider.of<GoalProvider>(context, listen: false);
                        final success = await goalProvider.updateGoalStatus(
                          widget.goal.id,
                          GoalStatus.completed,
                          100,
                        );
                        
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã đánh dấu mục tiêu hoàn thành'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.of(context).pop(); // Quay lại màn hình danh sách mục tiêu
                        }
                      },
                      isFullWidth: true,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin chi tiết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mô tả
            const Text(
              'Mô tả:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.goal.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            // Môn học
            if (_subject != null) ...[
              const Text(
                'Môn học:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.fromHex(_subject!.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _subject!.name,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Thời hạn
            const Text(
              'Hạn chót:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateTimeHelper.formatDateWithWeekday(widget.goal.deadline),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Trạng thái
            const Text(
              'Trạng thái:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(),
            const SizedBox(height: 8),
            
            // Ngày tạo
            const Text(
              'Ngày tạo:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateTimeHelper.formatDateTime(widget.goal.createdAt),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến độ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: widget.goal.progressPercentage / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${widget.goal.progressPercentage}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'hoàn thành',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            LinearProgressIndicator(
              value: widget.goal.progressPercentage / 100,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            
            Text(
              'Cập nhật lần cuối: ${DateTimeHelper.formatDateTime(widget.goal.updatedAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip() {
    Color statusColor = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            widget.goal.status.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (widget.goal.status) {
      case GoalStatus.notStarted:
        return AppColors.textSecondary;
      case GoalStatus.inProgress:
        return AppColors.primary;
      case GoalStatus.completed:
        return AppColors.success;
      case GoalStatus.failed:
        return AppColors.error;
    }
  }
  
  IconData _getStatusIcon() {
    switch (widget.goal.status) {
      case GoalStatus.notStarted:
        return Icons.pending;
      case GoalStatus.inProgress:
        return Icons.timelapse;
      case GoalStatus.completed:
        return Icons.check_circle;
      case GoalStatus.failed:
        return Icons.cancel;
    }
  }
}