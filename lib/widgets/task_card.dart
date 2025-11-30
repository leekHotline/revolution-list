import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = TaskCategory.getColor(task.category);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: task.isCompleted
                      ? Icon(Icons.check, color: color, size: 18)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTag(
                          TaskCategory.getLabel(task.category),
                          color,
                        ),
                        const SizedBox(width: 8),
                        _buildPriorityTag(task.priority),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 8),
                          _buildDateTag(task.dueDate!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Drag Handle
              const Icon(
                Icons.drag_handle,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPriorityTag(int priority) {
    final colors = [
      AppColors.danger,
      AppColors.warning,
      AppColors.success,
      AppColors.textSecondary,
      AppColors.textSecondary,
    ];
    final labels = ['P1', 'P2', 'P3', 'P4', 'P5'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: colors[priority - 1].withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        labels[priority - 1],
        style: TextStyle(
          color: colors[priority - 1],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateTag(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    Color color = AppColors.textSecondary;
    if (diff < 0) color = AppColors.danger;
    else if (diff <= 3) color = AppColors.warning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          '${date.month}/${date.day}',
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }
}