import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/utils/database_helper.dart';
import 'package:notezen/features/tasks/domain/tasks.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ─── Get All Tasks ───────────────────────────────
  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tasks, orderBy: 'isCompleted ASC, deadline ASC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ─── Get Task By Id ──────────────────────────────
  Future<Task?> getTaskById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tasks, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  // ─── Insert Task ─────────────────────────────────
  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.tasks, task.toMap());
  }

  // ─── Update Task ─────────────────────────────────
  Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(AppConstants.tasks, task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  // ─── Delete Task ─────────────────────────────────
  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(AppConstants.tasks, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Toggle Complete ─────────────────────────────
  Future<void> toggleComplete(Task task) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tasks,
      {'isCompleted': task.isCompleted ? 0 : 1},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // ─── Get Pending Tasks ───────────────────────────
  Future<List<Task>> getPendingTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tasks, where: 'isCompleted = ?', whereArgs: [0], orderBy: 'deadline ASC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ─── Get Completed Tasks ─────────────────────────
  Future<List<Task>> getCompletedTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tasks, where: 'isCompleted = ?', whereArgs: [1], orderBy: 'deadline DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ─── Get Overdue Tasks ───────────────────────────
  Future<List<Task>> getOverdueTasks() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      AppConstants.tasks,
      where: 'isCompleted = ? AND deadline < ?',
      whereArgs: [0, now],
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ─── Get Tasks By Priority ───────────────────────
  Future<List<Task>> getTasksByPriority(int priority) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tasks,
      where: 'priority = ? AND isCompleted = ?',
      whereArgs: [priority, 0],
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ─── Get Tasks By Folder ─────────────────────────
  Future<List<Task>> getTasksByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tasks,
      where: 'folderId = ?',
      whereArgs: [folderId],
      orderBy: 'isCompleted ASC, deadline ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ─── Search Tasks ────────────────────────────────
  Future<List<Task>> searchTasks(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT * FROM ${AppConstants.tasks}
      WHERE title LIKE ? OR description LIKE ?
      ORDER BY isCompleted ASC, deadline ASC
      ''',
      ['%$query%', '%$query%'],
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ─── Get Tasks Count ─────────────────────────────
  Future<Map<String, int>> getTasksCount() async {
    final db = await _dbHelper.database;

    final total = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tasks}');
    final completed = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tasks} WHERE isCompleted = 1');
    final pending = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tasks} WHERE isCompleted = 0');

    return {
      'total': total.first['count'] as int,
      'completed': completed.first['count'] as int,
      'pending': pending.first['count'] as int,
    };
  }
}
