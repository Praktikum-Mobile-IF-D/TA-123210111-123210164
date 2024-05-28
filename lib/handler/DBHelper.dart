import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ta_123210111_123210164/model/user.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;
  DBHelper._();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if(_database != null) return _database!;

    _database = await getDb();
    return _database!;
  }

  Future<Database> getDb() async {
    String path =
    join(await getDatabasesPath(), 'mangakobra.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate:  _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, favorites TEXT, image TEXT)');
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toJson());
  }

  Future<List<User>> retrieveUsers() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('users');
    return List.generate(result.length, (i) {
      return User.fromJson(result[i]);
    });
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: "id = ?",
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: "id = ?",
      whereArgs: [id],
    );
  }
  //
  // Future<int> insertUser(String username, String password, String favorite, String img) async {
  //   final db = await database;
  //   return await db.insert('users', {
  //     'username': username,
  //     'password': password,
  //     'favorites': favorite,
  //     'image': img,
  //   });
  // }
  //
  Future<Map<String, dynamic>?> check(String username, String password) async {
    final db = await database;
    final response = await db.query('users',
        where: 'username = ? AND password = ?',
        whereArgs: [username,password]);

    return response.isNotEmpty ? response.first : null;
  }
  //
  // Future<int> insertPurchases(int userId, String vehicle, String dateArrival) async {
  //   final db = await database;
  //   return await db.insert('purchases', {
  //     'userid': userId,
  //     'vehicle': vehicle,
  //     'date_arrival': dateArrival,
  //   });
  // }
  //
  // Future<List<Map<String, dynamic>>?> getPurchases(int userId) async {
  //   final db = await database;
  //   final response = await db.query('purchases',
  //       where: 'userid = ?',
  //       whereArgs: [userId]);
  //
  //   if(response.isNotEmpty) return response;
  //   return null;
  // }
}