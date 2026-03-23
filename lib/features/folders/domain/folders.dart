import 'package:flutter/material.dart';

class Folder {
  Folder({this.id, required this.name, required this.color, required this.createdAt});

  final int? id;
  final String name;
  final int color;
  final DateTime createdAt;

  // ─── CopyWith ────────────────────────────────────
  Folder copyWith({int? id, String? name, int? color, DateTime? createdAt}) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ─── To Map ──────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color, 'createdAt': createdAt.toIso8601String()};
  }

  // ─── From Map ────────────────────────────────────
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // ─── Convenience Getters ─────────────────────────
  Color get folderColor => Color(color);

  bool get hasDefaultColor => color == 0xFF42A5F5;

  // ─── Equality ────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Folder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ─── Debug ───────────────────────────────────────
  @override
  String toString() => 'Folder(id: $id, name: $name, color: $color)';
}
