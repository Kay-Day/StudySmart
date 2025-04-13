// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:mongo_dart/mongo_dart.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../constants/app_colors.dart';
// import '../../data/models/subject.dart';
// import '../../data/models/goal.dart';
// import '../../data/models/study_session.dart';
// import '../../helpers/date_time_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/subject_provider.dart';
// import '../../providers/study_session_provider.dart';
// import '../../providers/goal_provider.dart';
// import '../../widgets/custom_app_bar.dart';
// import '../../widgets/loading_indicator.dart';
// import '../../widgets/empty_state.dart';
// import 'widgets/study_timer_widget.dart';
// import 'widgets/upcoming_goals_widget.dart';
// import 'widgets/recent_sessions_widget.dart';
// import 'widgets/subject_progress_widget.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({Key? key}) : super(key: key);

//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   bool _isLoading = true;
//   int _totalStudyMinutes = 0;
//   Map<String, int> _subjectStudyTimes = {};
//   List<Subject> _subjects = [];
//   List<StudySession> _recentSessions = [];
//   List<Goal> _upcomingGoals = [];
  
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
  
//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
//       final sessionProvider = Provider.of<StudySessionProvider>(context, listen: false);
//       final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      
//       if (authProvider.currentUser != null) {
//         final userId = authProvider.currentUser!.id;
        
//         // Lấy danh sách môn học
//         await subjectProvider.loadSubjects(userId);
//         _subjects = subjectProvider.subjects;
        
//         // Lấy danh sách phiên học gần đây
//         await sessionProvider.loadSessions(userId, limit: 10);
//         _recentSessions = sessionProvider.sessions;
        
//         // Lấy danh sách mục tiêu sắp tới
//         _upcomingGoals = await goalProvider.getUpcomingGoalsFromServer(userId, limit: 5);
        
//         // Lấy tổng thời gian học trong tuần
//         final now = DateTime.now();
//         final startOfWeek = DateTimeHelper.getFirstDayOfWeek(now);
//         final endOfWeek = DateTimeHelper.getLastDayOfWeek(now);
        
//         _totalStudyMinutes = await sessionProvider.getTotalStudyTime(
//           userId, 
//           startOfWeek,
//           endOfWeek,
//         );
        
//         // Lấy thời gian học theo môn học
//         _subjectStudyTimes = await sessionProvider.getTotalStudyTimeBySubject(
//           userId, 
//           startOfWeek,
//           endOfWeek,
//         );
//       }
//     } catch (e) {
//       print('Lỗi khi tải dữ liệu dashboard: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final sessionProvider = Provider.of<StudySessionProvider>(context);
    
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Tổng Quan',
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadData,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const LoadingIndicator(message: 'Đang tải dữ liệu...')
//           : RefreshIndicator(
//               onRefresh: _loadData,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Chào mừng người dùng
//                     Text(
//                       'Xin chào, ${authProvider.currentUser?.fullName ?? "Học sinh"}!',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Hôm nay là ${DateTimeHelper.formatDateWithWeekday(DateTime.now())}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Tổng quan thời gian học
//                     _buildWeeklyOverview(),
//                     const SizedBox(height: 24),
                    
//                     // Bộ hẹn giờ học tập
//                     const Text(
//                       'Bắt đầu phiên học mới',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     StudyTimerWidget(
//                       subjects: _subjects,
//                       sessionProvider: sessionProvider,
//                       userId: authProvider.currentUser?.id,
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Mục tiêu sắp tới
//                     const Text(
//                       'Mục tiêu sắp tới',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     UpcomingGoalsWidget(goals: _upcomingGoals),
//                     const SizedBox(height: 24),
                    
//                     // Tiến độ môn học
//                     const Text(
//                       'Tiến độ môn học',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SubjectProgressWidget(
//                       subjects: _subjects,
//                       subjectStudyTimes: _subjectStudyTimes,
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Phiên học gần đây
//                     const Text(
//                       'Phiên học gần đây',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     RecentSessionsWidget(
//                       sessions: _recentSessions,
//                       subjects: _subjects,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
  
//   Widget _buildWeeklyOverview() {
//     final totalHours = _totalStudyMinutes / 60;
//     final targetHours = 20.0; // Mục tiêu 20 giờ/tuần
//     final progress = totalHours / targetHours;
    
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Thời gian học trong tuần này',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${totalHours.toStringAsFixed(1)} giờ',
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       Text(
//                         'Mục tiêu: ${targetHours.toStringAsFixed(1)} giờ',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: SizedBox(
//                     height: 80,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 80,
//                           height: 80,
//                           child: CircularProgressIndicator(
//                             value: progress.clamp(0.0, 1.0),
//                             strokeWidth: 10,
//                             backgroundColor: AppColors.divider,
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                               AppColors.primary,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '${(progress * 100).toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_subjects.isNotEmpty && _subjectStudyTimes.isNotEmpty)
//               SizedBox(
//                 height: 120,
//                 child: BarChart(
//                   BarChartData(
//                     alignment: BarChartAlignment.center,
//                     barTouchData: BarTouchData(
//                       enabled: true,
//                       touchTooltipData: BarTouchTooltipData(
//                         tooltipBgColor: Colors.blueGrey.shade800,
//                         getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                           final subjectId = _subjects[groupIndex].id.toString();
//                           final minutes = _subjectStudyTimes[subjectId] ?? 0;
//                           final hours = minutes / 60;
//                           return BarTooltipItem(
//                             '${_subjects[groupIndex].name}\n${hours.toStringAsFixed(1)} giờ',
//                             const TextStyle(color: Colors.white),
//                           );
//                         }
//                       ),
//                     ),
//                     titlesData: FlTitlesData(
//                       show: true,
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             if (value >= 0 && value < _subjects.length) {
//                               return Text(
//                                 _subjects[value.toInt()].name.substring(0, 1),
//                                 style: const TextStyle(
//                                   color: AppColors.textSecondary,
//                                   fontSize: 12,
//                                 ),
//                               );
//                             }
//                             return const Text('');
//                           },
//                         ),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       topTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       rightTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                     ),
//                     borderData: FlBorderData(show: false),
//                     gridData: FlGridData(show: false),
//                     barGroups: List.generate(
//                       _subjects.length,
//                       (index) {
//                         final subject = _subjects[index];
//                         final subjectId = subject.id.toString();
//                         final minutes = _subjectStudyTimes[subjectId] ?? 0;
//                         final hours = minutes / 60;
                        
//                         return BarChartGroupData(
//                           x: index,
//                           barRods: [
//                             BarChartRodData(
//                               toY: hours,
//                               color: AppColors.fromHex(subject.color),
//                               width: 20,
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(4),
//                                 topRight: Radius.circular(4),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart' hide State;
import 'package:flutter/material.dart' as flutter show State;
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Center;
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../data/models/subject.dart';
import '../../data/models/goal.dart';
import '../../data/models/study_session.dart';
import '../../helpers/date_time_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/study_session_provider.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'widgets/study_timer_widget.dart';
import 'widgets/upcoming_goals_widget.dart';
import 'widgets/recent_sessions_widget.dart';
import 'widgets/subject_progress_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  flutter.State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends flutter.State<DashboardScreen> {
  bool _isLoading = true;
  int _totalStudyMinutes = 0;
  Map<String, int> _subjectStudyTimes = {};
  List<Subject> _subjects = [];
  List<StudySession> _recentSessions = [];
  List<Goal> _upcomingGoals = [];
  
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      final sessionProvider = Provider.of<StudySessionProvider>(context, listen: false);
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        final userId = authProvider.currentUser!.id;
        
        // Lấy danh sách môn học
        await subjectProvider.loadSubjects(userId);
        _subjects = subjectProvider.subjects;
        
        // Lấy danh sách phiên học gần đây
        await sessionProvider.loadSessions(userId, limit: 10);
        _recentSessions = sessionProvider.sessions;
        
        // Lấy danh sách mục tiêu sắp tới
        _upcomingGoals = await goalProvider.getUpcomingGoalsFromServer(userId, limit: 5);
        
        // Lấy tổng thời gian học trong tuần
        final now = DateTime.now();
        final startOfWeek = DateTimeHelper.getFirstDayOfWeek(now);
        final endOfWeek = DateTimeHelper.getLastDayOfWeek(now);
        
        _totalStudyMinutes = await sessionProvider.getTotalStudyTime(
          userId, 
          startOfWeek,
          endOfWeek,
        );
        
        // Lấy thời gian học theo môn học
        _subjectStudyTimes = await sessionProvider.getTotalStudyTimeBySubject(
          userId, 
          startOfWeek,
          endOfWeek,
        );
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu dashboard: $e');
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
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionProvider = Provider.of<StudySessionProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tổng Quan',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải dữ liệu...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chào mừng người dùng
                    Text(
                      'Xin chào, ${authProvider.currentUser?.fullName ?? "Học sinh"}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hôm nay là ${DateTimeHelper.formatDateWithWeekday(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tổng quan thời gian học
                    _buildWeeklyOverview(),
                    const SizedBox(height: 24),
                    
                    // Bộ hẹn giờ học tập
                    const Text(
                      'Bắt đầu phiên học mới',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StudyTimerWidget(
                      subjects: _subjects,
                      sessionProvider: sessionProvider,
                      userId: authProvider.currentUser?.id,
                    ),
                    const SizedBox(height: 24),
                    
                    // Mục tiêu sắp tới
                    const Text(
                      'Mục tiêu sắp tới',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    UpcomingGoalsWidget(goals: _upcomingGoals),
                    const SizedBox(height: 24),
                    
                    // Tiến độ môn học
                    const Text(
                      'Tiến độ môn học',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SubjectProgressWidget(
                      subjects: _subjects,
                      subjectStudyTimes: _subjectStudyTimes,
                    ),
                    const SizedBox(height: 24),
                    
                    // Phiên học gần đây
                    const Text(
                      'Phiên học gần đây',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RecentSessionsWidget(
                      sessions: _recentSessions,
                      subjects: _subjects,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildWeeklyOverview() {
    final totalHours = _totalStudyMinutes / 60;
    final targetHours = 20.0; // Mục tiêu 20 giờ/tuần
    final progress = totalHours / targetHours;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thời gian học trong tuần này',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${totalHours.toStringAsFixed(1)} giờ',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Mục tiêu: ${targetHours.toStringAsFixed(1)} giờ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 10,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_subjects.isNotEmpty && _subjectStudyTimes.isNotEmpty)
              SizedBox(
                height: 120,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final subjectId = _subjects[groupIndex].id.toString();
                          final minutes = _subjectStudyTimes[subjectId] ?? 0;
                          final hours = minutes / 60;
                          return BarTooltipItem(
                            '${_subjects[groupIndex].name}\n${hours.toStringAsFixed(1)} giờ',
                            const TextStyle(color: Colors.white),
                          );
                        }
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < _subjects.length) {
                              return Text(
                                _subjects[value.toInt()].name.substring(0, 1),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    barGroups: List.generate(
                      _subjects.length,
                      (index) {
                        final subject = _subjects[index];
                        final subjectId = subject.id.toString();
                        final minutes = _subjectStudyTimes[subjectId] ?? 0;
                        final hours = minutes / 60;
                        
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: hours,
                              color: AppColors.fromHex(subject.color),
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}