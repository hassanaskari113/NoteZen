import 'package:notezen/core/utils/database_helper.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/features/folders/domain/folders.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ─── Get All Folders ─────────────────────────────
  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.folders, orderBy: 'createdAt DESC');
    return maps.map((map) => Folder.fromMap(map)).toList();
  }

  // ─── Get Folder By Id ────────────────────────────
  Future<Folder?> getFolderById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.folders, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Folder.fromMap(maps.first);
  }

  // ─── Insert Folder ───────────────────────────────
  Future<int> insertFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.folders, folder.toMap());
  }

  // ─── Update Folder ───────────────────────────────
  Future<int> updateFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return await db.update(AppConstants.folders, folder.toMap(), where: 'id = ?', whereArgs: [folder.id]);
  }

  // ─── Delete Folder (Safe) ────────────────────────
  // Unassigns all notes and tasks before deleting
  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;

    // Use transaction for data consistency
    return await db.transaction((txn) async {
      // Unassign notes
      await txn.rawUpdate('UPDATE ${AppConstants.notes} SET folderId = NULL WHERE folderId = ?', [id]);

      // Unassign tasks
      await txn.rawUpdate('UPDATE ${AppConstants.tasks} SET folderId = NULL WHERE folderId = ?', [id]);

      // Delete folder
      return await txn.delete(AppConstants.folders, where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── Get Folder Notes Count ──────────────────────
  Future<int> getNotesCount(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.notes} WHERE folderId = ?', [
      folderId,
    ]);
    return result.first['count'] as int;
  }

  // ─── Get Folder Tasks Count ──────────────────────
  Future<int> getTasksCount(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tasks} WHERE folderId = ?', [
      folderId,
    ]);
    return result.first['count'] as int;
  }

  // ─── Check Folder Name Exists ────────────────────
  Future<bool> nameExists(String name, {int? excludeId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.folders,
      where: excludeId != null ? 'name = ? AND id != ?' : 'name = ?',
      whereArgs: excludeId != null ? [name, excludeId] : [name],
    );
    return maps.isNotEmpty;
  }
}
