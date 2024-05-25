import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user.dart';

class DatabaseHandler {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDB();
    return _database!;
  }

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    await deleteDatabase(join(path, 'user.db'));
    return openDatabase(
      join(path, 'user.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, favorites TEXT, image TEXT)",
        );
      },
      version: 2,
    );
  }

  Future<int> insertUser(User user) async {
    Database db = await this.database;
    return await db.insert('users', user.toJson());
  }

  Future<List<User>> retrieveUsers() async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query('users');
    return List.generate(result.length, (i) {
      return User.fromJson(result[i]);
    });
  }

  Future<int> updateUser(User user) async {
    Database db = await this.database;
    return await db.update(
      'users',
      user.toJson(),
      where: "id = ?",
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await this.database;
    return await db.delete(
      'users',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}