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
    _database = await _getDB();
    return _database!;
  }

  static const int _version = 5;
  static const String _dbName = "cari_kampus.db";

  Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE kampus_catatan ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "name TEXT, "
          "short_name TEXT, "
          "type TEXT, "
          "group_pt TEXT, "
          "address TEXT, "
          "province_name TEXT, "
          "regency_name TEXT, "
          "domain TEXT, "
          "web_page TEXT, "
          "catatan TEXT"
          ")"
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Simplest upgrade: drop and recreate since it's a student project
          await db.execute("DROP TABLE IF EXISTS kampus_catatan");
          await db.execute(
            "CREATE TABLE kampus_catatan ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "name TEXT, "
            "short_name TEXT, "
            "type TEXT, "
            "group_pt TEXT, "
            "address TEXT, "
            "province_name TEXT, "
            "regency_name TEXT, "
            "domain TEXT, "
            "web_page TEXT, "
            "catatan TEXT"
            ")"
          );
        }
      },
      version: _version,
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
