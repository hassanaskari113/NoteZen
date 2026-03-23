import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // ─── Main Format ─────────────────────────────────
  static String format(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (date == today) {
      return 'Today at $timeStr';
    } else if (date == yesterday) {
      return 'Yesterday at $timeStr';
    } else if (today.difference(date).inDays < 7) {
      final dayName = DateFormat('EEEE').format(dateTime);
      return '$dayName at $timeStr';
    } else if (dateTime.year == now.year) {
      final monthDay = DateFormat('MMM d').format(dateTime);
      return '$monthDay at $timeStr';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  // ─── Deadline Format ─────────────────────────────
  // Used in TaskTile — shows urgency
  static String formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (deadline.isBefore(now)) {
      return 'Overdue!';
    } else if (diff.inMinutes < 60) {
      return 'Due in ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'Due in ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Due tomorrow';
    } else if (diff.inDays < 7) {
      return 'Due in ${diff.inDays} days';
    } else {
      return format(deadline);
    }
  }

  // ─── Deadline Color ──────────────────────────────
  // Returns color based on urgency
  static DeadlineStatus getDeadlineStatus(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (deadline.isBefore(now)) {
      return DeadlineStatus.overdue;
    } else if (diff.inHours < 3) {
      return DeadlineStatus.urgent;
    } else if (diff.inHours < 24) {
      return DeadlineStatus.soon;
    } else {
      return DeadlineStatus.normal;
    }
  }

  // ─── Short Format ────────────────────────────────
  // Used in compact places like folder content
  static String formatShort(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime);
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  // ─── Time Only ───────────────────────────────────
  static String timeOnly(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  // ─── Date Only ───────────────────────────────────
  static String dateOnly(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }
}

// ─── Deadline Status Enum ────────────────────────
enum DeadlineStatus {
  overdue, // past deadline → red
  urgent, // < 3 hours     → orange
  soon, // < 24 hours    → yellow
  normal, // plenty of time → grey
}

extension DeadlineStatusExtension on DeadlineStatus {
  bool get isOverdue => this == DeadlineStatus.overdue;
  bool get isUrgent => this == DeadlineStatus.urgent;
  bool get isSoon => this == DeadlineStatus.soon;
  bool get isNormal => this == DeadlineStatus.normal;
}
