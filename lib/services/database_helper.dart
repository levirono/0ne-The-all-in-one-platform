import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('one.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7, // Incremented from 6 to 7
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE user_cache(
      id TEXT PRIMARY KEY,
      fullName TEXT,
      email TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE notes(
      id TEXT PRIMARY KEY,
      title TEXT,
      content TEXT,
      timestamp TEXT,
      backgroundColor INTEGER,
      titleColor INTEGER,
      contentColor INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE todos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      timeframe TEXT,
      week INTEGER,
      weeklyTasks TEXT,
      dailyTasks TEXT,
      month TEXT,
      monthlyTasks TEXT,
      customDateTime TEXT,
      completed BOOLEAN DEFAULT FALSE
    )
    ''');

    await db.execute('''
    CREATE TABLE app_settings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT UNIQUE,
      value TEXT
    )
    ''');

    print('Tables created successfully.');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE notes ADD COLUMN backgroundColor INTEGER;
      ''');
      await db.execute('''
      ALTER TABLE notes ADD COLUMN titleColor INTEGER;
      ''');
      await db.execute('''
      ALTER TABLE notes ADD COLUMN contentColor INTEGER;
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE,
        value TEXT
      )
      ''');
    }
    if (oldVersion < 4) {
      // Check if todos table exists
      var tableInfo = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='todos'");
      if (tableInfo.isEmpty) {
        // Create todos table only if it doesn't exist
        await db.execute('''
        CREATE TABLE todos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          timeframe TEXT,
          week INTEGER,
          weeklyTasks TEXT,
          dailyTasks TEXT,
          month TEXT,
          monthlyTasks TEXT
        )
        ''');
        print('Todos table created successfully.');
      } else {
        print('Todos table already exists.');
      }
    }
    if (oldVersion < 5) {
      // Add the customDateTime column to the todos table
      await db.execute('''
      ALTER TABLE todos ADD COLUMN customDateTime TEXT;
      ''');
      print('Added customDateTime column to todos table.');
    }
    if (oldVersion < 6) {
      // Add the completed column to the todos table
      await db.execute('''
      ALTER TABLE todos ADD COLUMN completed BOOLEAN DEFAULT FALSE;
      ''');
      print('Added completed column to todos table.');
    }
    if (oldVersion < 7) {
      // Add the titleColor and contentColor columns to the notes table
      await db.execute('''
      ALTER TABLE notes ADD COLUMN titleColor INTEGER;
      ''');
      await db.execute('''
      ALTER TABLE notes ADD COLUMN contentColor INTEGER;
      ''');
      print('Added titleColor and contentColor columns to notes table.');
    }
  }

  Future<void> cacheUserData(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('user_cache', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getCachedUserData() async {
    final db = await database;
    final maps = await db.query('user_cache');
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> clearUserCache() async {
    final db = await database;
    await db.delete('user_cache');
  }

  Future<void> addNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert('notes', note,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  Future<int> deleteNote(String id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setAppSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getAppSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }

  Future<int> insertTodo(Map<String, dynamic> todo) async {
    try {
      Database db = await instance.database;
      // Check if todos table exists before inserting
      var tableInfo = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='todos'");
      if (tableInfo.isEmpty) {
        print('Todos table does not exist. Attempting to create it.');
        await db.execute('''
        CREATE TABLE todos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          timeframe TEXT,
          week INTEGER,
          weeklyTasks TEXT,
          dailyTasks TEXT,
          month TEXT,
          monthlyTasks TEXT,
          customDateTime TEXT,
          completed BOOLEAN DEFAULT FALSE
        )
        ''');
      }
      return await db.insert('todos', todo);
    } catch (e) {
      print('Error inserting todo: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    Database db = await instance.database;
    var todos = await db.query('todos', orderBy: 'id DESC');
    print('Retrieved ${todos.length} todos from local database');
    return todos;
  }

  Future<int> updateTodo(int id, Map<String, dynamic> todo) async {
    Database db = await instance.database;
    return await db.update('todos', todo, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTodo(int id) async {
    Database db = await instance.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}