import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/features/tasks/domain/tasks.dart';
import 'package:notezen/features/tasks/data/task_repository.dart';
import 'package:notezen/core/utils/notification_service.dart';

class TasksNotifier extends Notifier<List<Task>> {
  final TaskRepository _repository = TaskRepository();

  @override
  List<Task> build() {
    loadTasks();
    return [];
  }

  // ─── Load All Tasks ──────────────────────────────
  Future<void> loadTasks() async {
    final tasks = await _repository.getAllTasks();
    state = tasks;
  }

  // ─── Add Task ────────────────────────────────────
  Future<void> addTask(Task task) async {
    final id = await _repository.insertTask(task);
    final taskWithId = task.copyWith(id: id);

    // Schedule 1 hour reminder
    final notifId = await NotificationService.instance.scheduleTaskReminder(taskWithId);

    // Schedule deadline notification
    await NotificationService.instance.scheduleDeadlineNotification(taskWithId);

    // Save notificationId back to task
    if (notifId != -1) {
      await _repository.updateTask(taskWithId.copyWith(notificationId: notifId));
    }

    await loadTasks();
  }

  // ─── Update Task ─────────────────────────────────
  Future<void> updateTask(Task task) async {
    // Cancel existing notifications
    if (task.notificationId != null) {
      await NotificationService.instance.cancelNotification(task.notificationId!);
    }

    // Reschedule notifications
    final notifId = await NotificationService.instance.scheduleTaskReminder(task);

    await NotificationService.instance.scheduleDeadlineNotification(task);

    // Save with new notificationId
    await _repository.updateTask(task.copyWith(notificationId: notifId != -1 ? notifId : null));

    await loadTasks();
  }

  // ─── Delete Task ─────────────────────────────────
  Future<void> deleteTask(int id) async {
    final task = await _repository.getTaskById(id);

    // Cancel all notifications for this task
    if (task?.notificationId != null) {
      await NotificationService.instance.cancelNotification(task!.notificationId!);
    }

    await _repository.deleteTask(id);
    await loadTasks();
  }

  // ─── Toggle Complete ─────────────────────────────
  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);

    await _repository.updateTask(updated);

    // Cancel notifications when task is completed
    if (updated.isCompleted && task.notificationId != null) {
      await NotificationService.instance.cancelNotification(task.notificationId!);
    }

    // Reschedule if task is uncompleted
    if (!updated.isCompleted) {
      final notifId = await NotificationService.instance.scheduleTaskReminder(updated);
      await NotificationService.instance.scheduleDeadlineNotification(updated);
      if (notifId != -1) {
        await _repository.updateTask(updated.copyWith(notificationId: notifId));
      }
    }

    await loadTasks();
  }

  // ─── Search Tasks ────────────────────────────────
  Future<List<Task>> searchTasks(String query) async {
    return await _repository.searchTasks(query);
  }

  // ─── Get From State ──────────────────────────────
  Task? getTaskById(int id) {
    try {
      return state.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Getters ─────────────────────────────────────
  List<Task> get pendingTasks => state.where((t) => !t.isCompleted).toList();

  List<Task> get completedTasks => state.where((t) => t.isCompleted).toList();

  List<Task> get overdueTasks => state.where((t) => t.isOverdue).toList();

  List<Task> get todayTasks => state.where((t) => t.isDueToday && !t.isCompleted).toList();

  List<Task> getTasksByFolder(int folderId) => state.where((t) => t.folderId == folderId).toList();
}

final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(() => TasksNotifier());
