import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF8B5CF6);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const surfaceLight = Color(0xFF334155);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
}

class TaskCategory {
  static const String project = 'project';
  static const String nextAction = 'next_action';
  static const String scheduled = 'scheduled';
  static const String waiting = 'waiting';
  static const String future = 'future';

  static String getLabel(String category) {
    switch (category) {
      case project:
        return '项目';
      case nextAction:
        return '下一步';
      case scheduled:
        return '日程';
      case waiting:
        return '等待';
      case future:
        return '将来';
      default:
        return '';
    }
  }

  static IconData getIcon(String category) {
    switch (category) {
      case project:
        return Icons.folder_outlined;
      case nextAction:
        return Icons.flash_on;
      case scheduled:
        return Icons.schedule;
      case waiting:
        return Icons.hourglass_empty;
      case future:
        return Icons.lightbulb_outline;
      default:
        return Icons.task;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case project:
        return AppColors.primary;
      case nextAction:
        return AppColors.success;
      case scheduled:
        return AppColors.warning;
      case waiting:
        return AppColors.secondary;
      case future:
        return const Color(0xFF06B6D4);
      default:
        return AppColors.primary;
    }
  }
}