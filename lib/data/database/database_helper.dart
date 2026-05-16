import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'classnotes_v3.db'); // Bumped to v3 for a truly fresh start
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        content TEXT NOT NULL,
        colorHex TEXT NOT NULL DEFAULT '#7C6AFA',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    try {
      return await db.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // 🚨 SELF-HEALING: If Hot Reload lost the table, recreate it and try again!
      if (e.toString().contains('no such table')) {
        await _onCreate(db, 1);
        return await db.insert(
          'notes',
          note.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      rethrow;
    }
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    try {
      final maps = await db.query('notes', orderBy: 'updatedAt DESC');
      return maps.map(NoteModel.fromMap).toList();
    } catch (e) {
      // 🚨 SELF-HEALING fallback
      if (e.toString().contains('no such table')) {
        await _onCreate(db, 1);
        return [];
      }
      rethrow;
    }
  }

  Future<NoteModel?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return NoteModel.fromMap(maps.first);
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final db = await database;
    try {
      final q = '%${query.toLowerCase()}%';
      final maps = await db.rawQuery(
        '''SELECT * FROM notes 
           WHERE LOWER(title) LIKE ? 
              OR LOWER(subject) LIKE ? 
              OR LOWER(content) LIKE ?
           ORDER BY updatedAt DESC''',
        [q, q, q],
      );
      return maps.map(NoteModel.fromMap).toList();
    } catch (e) {
       if (e.toString().contains('no such table')) {
        await _onCreate(db, 1);
        return [];
      }
      rethrow;
    }
  }

  Future<List<String>> getAllSubjects() async {
    final db = await database;
    try {
      final maps = await db.rawQuery(
        'SELECT DISTINCT subject FROM notes ORDER BY subject',
      );
      return maps.map((m) => m['subject'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}