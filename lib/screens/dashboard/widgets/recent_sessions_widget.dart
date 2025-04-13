import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/study_session.dart';
import '../../../data/models/subject.dart';
import '../../../helpers/date_time_helper.dart';
import '../../../widgets/empty_state.dart';

class RecentSessionsWidget extends StatelessWidget {
  final List<StudySession> sessions;
  final List<Subject> subjects;
  
  const RecentSessionsWidget({
    Key? key,
    required this.sessions,
    required this.subjects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const EmptyState(
        title: 'Chưa có phiên học nào',
        message: 'Bắt đầu một phiên học để theo dõi thời gian học tập của bạn',
        icon: Icons.timer,
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
        itemCount: sessions.length.clamp(0, 5), // Hiển thị tối đa 5 phiên
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final subject = _findSubject(session.subjectId);
          
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: subject != null
                    ? AppColors.fromHex(subject.color)
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer,
                color: Colors.white,
              ),
            ),
            title: Text(
              subject?.name ?? 'Môn học không xác định',
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
                      DateTimeHelper.formatDate(session.startTime),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateTimeHelper.formatTime(session.startTime)} - ${DateTimeHelper.formatTime(session.endTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Thời gian: ${DateTimeHelper.formatDuration(session.durationMinutes)}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildProductivityStars(session.productivityRating),
                  ],
                ),
              ],
            ),
            onTap: () {
              // TODO: Hiển thị chi tiết phiên học
            },
          );
        },
      ),
    );
  }
  
  Widget _buildProductivityStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: index < rating ? AppColors.warning : AppColors.textHint,
        );
      }),
    );
  }
  
  Subject? _findSubject(ObjectId subjectId) {
    for (var subject in subjects) {
      if (subject.id == subjectId) {
        return subject;
      }
    }
    return null;
  }
}