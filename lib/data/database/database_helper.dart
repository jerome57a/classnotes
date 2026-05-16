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
    final path = join(dbPath, 'classnotes.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
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

  // TODO: Replace with repository pattern + error handling for production

  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'updatedAt DESC');
    return maps.map(NoteModel.fromMap).toList();
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
  }

  Future<List<String>> getAllSubjects() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT subject FROM notes ORDER BY subject',
    );
    return maps.map((m) => m['subject'] as String).toList();
  }

  Future<void> seedDemoData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM notes'),
    );
    if (count != null && count > 0) return;

    final now = DateTime.now();
    final demoNotes = [
      {
        'title': 'Calculus — Limits & Continuity',
        'subject': 'Mathematics',
        'content':
            'A limit describes the value a function approaches as the input approaches some value.\n\nKey theorems:\n• Squeeze Theorem: if g(x) ≤ f(x) ≤ h(x) and lim g(x) = lim h(x) = L, then lim f(x) = L\n• L\'Hôpital\'s Rule applies when direct substitution gives 0/0 or ∞/∞\n\nContinuity requires: f(c) defined, lim f(x) exists, and lim f(x) = f(c)\n\nPractice problems assigned: Section 2.3 — exercises 1–15 (odd numbers)',
        'colorHex': '#7C6AFA',
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': 'Quantum Mechanics Intro',
        'subject': 'Physics',
        'content':
            'Wave-particle duality: light and matter exhibit both wave and particle properties.\n\nSchrödinger equation — describes how quantum state evolves over time:\niℏ ∂ψ/∂t = Ĥψ\n\nHeisenberg Uncertainty Principle:\nΔx · Δp ≥ ℏ/2\n\nKey concepts to review before midterm:\n1. Wave functions and probability density\n2. Operators and eigenvalues\n3. Quantum tunneling\n4. Hydrogen atom energy levels\n\nProfessor Chen mentioned this will be heavily tested — study the derivation of energy levels.',
        'colorHex': '#38BDF8',
        'createdAt': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'title': 'Organic Chemistry — Reaction Mechanisms',
        'subject': 'Chemistry',
        'content':
            'SN1 vs SN2 reactions — key differences:\n\nSN1 (Substitution Nucleophilic Unimolecular):\n• Two-step mechanism via carbocation intermediate\n• Rate depends only on substrate concentration\n• Favored by tertiary substrates\n• Stereochemistry: racemization\n\nSN2 (Substitution Nucleophilic Bimolecular):\n• One-step concerted mechanism\n• Rate depends on both substrate and nucleophile\n• Favored by primary substrates\n• Stereochemistry: inversion (Walden inversion)\n\nLab report due Friday — synthesis of aspirin.',
        'colorHex': '#22C55E',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'title': 'Cell Division — Mitosis & Meiosis',
        'subject': 'Biology',
        'content':
            'Mitosis produces 2 genetically identical daughter cells (diploid).\nMeiosis produces 4 genetically unique daughter cells (haploid).\n\nPhases of Mitosis:\nProphase → Metaphase → Anaphase → Telophase → Cytokinesis\n\nKey checkpoints:\n• G1 checkpoint: cell size, nutrients, growth factors\n• G2 checkpoint: DNA replication accuracy\n• M checkpoint (spindle checkpoint): chromosome attachment\n\nCrossing over during meiosis I increases genetic diversity — occurs at chiasmata.',
        'colorHex': '#F59E0B',
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'title': 'World War I — Causes & Consequences',
        'subject': 'History',
        'content':
            'MAIN acronym for causes: Militarism, Alliances, Imperialism, Nationalism\n\nAssassination of Archduke Franz Ferdinand (June 28, 1914) — the trigger.\n\nAlliance systems:\n• Triple Entente: France, Russia, Britain\n• Triple Alliance: Germany, Austria-Hungary, Italy\n\nConsequences:\n• ~20 million deaths\n• Collapse of 4 empires: Ottoman, Austro-Hungarian, Russian, German\n• Treaty of Versailles (1919) — harsh reparations on Germany\n• Seeds of WWII planted\n\nEssay topic: "Was the Treaty of Versailles a cause of WWII?" — 1500 words, due next Thursday.',
        'colorHex': '#F97316',
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'title': 'Data Structures — Binary Trees',
        'subject': 'Computer Science',
        'content':
            'Binary Search Tree (BST) properties:\n• Left child < parent < right child\n• Inorder traversal gives sorted sequence\n\nTime complexity:\n• Search: O(log n) average, O(n) worst case\n• Insert: O(log n) average\n• Delete: O(log n) average\n\nBalanced BSTs (AVL, Red-Black):\n• Guarantee O(log n) for all operations\n• Self-balancing via rotations\n\nImplementation in Python assigned — build BST with insert, search, delete, and inorder traversal methods. Submit via GitHub by Sunday 11:59 PM.',
        'colorHex': '#06B6D4',
        'createdAt': now.subtract(const Duration(days: 4)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'title': 'Shakespeare — Hamlet Analysis',
        'subject': 'Literature',
        'content':
            'Major themes in Hamlet:\n1. Revenge and justice — Hamlet\'s hesitation vs. Laertes\' immediate action\n2. Appearance vs. reality — "To be or not to be" soliloquy\n3. Corruption and decay — "Something is rotten in the state of Denmark"\n4. Madness (real vs. feigned) — Hamlet vs. Ophelia\n\nKey quotes for essay:\n• "The lady doth protest too much, methinks" (Act 3, Scene 2)\n• "Frailty, thy name is woman!" (Act 1, Scene 2)\n\nMidterm essay: Compare Hamlet and Laertes as foil characters — 2000 words.',
        'colorHex': '#EC4899',
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
    ];

    for (final note in demoNotes) {
      await db.insert('notes', note);
    }
  }
}
