// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../constants/app_colors.dart';
// import '../../data/models/subject.dart';
// import '../../data/models/study_session.dart';
// import '../../data/models/goal.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/study_session_provider.dart';
// import '../../providers/goal_provider.dart';
// import '../../helpers/date_time_helper.dart';
// import '../../widgets/custom_app_bar.dart';
// import '../../widgets/loading_indicator.dart';
// import '../../widgets/empty_state.dart';
// import 'edit_subject_screen.dart';

// class SubjectDetailScreen extends StatefulWidget {
//   final Subject subject;
  
//   const SubjectDetailScreen({
//     Key? key,
//     required this.subject,
//   }) : super(key: key);

//   @override
//   _SubjectDetailScreenState createState() => _SubjectDetailScreenState();
// }

// class _SubjectDetailScreenState extends State<SubjectDetailScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<StudySession> _studySessions = [];
//   List<Goal> _goals = [];
//   Map<DateTime, int> _studyMinutesByDay = {};
//   int _totalStudyMinutes = 0;
//   double _averageProductivity = 0;
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadData();
//   }
  
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
  
//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       final sessionProvider = Provider.of<StudySessionProvider>(context, listen: false);
//       final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      
//       // Lấy danh sách phiên học
//       await sessionProvider.loadSessionsBySubject(widget.subject.id);
//       _studySessions = sessionProvider.sessions;
      
//       // Lấy danh sách mục tiêu
//       await goalProvider.loadGoalsBySubject(widget.subject.id);
//       _goals = goalProvider.goals;
      
//       // Tổng hợp dữ liệu
//       _calculateStats();
//     } catch (e) {
//       print('Lỗi khi tải dữ liệu: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
  
//   void _calculateStats() {
//     _totalStudyMinutes = 0;
//     int totalProductivity = 0;
//     _studyMinutesByDay = {};
    
//     for (var session in _studySessions) {
//       _totalStudyMinutes += session.durationMinutes;
//       totalProductivity += session.productivityRating;
      
//       // Nhóm theo ngày
//       final dateOnly = DateTime(
//         session.startTime.year,
//         session.startTime.month,
//         session.startTime.day,
//       );
      
//       if (_studyMinutesByDay.containsKey(dateOnly)) {
//         _studyMinutesByDay[dateOnly] = _studyMinutesByDay[dateOnly]! + session.durationMinutes;
//       } else {
//         _studyMinutesByDay[dateOnly] = session.durationMinutes;
//       }
//     }
    
//     if (_studySessions.isNotEmpty) {
//       _averageProductivity = totalProductivity / _studySessions.length;
//     }
//   }
  
//   void _editSubject() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditSubjectScreen(subject: widget.subject),
//       ),
//     ).then((_) {
//       _loadData();
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final subjectColor = AppColors.fromHex(widget.subject.color);
    
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: widget.subject.name,
//         backgroundColor: subjectColor,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: _editSubject,
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadData,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const LoadingIndicator(message: 'Đang tải dữ liệu...')
//           : Column(
//               children: [
//                 // Thông tin tổng quan
//                 _buildOverview(subjectColor),
                
//                 // TabBar
//                 Container(
//                   color: Colors.white,
//                   child: TabBar(
//                     controller: _tabController,
//                     labelColor: subjectColor,
//                     unselectedLabelColor: AppColors.textSecondary,
//                     indicatorColor: subjectColor,
//                     tabs: const [
//                       Tab(text: 'Thống kê'),
//                       Tab(text: 'Phiên học'),
//                       Tab(text: 'Mục tiêu'),
//                     ],
//                   ),
//                 ),
                
//                 // TabBarView
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildStatsTab(),
//                       _buildSessionsTab(),
//                       _buildGoalsTab(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
  
//   Widget _buildOverview(Color subjectColor) {
//     final totalHours = _totalStudyMinutes / 60;
//     final weeklyTarget = widget.subject.targetHoursPerWeek.toDouble();
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: subjectColor.withOpacity(0.1),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Mô tả
//           if (widget.subject.description != null && widget.subject.description!.isNotEmpty) ...[
//             Text(
//               widget.subject.description!,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
          
//           // Thống kê nhanh
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem(
//                 'Tổng thời gian',
//                 '${totalHours.toStringAsFixed(1)} giờ',
//                 Icons.timer,
//                 subjectColor,
//               ),
//               _buildStatItem(
//                 'Mục tiêu tuần',
//                 '$weeklyTarget giờ',
//                 Icons.flag,
//                 subjectColor,
//               ),
//               _buildStatItem(
//                 'Số phiên học',
//                 '${_studySessions.length}',
//                 Icons.event_note,
//                 subjectColor,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildStatItem(String label, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 24,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: AppColors.textSecondary,
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildStatsTab() {
//     if (_studySessions.isEmpty) {
//       return const EmptyState(
//         title: 'Chưa có dữ liệu',
//         message: 'Bắt đầu học môn này để xem thống kê',
//         icon: Icons.insights,
//       );
//     }
    
//     // Sắp xếp dữ liệu theo ngày
//     final sortedDays = _studyMinutesByDay.keys.toList()
//       ..sort((a, b) => a.compareTo(b));
    
//     // Chỉ lấy 7 ngày gần nhất
//     final recentDays = sortedDays.length > 7
//         ? sortedDays.sublist(sortedDays.length - 7)
//         : sortedDays;
    
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Thời gian học (7 ngày gần đây)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           // Biểu đồ thời gian học
//           SizedBox(
//             height: 200,
//             child: BarChart(
//               BarChartData(
//                 alignment: BarChartAlignment.center,
//                 barTouchData: BarTouchData(
//                   enabled: true,
//                   touchTooltipData: BarTouchTooltipData(
//                     tooltipBgColor: Colors.blueGrey.shade800,
//                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                       final date = recentDays[groupIndex];
//                       final minutes = _studyMinutesByDay[date] ?? 0;
//                       final hours = minutes / 60;
//                       return BarTooltipItem(
//                         '${DateTimeHelper.formatDate(date)}\n${hours.toStringAsFixed(1)} giờ',
//                         const TextStyle(color: Colors.white),
//                       );
//                     },
//                   ),
//                 ),
//                 titlesData: FlTitlesData(
//                   show: true,
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         if (value >= 0 && value < recentDays.length) {
//                           final date = recentDays[value.toInt()];
//                           return Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: Text(
//                               '${date.day}/${date.month}',
//                               style: const TextStyle(
//                                 color: AppColors.textSecondary,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           );
//                         }
//                         return const Text('');
//                       },
//                       reservedSize: 30,
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           '${value.toInt()} giờ',
//                           style: const TextStyle(
//                             color: AppColors.textSecondary,
//                             fontSize: 10,
//                           ),
//                         );
//                       },
//                       reservedSize: 40,
//                     ),
//                   ),
//                   topTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   rightTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 gridData: FlGridData(
//                   show: true,
//                   horizontalInterval: 1,
//                   drawVerticalLine: false,
//                   getDrawingHorizontalLine: (value) {
//                     return FlLine(
//                       color: AppColors.divider,
//                       strokeWidth: 1,
//                     );
//                   },
//                 ),
//                 barGroups: List.generate(
//                   recentDays.length,
//                   (index) {
//                     final date = recentDays[index];
//                     final minutes = _studyMinutesByDay[date] ?? 0;
//                     final hours = minutes / 60;
                    
//                     return BarChartGroupData(
//                       x: index,
//                       barRods: [
//                         BarChartRodData(
//                           toY: hours,
//                           color: AppColors.fromHex(widget.subject.color),
//                           width: 16,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(4),
//                             topRight: Radius.circular(4),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Các chỉ số khác
//           const Text(
//             'Các chỉ số',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           _buildMetricCard(
//             'Tổng thời gian học',
//             '${(_totalStudyMinutes / 60).toStringAsFixed(1)} giờ',
//             'Tổng thời gian đã học môn này',
//             Icons.timer,
//             AppColors.primary,
//           ),
//           _buildMetricCard(
//             'Đánh giá hiệu quả trung bình',
//             '${_averageProductivity.toStringAsFixed(1)}/5',
//             'Mức độ hiệu quả trung bình các phiên học',
//             Icons.star,
//             AppColors.warning,
//           ),
//           _buildMetricCard(
//             'Phần trăm hoàn thành mục tiêu',
//             '${((_totalStudyMinutes / 60) / widget.subject.targetHoursPerWeek * 100).toStringAsFixed(1)}%',
//             'Tiến độ hoàn thành mục tiêu tuần này',
//             Icons.pie_chart,
//             AppColors.success,
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildMetricCard(
//     String title,
//     String value,
//     String description,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     description,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: AppColors.textHint,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildSessionsTab() {
//     if (_studySessions.isEmpty) {
//       return const EmptyState(
//         title: 'Chưa có phiên học nào',
//         message: 'Bắt đầu học môn này để xem lịch sử phiên học',
//         icon: Icons.timer,
//       );
//     }
    
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: _studySessions.length,
//       separatorBuilder: (context, index) => const Divider(),
//       itemBuilder: (context, index) {
//         final session = _studySessions[index];
//         final durationHours = session.durationMinutes / 60;
        
//         return Card(
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(16),
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   DateTimeHelper.formatDateWithWeekday(session.startTime),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${DateTimeHelper.formatTime(session.startTime)} - ${DateTimeHelper.formatTime(session.endTime)}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     _buildSessionInfo(
//                       'Thời lượng',
//                       '${durationHours.toStringAsFixed(1)} giờ',
//                       Icons.timer,
//                     ),
//                     const SizedBox(width: 16),
//                     _buildSessionInfo(
//                       'Đánh giá',
//                       '${session.productivityRating}/5',
//                       Icons.star,
//                     ),
//                   ],
//                 ),
//                 if (session.notes != null && session.notes!.isNotEmpty) ...[
//                   const SizedBox(height: 8),
//                   const Divider(),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Ghi chú:',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     session.notes!,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildSessionInfo(String label, String value, IconData icon) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: AppColors.textSecondary,
//         ),
//         const SizedBox(width: 4),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
  
//   Widget _buildGoalsTab() {
//     if (_goals.isEmpty) {
//       return const EmptyState(
//         title: 'Chưa có mục tiêu nào',
//         message: 'Thêm mục tiêu cho môn học này để theo dõi tiến độ',
//         icon: Icons.flag,
//       );
//     }
    
//     // Phân loại mục tiêu
//     final completedGoals = _goals.where((g) => g.status == GoalStatus.completed).toList();
//     final inProgressGoals = _goals.where((g) => g.status == GoalStatus.inProgress).toList();
//     final notStartedGoals = _goals.where((g) => g.status == GoalStatus.notStarted).toList();
//     final failedGoals = _goals.where((g) => g.status == GoalStatus.failed).toList();
    
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         if (inProgressGoals.isNotEmpty) ...[
//           const Text(
//             'Đang thực hiện',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ..._buildGoalCards(inProgressGoals),
//           const SizedBox(height: 16),
//         ],
        
//         if (notStartedGoals.isNotEmpty) ...[
//           const Text(
//             'Chưa bắt đầu',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ..._buildGoalCards(notStartedGoals),
//           const SizedBox(height: 16),
//         ],
        
//         if (completedGoals.isNotEmpty) ...[
//           const Text(
//             'Đã hoàn thành',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ..._buildGoalCards(completedGoals),
//           const SizedBox(height: 16),
//         ],
        
//         if (failedGoals.isNotEmpty) ...[
//           const Text(
//             'Không đạt',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ..._buildGoalCards(failedGoals),
//         ],
//       ],
//     );
//   }
  
//   List<Widget> _buildGoalCards(List<Goal> goals) {
//     return goals.map((goal) {
//       final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
      
//       Color statusColor;
//       switch (goal.status) {
//         case GoalStatus.completed:
//           statusColor = AppColors.success;
//           break;
//         case GoalStatus.inProgress:
//           statusColor = AppColors.primary;
//           break;
//         case GoalStatus.notStarted:
//           statusColor = AppColors.textSecondary;
//           break;
//         case GoalStatus.failed:
//           statusColor = AppColors.error;
//           break;
//       }
      
//       return Card(
//         margin: const EdgeInsets.only(bottom: 8),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       goal.title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       goal.status.name,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: statusColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 goal.description,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.calendar_today,
//                     size: 16,
//                     color: AppColors.textSecondary,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Hạn: ${DateTimeHelper.formatDate(goal.deadline)}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   if (goal.status != GoalStatus.completed && goal.status != GoalStatus.failed)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: daysLeft <= 1
//                             ? AppColors.error
//                             : daysLeft <= 3
//                                 ? AppColors.warning
//                                 : AppColors.info,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         daysLeft <= 0
//                             ? 'Hôm nay'
//                             : 'Còn $daysLeft ngày',
//                         style: const TextStyle(
//                           fontSize: 10,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               LinearProgressIndicator(
//                 value: goal.progressPercentage / 100,
//                 backgroundColor: AppColors.divider,
//                 valueColor: AlwaysStoppedAnimation<Color>(statusColor),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${goal.progressPercentage}% hoàn thành',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }).toList();
//   }
// }



import 'package:flutter/material.dart' hide State;
import 'package:flutter/material.dart' as flutter show State;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../data/models/subject.dart';
import '../../data/models/study_session.dart';
import '../../data/models/goal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/study_session_provider.dart';
import '../../providers/goal_provider.dart';
import '../../helpers/date_time_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'edit_subject_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;
  
  const SubjectDetailScreen({
    Key? key,
    required this.subject,
  }) : super(key: key);

  @override
  flutter.State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends flutter.State<SubjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<StudySession> _studySessions = [];
  List<Goal> _goals = [];
  Map<DateTime, int> _studyMinutesByDay = {};
  int _totalStudyMinutes = 0;
  double _averageProductivity = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final sessionProvider = Provider.of<StudySessionProvider>(context, listen: false);
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      
      // Lấy danh sách phiên học
      await sessionProvider.loadSessionsBySubject(widget.subject.id);
      _studySessions = sessionProvider.sessions;
      
      // Lấy danh sách mục tiêu
      await goalProvider.loadGoalsBySubject(widget.subject.id);
      _goals = goalProvider.goals;
      
      // Tổng hợp dữ liệu
      _calculateStats();
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
  
  void _calculateStats() {
    _totalStudyMinutes = 0;
    int totalProductivity = 0;
    _studyMinutesByDay = {};
    
    for (var session in _studySessions) {
      _totalStudyMinutes += session.durationMinutes;
      totalProductivity += session.productivityRating;
      
      // Nhóm theo ngày
      final dateOnly = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      
      if (_studyMinutesByDay.containsKey(dateOnly)) {
        _studyMinutesByDay[dateOnly] = _studyMinutesByDay[dateOnly]! + session.durationMinutes;
      } else {
        _studyMinutesByDay[dateOnly] = session.durationMinutes;
      }
    }
    
    if (_studySessions.isNotEmpty) {
      _averageProductivity = totalProductivity / _studySessions.length;
    }
  }
  
  void _editSubject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSubjectScreen(subject: widget.subject),
      ),
    ).then((_) {
      _loadData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final subjectColor = AppColors.fromHex(widget.subject.color);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.subject.name,
        backgroundColor: subjectColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editSubject,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải dữ liệu...')
          : Column(
              children: [
                // Thông tin tổng quan
                _buildOverview(subjectColor),
                
                // TabBar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: subjectColor,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: subjectColor,
                    tabs: const [
                      Tab(text: 'Thống kê'),
                      Tab(text: 'Phiên học'),
                      Tab(text: 'Mục tiêu'),
                    ],
                  ),
                ),
                
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsTab(),
                      _buildSessionsTab(),
                      _buildGoalsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildOverview(Color subjectColor) {
    final totalHours = _totalStudyMinutes / 60;
    final weeklyTarget = widget.subject.targetHoursPerWeek.toDouble();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: subjectColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mô tả
          if (widget.subject.description != null && widget.subject.description!.isNotEmpty) ...[
            Text(
              widget.subject.description!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Thống kê nhanh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Tổng thời gian',
                '${totalHours.toStringAsFixed(1)} giờ',
                Icons.timer,
                subjectColor,
              ),
              _buildStatItem(
                'Mục tiêu tuần',
                '$weeklyTarget giờ',
                Icons.flag,
                subjectColor,
              ),
              _buildStatItem(
                'Số phiên học',
                '${_studySessions.length}',
                Icons.event_note,
                subjectColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatsTab() {
    if (_studySessions.isEmpty) {
      return const EmptyState(
        title: 'Chưa có dữ liệu',
        message: 'Bắt đầu học môn này để xem thống kê',
        icon: Icons.insights,
      );
    }
    
    // Sắp xếp dữ liệu theo ngày
    final sortedDays = _studyMinutesByDay.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    // Chỉ lấy 7 ngày gần nhất
    final recentDays = sortedDays.length > 7
        ? sortedDays.sublist(sortedDays.length - 7)
        : sortedDays;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thời gian học (7 ngày gần đây)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Biểu đồ thời gian học
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final date = recentDays[groupIndex];
                      final minutes = _studyMinutesByDay[date] ?? 0;
                      final hours = minutes / 60;
                      return BarTooltipItem(
                        '${DateTimeHelper.formatDate(date)}\n${hours.toStringAsFixed(1)} giờ',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < recentDays.length) {
                          final date = recentDays[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} giờ',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: List.generate(
                  recentDays.length,
                  (index) {
                    final date = recentDays[index];
                    final minutes = _studyMinutesByDay[date] ?? 0;
                    final hours = minutes / 60;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: hours,
                          color: AppColors.fromHex(widget.subject.color),
                          width: 16,
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
          const SizedBox(height: 24),
          
          // Các chỉ số khác
          const Text(
            'Các chỉ số',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildMetricCard(
            'Tổng thời gian học',
            '${(_totalStudyMinutes / 60).toStringAsFixed(1)} giờ',
            'Tổng thời gian đã học môn này',
            Icons.timer,
            AppColors.primary,
          ),
          _buildMetricCard(
            'Đánh giá hiệu quả trung bình',
            '${_averageProductivity.toStringAsFixed(1)}/5',
            'Mức độ hiệu quả trung bình các phiên học',
            Icons.star,
            AppColors.warning,
          ),
          _buildMetricCard(
            'Phần trăm hoàn thành mục tiêu',
            '${((_totalStudyMinutes / 60) / widget.subject.targetHoursPerWeek * 100).toStringAsFixed(1)}%',
            'Tiến độ hoàn thành mục tiêu tuần này',
            Icons.pie_chart,
            AppColors.success,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSessionsTab() {
    if (_studySessions.isEmpty) {
      return const EmptyState(
        title: 'Chưa có phiên học nào',
        message: 'Bắt đầu học môn này để xem lịch sử phiên học',
        icon: Icons.timer,
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _studySessions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final session = _studySessions[index];
        final durationHours = session.durationMinutes / 60;
        
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTimeHelper.formatDateWithWeekday(session.startTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateTimeHelper.formatTime(session.startTime)} - ${DateTimeHelper.formatTime(session.endTime)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSessionInfo(
                      'Thời lượng',
                      '${durationHours.toStringAsFixed(1)} giờ',
                      Icons.timer,
                    ),
                    const SizedBox(width: 16),
                    _buildSessionInfo(
                      'Đánh giá',
                      '${session.productivityRating}/5',
                      Icons.star,
                    ),
                  ],
                ),
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Ghi chú:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSessionInfo(String label, String value, IconData icon) {
    return Row(
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
  
  Widget _buildGoalsTab() {
    if (_goals.isEmpty) {
      return const EmptyState(
        title: 'Chưa có mục tiêu nào',
        message: 'Thêm mục tiêu cho môn học này để theo dõi tiến độ',
        icon: Icons.flag,
      );
    }
    
    // Phân loại mục tiêu
    final completedGoals = _goals.where((g) => g.status == GoalStatus.completed).toList();
    final inProgressGoals = _goals.where((g) => g.status == GoalStatus.inProgress).toList();
    final notStartedGoals = _goals.where((g) => g.status == GoalStatus.notStarted).toList();
    final failedGoals = _goals.where((g) => g.status == GoalStatus.failed).toList();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inProgressGoals.isNotEmpty) ...[
          const Text(
            'Đang thực hiện',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildGoalCards(inProgressGoals),
          const SizedBox(height: 16),
        ],
        
        if (notStartedGoals.isNotEmpty) ...[
          const Text(
            'Chưa bắt đầu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildGoalCards(notStartedGoals),
          const SizedBox(height: 16),
        ],
        
        if (completedGoals.isNotEmpty) ...[
          const Text(
            'Đã hoàn thành',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildGoalCards(completedGoals),
          const SizedBox(height: 16),
        ],
        
        if (failedGoals.isNotEmpty) ...[
          const Text(
            'Không đạt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildGoalCards(failedGoals),
        ],
      ],
    );
  }
  
  List<Widget> _buildGoalCards(List<Goal> goals) {
    return goals.map((goal) {
      final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
      
      Color statusColor;
      switch (goal.status) {
        case GoalStatus.completed:
          statusColor = AppColors.success;
          break;
        case GoalStatus.inProgress:
          statusColor = AppColors.primary;
          break;
        case GoalStatus.notStarted:
          statusColor = AppColors.textSecondary;
          break;
        case GoalStatus.failed:
          statusColor = AppColors.error;
          break;
      }
      
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
              Text(
                goal.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
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
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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
        ),
      );
    }).toList();
  }
}