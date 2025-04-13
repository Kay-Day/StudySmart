import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/goal.dart';
import '../../../providers/goal_provider.dart';
import '../../../helpers/date_time_helper.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  
  const GoalCard({
    Key? key,
    required this.goal,
    required this.onTap,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    
    // Xác định màu sắc dựa trên trạng thái
    Color statusColor = _getStatusColor(goal.status);
    
    // Xác định màu sắc dựa trên số ngày còn lại
    Color deadlineColor = _getDeadlineColor(daysLeft, goal.status);
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và trạng thái
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      goal.status.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Mô tả
              Text(
                goal.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Deadline và ngày còn lại
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hạn: ${DateTimeHelper.formatDate(goal.deadline)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (goal.status != GoalStatus.completed && goal.status != GoalStatus.failed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: deadlineColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        daysLeft <= 0
                            ? 'Hôm nay'
                            : 'Còn $daysLeft ngày',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Tiến độ
              LinearProgressIndicator(
                value: goal.progressPercentage / 100,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Text(
                    '${goal.progressPercentage}% hoàn thành',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  
                  // Cập nhật trạng thái
                  if (goal.status != GoalStatus.completed && goal.status != GoalStatus.failed)
                    _buildActionButtons(context, goalProvider),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, GoalProvider goalProvider) {
    return Row(
      children: [
        // Cập nhật tiến độ
        InkWell(
          onTap: () => _showUpdateProgressDialog(context, goalProvider),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                const Icon(
                  Icons.update,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Cập nhật',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Đánh dấu hoàn thành
        if (goal.status != GoalStatus.completed)
          InkWell(
            onTap: () => _markAsCompleted(context, goalProvider),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hoàn thành',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  void _showUpdateProgressDialog(BuildContext context, GoalProvider goalProvider) {
    int progress = goal.progressPercentage;
    
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
              
              final success = await goalProvider.updateGoalStatus(
                goal.id,
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
                onRefresh();
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
  
  void _markAsCompleted(BuildContext context, GoalProvider goalProvider) async {
    final success = await goalProvider.updateGoalStatus(
      goal.id,
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
      onRefresh();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            goalProvider.error ?? 'Không thể cập nhật trạng thái',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Color _getStatusColor(GoalStatus status) {
    switch (status) {
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
  
  Color _getDeadlineColor(int daysLeft, GoalStatus status) {
    if (status == GoalStatus.completed || status == GoalStatus.failed) {
      return AppColors.textHint;
    }
    
    if (daysLeft <= 0) {
      return AppColors.error;
    } else if (daysLeft <= 3) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }
}