import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'innerscape.db');

    return openDatabase(
      path,
      version: kMigrations.length,
      onCreate: (db, version) async {
        for (final sql in kMigrations) {
          await db.execute(sql);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int i = oldVersion; i < newVersion; i++) {
          await db.execute(kMigrations[i]);
        }
      },
    );
  }
}
