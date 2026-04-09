import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/board.dart';
import '../models/board_column.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flowboard.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE boards(
            id TEXT PRIMARY KEY,
            title TEXT,
            backgroundColor TEXT,
            columns_data TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveBoards(List<Board> boards) async {
    final db = await database;
    await db.delete('boards');
    for (var board in boards) {
      await db.insert('boards', {
        'id': board.id,
        'title': board.title,
        'backgroundColor': board.backgroundColor,
        'columns_data': jsonEncode(_encodeColumns(board.columns)),
      });
    }
  }

  Future<List<Board>> getBoards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('boards');
    
    return maps.map((map) {
      return Board(
        id: map['id'],
        title: map['title'],
        backgroundColor: map['backgroundColor'],
        columns: _decodeColumns(map['columns_data']),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _encodeColumns(List<BoardColumn> columns) {
    return columns.map((col) => {
      'id': col.id,
      'title': col.title,
      'tasks': col.tasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'labels': t.labels,
        'dueDate': t.dueDate?.toIso8601String(),
        'priority': t.priority.name,
        'checklist': t.checklist.map((c) => {
          'id': c.id,
          'title': c.title,
          'isDone': c.isDone,
        }).toList(),
      }).toList(),
    }).toList();
  }

  List<BoardColumn> _decodeColumns(String jsonStr) {
    final List<dynamic> data = jsonDecode(jsonStr);
    return data.map((colMap) {
      return BoardColumn(
        id: colMap['id'],
        title: colMap['title'],
        tasks: (colMap['tasks'] as List).map((t) {
          return Task(
            id: t['id'],
            title: t['title'],
            description: t['description'] ?? '',
            labels: List<String>.from(t['labels'] ?? []),
            dueDate: t['dueDate'] != null ? DateTime.parse(t['dueDate']) : null,
            priority: TaskPriority.values.firstWhere(
              (e) => e.name == (t['priority'] ?? 'low'),
              orElse: () => TaskPriority.low,
            ),
            checklist: (t['checklist'] as List? ?? []).map((c) => ChecklistItem(
              id: c['id'],
              title: c['title'],
              isDone: c['isDone'] ?? false,
            )).toList(),
          );
        }).toList(),
      );
    }).toList();
  }
}
