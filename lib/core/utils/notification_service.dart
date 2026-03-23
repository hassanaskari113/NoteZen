import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:notezen/features/tasks/domain/tasks.dart';

class NotificationService {
  // ─── Singleton ───────────────────────────────────
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // ─── Channel Config ──────────────────────────────
  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Task Reminders';
  static const String _channelDesc = 'Notifications for upcoming task deadlines';

  // ─── Initialize ──────────────────────────────────
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings: settings, onDidReceiveNotificationResponse: _onNotificationTap);

    _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ─── Notification Tap Handler ────────────────────
  void _onNotificationTap(NotificationResponse response) {
    // Future: navigate to specific task
  }

  // ─── Schedule 1 Hour Reminder ────────────────────
  Future<int> scheduleTaskReminder(Task task) async {
    final reminderTime = task.deadline.subtract(const Duration(hours: 1));

    if (reminderTime.isBefore(DateTime.now())) return -1;

    final id = task.id!;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        '${task.title} is due in 1 hour!',
        htmlFormatBigText: false,
        contentTitle: 'Task Reminder 🔔',
        summaryText: _getPriorityLabel(task.priority),
      ),
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: 'Task Reminder 🔔',
      body: '${task.title} is due in 1 hour!',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    return id;
  }

  // ─── Schedule Deadline Notification ──────────────
  Future<void> scheduleDeadlineNotification(Task task) async {
    if (task.deadline.isBefore(DateTime.now())) return;

    final id = -(task.id!);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: '⏰ Deadline Reached!',
      body: '"${task.title}" deadline is now!',
      scheduledDate: tz.TZDateTime.from(task.deadline, tz.local),
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ─── Cancel Notification ─────────────────────────
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
    await _notifications.cancel(id: -id);
  }

  // ─── Cancel All ──────────────────────────────────
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // ─── Check Permissions ───────────────────────────
  Future<bool> areNotificationsEnabled() async {
    final plugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (plugin == null) return false;
    final result = await plugin.areNotificationsEnabled();
    return result ?? false;
  }

  // ─── Priority Label ──────────────────────────────
  String _getPriorityLabel(int? priority) {
    switch (priority) {
      case 2:
        return '🔴 High Priority';
      case 1:
        return '🟡 Medium Priority';
      case 0:
        return '🟢 Low Priority';
      default:
        return 'Task Reminder';
    }
  }
}
