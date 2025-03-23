import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String tableName = 'offline_data';

  static Database? _database;

  /// ✅ Initialize Database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// ✅ Database Initialization
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_data.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            storageCode TEXT,
            serialNo TEXT,
            itemName TEXT,
            brand TEXT,
            expirationDate TEXT,
            unitMeasurement TEXT,
            specification TEXT,
            quantity INTEGER,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  /// ✅ Insert Data - Fixes the Map Data Insertion
  Future<void> insertData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(tableName, data);


  }



  // Inside DatabaseHelper class
  Future<void> updateQuantity(int id, int newQuantity) async {
    final db = await database;
    await db.update(
      tableName,
      { 'quantity': newQuantity },  // Corrected column reference
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  /// ✅ DELETE DATA BY ID
  Future<void> deleteDataById(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ✅ Clear Entire Database (Optional)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(tableName);
  }
}
