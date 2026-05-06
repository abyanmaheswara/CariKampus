import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'kampus_tracking.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kampus_catatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            domain TEXT,
            web_page TEXT,
            country TEXT,
            catatan TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS kampus_catatan');
        await db.execute('''
          CREATE TABLE kampus_catatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            domain TEXT,
            web_page TEXT,
            country TEXT,
            catatan TEXT
          )
        ''');
      }
    );
  }

  Future<int> insertKampus(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('kampus_catatan', data);
  }

  Future<List<Map<String, dynamic>>> getAllKampus() async {
    final db = await database;
    return await db.query('kampus_catatan');
  }

  Future<int> updateKampus(Map<String, dynamic> data) async {
    final db = await database;
    int id = data['id'];
    return await db.update('kampus_catatan', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteKampus(int id) async {
    final db = await database;
    return await db.delete('kampus_catatan', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> searchKampus(String keyword) async {
    final db = await database;
    if (keyword.isEmpty) {
      return await db.query('kampus_catatan');
    }
    return await db.query('kampus_catatan', where: 'name LIKE ?', whereArgs: ['%$keyword%']);
  }
}
