import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/goal.dart';
import '../../../helpers/date_time_helper.dart';
import '../../../widgets/empty_state.dart';

class UpcomingGoalsWidget extends StatelessWidget {
  final List<Goal> goals;
  
  const UpcomingGoalsWidget({
    Key? key,
    required this.goals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const EmptyState(
        title: 'Không có mục tiêu nào',
        message: 'Hãy thêm mục tiêu để theo dõi tiến độ học tập của bạn',
        icon: Icons.flag,
      );
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: goals.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final goal = goals[index];
          final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
          
          return ListTile(
            title: Text(
              goal.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
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
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: daysLeft <= 1
                            ? AppColors.error
                            : daysLeft <= 3
                                ? AppColors.warning
                                : AppColors.info,
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
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.status == GoalStatus.completed
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.progressPercentage}% hoàn thành',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              _getGoalStatusIcon(goal.status),
              color: _getGoalStatusColor(goal.status),
            ),
            onTap: () {
              // TODO: Điều hướng đến chi tiết mục tiêu
            },
          );
        },
      ),
    );
  }
  
  IconData _getGoalStatusIcon(GoalStatus status) {
    switch (status) {
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
  
  Color _getGoalStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.notStarted:
        return AppColors.textHint;
      case GoalStatus.inProgress:
        return AppColors.info;
      case GoalStatus.completed:
        return AppColors.success;
      case GoalStatus.failed:
        return AppColors.error;
    }
  }
}