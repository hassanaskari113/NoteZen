import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notezen/core/constants/app_constants.dart';

class DatabaseHelper {
  // ─── Singleton ───────────────────────────────────
  DatabaseHelper._();
  static final DatabaseHelper _instance = DatabaseHelper._();
  static DatabaseHelper get instance => _instance;

  Database? _database;

  // ─── Database Getter ─────────────────────────────
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ─── Init ────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final fullPath = join(path, AppConstants.dbName);

    return openDatabase(fullPath, version: AppConstants.dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // ─── Create Tables ───────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await _createNotesTable(db);
    await _createTasksTable(db);
    await _createFoldersTable(db);
  }

  // ─── Upgrade Handler ─────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE Notes ADD COLUMN tag TEXT');
    // }
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.notes} (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        content     TEXT    NOT NULL,
        color       INTEGER NOT NULL DEFAULT 0xFFFFFFFF,
        isPinned    INTEGER NOT NULL DEFAULT 0,
        createdAt   TEXT    NOT NULL,
        updatedAt   TEXT    NOT NULL,
        folderId    INTEGER,
        FOREIGN KEY (folderId) 
          REFERENCES ${AppConstants.folders}(id)
          ON DELETE SET NULL
      );
    ''');
  }

  Future<void> _createTasksTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tasks} (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        title          TEXT    NOT NULL,
        description    TEXT,
        priority       INTEGER NOT NULL DEFAULT 1,
        isCompleted    INTEGER NOT NULL DEFAULT 0,
        deadline       TEXT    NOT NULL,
        notificationId INTEGER,
        createdAt      TEXT    NOT NULL,
        folderId       INTEGER,
        FOREIGN KEY (folderId) 
          REFERENCES ${AppConstants.folders}(id)
          ON DELETE SET NULL
      );
    ''');
  }

  Future<void> _createFoldersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.folders} (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        name      TEXT    NOT NULL,
        color     INTEGER NOT NULL DEFAULT 0xFF42A5F5,
        createdAt TEXT    NOT NULL
      );
    ''');
  }

  // ─── Helper: Close DB ────────────────────────────
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
