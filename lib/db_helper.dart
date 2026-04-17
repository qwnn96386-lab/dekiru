import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Shop {
  final int? id;
  final String name;
  final double lat;
  final double lng;

  Shop({this.id, required this.name, required this.lat, required this.lng});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'lat': lat, 'lng': lng};
}

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'shops_manager.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE shops(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lat REAL, lng REAL)",
      );
    });
  }

  Future<void> insertShop(Shop shop) async {
    final dbClient = await db;
    await dbClient.insert('shops', shop.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Shop>> getShops() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('shops');
    return maps.map((m) => Shop(
      id: m['id'],
      name: m['name'],
      lat: m['lat'],
      lng: m['lng'],
    )).toList();
  }

  Future<void> deleteShop(int id) async {
    final dbClient = await db;
    await dbClient.delete('shops', where: 'id = ?', whereArgs: [id]);
  }
}