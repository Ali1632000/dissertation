import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist/models/task_model.dart';

class TaskDatabaseHelper {
  static final TaskDatabaseHelper _instance = TaskDatabaseHelper.internal();

  factory TaskDatabaseHelper() => _instance;

  static Database? _db;

  TaskDatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        priority TEXT,
        dateTime TEXT,
        color INTEGER
      )
    ''');
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    Database dbClient = await db;
    return await dbClient.insert('tasks', task);
  }

  Future<List<Task>> getTasks() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query('tasks');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> deleteTask(int taskId) async {
    Database dbClient = await db;
    return await dbClient.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  Future<int> deleteAllTasks() async {
    Database dbClient = await db;
    return await dbClient.delete('tasks');
  }
}
