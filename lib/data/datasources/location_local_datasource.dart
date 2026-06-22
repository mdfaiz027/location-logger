import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:location_logger_app/data/models/location_model.dart';

class LocationLocalDatasource {
  static Database? _database;
  static const String tableName = 'locations';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(dir.path, 'location_logger.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            session_id TEXT NOT NULL
          )
        ''');
        // Index for faster queries by session
        await db.execute('CREATE INDEX idx_session ON $tableName(session_id)');
      },
    );
  }

  Future<int> insertLocation(LocationModel location) async {
    final db = await database;
    return await db.insert(tableName, location.toMap());
  }

  Future<List<LocationModel>> getAllLocations() async {
    final db = await database;
    final result = await db.query(tableName, orderBy: 'timestamp ASC');
    return result.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getLocationsBySession(String sessionId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return result.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> clearSession(String sessionId) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> countLocations() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<LocationModel?> getLastLocation() async {
    final db = await database;
    final result = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return LocationModel.fromMap(result.first);
    }
    return null;
  }
}