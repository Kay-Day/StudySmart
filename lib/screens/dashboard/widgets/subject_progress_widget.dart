import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/subject.dart';
import '../../../helpers/date_time_helper.dart';
import '../../../widgets/empty_state.dart';

class SubjectProgressWidget extends StatelessWidget {
  final List<Subject> subjects;
  final Map<String, int> subjectStudyTimes;
  
  const SubjectProgressWidget({
    Key? key,
    required this.subjects,
    required this.subjectStudyTimes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const EmptyState(
        title: 'Chưa có môn học nào',
        message: 'Hãy thêm môn học để theo dõi tiến độ học tập của bạn',
        icon: Icons.book,
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
        itemCount: subjects.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final subjectId = subject.id.toString();
          final studyMinutes = subjectStudyTimes[subjectId] ?? 0;
          final studyHours = studyMinutes / 60;
          final targetHours = subject.targetHoursPerWeek.toDouble();
          final progress = studyHours / targetHours;
          
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.fromHex(subject.color),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  subject.name.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              subject.name,
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
                    Text(
                      'Mục tiêu: ${targetHours.toStringAsFixed(1)} giờ/tuần',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đã học: ${studyHours.toStringAsFixed(1)} giờ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(
                      height: 6,
                      width: MediaQuery.of(context).size.width * 0.65 * progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        color: _getProgressColor(progress),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% hoàn thành',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Điều hướng đến chi tiết môn học
            },
          );
        },
      ),
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return AppColors.success;
    } else if (progress >= 0.6) {
      return AppColors.primary;
    } else if (progress >= 0.3) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}