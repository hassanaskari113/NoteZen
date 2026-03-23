import 'package:flutter/material.dart';

class Note {
  Note({
    this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
  });

  final int? id;
  final String title;
  final String content;
  final int color;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? folderId;

  // ─── CopyWith ────────────────────────────────────
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? color,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? folderId,
    bool clearFolder = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // clearFolder = true sets folderId to null
      folderId: clearFolder ? null : (folderId ?? this.folderId),
    );
  }

  // ─── To Map ──────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'isPinned': isPinned ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'folderId': folderId,
    };
  }

  // ─── From Map ────────────────────────────────────
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      color: map['color'] as int,
      isPinned: map['isPinned'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      folderId: map['folderId'] as int?,
    );
  }

  // ─── Convenience Getters ─────────────────────────
  Color get noteColor => Color(color);

  bool get hasFolder => folderId != null;

  bool get hasContent => content.trim().isNotEmpty;

  bool get isDefaultColor => color == 0xFFFFFFFF;

  String get contentPreview {
    if (content.isEmpty) return 'No content';
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }

  // ─── Equality ────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ─── Debug ───────────────────────────────────────
  @override
  String toString() => 'Note(id: $id, title: $title, isPinned: $isPinned)';
}
