import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../data/models/goal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';
import 'widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  static const String routeName = '/goals';
  
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGoals();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGoals() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
      });
      
      await goalProvider.loadGoals(authProvider.currentUser!.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _addGoal() {
    Navigator.pushNamed(context, AddGoalScreen.routeName).then((_) {
      _loadGoals();
    });
  }
  
  void _viewGoalDetail(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goal: goal),
      ),
    ).then((_) {
      _loadGoals();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mục Tiêu',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          indicatorColor: AppColors.onPrimary,
          tabs: const [
            Tab(text: 'Đang làm'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Quá hạn'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải danh sách mục tiêu...')
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Đang làm
                _buildGoalsList(
                  goalProvider.getUpcomingGoals(),
                  'Chưa có mục tiêu nào đang làm',
                  'Thêm mục tiêu để theo dõi tiến độ học tập của bạn',
                ),
                
                // Tab 2: Hoàn thành
                _buildGoalsList(
                  goalProvider.getCompletedGoals(),
                  'Chưa có mục tiêu nào hoàn thành',
                  'Hoàn thành mục tiêu để xem chúng ở đây',
                ),
                
                // Tab 3: Quá hạn
                _buildGoalsList(
                  goalProvider.getOverdueGoals(),
                  'Không có mục tiêu nào quá hạn',
                  'Thật tuyệt vời! Bạn đang theo kịp tất cả các mục tiêu của mình',
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        tooltip: 'Thêm mục tiêu',
      ),
    );
  }
  
  Widget _buildGoalsList(List<Goal> goals, String emptyTitle, String emptyMessage) {
    if (goals.isEmpty) {
      return EmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.flag,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GoalCard(
              goal: goal,
              onTap: () => _viewGoalDetail(goal),
              onRefresh: _loadGoals,
            ),
          );
        },
      ),
    );
  }
}