import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('money_mate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        warna INTEGER NOT NULL,
        ikon TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        nominal REAL NOT NULL,
        tanggal TEXT NOT NULL,
        kategori TEXT NOT NULL,
        deskripsi TEXT,
        isPemasukan INTEGER NOT NULL
      )
    ''');
  }

  // CATEGORY
  Future<int> insertCategory(Map<String, dynamic> map) async {
    final db = await instance.database;
    return await db.insert('categories', map);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await instance.database;
    return await db.query('categories', orderBy: 'nama');
  }

  Future<int> deleteCategory(String id) async {
    final db = await instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // TRANSACTION
  Future<int> insertTransaction(Map<String, dynamic> map) async {
    final db = await instance.database;
    return await db.insert('transactions', map);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await instance.database;
    return await db.query('transactions', orderBy: 'tanggal DESC');
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}