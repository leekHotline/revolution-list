import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static Database? _database;
  static SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ========== 移动端：SQLite ==========
  Future<Database> get database async {
    if (kIsWeb) throw Exception('SQLite not supported on web');
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'revolution_list.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT NOT NULL,
            priority INTEGER DEFAULT 3,
            createdAt TEXT NOT NULL,
            dueDate TEXT,
            isCompleted INTEGER DEFAULT 0,
            sortOrder INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // ========== 通用方法（自动选择存储方式）==========
  
  Future<void> insertTask(Task task) async {
    if (kIsWeb) {
      await _webInsertTask(task);
    } else {
      final db = await database;
      await db.insert('tasks', task.toMap());
    }
    await _incrementTaskCount();
  }

  Future<List<Task>> getTasks({String? category, bool? completed}) async {
    if (kIsWeb) {
      return _webGetTasks(category: category, completed: completed);
    }
    
    final db = await database;
    String where = '';
    List<dynamic> args = [];

    if (category != null) {
      where = 'category = ?';
      args.add(category);
    }
    if (completed != null) {
      where += where.isNotEmpty ? ' AND ' : '';
      where += 'isCompleted = ?';
      args.add(completed ? 1 : 0);
    }

    final maps = await db.query(
      'tasks',
      where: where.isNotEmpty ? where : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'sortOrder ASC, priority ASC, createdAt DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> updateTask(Task task) async {
    if (kIsWeb) {
      await _webUpdateTask(task);
    } else {
      final db = await database;
      await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
    }
  }

  Future<void> deleteTask(String id) async {
    if (kIsWeb) {
      await _webDeleteTask(id);
    } else {
      final db = await database;
      await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> updateTaskOrder(List<Task> tasks) async {
    if (kIsWeb) {
      await _webUpdateTaskOrder(tasks);
    } else {
      final db = await database;
      final batch = db.batch();
      for (int i = 0; i < tasks.length; i++) {
        batch.update('tasks', {'sortOrder': i}, where: 'id = ?', whereArgs: [tasks[i].id]);
      }
      await batch.commit();
    }
  }

  // ========== Web 专用方法（使用 SharedPreferences）==========
  
  Future<List<Task>> _webGetAllTasks() async {
    final p = await prefs;
    final String? data = p.getString('tasks_data');
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Task.fromMap(json)).toList();
  }

  Future<void> _webSaveAllTasks(List<Task> tasks) async {
    final p = await prefs;
    final String data = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await p.setString('tasks_data', data);
  }

  Future<void> _webInsertTask(Task task) async {
    final tasks = await _webGetAllTasks();
    tasks.add(task);
    await _webSaveAllTasks(tasks);
  }

  Future<List<Task>> _webGetTasks({String? category, bool? completed}) async {
    var tasks = await _webGetAllTasks();
    
    if (category != null) {
      tasks = tasks.where((t) => t.category == category).toList();
    }
    if (completed != null) {
      tasks = tasks.where((t) => t.isCompleted == completed).toList();
    }
    
    tasks.sort((a, b) {
      if (a.sortOrder != b.sortOrder) return a.sortOrder.compareTo(b.sortOrder);
      if (a.priority != b.priority) return a.priority.compareTo(b.priority);
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return tasks;
  }

  Future<void> _webUpdateTask(Task task) async {
    final tasks = await _webGetAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _webSaveAllTasks(tasks);
    }
  }

  Future<void> _webDeleteTask(String id) async {
    final tasks = await _webGetAllTasks();
    tasks.removeWhere((t) => t.id == id);
    await _webSaveAllTasks(tasks);
  }

  Future<void> _webUpdateTaskOrder(List<Task> orderedTasks) async {
    final allTasks = await _webGetAllTasks();
    
    for (int i = 0; i < orderedTasks.length; i++) {
      final index = allTasks.indexWhere((t) => t.id == orderedTasks[i].id);
      if (index != -1) {
        allTasks[index] = allTasks[index].copyWith(sortOrder: i);
      }
    }
    
    await _webSaveAllTasks(allTasks);
  }

  // ========== 统计和设置 ==========
  
  Future<void> _incrementTaskCount() async {
    final p = await prefs;
    int count = p.getInt('totalTasks') ?? 0;
    await p.setInt('totalTasks', count + 1);
  }

  Future<void> incrementCompletedCount() async {
    final p = await prefs;
    int count = p.getInt('completedTasks') ?? 0;
    await p.setInt('completedTasks', count + 1);
  }

  Future<Map<String, int>> getStats() async {
    final p = await prefs;
    return {
      'total': p.getInt('totalTasks') ?? 0,
      'completed': p.getInt('completedTasks') ?? 0,
    };
  }

  Future<DateTime?> getLastReviewDate() async {
    final p = await prefs;
    String? date = p.getString('lastReviewDate');
    return date != null ? DateTime.parse(date) : null;
  }

  Future<void> setLastReviewDate(DateTime date) async {
    final p = await prefs;
    await p.setString('lastReviewDate', date.toIso8601String());
  }

  Future<DateTime?> getLastCleanupDate() async {
    final p = await prefs;
    String? date = p.getString('lastCleanupDate');
    return date != null ? DateTime.parse(date) : null;
  }

  Future<void> setLastCleanupDate(DateTime date) async {
    final p = await prefs;
    await p.setString('lastCleanupDate', date.toIso8601String());
  }
}