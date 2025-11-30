import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TopTasksWidget extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onComplete;

  const TopTasksWidget({
    super.key,
    required this.tasks,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: AppColors.success.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '没有待办任务',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.warning, Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '最重要的 5 个任务',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...tasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          return _TopTaskItem(
            index: index + 1,
            task: task,
            onComplete: () => onComplete(task.id),
          ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.1);
        }),
      ],
    );
  }
}

class _TopTaskItem extends StatelessWidget {
  final int index;
  final Task task;
  final VoidCallback onComplete;

  const _TopTaskItem({
    required this.index,
    required this.task,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = TaskCategory.getColor(task.category);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TaskCategory.getLabel(task.category),
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle_outline),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}