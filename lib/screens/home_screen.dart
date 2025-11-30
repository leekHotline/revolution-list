import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/task_card.dart';
import '../widgets/reward_animation.dart';
import '../widgets/top_tasks_widget.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'top5',
    TaskCategory.project,
    TaskCategory.nextAction,
    TaskCategory.scheduled,
    TaskCategory.waiting,
    TaskCategory.future,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      _checkReminders();
    });
  }

  void _checkReminders() async {
    final provider = context.read<TaskProvider>();
    
    if (await provider.shouldShowReview()) {
      if (mounted) {
        _showReminderDialog(
          '周回顾提醒',
          '已经过去一周了，是时候回顾一下你的任务完成情况了！',
          '开始回顾',
          () => provider.markReviewed(),
        );
      }
    } else if (await provider.shouldShowCleanup()) {
      if (mounted) {
        _showReminderDialog(
          '清理提醒',
          '是否要清理已完成的任务，保持清单整洁？',
          '立即清理',
          () => provider.cleanupCompleted(),
        );
      }
    }
  }

  void _showReminderDialog(
    String title,
    String content,
    String action,
    VoidCallback onAction,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(content, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              onAction();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: _buildAppBar(),
              body: TabBarView(
                controller: _tabController,
                children: _categories.map((cat) {
                  if (cat == 'top5') {
                    return TopTasksWidget(
                      tasks: provider.topFiveTasks,
                      onComplete: (id) => provider.completeTask(id),
                    );
                  }
                  return _buildTaskList(provider, cat);
                }).toList(),
              ),
              floatingActionButton: _buildFAB(),
            ),
            
            // Reward Animation
            if (provider.showReward)
              RewardAnimation(
                type: provider.rewardType,
                onComplete: () {},
              ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Revolution',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: -0.2),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: [
          const Tab(text: '⭐ Top5'),
          Tab(
            icon: Icon(TaskCategory.getIcon(TaskCategory.project), size: 18),
            text: TaskCategory.getLabel(TaskCategory.project),
          ),
          Tab(
            icon: Icon(TaskCategory.getIcon(TaskCategory.nextAction), size: 18),
            text: TaskCategory.getLabel(TaskCategory.nextAction),
          ),
          Tab(
            icon: Icon(TaskCategory.getIcon(TaskCategory.scheduled), size: 18),
            text: TaskCategory.getLabel(TaskCategory.scheduled),
          ),
          Tab(
            icon: Icon(TaskCategory.getIcon(TaskCategory.waiting), size: 18),
            text: TaskCategory.getLabel(TaskCategory.waiting),
          ),
          Tab(
            icon: Icon(TaskCategory.getIcon(TaskCategory.future), size: 18),
            text: TaskCategory.getLabel(TaskCategory.future),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider, String category) {
    final tasks = provider.getTasksByCategory(category);
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TaskCategory.getIcon(category),
              size: 80,
              color: TaskCategory.getColor(category).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无${TaskCategory.getLabel(category)}任务',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角按钮添加新任务',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        provider.reorderTasks(category, oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              color: Colors.transparent,
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          onComplete: () => provider.completeTask(task.id),
          onDelete: () => provider.deleteTask(task.id),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        final currentCat = _tabController.index > 0 
            ? _categories[_tabController.index]
            : null;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AddTaskScreen(initialCategory: currentCat),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          ),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        '新任务',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ).animate().scale(delay: 500.ms).then().shimmer(duration: 2.seconds);
  }
}