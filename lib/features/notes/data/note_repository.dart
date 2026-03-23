import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/utils/database_helper.dart';
import 'package:notezen/features/notes/domain/notes.dart';

class NoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ─── Get All Notes ───────────────────────────────
  Future<List<Note>> getAllNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.notes, orderBy: 'isPinned DESC, updatedAt DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // ─── Get Note By Id ──────────────────────────────
  Future<Note?> getNoteById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.notes, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  // ─── Insert Note ─────────────────────────────────
  Future<int> insertNote(Note note) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.notes, note.toMap());
  }

  // ─── Update Note ─────────────────────────────────
  Future<int> updateNote(Note note) async {
    final db = await _dbHelper.database;
    return await db.update(AppConstants.notes, note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  // ─── Delete Note ─────────────────────────────────
  Future<int> deleteNote(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(AppConstants.notes, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Toggle Pin ──────────────────────────────────
  Future<void> togglePin(Note note) async {
    final db = await _dbHelper.database;
    await db.update(AppConstants.notes, {'isPinned': note.isPinned ? 0 : 1}, where: 'id = ?', whereArgs: [note.id]);
  }

  // ─── Get Pinned Notes ────────────────────────────
  Future<List<Note>> getPinnedNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.notes, where: 'isPinned = ?', whereArgs: [1], orderBy: 'updatedAt DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // ─── Get Notes By Folder ─────────────────────────
  Future<List<Note>> getNotesByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notes,
      where: 'folderId = ?',
      whereArgs: [folderId],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // ─── Search Notes ────────────────────────────────
  Future<List<Note>> searchNotes(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT * FROM ${AppConstants.notes}
      WHERE title LIKE ? OR content LIKE ?
      ORDER BY isPinned DESC, updatedAt DESC
      ''',
      ['%$query%', '%$query%'],
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // ─── Get Notes Count ─────────────────────────────
  Future<int> getNotesCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.notes}');
    return result.first['count'] as int;
  }
}
