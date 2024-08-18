import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cart_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Create cart table
        db.execute(
          'CREATE TABLE cart(id INTEGER PRIMARY KEY AUTOINCREMENT, productTitle TEXT, quantity INTEGER, price REAL)',
        );
        // Create users table
        db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT, firstName TEXT, lastName TEXT, age INTEGER)',
        );
      },
    );
  }

  // Cart Table CRUD operations
  Future<void> insertItem(
      String productTitle, int quantity, double price) async {
    final db = await database;
    await db!.insert(
      'cart',
      {'productTitle': productTitle, 'quantity': quantity, 'price': price},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(String productTitle, int quantity) async {
    final db = await database;
    await db!.update(
      'cart',
      {'quantity': quantity},
      where: 'productTitle = ?',
      whereArgs: [productTitle],
    );
  }

  Future<void> deleteItem(String productTitle) async {
    final db = await database;
    await db!.delete(
      'cart',
      where: 'productTitle = ?',
      whereArgs: [productTitle],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllItems() async {
    final db = await database;
    return await db!.query(
      'cart',
      orderBy: 'id DESC', // Order by ID, latest first
    );
  }

  Future<List<Map<String, dynamic>>> queryItem(String productTitle) async {
    final db = await database;
    return await db!.query(
      'cart',
      where: 'productTitle = ?',
      whereArgs: [productTitle],
    );
  }

  // Users Table CRUD operations
  Future<void> insertUser(String username, String password, String firstName,
      String lastName, int age) async {
    try {
      final db = await database;
      await db!.insert(
        'users',
        {
          'username': username,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Use .ignore if needed
      );
    } catch (e) {
      print("Error inserting user: $e");
    }
  }

  Future<void> updateUser(int id, String username, String password,
      String firstName, String lastName, int age) async {
    final db = await database;
    await db!.update(
      'users',
      {
        'username': username,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db!.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    final db = await database;
    return await db!.query(
      'users',
      orderBy: 'id DESC', // Order by ID, latest first
    );
  }

  Future<Map<String, dynamic>?> queryUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> userExists(String username, String password) async {
    final db = await database;
    final result = await db!.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }
}
