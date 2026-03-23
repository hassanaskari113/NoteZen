import 'package:flutter/material.dart';
import 'package:notezen/core/themes/app_theme.dart';

class Task {
  Task({
    this.id,
    required this.title,
    this.description,
    this.priority,
    required this.isCompleted,
    required this.deadline,
    this.notificationId,
    required this.createdAt,
    this.folderId,
  });

  final int? id;
  final String title;
  final String? description;
  final int? priority;
  final bool isCompleted;
  final DateTime deadline;
  final int? notificationId;
  final DateTime createdAt;
  final int? folderId;

  // ─── CopyWith ────────────────────────────────────
  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? priority,
    bool? isCompleted,
    DateTime? deadline,
    int? notificationId,
    DateTime? createdAt,
    int? folderId,
    bool clearFolder = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
    );
  }

  // ─── To Map ──────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'deadline': deadline.toIso8601String(),
      'notificationId': notificationId,
      'createdAt': createdAt.toIso8601String(),
      'folderId': folderId,
    };
  }

  // ─── From Map ────────────────────────────────────
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: map['priority'] as int?,
      isCompleted: map['isCompleted'] == 1,
      deadline: DateTime.parse(map['deadline'] as String),
      notificationId: map['notificationId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      folderId: map['folderId'] as int?,
    );
  }

  // ─── Deadline Status ─────────────────────────────
  bool get isOverdue => !isCompleted && deadline.isBefore(DateTime.now());

  bool get isUrgent {
    if (isCompleted || isOverdue) return false;
    return deadline.difference(DateTime.now()).inHours < 3;
  }

  bool get isDueSoon {
    if (isCompleted || isOverdue) return false;
    final diff = deadline.difference(DateTime.now());
    return diff.inHours >= 3 && diff.inHours < 24;
  }

  bool get isDueToday {
    final now = DateTime.now();
    return deadline.year == now.year && deadline.month == now.month && deadline.day == now.day;
  }

  // ─── Priority Helpers ────────────────────────────
  String get priorityLabel {
    switch (priority) {
      case 2:
        return 'High';
      case 1:
        return 'Medium';
      case 0:
        return 'Low';
      default:
        return 'None';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 2:
        return AppTheme.priorityHigh;
      case 1:
        return AppTheme.priorityMedium;
      case 0:
        return AppTheme.priorityLow;
      default:
        return Colors.grey;
    }
  }

  // ─── Convenience Getters ─────────────────────────
  bool get hasDescription => description != null && description!.trim().isNotEmpty;

  bool get hasFolder => folderId != null;

  bool get hasNotification => notificationId != null;

  // ─── Deadline Color ──────────────────────────────
  Color get deadlineColor {
    if (isCompleted) return Colors.grey;
    if (isOverdue) return AppTheme.error;
    if (isUrgent) return AppTheme.priorityHigh;
    if (isDueSoon) return AppTheme.priorityMedium;
    return Colors.grey;
  }

  // ─── Equality ────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ─── Debug ───────────────────────────────────────
  @override
  String toString() =>
      'Task(id: $id, title: $title, '
      'isCompleted: $isCompleted, deadline: $deadline)';
}
