import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Task> _tasks = [];
  bool _showReward = false;
  String _rewardType = 'create';

  List<Task> get tasks => _tasks;
  bool get showReward => _showReward;
  String get rewardType => _rewardType;

  List<Task> getTasksByCategory(String category) {
    return _tasks.where((t) => t.category == category && !t.isCompleted).toList();
  }

  List<Task> get topFiveTasks {
    var incomplete = _tasks.where((t) => !t.isCompleted).toList();
    incomplete.sort((a, b) {
      if (a.priority != b.priority) return a.priority.compareTo(b.priority);
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    return incomplete.take(5).toList();
  }

  Future<void> loadTasks() async {
    _tasks = await _db.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _db.insertTask(task);
    await loadTasks();
    _triggerReward('create');
  }

  Future<void> completeTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _db.updateTask(task.copyWith(isCompleted: true));
    await _db.incrementCompletedCount();
    await loadTasks();
    _triggerReward('complete');
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    await loadTasks();
  }

  Future<void> reorderTasks(String category, int oldIndex, int newIndex) async {
    var categoryTasks = getTasksByCategory(category);
    final task = categoryTasks.removeAt(oldIndex);
    categoryTasks.insert(newIndex, task);
    await _db.updateTaskOrder(categoryTasks);
    await loadTasks();
  }

  void _triggerReward(String type) {
    _rewardType = type;
    _showReward = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _showReward = false;
      notifyListeners();
    });
  }

  Future<bool> shouldShowReview() async {
    final lastReview = await _db.getLastReviewDate();
    if (lastReview == null) return true;
    return DateTime.now().difference(lastReview).inDays >= 7;
  }

  Future<void> markReviewed() async {
    await _db.setLastReviewDate(DateTime.now());
  }

  Future<bool> shouldShowCleanup() async {
    final lastCleanup = await _db.getLastCleanupDate();
    if (lastCleanup == null) return true;
    return DateTime.now().difference(lastCleanup).inDays >= 7;
  }

  Future<void> markCleanedUp() async {
    await _db.setLastCleanupDate(DateTime.now());
  }

  Future<void> cleanupCompleted() async {
    final completed = _tasks.where((t) => t.isCompleted).toList();
    for (var task in completed) {
      await _db.deleteTask(task.id);
    }
    await loadTasks();
    await markCleanedUp();
  }
}